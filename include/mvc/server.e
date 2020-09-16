
namespace server

include std/console.e
include std/map.e
include std/net/url.e
include std/sequence.e
include std/socket.e as socket
include std/text.e
include std/types.e

ifdef WINDOWS then
include std/dll.e
include std/machine.e
end ifdef

include mvc/logger.e
include mvc/app.e
include mvc/headers.e
include mvc/hooks.e

constant DEFAULT_ADDR = "127.0.0.1"
constant DEFAULT_PORT = 5000

constant PROTOCOL_NONE = 0
constant SOCKET_BACKLOG = 10
constant SOCKET_TIMEOUT_SEC = 0
constant SOCKET_TIMEOUT_MICRO = 100000

integer m_server_running = FALSE

ifdef WINDOWS then

atom shell32 = open_dll( "shell32.dll" )
constant xShellExecuteA = define_c_func( shell32, "ShellExecuteA", {C_HANDLE,C_POINTER,C_POINTER,C_POINTER,C_POINTER,C_INT}, C_HANDLE )

constant SW_SHOWNORMAL = 1

function _( object str, integer cleanup = TRUE )
	
	if sequence( str ) then
		return allocate_string( str, cleanup )
	end if
	
	return str
end function

function ShellExecuteA( atom hwnd = NULL, object lpOperation = NULL, object lpFile = NULL, object lpParameters = NULL, object lpDirectory = NULL, integer nShowCmd = SW_SHOWNORMAL )
	return c_func( xShellExecuteA, {hwnd,_(lpOperation),_(lpFile),_(lpParameters),_(lpDirectory),nShowCmd} )
end function

end ifdef

public procedure start_url( sequence url )

ifdef WINDOWS then
	ShellExecuteA( NULL, "open", url )
elsifdef LINUX then
	-- FIXME
end ifdef

end procedure

public procedure client_handler( socket client_sock, sequence client_addr )

	object request_data = socket:receive( client_sock )

	if atom( request_data ) then
		log_error( "Could not receive request data (%d)", socket:error_code() )
		return
	end if

	integer received_bytes = length( request_data )
	request_data = split( request_data, "\r\n" )

	log_debug( "Received %d bytes from %s", {received_bytes,client_addr} )

	sequence request_info = split( request_data[1], " " ) -- e.g. {"GET","/path","HTTP/1.1"}
	sequence request_method = request_info[1]
	sequence path_info      = request_info[2]
	sequence http_protocol  = request_info[3]
	sequence query_string   = ""

	log_trace( "request_method = %s", {request_method} )
	log_trace( "path_info = %s",      {path_info} )
	log_trace( "http_protocol = %s",  {http_protocol} )
	log_trace( "query_string = %s",   {query_string} )

	if find( '?', path_info ) then
		{path_info,query_string} = split( path_info, '?' )
	end if

	if equal( request_method, "POST" ) then
		if length( query_string ) then
			query_string &= "&"
		end if
		query_string &= request_data[$]
	end if

	path_info = url:decode( path_info )
	query_string = url:decode( query_string )

	sequence response_data = handle_request( path_info, request_method, query_string )

	if run_hooks( HOOK_HEADERS_START ) then
		socket:close( client_sock )
		return
	end if

	sequence status = get_header( "Status", "200 OK" )
	sequence headers = format_headers()
	clear_headers()

	log_trace( "status = %s", {status} )
	log_trace( "headers = %s", {headers} )

	log_info( "%s %s %s %s", {client_addr,request_method,path_info,status} )

	if run_hooks( HOOK_HEADERS_END ) then
		socket:close( client_sock )
		return
	end if

	integer sent_bytes = socket:send( client_sock,
		"HTTP/1.1 " & status & "\r\n" &
		headers & "\r\n" & response_data
	)

	log_debug( "Send %d bytes to %s", {sent_bytes,client_addr} )

	if sent_bytes = -1 then
		log_error( "Could not send response data (%d)", socket:error_code() )
	end if

	socket:shutdown( client_sock )
	socket:close( client_sock )

	log_debug( "Closed connection from %s", {client_addr} )

	delete( client_sock )

end procedure

public function create_server( sequence listen_addr, integer listen_port )

	log_info( "Euphoria MVC Development Server" )
	set_server_signature( "Euphoria MVC development server at %s:%d", {listen_addr,listen_port} )

	object server_sock = socket:create( AF_INET, SOCK_STREAM, PROTOCOL_NONE )

	if atom( server_sock ) then
		log_error( "Could not create server socket (%d)", socket:error_code() )
		return 0
	end if

	log_debug( "Created server socket" )

	if socket:set_option( server_sock, SOL_SOCKET, SO_REUSEPORT, TRUE ) != OK then
		log_warn( "Could not set socket option SO_REUSEPORT (%d)", socket:error_code() )
	end if

	if socket:bind( server_sock, listen_addr, listen_port ) != OK then
		log_error( "Could not bind server socket (%d)", socket:error_code() )
		return 0
	end if

	if socket:listen( server_sock, SOCKET_BACKLOG ) != OK then
		log_error( "Could not listen on server socket (%d)", socket:error_code() )
		return 0
	end if

	log_debug( "Listening on %s:%d", {listen_addr,listen_port} )

	allow_break( FALSE )
	m_server_running = TRUE

	log_info( "Press Ctrl+C to quit" )
	log_debug( "Waiting for client..." )

	return server_sock
end function

public function server_loop( object server_sock )

	if not m_server_running then
		log_error( "Server not started!" )
		return FALSE
	end if

	object result = socket:select( server_sock, {}, {}, SOCKET_TIMEOUT_SEC, SOCKET_TIMEOUT_MICRO )

	if sequence( result ) and result[1][SELECT_IS_READABLE] then

		object client_info = socket:accept( server_sock )

		if atom( client_info ) then

			log_error( "Could not accept client socket (%d)", socket:error_code() )

		else

			log_debug( "Accepted connection from %s", {client_info[2]} )
			client_handler( client_info[1], client_info[2] )

		end if

	end if

	if check_break() then

		log_info( "Ctrl+C triggered shutdown" )
		m_server_running = FALSE

	end if

	return m_server_running
end function

public procedure start( sequence listen_addr = DEFAULT_ADDR, integer listen_port = DEFAULT_PORT )

	object server_sock = create_server( listen_addr, listen_port )

	if run_hooks( HOOK_APP_START ) then
		socket:close( server_sock )
		return
	end if

	m_server_running = TRUE

	sequence url = sprintf( "http://%s:%d", {listen_addr,listen_port} )
	log_info( "Running on %s", {url} )

ifdef AUTO_LAUNCH then

	log_debug( "Launching %s", {url} )
	start_url( url )

end ifdef

	while server_loop( server_sock ) do
		task_yield()
	end while

	if run_hooks( HOOK_APP_END ) then
		socket:close( server_sock )
		return
	end if

	socket:shutdown( server_sock )
	socket:close( server_sock )

	log_debug( "Closed server socket" )

ifdef APP_DEBUG then
	dump_ram_space()
end ifdef

end procedure

public procedure stop()

	m_server_running = FALSE

end procedure


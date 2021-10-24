
namespace server

include std/console.e
include std/convert.e
--include std/map.e
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
include mvc/mapdbg.e as map
include mvc/utils.e

public constant DEFAULT_ADDR = "127.0.0.1"
public constant DEFAULT_PORT = 5000

constant PROTOCOL_NONE = 0
constant SOCKET_BACKLOG = 10
constant SOCKET_RCVBUF = 4096
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

	integer received_bytes = 0
	object request_buff = socket:receive( client_sock )

	if atom( request_buff ) then
		log_error( "Could not receive request data (%d)", socket:error_code() )
		return
	end if

	received_bytes += length( request_buff )

	integer request_sep = match( "\r\n\r\n", request_buff )

	while request_sep = 0 do

		object request_temp = socket:receive( client_sock )

		if atom( request_temp ) then
			log_error( "Could not receive request data (%d)", socket:error_code() )
			return
		end if

		received_bytes += length( request_temp )

		if length( request_temp ) = 0 then
			exit
		end if

		request_buff &= request_temp
		request_sep = match( "\r\n\r\n", request_buff )

	end while

	sequence request_head = request_buff[1..request_sep-1]
	sequence request_body = request_buff[request_sep+4..$]

	sequence request_headers = split( request_head, "\r\n" )
	request_headers[1] = split( request_headers[1], " " )

	sequence request_method = request_headers[1][1]
	sequence request_path   = request_headers[1][2]
	sequence request_proto  = request_headers[1][3]
	request_headers = request_headers[2..$]

	log_trace( "request_method = %s",  {request_method} )
	log_trace( "request_path = %s",    {request_path} )
	log_trace( "request_proto = %s",   {request_proto} )

	integer content_length = 0
	sequence query_string = ""

	for i = 1 to length( request_headers ) do
		request_headers[i] = split( request_headers[i], ": " )
		if equal( request_headers[i][1], "Content-Length" ) then
			content_length = to_integer( request_headers[i][2] )
		end if
	end for

	log_trace( "request_headers = %s", {request_headers} )
	log_trace( "content_length = %d",  {content_length} )

	while length( request_body ) < content_length do

		request_buff = socket:receive( client_sock )

		if atom( request_buff ) then
			log_error( "Could not receive request data (%d)", socket:error_code() )
			return
		end if

		received_bytes += length( request_buff )

		if length( request_buff ) = 0 then
			exit
		end if

		request_body &= request_buff

	end while

	delete( request_buff )

	log_trace( "received %d bytes", received_bytes )

	if equal( request_method, "GET" ) then

		integer query_sep = find( '?', request_path )

		if query_sep then
			query_string = request_path[query_sep+1..$]
			request_path = request_path[1..query_sep-1]
		end if

	elsif equal( request_method, "POST" ) then

		if length( query_string ) then
			query_string &= "&"
		end if

		query_string &= request_body

	end if

	delete( request_body )

	request_path = url_decode( request_path )

	sequence response_data = handle_request( request_path, request_method, query_string, request_headers )

	if run_hooks( HOOK_HEADERS_START ) then
		socket:close( client_sock )
		return
	end if

	sequence status = get_header( "Status", "200 OK" )
	sequence headers = format_headers()

	clear_headers()

	log_trace( "status = %s", {status} )
	log_trace( "headers = %s", {headers} )

	log_info( "%s %s %s %s", {client_addr,request_method,request_path,status} )

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

	ifdef MAPDBG then
		print_maps()
	end ifdef

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

	integer result

	result = socket:set_option( server_sock, SOL_SOCKET, SO_RCVBUF, SOCKET_RCVBUF )

	if result != SOCKET_RCVBUF then
		log_warn( "Could not set socket option SO_RCVBUF (%d)", {result} )
	end if

	result = socket:set_option( server_sock, SOL_SOCKET, SO_REUSEADDR, TRUE )

	if result != TRUE then
		log_warn( "Could not set socket option SO_REUSEADDR (%d)", {result} )
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

	if atom( server_sock ) or not m_server_running then
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

	while sequence( server_sock ) and m_server_running do

		server_loop( server_sock )
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


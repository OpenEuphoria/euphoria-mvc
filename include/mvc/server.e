
namespace server

include std/map.e
include std/sequence.e
include std/socket.e as socket
include std/text.e
include std/types.e

ifdef WINDOWS then
include std/dll.e
include std/machine.e
end ifdef

include mvc/app.e
include mvc/logger.e

constant DEFAULT_ADDR = "127.0.0.1"
constant DEFAULT_PORT = 5000

constant PROTOCOL_NONE = 0
constant SOCKET_BACKLOG = 10

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

	integer exit_code = 0
	object request_data = socket:receive( client_sock )

	if atom( request_data ) then
		log_error( "Could not receive request data (%d)", socket:error_code() )
		return
	end if

	integer received_bytes = length( request_data )
	log_trace( "received_bytes = %d", {received_bytes} )

	request_data = split( request_data, "\r\n" )
	request_data[1] = split( request_data[1], " " ) -- e.g. {"HTTP/1.1","GET","/path"}

	sequence path_info      = request_data[1][2]
	sequence request_method = request_data[1][1]
	sequence query_string   = "" -- FIXME

	log_trace( "path_info = %s", {path_info} )
	log_trace( "request_method = %s", {request_method} )
	log_trace( "query_string = %s", {query_string} )

	sequence response_data = handle_request( path_info, request_method, query_string )

	exit_code = run_hooks( HOOK_HEADERS_START )
	if exit_code then return end if

	sequence status = map:get( m_headers, "Status", "200 OK" )
	sequence headers = format_headers( m_headers )

	log_trace( "status = %s", {status} )
	log_trace( "headers = %s", {headers} )

	log_info( "%s %s %s %s", {client_addr,request_method,path_info,status} )

	map:remove( m_headers, "Status" )

	exit_code = run_hooks( HOOK_HEADERS_END )
	if exit_code then return end if

	integer sent_bytes = socket:send( client_sock,
		"HTTP/1.1 " & status & "\r\n" &
		headers & "\r\n" & response_data
	)
	
	log_trace( "sent_bytes = %d", {sent_bytes} )
	
	if sent_bytes = -1 then
		log_error( "Could not send response data (%d)", socket:error_code() )
	end if

end procedure

public procedure run_server( sequence listen_addr, integer listen_port )

	integer exit_code = 0
	socket server_sock = socket:create( AF_INET, SOCK_STREAM, PROTOCOL_NONE )

	log_info( "Euphoria MVC Development Server" )

	if atom( server_sock ) then
		log_error( "Could not create server socket (%d)", socket:error_code() )
		return
	end if

	log_debug( "Created server socket" )

	if socket:bind( server_sock, listen_addr, listen_port ) != OK then
		log_error( "Could not bind server socket (%d)", socket:error_code() )
		return
	end if

	if socket:listen( server_sock, SOCKET_BACKLOG ) != OK then
		log_error( "Could not listen on server socket (%d)", socket:error_code() )
		return
	end if

	log_debug( "Listening on %s:%d", {listen_addr,listen_port} )

	exit_code = run_hooks( HOOK_APP_START )
	if exit_code then return end if

	sequence url = sprintf( "http://%s:%d", {listen_addr,listen_port} )
	log_info( "Running on %s", {url} )

ifdef LAUNCH_URL then

	log_debug( "Launching %s", {url} )
	start_url( url )

end ifdef

	allow_break( FALSE )
	m_server_running = TRUE

	log_info( "Press Ctrl+C to quit" )
	log_debug( "Waiting for client..." )

	while m_server_running do

		sequence result = socket:select( server_sock, {}, {}, 0, 100 )

		if result[1][SELECT_IS_READABLE] then

			object client_info = socket:accept( server_sock )

			if atom( client_info ) then
				log_error( "Could not accept client socket (%d)", socket:error_code() )
				continue
			end if

			log_debug( "Accepted connection from %s", {client_info[2]} )

			client_handler( client_info[1], client_info[2] )
			socket:close( client_info[1] )

			log_debug( "Closed connection from %s", {client_info[2]} )
			log_debug( "Waiting for client..." )

		end if

		if check_break() then
			log_info( "Ctrl+C triggered shutdown" )
			m_server_running = FALSE
		end if

		task_yield()

	end while

	exit_code = run_hooks( HOOK_APP_END )
	if exit_code then return end if

	socket:close( server_sock )
	log_debug( "Closed server socket" )

end procedure

public procedure start( sequence listen_addr = DEFAULT_ADDR, integer listen_port = DEFAULT_PORT )

	run_server( listen_addr, listen_port )

end procedure

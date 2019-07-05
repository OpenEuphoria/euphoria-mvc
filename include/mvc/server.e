
namespace server

include std/map.e
include std/sequence.e
include std/socket.e as socket
include std/text.e
include std/types.e

include mvc/app.e
include mvc/logger.e

constant DEFAULT_ADDR = "127.0.0.1"
constant DEFAULT_PORT = 5000

constant PROTOCOL_NONE = 0
constant SOCKET_BACKLOG = 10

integer m_server_running = FALSE

public procedure client_handler( socket client_sock, sequence client_addr )

	integer exit_code

	object request_data = socket:receive( client_sock )

	if atom( request_data ) then
		log_error( "Could not receive request data" )
		? socket:error_code()
		socket:close( client_sock )
		return
	end if

	log_trace( "Received %d bytes", length(request_data) )
	log_debug( "Request data:\n%s", {request_data} )

	request_data = split( request_data, "\n" )
	request_data[1] = split( request_data[1], " " )

	sequence path_info      = request_data[1][2]
	sequence request_method = request_data[1][1]
	sequence query_string   = ""

	sequence response_data = handle_request( path_info, request_method, query_string )

	exit_code = run_hooks( HOOK_HEADERS_START )
	if exit_code then return end if

	sequence status = map:get( m_headers, "Status", "200 OK" )

	sequence headers = map:keys( m_headers )
	sequence headers_data = "HTTP/1.1 " & status & "\r\n"

	for i = 1 to length( headers ) do

		object value = map:get( m_headers, headers[i] )

		if sequence_array( value ) then
			for j = 1 to length( value ) do
				headers_data &= sprintf( "%s: %s\r\n", {headers[i],value[j]} )
			end for
		else
			if atom( value ) then value = sprint( value ) end if
			headers_data &= sprintf( "%s: %s\r\n", {headers[i],value} )
		end if

	end for

	response_data = headers_data & "\r\n" & response_data
	delete( headers_data )

	exit_code = run_hooks( HOOK_HEADERS_END )
	if exit_code then return end if

	log_debug( "Response data:\n%s", {response_data} )

	integer sent_bytes = socket:send( client_sock, response_data )
	
	if sent_bytes = -1 then
		log_error( "Could not send response data" )
	else
		log_trace( "Sent %d bytes", sent_bytes )
	end if

	socket:close( client_sock )

end procedure

public procedure start( sequence listen_addr = DEFAULT_ADDR, integer listen_port = DEFAULT_PORT )

	socket server_sock = socket:create( AF_INET, SOCK_STREAM, PROTOCOL_NONE )

	if atom( server_sock ) then
		log_error( "Could not create server socket" )
		? socket:error_code()
		return
	end if

	log_trace( "Created server socket" )

	if socket:bind( server_sock, listen_addr, listen_port ) != OK then
		log_error( "Could not bind server socket" )
		? socket:error_code()
		return
	end if

	if socket:listen( server_sock, SOCKET_BACKLOG ) != OK then
		log_error( "Could not listen on server socket" )
		? socket:error_code()
		return
	end if

	log_info( "Euphoria MVC Development Server" )
	log_info( "Running on http://%s:%d", {listen_addr,listen_port} )
	log_info( "Press Ctrl+C to quit" )

	integer exit_code

	exit_code = run_hooks( HOOK_APP_START )
	if exit_code then return end if

	m_server_running = TRUE

	while m_server_running do

		object client_info = socket:accept( server_sock )

		if atom( client_info ) then
			log_error( "Could not accept client socket" )
			? socket:error_code()
			return
		end if

		socket client_sock = client_info[1]
		sequence client_addr = client_info[2]

		log_debug( "Accepted connection from %s", {client_addr} )

		client_handler( client_sock, client_addr )

	end while

	exit_code = run_hooks( HOOK_APP_END )
	if exit_code then return end if

	socket:close( server_sock )

end procedure


namespace app

include std/convert.e
include std/error.e
include std/map.e
include std/io.e
include std/pretty.e
include std/regex.e
include std/search.e
include std/sequence.e
include std/net/url.e
include std/text.e
include std/types.e
include std/utils.e

include mvc/logger.e
include mvc/template.e

public include mvc/hooks.e
public include mvc/headers.e
public include mvc/utils.e

--
-- Debugging
--

ifdef APP_DEBUG then

set_log_level( LOG_DEBUG )
log_info( "Application debugging mode enabled" )

-- TODO: add crash handler

public function crash_handler( integer param )


	return 0 and param
end function
crash_routine( routine_id("crash_handler") )

end ifdef

--
-- Route Parsing
--

-- current route and path
sequence m_current_route
sequence m_current_path

-- variable name only
constant re_varonly = regex:new( `^<([_a-zA-Z][_a-zA-Z0-9]*)>$` )

-- variable with type
constant re_vartype = regex:new( `^<([_a-zA-Z][_a-zA-Z0-9]*):(atom|integer|string|object)>$` )

-- variable with optional types
--constant re_variable = regex:new( `<([_a-zA-Z)[_a-zA-Z0-9]*)(?:\:(atom|integer|string|object))?>` )
constant re_variable = regex:new( `<([_a-zA-Z)[_a-zA-Z0-9]*)(?:\:(.+))?>` )

-- type identifier patterns
map m_regex = map:new()
map:put( m_regex, "atom",    regex:new(`([-]?[0-9]*\.[0-9]+)`) )
map:put( m_regex, "integer", regex:new(`([-]?[0-9]+)`) )
map:put( m_regex, "string",  regex:new(`([\w\d\.\/]+)`) )
map:put( m_regex, "object",  regex:new(`([^\s\/]+)`) )

--
-- Route Lookup
--

-- name -> pattern lookup
map m_names = map:new()

-- pattern -> data storage
map m_routes = map:new()

--
-- HTTP Status Codes
--

-- status -> description
map m_status = map:new_from_kvpairs({
	-- 1xx Information Response
	{ 100, "Continue" },
	{ 101, "Switching Protocols" },
	{ 102, "Processing" },
	{ 103, "Early Hints" },
	-- 2xx Success
	{ 200, "OK" },
	{ 201, "Created" },
	{ 202, "Accepted" },
	{ 203, "Non-Authoritative Information" },
	{ 204, "No Content" },
	{ 205, "Reset Content" },
	{ 206, "Partial Content" },
	{ 207, "Multi-Status" },
	{ 208, "Already Reported" },
	{ 226, "IM Used" },
	-- 3xx Redirection
	{ 300, "Multiple Choices" },
	{ 301, "Moved Permanently" },
	{ 302, "Found" },
	{ 303, "See Other" },
	{ 304, "Not Modified" },
	{ 305, "Use Proxy" },
	{ 306, "Switch Proxy" },
	{ 307, "Temporary Redirect" },
	{ 308, "Permanent Redirect" },
	-- 4xx Client Errors
	{ 400, "Bad Request" },
	{ 401, "Unauthorized" },
	{ 403, "Forbidden" },
	{ 404, "Not Found" },
	{ 405, "Method Not Allowed" },
	{ 406, "Not Acceptable" },
	{ 407, "Proxy Authentication Required" },
	{ 408, "Request Timeout" },
	{ 409, "Conflict" },
	{ 410, "Gone" },
	{ 411, "Length Required" },
	{ 412, "Precondition Failed" },
	{ 413, "Payload Too Large" },
	{ 414, "URI Too Long" },
	{ 415, "Unsupported Media Type" },
	{ 416, "Range Not Satisfied" },
	{ 417, "Expectation Failed" },
	{ 418, "I'm a teapot" },
	{ 421, "Misdirected Request" },
	{ 422, "Unprocessable Entity" },
	{ 423, "Locked" },
	{ 424, "Failed Dependency" },
	{ 426, "Upgrade Required" },
	{ 428, "Precondition Required" },
	{ 429, "Too Many Requests" },
	{ 431, "Request Header Fields Too Large" },
	{ 451, "Unavailable for Legal Reasons" },
	-- 5xx Server Errors
	{ 500, "Internal Server Error" },
	{ 501, "Not Implemented" },
	{ 502, "Bad Gateway" },
	{ 503, "Service Unavailable" },
	{ 504, "Gateway Timeout" },
	{ 505, "HTTP Version Not Supported" },
	{ 506, "Variant Also Negotiates" },
	{ 507, "Insufficient Storage" },
	{ 508, "Loop Detected" },
	{ 510, "Not Extended" },
	{ 511, "Network Authentication Required" }
})

--
-- Error Page Template
--

sequence SERVER_SIGNATURE = getenv( "SERVER_SIGNATURE" )

constant DEFAULT_ERROR_PAGE = """
<!DOCTYPE html>
<html>
<head>
  <title>{{ title }}</title>
</head>
<body>
  <h1>{{ title }}</h1>
  <p>{{ message }}</p>
  <hr>
  <p><em>{{ signature }}</em></p>
  </body>
</html>

"""

map m_error_page = map:new()

--
-- Returns the error page template defined for the response code.
--
public function get_error_page( integer error_code )

	log_trace( "error_code = %s", {error_code} )

	return map:get( m_error_page, error_code, DEFAULT_ERROR_PAGE )
end function

--
-- Set the error page template defined for the response code.
--
public procedure set_error_page( integer error_code, sequence error_page )

	log_trace( "error_code = %s", {error_code} )
	log_trace( "error_page = %s", {error_page}, LOG_VERBOSE )

	map:put( m_error_page, error_code, error_page )

	log_debug( "Registered custom %d error page", {error_code} )

end procedure

--
-- Override the default "SERVER_SIGNATURE" environment variable.
--
public procedure set_server_signature( sequence signature, object data = {} )

	SERVER_SIGNATURE = sprintf( signature, data )

end procedure

--
-- Variables
--

--
-- Return TRUE if an item looks like a variable.
--
public function is_variable( sequence item )
	return regex:is_match( re_varonly, item )
		or regex:is_match( re_vartype, item )
end function

--
-- Parse a variable and return its name and type.
--
public function parse_variable( sequence var_item )

	sequence var_name = ""
	sequence var_type = "object"

	if regex:is_match( re_varonly, var_item ) then
		{?,var_name} = regex:matches( re_varonly, var_item )

	elsif regex:is_match( re_vartype, var_item ) then
		{?,var_name,var_type} = regex:matches( re_vartype, var_item )

	end if

	log_trace( "var_item = %s", {var_item} )
	log_trace( "var_name = %s", {var_name} )
	log_trace( "var_type = %s", {var_type} )

	return {var_name,var_type}
end function

--
-- Routing
--

enum
	ROUTE_PATH,
	ROUTE_NAME,
	ROUTE_VARS,
	ROUTE_METHODS,
	ROUTE_RID

--
-- Return the current route name.
--
public function get_current_route()

	if object( m_current_route ) then
		return m_current_route
	end if

	return ""
end function

--
-- Return the current route path.
--
public function get_current_path()

	if object( m_current_path ) then
		return m_current_path
	end if

	return ""
end function

--
-- Build a URL from a route using optional response object.
--
public function url_for( sequence route_name, object response = {} )

	sequence default = "#" & route_name

	regex pattern = map:get( m_names, route_name, "" )
	if length( pattern ) = 0 then
		return default
	end if

	sequence route_data = map:get( m_routes, pattern, {} )
	if length( route_data ) = 0 then
		return default
	end if

	sequence route_path = route_data[ROUTE_PATH]

	-- TODO: this should match the parsing of route()

	if map( response ) then

		sequence parts = stdseq:split( route_path[2..$], "/" )
		sequence var_name, var_type

		for i = 1 to length( parts ) do
			if is_variable( parts[i] ) then

				{var_name,var_type} = parse_variable( parts[i] )

				log_trace( "var_name = %s", {var_name} )
				log_trace( "var_type = %s", {var_type} )

				if length( var_name ) and length( var_type ) then
					object value = map:get( response, var_name, 0 )

					if atom( value ) then
						value = sprint( value )
					end if

					parts[i] = value
				end if

			end if
		end for

		route_path = "/" & stdseq:join( parts, "/" )

	end if

	log_trace( "route_name = %s, route_path = %s", {route_name,route_path} )

	return route_path
end function

--
-- Return an HTTP redirect code and a link in case that doesn't work.
--
public function redirect( sequence redirect_url, integer redirect_code = 302 )

	log_trace( "redirect_url = %s", {redirect_url} )
	log_trace( "redirect_code = %s", {redirect_code} )

	sequence message = sprintf( `Please <a href="%s">click here</a> if you are not automatically redirected.`, {redirect_url} )

	header( "Location", "%s", {redirect_url} )

	return response_code( redirect_code, "Redirect", message )
end function

--
-- Return a response code with optional status (the description) and message (displayed on the page).
--
public function response_code( integer code, sequence status = "", sequence message = "" )

	if length( status ) = 0 then
		status = map:get( m_status, code, "Undefined" )
	end if

	sequence title = sprintf( "%d %s", {code,status} )
	sequence signature = SERVER_SIGNATURE

	sequence template = get_error_page( code )

	object response = map:new()
	map:put( response, "title",     title )
	map:put( response, "status",    status )
	map:put( response, "message",   message )
	map:put( response, "signature", signature )

	log_trace( "code = %s", {code} )
	log_trace( "title = %s", {title} )
	log_trace( "status = %s", {status} )
	log_trace( "message = %s", {message} )
	log_trace( "signature = %s", {signature} )

	header( "Status", "%d %s", {code,status} )

	return parse_template( template, response )
end function

--
-- Convert a route path to a simple name.
--
public function get_route_name( sequence route_path )

	log_trace( "route_path = %s" )

	sequence route_name = ""

	if equal( "*", route_path ) then
		route_name = "default"

	elsif search:begins( "/", route_path ) then

		sequence parts = stdseq:split( route_path[2..$], "/" )

		if length( parts ) = 0 then
			return ""
		end if

		route_name = stdseq:retain_all( "_abcdefghijklmnopqrstuvwxyz", parts[1] )

	end if

	log_trace( "route_name = %s", {route_name} )

	return route_name
end function

--
-- Assign a route path to a handler function.
--
public procedure route( sequence path, sequence name = get_route_name(path), sequence methods = {"GET"}, integer func_id = routine_id(name) )

	if func_id = -1 then
		log_error( "route function '%s' not found", {name} )
		error:crash( "route function %s not found", {name} )
	end if

	if equal( "*", path ) then
		regex pattern = regex:new( "^/.+$" )
		map:put( m_names, name, pattern )
		map:put( m_routes, pattern, {path,name,{},func_id} )
		log_debug( "Registered catch-all route handler %s", {name} )
		return

	elsif map:has( m_routes, path ) then
		sequence orig = map:get( m_routes, path, "" )
		log_warn( "Route for path %s already registered with %s", {path,orig} )
		return

	elsif not search:begins( "/", path ) then
		log_error( "Route %s does not begin with a slash", {path} )
		error:crash( "Route %s does not begin with a slash", {path} )

	end if

	sequence vars = {""}
	sequence varname, vartype, varpattern
	integer match_start, match_stop
	integer name_start, name_stop
	integer type_start, type_stop

	object pattern = path
	object matches = regex:find( re_variable, pattern )

	log_trace( "path = %s", {path} )

	while sequence( matches ) do

		{match_start,match_stop} = matches[1]

		log_trace( "match_start = %d, match_stop = %d", {match_start,match_stop} )

		if length( matches ) = 2 then

			{name_start,name_stop} = matches[2]

			log_trace( "name_start = %d, name_stop = %d", {name_start,name_stop} )

			varname = pattern[name_start..name_stop]
			vartype = "object"

		elsif length( matches ) = 3 then

			{name_start,name_stop} = matches[2]
			{type_start,type_stop} = matches[3]

			log_trace( "name_start = %d, name_stop = %d", {name_start,name_stop} )
			log_trace( "type_start = %d, type_stop = %d", {type_start,type_stop} )

			varname = pattern[name_start..name_stop]
			vartype = pattern[type_start..type_stop]

		else

			exit

		end if

		if map:has( m_regex, vartype ) then
			varpattern = map:get( m_regex, vartype )
		else
			-- TODO: detect regex patterns?
			varpattern = vartype
		end if

		log_trace( "varname = %s", {varname} )
		log_trace( "vartype = %s", {vartype} )
		log_trace( "varpattern = %s", {varpattern} )

		vars = append( vars, {varname,vartype} )
		pattern = replace( pattern, varpattern, match_start, match_stop )

		matches = regex:find( re_variable, pattern, matches[1][2] )
	end while

	pattern = regex:new( pattern )

	map:put( m_names, name, pattern )
	map:put( m_routes, pattern, {path,name,vars,methods,func_id} )

	log_debug( "Registered route %s with path %s and methods %s", {name,path,methods} )

end procedure


--
-- Requests
--

--
-- Parse the path and query string for available variables.
--
public function parse_request( sequence vars, sequence matches, sequence path_info, sequence request_method, sequence query_string )

	if length( vars ) != length( matches ) then
		error:crash( "route parameters do not match (%d != %d)",
			{ length(vars), length(matches) } )
	end if

	map request = parse_querystring( query_string )
	map:put( request, "PATH_INFO", path_info )
	map:put( request, "REQUEST_METHOD", request_method )
	map:put( request, "QUERY_STRING", query_string )

	object varname, vartype, vardata

	for j = 2 to length( vars ) do
		{varname,vartype} = vars[j]

		switch vartype do
			case "atom" then
				vardata = to_number( matches[j] )
			case "integer" then
				vardata = to_integer( matches[j] )
			case else
				vardata = matches[j]
		end switch

		map:put( request, varname, vardata )

	end for

	return request
end function

--
-- Parse an incoming request, call its handler, and return the response.
--
public function handle_request( sequence path_info, sequence request_method, sequence query_string )

	integer exit_code

	add_function( "url_for", {
		{"name"}, {"response",0}
	}, routine_id("url_for") )

	add_function( "get_current_route", {
	}, routine_id("get_current_route") )

	add_function( "get_current_path", {
	}, routine_id("get_current_path") )

	exit_code = run_hooks( HOOK_REQUEST_START )
	if exit_code then return "" end if

	integer route_found = 0
	integer default_route = 0
	sequence response = ""
	sequence patterns = map:keys( m_routes )
	sequence candidates = {}

	for i = 1 to length( patterns ) do
		sequence pattern = patterns[i]

		if regex:is_match( pattern, path_info ) then

			if equal( pattern, path_info ) then
				-- exact matches go at start of list
				log_trace( "pattern %s exact matches %s", {pattern,path_info} )
				candidates = insert( candidates, pattern, 1 )
				exit

			else
				-- regex matches go at end of list
				log_trace( "pattern %s regex matches path %s", {pattern,path_info} )
				candidates = append( candidates, pattern )

			end if

		else
			log_trace( "pattern %s does not match path %s", {pattern,path_info} )

		end if

	end for

	for i = 1 to length( candidates ) do
		sequence pattern = candidates[i]

		object path, name, vars, methods, func_id
		{path,name,vars,methods,func_id} = map:get( m_routes, pattern )

		if equal( "*", path ) then
			default_route = i
			continue
		end if

		if not find( request_method, methods ) then
			log_debug( "method %s not found in %s", {request_method,methods} )
			return response_code( 405 ) -- invalid method
		end if

		sequence matches = regex:matches( pattern, path_info )
		object request = parse_request( vars, matches,
			path_info, request_method, query_string )

		m_current_route = name
		m_current_path = path_info

		exit_code = run_hooks( HOOK_RESPONSE_START )
		if exit_code then return "" end if

		header( "Content-Type", "text/html" )
		response = call_func( func_id, {request} )

		exit_code = run_hooks( HOOK_RESPONSE_END )
		if exit_code then return "" end if

		delete( m_current_route )
		delete( request )

		route_found = i
		exit

	end for

	if not route_found then

		if default_route then

			sequence pattern = patterns[default_route]

			object path, name, vars, methods, func_id
			{path,name,vars,methods,func_id} = map:get( m_routes, pattern )

			object request = parse_request( {}, {},
				path_info, request_method, query_string )

			m_current_route = name
			m_current_path = path_info

			exit_code = run_hooks( HOOK_RESPONSE_START )
			if exit_code then return "" end if

			header( "Content-Type", "text/html" )
			response = call_func( func_id, {request} )

			exit_code = run_hooks( HOOK_RESPONSE_END )
			if exit_code then return "" end if

			delete( m_current_route )
			delete( m_current_path )

		else

			response = response_code( 404, "Not Found",
				"The requested URL was not found on this server."
			)

		end if

	end if

	header( "Content-Length", length(response) )

	exit_code = run_hooks( HOOK_REQUEST_END )
	if exit_code then return "" end if

	return response
end function

--
-- Entry point for the application. Performs basic setup and calls handle_request().
--
public procedure run()

	integer exit_code

	exit_code = run_hooks( HOOK_APP_START )
	if exit_code then return end if

	sequence path_info      = getenv( "PATH_INFO" )
	sequence request_method = getenv( "REQUEST_METHOD" )
	sequence query_string   = getenv( "QUERY_STRING" )
	integer content_length  = getenv( "CONTENT_LENGTH", AS_INTEGER, 0 )

	if equal( request_method, "POST" ) and content_length != 0 then
		query_string = get_bytes( STDIN, content_length )
	end if

	path_info = url:decode( path_info )
	query_string = url:decode( query_string )

	log_trace( "request_method = %s", {request_method} )
	log_trace( "path_info = %s",      {path_info} )
	log_trace( "query_string = %s",   {query_string} )
	log_trace( "content_length = %d", {content_length} )

	sequence response = handle_request( path_info, request_method, query_string )
	sequence headers = format_headers()

	puts( STDOUT, headers )
	puts( STDOUT, "\r\n" )
	puts( STDOUT, response )

	clear_headers()

	exit_code = run_hooks( HOOK_APP_END )
	if exit_code then return end if

end procedure

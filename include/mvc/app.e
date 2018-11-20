
namespace app

include std/convert.e
include std/map.e
include std/io.e
include std/pretty.e
include std/regex.e
include std/search.e
include std/sequence.e
include std/net/url.e
include std/text.e
include mvc/template.e

-- variable name only
constant re_varonly = regex:new( `^<([_a-zA-Z][_a-zA-Z0-9]*)>$` )

-- variable with type
constant re_vartype = regex:new( `^<([_a-zA-Z][_a-zA-Z0-9]*):(atom|integer|string|object)>$` )

-- type identifier patterns
map m_regex = map:new()
map:put( m_regex, "atom",    regex:new(`([-]?[0-9]*\.[0-9]+)`) )
map:put( m_regex, "integer", regex:new(`([-]?[0-9]+)`) )
map:put( m_regex, "string",  regex:new(`([\w\d\.\/]+)`) )
map:put( m_regex, "object",  regex:new(`([^\s\/]+)`) )

-- name -> pattern lookup
map m_names = map:new()

-- pattern -> data storage
map m_routes = map:new()

-- name -> value headers
map m_headers = map:new()

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

enum
    ROUTE_PATH,
    ROUTE_NAME,
    ROUTE_VARS,
    ROUTE_RID

public function getenv( sequence name, sequence default = "" )

    object value = eu:getenv( name )

    if atom( value ) then
        value = default
    end if

    return value
end function

public function is_variable( sequence item )
    return regex:is_match( re_varonly, item )
        or regex:is_match( re_vartype, item )
end function

public function parse_variable( sequence item )

    if regex:is_match( re_varonly, item ) then

        sequence matches = regex:matches( re_varonly, item )

        return {matches[2],"object"}

    elsif regex:is_match( re_vartype, item ) then

        sequence matches = regex:matches( re_vartype, item )

        return {matches[2],matches[3]}

    end if

    return {"",""}
end function

public function url_for( sequence name )

	sequence default = "#" & name

	sequence pattern = map:get( m_names, name, "" )
	if length( pattern ) = 0 then return default end if

	sequence data = map:get( m_routes, pattern, {} )
	if length( data ) = 0 then return default end if

	return data[ROUTE_PATH]
end function

public procedure header( sequence name, object value, object data = {} )

	if atom( value ) then value = sprint( value ) end if
	if not equal( data, {} ) then value = sprintf( value, data ) end if

	map:put( m_headers, name, value )

end procedure

public function response_code( integer code, sequence desc = "" )

	if length( desc ) = 0 then
		desc = map:get( m_status, code, desc )
	end if

	header( "Status", "%d %s", {code,desc} )

	return ""
end function

public procedure route( sequence path, sequence name, integer rid = routine_id(name) )

    if map:has( m_routes, path ) then
        return
    end if

    if not search:begins( "/", path ) then
        return
    end if

    sequence vars = {""}
    sequence varname, vartype

    sequence parts = stdseq:split( path[2..$], "/" )

    for i = 1 to length( parts ) do

        if is_variable( parts[i] ) then

            {varname,vartype} = parse_variable( parts[i] )

            if length( varname ) and length( vartype ) then
                vars = append( vars, {varname,vartype} )
                parts[i] = map:get( m_regex, vartype, "" )
            end if

        end if

    end for

    regex pattern = regex:new( "^/" & stdseq:join( parts, "/" ) & "$" )

	map:put( m_names, name, pattern )
    map:put( m_routes, pattern, {path,name,vars,rid} )

end procedure

public procedure handle_request( sequence path_info, sequence query_string )

    object varname, vartype, vardata
    sequence patterns = map:keys( m_routes )
	object response = 0

    for i = 1 to length( patterns ) do

        if regex:is_match( patterns[i], path_info ) then

            sequence matches = regex:matches( patterns[i], path_info )
            sequence item = map:get( m_routes, patterns[i] )

            sequence vars = item[ROUTE_VARS]
            integer rid = item[ROUTE_RID]

            if length( vars ) != length( matches ) then
                return
            end if

            map request = parse_querystring( query_string )

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

			header( "Content-Type", "text/html" )
            response = call_func( rid, {request} )

            exit

        end if

    end for

	if sequence( response ) then
		header( "Content-Length", length(response) )
	else
		response = response_code( 404 )
	end if

	sequence keys = map:keys( m_headers )

	for i = 1 to length( keys ) do
		object value = map:get( m_headers, keys[i] )
		printf( STDOUT, "%s: %s\r\n", {keys[i],value} )
	end for

    printf( STDOUT, "\r\n" )

	if sequence( response ) then
	    printf( STDOUT, response )
	end if

end procedure

public procedure run()

    sequence path_info = getenv( "PATH_INFO" )
	sequence query_string = getenv( "QUERY_STRING" )

	add_function( "url_for", {"name"} )
	handle_request( path_info, query_string )

end procedure


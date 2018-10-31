
namespace app

include std/convert.e
include std/map.e
include std/io.e
include std/pretty.e
include std/regex.e
include std/search.e
include std/sequence.e

-- variable name only
constant re_varonly = regex:new( `^<([_a-zA-Z][_a-zA-Z0-9]*)>$` )

-- variable with type
constant re_vartype = regex:new( `^<([_a-zA-Z][_a-zA-Z0-9]*):(atom|integer|string|object)>$` )

map m_regex = map:new()
map:put( m_regex, "atom",    regex:new(`([-]?[0-9]*\.[0-9]+)`) )
map:put( m_regex, "integer", regex:new(`([-]?[0-9]+)`) )
map:put( m_regex, "string",  regex:new(`([\w\d\.\/]+)`) )
map:put( m_regex, "object",  regex:new(`([^\s\/]+)`) )

map m_routes = map:new()

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
    map:put( m_routes, pattern, {path,name,vars,rid} )
    
end procedure

public procedure run()

    sequence varname, vartype
    object vardata
    
    sequence request_uri = getenv( "REQUEST_URI" )
    sequence patterns = map:keys( m_routes )
    
    for i = 1 to length( patterns ) do
        
        if regex:is_match( patterns[i], request_uri ) then
            
            sequence matches = regex:matches( patterns[i], request_uri )
            sequence item = map:get( m_routes, patterns[i] )
            
            sequence vars = item[ROUTE_VARS]
            integer rid = item[ROUTE_RID]
            
            if length( vars ) != length( matches ) then
                return
            end if
            
            map request = map:new()
            
            for j = 2 to length( vars ) do
                {varname,vartype} = vars[j]
                
                switch vartype do
                    case "atom"    then vardata = to_number( matches[j] )
                    case "integer" then vardata = to_integer( matches[j] )
                    case else           vardata = matches[j]
                end switch
                
                map:put( request, varname, vardata )
                
            end for
            
            object response = call_func( rid, {request} )
            
            printf( STDOUT, "Content-Type: text/html\n" )
            printf( STDOUT, "Content-Length: %d\n", length(response) )
            printf( STDOUT, "\n" )
            printf( STDOUT, response )
            
            exit
            
        end if
        
    end for

end procedure


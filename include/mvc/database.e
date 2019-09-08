
namespace database

include std/map.e
include std/net/url.e
include std/pretty.e
include std/search.e
include std/text.e
include std/types.e

include mvc/logger.e

public enum
-- handler ids
    DB_CONNECT,
    DB_DISCONNECT,
    DB_TABLE_EXISTS,
    DB_QUERY,
    DB_FETCH,
    DB_FREE,
    DB_ERROR,
    DB_LAST = DB_ERROR

constant DEFAULT_TIMEOUT = 5000
constant EMPTY_HANDLER = repeat( -1, DB_LAST )

sequence protocols = {}, handlers = {}

--
-- connection-to-protocol map
--
map m_conn = map:new()

--
-- keep track of the current connection
--
atom current_conn = 0

--
-- keep track of the current result
--
map m_current_result = map:new()

--
-- add a new protocol handler
--
public function add_protocol( sequence proto )

    protocols = append( protocols, proto )
    handlers  = append( handlers,  EMPTY_HANDLER )

    return length( protocols )
end function

--
-- add a new function handler
--
public procedure add_handler( integer proto_id, integer func_id, integer rtn_id )

    handlers[proto_id][func_id] = rtn_id

end procedure

--
-- connect to a database
--
public function db_connect( sequence url, integer timeout = DEFAULT_TIMEOUT )

    sequence parts = url:parse( url )
    object proto = parts[URL_PROTOCOL]

    sequence masked_url = url
    object password = parts[URL_PASSWORD]

    if sequence( password ) then
        sequence password_mask = repeat( '*', length(password) )
        masked_url = match_replace( password, masked_url, password_mask )
    end if

    log_debug( "url = %s, timeout = %d", {masked_url,timeout} )

    integer proto_id = find( proto, protocols )
    if proto_id = 0 then return 0 end if

    integer rtn_id = handlers[proto_id][DB_CONNECT]
    if rtn_id = -1 then return 0 end if

    atom conn = call_func( rtn_id, {url,timeout} )

    if conn then
        map:put( m_conn, conn, proto_id )
        current_conn = conn
    end if

    return conn
end function

--
-- select a different database
--
public function db_select( atom conn )

    if map:has( m_conn, conn ) then
        current_conn = conn
        return TRUE
    end if

    return FALSE
end function

--
-- disconnect from database
--
public procedure db_disconnect( atom conn = current_conn )

    integer proto_id = map:get( m_conn, conn, -1 )
    if proto_id = -1 then return end if

    integer rtn_id = handlers[proto_id][DB_DISCONNECT]
    if rtn_id = -1 then return end if

    call_proc( rtn_id, {conn} )
    map:remove( m_conn, conn )

end procedure

--
-- execute a query
--
public function db_query( sequence query, object params = {}, atom conn = current_conn )

    integer proto_id = map:get( m_conn, conn, -1 )
    if proto_id = -1 then return 0 end if

    integer rtn_id = handlers[proto_id][DB_QUERY]
    if rtn_id = -1 then return 0 end if

    query = find_replace( '\t', query, ' ' )
    query = find_replace( '\r', query, ' ' )
    query = find_replace( '\n', query, ' ' )
    query = match_replace( "   ", query, " " )
    query = match_replace( "  ", query, " " )
    query = text:trim( query )

    atom result = call_func( rtn_id, {conn,query,params} )

    if result then
        map:put( m_current_result, conn, result )
    end if

    return result
end function

--
-- fetch the next row
--
public function db_fetch( atom result = map:get(m_current_result,current_conn), atom conn = current_conn )

    integer proto_id = map:get( m_conn, conn, -1 )
    if proto_id = -1 then return 0 end if

    integer rtn_id = handlers[proto_id][DB_FETCH]
    if rtn_id = -1 then return 0 end if

    return call_func( rtn_id, {conn,result} )
end function

--
-- free the current result
--
public procedure db_free( atom result = map:get(m_current_result,current_conn), atom conn = current_conn )

    integer proto_id = map:get( m_conn, conn, -1 )
    if proto_id = -1 then return end if

    integer rtn_id = handlers[proto_id][DB_FREE]
    if rtn_id = -1 then return end if

    call_proc( rtn_id, {conn,result} )

end procedure

--
-- return the last error from the database
--
public function db_error( atom conn = current_conn )

    integer proto_id = map:get( m_conn, conn, -1 )
    if proto_id = -1 then return 0 end if

    integer rtn_id = handlers[proto_id][DB_ERROR]
    if rtn_id = -1 then return 0 end if

	return call_func( rtn_id, {conn} )
end function

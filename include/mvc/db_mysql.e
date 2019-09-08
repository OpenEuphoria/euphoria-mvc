namespace db_mysql

include std/dll.e
include std/machine.e
include std/map.e
include std/net/url.e
include std/pretty.e
include std/search.e
include std/types.e

include db/mysql.e
include mvc/database.e
include mvc/logger.e

constant MYSQL = add_protocol( "mysql" )

map m_valid_result = map:new()

function _connect( sequence url, integer timeout )

	object proto, host, user, passwd, db, port
	{proto,host,port,db,user,passwd,?} = url:parse( url )

	if length( db ) and db[1] = '/' then
        -- strip leading slash
        db = db[2..$]
    end if

	atom mysql = mysql_init()

	atom ptimeout = allocate_data( sizeof(C_UINT), TRUE )
	poke4( ptimeout, floor( timeout / 1000 ) )

	mysql_options( mysql, MYSQL_OPT_CONNECT_TIMEOUT, ptimeout )

	if mysql_real_connect( mysql, host, user, passwd, db, port ) = 0 then
	--	mysql_close( mysql )
		return 0
	end if

	return mysql
end function
add_handler( MYSQL, DB_CONNECT, routine_id("_connect") )

procedure _disconnect( atom mysql )

	mysql_close( mysql )

end procedure
add_handler( MYSQL, DB_DISCONNECT, routine_id("_disconnect") )

function _query( atom mysql, sequence stmt, object params )

--	sequence escape_stmt = mysql_real_escape_string( mysql, stmt )

    if not equal( params, {} ) then
        stmt = sprintf( stmt, params )
    end if

	if mysql_real_query( mysql, stmt ) then
		return -1
	end if

	atom result, rows

    if search:begins( "SELECT ", stmt ) then
        result = mysql_store_result( mysql )
        rows = mysql_num_rows( result )

    else
        result = 0
        rows = mysql_affected_rows( mysql )

    end if
    
    log_debug( "stmt = %s, rows = %d", {stmt,rows} )

    if result then
        map:put( m_valid_result, result, TRUE )
    end if

    return result
end function
add_handler( MYSQL, DB_QUERY, routine_id("_query") )

function _fetch( atom mysql, atom result )

    sequence row = mysql_fetch_row( result )

--  if length( row ) = 0 then
--      map:remove( m_valid_result, result )
--      mysql_free_result( result )
--  end if

    return row
end function
add_handler( MYSQL, DB_FETCH, routine_id("_fetch") )

procedure _free( atom mysql, atom result )

    if map:has( m_valid_result, result ) then
        map:remove( m_valid_result, result )
        mysql_free_result( result )
    end if

end procedure
add_handler( MYSQL, DB_FREE, routine_id("_free") )

function _error( atom mysql )
	return mysql_error( mysql )
end function
add_handler( MYSQL, DB_ERROR, routine_id("_error") )

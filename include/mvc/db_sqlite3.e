namespace db_mysql

include std/dll.e
include std/machine.e
--include std/map.e
include std/net/url.e
include std/pretty.e
include std/search.e
include std/types.e

include db/sqlite3.e
include mvc/database.e
include mvc/logger.e
include mvc/mapdbg.e as map

constant SQLITE3 = add_protocol( "sqlite3" )

map m_valid_stmt = map:new()

function _connect( sequence url, integer timeout )

	object proto, host, user, passwd, name, port
	{proto,host,port,name,user,passwd,?} = url:parse( url )

	atom result, db

	{result,db} = sqlite3_open( name )

	if result != SQLITE_OK then
		return 0
	end if

	return db
end function
add_handler( SQLITE3, DB_CONNECT, routine_id("_connect") )

procedure _disconnect( atom db )

	sqlite3_close( db )

end procedure
add_handler( SQLITE3, DB_DISCONNECT, routine_id("_disconnect") )

function _query( atom db, sequence sql, object params )

	atom result, stmt
	{result,stmt} = sqlite3_prepare_v2( db, sql )

	if result != SQLITE_OK then
		return 0
	end if

	sqlite3_assign_params( stmt, params )

	map:put( m_valid_stmt, stmt, 0 )

	return stmt
end function
add_handler( SQLITE3, DB_QUERY, routine_id("_query") )

function _fetch( atom db, atom stmt )

	if sqlite3_step( stmt ) = SQLITE_ROW then
		return sqlite3_fetch_row( stmt )
	end if

    return {}
end function
add_handler( SQLITE3, DB_FETCH, routine_id("_fetch") )

procedure _free( atom db, atom stmt )

    if map:has( m_valid_stmt, stmt ) then
        map:remove( m_valid_stmt, stmt )
		sqlite3_finalize( stmt )
    end if

end procedure
add_handler( SQLITE3, DB_FREE, routine_id("_free") )

function _error( atom db )
	return sqlite3_errmsg( db )
end function
add_handler( SQLITE3, DB_ERROR, routine_id("_error") )

function _insert_id( atom db )
	return sqlite3_last_insert_rowid( db )
end function
add_handler( SQLITE3, DB_INSERT_ID, routine_id("_insert_id") )

function _affected_rows( atom db )
	return sqlite3_changes( db )
end function
add_handler( SQLITE3, DB_AFFECTED_ROWS, routine_id("_affected_rows") )

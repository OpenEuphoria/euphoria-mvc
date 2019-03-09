namespace db_mysql

include db/mysql.e
include std/net/url.e
include std/pretty.e
include std/search.e
include mvc/database.e

constant MYSQL = add_protocol( "mysql" )

function _connect( sequence url )

	object proto, host, user, passwd, db, port
	{proto,host,port,db,user,passwd,?} = url:parse( url )

	if length( db ) and db[1] = '/' then
        -- strip leading slash
        db = db[2..$]
    end if

	atom mysql = mysql_init()

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

function _query( atom mysql, sequence stmt )

--	sequence escape_stmt = mysql_real_escape_string( mysql, stmt )

	if mysql_real_query( mysql, stmt ) then
		return 0
	end if

	return mysql_store_result( mysql )
end function
add_handler( MYSQL, DB_QUERY, routine_id("_query") )

function _fetch( atom mysql, atom result )

    sequence row = mysql_fetch_row( result )
    
    if length( row ) = 0 then
        mysql_free_result( result )
    end if
    
    return row
end function
add_handler( MYSQL, DB_FETCH, routine_id("_fetch") )

function _error( atom mysql )
	return mysql_error( mysql )
end function
add_handler( MYSQL, DB_ERROR, routine_id("_error") )

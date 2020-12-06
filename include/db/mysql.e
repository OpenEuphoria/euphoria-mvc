--****
-- == MySQL API
--
-- https://dev.mysql.com/doc/refman/8.0/en/c-api.html
--

namespace mysql

include std/dll.e
include std/machine.e
include std/error.e
include std/map.e

ifdef WINDOWS then
export atom libmysql = open_dll({ "libmariadb.dll", "libmysql.dll" })

elsifdef LINUX then
export atom libmysql = open_dll({ "libmariadb.so.3", "libmysqlclient.so.20" })

elsedef
error:crash( "Platform not supported" )

end ifdef

if libmysql = NULL then
	error:crash( "libmysql not found!" )
end if

function allocate_string( sequence str, integer cleanup = 0 )

	if length( str ) = 0 then
		return NULL
	end if

	return machine:allocate_string( str, cleanup )
end function

procedure free_string( object ptr )

	if atom( ptr ) then

		if ptr then
			free( ptr )
		end if

	else

		for i = 1 to length( ptr ) do
			free_string( ptr[i] )
		end for

	end if

end procedure

function peek_string( atom ptr )

	if ptr = NULL then
		return ""
	end if

	return eu:peek_string( ptr )
end function

function peek_str( atom ptr )

	if ptr = NULL then
		return ""
	end if

	return peek_string( peek_pointer(ptr) )
end function

function peek_ptr( atom ptr )
	return peek_pointer( ptr )
end function



public enum
	MYSQL_FIELD_NAME,
	MYSQL_FIELD_ORG_NAME,
	MYSQL_FIELD_TABLE,
	MYSQL_FIELD_ORG_TABLE,
	MYSQL_FIELD_DB,
	MYSQL_FIELD_CATALOG,
	MYSQL_FIELD_DEF,
	MYSQL_FIELD_LENGTH,
	MYSQL_FIELD_MAX_LENGTH,
	MYSQL_FIELD_NAME_LENGTH,
	MYSQL_FIELD_ORG_NAME_LENGTH,
	MYSQL_FIELD_TABLE_LENGTH,
	MYSQL_FIELD_ORG_TABLE_LENGTH,
	MYSQL_FIELD_DB_LENGTH,
	MYSQL_FIELD_CATALOG_LENGTH,
	MYSQL_FIELD_DEF_LENGTH,
	MYSQL_FIELD_FLAGS,
	MYSQL_FIELD_DECIMALS,
	MYSQL_FIELD_CHARSETNR,
	MYSQL_FIELD_TYPE,
	MYSQL_FIELD_EXTENSION,
$

public enum
	MYSQL_OPT_CONNECT_TIMEOUT = 0,
	MYSQL_OPT_COMPRESS,
	MYSQL_OPT_NAMED_PIPE,
	MYSQL_INIT_COMMAND,
	MYSQL_READ_DEFAULT_FILE,
	MYSQL_READ_DEFAULT_GROUP,
	MYSQL_SET_CHARSET_DIR,
	MYSQL_SET_CHARSET_NAME,
	MYSQL_OPT_LOCAL_INFILE,
	MYSQL_OPT_PROTOCOL,
	MYSQL_SHARED_MEMORY_BASE_NAME,
	MYSQL_OPT_READ_TIMEOUT,
	MYSQL_OPT_WRITE_TIMEOUT,
	MYSQL_OPT_USE_RESULT,
	MYSQL_OPT_USE_REMOTE_CONNECTION,
	MYSQL_OPT_USE_EMBEDDED_CONNECTION,
	MYSQL_OPT_GUESS_CONNECTION,
	MYSQL_SET_CLIENT_IP,
	MYSQL_SECURE_AUTH,
	MYSQL_REPORT_DATA_TRUNCATION,
	MYSQL_OPT_RECONNECT,
	MYSQL_OPT_SSL_VERIFY_SERVER_CERT,
	MYSQL_PLUGIN_DIR,
	MYSQL_DEFAULT_AUTH,
	MYSQL_OPT_BIND,
	MYSQL_OPT_SSL_KEY,
	MYSQL_OPT_SSL_CERT,
	MYSQL_OPT_SSL_CA,
	MYSQL_OPT_SSL_CAPATH,
	MYSQL_OPT_SSL_CIPHER,
	MYSQL_OPT_SSL_CRL,
	MYSQL_OPT_SSL_CRLPATH,
	/* Connection attribute options */
	MYSQL_OPT_CONNECT_ATTR_RESET,
	MYSQL_OPT_CONNECT_ATTR_ADD,
	MYSQL_OPT_CONNECT_ATTR_DELETE,
	MYSQL_SERVER_PUBLIC_KEY,
	MYSQL_ENABLE_CLEARTEXT_PLUGIN,
	MYSQL_OPT_CAN_HANDLE_EXPIRED_PASSWORDS,
	MYSQL_OPT_SSL_ENFORCE,
	MYSQL_OPT_MAX_ALLOWED_PACKET,
	MYSQL_OPT_NET_BUFFER_LENGTH,
	MYSQL_OPT_TLS_VERSION,
$

ifdef BITS64 then

constant
	mysql_field__name               =   0, -- char*
	mysql_field__org_name           =   8, -- char*
	mysql_field__table              =  16, -- char*
	mysql_field__org_table          =  24, -- char*
	mysql_field__db                 =  32, -- char*
	mysql_field__catalog            =  40, -- char*
	mysql_field__def                =  48, -- char*
	mysql_field__length             =  56, -- unsigned long
	mysql_field__max_length         =  64, -- unsigned long
	mysql_field__name_length        =  72, -- unsigned int
	mysql_field__org_name_length    =  76, -- unsigned int
	mysql_field__table_length       =  80, -- unsigned int
	mysql_field__org_table_length   =  84, -- unsigned int
	mysql_field__db_length          =  88, -- unsigned int
	mysql_field__catalog_length     =  92, -- unsigned int
	mysql_field__def_length         =  96, -- unsigned int
	mysql_field__flags              = 100, -- unsigned int
	mysql_field__decimals           = 104, -- unsigned int
	mysql_field__charsetnr          = 108, -- unsigned int
	mysql_field__type               = 112, -- enum_field_types
	mysql_field__extension          = 120, -- void*
	SIZEOF_MYSQL_FIELD              = 128,
$

elsedef

constant
	mysql_field__name               =  0, -- char*
	mysql_field__org_name           =  4, -- char*
	mysql_field__table              =  8, -- char*
	mysql_field__org_table          = 12, -- char*
	mysql_field__db                 = 16, -- char*
	mysql_field__catalog            = 20, -- char*
	mysql_field__def                = 24, -- char*
	mysql_field__length             = 28, -- unsigned long
	mysql_field__max_length         = 32, -- unsigned long
	mysql_field__name_length        = 36, -- unsigned int
	mysql_field__org_name_length    = 40, -- unsigned int
	mysql_field__table_length       = 44, -- unsigned int
	mysql_field__org_table_length   = 48, -- unsigned int
	mysql_field__db_length          = 52, -- unsigned int
	mysql_field__catalog_length     = 56, -- unsigned int
	mysql_field__def_length         = 60, -- unsigned int
	mysql_field__flags              = 64, -- unsigned int
	mysql_field__decimals           = 68, -- unsigned int
	mysql_field__charsetnr          = 72, -- unsigned int
	mysql_field__type               = 76, -- enum_field_types
	mysql_field__extension          = 80, -- void*
	SIZEOF_MYSQL_FIELD              = 84,
$

end ifdef

function peek_field( atom field )

	if field = NULL then
		return {}
	end if

	sequence name           = peek_str( field + mysql_field__name )
	sequence org_name       = peek_str( field + mysql_field__org_name )
	sequence table          = peek_str( field + mysql_field__table )
	sequence org_table      = peek_str( field + mysql_field__org_table )
	sequence db             = peek_str( field + mysql_field__db )
	sequence catalog        = peek_str( field + mysql_field__catalog )
	sequence def            = peek_str( field + mysql_field__def )
	atom _length            =   peek8u( field + mysql_field__length )
	atom max_length         =   peek8u( field + mysql_field__max_length )
	atom name_length        =   peek4u( field + mysql_field__name_length )
	atom org_name_length    =   peek4u( field + mysql_field__org_name_length )
	atom table_length       =   peek4u( field + mysql_field__table_length )
	atom org_table_length   =   peek4u( field + mysql_field__org_table_length )
	atom db_length          =   peek4u( field + mysql_field__db_length )
	atom catalog_length     =   peek4u( field + mysql_field__catalog_length )
	atom def_length         =   peek4u( field + mysql_field__def_length )
	atom flags              =   peek4u( field + mysql_field__flags )
	atom decimals           =   peek4u( field + mysql_field__decimals )
	atom charsetnr          =   peek4u( field + mysql_field__charsetnr )
	atom _type              =   peek4s( field + mysql_field__type )
	atom extension          = peek_ptr( field + mysql_field__extension )

	return { name, org_name, table, org_table, db, catalog, def, _length, max_length,
		name_length, org_name_length, table_length, org_table_length, db_length,
		catalog_length, def_length, flags, decimals, charsetnr, _type, extension }

end function



constant
	C_MYSQL       = C_POINTER,
	C_MYSQL_FIELD = C_POINTER,
	C_MYSQL_RES   = C_POINTER,
	C_MYSQL_ROW   = C_POINTER,
	C_STRING      = C_POINTER,
	C_INT64_T     = C_LONGLONG,
	C_UINT64_T    = C_LONGLONG -- C_ULONGLONG

constant
	_mysql_affected_rows            = define_c_func( libmysql, "mysql_affected_rows", {C_MYSQL}, C_LONGLONG ),
	_mysql_autocommit               = define_c_func( libmysql, "mysql_autocommit", {C_MYSQL,C_BOOL}, C_BOOL ),
	_mysql_change_user              = define_c_func( libmysql, "mysql_change_user", {C_MYSQL,C_STRING,C_STRING,C_STRING}, C_BOOL ),
	_mysql_character_set_name       = define_c_func( libmysql, "mysql_character_set_name", {C_MYSQL}, C_STRING ),
	_mysql_client_find_plugin       = define_c_func( libmysql, "mysql_client_find_plugin", {C_MYSQL,C_STRING,C_INT}, C_POINTER ),
	_mysql_client_register_plugin   = define_c_func( libmysql, "mysql_client_register_plugin", {C_MYSQL,C_POINTER}, C_POINTER ),
	_mysql_close                    = define_c_proc( libmysql, "mysql_close", {C_MYSQL} ),
	_mysql_commit                   = define_c_func( libmysql, "mysql_commit", {C_POINTER}, C_BOOL ),
--	_mysql_connect                  = define_c_func( libmysql, "mysql_connect", {C_MYSQL,C_STRING,C_STRING,C_STRING}, C_MYSQL ),
--	_mysql_create_db                = define_c_func( libmysql, "mysql_create_db", {C_MYSQL,C_STRING}, C_INT ),
	_mysql_data_seek                = define_c_proc( libmysql, "mysql_data_seek", {C_POINTER,C_LONGLONG} ),
--	_mysql_debug                    = define_c_proc( libmysql, "mysql_debug", {C_STRING} ),
--	_mysql_drop_db                  = define_c_func( libmysql, "mysql_drop_db", {C_MYSQL,C_STRING}, C_INT ),
--	_mysql_dump_debug_info          = define_c_func( libmysql, "mysql_dump_debug_info", {C_MYSQL}, C_INT ),
--	_mysql_eof                      = define_c_func( libmysql, "mysql_eof", {C_MYSQL_RES}, C_BOOL ),
	_mysql_errno                    = define_c_func( libmysql, "mysql_errno", {C_MYSQL}, C_UINT ),
	_mysql_error                    = define_c_func( libmysql, "mysql_error", {C_MYSQL}, C_STRING ),
	_mysql_fetch_field              = define_c_func( libmysql, "mysql_fetch_field", {C_MYSQL_RES}, C_MYSQL_FIELD ),
	_mysql_fetch_field_direct       = define_c_func( libmysql, "mysql_fetch_field_direct", {C_MYSQL_RES,C_UINT}, C_MYSQL_FIELD ),
	_mysql_fetch_fields             = define_c_func( libmysql, "mysql_fetch_fields", {C_MYSQL_RES}, C_MYSQL_FIELD ),
	_mysql_fetch_lengths            = define_c_func( libmysql, "mysql_fetch_lengths", {C_MYSQL_RES}, C_POINTER ),
	_mysql_fetch_row                = define_c_func( libmysql, "mysql_fetch_row", {C_MYSQL_RES}, C_MYSQL_ROW ),
	_mysql_field_count              = define_c_func( libmysql, "mysql_field_count", {C_MYSQL_RES}, C_UINT ),
	_mysql_field_seek               = define_c_func( libmysql, "mysql_field_seek", {C_MYSQL_RES,C_UINT}, C_UINT ),
	_mysql_field_tell               = define_c_func( libmysql, "mysql_field_tell", {C_MYSQL_RES}, C_UINT ),
	_mysql_free_result              = define_c_proc( libmysql, "mysql_free_result", {C_MYSQL_RES} ),
	_mysql_info                     = define_c_func( libmysql, "mysql_info", {C_POINTER}, C_STRING ),
	_mysql_init                     = define_c_func( libmysql, "mysql_init", {C_POINTER}, C_POINTER ),
	_mysql_insert_id                = define_c_func( libmysql, "mysql_insert_id", {C_POINTER}, C_LONGLONG ),
	_mysql_more_results             = define_c_func( libmysql, "mysql_more_results", {C_POINTER}, C_BOOL ),
	_mysql_next_result              = define_c_func( libmysql, "mysql_next_result", {C_POINTER}, C_INT ),
	_mysql_num_fields               = define_c_func( libmysql, "mysql_num_fields", {C_POINTER}, C_UINT ),
	_mysql_num_rows                 = define_c_func( libmysql, "mysql_num_rows", {C_POINTER}, C_LONGLONG ),
	_mysql_options                  = define_c_func( libmysql, "mysql_options", {C_POINTER,C_INT,C_POINTER}, C_INT ),
	_mysql_query                    = define_c_func( libmysql, "mysql_query", {C_POINTER,C_STRING}, C_INT ),
	_mysql_real_connect             = define_c_func( libmysql, "mysql_real_connect", {C_POINTER,C_STRING,C_STRING,C_STRING,C_STRING,C_UINT,C_STRING,C_ULONG}, C_POINTER ),
	_mysql_real_escape_string       = define_c_func( libmysql, "mysql_real_escape_string", {C_POINTER,C_STRING,C_STRING,C_ULONG}, C_ULONG ),
	_mysql_real_query               = define_c_func( libmysql, "mysql_real_query", {C_POINTER,C_STRING,C_ULONG}, C_INT ),
	_mysql_rollback                 = define_c_func( libmysql, "mysql_rollback", {C_POINTER}, C_BOOL ),
	_mysql_row_tell                 = define_c_func( libmysql, "mysql_row_tell", {C_POINTER}, C_POINTER ),
	_mysql_store_result             = define_c_func( libmysql, "mysql_store_result", {C_POINTER}, C_POINTER ),
	_mysql_thread_id                = define_c_func( libmysql, "mysql_thread_id", {C_POINTER}, C_ULONG ),
$

--****
-- === MySQL API Function Overview
--

--**
-- Returns the number of rows changed/deleted/inserted by the last ##UPDATE##, ##DELETE##, or ##INSERT## query.
--
-- Description:
-- 
-- [[mysql_affected_rows]]() may be called immediately after executing a statement with [[mysql_query]]() or [[mysql_real_query]]().
-- It returns the number of rows changed, deleted, or inserted by the last statement if it was an ##UPDATE##, ##DELETE##,
-- or ##INSERT##. For ##SELECT## statements, [[mysql_affected_rows]]() works like [[mysql_num_rows]]().
-- 
-- For ##UPDATE## statements, the affected-rows value by default is the number of rows actually changed. If you specify
-- the ##CLIENT_FOUND_ROWS## flag to [[mysql_real_connect]]() when connecting to **mysqld**, the affected-rows value is
-- the number of rows "found"; that is, matched by the ##WHERE## clause.
-- 
-- For ##REPLACE## statements, the affected-rows value is 2 if the new row replaced an old row, because in this case, one
-- row was inserted after the duplicate was deleted.
-- 
-- For ##INSERT ... ON DUPLICATE KEY UPDATE## statements, the affected-rows value per row is 1 if the row is inserted as
-- a new row, 2 if an existing row is updated, and 0 if an existing row is set to its current values. If you specify the
-- ##CLIENT_FOUND_ROWS## flag, the affected-rows value is 1 (not 0) if an existing row is set to its current values.
-- 
-- Following a ##CALL## statement for a stored procedure, [[mysql_affected_rows]]() returns the value that it would return
-- for the last statement executed within the procedure, or 0 if that statement would return -1. Within the procedure, you
-- can use ##ROW_COUNT()## at the SQL level to obtain the affected-rows value for individual statements.
-- 
-- [[mysql_affected_rows]]() returns a meaningful value for a wide range of statements. For details, see the description
-- for ##ROW_COUNT()## in [[https://dev.mysql.com/doc/refman/8.0/en/information-functions.html|Section 12.15, "Information
-- Functions"]].
--
-- Returns:
--
-- An integer greater than zero indicates the number of rows affected or retrieved. Zero indicates that no records were
-- updated for an ##UPDATE## statement, no rows matched the ##WHERE## clause in the query or that no query has yet been
-- executed. -1 indicates that the query returned an error or that, for a ##SELECT## query, [[mysql_affected_rows]]() was
-- called prior to calling [[mysql_store_result]]().
--
-- Example 1:
--
-- <eucode>
-- include std/io.e
-- include db/mysql.e
-- sequence stmt = `UPDATE products SET cost=cost*1.25
--                  WHERE group=10`
-- mysql_query( mysql, stmt )
-- printf( STDOUT, "%d products updated",
--          mysql_affected_rows(mysql) )
-- </eucode>
--
public function mysql_affected_rows( atom mysql )
	return c_func( _mysql_affected_rows, {mysql} )
end function

--**
-- Toggles autocommit mode on/off.
--
-- Description:
--
-- Sets autocommit mode on if ##mode## is 1, off if ##mode## is 0. 
--
-- Returns:
--
-- Zero for success. Nonzero if an error occurred.
--
public function mysql_autocommit( atom mysql, integer mode )
	return c_func( _mysql_autocommit, {mysql,mode} )
end function

--**
-- Changes the user and database on an open connection.
--
-- Description:
--
-- Changes the user and causes the database specified by db to become the default (current) database on the connection
-- specified by mysql. In subsequent queries, this database is the default for table references that include no explicit
-- database specifier.
--
-- [[mysql_change_user]]() fails if the connected user cannot be authenticated or does not have permission to use the database.
-- In this case, the user and database are not changed.
--
-- Pass a ##db## parameter of ##""## if you do not want to have a default database. This is the default.
--
-- This function resets the session state as if one had done a new connect and reauthenticated. (See
-- [[https://dev.mysql.com/doc/refman/8.0/en/c-api-auto-reconnect.html|Section 28.6.27, "C API Automatic Reconnection Control"]].)
-- It always performs a ##ROLLBACK## of any active transactions, closes and drops all temporary tables, and unlocks all
-- locked tables. Session system variables are reset to the values of the corresponding global system variables. Prepared
-- statements are released and ##HANDLER## variables are closed. Locks acquired with GET_LOCK() are released. These effects
-- occur even if the user did not change.
--
-- To reset the connection state in a more lightweight manner without changing the user, use [[mysql_reset_connection]]().
--
-- Returns:
--
-- Zero for success. Nonzero if an error occurred.
--
-- Errors:
--
-- The same that you can get from [[mysql_real_connect]](), plus:
--
-- * ##CR_COMMANDS_OUT_OF_SYNC## : Commands were executed in an improper order.
-- * ##CR_SERVER_GONE_ERROR## : The MySQL server has gone away.
-- * ##CR_SERVER_LOST## : The connection to the server was lost during the query.
-- * ##CR_UNKNOWN_ERROR## : An unknown error occurred.
-- * ##ER_UNKNOWN_COM_ERROR## : The MySQL server does not implement this command (probably an old server).
-- * ##ER_ACCESS_DENIED_ERROR## : The user or password was wrong.
-- * ##ER_BAD_DB_ERROR## : The database did not exist.
-- * ##ER_DBACCESS_DENIED_ERROR## : The user did not have access rights to the database.
-- * ##ER_WRONG_DB_NAME## : The database name was too long. 
--
-- Example 1:
--
-- <eucode>
-- include std/io.e
-- include db/mysql.e
--
-- if mysql_change_user( mysql, "user", "password", "new_database" ) then
--     printf( STDERR, "Failed to change user.  Error: %s\n",
--              {mysql_error(mysql)} )
-- end if
-- </eucode>
--
public function mysql_change_user( atom mysql, sequence user, sequence passwd, sequence db = "" )

	atom p_user = allocate_string( user )
	atom p_passwd = allocate_string( passwd )
	atom p_db = allocate_string( db )

	atom result = c_func( _mysql_change_user, {mysql,p_user,p_passwd,p_db} )

	free_string({ p_user, p_passwd, p_db })

	return result
end function

--**
-- Returns the default character set name for the current connection.
--
public function mysql_character_set_name( atom mysql )
	atom str = c_func( _mysql_character_set_name, {mysql} )
	return peek_string( str )
end function

--**
-- Returns a pointer to a plugin.
--
-- Description:
--
-- Returns a pointer to a loaded plugin, loading the plugin first if necessary. An error occurs if the type is invalid or
-- the plugin cannot be found or loaded.
--
-- Parameters:
--
-- * ##mysql## : A pointer to a MYSQL structure. The plugin API does not require a connection to a MySQL server, but this
--               structure must be properly initialized. The structure is used to obtain connection-related information.
-- * ##name## : The plugin name.
-- * ##type## : The plugin type. 
--
-- Returns:
--
-- A pointer to the plugin for success. ##NULL## if an error occurred.
--
-- Errors:
--
-- To check for errors, call the [[mysql_error]]() or [[mysql_errno]]() function.
--
public function mysql_client_find_plugin( atom mysql, sequence name, integer _type = 0 )

	atom p_name = allocate_string( name )

	atom result = c_func( _mysql_client_find_plugin, {mysql,p_name,_type} )

	free_string( p_name )

	return result
end function

--**
-- Registers a plugin.
--
-- Description:
--
-- Adds a plugin structure to the list of loaded plugins. An error occurs if the plugin is already loaded.
--
-- Parameters:
--
-- * ##mysql## : A pointer to a MYSQL structure. The plugin API does not require a connection to a MySQL server, but this
--               structure must be properly initialized. The structure is used to obtain connection-related information.
-- * ##plugin## : A pointer to the plugin structure. 
--
-- Returns:
--
-- A pointer to the plugin for success. ##NULL## if an error occurred.
--
-- Errors:
--
-- To check for errors, call the mysql_error() or mysql_errno() function.
--
public function mysql_client_register_plugin( atom mysql, atom plugin )
	return c_func( _mysql_client_register_plugin, {mysql,plugin} )
end function

--**
-- Closes a server connection.
--
-- Description:
--
-- Closes a previously opened connection. [[mysql_close]]() also deallocates the connection handler pointed to by mysql
-- if the handler was allocated automatically by [[mysql_init]]() or [[mysql_connect]](). Do not use the handler after it
-- has been closed.
--
public procedure mysql_close( atom mysql )
	c_proc( _mysql_close, {mysql} )
end procedure

--**
-- Commits the transaction.
--
-- Description:
--
-- The action of this function is subject to the value of the ##completion_type## system variable. In particular, if the
-- value of ##completion_type## is ##RELEASE## (or 2), the server performs a release after terminating a transaction and
-- closes the client connection. Call [[mysql_close]]() from the client program to close the connection from the client side.
--
-- Returns:
--
-- Zero for success. Nonzero if an error occurred.
--
public function mysql_commit( atom mysql )
	return c_func( _mysql_commit, {mysql} )
end function

--**
-- Seeks to an arbitrary row number in a query result set.
--
-- Description:
--
-- Seeks to an arbitrary row in a query result set. The offset value is a row number. Specify a value in the range from 
-- 0 to ##[[mysql_num_rows]](result)-1##.
--
-- This function requires that the result set structure contains the entire result of the query, so [[mysql_data_seek]]()
-- may be used only in conjunction with [[mysql_store_result]](), not with [[mysql_use_result]]().
--
public procedure mysql_data_seek( atom mysql, atom offset )
	c_proc( _mysql_data_seek, {mysql,offset} )
end procedure

--**
-- Returns the error number for the most recently invoked MySQL function.
--
-- Description:
--
-- For the connection specified by ##mysql##, [[mysql_errno]]() returns the error code for the most recently invoked API
-- function that can succeed or fail. A return value of zero means that no error occurred. Client error message numbers
-- are listed in the MySQL errmsg.h header file. Server error message numbers are listed in mysqld_error.h. Errors also
-- are listed at [[https://dev.mysql.com/doc/refman/8.0/en/error-handling.html|Appendix B, Errors, Error Codes, and Common
-- Problems]].
--
-- Returns:
--
-- An error code value for the last ##mysql_**//xxx//**()## call, if it failed. Zero means no error occurred.
--
-- Notes:
--
-- * Some functions such as [[mysql_fetch_row]]() do not set [[mysql_errno]]() if they succeed. A rule of thumb is that
-- all functions that have to ask the server for information reset [[mysql_errno]]() if they succeed.
-- * MySQL-specific error numbers returned by [[mysql_errno]]() differ from SQLSTATE values returned by [[mysql_sqlstate]]().
-- For example, the mysql client program displays errors using the following format, where ##1146## is the [[mysql_errno]]()
-- value and ##'42S02'## is the corresponding [[mysql_sqlstate]]() value:
--
-- {{{
-- shell> SELECT * FROM no_such_table;
-- ERROR 1146 (42S02): Table 'test.no_such_table' doesn't exist
-- }}}
--
public function mysql_errno( atom mysql )
	return c_func( _mysql_errno, {mysql} )
end function

--**
-- Returns the error message for the most recently invoked MySQL function.
--
-- Description:
--
-- For the connection specified by ##mysql##, [[mysql_error]]() returns a null-terminated string containing the error
-- message for the most recently invoked API function that failed. If a function did not fail, the return value of [[mysql_error]]()
-- may be the previous error or an empty string to indicate no error.
--
-- A rule of thumb is that all functions that have to ask the server for information reset [[mysql_error]]() if they succeed.
--
-- For functions that reset [[mysql_error]](), the following test can be used to check for an error:
--
-- <eucode>
-- if length( mysql_error(mysql) ) then
--     -- an error occurred
-- end if
-- </eucode>
--
-- The language of the client error messages may be changed by recompiling the MySQL client library. You can choose error
-- messages in several different languages. See [[https://dev.mysql.com/doc/refman/8.0/en/error-message-language.html|Section
-- 10.12, "Setting the Error Message Language"]].
--
-- Returns:
--
-- A null-terminated character string that describes the error. An empty string if no error occurred.
--
public function mysql_error( atom mysql )
	return peek_string( c_func( _mysql_error, {mysql} ) )
end function

--**
-- Returns the type of the next table field.
--
-- Description:
--
-- Returns the definition of one column of a result set as a ##MYSQL_FIELD## structure. Call this function repeatedly to
-- retrieve information about all columns in the result set. [[mysql_fetch_field]]() returns ##NULL## when no more fields
-- are left.
--
-- For metadata-optional connections, this function returns ##NULL## when the ##resultset_metadata## system variable is
-- set to ##NONE##. To check whether a result set has metadata, use the mysql_result_metadata() function. For details
-- about managing result set metadata transfer, see [[https://dev.mysql.com/doc/refman/8.0/en/c-api-optional-metadata.html|Section
-- 28.6.26, "C API Optional Result Set Metadata"]].
--
-- [[mysql_fetch_field]]() is reset to return information about the first field each time you execute a new ##SELECT## query.
-- The field returned by [[mysql_fetch_field]]() is also affected by calls to [[mysql_field_seek]]().
--
-- If you've called [[mysql_query]]() to perform a ##SELECT## on a table but have not called [[mysql_store_result]](),
-- MySQL returns the default blob length (8KB) if you call [[mysql_fetch_field]]() to ask for the length of a ##BLOB##
-- field. (The 8KB size is chosen because MySQL does not know the maximum length for the ##BLOB##. This should be made
-- configurable sometime.) Once you've retrieved the result set, ##field[MYSQL_FIELD_MAX_LENGTH]## contains the length of
-- the largest value for this column in the specific query.
--
-- Returns:
--
-- A sequence containing the ##MYSQL_FIELD## structure values for the current column. ##NULL## if no columns are left or
-- the result set has no metadata. The returned sequence contains the following values:
--
-- * ##MYSQL_FIELD_NAME##
-- * ##MYSQL_FIELD_ORG_NAME##
-- * ##MYSQL_FIELD_TABLE##
-- * ##MYSQL_FIELD_ORG_TABLE##
-- * ##MYSQL_FIELD_DB##
-- * ##MYSQL_FIELD_CATALOG##
-- * ##MYSQL_FIELD_DEF##
-- * ##MYSQL_FIELD_LENGTH##
-- * ##MYSQL_FIELD_MAX_LENGTH##
-- * ##MYSQL_FIELD_NAME_LENGTH##
-- * ##MYSQL_FIELD_ORG_NAME_LENGTH##
-- * ##MYSQL_FIELD_TABLE_LENGTH##
-- * ##MYSQL_FIELD_ORG_TABLE_LENGTH##
-- * ##MYSQL_FIELD_DB_LENGTH##
-- * ##MYSQL_FIELD_CATALOG_LENGTH##
-- * ##MYSQL_FIELD_DEF_LENGTH##
-- * ##MYSQL_FIELD_FLAGS##
-- * ##MYSQL_FIELD_DECIMALS##
-- * ##MYSQL_FIELD_CHARSETNR##
-- * ##MYSQL_FIELD_TYPE##
-- * ##MYSQL_FIELD_EXTENSION##
--
-- Example:
--
-- <eucode>
-- include std/io.e
-- include db/mysql.e
--
-- object field
-- integer i = 0
--
-- while sequence( field ) with entry do
--
--     printf( STDOUT, "Field %d is %s\n", {i,field[MYSQL_FIELD_NAME]} )
--     i += 1
--
-- entry
--     field = mysql_fetch_field( result )
--
-- end while
-- </eucode>
--
public function mysql_fetch_field( atom result )

	atom field = c_func( _mysql_fetch_field, {result} )

	if field then
		return peek_field( field )
	end if

	return field
end function

--**
-- Returns the type of a table field, given a field number.
--
-- Description:
--
--  Given a field number ##fieldnr## for a column within a result set, returns that column's field definition as a ##MYSQL_FIELD##
-- structure. Use this function to retrieve the definition for an arbitrary column. Specify a value for ##fieldnr## in the
-- range from 0 to ##[[mysql_num_fields]](result)-1##.
--
-- For metadata-optional connections, this function returns ##NULL## when the ##resultset_metadata## system variable is
-- set to ##NONE##. To check whether a result set has metadata, use the [[mysql_result_metadata]]() function. For details
-- about managing result set metadata transfer, see [[https://dev.mysql.com/doc/refman/8.0/en/c-api-optional-metadata.html|Section
-- 28.6.26, C API Optional Result Set Metadata]].
--
-- Returns:
--
-- A sequence containing the ##MYSQL_FIELD## structure values for the current column. ##NULL## if no columns are left or
-- the result set has no metadata. The returned sequence contains the following values:
--
-- * ##MYSQL_FIELD_NAME##
-- * ##MYSQL_FIELD_ORG_NAME##
-- * ##MYSQL_FIELD_TABLE##
-- * ##MYSQL_FIELD_ORG_TABLE##
-- * ##MYSQL_FIELD_DB##
-- * ##MYSQL_FIELD_CATALOG##
-- * ##MYSQL_FIELD_DEF##
-- * ##MYSQL_FIELD_LENGTH##
-- * ##MYSQL_FIELD_MAX_LENGTH##
-- * ##MYSQL_FIELD_NAME_LENGTH##
-- * ##MYSQL_FIELD_ORG_NAME_LENGTH##
-- * ##MYSQL_FIELD_TABLE_LENGTH##
-- * ##MYSQL_FIELD_ORG_TABLE_LENGTH##
-- * ##MYSQL_FIELD_DB_LENGTH##
-- * ##MYSQL_FIELD_CATALOG_LENGTH##
-- * ##MYSQL_FIELD_DEF_LENGTH##
-- * ##MYSQL_FIELD_FLAGS##
-- * ##MYSQL_FIELD_DECIMALS##
-- * ##MYSQL_FIELD_CHARSETNR##
-- * ##MYSQL_FIELD_TYPE##
-- * ##MYSQL_FIELD_EXTENSION##
--
-- Example:
--
-- <eucode>
-- include std/io.e
-- include db/mysql.e
--
-- atom num_fields = mysql_num_fields( result )
--
-- for i = 0 to num_fields - 1 do
--
--     sequence field = mysql_fetch_field_direct( result, i )
--
--     printf( STDOUT, "Field %d is %s\n", {i,field[MYSQL_FIELD_NAME]} )
--
-- end for
-- </eucode>
--
public function mysql_fetch_field_direct( atom result, atom fieldnr )

	atom field = c_func( _mysql_fetch_field_direct, {result,fieldnr} )

	if field then
		return peek_field( field )
	end if

	return field
end function

--**
-- Returns a sequence of all field structures.
--
-- Description:
--
-- Returns a sequence of all ##MYSQL_FIELD## structures for a result set. Each structure provides the field definition
-- for one column of the result set.
--
-- For metadata-optional connections, this function returns ##NULL## when the ##resultset_metadata## system variable is
-- set to NONE. To check whether a result set has metadata, use the [[mysql_result_metadata]]() function. For details
-- about managing result set metadata transfer, see
-- [[https://dev.mysql.com/doc/refman/8.0/en/c-api-optional-metadata.html|Section 28.6.26, "C API Optional Result Set Metadata"]].
--
-- Returns:
--
-- An sequence of ##MYSQL_FIELD## structures for all columns of a result set, or ##NULL## if the result set has no metadata.
-- The returned sequences each contain the following values:
--
-- * ##MYSQL_FIELD_NAME##
-- * ##MYSQL_FIELD_ORG_NAME##
-- * ##MYSQL_FIELD_TABLE##
-- * ##MYSQL_FIELD_ORG_TABLE##
-- * ##MYSQL_FIELD_DB##
-- * ##MYSQL_FIELD_CATALOG##
-- * ##MYSQL_FIELD_DEF##
-- * ##MYSQL_FIELD_LENGTH##
-- * ##MYSQL_FIELD_MAX_LENGTH##
-- * ##MYSQL_FIELD_NAME_LENGTH##
-- * ##MYSQL_FIELD_ORG_NAME_LENGTH##
-- * ##MYSQL_FIELD_TABLE_LENGTH##
-- * ##MYSQL_FIELD_ORG_TABLE_LENGTH##
-- * ##MYSQL_FIELD_DB_LENGTH##
-- * ##MYSQL_FIELD_CATALOG_LENGTH##
-- * ##MYSQL_FIELD_DEF_LENGTH##
-- * ##MYSQL_FIELD_FLAGS##
-- * ##MYSQL_FIELD_DECIMALS##
-- * ##MYSQL_FIELD_CHARSETNR##
-- * ##MYSQL_FIELD_TYPE##
-- * ##MYSQL_FIELD_EXTENSION##
--
-- Example:
--
-- <eucode>
-- include std/io.e
-- include db/mysql.e
--
-- atom num_fields = mysql_num_fields( result )
-- sequence fields = mysql_fetch_fields( result )
--
-- for i = 1 to num_fields do
--
--     printf( STDOUT, "Field %d is %s\n", {i,fields[i][MYSQL_FIELD_NAME]} )
--
-- end for
-- </eucode>
--
public function mysql_fetch_fields( atom result )

	atom fields = c_func( _mysql_fetch_fields, {result} )
	if fields = NULL then return NULL end if

	atom num_fields = c_func( _mysql_num_fields, {result} )
	sequence data = repeat( {}, num_fields )

	atom ptr = fields
	for i = 1 to num_fields do
		data[i] = peek_field( ptr )
		ptr += SIZEOF_MYSQL_FIELD
	end for

	return data
end function

--**
-- Returns the lengths of all columns in the current row.
--
-- Description:
--
-- Returns the lengths of the columns of the current row within a result set. The length for empty columns and for columns
-- containing NULL values is zero. To see how to distinguish these two cases, see the description for [[mysql_fetch_row]]().
--
-- Returns:
--
-- A sequence of integers representing the size of each column (not including any terminating null bytes). ##NULL## if an
-- error occurred.
--
-- Errors:
--
-- [[mysql_fetch_lengths]]() is valid only for the current row of the result set. It returns ##NULL## if you call it before
-- calling [[mysql_fetch_row]]() or after retrieving all rows in the result.
--
public function mysql_fetch_lengths( atom result )

	atom lengths = c_func( _mysql_fetch_lengths, {result} )
	if lengths = NULL then return NULL end if

	atom num_fields = c_func( _mysql_num_fields, {result} )
	sequence data = repeat( 0, num_fields )

	atom ptr = lengths
	for i = 1 to num_fields do
		data[i] = peek4u( ptr )
		ptr += sizeof( C_ULONG )
	end for

	return data
end function

--**
-- Fetches the next row from the result set.
--
-- Description:
--
-- [[mysql_fetch_row]]() retrieves the next row of a result set.
--
-- The number of values in the row is given by ##mysql_num_fields(result)##. If row holds the return value from a call
-- to [[mysql_fetch_row]](), the values are accessed as ##row[1]## to ##row[mysql_num_fields(result)]##. All non-**NULL**
-- values will be strings, while **NULL** values in the row are indicated by ##NULL##.
--
-- The lengths of the field values in the row may be obtained by calling [[mysql_fetch_lengths]](). Empty fields and
-- fields containing **NULL** both have length 0; you can distinguish these by checking the field value directly. If the
-- value is ##NULL##, the field is **NULL**; otherwise, the field is empty.
--
-- Returns:
--
-- A sequence containing the next row, or ##NULL##. The meaning of a ##NULL## return depends on which function was called
-- preceding ##mysql_fetch_row()##.
--
-- * When used after [[mysql_store_result]](), [[mysql_fetch_row]]() returns ##NULL## if there are no more rows to retrieve.
-- * When used after [[mysql_use_result]](), [[mysql_fetch_row]]() returns ##NULL## if there are no more rows to retrieve
-- or an error occurred. To determine whether an error occurred, check whether [[mysql_error]]() returns a nonempty string
-- or [[mysql_errno]]() returns nonzero.
--
public function mysql_fetch_row( atom result )

	atom row_ptr = c_func( _mysql_fetch_row, {result} )
	if row_ptr = 0 then return NULL end if

	atom len_ptr = c_func( _mysql_fetch_lengths, {result} )
	if len_ptr = 0 then return NULL end if

	atom num_fields = c_func( _mysql_num_fields, {result} )
	if num_fields = 0 then return NULL end if

	sequence fields = peek_pointer({ row_ptr, num_fields })
	sequence lengths = peek4u({ len_ptr, num_fields })

	sequence data = repeat( NULL, num_fields )

	for i = 1 to num_fields do
		if fields[i] != NULL then
			data[i] = peek({ fields[i], lengths[i] })
		end if
	end for

	return data
end function

public function mysql_fetch_map( atom result )

	atom row = c_func( _mysql_fetch_row, {result} )
	if row = NULL then return 0 end if

	atom fields = c_func( _mysql_fetch_fields, {result} )
	if fields = NULL then return 0 end if

	atom lengths = c_func( _mysql_fetch_lengths, {result} )
	if lengths = NULL then return 0 end if

	atom num_fields = c_func( _mysql_num_fields, {result} )
	map data = map:new()

	atom row_ptr = row
	atom len_ptr = lengths
    atom field_ptr = fields

	for i = 1 to num_fields do

		sequence field = peek_field( field_ptr )
		field = field[MYSQL_FIELD_NAME]

		object value = peek_pointer( row_ptr )
		if value != NULL then
			atom len = peek4u( len_ptr )
			value = peek({ value, len })
		end if

		map:put( data, field, value )

		row_ptr += sizeof( C_POINTER )
		len_ptr += sizeof( C_ULONG )
		field_ptr += SIZEOF_MYSQL_FIELD

	end for

	return data
end function

public function mysql_num_rows( atom result )
	return c_func( _mysql_num_rows, {result} )
end function

public function mysql_num_fields( atom result )
	return c_func( _mysql_num_fields, {result} )
end function

public function mysql_row_tell( atom result )
	return c_func( _mysql_row_tell, {result} )
end function

--public function mysql_field_tell( atom result )
--	return c_func( _mysql_field_tell, {result} )
--end function

public function mysql_field_count( atom mysql )
	return c_func( _mysql_field_count, {mysql} )
end function

public function mysql_more_results( atom mysql )
	return c_func( _mysql_more_results, {mysql} )
end function

--public function mysql_commit( atom mysql )
--	return c_func( _mysql_commit, {mysql} )
--end function

public function mysql_rollback( atom mysql )
	return c_func( _mysql_rollback, {mysql} )
end function

public function mysql_insert_id( atom mysql )
	return c_func( _mysql_insert_id, {mysql} )
end function

public function mysql_info( atom mysql )
	return peek_string( c_func( _mysql_info, {mysql} ) )
end function

public function mysql_thread_id( atom mysql )
	return c_func( _mysql_thread_id, {mysql} )
end function

public function mysql_field_seek( atom mysql, atom offset )
	return c_func( _mysql_field_seek, {mysql,offset} )
end function

public function mysql_field_tell( atom mysql )
	return c_func( _mysql_field_seek, {mysql} )
end function

public procedure mysql_free_result( atom result )
	c_proc( _mysql_free_result, {result} )
end procedure

public function mysql_init( atom mysql = NULL )
	return c_func( _mysql_init, {mysql} )
end function

public function mysql_options( atom mysql, integer option, atom arg )
	return c_func( _mysql_options, {mysql,option,arg} )
end function

public function mysql_query( atom mysql, sequence stmt )

	atom p_stmt = allocate_string( stmt )

	atom result = c_func( _mysql_query, {mysql,stmt} )

	free_string( p_stmt )

	return result
end function

public function mysql_real_connect( atom mysql, sequence host = "", sequence user = "", sequence passwd = "", sequence db = "",
		integer port = 0, sequence unix_socket = "", atom client_flag = 0 )

	atom p_host = allocate_string( host )
	atom p_user = allocate_string( user )
	atom p_passwd = allocate_string( passwd )
	atom p_db = allocate_string( db )
	atom p_sock = allocate_string( unix_socket )

	atom result = c_func( _mysql_real_connect, {mysql,p_host,p_user,p_passwd,p_db,port,p_sock,client_flag} )

	free_string({ p_host, p_user, p_passwd, p_db, p_sock })

	return result
end function

public function mysql_real_escape_string( atom mysql, sequence from_string, atom from_length = length(from_string) )

	atom p_from = allocate_string( from_string )

	atom to_length = floor( from_length * 2 )
	atom to_string = allocate_data( to_length )
	mem_set( to_string, NULL, to_length )

	to_length = c_func( _mysql_real_escape_string, {mysql,to_string,p_from,from_length} )

	sequence result = peek({ to_string, to_length })

	free_string({ p_from, to_string })

	return result
end function

public function mysql_real_query( atom mysql, sequence stmt, atom stmt_len = length(stmt) )

	atom p_stmt = allocate_string( stmt )

	atom result = c_func( _mysql_real_query, {mysql,p_stmt,stmt_len} )

	free_string( p_stmt )

	return result
end function

public function mysql_store_result( atom mysql )
	return c_func( _mysql_store_result, {mysql} )
end function

--
-- MySQL C API Prepared Statement Function Overview
-- https://dev.mysql.com/doc/refman/8.0/en/c-api-prepared-statement-function-overview.html
--

ifdef BITS64 then

constant
	mysql_bind__length              =   0, -- undsigned long*
	mysql_bind__is_null             =   8, -- my_bool*
	mysql_bind__buffer              =  16, -- void*
	mysql_bind__error               =  24, -- my_bool*
	mysql_bind__row_ptr             =  32, -- unsigned char*
	mysql_bind__store_param_func    =  40, -- void (*store_param_func)(NET *net, struct st_mysql_bind *param)
	mysql_bind__fetch_result        =  48, -- void (*fetch_result)(struct st_mysql_bind *, MYSQL_FIELD *, unsigned char **row)
	mysql_bind__skip_result         =  56, -- void (*skip_result)(struct st_mysql_bind *, MYSQL_FIELD *, unsigned char **row)
	mysql_bind__buffer_length       =  64, -- unsigned long
	mysql_bind__offset              =  72, -- unsigned long
	mysql_bind__length_value        =  80, -- unsigned long
	mysql_bind__param_number        =  88, -- unsigned int
    mysql_bind__pack_length         =  92, -- unsigned int
	mysql_bind__buffer_type         =  96, -- enum_field_types
	mysql_bind__error_value         = 100, -- my_bool
	mysql_bind__is_unsigned         = 101, -- my_bool
	mysql_bind__long_data_used      = 102, -- my_bool
	mysql_bind__is_null_value       = 103, -- my_bool
	mysql_bind__extension           = 104, -- void*
	SIZEOF_MYSQL_BIND               = 112,
$

elsedef

constant
	mysql_bind__length              =  0, -- undsigned long*
	mysql_bind__is_null             =  4, -- my_bool*
	mysql_bind__buffer              =  8, -- void*
	mysql_bind__error               = 12, -- my_bool*
	mysql_bind__row_ptr             = 16, -- unsigned char*
	mysql_bind__store_param_func    = 20, -- void (*store_param_func)(NET *net, struct st_mysql_bind *param)
	mysql_bind__fetch_result        = 24, -- void (*fetch_result)(struct st_mysql_bind *, MYSQL_FIELD *, unsigned char **row)
	mysql_bind__skip_result         = 28, -- void (*skip_result)(struct st_mysql_bind *, MYSQL_FIELD *, unsigned char **row)
	mysql_bind__buffer_length       = 32, -- unsigned long
	mysql_bind__offset              = 36, -- unsigned long
	mysql_bind__length_value        = 40, -- unsigned long
	mysql_bind__param_number        = 44, -- unsigned int
    mysql_bind__pack_length         = 48, -- unsigned int
	mysql_bind__buffer_type         = 52, -- enum_field_types
	mysql_bind__error_value         = 56, -- my_bool
	mysql_bind__is_unsigned         = 57, -- my_bool
	mysql_bind__long_data_used      = 58, -- my_bool
	mysql_bind__is_null_value       = 59, -- my_bool
	mysql_bind__extension           = 60, -- void*
	SIZEOF_MYSQL_BIND               = 64,
$

end ifdef

constant
	_mysql_stmt_affected_rows = define_c_func( libmysql, "mysql_stmt_affected_rows", {C_POINTER}, C_LONGLONG ),
$

public function mysql_stmt_affected_rows( atom stmt )
	return c_func( _mysql_stmt_affected_rows, {stmt} )
end function



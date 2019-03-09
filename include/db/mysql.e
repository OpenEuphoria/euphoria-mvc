--
-- MySQL 5.7 C API Function Overview
-- https://dev.mysql.com/doc/refman/5.7/en/c-api-function-overview.html
--

namespace mysql

include std/dll.e
include std/machine.e
include std/error.e

ifdef WINDOWS then
	atom libmysql = open_dll( "libmysql.dll" )

elsifdef LINUX then
	atom libmysql = open_dll({ "libmysqlclient.so.20", "libmysqlclient.so" })

elsedef
	error:crash( "Platform not supported." )

end ifdef



constant C_STRING = C_POINTER

function allocate_string( sequence str, integer cleanup = 1 )
	if length( str ) = 0 then return NULL end if
	return machine:allocate_string( str, cleanup )
end function

function peek_string( atom ptr )
	if ptr = NULL then return "" end if
	return eu:peek_string( ptr )
end function

function peek_str( atom ptr )
	if ptr = NULL then return "" end if
	ptr = peek_pointer( ptr )
	return peek_string( ptr )
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
	_mysql_affected_rows            = define_c_func( libmysql, "mysql_affected_rows", {C_POINTER}, C_LONGLONG ),
	_mysql_autocommit               = define_c_func( libmysql, "mysql_autocommit", {C_POINTER,C_BOOL}, C_BOOL ),
	_mysql_change_user              = define_c_func( libmysql, "mysql_change_user", {C_POINTER,C_STRING,C_STRING,C_STRING}, C_BOOL ),
	_mysql_character_set_name       = define_c_func( libmysql, "mysql_character_set_name", {C_POINTER}, C_STRING ),
	_mysql_client_find_plugin       = define_c_func( libmysql, "mysql_client_find_plugin", {C_POINTER,C_STRING,C_INT}, C_POINTER ),
	_mysql_client_register_plugin   = define_c_func( libmysql, "mysql_client_register_plugin", {C_POINTER,C_POINTER}, C_POINTER ),
	_mysql_close                    = define_c_proc( libmysql, "mysql_close", {C_POINTER} ),
	_mysql_commit                   = define_c_func( libmysql, "mysql_commit", {C_POINTER}, C_BOOL ),
--	_mysql_connect                  = define_c_func( libmysql, "mysql_connect", {C_POINTER,C_STRING,C_STRING,C_STRING}, C_POINTER ),
--	_mysql_create_db                = define_c_func( libmysql, "mysql_create_db", {C_POINTER,C_STRING}, C_INT ),
	_mysql_data_seek                = define_c_proc( libmysql, "mysql_data_seek", {C_POINTER,C_LONGLONG} ),
	_mysql_debug                    = define_c_proc( libmysql, "mysql_debug", {C_STRING} ),
--	_mysql_drop_db                  = define_c_func( libmysql, "mysql_drop_db", {C_POINTER,C_STRING} ),
	_mysql_dump_debug_info          = define_c_func( libmysql, "mysql_dump_debug_info", {C_POINTER}, C_INT ),
--	_mysql_eof                      = define_c_func( libmysql, "mysql_eof", {C_POINTER}, C_BOOL ),
	_mysql_errno                    = define_c_func( libmysql, "mysql_errno", {C_POINTER}, C_UINT ),
	_mysql_error                    = define_c_func( libmysql, "mysql_error", {C_POINTER}, C_STRING ),
--	_mysql_escape_string            = define_c_func( libmysql, "mysql_escape_string", {C_POINTER,C_POINTER,C_ULONG}, C_ULONG ),
	_mysql_fetch_field              = define_c_func( libmysql, "mysql_fetch_field", {C_POINTER}, C_POINTER ),
	_mysql_fetch_field_direct       = define_c_func( libmysql, "mysql_fetch_field_direct", {C_POINTER,C_UINT}, C_POINTER ),
	_mysql_fetch_fields             = define_c_func( libmysql, "mysql_fetch_fields", {C_POINTER}, C_POINTER ),
	_mysql_fetch_lengths            = define_c_func( libmysql, "mysql_fetch_lengths", {C_POINTER}, C_POINTER ),
	_mysql_fetch_row                = define_c_func( libmysql, "mysql_fetch_row", {C_POINTER}, C_POINTER ),
	_mysql_field_count              = define_c_func( libmysql, "mysql_field_count", {C_POINTER}, C_UINT ),
	_mysql_field_seek               = define_c_func( libmysql, "mysql_field_seek", {C_POINTER,C_UINT}, C_UINT ),
	_mysql_field_tell               = define_c_func( libmysql, "mysql_field_tell", {C_POINTER}, C_UINT ),
	_mysql_free_result              = define_c_proc( libmysql, "mysql_free_result", {C_POINTER} ),
	_mysql_init                     = define_c_func( libmysql, "mysql_init", {C_POINTER}, C_POINTER ),
	_mysql_insert_id                = define_c_func( libmysql, "mysql_insert_id", {C_POINTER}, C_LONGLONG ),
	_mysql_num_fields               = define_c_func( libmysql, "mysql_num_fields", {C_POINTER}, C_UINT ),
	_mysql_options                  = define_c_func( libmysql, "mysql_options", {C_POINTER,C_INT,C_POINTER}, C_INT ),
	_mysql_query                    = define_c_func( libmysql, "mysql_query", {C_POINTER,C_STRING}, C_INT ),
	_mysql_real_connect             = define_c_func( libmysql, "mysql_real_connect", {C_POINTER,C_STRING,C_STRING,C_STRING,C_STRING,C_UINT,C_STRING,C_ULONG}, C_POINTER ),
	_mysql_real_escape_string       = define_c_func( libmysql, "mysql_real_escape_string", {C_POINTER,C_STRING,C_STRING,C_ULONG}, C_ULONG ),
	_mysql_real_query               = define_c_func( libmysql, "mysql_real_query", {C_POINTER,C_STRING,C_ULONG}, C_INT ),
	_mysql_store_result             = define_c_func( libmysql, "mysql_store_result", {C_POINTER}, C_POINTER ),
$

public function mysql_affected_rows( atom mysql )
	return c_func( _mysql_affected_rows, {mysql} )
end function

public function mysql_autocommit( atom mysql, integer mode )
	return c_func( _mysql_autocommit, {mysql,mode} )
end function

public function mysql_change_user( atom mysql, sequence user, sequence passwd, sequence db = "" )
	return c_func( _mysql_change_user, {mysql,allocate_string(user,1),allocate_string(passwd,1),allocate_string(db,1)} )
end function

public function mysql_character_set_name( atom mysql )
	atom str = c_func( _mysql_character_set_name, {mysql} )
	return peek_string( str )
end function

public function mysql_client_find_plugin( atom mysql, sequence name, integer _type = 0 )
	return c_func( _mysql_client_find_plugin, {mysql,allocate_string(name,1),_type} )
end function

public function mysql_client_register_plugin( atom mysql, atom plugin )
	return c_func( _mysql_client_register_plugin, {mysql,plugin} )
end function

public procedure mysql_close( atom mysql )
	c_proc( _mysql_close, {mysql} )
end procedure

public function mysql_commit( atom mysql )
	return c_func( _mysql_commit, {mysql} )
end function

public procedure mysql_data_seek( atom mysql, atom offset )
	c_proc( _mysql_data_seek, {mysql,offset} )
end procedure

public procedure mysql_debug( sequence debug )
	c_proc( _mysql_debug, {allocate_string(debug,1)} )
end procedure

public function mysql_dump_debug_info( atom mysql )
	return c_func( _mysql_dump_debug_info, {mysql} )
end function

public function mysql_errno( atom mysql )
	return c_func( _mysql_errno, {mysql} )
end function

public function mysql_error( atom mysql )
	atom str = c_func( _mysql_error, {mysql} )
	return peek_string( str )
end function

public function mysql_fetch_field( atom result )
	atom field = c_func( _mysql_fetch_field, {result} )
	return peek_field( field )
end function

public function mysql_fetch_field_direct( atom result, atom fieldnr )
	atom field = c_func( _mysql_fetch_field_direct, {result,fieldnr} )
	return peek_field( field )
end function

public function mysql_fetch_fields( atom result )

	atom fields = c_func( _mysql_fetch_fields, {result} )
	if fields = NULL then return {} end if

	atom num_fields = c_func( _mysql_num_fields, {result} )
	sequence data = repeat( {}, num_fields )

	atom ptr = fields
	for i = 1 to num_fields do
		data[i] = peek_field( ptr )
		ptr += SIZEOF_MYSQL_FIELD
	end for

	return data
end function

public function mysql_fetch_lengths( atom result )

	atom lengths = c_func( _mysql_fetch_lengths, {result} )
	if lengths = NULL then return {} end if

	atom num_fields = c_func( _mysql_num_fields, {result} )
	sequence data = repeat( 0, num_fields )

	atom ptr = lengths
	for i = 1 to num_fields do
		data[i] = peek4u( ptr )
		ptr += sizeof( C_ULONG )
	end for

	return data
end function

public function mysql_fetch_row( atom result )

	atom row = c_func( _mysql_fetch_row, {result} )
	if row = NULL then return {} end if

	atom lengths = c_func( _mysql_fetch_lengths, {result} )
	if lengths = NULL then return {} end if

	atom num_fields = c_func( _mysql_num_fields, {result} )
	sequence data = repeat( NULL, num_fields )

	atom row_ptr = row
	atom len_ptr = lengths

	for i = 1 to num_fields do

		object str = peek_pointer( row_ptr )
		if str != NULL then
			atom len = peek4u( len_ptr )
			str = peek({ str, len })
		end if

		data[i] = str

		row_ptr += sizeof( C_POINTER )
		len_ptr += sizeof( C_ULONG )

	end for

	return data
end function

public function mysql_field_count( atom mysql )
	return c_func( _mysql_field_count, {mysql} )
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

public function mysql_insert_id( atom mysql )
	return c_func( _mysql_insert_id, {mysql} )
end function

public function mysql_num_fields( atom result )
	return c_func( _mysql_num_fields, {result} )
end function

public function mysql_options( atom mysql, integer option, atom arg )
	return c_func( _mysql_options, {mysql,option,arg} )
end function

public function mysql_query( atom mysql, sequence stmt_str )
	return c_func( _mysql_query, {mysql,allocate_string(stmt_str)} )
end function

public function mysql_real_connect( atom mysql, sequence host = "", sequence user = "", sequence passwd = "", sequence db = "",
		integer port = 0, sequence unix_socket = "", atom client_flag = 0 )
	return c_func( _mysql_real_connect, {mysql,allocate_string(host),allocate_string(user),allocate_string(passwd),
		allocate_string(db),port,allocate_string(unix_socket),client_flag} )
end function

public function mysql_real_escape_string( atom mysql, sequence from_string, atom from_length = length(from_string) )

	atom to_length = floor( from_length * 2 )
	atom to_string = allocate_data( to_length, 1 )
	mem_set( to_string, NULL, to_length )

	to_length = c_func( _mysql_real_escape_string, {mysql,to_string,allocate_string(from_string,1),from_length} )

	return peek({ to_string, to_length })
end function

public function mysql_real_query( atom mysql, sequence stmt_str, atom stmt_len = length(stmt_str) )
	return c_func( _mysql_real_query, {mysql,allocate_string(stmt_str),stmt_len} )
end function

public function mysql_store_result( atom mysql )
	return c_func( _mysql_store_result, {mysql} )
end function

--
-- MySQL C API Prepared Statement Function Overview
-- https://dev.mysql.com/doc/refman/5.7/en/c-api-prepared-statement-function-overview.html
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



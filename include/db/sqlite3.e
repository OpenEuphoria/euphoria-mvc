--
-- C-language Interface Specification for SQLite
-- https://www.sqlite.org/capi3ref.html
--

namespace sqlite3

include std/dll.e
include std/error.e
include std/machine.e
include std/map.e
include std/serialize.e
include std/types.e

constant
	C_CALLBACK          = C_POINTER,
	C_SQLITE3           = C_POINTER,
	C_SQLITE3_BACKUP    = C_POINTER,
	C_SQLITE3_BLOB      = C_POINTER,
	C_SQLITE3_CONTEXT   = C_POINTER,
	C_SQLITE3_MODULE    = C_POINTER,
	C_SQLITE3_STMT      = C_POINTER,
	C_SQLITE3_VALUE     = C_POINTER,
	C_SQLITE3_VFS       = C_POINTER,
	C_STRING            = C_POINTER,
	C_WSTRING           = C_POINTER,
	C_ULONGLONG         = C_LONGLONG -- FIXME

constant INVALID_RID = -1

-- safely return NULL if rid is invalid
function call_back( integer rid )

	if rid = INVALID_RID then
		return NULL
	end if

	return dll:call_back( rid )
end function

-- store a sequence of bytes in memory, or allocate and clear memory
function allocate_data( object data, integer cleanup = FALSE )

	atom ptr

	if sequence( data ) then

		ptr = machine:allocate_data( length(data), cleanup )
		poke( ptr, data )

	else

		ptr =  machine:allocate_data( data, cleanup )
		mem_set( ptr, data, NULL )

	end if

	return ptr
end function

-- safely return NULL if string is empty
function allocate_string( sequence str, integer cleanup = FALSE )

	if length( str ) = 0 then
		return NULL
	end if

	return machine:allocate_string( str, cleanup )
end function

-- safely return NULL if string is empty
function allocate_wstring( sequence str, integer cleanup = FALSE )

	if length( str ) = 0 then
		return NULL
	end if

	return machine:allocate_wstring( str, cleanup )
end function

-- safely return an empty string if ptr is NULL
function peek_string( atom ptr )

	if ptr then
		return eu:peek_string( ptr )
	end if

	return ""
end function

-- safely return an empty string if ptr is NULL
function peek_wstring( atom ptr )

	if ptr then
		return machine:peek_wstring( ptr )
	end if

	return ""
end function

ifdef WINDOWS then
export atom sqlite3 = open_dll( "sqlite3.dll" )

elsifdef LINUX then
export atom sqlite3 = open_dll( "libsqlite3.so" )

elsedef
error:crash( "Platform not supported" )

end ifdef

constant
	_sqlite3_version                = define_c_var( sqlite3, "sqlite3_version" ),
	_sqlite3_libversion             = define_c_func( sqlite3, "sqlite3_libversion", {}, C_STRING ),
	_sqlite3_libversion_number      = define_c_func( sqlite3, "sqlite3_libversion_number", {}, C_INT ),
	_sqlite3_sourceid               = define_c_func( sqlite3, "sqlite3_sourceid", {}, C_STRING ),
	_sqlite3_compileoption_used     = define_c_func( sqlite3, "sqlite3_compileoption_used", {C_STRING}, C_INT ),
	_sqlite3_compileoption_get      = define_c_func( sqlite3, "sqlite3_compileoption_get", {C_INT}, C_STRING ),
	_sqlite3_threadsafe             = define_c_func( sqlite3, "sqlite3_threadsafe", {}, C_INT ),
	_sqlite3_close                  = define_c_func( sqlite3, "sqlite3_close", {C_SQLITE3}, C_INT ),
	_sqlite3_close_v2               = define_c_func( sqlite3, "sqlite3_close_v2", {C_SQLITE3}, C_INT ),
	_sqlite3_exec                   = define_c_func( sqlite3, "sqlite3_exec", {C_SQLITE3,C_STRING,C_CALLBACK,C_POINTER,C_POINTER}, C_INT ),
	_sqlite3_initialize             = define_c_func( sqlite3, "sqlite3_initialize", {}, C_INT ),
	_sqlite3_shutdown               = define_c_func( sqlite3, "sqlite3_shutdown", {}, C_INT ),
	_sqlite3_extended_result_codes  = define_c_func( sqlite3, "sqlite3_extended_result_codes", {C_SQLITE3,C_INT}, C_INT ),
	_sqlite3_last_insert_rowid      = define_c_func( sqlite3, "sqlite3_last_insert_rowid", {C_SQLITE3}, C_LONGLONG ),
	_sqlite3_set_last_insert_rowid  = define_c_proc( sqlite3, "sqlite3_set_last_insert_rowid", {C_SQLITE3,C_LONGLONG} ),
	_sqlite3_changes                = define_c_func( sqlite3, "sqlite3_changes", {C_SQLITE3}, C_INT ),
	_sqlite3_total_changes          = define_c_func( sqlite3, "sqlite3_total_changes", {C_SQLITE3}, C_INT ),
	_sqlite3_interrupt              = define_c_proc( sqlite3, "sqlite3_interrupt", {C_SQLITE3} ),
	_sqlite3_complete               = define_c_func( sqlite3, "sqlite3_complete", {C_STRING}, C_INT ),
	_sqlite3_complete16             = define_c_func( sqlite3, "sqlite3_complete16", {C_WSTRING}, C_INT ),
	_sqlite3_busy_handler           = define_c_func( sqlite3, "sqlite3_busy_handler", {C_SQLITE3,C_CALLBACK,C_POINTER}, C_INT ),
	_sqlite3_busy_timeout           = define_c_func( sqlite3, "sqlite3_busy_timeout", {C_SQLITE3,C_INT}, C_INT ),
	_sqlite3_get_table              = define_c_func( sqlite3, "sqlite3_get_table", {C_SQLITE3,C_STRING,C_POINTER,C_POINTER,C_POINTER,C_POINTER}, C_INT ),
	_sqlite3_free_table             = define_c_proc( sqlite3, "sqlite3_free_table", {C_POINTER} ),
	_sqlite3_malloc                 = define_c_func( sqlite3, "sqlite3_malloc", {C_INT}, C_POINTER ),
	_sqlite3_malloc64               = define_c_func( sqlite3, "sqlite3_malloc64", {C_ULONGLONG}, C_POINTER ),
	_sqlite3_realloc                = define_c_func( sqlite3, "sqlite3_realloc", {C_POINTER,C_INT}, C_POINTER ),
	_sqlite3_realloc64              = define_c_func( sqlite3, "sqlite3_realloc64", {C_POINTER,C_ULONGLONG}, C_POINTER ),
	_sqlite3_free                   = define_c_proc( sqlite3, "sqlite3_free", {C_POINTER} ),
	_sqlite3_msize                  = define_c_func( sqlite3, "sqlite3_msize", {C_POINTER}, C_ULONGLONG ),
	_sqlite3_memory_used            = define_c_func( sqlite3, "sqlite3_memory_used", {}, C_LONGLONG ),
	_sqlite3_memory_highwater       = define_c_func( sqlite3, "sqlite3_memory_highwater", {C_INT}, C_LONGLONG ),
	_sqlite3_randomness             = define_c_proc( sqlite3, "sqlite3_randomness", {C_INT,C_POINTER} ),
	_sqlite3_set_authorizer         = define_c_func( sqlite3, "sqlite3_set_authorizer", {C_SQLITE3,C_CALLBACK,C_POINTER}, C_INT ),
	_sqlite3_trace                  = define_c_func( sqlite3, "sqlite3_trace", {C_SQLITE3,C_CALLBACK,C_POINTER}, C_POINTER ),
	_sqlite3_profile                = define_c_func( sqlite3, "sqlite3_profile", {C_SQLITE3,C_CALLBACK,C_POINTER}, C_POINTER ),
	_sqlite3_trace_v2               = define_c_func( sqlite3, "sqlite3_trace_v2", {C_SQLITE3,C_UINT,C_CALLBACK,C_POINTER}, C_INT ),
	_sqlite3_progress_handler       = define_c_proc( sqlite3, "sqlite3_progress_handler", {C_SQLITE3,C_INT,C_CALLBACK,C_POINTER} ),
	_sqlite3_open                   = define_c_func( sqlite3, "sqlite3_open", {C_STRING,C_POINTER}, C_INT ),
	_sqlite3_open16                 = define_c_func( sqlite3, "sqlite3_open16", {C_WSTRING,C_POINTER}, C_INT ),
	_sqlite3_open_v2                = define_c_func( sqlite3, "sqlite3_open_v2", {C_STRING,C_POINTER,C_INT,C_STRING}, C_INT ),
	_sqlite3_uri_parameter          = define_c_func( sqlite3, "sqlite3_uri_parameter", {C_STRING,C_STRING}, C_STRING ),
	_sqlite3_uri_boolean            = define_c_func( sqlite3, "sqlite3_uri_boolean", {C_STRING,C_STRING,C_INT}, C_INT ),
	_sqlite3_uri_int64              = define_c_func( sqlite3, "sqlite3_uri_int64", {C_STRING,C_STRING,C_LONGLONG}, C_LONGLONG ),
	_sqlite3_uri_key                = define_c_func( sqlite3, "sqlite3_uri_key", {C_STRING,C_INT}, C_STRING ),
	_sqlite3_filename_database      = define_c_func( sqlite3, "sqlite3_filename_database", {C_STRING}, C_STRING ),
	_sqlite3_filename_journal       = define_c_func( sqlite3, "sqlite3_filename_journal", {C_STRING}, C_STRING ),
	_sqlite3_filename_wal           = define_c_func( sqlite3, "sqlite3_filename_wal", {C_STRING}, C_STRING ),
	_sqlite3_errcode                = define_c_func( sqlite3, "sqlite3_errcode", {C_SQLITE3}, C_INT ),
	_sqlite3_extended_errcode       = define_c_func( sqlite3, "sqlite3_extended_errcode", {C_SQLITE3}, C_INT ),
	_sqlite3_errmsg                 = define_c_func( sqlite3, "sqlite3_errmsg", {C_SQLITE3}, C_STRING ),
	_sqlite3_errmsg16               = define_c_func( sqlite3, "sqlite3_errmsg16", {C_SQLITE3}, C_WSTRING ),
	_sqlite3_errstr                 = define_c_func( sqlite3, "sqlite3_errstr", {C_INT}, C_STRING ),
	_sqlite3_limit                  = define_c_func( sqlite3, "sqlite3_limit", {C_SQLITE3,C_INT,C_INT}, C_INT ),
	_sqlite3_prepare                = define_c_func( sqlite3, "sqlite3_prepare", {C_SQLITE3,C_STRING,C_INT,C_POINTER,C_POINTER}, C_INT ),
	_sqlite3_prepare_v2             = define_c_func( sqlite3, "sqlite3_prepare_v2", {C_SQLITE3,C_STRING,C_INT,C_POINTER,C_POINTER}, C_INT ),
	_sqlite3_prepare_v3             = define_c_func( sqlite3, "sqlite3_prepare_v3", {C_SQLITE3,C_STRING,C_INT,C_UINT,C_POINTER,C_POINTER}, C_INT ),
	_sqlite3_prepare16              = define_c_func( sqlite3, "sqlite3_prepare16", {C_SQLITE3,C_STRING,C_INT,C_POINTER,C_POINTER}, C_INT ),
	_sqlite3_prepare16_v2           = define_c_func( sqlite3, "sqlite3_prepare16_v2", {C_SQLITE3,C_STRING,C_INT,C_POINTER,C_POINTER}, C_INT ),
	_sqlite3_prepare16_v3           = define_c_func( sqlite3, "sqlite3_prepare16_v3", {C_SQLITE3,C_STRING,C_INT,C_UINT,C_POINTER,C_POINTER}, C_INT ),
	_sqlite3_sql                    = define_c_func( sqlite3, "sqlite3_sql", {C_POINTER}, C_STRING ),
	_sqlite3_expanded_sql           = define_c_func( sqlite3, "sqlite3_expanded_sql", {C_POINTER}, C_STRING ),
	_sqlite3_stmt_readonly          = define_c_func( sqlite3, "sqlite3_stmt_readonly", {C_SQLITE3_STMT}, C_INT ),
	_sqlite3_stmt_isexplain         = define_c_func( sqlite3, "sqlite3_stmt_isexplain", {C_SQLITE3_STMT}, C_INT ),
	_sqlite3_stmt_busy              = define_c_func( sqlite3, "sqlite3_stmt_busy", {C_SQLITE3_STMT}, C_INT ),
	_sqlite3_bind_blob              = define_c_func( sqlite3, "sqlite3_bind_blob", {C_SQLITE3_STMT,C_INT,C_POINTER,C_INT,C_CALLBACK}, C_INT ),
	_sqlite3_bind_blob64            = define_c_func( sqlite3, "sqlite3_bind_blob64", {C_SQLITE3_STMT,C_INT,C_POINTER,C_ULONGLONG,C_CALLBACK}, C_INT ),
	_sqlite3_bind_double            = define_c_func( sqlite3, "sqlite3_bind_double", {C_SQLITE3_STMT,C_INT,C_DOUBLE}, C_INT ),
	_sqlite3_bind_int               = define_c_func( sqlite3, "sqlite3_bind_int", {C_SQLITE3_STMT,C_INT,C_INT}, C_INT ),
	_sqlite3_bind_int64             = define_c_func( sqlite3, "sqlite3_bind_int64", {C_SQLITE3_STMT,C_INT,C_LONGLONG}, C_INT ),
	_sqlite3_bind_null              = define_c_func( sqlite3, "sqlite3_bind_null", {C_SQLITE3_STMT,C_INT}, C_INT ),
	_sqlite3_bind_text              = define_c_func( sqlite3, "sqlite3_bind_text", {C_SQLITE3_STMT,C_INT,C_STRING,C_INT,C_CALLBACK}, C_INT ),
	_sqlite3_bind_text16            = define_c_func( sqlite3, "sqlite3_bind_text16", {C_SQLITE3_STMT,C_INT,C_POINTER,C_INT,C_CALLBACK}, C_INT ),
	_sqlite3_bind_text64            = define_c_func( sqlite3, "sqlite3_bind_text64", {C_SQLITE3_STMT,C_INT,C_STRING,C_ULONGLONG,C_CALLBACK,C_UCHAR}, C_INT ),
	_sqlite3_bind_value             = define_c_func( sqlite3, "sqlite3_bind_value", {C_SQLITE3_STMT,C_INT,C_POINTER}, C_INT ),
	_sqlite3_bind_pointer           = define_c_func( sqlite3, "sqlite3_bind_pointer", {C_SQLITE3_STMT,C_INT,C_POINTER,C_STRING,C_CALLBACK}, C_INT ),
	_sqlite3_bind_zeroblob          = define_c_func( sqlite3, "sqlite3_bind_zeroblob", {C_SQLITE3_STMT,C_INT,C_INT}, C_INT ),
	_sqlite3_bind_zeroblob64        = define_c_func( sqlite3, "sqlite3_bind_zeroblob64", {C_SQLITE3_STMT,C_INT,C_ULONGLONG}, C_INT ),
	_sqlite3_bind_parameter_count   = define_c_func( sqlite3, "sqlite3_bind_parameter_count", {C_SQLITE3_STMT}, C_INT ),
	_sqlite3_bind_parameter_name    = define_c_func( sqlite3, "sqlite3_bind_parameter_name", {C_SQLITE3_STMT,C_INT}, C_STRING ),
	_sqlite3_bind_parameter_index   = define_c_func( sqlite3, "sqlite3_bind_parameter_index", {C_SQLITE3_STMT,C_STRING}, C_INT ),
	_sqlite3_clear_bindings         = define_c_func( sqlite3, "sqlite3_clear_bindings", {C_SQLITE3_STMT}, C_INT ),
	_sqlite3_column_count           = define_c_func( sqlite3, "sqlite3_column_count", {C_SQLITE3_STMT}, C_INT ),
	_sqlite3_column_name            = define_c_func( sqlite3, "sqlite3_column_name", {C_SQLITE3_STMT,C_INT}, C_STRING ),
	_sqlite3_column_name16          = define_c_func( sqlite3, "sqlite3_column_name16", {C_SQLITE3_STMT,C_INT}, C_WSTRING ),
	_sqlite3_column_database_name   = define_c_func( sqlite3, "sqlite3_column_database_name", {C_SQLITE3_STMT,C_INT}, C_STRING ),
	_sqlite3_column_database_name16 = define_c_func( sqlite3, "sqlite3_column_database_name16", {C_SQLITE3_STMT,C_INT}, C_WSTRING ),
	_sqlite3_column_table_name      = define_c_func( sqlite3, "sqlite3_column_table_name", {C_SQLITE3_STMT,C_INT}, C_STRING ),
	_sqlite3_column_table_name16    = define_c_func( sqlite3, "sqlite3_column_table_name16", {C_SQLITE3_STMT,C_INT}, C_WSTRING ),
	_sqlite3_column_origin_name     = define_c_func( sqlite3, "sqlite3_column_origin_name", {C_SQLITE3_STMT,C_INT}, C_STRING ),
	_sqlite3_column_origin_name16   = define_c_func( sqlite3, "sqlite3_column_origin_name16", {C_SQLITE3_STMT,C_INT}, C_WSTRING ),
	_sqlite3_column_decltype        = define_c_func( sqlite3, "sqlite3_column_decltype", {C_SQLITE3_STMT,C_INT}, C_STRING ),
	_sqlite3_column_decltype16      = define_c_func( sqlite3, "sqlite3_column_decltype16", {C_SQLITE3_STMT,C_INT}, C_WSTRING ),
	_sqlite3_step                   = define_c_func( sqlite3, "sqlite3_step", {C_SQLITE3_STMT}, C_INT ),
	_sqlite3_data_count             = define_c_func( sqlite3, "sqlite3_data_count", {C_SQLITE3_STMT}, C_INT ),
	_sqlite3_column_blob            = define_c_func( sqlite3, "sqlite3_column_blob", {C_SQLITE3_STMT,C_INT}, C_POINTER ),
	_sqlite3_column_double          = define_c_func( sqlite3, "sqlite3_column_double", {C_SQLITE3_STMT,C_INT}, C_DOUBLE ),
	_sqlite3_column_int             = define_c_func( sqlite3, "sqlite3_column_int", {C_SQLITE3_STMT,C_INT}, C_INT ),
	_sqlite3_column_int64           = define_c_func( sqlite3, "sqlite3_column_int64", {C_SQLITE3_STMT,C_INT}, C_LONGLONG ),
	_sqlite3_column_text            = define_c_func( sqlite3, "sqlite3_column_text", {C_SQLITE3_STMT,C_INT}, C_STRING ),
	_sqlite3_column_text16          = define_c_func( sqlite3, "sqlite3_column_text16", {C_SQLITE3_STMT,C_INT}, C_WSTRING ),
	_sqlite3_column_value           = define_c_func( sqlite3, "sqlite3_column_value", {C_SQLITE3_STMT,C_INT}, C_POINTER ),
	_sqlite3_column_bytes           = define_c_func( sqlite3, "sqlite3_column_bytes", {C_SQLITE3_STMT,C_INT}, C_INT ),
	_sqlite3_column_bytes16         = define_c_func( sqlite3, "sqlite3_column_bytes16", {C_SQLITE3_STMT,C_INT}, C_INT ),
	_sqlite3_column_type            = define_c_func( sqlite3, "sqlite3_column_type", {C_SQLITE3_STMT,C_INT}, C_INT ),
	_sqlite3_finalize               = define_c_func( sqlite3, "sqlite3_finalize", {C_SQLITE3_STMT}, C_INT ),
	_sqlite3_reset                  = define_c_func( sqlite3, "sqlite3_reset", {C_SQLITE3_STMT}, C_INT ),
	_sqlite3_create_function        = define_c_func( sqlite3, "sqlite3_create_function", {C_SQLITE3,C_STRING,C_INT,C_INT,C_POINTER,C_CALLBACK,C_CALLBACK,C_CALLBACK}, C_INT ),
	_sqlite3_create_function16      = define_c_func( sqlite3, "sqlite3_create_function16", {C_SQLITE3,C_WSTRING,C_INT,C_INT,C_POINTER,C_CALLBACK,C_CALLBACK,C_CALLBACK}, C_INT ),
	_sqlite3_create_function_v2     = define_c_func( sqlite3, "sqlite3_create_function_v2", {C_SQLITE3,C_STRING,C_INT,C_INT,C_POINTER,C_CALLBACK,C_CALLBACK,C_CALLBACK,C_CALLBACK}, C_INT ),
	_sqlite3_create_window_function = define_c_func( sqlite3, "sqlite3_create_window_function", {C_SQLITE3,C_STRING,C_INT,C_INT,C_POINTER,C_CALLBACK,C_CALLBACK,C_CALLBACK,C_CALLBACK,C_CALLBACK}, C_INT ),
	_sqlite3_value_blob             = define_c_func( sqlite3, "sqlite3_value_blob", {C_SQLITE3_VALUE}, C_POINTER ),
	_sqlite3_value_double           = define_c_func( sqlite3, "sqlite3_value_double", {C_SQLITE3_VALUE}, C_DOUBLE ),
	_sqlite3_value_int              = define_c_func( sqlite3, "sqlite3_value_int", {C_SQLITE3_VALUE}, C_INT ),
	_sqlite3_value_int64            = define_c_func( sqlite3, "sqlite3_value_int64", {C_SQLITE3_VALUE}, C_LONGLONG ),
	_sqlite3_value_pointer          = define_c_func( sqlite3, "sqlite3_value_pointer", {C_SQLITE3_VALUE,C_STRING}, C_POINTER ),
	_sqlite3_value_text             = define_c_func( sqlite3, "sqlite3_value_text", {C_SQLITE3_VALUE}, C_STRING ),
	_sqlite3_value_text16           = define_c_func( sqlite3, "sqlite3_value_text16", {C_SQLITE3_VALUE}, C_WSTRING ),
	_sqlite3_value_text16le         = define_c_func( sqlite3, "sqlite3_value_text16le", {C_SQLITE3_VALUE}, C_WSTRING ),
	_sqlite3_value_text16be         = define_c_func( sqlite3, "sqlite3_value_text16be", {C_SQLITE3_VALUE}, C_WSTRING ),
	_sqlite3_value_bytes            = define_c_func( sqlite3, "sqlite3_value_bytes", {C_SQLITE3_VALUE}, C_INT ),
	_sqlite3_value_bytes16          = define_c_func( sqlite3, "sqlite3_value_bytes16", {C_SQLITE3_VALUE}, C_INT ),
	_sqlite3_value_type             = define_c_func( sqlite3, "sqlite3_value_type", {C_SQLITE3_VALUE}, C_INT ),
	_sqlite3_value_numeric_type     = define_c_func( sqlite3, "sqlite3_value_numeric_type", {C_SQLITE3_VALUE}, C_INT ),
	_sqlite3_value_nochange         = define_c_func( sqlite3, "sqlite3_value_nochange", {C_SQLITE3_VALUE}, C_INT ),
	_sqlite3_value_frombind         = define_c_func( sqlite3, "sqlite3_value_frombind", {C_SQLITE3_VALUE}, C_INT ),
	_sqlite3_value_subtype          = define_c_func( sqlite3, "sqlite3_value_subtype", {C_SQLITE3_VALUE}, C_UINT ),
	_sqlite3_value_dup              = define_c_func( sqlite3, "sqlite3_value_dup", {C_SQLITE3_VALUE}, C_SQLITE3_VALUE ),
	_sqlite3_value_free             = define_c_proc( sqlite3, "sqlite3_value_free", {C_SQLITE3_VALUE} ),
	_sqlite3_aggregate_context      = define_c_func( sqlite3, "sqlite3_aggregate_context", {C_SQLITE3_CONTEXT,C_INT}, C_POINTER ),
	_sqlite3_user_data              = define_c_func( sqlite3, "sqlite3_user_data", {C_SQLITE3_CONTEXT}, C_POINTER ),
	_sqlite3_context_db_handle      = define_c_func( sqlite3, "sqlite3_context_db_handle", {C_SQLITE3_CONTEXT}, C_SQLITE3 ),
	_sqlite3_get_auxdata            = define_c_func( sqlite3, "sqlite3_get_auxdata", {C_POINTER,C_INT}, C_POINTER ),
	_sqlite3_set_auxdata            = define_c_proc( sqlite3, "sqlite3_set_auxdata", {C_POINTER,C_INT,C_POINTER,C_CALLBACK} ),
	_sqlite3_result_blob            = define_c_proc( sqlite3, "sqlite3_result_blob", {C_SQLITE3_CONTEXT,C_POINTER,C_INT,C_CALLBACK} ),
	_sqlite3_result_blob64          = define_c_proc( sqlite3, "sqlite3_result_blob64", {C_SQLITE3_CONTEXT,C_POINTER,C_ULONGLONG,C_CALLBACK} ),
	_sqlite3_result_double          = define_c_proc( sqlite3, "sqlite3_result_double", {C_SQLITE3_CONTEXT,C_DOUBLE} ),
	_sqlite3_result_error           = define_c_proc( sqlite3, "sqlite3_result_error", {C_SQLITE3_CONTEXT,C_STRING,C_INT} ),
	_sqlite3_result_error16         = define_c_proc( sqlite3, "sqlite3_result_error16", {C_SQLITE3_CONTEXT,C_WSTRING,C_INT} ),
	_sqlite3_result_error_toobig    = define_c_proc( sqlite3, "sqlite3_result_error_toobig", {C_SQLITE3_CONTEXT} ),
	_sqlite3_result_error_nomem     = define_c_proc( sqlite3, "sqlite3_result_error_nomem", {C_SQLITE3_CONTEXT} ),
	_sqlite3_result_error_code      = define_c_proc( sqlite3, "sqlite3_result_error_code", {C_SQLITE3_CONTEXT,C_INT} ),
	_sqlite3_result_int             = define_c_proc( sqlite3, "sqlite3_result_int", {C_SQLITE3_CONTEXT,C_INT} ),
	_sqlite3_result_int64           = define_c_proc( sqlite3, "sqlite3_result_int64", {C_SQLITE3_CONTEXT,C_LONGLONG} ),
	_sqlite3_result_null            = define_c_proc( sqlite3, "sqlite3_result_null", {C_SQLITE3_CONTEXT} ),
	_sqlite3_result_text            = define_c_proc( sqlite3, "sqlite3_result_text", {C_SQLITE3_CONTEXT,C_STRING,C_INT,C_CALLBACK} ),
	_sqlite3_result_text64          = define_c_proc( sqlite3, "sqlite3_result_text64", {C_SQLITE3_CONTEXT,C_STRING,C_LONGLONG,C_CALLBACK,C_INT} ),
	_sqlite3_result_text16          = define_c_proc( sqlite3, "sqlite3_result_text16", {C_SQLITE3_CONTEXT,C_POINTER,C_INT,C_CALLBACK} ),
	_sqlite3_result_text16le        = define_c_proc( sqlite3, "sqlite3_result_text16le", {C_SQLITE3_CONTEXT,C_POINTER,C_INT,C_CALLBACK} ),
	_sqlite3_result_text16be        = define_c_proc( sqlite3, "sqlite3_result_text16be", {C_SQLITE3_CONTEXT,C_POINTER,C_INT,C_CALLBACK} ),
	_sqlite3_result_value           = define_c_proc( sqlite3, "sqlite3_result_value", {C_SQLITE3_CONTEXT,C_SQLITE3_VALUE} ),
	_sqlite3_result_pointer         = define_c_proc( sqlite3, "sqlite3_result_pointer", {C_SQLITE3_CONTEXT,C_POINTER,C_STRING,C_CALLBACK} ),
	_sqlite3_result_zeroblob        = define_c_proc( sqlite3, "sqlite3_result_zeroblob", {C_SQLITE3_CONTEXT,C_INT} ),
	_sqlite3_result_zeroblob64      = define_c_func( sqlite3, "sqlite3_result_zeroblob64", {C_SQLITE3_CONTEXT,C_LONGLONG}, C_INT ),
	_sqlite3_result_subtype         = define_c_proc( sqlite3, "sqlite3_result_subtype", {C_SQLITE3_CONTEXT,C_UINT} ),
	_sqlite3_create_collation       = define_c_func( sqlite3, "sqlite3_create_collation", {C_SQLITE3,C_STRING,C_INT,C_POINTER,C_CALLBACK}, C_INT ),
	_sqlite3_create_collation_v2    = define_c_func( sqlite3, "sqlite3_create_collation_v2", {C_SQLITE3,C_STRING,C_INT,C_POINTER,C_CALLBACK,C_CALLBACK}, C_INT ),
	_sqlite3_create_collation16     = define_c_func( sqlite3, "sqlite3_create_collation16", {C_SQLITE3,C_STRING,C_INT,C_POINTER,C_CALLBACK}, C_INT ),
	_sqlite3_collation_needed       = define_c_func( sqlite3, "sqlite3_collation_needed", {C_SQLITE3,C_POINTER,C_CALLBACK}, C_INT ),
	_sqlite3_collation_needed16     = define_c_func( sqlite3, "sqlite3_collation_needed16", {C_SQLITE3,C_POINTER,C_CALLBACK}, C_INT ),
	_sqlite3_sleep                  = define_c_func( sqlite3, "sqlite3_sleep", {C_INT}, C_INT ),
	_sqlite3_temp_directory         = define_c_var( sqlite3, "sqlite3_temp_directory" ),
	_sqlite3_data_directory         = define_c_var( sqlite3, "sqlite3_data_directory" ),
	_sqlite3_win32_set_directory    = define_c_func( sqlite3, "sqlite3_win32_set_directory", {C_ULONG,C_STRING}, C_INT ),
	_sqlite3_win32_set_directory8   = define_c_func( sqlite3, "sqlite3_win32_set_directory8", {C_ULONG,C_STRING}, C_INT ),
	_sqlite3_win32_set_directory16  = define_c_func( sqlite3, "sqlite3_win32_set_directory16", {C_ULONG,C_WSTRING}, C_INT ),
	_sqlite3_get_autocommit         = define_c_func( sqlite3, "sqlite3_get_autocommit", {C_SQLITE3}, C_INT ),
	_sqlite3_db_handle              = define_c_func( sqlite3, "sqlite3_db_handle", {C_SQLITE3_STMT}, C_SQLITE3 ),
	_sqlite3_db_filename            = define_c_func( sqlite3, "sqlite3_db_filename", {C_SQLITE3,C_STRING}, C_STRING ),
	_sqlite3_db_readonly            = define_c_func( sqlite3, "sqlite3_db_readonly", {C_SQLITE3,C_STRING}, C_INT ),
	_sqlite3_next_stmt              = define_c_func( sqlite3, "sqlite3_next_stmt", {C_SQLITE3,C_SQLITE3_STMT}, C_SQLITE3_STMT ),
	_sqlite3_commit_hook            = define_c_func( sqlite3, "sqlite3_commit_hook", {C_SQLITE3,C_CALLBACK,C_POINTER}, C_POINTER ),
	_sqlite3_rollback_hook          = define_c_func( sqlite3, "sqlite3_rollback_hook", {C_SQLITE3,C_CALLBACK,C_POINTER}, C_POINTER ),
	_sqlite3_enable_shared_cache    = define_c_func( sqlite3, "sqlite3_enable_shared_cache", {C_INT}, C_INT ),
	_sqlite3_release_memory         = define_c_func( sqlite3, "sqlite3_release_memory", {C_INT}, C_INT ),
	_sqlite3_db_release_memory      = define_c_func( sqlite3, "sqlite3_db_release_memory", {C_SQLITE3}, C_INT ),
	_sqlite3_soft_heap_limit        = define_c_proc( sqlite3, "sqlite3_soft_heap_limit", {C_INT} ),
	_sqlite3_soft_heap_limit64      = define_c_func( sqlite3, "sqlite3_soft_heap_limit64", {C_LONGLONG}, C_LONGLONG ),
	_sqlite3_table_column_metadata  = define_c_func( sqlite3, "sqlite3_table_column_metadata", {C_SQLITE3,C_STRING,C_STRING,C_STRING,C_POINTER,C_POINTER,C_POINTER,C_POINTER,C_POINTER}, C_INT ),
	_sqlite3_load_extension         = define_c_func( sqlite3, "sqlite3_load_extension", {C_SQLITE3,C_STRING,C_STRING,C_POINTER}, C_INT ),
	_sqlite3_enable_load_extension  = define_c_func( sqlite3, "sqlite3_enable_load_extension", {C_SQLITE3,C_INT}, C_INT ),
	_sqlite3_auto_extension         = define_c_func( sqlite3, "sqlite3_auto_extension", {C_CALLBACK}, C_INT ),
	_sqlite3_cancel_auto_extension  = define_c_func( sqlite3, "sqlite3_cancel_auto_extension", {C_CALLBACK}, C_INT ),
	_sqlite3_reset_auto_extension   = define_c_proc( sqlite3, "sqlite3_reset_auto_extension", {} ),
	_sqlite3_create_module          = define_c_func( sqlite3, "sqlite3_create_module", {C_SQLITE3,C_STRING,C_SQLITE3_MODULE,C_POINTER}, C_INT ),
	_sqlite3_create_module_v2       = define_c_func( sqlite3, "sqlite3_create_module_v2", {C_SQLITE3,C_STRING,C_SQLITE3_MODULE,C_POINTER,C_CALLBACK}, C_INT ),
	_sqlite3_declare_vtab           = define_c_func( sqlite3, "sqlite3_declare_vtab", {C_SQLITE3,C_STRING}, C_INT ),
	_sqlite3_overload_function      = define_c_func( sqlite3, "sqlite3_overload_function", {C_SQLITE3,C_STRING,C_INT}, C_INT ),
	_sqlite3_blob_open              = define_c_func( sqlite3, "sqlite3_blob_open", {C_SQLITE3,C_STRING,C_STRING,C_STRING,C_LONGLONG,C_INT,C_POINTER}, C_INT ),
	_sqlite3_blob_reopen            = define_c_func( sqlite3, "sqlite3_blob_reopen", {C_SQLITE3_BLOB,C_LONGLONG}, C_INT ),
	_sqlite3_blob_close             = define_c_func( sqlite3, "sqlite3_blob_close", {C_SQLITE3_BLOB}, C_INT ),
	_sqlite3_blob_bytes             = define_c_func( sqlite3, "sqlite3_blob_bytes", {C_SQLITE3_BLOB}, C_INT ),
	_sqlite3_blob_read              = define_c_func( sqlite3, "sqlite3_blob_read", {C_SQLITE3_BLOB,C_POINTER,C_INT,C_INT}, C_INT ),
	_sqlite3_blob_write             = define_c_func( sqlite3, "sqlite3_blob_write", {C_SQLITE3_BLOB,C_POINTER,C_INT,C_INT}, C_INT ),
	_sqlite3_vfs_find               = define_c_func( sqlite3, "sqlite3_vfs_find", {C_STRING}, C_SQLITE3_VFS ),
	_sqlite3_vfs_register           = define_c_func( sqlite3, "sqlite3_vfs_register", {C_SQLITE3_VFS,C_INT}, C_INT ),
	_sqlite3_vfs_unregister         = define_c_func( sqlite3, "sqlite3_vfs_unregister", {C_SQLITE3_VFS}, C_INT ),
	_sqlite3_file_control           = define_c_func( sqlite3, "sqlite3_file_control", {C_SQLITE3,C_STRING,C_INT,C_POINTER}, C_INT ),
	_sqlite3_keyword_count          = define_c_func( sqlite3, "sqlite3_keyword_count", {}, C_INT ),
	_sqlite3_keyword_name           = define_c_func( sqlite3, "sqlite3_keyword_name", {C_INT,C_POINTER,C_POINTER}, C_INT ),
	_sqlite3_keyword_check          = define_c_func( sqlite3, "sqlite3_keyword_check", {C_STRING,C_INT}, C_INT ),
	_sqlite3_status                 = define_c_func( sqlite3, "sqlite3_status", {C_INT,C_POINTER,C_POINTER,C_INT}, C_INT ),
	_sqlite3_status64               = define_c_func( sqlite3, "sqlite3_status64", {C_INT,C_POINTER,C_POINTER,C_INT}, C_INT ),
	_sqlite3_db_status              = define_c_func( sqlite3, "sqlite3_db_status", {C_SQLITE3,C_INT,C_POINTER,C_POINTER,C_INT}, C_INT ),
	_sqlite3_stmt_status            = define_c_func( sqlite3, "sqlite3_stmt_status", {C_SQLITE3_STMT,C_INT,C_INT}, C_INT ),
	_sqlite3_backup_init            = define_c_func( sqlite3, "sqlite3_backup_init", {C_SQLITE3,C_STRING,C_SQLITE3,C_STRING}, C_SQLITE3_BACKUP ),
	_sqlite3_backup_step            = define_c_func( sqlite3, "sqlite3_backup_step", {C_SQLITE3_BACKUP,C_INT}, C_INT ),
	_sqlite3_backup_finish          = define_c_func( sqlite3, "sqlite3_backup_finish", {C_SQLITE3_BACKUP}, C_INT ),
	_sqlite3_backup_remaining       = define_c_func( sqlite3, "sqlite3_backup_remaining", {C_SQLITE3_BACKUP}, C_INT ),
	_sqlite3_backup_pagecount       = define_c_func( sqlite3, "sqlite3_backup_pagecount", {C_SQLITE3_BACKUP}, C_INT ),
	_sqlite3_wal_hook               = define_c_func( sqlite3, "sqlite3_wal_hook", {C_SQLITE3,C_CALLBACK,C_POINTER}, C_POINTER ),
	_sqlite3_wal_autocheckpoint     = define_c_func( sqlite3, "sqlite3_wal_autocheckpoint", {C_SQLITE3,C_INT}, C_INT ),
	_sqlite3_wal_checkpoint         = define_c_func( sqlite3, "sqlite3_wal_checkpoint", {C_SQLITE3,C_STRING}, C_INT ),
	_sqlite3_wal_checkpoint_v2      = define_c_func( sqlite3, "sqlite3_wal_checkpoint_v2", {C_SQLITE3,C_STRING,C_INT,C_POINTER,C_POINTER}, C_INT ),
	_sqlite3_db_cacheflush          = define_c_func( sqlite3, "sqlite3_db_cacheflush", {C_SQLITE3}, C_INT ),
	_sqlite3_system_errno           = define_c_func( sqlite3, "sqlite3_system_errno", {C_SQLITE3}, C_INT ),
	_sqlite3_serialize              = define_c_func( sqlite3, "sqlite3_serialize", {C_SQLITE3,C_STRING,C_POINTER,C_UINT}, C_STRING ),
	_sqlite3_deserialize            = define_c_func( sqlite3, "sqlite3_deserialize", {C_SQLITE3,C_STRING,C_POINTER,C_LONGLONG,C_LONGLONG,C_UINT}, C_INT ),
$

map _sqlite3_config = map:new()
map _sqlite3_db_config = map:new()


/*
** CAPI3REF: Compile-Time Library Version Numbers
**
** ^(The [SQLITE_VERSION] C preprocessor macro in the sqlite3.h header
** evaluates to a string literal that is the SQLite version in the
** format "X.Y.Z" where X is the major version number (always 3 for
** SQLite3) and Y is the minor version number and Z is the release number.)^
** ^(The [SQLITE_VERSION_NUMBER] C preprocessor macro resolves to an integer
** with the value (X*1000000 + Y*1000 + Z) where X, Y, and Z are the same
** numbers used in [SQLITE_VERSION].)^
** The SQLITE_VERSION_NUMBER for any given release of SQLite will also
** be larger than the release from which it is derived.  Either Y will
** be held constant and Z will be incremented or else Y will be incremented
** and Z will be reset to zero.
**
** Since [version 3.6.18] ([dateof:3.6.18]),
** SQLite source code has been stored in the
** <a href="http://www.fossil-scm.org/">Fossil configuration management
** system</a>.  ^The SQLITE_SOURCE_ID macro evaluates to
** a string which identifies a particular check-in of SQLite
** within its configuration management system.  ^The SQLITE_SOURCE_ID
** string contains the date and time of the check-in (UTC) and a SHA1
** or SHA3-256 hash of the entire source tree.  If the source code has
** been edited in any way since it was last checked in, then the last
** four hexadecimal digits of the hash may be modified.
**
** See also: [sqlite3_libversion()],
** [sqlite3_libversion_number()], [sqlite3_sourceid()],
** [sqlite_version()] and [sqlite_source_id()].
*/

public constant SQLITE_VERSION        = "3.33.0"
public constant SQLITE_VERSION_NUMBER = 3033000
public constant SQLITE_SOURCE_ID      = "2020-08-14 13:23:32 fca8dc8b578f215a969cd899336378966156154710873e68b3d9ac5881b0ff3f"


/*
** CAPI3REF: Run-Time Library Version Numbers
** KEYWORDS: sqlite3_version sqlite3_sourceid
**
** These interfaces provide the same information as the [SQLITE_VERSION],
** [SQLITE_VERSION_NUMBER], and [SQLITE_SOURCE_ID] C preprocessor macros
** but are associated with the library instead of the header file.  ^(Cautious
** programmers might include assert() statements in their application to
** verify that values returned by these interfaces match the macros in
** the header, and thus ensure that the application is
** compiled with matching library and header files.
**
** <blockquote><pre>
** assert( sqlite3_libversion_number()==SQLITE_VERSION_NUMBER );
** assert( strncmp(sqlite3_sourceid(),SQLITE_SOURCE_ID,80)==0 );
** assert( strcmp(sqlite3_libversion(),SQLITE_VERSION)==0 );
** </pre></blockquote>)^
**
** ^The sqlite3_version[] string constant contains the text of [SQLITE_VERSION]
** macro.  ^The sqlite3_libversion() function returns a pointer to the
** to the sqlite3_version[] string constant.  The sqlite3_libversion()
** function is provided for use in DLLs since DLL users usually do not have
** direct access to string constants within the DLL.  ^The
** sqlite3_libversion_number() function returns an integer equal to
** [SQLITE_VERSION_NUMBER].  ^(The sqlite3_sourceid() function returns
** a pointer to a string constant whose value is the same as the
** [SQLITE_SOURCE_ID] C preprocessor macro.  Except if SQLite is built
** using an edited copy of [the amalgamation], then the last four characters
** of the hash might be different from [SQLITE_SOURCE_ID].)^
**
** See also: [sqlite_version()] and [sqlite_source_id()].
*/

public constant sqlite3_version = peek_string( _sqlite3_version )

public function sqlite3_libversion()
	return peek_string( c_func( _sqlite3_libversion, {} ) )
end function

public function sqlite3_sourceid()
	return peek_string( c_func( _sqlite3_sourceid, {} ) )
end function

public function sqlite3_libversion_number()
	return c_func( _sqlite3_libversion_number, {} )
end function

public constant
	SQLITE_INVALID_VERSION        = -1,
	SQLITE_INVALID_VERSION_NUMBER = -2,
	SQLITE_INVALID_SOURCE_ID      = -3,
$

public function sqlite3_check_version()

	if not equal( sqlite3_libversion(), SQLITE_VERSION ) then
		return SQLITE_INVALID_VERSION
	end if

	if not equal( sqlite3_libversion_number(), SQLITE_VERSION_NUMBER ) then
		return SQLITE_INVALID_VERSION_NUMBER
	end if

	if not equal( sqlite3_sourceid(), SQLITE_SOURCE_ID ) then
		return SQLITE_INVALID_SOURCE_ID
	end if

	return SQLITE_OK
end function


/*
** CAPI3REF: Run-Time Library Compilation Options Diagnostics
**
** ^The sqlite3_compileoption_used() function returns 0 or 1
** indicating whether the specified option was defined at
** compile time.  ^The SQLITE_ prefix may be omitted from the
** option name passed to sqlite3_compileoption_used().
**
** ^The sqlite3_compileoption_get() function allows iterating
** over the list of options that were defined at compile time by
** returning the N-th compile time option string.  ^If N is out of range,
** sqlite3_compileoption_get() returns a NULL pointer.  ^The SQLITE_
** prefix is omitted from any strings returned by
** sqlite3_compileoption_get().
**
** ^Support for the diagnostic functions sqlite3_compileoption_used()
** and sqlite3_compileoption_get() may be omitted by specifying the
** [SQLITE_OMIT_COMPILEOPTION_DIAGS] option at compile time.
**
** See also: SQL functions [sqlite_compileoption_used()] and
** [sqlite_compileoption_get()] and the [compile_options pragma].
*/

public function sqlite3_compileoption_used( sequence optname )
	return c_func( _sqlite3_compileoption_used, {allocate_string(optname,TRUE)} )
end function

public function sqlite3_compileoption_get( integer opt )
	return peek_string( c_func( _sqlite3_compileoption_get, {opt} ) )
end function


/*
** CAPI3REF: Test To See If The Library Is Threadsafe
**
** ^The sqlite3_threadsafe() function returns zero if and only if
** SQLite was compiled with mutexing code omitted due to the
** [SQLITE_THREADSAFE] compile-time option being set to 0.
**
** SQLite can be compiled with or without mutexes.  When
** the [SQLITE_THREADSAFE] C preprocessor macro is 1 or 2, mutexes
** are enabled and SQLite is threadsafe.  When the
** [SQLITE_THREADSAFE] macro is 0,
** the mutexes are omitted.  Without the mutexes, it is not safe
** to use SQLite concurrently from more than one thread.
**
** Enabling mutexes incurs a measurable performance penalty.
** So if speed is of utmost importance, it makes sense to disable
** the mutexes.  But for maximum safety, mutexes should be enabled.
** ^The default behavior is for mutexes to be enabled.
**
** This interface can be used by an application to make sure that the
** version of SQLite that it is linking against was compiled with
** the desired setting of the [SQLITE_THREADSAFE] macro.
**
** This interface only reports on the compile-time mutex setting
** of the [SQLITE_THREADSAFE] flag.  If SQLite is compiled with
** SQLITE_THREADSAFE=1 or =2 then mutexes are enabled by default but
** can be fully or partially disabled using a call to [sqlite3_config()]
** with the verbs [SQLITE_CONFIG_SINGLETHREAD], [SQLITE_CONFIG_MULTITHREAD],
** or [SQLITE_CONFIG_SERIALIZED].  ^(The return value of the
** sqlite3_threadsafe() function shows only the compile-time setting of
** thread safety, not any run-time changes to that setting made by
** sqlite3_config(). In other words, the return value from sqlite3_threadsafe()
** is unchanged by calls to sqlite3_config().)^
**
** See the [threading mode] documentation for additional information.
*/

public function sqlite3_threadsafe()
	return c_func( _sqlite3_threadsafe, {} )
end function


/*
** CAPI3REF: Closing A Database Connection
** DESTRUCTOR: sqlite3
**
** ^The sqlite3_close() and sqlite3_close_v2() routines are destructors
** for the [sqlite3] object.
** ^Calls to sqlite3_close() and sqlite3_close_v2() return [SQLITE_OK] if
** the [sqlite3] object is successfully destroyed and all associated
** resources are deallocated.
**
** Ideally, applications should [sqlite3_finalize | finalize] all
** [prepared statements], [sqlite3_blob_close | close] all [BLOB handles], and
** [sqlite3_backup_finish | finish] all [sqlite3_backup] objects associated
** with the [sqlite3] object prior to attempting to close the object.
** ^If the database connection is associated with unfinalized prepared
** statements, BLOB handlers, and/or unfinished sqlite3_backup objects then
** sqlite3_close() will leave the database connection open and return
** [SQLITE_BUSY]. ^If sqlite3_close_v2() is called with unfinalized prepared
** statements, unclosed BLOB handlers, and/or unfinished sqlite3_backups,
** it returns [SQLITE_OK] regardless, but instead of deallocating the database
** connection immediately, it marks the database connection as an unusable
** "zombie" and makes arrangements to automatically deallocate the database
** connection after all prepared statements are finalized, all BLOB handles
** are closed, and all backups have finished. The sqlite3_close_v2() interface
** is intended for use with host languages that are garbage collected, and
** where the order in which destructors are called is arbitrary.
**
** ^If an [sqlite3] object is destroyed while a transaction is open,
** the transaction is automatically rolled back.
**
** The C parameter to [sqlite3_close(C)] and [sqlite3_close_v2(C)]
** must be either a NULL
** pointer or an [sqlite3] object pointer obtained
** from [sqlite3_open()], [sqlite3_open16()], or
** [sqlite3_open_v2()], and not previously closed.
** ^Calling sqlite3_close() or sqlite3_close_v2() with a NULL pointer
** argument is a harmless no-op.
*/

public function sqlite3_close( atom db )
	return c_func( _sqlite3_close, {db} )
end function

public function sqlite3_close_v2( atom db )
	return c_func( _sqlite3_close_v2, {db} )
end function


/*
** CAPI3REF: One-Step Query Execution Interface
** METHOD: sqlite3
**
** The sqlite3_exec() interface is a convenience wrapper around
** [sqlite3_prepare_v2()], [sqlite3_step()], and [sqlite3_finalize()],
** that allows an application to run multiple statements of SQL
** without having to use a lot of C code.
**
** ^The sqlite3_exec() interface runs zero or more UTF-8 encoded,
** semicolon-separate SQL statements passed into its 2nd argument,
** in the context of the [database connection] passed in as its 1st
** argument.  ^If the callback function of the 3rd argument to
** sqlite3_exec() is not NULL, then it is invoked for each result row
** coming out of the evaluated SQL statements.  ^The 4th argument to
** sqlite3_exec() is relayed through to the 1st argument of each
** callback invocation.  ^If the callback pointer to sqlite3_exec()
** is NULL, then no callback is ever invoked and result rows are
** ignored.
**
** ^If an error occurs while evaluating the SQL statements passed into
** sqlite3_exec(), then execution of the current statement stops and
** subsequent statements are skipped.  ^If the 5th parameter to sqlite3_exec()
** is not NULL then any error message is written into memory obtained
** from [sqlite3_malloc()] and passed back through the 5th parameter.
** To avoid memory leaks, the application should invoke [sqlite3_free()]
** on error message strings returned through the 5th parameter of
** sqlite3_exec() after the error message string is no longer needed.
** ^If the 5th parameter to sqlite3_exec() is not NULL and no errors
** occur, then sqlite3_exec() sets the pointer in its 5th parameter to
** NULL before returning.
**
** ^If an sqlite3_exec() callback returns non-zero, the sqlite3_exec()
** routine returns SQLITE_ABORT without invoking the callback again and
** without running any subsequent SQL statements.
**
** ^The 2nd argument to the sqlite3_exec() callback function is the
** number of columns in the result.  ^The 3rd argument to the sqlite3_exec()
** callback is an array of pointers to strings obtained as if from
** [sqlite3_column_text()], one for each column.  ^If an element of a
** result row is NULL then the corresponding string pointer for the
** sqlite3_exec() callback is a NULL pointer.  ^The 4th argument to the
** sqlite3_exec() callback is an array of pointers to strings where each
** entry represents the name of corresponding result column as obtained
** from [sqlite3_column_name()].
**
** ^If the 2nd parameter to sqlite3_exec() is a NULL pointer, a pointer
** to an empty string, or a pointer that contains only whitespace and/or
** SQL comments, then no SQL statements are evaluated and the database
** is not changed.
**
** Restrictions:
**
** <ul>
** <li> The application must ensure that the 1st parameter to sqlite3_exec()
**      is a valid and open [database connection].
** <li> The application must not close the [database connection] specified by
**      the 1st parameter to sqlite3_exec() while sqlite3_exec() is running.
** <li> The application must not modify the SQL statement text passed into
**      the 2nd parameter of sqlite3_exec() while sqlite3_exec() is running.
** </ul>
*/

public function sqlite3_exec( atom db, sequence sql, sequence func="", atom data=NULL, integer func_id=routine_id(func) )
	return c_func( _sqlite3_exec, {db,allocate_string(sql,TRUE),call_back(func_id),data,NULL} )
end function

public function sqlite3_exec_stmt( atom db, sequence sql, object params = {} )

	atom result, stmt
	{result,stmt} = sqlite3_prepare16_v2( db, sql )

	if result != SQLITE_OK then
		return {result,NULL}
	end if

	if atom( params ) then
		params = {params}
	end if

	for i = 1 to length( params ) do

		if atom( params[i] ) or length( params[i] ) != 2 then
			params[i] = {params[i]}
		end if

		object param_value = params[i][1]
		integer param_type = SQLITE_NULL

		if length( params[i] ) = 2   then param_type  = params[i][2]
		elsif integer( param_value ) then param_type = SQLITE_INTEGER
		elsif atom( param_value )    then param_type = SQLITE_FLOAT
		elsif string( param_value )  then param_type = SQLITE_TEXT
		else                              param_type = SQLITE_BLOB
		end if

		switch param_type do
			case SQLITE_INTEGER then sqlite3_bind_int( stmt, i, param_value )
			case SQLITE_FLOAT   then sqlite3_bind_double( stmt, i, param_value )
			case SQLITE_TEXT    then sqlite3_bind_text( stmt, i, param_value )
			case SQLITE_BLOB    then sqlite3_bind_blob( stmt, i, param_value )
		end switch

	end for

	result = sqlite3_step( stmt )

	sqlite3_finalize( stmt )

	return result
end function

public function sqlite3_exec_scalar( atom db, sequence sql, object params = {} )

	atom result, stmt
	{result,stmt} = sqlite3_prepare16_v2( db, sql )

	if result != SQLITE_OK then
		return {result,NULL}
	end if

	if atom( params ) then
		params = {params}
	end if

	for i = 1 to length( params ) do

		if atom( params[i] ) or length( params[i] ) != 2 then
			params[i] = {params[i]}
		end if

		object param_value = params[i][1]
		integer param_type = SQLITE_NULL

		if length( params[i] ) = 2   then param_type  = params[i][2]
		elsif integer( param_value ) then param_type = SQLITE_INTEGER
		elsif atom( param_value )    then param_type = SQLITE_FLOAT
		elsif string( param_value )  then param_type = SQLITE_TEXT
		else                              param_type = SQLITE_BLOB
		end if

		switch param_type do
			case SQLITE_INTEGER then sqlite3_bind_int( stmt, i, param_value )
			case SQLITE_FLOAT   then sqlite3_bind_double( stmt, i, param_value )
			case SQLITE_TEXT    then sqlite3_bind_text( stmt, i, param_value )
			case SQLITE_BLOB    then sqlite3_bind_blob( stmt, i, param_value )
		end switch

	end for

	result = sqlite3_step( stmt )

	if result != SQLITE_ROW then
		sqlite3_finalize( stmt )
		return {result,NULL}
	end if

	integer columns = sqlite3_column_count( stmt )

	if columns != 1 then
		sqlite3_finalize( stmt )
		return {SQLITE_MISUSE,NULL}
	end if

	sequence row = sqlite3_fetch_row( stmt )

	sqlite3_finalize( stmt )

	return {SQLITE_DONE,row[1]}
end function


/*
** CAPI3REF: Result Codes
** KEYWORDS: {result code definitions}
**
** Many SQLite functions return an integer result code from the set shown
** here in order to indicate success or failure.
**
** New error codes may be added in future versions of SQLite.
**
** See also: [extended result code definitions]
*/

public constant
	SQLITE_OK           =   0,  /* Successful result */
	/* beginning-of-error-codes */
	SQLITE_ERROR        =   1,  /* Generic error */
	SQLITE_INTERNAL     =   2,  /* Internal logic error in SQLite */
	SQLITE_PERM         =   3,  /* Access permission denied */
	SQLITE_ABORT        =   4,  /* Callback routine requested an abort */
	SQLITE_BUSY         =   5,  /* The database file is locked */
	SQLITE_LOCKED       =   6,  /* A table in the database is locked */
	SQLITE_NOMEM        =   7,  /* A malloc() failed */
	SQLITE_READONLY     =   8,  /* Attempt to write a readonly database */
	SQLITE_INTERRUPT    =   9,  /* Operation terminated by sqlite3_interrupt()*/
	SQLITE_IOERR        =  10,  /* Some kind of disk I/O error occurred */
	SQLITE_CORRUPT      =  11,  /* The database disk image is malformed */
	SQLITE_NOTFOUND     =  12,  /* Unknown opcode in sqlite3_file_control() */
	SQLITE_FULL         =  13,  /* Insertion failed because database is full */
	SQLITE_CANTOPEN     =  14,  /* Unable to open the database file */
	SQLITE_PROTOCOL     =  15,  /* Database lock protocol error */
	SQLITE_EMPTY        =  16,  /* Internal use only */
	SQLITE_SCHEMA       =  17,  /* The database schema changed */
	SQLITE_TOOBIG       =  18,  /* String or BLOB exceeds size limit */
	SQLITE_CONSTRAINT   =  19,  /* Abort due to constraint violation */
	SQLITE_MISMATCH     =  20,  /* Data type mismatch */
	SQLITE_MISUSE       =  21,  /* Library used incorrectly */
	SQLITE_NOLFS        =  22,  /* Uses OS features not supported on host */
	SQLITE_AUTH         =  23,  /* Authorization denied */
	SQLITE_FORMAT       =  24,  /* Not used */
	SQLITE_RANGE        =  25,  /* 2nd parameter to sqlite3_bind out of range */
	SQLITE_NOTADB       =  26,  /* File opened that is not a database file */
	SQLITE_NOTICE       =  27,  /* Notifications from sqlite3_log() */
	SQLITE_WARNING      =  28,  /* Warnings from sqlite3_log() */
	SQLITE_ROW          = 100,  /* sqlite3_step() has another row ready */
	SQLITE_DONE         = 101,  /* sqlite3_step() has finished executing */
	/* end-of-error-codes */
$


/*
** CAPI3REF: Extended Result Codes
** KEYWORDS: {extended result code definitions}
**
** In its default configuration, SQLite API routines return one of 30 integer
** [result codes].  However, experience has shown that many of
** these result codes are too coarse-grained.  They do not provide as
** much information about problems as programmers might like.  In an effort to
** address this, newer versions of SQLite (version 3.3.8 [dateof:3.3.8]
** and later) include
** support for additional result codes that provide more detailed information
** about errors. These [extended result codes] are enabled or disabled
** on a per database connection basis using the
** [sqlite3_extended_result_codes()] API.  Or, the extended code for
** the most recent error can be obtained using
** [sqlite3_extended_errcode()].
*/

public constant
	SQLITE_ERROR_MISSING_COLLSEQ    =  257,  -- (SQLITE_ERROR      | ( 1<<8))
	SQLITE_ERROR_RETRY              =  513,  -- (SQLITE_ERROR      | ( 2<<8))
	SQLITE_ERROR_SNAPSHOT           =  769,  -- (SQLITE_ERROR      | ( 3<<8))
	SQLITE_IOERR_READ               =  266,  -- (SQLITE_IOERR      | ( 1<<8))
	SQLITE_IOERR_SHORT_READ         =  522,  -- (SQLITE_IOERR      | ( 2<<8))
	SQLITE_IOERR_WRITE              =  778,  -- (SQLITE_IOERR      | ( 3<<8))
	SQLITE_IOERR_FSYNC              = 1034,  -- (SQLITE_IOERR      | ( 4<<8))
	SQLITE_IOERR_DIR_FSYNC          = 1290,  -- (SQLITE_IOERR      | ( 5<<8))
	SQLITE_IOERR_TRUNCATE           = 1546,  -- (SQLITE_IOERR      | ( 6<<8))
	SQLITE_IOERR_FSTAT              = 1802,  -- (SQLITE_IOERR      | ( 7<<8))
	SQLITE_IOERR_UNLOCK             = 2058,  -- (SQLITE_IOERR      | ( 8<<8))
	SQLITE_IOERR_RDLOCK             = 2314,  -- (SQLITE_IOERR      | ( 9<<8))
	SQLITE_IOERR_DELETE             = 2570,  -- (SQLITE_IOERR      | (10<<8))
	SQLITE_IOERR_BLOCKED            = 2826,  -- (SQLITE_IOERR      | (11<<8))
	SQLITE_IOERR_NOMEM              = 3082,  -- (SQLITE_IOERR      | (12<<8))
	SQLITE_IOERR_ACCESS             = 3338,  -- (SQLITE_IOERR      | (13<<8))
	SQLITE_IOERR_CHECKRESERVEDLOCK  = 3594,  -- (SQLITE_IOERR      | (14<<8))
	SQLITE_IOERR_LOCK               = 3850,  -- (SQLITE_IOERR      | (15<<8))
	SQLITE_IOERR_CLOSE              = 4106,  -- (SQLITE_IOERR      | (16<<8))
	SQLITE_IOERR_DIR_CLOSE          = 4362,  -- (SQLITE_IOERR      | (17<<8))
	SQLITE_IOERR_SHMOPEN            = 4618,  -- (SQLITE_IOERR      | (18<<8))
	SQLITE_IOERR_SHMSIZE            = 4874,  -- (SQLITE_IOERR      | (19<<8))
	SQLITE_IOERR_SHMLOCK            = 5130,  -- (SQLITE_IOERR      | (20<<8))
	SQLITE_IOERR_SHMMAP             = 5386,  -- (SQLITE_IOERR      | (21<<8))
	SQLITE_IOERR_SEEK               = 5642,  -- (SQLITE_IOERR      | (22<<8))
	SQLITE_IOERR_DELETE_NOENT       = 5898,  -- (SQLITE_IOERR      | (23<<8))
	SQLITE_IOERR_MMAP               = 6154,  -- (SQLITE_IOERR      | (24<<8))
	SQLITE_IOERR_GETTEMPPATH        = 6410,  -- (SQLITE_IOERR      | (25<<8))
	SQLITE_IOERR_CONVPATH           = 6666,  -- (SQLITE_IOERR      | (26<<8))
	SQLITE_IOERR_VNODE              = 6922,  -- (SQLITE_IOERR      | (27<<8))
	SQLITE_IOERR_AUTH               = 7178,  -- (SQLITE_IOERR      | (28<<8))
	SQLITE_IOERR_BEGIN_ATOMIC       = 7434,  -- (SQLITE_IOERR      | (29<<8))
	SQLITE_IOERR_COMMIT_ATOMIC      = 7690,  -- (SQLITE_IOERR      | (30<<8))
	SQLITE_IOERR_ROLLBACK_ATOMIC    = 7946,  -- (SQLITE_IOERR      | (31<<8))
	SQLITE_LOCKED_SHAREDCACHE       =  262,  -- (SQLITE_LOCKED     |  (1<<8))
	SQLITE_LOCKED_VTAB              =  518,  -- (SQLITE_LOCKED     |  (2<<8))
	SQLITE_BUSY_RECOVERY            =  261,  -- (SQLITE_BUSY       |  (1<<8))
	SQLITE_BUSY_SNAPSHOT            =  517,  -- (SQLITE_BUSY       |  (2<<8))
	SQLITE_CANTOPEN_NOTEMPDIR       =  270,  -- (SQLITE_CANTOPEN   |  (1<<8))
	SQLITE_CANTOPEN_ISDIR           =  526,  -- (SQLITE_CANTOPEN   |  (2<<8))
	SQLITE_CANTOPEN_FULLPATH        =  782,  -- (SQLITE_CANTOPEN   |  (3<<8))
	SQLITE_CANTOPEN_CONVPATH        = 1038,  -- (SQLITE_CANTOPEN   |  (4<<8))
	SQLITE_CANTOPEN_DIRTYWAL        = 1294,  -- (SQLITE_CANTOPEN   |  (5<<8)) /* Not Used */
	SQLITE_CORRUPT_VTAB             =  267,  -- (SQLITE_CORRUPT    |  (1<<8))
	SQLITE_CORRUPT_SEQUENCE         =  523,  -- (SQLITE_CORRUPT    |  (2<<8))
	SQLITE_READONLY_RECOVERY        =  264,  -- (SQLITE_READONLY   |  (1<<8))
	SQLITE_READONLY_CANTLOCK        =  520,  -- (SQLITE_READONLY   |  (2<<8))
	SQLITE_READONLY_ROLLBACK        =  776,  -- (SQLITE_READONLY   |  (3<<8))
	SQLITE_READONLY_DBMOVED         = 1032,  -- (SQLITE_READONLY   |  (4<<8))
	SQLITE_READONLY_CANTINIT        = 1288,  -- (SQLITE_READONLY   |  (5<<8))
	SQLITE_READONLY_DIRECTORY       = 1544,  -- (SQLITE_READONLY   |  (6<<8))
	SQLITE_ABORT_ROLLBACK           =  516,  -- (SQLITE_ABORT      |  (2<<8))
	SQLITE_CONSTRAINT_CHECK         =  275,  -- (SQLITE_CONSTRAINT |  (1<<8))
	SQLITE_CONSTRAINT_COMMITHOOK    =  531,  -- (SQLITE_CONSTRAINT |  (2<<8))
	SQLITE_CONSTRAINT_FOREIGNKEY    =  787,  -- (SQLITE_CONSTRAINT |  (3<<8))
	SQLITE_CONSTRAINT_FUNCTION      = 1043,  -- (SQLITE_CONSTRAINT |  (4<<8))
	SQLITE_CONSTRAINT_NOTNULL       = 1299,  -- (SQLITE_CONSTRAINT |  (5<<8))
	SQLITE_CONSTRAINT_PRIMARYKEY    = 1555,  -- (SQLITE_CONSTRAINT |  (6<<8))
	SQLITE_CONSTRAINT_TRIGGER       = 1811,  -- (SQLITE_CONSTRAINT |  (7<<8))
	SQLITE_CONSTRAINT_UNIQUE        = 2067,  -- (SQLITE_CONSTRAINT |  (8<<8))
	SQLITE_CONSTRAINT_VTAB          = 2323,  -- (SQLITE_CONSTRAINT |  (9<<8))
	SQLITE_CONSTRAINT_ROWID         = 2579,  -- (SQLITE_CONSTRAINT | (10<<8))
	SQLITE_NOTICE_RECOVER_WAL       =  283,  -- (SQLITE_NOTICE     |  (1<<8))
	SQLITE_NOTICE_RECOVER_ROLLBACK  =  539,  -- (SQLITE_NOTICE     |  (2<<8))
	SQLITE_WARNING_AUTOINDEX        =  284,  -- (SQLITE_WARNING    |  (1<<8))
	SQLITE_AUTH_USER                =  279,  -- (SQLITE_AUTH       |  (1<<8))
	SQLITE_OK_LOAD_PERMANENTLY      =  256,  -- (SQLITE_OK         |  (1<<8))
$


/*
** CAPI3REF: Flags For File Open Operations
**
** These bit values are intended for use in the
** 3rd parameter to the [sqlite3_open_v2()] interface and
** in the 4th parameter to the [sqlite3_vfs.xOpen] method.
*/

public constant
	SQLITE_OPEN_READONLY        = 0x00000001, /* Ok for sqlite3_open_v2() */
	SQLITE_OPEN_READWRITE       = 0x00000002, /* Ok for sqlite3_open_v2() */
	SQLITE_OPEN_CREATE          = 0x00000004, /* Ok for sqlite3_open_v2() */
	SQLITE_OPEN_DELETEONCLOSE   = 0x00000008, /* VFS only */
	SQLITE_OPEN_EXCLUSIVE       = 0x00000010, /* VFS only */
	SQLITE_OPEN_AUTOPROXY       = 0x00000020, /* VFS only */
	SQLITE_OPEN_URI             = 0x00000040, /* Ok for sqlite3_open_v2() */
	SQLITE_OPEN_MEMORY          = 0x00000080, /* Ok for sqlite3_open_v2() */
	SQLITE_OPEN_MAIN_DB         = 0x00000100, /* VFS only */
	SQLITE_OPEN_TEMP_DB         = 0x00000200, /* VFS only */
	SQLITE_OPEN_TRANSIENT_DB    = 0x00000400, /* VFS only */
	SQLITE_OPEN_MAIN_JOURNAL    = 0x00000800, /* VFS only */
	SQLITE_OPEN_TEMP_JOURNAL    = 0x00001000, /* VFS only */
	SQLITE_OPEN_SUBJOURNAL      = 0x00002000, /* VFS only */
	SQLITE_OPEN_NOMUTEX         = 0x00008000, /* Ok for sqlite3_open_v2() */
	SQLITE_OPEN_FULLMUTEX       = 0x00010000, /* Ok for sqlite3_open_v2() */
	SQLITE_OPEN_SHAREDCACHE     = 0x00020000, /* Ok for sqlite3_open_v2() */
	SQLITE_OPEN_PRIVATECACHE    = 0x00040000, /* Ok for sqlite3_open_v2() */
	SQLITE_OPEN_WAL             = 0x00080000, /* VFS only */
 /* Reserved:                     0x00F00000, */
	/* Legacy compatibility: */
	SQLITE_OPEN_MASTER_JOURNAL  = 0x00004000,  /* VFS only */
$


/*
** CAPI3REF: Device Characteristics
**
** The xDeviceCharacteristics method of the [sqlite3_io_methods]
** object returns an integer which is a vector of these
** bit values expressing I/O characteristics of the mass storage
** device that holds the file that the [sqlite3_io_methods]
** refers to.
**
** The SQLITE_IOCAP_ATOMIC property means that all writes of
** any size are atomic.  The SQLITE_IOCAP_ATOMICnnn values
** mean that writes of blocks that are nnn bytes in size and
** are aligned to an address which is an integer multiple of
** nnn are atomic.  The SQLITE_IOCAP_SAFE_APPEND value means
** that when data is appended to a file, the data is appended
** first then the size of the file is extended, never the other
** way around.  The SQLITE_IOCAP_SEQUENTIAL property means that
** information is written to disk in the same order as calls
** to xWrite().  The SQLITE_IOCAP_POWERSAFE_OVERWRITE property means that
** after reboot following a crash or power loss, the only bytes in a
** file that were written at the application level might have changed
** and that adjacent bytes, even bytes within the same sector are
** guaranteed to be unchanged.  The SQLITE_IOCAP_UNDELETABLE_WHEN_OPEN
** flag indicates that a file cannot be deleted when open.  The
** SQLITE_IOCAP_IMMUTABLE flag indicates that the file is on
** read-only media and cannot be changed even by processes with
** elevated privileges.
**
** The SQLITE_IOCAP_BATCH_ATOMIC property means that the underlying
** filesystem supports doing multiple write operations atomically when those
** write operations are bracketed by [SQLITE_FCNTL_BEGIN_ATOMIC_WRITE] and
** [SQLITE_FCNTL_COMMIT_ATOMIC_WRITE].
*/

public constant
	SQLITE_IOCAP_ATOMIC                 = 0x00000001,
	SQLITE_IOCAP_ATOMIC512              = 0x00000002,
	SQLITE_IOCAP_ATOMIC1K               = 0x00000004,
	SQLITE_IOCAP_ATOMIC2K               = 0x00000008,
	SQLITE_IOCAP_ATOMIC4K               = 0x00000010,
	SQLITE_IOCAP_ATOMIC8K               = 0x00000020,
	SQLITE_IOCAP_ATOMIC16K              = 0x00000040,
	SQLITE_IOCAP_ATOMIC32K              = 0x00000080,
	SQLITE_IOCAP_ATOMIC64K              = 0x00000100,
	SQLITE_IOCAP_SAFE_APPEND            = 0x00000200,
	SQLITE_IOCAP_SEQUENTIAL             = 0x00000400,
	SQLITE_IOCAP_UNDELETABLE_WHEN_OPEN  = 0x00000800,
	SQLITE_IOCAP_POWERSAFE_OVERWRITE    = 0x00001000,
	SQLITE_IOCAP_IMMUTABLE              = 0x00002000,
	SQLITE_IOCAP_BATCH_ATOMIC           = 0x00004000,
$


/*
** CAPI3REF: File Locking Levels
**
** SQLite uses one of these integer values as the second
** argument to calls it makes to the xLock() and xUnlock() methods
** of an [sqlite3_io_methods] object.
*/

public constant
	SQLITE_LOCK_NONE        = 0,
	SQLITE_LOCK_SHARED      = 1,
	SQLITE_LOCK_RESERVED    = 2,
	SQLITE_LOCK_PENDING     = 3,
	SQLITE_LOCK_EXCLUSIVE   = 4,
$


/*
** CAPI3REF: Synchronization Type Flags
**
** When SQLite invokes the xSync() method of an
** [sqlite3_io_methods] object it uses a combination of
** these integer values as the second argument.
**
** When the SQLITE_SYNC_DATAONLY flag is used, it means that the
** sync operation only needs to flush data to mass storage.  Inode
** information need not be flushed. If the lower four bits of the flag
** equal SQLITE_SYNC_NORMAL, that means to use normal fsync() semantics.
** If the lower four bits equal SQLITE_SYNC_FULL, that means
** to use Mac OS X style fullsync instead of fsync().
**
** Do not confuse the SQLITE_SYNC_NORMAL and SQLITE_SYNC_FULL flags
** with the [PRAGMA synchronous]=NORMAL and [PRAGMA synchronous]=FULL
** settings.  The [synchronous pragma] determines when calls to the
** xSync VFS method occur and applies uniformly across all platforms.
** The SQLITE_SYNC_NORMAL and SQLITE_SYNC_FULL flags determine how
** energetic or rigorous or forceful the sync operations are and
** only make a difference on Mac OSX for the default SQLite code.
** (Third-party VFS implementations might also make the distinction
** between SQLITE_SYNC_NORMAL and SQLITE_SYNC_FULL, but among the
** operating systems natively supported by SQLite, only Mac OSX
** cares about the difference.)
*/

public constant
	SQLITE_SYNC_NORMAL      = 0x00002,
	SQLITE_SYNC_FULL        = 0x00003,
	SQLITE_SYNC_DATAONLY    = 0x00010,
$


/*
** CAPI3REF: Standard File Control Opcodes
** KEYWORDS: {file control opcodes} {file control opcode}
**
** These integer constants are opcodes for the xFileControl method
** of the [sqlite3_io_methods] object and for the [sqlite3_file_control()]
** interface.
**
** <ul>
** <li>[[SQLITE_FCNTL_LOCKSTATE]]
** The [SQLITE_FCNTL_LOCKSTATE] opcode is used for debugging.  This
** opcode causes the xFileControl method to write the current state of
** the lock (one of [SQLITE_LOCK_NONE], [SQLITE_LOCK_SHARED],
** [SQLITE_LOCK_RESERVED], [SQLITE_LOCK_PENDING], or [SQLITE_LOCK_EXCLUSIVE])
** into an integer that the pArg argument points to. This capability
** is used during testing and is only available when the SQLITE_TEST
** compile-time option is used.
**
** <li>[[SQLITE_FCNTL_SIZE_HINT]]
** The [SQLITE_FCNTL_SIZE_HINT] opcode is used by SQLite to give the VFS
** layer a hint of how large the database file will grow to be during the
** current transaction.  This hint is not guaranteed to be accurate but it
** is often close.  The underlying VFS might choose to preallocate database
** file space based on this hint in order to help writes to the database
** file run faster.
**
** <li>[[SQLITE_FCNTL_SIZE_LIMIT]]
** The [SQLITE_FCNTL_SIZE_LIMIT] opcode is used by in-memory VFS that
** implements [sqlite3_deserialize()] to set an upper bound on the size
** of the in-memory database.  The argument is a pointer to a [sqlite3_int64].
** If the integer pointed to is negative, then it is filled in with the
** current limit.  Otherwise the limit is set to the larger of the value
** of the integer pointed to and the current database size.  The integer
** pointed to is set to the new limit.
**
** <li>[[SQLITE_FCNTL_CHUNK_SIZE]]
** The [SQLITE_FCNTL_CHUNK_SIZE] opcode is used to request that the VFS
** extends and truncates the database file in chunks of a size specified
** by the user. The fourth argument to [sqlite3_file_control()] should
** point to an integer (type int) containing the new chunk-size to use
** for the nominated database. Allocating database file space in large
** chunks (say 1MB at a time), may reduce file-system fragmentation and
** improve performance on some systems.
**
** <li>[[SQLITE_FCNTL_FILE_POINTER]]
** The [SQLITE_FCNTL_FILE_POINTER] opcode is used to obtain a pointer
** to the [sqlite3_file] object associated with a particular database
** connection.  See also [SQLITE_FCNTL_JOURNAL_POINTER].
**
** <li>[[SQLITE_FCNTL_JOURNAL_POINTER]]
** The [SQLITE_FCNTL_JOURNAL_POINTER] opcode is used to obtain a pointer
** to the [sqlite3_file] object associated with the journal file (either
** the [rollback journal] or the [write-ahead log]) for a particular database
** connection.  See also [SQLITE_FCNTL_FILE_POINTER].
**
** <li>[[SQLITE_FCNTL_SYNC_OMITTED]]
** No longer in use.
**
** <li>[[SQLITE_FCNTL_SYNC]]
** The [SQLITE_FCNTL_SYNC] opcode is generated internally by SQLite and
** sent to the VFS immediately before the xSync method is invoked on a
** database file descriptor. Or, if the xSync method is not invoked
** because the user has configured SQLite with
** [PRAGMA synchronous | PRAGMA synchronous=OFF] it is invoked in place
** of the xSync method. In most cases, the pointer argument passed with
** this file-control is NULL. However, if the database file is being synced
** as part of a multi-database commit, the argument points to a nul-terminated
** string containing the transactions super-journal file name. VFSes that
** do not need this signal should silently ignore this opcode. Applications
** should not call [sqlite3_file_control()] with this opcode as doing so may
** disrupt the operation of the specialized VFSes that do require it.
**
** <li>[[SQLITE_FCNTL_COMMIT_PHASETWO]]
** The [SQLITE_FCNTL_COMMIT_PHASETWO] opcode is generated internally by SQLite
** and sent to the VFS after a transaction has been committed immediately
** but before the database is unlocked. VFSes that do not need this signal
** should silently ignore this opcode. Applications should not call
** [sqlite3_file_control()] with this opcode as doing so may disrupt the
** operation of the specialized VFSes that do require it.
**
** <li>[[SQLITE_FCNTL_WIN32_AV_RETRY]]
** ^The [SQLITE_FCNTL_WIN32_AV_RETRY] opcode is used to configure automatic
** retry counts and intervals for certain disk I/O operations for the
** windows [VFS] in order to provide robustness in the presence of
** anti-virus programs.  By default, the windows VFS will retry file read,
** file write, and file delete operations up to 10 times, with a delay
** of 25 milliseconds before the first retry and with the delay increasing
** by an additional 25 milliseconds with each subsequent retry.  This
** opcode allows these two values (10 retries and 25 milliseconds of delay)
** to be adjusted.  The values are changed for all database connections
** within the same process.  The argument is a pointer to an array of two
** integers where the first integer is the new retry count and the second
** integer is the delay.  If either integer is negative, then the setting
** is not changed but instead the prior value of that setting is written
** into the array entry, allowing the current retry settings to be
** interrogated.  The zDbName parameter is ignored.
**
** <li>[[SQLITE_FCNTL_PERSIST_WAL]]
** ^The [SQLITE_FCNTL_PERSIST_WAL] opcode is used to set or query the
** persistent [WAL | Write Ahead Log] setting.  By default, the auxiliary
** write ahead log ([WAL file]) and shared memory
** files used for transaction control
** are automatically deleted when the latest connection to the database
** closes.  Setting persistent WAL mode causes those files to persist after
** close.  Persisting the files is useful when other processes that do not
** have write permission on the directory containing the database file want
** to read the database file, as the WAL and shared memory files must exist
** in order for the database to be readable.  The fourth parameter to
** [sqlite3_file_control()] for this opcode should be a pointer to an integer.
** That integer is 0 to disable persistent WAL mode or 1 to enable persistent
** WAL mode.  If the integer is -1, then it is overwritten with the current
** WAL persistence setting.
**
** <li>[[SQLITE_FCNTL_POWERSAFE_OVERWRITE]]
** ^The [SQLITE_FCNTL_POWERSAFE_OVERWRITE] opcode is used to set or query the
** persistent "powersafe-overwrite" or "PSOW" setting.  The PSOW setting
** determines the [SQLITE_IOCAP_POWERSAFE_OVERWRITE] bit of the
** xDeviceCharacteristics methods. The fourth parameter to
** [sqlite3_file_control()] for this opcode should be a pointer to an integer.
** That integer is 0 to disable zero-damage mode or 1 to enable zero-damage
** mode.  If the integer is -1, then it is overwritten with the current
** zero-damage mode setting.
**
** <li>[[SQLITE_FCNTL_OVERWRITE]]
** ^The [SQLITE_FCNTL_OVERWRITE] opcode is invoked by SQLite after opening
** a write transaction to indicate that, unless it is rolled back for some
** reason, the entire database file will be overwritten by the current
** transaction. This is used by VACUUM operations.
**
** <li>[[SQLITE_FCNTL_VFSNAME]]
** ^The [SQLITE_FCNTL_VFSNAME] opcode can be used to obtain the names of
** all [VFSes] in the VFS stack.  The names are of all VFS shims and the
** final bottom-level VFS are written into memory obtained from
** [sqlite3_malloc()] and the result is stored in the char* variable
** that the fourth parameter of [sqlite3_file_control()] points to.
** The caller is responsible for freeing the memory when done.  As with
** all file-control actions, there is no guarantee that this will actually
** do anything.  Callers should initialize the char* variable to a NULL
** pointer in case this file-control is not implemented.  This file-control
** is intended for diagnostic use only.
**
** <li>[[SQLITE_FCNTL_VFS_POINTER]]
** ^The [SQLITE_FCNTL_VFS_POINTER] opcode finds a pointer to the top-level
** [VFSes] currently in use.  ^(The argument X in
** sqlite3_file_control(db,SQLITE_FCNTL_VFS_POINTER,X) must be
** of type "[sqlite3_vfs] **".  This opcodes will set *X
** to a pointer to the top-level VFS.)^
** ^When there are multiple VFS shims in the stack, this opcode finds the
** upper-most shim only.
**
** <li>[[SQLITE_FCNTL_PRAGMA]]
** ^Whenever a [PRAGMA] statement is parsed, an [SQLITE_FCNTL_PRAGMA]
** file control is sent to the open [sqlite3_file] object corresponding
** to the database file to which the pragma statement refers. ^The argument
** to the [SQLITE_FCNTL_PRAGMA] file control is an array of
** pointers to strings (char**) in which the second element of the array
** is the name of the pragma and the third element is the argument to the
** pragma or NULL if the pragma has no argument.  ^The handler for an
** [SQLITE_FCNTL_PRAGMA] file control can optionally make the first element
** of the char** argument point to a string obtained from [sqlite3_mprintf()]
** or the equivalent and that string will become the result of the pragma or
** the error message if the pragma fails. ^If the
** [SQLITE_FCNTL_PRAGMA] file control returns [SQLITE_NOTFOUND], then normal
** [PRAGMA] processing continues.  ^If the [SQLITE_FCNTL_PRAGMA]
** file control returns [SQLITE_OK], then the parser assumes that the
** VFS has handled the PRAGMA itself and the parser generates a no-op
** prepared statement if result string is NULL, or that returns a copy
** of the result string if the string is non-NULL.
** ^If the [SQLITE_FCNTL_PRAGMA] file control returns
** any result code other than [SQLITE_OK] or [SQLITE_NOTFOUND], that means
** that the VFS encountered an error while handling the [PRAGMA] and the
** compilation of the PRAGMA fails with an error.  ^The [SQLITE_FCNTL_PRAGMA]
** file control occurs at the beginning of pragma statement analysis and so
** it is able to override built-in [PRAGMA] statements.
**
** <li>[[SQLITE_FCNTL_BUSYHANDLER]]
** ^The [SQLITE_FCNTL_BUSYHANDLER]
** file-control may be invoked by SQLite on the database file handle
** shortly after it is opened in order to provide a custom VFS with access
** to the connection's busy-handler callback. The argument is of type (void**)
** - an array of two (void *) values. The first (void *) actually points
** to a function of type (int (*)(void *)). In order to invoke the connection's
** busy-handler, this function should be invoked with the second (void *) in
** the array as the only argument. If it returns non-zero, then the operation
** should be retried. If it returns zero, the custom VFS should abandon the
** current operation.
**
** <li>[[SQLITE_FCNTL_TEMPFILENAME]]
** ^Applications can invoke the [SQLITE_FCNTL_TEMPFILENAME] file-control
** to have SQLite generate a
** temporary filename using the same algorithm that is followed to generate
** temporary filenames for TEMP tables and other internal uses.  The
** argument should be a char** which will be filled with the filename
** written into memory obtained from [sqlite3_malloc()].  The caller should
** invoke [sqlite3_free()] on the result to avoid a memory leak.
**
** <li>[[SQLITE_FCNTL_MMAP_SIZE]]
** The [SQLITE_FCNTL_MMAP_SIZE] file control is used to query or set the
** maximum number of bytes that will be used for memory-mapped I/O.
** The argument is a pointer to a value of type sqlite3_int64 that
** is an advisory maximum number of bytes in the file to memory map.  The
** pointer is overwritten with the old value.  The limit is not changed if
** the value originally pointed to is negative, and so the current limit
** can be queried by passing in a pointer to a negative number.  This
** file-control is used internally to implement [PRAGMA mmap_size].
**
** <li>[[SQLITE_FCNTL_TRACE]]
** The [SQLITE_FCNTL_TRACE] file control provides advisory information
** to the VFS about what the higher layers of the SQLite stack are doing.
** This file control is used by some VFS activity tracing [shims].
** The argument is a zero-terminated string.  Higher layers in the
** SQLite stack may generate instances of this file control if
** the [SQLITE_USE_FCNTL_TRACE] compile-time option is enabled.
**
** <li>[[SQLITE_FCNTL_HAS_MOVED]]
** The [SQLITE_FCNTL_HAS_MOVED] file control interprets its argument as a
** pointer to an integer and it writes a boolean into that integer depending
** on whether or not the file has been renamed, moved, or deleted since it
** was first opened.
**
** <li>[[SQLITE_FCNTL_WIN32_GET_HANDLE]]
** The [SQLITE_FCNTL_WIN32_GET_HANDLE] opcode can be used to obtain the
** underlying native file handle associated with a file handle.  This file
** control interprets its argument as a pointer to a native file handle and
** writes the resulting value there.
**
** <li>[[SQLITE_FCNTL_WIN32_SET_HANDLE]]
** The [SQLITE_FCNTL_WIN32_SET_HANDLE] opcode is used for debugging.  This
** opcode causes the xFileControl method to swap the file handle with the one
** pointed to by the pArg argument.  This capability is used during testing
** and only needs to be supported when SQLITE_TEST is defined.
**
** <li>[[SQLITE_FCNTL_WAL_BLOCK]]
** The [SQLITE_FCNTL_WAL_BLOCK] is a signal to the VFS layer that it might
** be advantageous to block on the next WAL lock if the lock is not immediately
** available.  The WAL subsystem issues this signal during rare
** circumstances in order to fix a problem with priority inversion.
** Applications should <em>not</em> use this file-control.
**
** <li>[[SQLITE_FCNTL_ZIPVFS]]
** The [SQLITE_FCNTL_ZIPVFS] opcode is implemented by zipvfs only. All other
** VFS should return SQLITE_NOTFOUND for this opcode.
**
** <li>[[SQLITE_FCNTL_RBU]]
** The [SQLITE_FCNTL_RBU] opcode is implemented by the special VFS used by
** the RBU extension only.  All other VFS should return SQLITE_NOTFOUND for
** this opcode.
**
** <li>[[SQLITE_FCNTL_BEGIN_ATOMIC_WRITE]]
** If the [SQLITE_FCNTL_BEGIN_ATOMIC_WRITE] opcode returns SQLITE_OK, then
** the file descriptor is placed in "batch write mode", which
** means all subsequent write operations will be deferred and done
** atomically at the next [SQLITE_FCNTL_COMMIT_ATOMIC_WRITE].  Systems
** that do not support batch atomic writes will return SQLITE_NOTFOUND.
** ^Following a successful SQLITE_FCNTL_BEGIN_ATOMIC_WRITE and prior to
** the closing [SQLITE_FCNTL_COMMIT_ATOMIC_WRITE] or
** [SQLITE_FCNTL_ROLLBACK_ATOMIC_WRITE], SQLite will make
** no VFS interface calls on the same [sqlite3_file] file descriptor
** except for calls to the xWrite method and the xFileControl method
** with [SQLITE_FCNTL_SIZE_HINT].
**
** <li>[[SQLITE_FCNTL_COMMIT_ATOMIC_WRITE]]
** The [SQLITE_FCNTL_COMMIT_ATOMIC_WRITE] opcode causes all write
** operations since the previous successful call to
** [SQLITE_FCNTL_BEGIN_ATOMIC_WRITE] to be performed atomically.
** This file control returns [SQLITE_OK] if and only if the writes were
** all performed successfully and have been committed to persistent storage.
** ^Regardless of whether or not it is successful, this file control takes
** the file descriptor out of batch write mode so that all subsequent
** write operations are independent.
** ^SQLite will never invoke SQLITE_FCNTL_COMMIT_ATOMIC_WRITE without
** a prior successful call to [SQLITE_FCNTL_BEGIN_ATOMIC_WRITE].
**
** <li>[[SQLITE_FCNTL_ROLLBACK_ATOMIC_WRITE]]
** The [SQLITE_FCNTL_ROLLBACK_ATOMIC_WRITE] opcode causes all write
** operations since the previous successful call to
** [SQLITE_FCNTL_BEGIN_ATOMIC_WRITE] to be rolled back.
** ^This file control takes the file descriptor out of batch write mode
** so that all subsequent write operations are independent.
** ^SQLite will never invoke SQLITE_FCNTL_ROLLBACK_ATOMIC_WRITE without
** a prior successful call to [SQLITE_FCNTL_BEGIN_ATOMIC_WRITE].
**
** <li>[[SQLITE_FCNTL_LOCK_TIMEOUT]]
** The [SQLITE_FCNTL_LOCK_TIMEOUT] opcode is used to configure a VFS
** to block for up to M milliseconds before failing when attempting to
** obtain a file lock using the xLock or xShmLock methods of the VFS.
** The parameter is a pointer to a 32-bit signed integer that contains
** the value that M is to be set to. Before returning, the 32-bit signed
** integer is overwritten with the previous value of M.
**
** <li>[[SQLITE_FCNTL_DATA_VERSION]]
** The [SQLITE_FCNTL_DATA_VERSION] opcode is used to detect changes to
** a database file.  The argument is a pointer to a 32-bit unsigned integer.
** The "data version" for the pager is written into the pointer.  The
** "data version" changes whenever any change occurs to the corresponding
** database file, either through SQL statements on the same database
** connection or through transactions committed by separate database
** connections possibly in other processes. The [sqlite3_total_changes()]
** interface can be used to find if any database on the connection has changed,
** but that interface responds to changes on TEMP as well as MAIN and does
** not provide a mechanism to detect changes to MAIN only.  Also, the
** [sqlite3_total_changes()] interface responds to internal changes only and
** omits changes made by other database connections.  The
** [PRAGMA data_version] command provides a mechanism to detect changes to
** a single attached database that occur due to other database connections,
** but omits changes implemented by the database connection on which it is
** called.  This file control is the only mechanism to detect changes that
** happen either internally or externally and that are associated with
** a particular attached database.
**
** <li>[[SQLITE_FCNTL_CKPT_START]]
** The [SQLITE_FCNTL_CKPT_START] opcode is invoked from within a checkpoint
** in wal mode before the client starts to copy pages from the wal
** file to the database file.
**
** <li>[[SQLITE_FCNTL_CKPT_DONE]]
** The [SQLITE_FCNTL_CKPT_DONE] opcode is invoked from within a checkpoint
** in wal mode after the client has finished copying pages from the wal
** file to the database file, but before the *-shm file is updated to
** record the fact that the pages have been checkpointed.
** </ul>
*/

public constant
	SQLITE_FCNTL_LOCKSTATE              =  1,
	SQLITE_FCNTL_GET_LOCKPROXYFILE      =  2,
	SQLITE_FCNTL_SET_LOCKPROXYFILE      =  3,
	SQLITE_FCNTL_LAST_ERRNO             =  4,
	SQLITE_FCNTL_SIZE_HINT              =  5,
	SQLITE_FCNTL_CHUNK_SIZE             =  6,
	SQLITE_FCNTL_FILE_POINTER           =  7,
	SQLITE_FCNTL_SYNC_OMITTED           =  8,
	SQLITE_FCNTL_WIN32_AV_RETRY         =  9,
	SQLITE_FCNTL_PERSIST_WAL            = 10,
	SQLITE_FCNTL_OVERWRITE              = 11,
	SQLITE_FCNTL_VFSNAME                = 12,
	SQLITE_FCNTL_POWERSAFE_OVERWRITE    = 13,
	SQLITE_FCNTL_PRAGMA                 = 14,
	SQLITE_FCNTL_BUSYHANDLER            = 15,
	SQLITE_FCNTL_TEMPFILENAME           = 16,
	SQLITE_FCNTL_MMAP_SIZE              = 18,
	SQLITE_FCNTL_TRACE                  = 19,
	SQLITE_FCNTL_HAS_MOVED              = 20,
	SQLITE_FCNTL_SYNC                   = 21,
	SQLITE_FCNTL_COMMIT_PHASETWO        = 22,
	SQLITE_FCNTL_WIN32_SET_HANDLE       = 23,
	SQLITE_FCNTL_WAL_BLOCK              = 24,
	SQLITE_FCNTL_ZIPVFS                 = 25,
	SQLITE_FCNTL_RBU                    = 26,
	SQLITE_FCNTL_VFS_POINTER            = 27,
	SQLITE_FCNTL_JOURNAL_POINTER        = 28,
	SQLITE_FCNTL_WIN32_GET_HANDLE       = 29,
	SQLITE_FCNTL_PDB                    = 30,
	SQLITE_FCNTL_BEGIN_ATOMIC_WRITE     = 31,
	SQLITE_FCNTL_COMMIT_ATOMIC_WRITE    = 32,
	SQLITE_FCNTL_ROLLBACK_ATOMIC_WRITE  = 33,
	SQLITE_FCNTL_LOCK_TIMEOUT           = 34,
	SQLITE_FCNTL_DATA_VERSION           = 35,
	SQLITE_FCNTL_SIZE_LIMIT             = 36,

	/* deprecated names */
	SQLITE_GET_LOCKPROXYFILE    = SQLITE_FCNTL_GET_LOCKPROXYFILE,
	SQLITE_SET_LOCKPROXYFILE    = SQLITE_FCNTL_SET_LOCKPROXYFILE,
	SQLITE_LAST_ERRNO           = SQLITE_FCNTL_LAST_ERRNO,
$


/*
** CAPI3REF: Flags for the xAccess VFS method
**
** These integer constants can be used as the third parameter to
** the xAccess method of an [sqlite3_vfs] object.  They determine
** what kind of permissions the xAccess method is looking for.
** With SQLITE_ACCESS_EXISTS, the xAccess method
** simply checks whether the file exists.
** With SQLITE_ACCESS_READWRITE, the xAccess method
** checks whether the named directory is both readable and writable
** (in other words, if files can be added, removed, and renamed within
** the directory).
** The SQLITE_ACCESS_READWRITE constant is currently used only by the
** [temp_store_directory pragma], though this could change in a future
** release of SQLite.
** With SQLITE_ACCESS_READ, the xAccess method
** checks whether the file is readable.  The SQLITE_ACCESS_READ constant is
** currently unused, though it might be used in a future release of
** SQLite.
*/

public constant
	SQLITE_ACCESS_EXISTS    = 0,
	SQLITE_ACCESS_READWRITE = 1, /* Used by PRAGMA temp_store_directory */
	SQLITE_ACCESS_READ      = 2, /* Unused */
$


/*
** CAPI3REF: Flags for the xShmLock VFS method
**
** These integer constants define the various locking operations
** allowed by the xShmLock method of [sqlite3_io_methods].  The
** following are the only legal combinations of flags to the
** xShmLock method:
**
** <ul>
** <li>  SQLITE_SHM_LOCK | SQLITE_SHM_SHARED
** <li>  SQLITE_SHM_LOCK | SQLITE_SHM_EXCLUSIVE
** <li>  SQLITE_SHM_UNLOCK | SQLITE_SHM_SHARED
** <li>  SQLITE_SHM_UNLOCK | SQLITE_SHM_EXCLUSIVE
** </ul>
**
** When unlocking, the same SHARED or EXCLUSIVE flag must be supplied as
** was given on the corresponding lock.
**
** The xShmLock method can transition between unlocked and SHARED or
** between unlocked and EXCLUSIVE.  It cannot transition between SHARED
** and EXCLUSIVE.
*/

public constant
	SQLITE_SHM_UNLOCK       = 1,
	SQLITE_SHM_LOCK         = 2,
	SQLITE_SHM_SHARED       = 4,
	SQLITE_SHM_EXCLUSIVE    = 8,
$


/*
** CAPI3REF: Maximum xShmLock index
**
** The xShmLock method on [sqlite3_io_methods] may use values
** between 0 and this upper bound as its "offset" argument.
** The SQLite core will never attempt to acquire or release a
** lock outside of this range
*/

public constant SQLITE_SHM_NLOCK = 8


/*
** CAPI3REF: Initialize The SQLite Library
**
** ^The sqlite3_initialize() routine initializes the
** SQLite library.  ^The sqlite3_shutdown() routine
** deallocates any resources that were allocated by sqlite3_initialize().
** These routines are designed to aid in process initialization and
** shutdown on embedded systems.  Workstation applications using
** SQLite normally do not need to invoke either of these routines.
**
** A call to sqlite3_initialize() is an "effective" call if it is
** the first time sqlite3_initialize() is invoked during the lifetime of
** the process, or if it is the first time sqlite3_initialize() is invoked
** following a call to sqlite3_shutdown().  ^(Only an effective call
** of sqlite3_initialize() does any initialization.  All other calls
** are harmless no-ops.)^
**
** A call to sqlite3_shutdown() is an "effective" call if it is the first
** call to sqlite3_shutdown() since the last sqlite3_initialize().  ^(Only
** an effective call to sqlite3_shutdown() does any deinitialization.
** All other valid calls to sqlite3_shutdown() are harmless no-ops.)^
**
** The sqlite3_initialize() interface is threadsafe, but sqlite3_shutdown()
** is not.  The sqlite3_shutdown() interface must only be called from a
** single thread.  All open [database connections] must be closed and all
** other SQLite resources must be deallocated prior to invoking
** sqlite3_shutdown().
**
** Among other things, ^sqlite3_initialize() will invoke
** sqlite3_os_init().  Similarly, ^sqlite3_shutdown()
** will invoke sqlite3_os_end().
**
** ^The sqlite3_initialize() routine returns [SQLITE_OK] on success.
** ^If for some reason, sqlite3_initialize() is unable to initialize
** the library (perhaps it is unable to allocate a needed resource such
** as a mutex) it returns an [error code] other than [SQLITE_OK].
**
** ^The sqlite3_initialize() routine is called internally by many other
** SQLite interfaces so that an application usually does not need to
** invoke sqlite3_initialize() directly.  For example, [sqlite3_open()]
** calls sqlite3_initialize() so the SQLite library will be automatically
** initialized when [sqlite3_open()] is called if it has not be initialized
** already.  ^However, if SQLite is compiled with the [SQLITE_OMIT_AUTOINIT]
** compile-time option, then the automatic calls to sqlite3_initialize()
** are omitted and the application must call sqlite3_initialize() directly
** prior to using any other SQLite interface.  For maximum portability,
** it is recommended that applications always invoke sqlite3_initialize()
** directly prior to using any other SQLite interface.  Future releases
** of SQLite may require this.  In other words, the behavior exhibited
** when SQLite is compiled with [SQLITE_OMIT_AUTOINIT] might become the
** default behavior in some future release of SQLite.
**
** The sqlite3_os_init() routine does operating-system specific
** initialization of the SQLite library.  The sqlite3_os_end()
** routine undoes the effect of sqlite3_os_init().  Typical tasks
** performed by these routines include allocation or deallocation
** of static resources, initialization of global variables,
** setting up a default [sqlite3_vfs] module, or setting up
** a default configuration using [sqlite3_config()].
**
** The application should never invoke either sqlite3_os_init()
** or sqlite3_os_end() directly.  The application should only invoke
** sqlite3_initialize() and sqlite3_shutdown().  The sqlite3_os_init()
** interface is called automatically by sqlite3_initialize() and
** sqlite3_os_end() is called by sqlite3_shutdown().  Appropriate
** implementations for sqlite3_os_init() and sqlite3_os_end()
** are built into SQLite when it is compiled for Unix, Windows, or OS/2.
** When [custom builds | built for other platforms]
** (using the [SQLITE_OS_OTHER=1] compile-time
** option) the application must supply a suitable implementation for
** sqlite3_os_init() and sqlite3_os_end().  An application-supplied
** implementation of sqlite3_os_init() or sqlite3_os_end()
** must return [SQLITE_OK] on success and some other [error code] upon
** failure.
*/

public function sqlite3_initialize()
	return c_func( _sqlite3_initialize, {} )
end function

public function sqlite3_shutdown()
	return c_func( _sqlite3_shutdown, {} )
end function


/*
** CAPI3REF: Configuring The SQLite Library
**
** The sqlite3_config() interface is used to make global configuration
** changes to SQLite in order to tune SQLite to the specific needs of
** the application.  The default configuration is recommended for most
** applications and so this routine is usually not necessary.  It is
** provided to support rare applications with unusual needs.
**
** <b>The sqlite3_config() interface is not threadsafe. The application
** must ensure that no other SQLite interfaces are invoked by other
** threads while sqlite3_config() is running.</b>
**
** The sqlite3_config() interface
** may only be invoked prior to library initialization using
** [sqlite3_initialize()] or after shutdown by [sqlite3_shutdown()].
** ^If sqlite3_config() is called after [sqlite3_initialize()] and before
** [sqlite3_shutdown()] then it will return SQLITE_MISUSE.
** Note, however, that ^sqlite3_config() can be called as part of the
** implementation of an application-defined [sqlite3_os_init()].
**
** The first argument to sqlite3_config() is an integer
** [configuration option] that determines
** what property of SQLite is to be configured.  Subsequent arguments
** vary depending on the [configuration option]
** in the first argument.
**
** ^When a configuration option is set, sqlite3_config() returns [SQLITE_OK].
** ^If the option is unknown or SQLite is unable to set the option
** then this routine returns a non-zero [error code].
*/

public function sqlite3_config( integer op, object params = {} )

	sequence c_types = {C_INT}
	sequence c_params = {op} & params

	switch op with fallthru do

		case SQLITE_CONFIG_SINGLETHREAD then
		case SQLITE_CONFIG_MULTITHREAD then
		case SQLITE_CONFIG_SERIALIZED then
		case SQLITE_CONFIG_PCACHE then
		case SQLITE_CONFIG_GETPCACHE then
		case SQLITE_CONFIG_MUTEX then
		case SQLITE_CONFIG_GETMUTEX then
			/* nil */
			break

		case SQLITE_CONFIG_MEMSTATUS then
		case SQLITE_CONFIG_SMALL_MALLOC then
			/* boolean */
			c_types &= {C_BOOL}
			break

		case SQLITE_CONFIG_URI then
		case SQLITE_CONFIG_COVERING_INDEX_SCAN then
		case SQLITE_CONFIG_WIN32_HEAPSIZE then
		case SQLITE_CONFIG_STMTJRNL_SPILL then
		case SQLITE_CONFIG_SORTERREF_SIZE then
			/* int */
			c_types &= {C_INT}
			break

		case SQLITE_CONFIG_PMASZ then
			/* unsigned int */
			c_types &= {C_UINT}
			break

		case SQLITE_CONFIG_MALLOC then
		case SQLITE_CONFIG_GETMALLOC then
		case SQLITE_CONFIG_PCACHE2 then
		case SQLITE_CONFIG_GETPCACHE2 then
		case SQLITE_CONFIG_PCACHE_HDRSZ then
			/* void* */
			c_types &= {C_POINTER}
			break

		case SQLITE_CONFIG_MEMDB_MAXSIZE then
			/* sqlite3_int64 */
			c_types &= {C_LONGLONG}
			break

		case SQLITE_CONFIG_LOOKASIDE then
			/* int, int */
			c_types &= {C_INT,C_INT}
			break

		case SQLITE_CONFIG_LOG then
		case SQLITE_CONFIG_SQLLOG then
			/* void*, void* */
			c_types &= {C_POINTER,C_POINTER}
			break

		case SQLITE_CONFIG_MMAP_SIZE then
			/* sqlite3_int64, sqlite3_int64 */
			c_types &= {C_LONGLONG,C_LONGLONG}
			break

		case SQLITE_CONFIG_PAGECACHE then
		case SQLITE_CONFIG_HEAP then
			/* void*, int, int */
			c_types &= {C_POINTER,C_INT,C_INT}
			break

	end switch

	if length( c_types ) != length( c_params ) then
		return SQLITE_MISUSE
	end if

	integer func_id = map:get( _sqlite3_config, c_types, INVALID_RID )

	if func_id = INVALID_RID then
		func_id = define_c_func( sqlite3, "sqlite3_config", c_types, {C_INT} )
		map:put( _sqlite3_config, c_types, func_id )
	end if

	return c_func( func_id, c_params )
end function


/*
** CAPI3REF: Configure database connections
** METHOD: sqlite3
**
** The sqlite3_db_config() interface is used to make configuration
** changes to a [database connection].  The interface is similar to
** [sqlite3_config()] except that the changes apply to a single
** [database connection] (specified in the first argument).
**
** The second argument to sqlite3_db_config(D,V,...)  is the
** [SQLITE_DBCONFIG_LOOKASIDE | configuration verb] - an integer code
** that indicates what aspect of the [database connection] is being configured.
** Subsequent arguments vary depending on the configuration verb.
**
** ^Calls to sqlite3_db_config() return SQLITE_OK if and only if
** the call is considered successful.
*/

public function sqlite3_db_config( atom db, integer op, object params = {} )

	sequence c_types = {C_SQLITE3,C_INT}
	sequence c_params = {db,op} & params

	switch op with fallthru do

		case SQLITE_DBCONFIG_MAINDBNAME then
			/* const char* */
			c_types &= {C_STRING}
			c_params[3] = allocate_string( c_params[3], TRUE )
			break

		case SQLITE_DBCONFIG_LOOKASIDE then
			/* void*, int, int */
			c_types &= {C_POINTER,C_INT,C_INT}
			break

		case SQLITE_DBCONFIG_ENABLE_FKEY then
		case SQLITE_DBCONFIG_ENABLE_TRIGGER then
		case SQLITE_DBCONFIG_ENABLE_FTS3_TOKENIZER then
		case SQLITE_DBCONFIG_ENABLE_LOAD_EXTENSION then
		case SQLITE_DBCONFIG_NO_CKPT_ON_CLOSE then
		case SQLITE_DBCONFIG_ENABLE_QPSG then
		case SQLITE_DBCONFIG_TRIGGER_EQP then
		case SQLITE_DBCONFIG_RESET_DATABASE then
		case SQLITE_DBCONFIG_DEFENSIVE then
		case SQLITE_DBCONFIG_WRITABLE_SCHEMA then
		case SQLITE_DBCONFIG_LEGACY_ALTER_TABLE then
		case SQLITE_DBCONFIG_DQS_DML then
		case SQLITE_DBCONFIG_DQS_DDL then
			/* int, int */
			c_types &= {C_INT,C_INT}
			break

	end switch

	if length( c_types ) != length( c_params ) then
		return SQLITE_MISUSE
	end if

	integer func_id = map:get( _sqlite3_db_config, c_types, INVALID_RID )

	if func_id = INVALID_RID then
		func_id = define_c_func( sqlite3, "sqlite3_db_config", c_types, {C_INT} )
		map:put( _sqlite3_db_config, c_types, func_id )
	end if

	return c_func( func_id, c_params )
end function


/*
** CAPI3REF: Configuration Options
** KEYWORDS: {configuration option}
**
** These constants are the available integer configuration options that
** can be passed as the first argument to the [sqlite3_config()] interface.
**
** New configuration options may be added in future releases of SQLite.
** Existing configuration options might be discontinued.  Applications
** should check the return code from [sqlite3_config()] to make sure that
** the call worked.  The [sqlite3_config()] interface will return a
** non-zero [error code] if a discontinued or unsupported configuration option
** is invoked.
**
** <dl>
** [[SQLITE_CONFIG_SINGLETHREAD]] <dt>SQLITE_CONFIG_SINGLETHREAD</dt>
** <dd>There are no arguments to this option.  ^This option sets the
** [threading mode] to Single-thread.  In other words, it disables
** all mutexing and puts SQLite into a mode where it can only be used
** by a single thread.   ^If SQLite is compiled with
** the [SQLITE_THREADSAFE | SQLITE_THREADSAFE=0] compile-time option then
** it is not possible to change the [threading mode] from its default
** value of Single-thread and so [sqlite3_config()] will return
** [SQLITE_ERROR] if called with the SQLITE_CONFIG_SINGLETHREAD
** configuration option.</dd>
**
** [[SQLITE_CONFIG_MULTITHREAD]] <dt>SQLITE_CONFIG_MULTITHREAD</dt>
** <dd>There are no arguments to this option.  ^This option sets the
** [threading mode] to Multi-thread.  In other words, it disables
** mutexing on [database connection] and [prepared statement] objects.
** The application is responsible for serializing access to
** [database connections] and [prepared statements].  But other mutexes
** are enabled so that SQLite will be safe to use in a multi-threaded
** environment as long as no two threads attempt to use the same
** [database connection] at the same time.  ^If SQLite is compiled with
** the [SQLITE_THREADSAFE | SQLITE_THREADSAFE=0] compile-time option then
** it is not possible to set the Multi-thread [threading mode] and
** [sqlite3_config()] will return [SQLITE_ERROR] if called with the
** SQLITE_CONFIG_MULTITHREAD configuration option.</dd>
**
** [[SQLITE_CONFIG_SERIALIZED]] <dt>SQLITE_CONFIG_SERIALIZED</dt>
** <dd>There are no arguments to this option.  ^This option sets the
** [threading mode] to Serialized. In other words, this option enables
** all mutexes including the recursive
** mutexes on [database connection] and [prepared statement] objects.
** In this mode (which is the default when SQLite is compiled with
** [SQLITE_THREADSAFE=1]) the SQLite library will itself serialize access
** to [database connections] and [prepared statements] so that the
** application is free to use the same [database connection] or the
** same [prepared statement] in different threads at the same time.
** ^If SQLite is compiled with
** the [SQLITE_THREADSAFE | SQLITE_THREADSAFE=0] compile-time option then
** it is not possible to set the Serialized [threading mode] and
** [sqlite3_config()] will return [SQLITE_ERROR] if called with the
** SQLITE_CONFIG_SERIALIZED configuration option.</dd>
**
** [[SQLITE_CONFIG_MALLOC]] <dt>SQLITE_CONFIG_MALLOC</dt>
** <dd> ^(The SQLITE_CONFIG_MALLOC option takes a single argument which is
** a pointer to an instance of the [sqlite3_mem_methods] structure.
** The argument specifies
** alternative low-level memory allocation routines to be used in place of
** the memory allocation routines built into SQLite.)^ ^SQLite makes
** its own private copy of the content of the [sqlite3_mem_methods] structure
** before the [sqlite3_config()] call returns.</dd>
**
** [[SQLITE_CONFIG_GETMALLOC]] <dt>SQLITE_CONFIG_GETMALLOC</dt>
** <dd> ^(The SQLITE_CONFIG_GETMALLOC option takes a single argument which
** is a pointer to an instance of the [sqlite3_mem_methods] structure.
** The [sqlite3_mem_methods]
** structure is filled with the currently defined memory allocation routines.)^
** This option can be used to overload the default memory allocation
** routines with a wrapper that simulations memory allocation failure or
** tracks memory usage, for example. </dd>
**
** [[SQLITE_CONFIG_SMALL_MALLOC]] <dt>SQLITE_CONFIG_SMALL_MALLOC</dt>
** <dd> ^The SQLITE_CONFIG_SMALL_MALLOC option takes single argument of
** type int, interpreted as a boolean, which if true provides a hint to
** SQLite that it should avoid large memory allocations if possible.
** SQLite will run faster if it is free to make large memory allocations,
** but some application might prefer to run slower in exchange for
** guarantees about memory fragmentation that are possible if large
** allocations are avoided.  This hint is normally off.
** </dd>
**
** [[SQLITE_CONFIG_MEMSTATUS]] <dt>SQLITE_CONFIG_MEMSTATUS</dt>
** <dd> ^The SQLITE_CONFIG_MEMSTATUS option takes single argument of type int,
** interpreted as a boolean, which enables or disables the collection of
** memory allocation statistics. ^(When memory allocation statistics are
** disabled, the following SQLite interfaces become non-operational:
**   <ul>
**   <li> [sqlite3_hard_heap_limit64()]
**   <li> [sqlite3_memory_used()]
**   <li> [sqlite3_memory_highwater()]
**   <li> [sqlite3_soft_heap_limit64()]
**   <li> [sqlite3_status64()]
**   </ul>)^
** ^Memory allocation statistics are enabled by default unless SQLite is
** compiled with [SQLITE_DEFAULT_MEMSTATUS]=0 in which case memory
** allocation statistics are disabled by default.
** </dd>
**
** [[SQLITE_CONFIG_SCRATCH]] <dt>SQLITE_CONFIG_SCRATCH</dt>
** <dd> The SQLITE_CONFIG_SCRATCH option is no longer used.
** </dd>
**
** [[SQLITE_CONFIG_PAGECACHE]] <dt>SQLITE_CONFIG_PAGECACHE</dt>
** <dd> ^The SQLITE_CONFIG_PAGECACHE option specifies a memory pool
** that SQLite can use for the database page cache with the default page
** cache implementation.
** This configuration option is a no-op if an application-defined page
** cache implementation is loaded using the [SQLITE_CONFIG_PCACHE2].
** ^There are three arguments to SQLITE_CONFIG_PAGECACHE: A pointer to
** 8-byte aligned memory (pMem), the size of each page cache line (sz),
** and the number of cache lines (N).
** The sz argument should be the size of the largest database page
** (a power of two between 512 and 65536) plus some extra bytes for each
** page header.  ^The number of extra bytes needed by the page header
** can be determined using [SQLITE_CONFIG_PCACHE_HDRSZ].
** ^It is harmless, apart from the wasted memory,
** for the sz parameter to be larger than necessary.  The pMem
** argument must be either a NULL pointer or a pointer to an 8-byte
** aligned block of memory of at least sz*N bytes, otherwise
** subsequent behavior is undefined.
** ^When pMem is not NULL, SQLite will strive to use the memory provided
** to satisfy page cache needs, falling back to [sqlite3_malloc()] if
** a page cache line is larger than sz bytes or if all of the pMem buffer
** is exhausted.
** ^If pMem is NULL and N is non-zero, then each database connection
** does an initial bulk allocation for page cache memory
** from [sqlite3_malloc()] sufficient for N cache lines if N is positive or
** of -1024*N bytes if N is negative, . ^If additional
** page cache memory is needed beyond what is provided by the initial
** allocation, then SQLite goes to [sqlite3_malloc()] separately for each
** additional cache line. </dd>
**
** [[SQLITE_CONFIG_HEAP]] <dt>SQLITE_CONFIG_HEAP</dt>
** <dd> ^The SQLITE_CONFIG_HEAP option specifies a static memory buffer
** that SQLite will use for all of its dynamic memory allocation needs
** beyond those provided for by [SQLITE_CONFIG_PAGECACHE].
** ^The SQLITE_CONFIG_HEAP option is only available if SQLite is compiled
** with either [SQLITE_ENABLE_MEMSYS3] or [SQLITE_ENABLE_MEMSYS5] and returns
** [SQLITE_ERROR] if invoked otherwise.
** ^There are three arguments to SQLITE_CONFIG_HEAP:
** An 8-byte aligned pointer to the memory,
** the number of bytes in the memory buffer, and the minimum allocation size.
** ^If the first pointer (the memory pointer) is NULL, then SQLite reverts
** to using its default memory allocator (the system malloc() implementation),
** undoing any prior invocation of [SQLITE_CONFIG_MALLOC].  ^If the
** memory pointer is not NULL then the alternative memory
** allocator is engaged to handle all of SQLites memory allocation needs.
** The first pointer (the memory pointer) must be aligned to an 8-byte
** boundary or subsequent behavior of SQLite will be undefined.
** The minimum allocation size is capped at 2**12. Reasonable values
** for the minimum allocation size are 2**5 through 2**8.</dd>
**
** [[SQLITE_CONFIG_MUTEX]] <dt>SQLITE_CONFIG_MUTEX</dt>
** <dd> ^(The SQLITE_CONFIG_MUTEX option takes a single argument which is a
** pointer to an instance of the [sqlite3_mutex_methods] structure.
** The argument specifies alternative low-level mutex routines to be used
** in place the mutex routines built into SQLite.)^  ^SQLite makes a copy of
** the content of the [sqlite3_mutex_methods] structure before the call to
** [sqlite3_config()] returns. ^If SQLite is compiled with
** the [SQLITE_THREADSAFE | SQLITE_THREADSAFE=0] compile-time option then
** the entire mutexing subsystem is omitted from the build and hence calls to
** [sqlite3_config()] with the SQLITE_CONFIG_MUTEX configuration option will
** return [SQLITE_ERROR].</dd>
**
** [[SQLITE_CONFIG_GETMUTEX]] <dt>SQLITE_CONFIG_GETMUTEX</dt>
** <dd> ^(The SQLITE_CONFIG_GETMUTEX option takes a single argument which
** is a pointer to an instance of the [sqlite3_mutex_methods] structure.  The
** [sqlite3_mutex_methods]
** structure is filled with the currently defined mutex routines.)^
** This option can be used to overload the default mutex allocation
** routines with a wrapper used to track mutex usage for performance
** profiling or testing, for example.   ^If SQLite is compiled with
** the [SQLITE_THREADSAFE | SQLITE_THREADSAFE=0] compile-time option then
** the entire mutexing subsystem is omitted from the build and hence calls to
** [sqlite3_config()] with the SQLITE_CONFIG_GETMUTEX configuration option will
** return [SQLITE_ERROR].</dd>
**
** [[SQLITE_CONFIG_LOOKASIDE]] <dt>SQLITE_CONFIG_LOOKASIDE</dt>
** <dd> ^(The SQLITE_CONFIG_LOOKASIDE option takes two arguments that determine
** the default size of lookaside memory on each [database connection].
** The first argument is the
** size of each lookaside buffer slot and the second is the number of
** slots allocated to each database connection.)^  ^(SQLITE_CONFIG_LOOKASIDE
** sets the <i>default</i> lookaside size. The [SQLITE_DBCONFIG_LOOKASIDE]
** option to [sqlite3_db_config()] can be used to change the lookaside
** configuration on individual connections.)^ </dd>
**
** [[SQLITE_CONFIG_PCACHE2]] <dt>SQLITE_CONFIG_PCACHE2</dt>
** <dd> ^(The SQLITE_CONFIG_PCACHE2 option takes a single argument which is
** a pointer to an [sqlite3_pcache_methods2] object.  This object specifies
** the interface to a custom page cache implementation.)^
** ^SQLite makes a copy of the [sqlite3_pcache_methods2] object.</dd>
**
** [[SQLITE_CONFIG_GETPCACHE2]] <dt>SQLITE_CONFIG_GETPCACHE2</dt>
** <dd> ^(The SQLITE_CONFIG_GETPCACHE2 option takes a single argument which
** is a pointer to an [sqlite3_pcache_methods2] object.  SQLite copies of
** the current page cache implementation into that object.)^ </dd>
**
** [[SQLITE_CONFIG_LOG]] <dt>SQLITE_CONFIG_LOG</dt>
** <dd> The SQLITE_CONFIG_LOG option is used to configure the SQLite
** global [error log].
** (^The SQLITE_CONFIG_LOG option takes two arguments: a pointer to a
** function with a call signature of void(*)(void*,int,const char*),
** and a pointer to void. ^If the function pointer is not NULL, it is
** invoked by [sqlite3_log()] to process each logging event.  ^If the
** function pointer is NULL, the [sqlite3_log()] interface becomes a no-op.
** ^The void pointer that is the second argument to SQLITE_CONFIG_LOG is
** passed through as the first parameter to the application-defined logger
** function whenever that function is invoked.  ^The second parameter to
** the logger function is a copy of the first parameter to the corresponding
** [sqlite3_log()] call and is intended to be a [result code] or an
** [extended result code].  ^The third parameter passed to the logger is
** log message after formatting via [sqlite3_snprintf()].
** The SQLite logging interface is not reentrant; the logger function
** supplied by the application must not invoke any SQLite interface.
** In a multi-threaded application, the application-defined logger
** function must be threadsafe. </dd>
**
** [[SQLITE_CONFIG_URI]] <dt>SQLITE_CONFIG_URI
** <dd>^(The SQLITE_CONFIG_URI option takes a single argument of type int.
** If non-zero, then URI handling is globally enabled. If the parameter is zero,
** then URI handling is globally disabled.)^ ^If URI handling is globally
** enabled, all filenames passed to [sqlite3_open()], [sqlite3_open_v2()],
** [sqlite3_open16()] or
** specified as part of [ATTACH] commands are interpreted as URIs, regardless
** of whether or not the [SQLITE_OPEN_URI] flag is set when the database
** connection is opened. ^If it is globally disabled, filenames are
** only interpreted as URIs if the SQLITE_OPEN_URI flag is set when the
** database connection is opened. ^(By default, URI handling is globally
** disabled. The default value may be changed by compiling with the
** [SQLITE_USE_URI] symbol defined.)^
**
** [[SQLITE_CONFIG_COVERING_INDEX_SCAN]] <dt>SQLITE_CONFIG_COVERING_INDEX_SCAN
** <dd>^The SQLITE_CONFIG_COVERING_INDEX_SCAN option takes a single integer
** argument which is interpreted as a boolean in order to enable or disable
** the use of covering indices for full table scans in the query optimizer.
** ^The default setting is determined
** by the [SQLITE_ALLOW_COVERING_INDEX_SCAN] compile-time option, or is "on"
** if that compile-time option is omitted.
** The ability to disable the use of covering indices for full table scans
** is because some incorrectly coded legacy applications might malfunction
** when the optimization is enabled.  Providing the ability to
** disable the optimization allows the older, buggy application code to work
** without change even with newer versions of SQLite.
**
** [[SQLITE_CONFIG_PCACHE]] [[SQLITE_CONFIG_GETPCACHE]]
** <dt>SQLITE_CONFIG_PCACHE and SQLITE_CONFIG_GETPCACHE
** <dd> These options are obsolete and should not be used by new code.
** They are retained for backwards compatibility but are now no-ops.
** </dd>
**
** [[SQLITE_CONFIG_SQLLOG]]
** <dt>SQLITE_CONFIG_SQLLOG
** <dd>This option is only available if sqlite is compiled with the
** [SQLITE_ENABLE_SQLLOG] pre-processor macro defined. The first argument should
** be a pointer to a function of type void(*)(void*,sqlite3*,const char*, int).
** The second should be of type (void*). The callback is invoked by the library
** in three separate circumstances, identified by the value passed as the
** fourth parameter. If the fourth parameter is 0, then the database connection
** passed as the second argument has just been opened. The third argument
** points to a buffer containing the name of the main database file. If the
** fourth parameter is 1, then the SQL statement that the third parameter
** points to has just been executed. Or, if the fourth parameter is 2, then
** the connection being passed as the second parameter is being closed. The
** third parameter is passed NULL In this case.  An example of using this
** configuration option can be seen in the "test_sqllog.c" source file in
** the canonical SQLite source tree.</dd>
**
** [[SQLITE_CONFIG_MMAP_SIZE]]
** <dt>SQLITE_CONFIG_MMAP_SIZE
** <dd>^SQLITE_CONFIG_MMAP_SIZE takes two 64-bit integer (sqlite3_int64) values
** that are the default mmap size limit (the default setting for
** [PRAGMA mmap_size]) and the maximum allowed mmap size limit.
** ^The default setting can be overridden by each database connection using
** either the [PRAGMA mmap_size] command, or by using the
** [SQLITE_FCNTL_MMAP_SIZE] file control.  ^(The maximum allowed mmap size
** will be silently truncated if necessary so that it does not exceed the
** compile-time maximum mmap size set by the
** [SQLITE_MAX_MMAP_SIZE] compile-time option.)^
** ^If either argument to this option is negative, then that argument is
** changed to its compile-time default.
**
** [[SQLITE_CONFIG_WIN32_HEAPSIZE]]
** <dt>SQLITE_CONFIG_WIN32_HEAPSIZE
** <dd>^The SQLITE_CONFIG_WIN32_HEAPSIZE option is only available if SQLite is
** compiled for Windows with the [SQLITE_WIN32_MALLOC] pre-processor macro
** defined. ^SQLITE_CONFIG_WIN32_HEAPSIZE takes a 32-bit unsigned integer value
** that specifies the maximum size of the created heap.
**
** [[SQLITE_CONFIG_PCACHE_HDRSZ]]
** <dt>SQLITE_CONFIG_PCACHE_HDRSZ
** <dd>^The SQLITE_CONFIG_PCACHE_HDRSZ option takes a single parameter which
** is a pointer to an integer and writes into that integer the number of extra
** bytes per page required for each page in [SQLITE_CONFIG_PAGECACHE].
** The amount of extra space required can change depending on the compiler,
** target platform, and SQLite version.
**
** [[SQLITE_CONFIG_PMASZ]]
** <dt>SQLITE_CONFIG_PMASZ
** <dd>^The SQLITE_CONFIG_PMASZ option takes a single parameter which
** is an unsigned integer and sets the "Minimum PMA Size" for the multithreaded
** sorter to that integer.  The default minimum PMA Size is set by the
** [SQLITE_SORTER_PMASZ] compile-time option.  New threads are launched
** to help with sort operations when multithreaded sorting
** is enabled (using the [PRAGMA threads] command) and the amount of content
** to be sorted exceeds the page size times the minimum of the
** [PRAGMA cache_size] setting and this value.
**
** [[SQLITE_CONFIG_STMTJRNL_SPILL]]
** <dt>SQLITE_CONFIG_STMTJRNL_SPILL
** <dd>^The SQLITE_CONFIG_STMTJRNL_SPILL option takes a single parameter which
** becomes the [statement journal] spill-to-disk threshold.
** [Statement journals] are held in memory until their size (in bytes)
** exceeds this threshold, at which point they are written to disk.
** Or if the threshold is -1, statement journals are always held
** exclusively in memory.
** Since many statement journals never become large, setting the spill
** threshold to a value such as 64KiB can greatly reduce the amount of
** I/O required to support statement rollback.
** The default value for this setting is controlled by the
** [SQLITE_STMTJRNL_SPILL] compile-time option.
**
** [[SQLITE_CONFIG_SORTERREF_SIZE]]
** <dt>SQLITE_CONFIG_SORTERREF_SIZE
** <dd>The SQLITE_CONFIG_SORTERREF_SIZE option accepts a single parameter
** of type (int) - the new value of the sorter-reference size threshold.
** Usually, when SQLite uses an external sort to order records according
** to an ORDER BY clause, all fields required by the caller are present in the
** sorted records. However, if SQLite determines based on the declared type
** of a table column that its values are likely to be very large - larger
** than the configured sorter-reference size threshold - then a reference
** is stored in each sorted record and the required column values loaded
** from the database as records are returned in sorted order. The default
** value for this option is to never use this optimization. Specifying a
** negative value for this option restores the default behaviour.
** This option is only available if SQLite is compiled with the
** [SQLITE_ENABLE_SORTER_REFERENCES] compile-time option.
**
** [[SQLITE_CONFIG_MEMDB_MAXSIZE]]
** <dt>SQLITE_CONFIG_MEMDB_MAXSIZE
** <dd>The SQLITE_CONFIG_MEMDB_MAXSIZE option accepts a single parameter
** [sqlite3_int64] parameter which is the default maximum size for an in-memory
** database created using [sqlite3_deserialize()].  This default maximum
** size can be adjusted up or down for individual databases using the
** [SQLITE_FCNTL_SIZE_LIMIT] [sqlite3_file_control|file-control].  If this
** configuration setting is never used, then the default maximum is determined
** by the [SQLITE_MEMDB_DEFAULT_MAXSIZE] compile-time option.  If that
** compile-time option is not set, then the default maximum is 1073741824.
** </dl>
*/

public constant
	SQLITE_CONFIG_SINGLETHREAD          =  1, /* nil */
	SQLITE_CONFIG_MULTITHREAD           =  2, /* nil */
	SQLITE_CONFIG_SERIALIZED            =  3, /* nil */
	SQLITE_CONFIG_MALLOC                =  4, /* sqlite3_mem_methods* */
	SQLITE_CONFIG_GETMALLOC             =  5, /* sqlite3_mem_methods* */
	SQLITE_CONFIG_SCRATCH               =  6, /* No longer used */
	SQLITE_CONFIG_PAGECACHE             =  7, /* void*, int sz, int N */
	SQLITE_CONFIG_HEAP                  =  8, /* void*, int nByte, int min */
	SQLITE_CONFIG_MEMSTATUS             =  9, /* boolean */
	SQLITE_CONFIG_MUTEX                 = 10, /* sqlite3_mutex_methods* */
	SQLITE_CONFIG_GETMUTEX              = 11, /* sqlite3_mutex_methods* */
	/* previously SQLITE_CONFIG_CHUNKALLOC 12 which is now unused. */
	SQLITE_CONFIG_LOOKASIDE             = 13, /* int int */
	SQLITE_CONFIG_PCACHE                = 14, /* no-op */
	SQLITE_CONFIG_GETPCACHE             = 15, /* no-op */
	SQLITE_CONFIG_LOG                   = 16, /* xFunc, void* */
	SQLITE_CONFIG_URI                   = 17, /* int */
	SQLITE_CONFIG_PCACHE2               = 18, /* sqlite3_pcache_methods2* */
	SQLITE_CONFIG_GETPCACHE2            = 19, /* sqlite3_pcache_methods2* */
	SQLITE_CONFIG_COVERING_INDEX_SCAN   = 20, /* int */
	SQLITE_CONFIG_SQLLOG                = 21, /* xSqllog, void* */
	SQLITE_CONFIG_MMAP_SIZE             = 22, /* sqlite3_int64, sqlite3_int64 */
	SQLITE_CONFIG_WIN32_HEAPSIZE        = 23, /* int nByte */
	SQLITE_CONFIG_PCACHE_HDRSZ          = 24, /* int *psz */
	SQLITE_CONFIG_PMASZ                 = 25, /* unsigned int szPma */
	SQLITE_CONFIG_STMTJRNL_SPILL        = 26, /* int nByte */
	SQLITE_CONFIG_SMALL_MALLOC          = 27, /* boolean */
	SQLITE_CONFIG_SORTERREF_SIZE        = 28, /* int nByte */
	SQLITE_CONFIG_MEMDB_MAXSIZE         = 29, /* sqlite3_int64 */
$


/*
** CAPI3REF: Database Connection Configuration Options
**
** These constants are the available integer configuration options that
** can be passed as the second argument to the [sqlite3_db_config()] interface.
**
** New configuration options may be added in future releases of SQLite.
** Existing configuration options might be discontinued.  Applications
** should check the return code from [sqlite3_db_config()] to make sure that
** the call worked.  ^The [sqlite3_db_config()] interface will return a
** non-zero [error code] if a discontinued or unsupported configuration option
** is invoked.
**
** <dl>
** [[SQLITE_DBCONFIG_LOOKASIDE]]
** <dt>SQLITE_DBCONFIG_LOOKASIDE</dt>
** <dd> ^This option takes three additional arguments that determine the
** [lookaside memory allocator] configuration for the [database connection].
** ^The first argument (the third parameter to [sqlite3_db_config()] is a
** pointer to a memory buffer to use for lookaside memory.
** ^The first argument after the SQLITE_DBCONFIG_LOOKASIDE verb
** may be NULL in which case SQLite will allocate the
** lookaside buffer itself using [sqlite3_malloc()]. ^The second argument is the
** size of each lookaside buffer slot.  ^The third argument is the number of
** slots.  The size of the buffer in the first argument must be greater than
** or equal to the product of the second and third arguments.  The buffer
** must be aligned to an 8-byte boundary.  ^If the second argument to
** SQLITE_DBCONFIG_LOOKASIDE is not a multiple of 8, it is internally
** rounded down to the next smaller multiple of 8.  ^(The lookaside memory
** configuration for a database connection can only be changed when that
** connection is not currently using lookaside memory, or in other words
** when the "current value" returned by
** [sqlite3_db_status](D,[SQLITE_CONFIG_LOOKASIDE],...) is zero.
** Any attempt to change the lookaside memory configuration when lookaside
** memory is in use leaves the configuration unchanged and returns
** [SQLITE_BUSY].)^</dd>
**
** [[SQLITE_DBCONFIG_ENABLE_FKEY]]
** <dt>SQLITE_DBCONFIG_ENABLE_FKEY</dt>
** <dd> ^This option is used to enable or disable the enforcement of
** [foreign key constraints].  There should be two additional arguments.
** The first argument is an integer which is 0 to disable FK enforcement,
** positive to enable FK enforcement or negative to leave FK enforcement
** unchanged.  The second parameter is a pointer to an integer into which
** is written 0 or 1 to indicate whether FK enforcement is off or on
** following this call.  The second parameter may be a NULL pointer, in
** which case the FK enforcement setting is not reported back. </dd>
**
** [[SQLITE_DBCONFIG_ENABLE_TRIGGER]]
** <dt>SQLITE_DBCONFIG_ENABLE_TRIGGER</dt>
** <dd> ^This option is used to enable or disable [CREATE TRIGGER | triggers].
** There should be two additional arguments.
** The first argument is an integer which is 0 to disable triggers,
** positive to enable triggers or negative to leave the setting unchanged.
** The second parameter is a pointer to an integer into which
** is written 0 or 1 to indicate whether triggers are disabled or enabled
** following this call.  The second parameter may be a NULL pointer, in
** which case the trigger setting is not reported back. </dd>
**
** [[SQLITE_DBCONFIG_ENABLE_VIEW]]
** <dt>SQLITE_DBCONFIG_ENABLE_VIEW</dt>
** <dd> ^This option is used to enable or disable [CREATE VIEW | views].
** There should be two additional arguments.
** The first argument is an integer which is 0 to disable views,
** positive to enable views or negative to leave the setting unchanged.
** The second parameter is a pointer to an integer into which
** is written 0 or 1 to indicate whether views are disabled or enabled
** following this call.  The second parameter may be a NULL pointer, in
** which case the view setting is not reported back. </dd>
**
** [[SQLITE_DBCONFIG_ENABLE_FTS3_TOKENIZER]]
** <dt>SQLITE_DBCONFIG_ENABLE_FTS3_TOKENIZER</dt>
** <dd> ^This option is used to enable or disable the
** [fts3_tokenizer()] function which is part of the
** [FTS3] full-text search engine extension.
** There should be two additional arguments.
** The first argument is an integer which is 0 to disable fts3_tokenizer() or
** positive to enable fts3_tokenizer() or negative to leave the setting
** unchanged.
** The second parameter is a pointer to an integer into which
** is written 0 or 1 to indicate whether fts3_tokenizer is disabled or enabled
** following this call.  The second parameter may be a NULL pointer, in
** which case the new setting is not reported back. </dd>
**
** [[SQLITE_DBCONFIG_ENABLE_LOAD_EXTENSION]]
** <dt>SQLITE_DBCONFIG_ENABLE_LOAD_EXTENSION</dt>
** <dd> ^This option is used to enable or disable the [sqlite3_load_extension()]
** interface independently of the [load_extension()] SQL function.
** The [sqlite3_enable_load_extension()] API enables or disables both the
** C-API [sqlite3_load_extension()] and the SQL function [load_extension()].
** There should be two additional arguments.
** When the first argument to this interface is 1, then only the C-API is
** enabled and the SQL function remains disabled.  If the first argument to
** this interface is 0, then both the C-API and the SQL function are disabled.
** If the first argument is -1, then no changes are made to state of either the
** C-API or the SQL function.
** The second parameter is a pointer to an integer into which
** is written 0 or 1 to indicate whether [sqlite3_load_extension()] interface
** is disabled or enabled following this call.  The second parameter may
** be a NULL pointer, in which case the new setting is not reported back.
** </dd>
**
** [[SQLITE_DBCONFIG_MAINDBNAME]] <dt>SQLITE_DBCONFIG_MAINDBNAME</dt>
** <dd> ^This option is used to change the name of the "main" database
** schema.  ^The sole argument is a pointer to a constant UTF8 string
** which will become the new schema name in place of "main".  ^SQLite
** does not make a copy of the new main schema name string, so the application
** must ensure that the argument passed into this DBCONFIG option is unchanged
** until after the database connection closes.
** </dd>
**
** [[SQLITE_DBCONFIG_NO_CKPT_ON_CLOSE]]
** <dt>SQLITE_DBCONFIG_NO_CKPT_ON_CLOSE</dt>
** <dd> Usually, when a database in wal mode is closed or detached from a
** database handle, SQLite checks if this will mean that there are now no
** connections at all to the database. If so, it performs a checkpoint
** operation before closing the connection. This option may be used to
** override this behaviour. The first parameter passed to this operation
** is an integer - positive to disable checkpoints-on-close, or zero (the
** default) to enable them, and negative to leave the setting unchanged.
** The second parameter is a pointer to an integer
** into which is written 0 or 1 to indicate whether checkpoints-on-close
** have been disabled - 0 if they are not disabled, 1 if they are.
** </dd>
**
** [[SQLITE_DBCONFIG_ENABLE_QPSG]] <dt>SQLITE_DBCONFIG_ENABLE_QPSG</dt>
** <dd>^(The SQLITE_DBCONFIG_ENABLE_QPSG option activates or deactivates
** the [query planner stability guarantee] (QPSG).  When the QPSG is active,
** a single SQL query statement will always use the same algorithm regardless
** of values of [bound parameters].)^ The QPSG disables some query optimizations
** that look at the values of bound parameters, which can make some queries
** slower.  But the QPSG has the advantage of more predictable behavior.  With
** the QPSG active, SQLite will always use the same query plan in the field as
** was used during testing in the lab.
** The first argument to this setting is an integer which is 0 to disable
** the QPSG, positive to enable QPSG, or negative to leave the setting
** unchanged. The second parameter is a pointer to an integer into which
** is written 0 or 1 to indicate whether the QPSG is disabled or enabled
** following this call.
** </dd>
**
** [[SQLITE_DBCONFIG_TRIGGER_EQP]] <dt>SQLITE_DBCONFIG_TRIGGER_EQP</dt>
** <dd> By default, the output of EXPLAIN QUERY PLAN commands does not
** include output for any operations performed by trigger programs. This
** option is used to set or clear (the default) a flag that governs this
** behavior. The first parameter passed to this operation is an integer -
** positive to enable output for trigger programs, or zero to disable it,
** or negative to leave the setting unchanged.
** The second parameter is a pointer to an integer into which is written
** 0 or 1 to indicate whether output-for-triggers has been disabled - 0 if
** it is not disabled, 1 if it is.
** </dd>
**
** [[SQLITE_DBCONFIG_RESET_DATABASE]] <dt>SQLITE_DBCONFIG_RESET_DATABASE</dt>
** <dd> Set the SQLITE_DBCONFIG_RESET_DATABASE flag and then run
** [VACUUM] in order to reset a database back to an empty database
** with no schema and no content. The following process works even for
** a badly corrupted database file:
** <ol>
** <li> If the database connection is newly opened, make sure it has read the
**      database schema by preparing then discarding some query against the
**      database, or calling sqlite3_table_column_metadata(), ignoring any
**      errors.  This step is only necessary if the application desires to keep
**      the database in WAL mode after the reset if it was in WAL mode before
**      the reset.
** <li> sqlite3_db_config(db, SQLITE_DBCONFIG_RESET_DATABASE, 1, 0);
** <li> [sqlite3_exec](db, "[VACUUM]", 0, 0, 0);
** <li> sqlite3_db_config(db, SQLITE_DBCONFIG_RESET_DATABASE, 0, 0);
** </ol>
** Because resetting a database is destructive and irreversible, the
** process requires the use of this obscure API and multiple steps to help
** ensure that it does not happen by accident.
**
** [[SQLITE_DBCONFIG_DEFENSIVE]] <dt>SQLITE_DBCONFIG_DEFENSIVE</dt>
** <dd>The SQLITE_DBCONFIG_DEFENSIVE option activates or deactivates the
** "defensive" flag for a database connection.  When the defensive
** flag is enabled, language features that allow ordinary SQL to
** deliberately corrupt the database file are disabled.  The disabled
** features include but are not limited to the following:
** <ul>
** <li> The [PRAGMA writable_schema=ON] statement.
** <li> The [PRAGMA journal_mode=OFF] statement.
** <li> Writes to the [sqlite_dbpage] virtual table.
** <li> Direct writes to [shadow tables].
** </ul>
** </dd>
**
** [[SQLITE_DBCONFIG_WRITABLE_SCHEMA]] <dt>SQLITE_DBCONFIG_WRITABLE_SCHEMA</dt>
** <dd>The SQLITE_DBCONFIG_WRITABLE_SCHEMA option activates or deactivates the
** "writable_schema" flag. This has the same effect and is logically equivalent
** to setting [PRAGMA writable_schema=ON] or [PRAGMA writable_schema=OFF].
** The first argument to this setting is an integer which is 0 to disable
** the writable_schema, positive to enable writable_schema, or negative to
** leave the setting unchanged. The second parameter is a pointer to an
** integer into which is written 0 or 1 to indicate whether the writable_schema
** is enabled or disabled following this call.
** </dd>
**
** [[SQLITE_DBCONFIG_LEGACY_ALTER_TABLE]]
** <dt>SQLITE_DBCONFIG_LEGACY_ALTER_TABLE</dt>
** <dd>The SQLITE_DBCONFIG_LEGACY_ALTER_TABLE option activates or deactivates
** the legacy behavior of the [ALTER TABLE RENAME] command such it
** behaves as it did prior to [version 3.24.0] (2018-06-04).  See the
** "Compatibility Notice" on the [ALTER TABLE RENAME documentation] for
** additional information. This feature can also be turned on and off
** using the [PRAGMA legacy_alter_table] statement.
** </dd>
**
** [[SQLITE_DBCONFIG_DQS_DML]]
** <dt>SQLITE_DBCONFIG_DQS_DML</td>
** <dd>The SQLITE_DBCONFIG_DQS_DML option activates or deactivates
** the legacy [double-quoted string literal] misfeature for DML statements
** only, that is DELETE, INSERT, SELECT, and UPDATE statements. The
** default value of this setting is determined by the [-DSQLITE_DQS]
** compile-time option.
** </dd>
**
** [[SQLITE_DBCONFIG_DQS_DDL]]
** <dt>SQLITE_DBCONFIG_DQS_DDL</td>
** <dd>The SQLITE_DBCONFIG_DQS option activates or deactivates
** the legacy [double-quoted string literal] misfeature for DDL statements,
** such as CREATE TABLE and CREATE INDEX. The
** default value of this setting is determined by the [-DSQLITE_DQS]
** compile-time option.
** </dd>
**
** [[SQLITE_DBCONFIG_TRUSTED_SCHEMA]]
** <dt>SQLITE_DBCONFIG_TRUSTED_SCHEMA</td>
** <dd>The SQLITE_DBCONFIG_TRUSTED_SCHEMA option tells SQLite to
** assume that database schemas are untainted by malicious content.
** When the SQLITE_DBCONFIG_TRUSTED_SCHEMA option is disabled, SQLite
** takes additional defensive steps to protect the application from harm
** including:
** <ul>
** <li> Prohibit the use of SQL functions inside triggers, views,
** CHECK constraints, DEFAULT clauses, expression indexes,
** partial indexes, or generated columns
** unless those functions are tagged with [SQLITE_INNOCUOUS].
** <li> Prohibit the use of virtual tables inside of triggers or views
** unless those virtual tables are tagged with [SQLITE_VTAB_INNOCUOUS].
** </ul>
** This setting defaults to "on" for legacy compatibility, however
** all applications are advised to turn it off if possible. This setting
** can also be controlled using the [PRAGMA trusted_schema] statement.
** </dd>
**
** [[SQLITE_DBCONFIG_LEGACY_FILE_FORMAT]]
** <dt>SQLITE_DBCONFIG_LEGACY_FILE_FORMAT</td>
** <dd>The SQLITE_DBCONFIG_LEGACY_FILE_FORMAT option activates or deactivates
** the legacy file format flag.  When activated, this flag causes all newly
** created database file to have a schema format version number (the 4-byte
** integer found at offset 44 into the database header) of 1.  This in turn
** means that the resulting database file will be readable and writable by
** any SQLite version back to 3.0.0 ([dateof:3.0.0]).  Without this setting,
** newly created databases are generally not understandable by SQLite versions
** prior to 3.3.0 ([dateof:3.3.0]).  As these words are written, there
** is now scarcely any need to generated database files that are compatible
** all the way back to version 3.0.0, and so this setting is of little
** practical use, but is provided so that SQLite can continue to claim the
** ability to generate new database files that are compatible with  version
** 3.0.0.
** <p>Note that when the SQLITE_DBCONFIG_LEGACY_FILE_FORMAT setting is on,
** the [VACUUM] command will fail with an obscure error when attempting to
** process a table with generated columns and a descending index.  This is
** not considered a bug since SQLite versions 3.3.0 and earlier do not support
** either generated columns or decending indexes.
** </dd>
** </dl>
*/

public constant
	SQLITE_DBCONFIG_MAINDBNAME              = 1000, /* const char* */
	SQLITE_DBCONFIG_LOOKASIDE               = 1001, /* void* int int */
	SQLITE_DBCONFIG_ENABLE_FKEY             = 1002, /* int int* */
	SQLITE_DBCONFIG_ENABLE_TRIGGER          = 1003, /* int int* */
	SQLITE_DBCONFIG_ENABLE_FTS3_TOKENIZER   = 1004, /* int int* */
	SQLITE_DBCONFIG_ENABLE_LOAD_EXTENSION   = 1005, /* int int* */
	SQLITE_DBCONFIG_NO_CKPT_ON_CLOSE        = 1006, /* int int* */
	SQLITE_DBCONFIG_ENABLE_QPSG             = 1007, /* int int* */
	SQLITE_DBCONFIG_TRIGGER_EQP             = 1008, /* int int* */
	SQLITE_DBCONFIG_RESET_DATABASE          = 1009, /* int int* */
	SQLITE_DBCONFIG_DEFENSIVE               = 1010, /* int int* */
	SQLITE_DBCONFIG_WRITABLE_SCHEMA         = 1011, /* int int* */
	SQLITE_DBCONFIG_LEGACY_ALTER_TABLE      = 1012, /* int int* */
	SQLITE_DBCONFIG_DQS_DML                 = 1013, /* int int* */
	SQLITE_DBCONFIG_DQS_DDL                 = 1014, /* int int* */
$


/*
** CAPI3REF: Enable Or Disable Extended Result Codes
** METHOD: sqlite3
**
** ^The sqlite3_extended_result_codes() routine enables or disables the
** [extended result codes] feature of SQLite. ^The extended result
** codes are disabled by default for historical compatibility.
*/

public function sqlite3_extended_result_codes( atom db, integer onoff )
	return c_func( _sqlite3_extended_result_codes, {db,onoff} )
end function


/*
** CAPI3REF: Last Insert Rowid
** METHOD: sqlite3
**
** ^Each entry in most SQLite tables (except for [WITHOUT ROWID] tables)
** has a unique 64-bit signed
** integer key called the [ROWID | "rowid"]. ^The rowid is always available
** as an undeclared column named ROWID, OID, or _ROWID_ as long as those
** names are not also used by explicitly declared columns. ^If
** the table has a column of type [INTEGER PRIMARY KEY] then that column
** is another alias for the rowid.
**
** ^The sqlite3_last_insert_rowid(D) interface usually returns the [rowid] of
** the most recent successful [INSERT] into a rowid table or [virtual table]
** on database connection D. ^Inserts into [WITHOUT ROWID] tables are not
** recorded. ^If no successful [INSERT]s into rowid tables have ever occurred
** on the database connection D, then sqlite3_last_insert_rowid(D) returns
** zero.
**
** As well as being set automatically as rows are inserted into database
** tables, the value returned by this function may be set explicitly by
** [sqlite3_set_last_insert_rowid()]
**
** Some virtual table implementations may INSERT rows into rowid tables as
** part of committing a transaction (e.g. to flush data accumulated in memory
** to disk). In this case subsequent calls to this function return the rowid
** associated with these internal INSERT operations, which leads to
** unintuitive results. Virtual table implementations that do write to rowid
** tables in this way can avoid this problem by restoring the original
** rowid value using [sqlite3_set_last_insert_rowid()] before returning
** control to the user.
**
** ^(If an [INSERT] occurs within a trigger then this routine will
** return the [rowid] of the inserted row as long as the trigger is
** running. Once the trigger program ends, the value returned
** by this routine reverts to what it was before the trigger was fired.)^
**
** ^An [INSERT] that fails due to a constraint violation is not a
** successful [INSERT] and does not change the value returned by this
** routine.  ^Thus INSERT OR FAIL, INSERT OR IGNORE, INSERT OR ROLLBACK,
** and INSERT OR ABORT make no changes to the return value of this
** routine when their insertion fails.  ^(When INSERT OR REPLACE
** encounters a constraint violation, it does not fail.  The
** INSERT continues to completion after deleting rows that caused
** the constraint problem so INSERT OR REPLACE will always change
** the return value of this interface.)^
**
** ^For the purposes of this routine, an [INSERT] is considered to
** be successful even if it is subsequently rolled back.
**
** This function is accessible to SQL statements via the
** [last_insert_rowid() SQL function].
**
** If a separate thread performs a new [INSERT] on the same
** database connection while the [sqlite3_last_insert_rowid()]
** function is running and thus changes the last insert [rowid],
** then the value returned by [sqlite3_last_insert_rowid()] is
** unpredictable and might not equal either the old or the new
** last insert [rowid].
*/

public function sqlite3_last_insert_rowid( atom db )
	return c_func( _sqlite3_last_insert_rowid, {db} )
end function


/*
** CAPI3REF: Set the Last Insert Rowid value.
** METHOD: sqlite3
**
** The sqlite3_set_last_insert_rowid(D, R) method allows the application to
** set the value returned by calling sqlite3_last_insert_rowid(D) to R
** without inserting a row into the database.
*/

public procedure sqlite3_set_last_insert_rowid( atom db, atom rowid )
	c_proc( _sqlite3_set_last_insert_rowid, {db,rowid} )
end procedure


/*
** CAPI3REF: Count The Number Of Rows Modified
** METHOD: sqlite3
**
** ^This function returns the number of rows modified, inserted or
** deleted by the most recently completed INSERT, UPDATE or DELETE
** statement on the database connection specified by the only parameter.
** ^Executing any other type of SQL statement does not modify the value
** returned by this function.
**
** ^Only changes made directly by the INSERT, UPDATE or DELETE statement are
** considered - auxiliary changes caused by [CREATE TRIGGER | triggers],
** [foreign key actions] or [REPLACE] constraint resolution are not counted.
**
** Changes to a view that are intercepted by
** [INSTEAD OF trigger | INSTEAD OF triggers] are not counted. ^The value
** returned by sqlite3_changes() immediately after an INSERT, UPDATE or
** DELETE statement run on a view is always zero. Only changes made to real
** tables are counted.
**
** Things are more complicated if the sqlite3_changes() function is
** executed while a trigger program is running. This may happen if the
** program uses the [changes() SQL function], or if some other callback
** function invokes sqlite3_changes() directly. Essentially:
**
** <ul>
**   <li> ^(Before entering a trigger program the value returned by
**        sqlite3_changes() function is saved. After the trigger program
**        has finished, the original value is restored.)^
**
**   <li> ^(Within a trigger program each INSERT, UPDATE and DELETE
**        statement sets the value returned by sqlite3_changes()
**        upon completion as normal. Of course, this value will not include
**        any changes performed by sub-triggers, as the sqlite3_changes()
**        value will be saved and restored after each sub-trigger has run.)^
** </ul>
**
** ^This means that if the changes() SQL function (or similar) is used
** by the first INSERT, UPDATE or DELETE statement within a trigger, it
** returns the value as set when the calling statement began executing.
** ^If it is used by the second or subsequent such statement within a trigger
** program, the value returned reflects the number of rows modified by the
** previous INSERT, UPDATE or DELETE statement within the same trigger.
**
** If a separate thread makes changes on the same database connection
** while [sqlite3_changes()] is running then the value returned
** is unpredictable and not meaningful.
**
** See also:
** <ul>
** <li> the [sqlite3_total_changes()] interface
** <li> the [count_changes pragma]
** <li> the [changes() SQL function]
** <li> the [data_version pragma]
** </ul>
*/

public function sqlite3_changes( atom db )
	return c_func( _sqlite3_changes, {db} )
end function


/*
** CAPI3REF: Total Number Of Rows Modified
** METHOD: sqlite3
**
** ^This function returns the total number of rows inserted, modified or
** deleted by all [INSERT], [UPDATE] or [DELETE] statements completed
** since the database connection was opened, including those executed as
** part of trigger programs. ^Executing any other type of SQL statement
** does not affect the value returned by sqlite3_total_changes().
**
** ^Changes made as part of [foreign key actions] are included in the
** count, but those made as part of REPLACE constraint resolution are
** not. ^Changes to a view that are intercepted by INSTEAD OF triggers
** are not counted.
**
** The [sqlite3_total_changes(D)] interface only reports the number
** of rows that changed due to SQL statement run against database
** connection D.  Any changes by other database connections are ignored.
** To detect changes against a database file from other database
** connections use the [PRAGMA data_version] command or the
** [SQLITE_FCNTL_DATA_VERSION] [file control].
**
** If a separate thread makes changes on the same database connection
** while [sqlite3_total_changes()] is running then the value
** returned is unpredictable and not meaningful.
**
** See also:
** <ul>
** <li> the [sqlite3_changes()] interface
** <li> the [count_changes pragma]
** <li> the [changes() SQL function]
** <li> the [data_version pragma]
** <li> the [SQLITE_FCNTL_DATA_VERSION] [file control]
** </ul>
*/

public function sqlite3_total_changes( atom db )
	return c_func( _sqlite3_total_changes, {db} )
end function


/*
** CAPI3REF: Interrupt A Long-Running Query
** METHOD: sqlite3
**
** ^This function causes any pending database operation to abort and
** return at its earliest opportunity. This routine is typically
** called in response to a user action such as pressing "Cancel"
** or Ctrl-C where the user wants a long query operation to halt
** immediately.
**
** ^It is safe to call this routine from a thread different from the
** thread that is currently running the database operation.  But it
** is not safe to call this routine with a [database connection] that
** is closed or might close before sqlite3_interrupt() returns.
**
** ^If an SQL operation is very nearly finished at the time when
** sqlite3_interrupt() is called, then it might not have an opportunity
** to be interrupted and might continue to completion.
**
** ^An SQL operation that is interrupted will return [SQLITE_INTERRUPT].
** ^If the interrupted SQL operation is an INSERT, UPDATE, or DELETE
** that is inside an explicit transaction, then the entire transaction
** will be rolled back automatically.
**
** ^The sqlite3_interrupt(D) call is in effect until all currently running
** SQL statements on [database connection] D complete.  ^Any new SQL statements
** that are started after the sqlite3_interrupt() call and before the
** running statement count reaches zero are interrupted as if they had been
** running prior to the sqlite3_interrupt() call.  ^New SQL statements
** that are started after the running statement count reaches zero are
** not effected by the sqlite3_interrupt().
** ^A call to sqlite3_interrupt(D) that occurs when there are no running
** SQL statements is a no-op and has no effect on SQL statements
** that are started after the sqlite3_interrupt() call returns.
*/

public procedure sqlite3_interrupt( atom db )
	c_proc( _sqlite3_interrupt, {db} )
end procedure


/*
** CAPI3REF: Determine If An SQL Statement Is Complete
**
** These routines are useful during command-line input to determine if the
** currently entered text seems to form a complete SQL statement or
** if additional input is needed before sending the text into
** SQLite for parsing.  ^These routines return 1 if the input string
** appears to be a complete SQL statement.  ^A statement is judged to be
** complete if it ends with a semicolon token and is not a prefix of a
** well-formed CREATE TRIGGER statement.  ^Semicolons that are embedded within
** string literals or quoted identifier names or comments are not
** independent tokens (they are part of the token in which they are
** embedded) and thus do not count as a statement terminator.  ^Whitespace
** and comments that follow the final semicolon are ignored.
**
** ^These routines return 0 if the statement is incomplete.  ^If a
** memory allocation fails, then SQLITE_NOMEM is returned.
**
** ^These routines do not parse the SQL statements thus
** will not detect syntactically incorrect SQL.
**
** ^(If SQLite has not been initialized using [sqlite3_initialize()] prior
** to invoking sqlite3_complete16() then sqlite3_initialize() is invoked
** automatically by sqlite3_complete16().  If that initialization fails,
** then the return value from sqlite3_complete16() will be non-zero
** regardless of whether or not the input SQL is complete.)^
**
** The input to [sqlite3_complete()] must be a zero-terminated
** UTF-8 string.
**
** The input to [sqlite3_complete16()] must be a zero-terminated
** UTF-16 string in native byte order.
*/

public function sqlite3_complete( sequence sql )
	return c_func( _sqlite3_complete, {allocate_string(sql,TRUE)} )
end function

public function sqlite3_complete16( sequence sql )
	return c_func( _sqlite3_complete16, {allocate_wstring(sql,TRUE)} )
end function


/*
** CAPI3REF: Register A Callback To Handle SQLITE_BUSY Errors
** KEYWORDS: {busy-handler callback} {busy handler}
** METHOD: sqlite3
**
** ^The sqlite3_busy_handler(D,X,P) routine sets a callback function X
** that might be invoked with argument P whenever
** an attempt is made to access a database table associated with
** [database connection] D when another thread
** or process has the table locked.
** The sqlite3_busy_handler() interface is used to implement
** [sqlite3_busy_timeout()] and [PRAGMA busy_timeout].
**
** ^If the busy callback is NULL, then [SQLITE_BUSY]
** is returned immediately upon encountering the lock.  ^If the busy callback
** is not NULL, then the callback might be invoked with two arguments.
**
** ^The first argument to the busy handler is a copy of the void* pointer which
** is the third argument to sqlite3_busy_handler().  ^The second argument to
** the busy handler callback is the number of times that the busy handler has
** been invoked previously for the same locking event.  ^If the
** busy callback returns 0, then no additional attempts are made to
** access the database and [SQLITE_BUSY] is returned
** to the application.
** ^If the callback returns non-zero, then another attempt
** is made to access the database and the cycle repeats.
**
** The presence of a busy handler does not guarantee that it will be invoked
** when there is lock contention. ^If SQLite determines that invoking the busy
** handler could result in a deadlock, it will go ahead and return [SQLITE_BUSY]
** to the application instead of invoking the
** busy handler.
** Consider a scenario where one process is holding a read lock that
** it is trying to promote to a reserved lock and
** a second process is holding a reserved lock that it is trying
** to promote to an exclusive lock.  The first process cannot proceed
** because it is blocked by the second and the second process cannot
** proceed because it is blocked by the first.  If both processes
** invoke the busy handlers, neither will make any progress.  Therefore,
** SQLite returns [SQLITE_BUSY] for the first process, hoping that this
** will induce the first process to release its read lock and allow
** the second process to proceed.
**
** ^The default busy callback is NULL.
**
** ^(There can only be a single busy handler defined for each
** [database connection].  Setting a new busy handler clears any
** previously set handler.)^  ^Note that calling [sqlite3_busy_timeout()]
** or evaluating [PRAGMA busy_timeout=N] will change the
** busy handler and thus clear any previously set busy handler.
**
** The busy callback should not take any actions which modify the
** database connection that invoked the busy handler.  In other words,
** the busy handler is not reentrant.  Any such actions
** result in undefined behavior.
**
** A busy handler must not close the database connection
** or [prepared statement] that invoked the busy handler.
*/

public function sqlite3_busy_handler( atom db, sequence func, atom data = NULL,
		integer func_id = routine_id(func) )

	atom func_cb = call_back( func_id )

	return c_func( _sqlite3_busy_handler, {db,func_cb,data} )
end function


/*
** CAPI3REF: Set A Busy Timeout
** METHOD: sqlite3
**
** ^This routine sets a [sqlite3_busy_handler | busy handler] that sleeps
** for a specified amount of time when a table is locked.  ^The handler
** will sleep multiple times until at least "ms" milliseconds of sleeping
** have accumulated.  ^After at least "ms" milliseconds of sleeping,
** the handler returns 0 which causes [sqlite3_step()] to return
** [SQLITE_BUSY].
**
** ^Calling this routine with an argument less than or equal to zero
** turns off all busy handlers.
**
** ^(There can only be a single busy handler for a particular
** [database connection] at any given moment.  If another busy handler
** was defined  (using [sqlite3_busy_handler()]) prior to calling
** this routine, that other busy handler is cleared.)^
**
** See also:  [PRAGMA busy_timeout]
*/

public function sqlite3_busy_timeout( atom db, integer ms )
	return c_func( _sqlite3_busy_timeout, {db,ms} )
end function


/*
** CAPI3REF: Convenience Routines For Running Queries
** METHOD: sqlite3
**
** This is a legacy interface that is preserved for backwards compatibility.
** Use of this interface is not recommended.
**
** Definition: A <b>result table</b> is memory data structure created by the
** [sqlite3_get_table()] interface.  A result table records the
** complete query results from one or more queries.
**
** The table conceptually has a number of rows and columns.  But
** these numbers are not part of the result table itself.  These
** numbers are obtained separately.  Let N be the number of rows
** and M be the number of columns.
**
** A result table is an array of pointers to zero-terminated UTF-8 strings.
** There are (N+1)*M elements in the array.  The first M pointers point
** to zero-terminated strings that  contain the names of the columns.
** The remaining entries all point to query results.  NULL values result
** in NULL pointers.  All other values are in their UTF-8 zero-terminated
** string representation as returned by [sqlite3_column_text()].
**
** A result table might consist of one or more memory allocations.
** It is not safe to pass a result table directly to [sqlite3_free()].
** A result table should be deallocated using [sqlite3_free_table()].
**
** ^(As an example of the result table format, suppose a query result
** is as follows:
**
** <blockquote><pre>
**        Name        | Age
**        -----------------------
**        Alice       | 43
**        Bob         | 28
**        Cindy       | 21
** </pre></blockquote>
**
** There are two columns (M==2) and three rows (N==3).  Thus the
** result table has 8 entries.  Suppose the result table is stored
** in an array named azResult.  Then azResult holds this content:
**
** <blockquote><pre>
**        azResult&#91;0] = "Name";
**        azResult&#91;1] = "Age";
**        azResult&#91;2] = "Alice";
**        azResult&#91;3] = "43";
**        azResult&#91;4] = "Bob";
**        azResult&#91;5] = "28";
**        azResult&#91;6] = "Cindy";
**        azResult&#91;7] = "21";
** </pre></blockquote>)^
**
** ^The sqlite3_get_table() function evaluates one or more
** semicolon-separated SQL statements in the zero-terminated UTF-8
** string of its 2nd parameter and returns a result table to the
** pointer given in its 3rd parameter.
**
** After the application has finished with the result from sqlite3_get_table(),
** it must pass the result table pointer to sqlite3_free_table() in order to
** release the memory that was malloced.  Because of the way the
** [sqlite3_malloc()] happens within sqlite3_get_table(), the calling
** function must not try to call [sqlite3_free()] directly.  Only
** [sqlite3_free_table()] is able to release the memory properly and safely.
**
** The sqlite3_get_table() interface is implemented as a wrapper around
** [sqlite3_exec()].  The sqlite3_get_table() routine does not have access
** to any internal data structures of SQLite.  It uses only the public
** interface defined here.  As a consequence, errors that occur in the
** wrapper layer outside of the internal [sqlite3_exec()] call are not
** reflected in subsequent calls to [sqlite3_errcode()] or
** [sqlite3_errmsg()].
*/

public function sqlite3_get_table( atom db, sequence sql )

	atom szSql     = allocate_string( sql, TRUE )
	atom pazResult = allocate_data( sizeof(C_POINTER), TRUE )
	atom pnRow     = allocate_data( sizeof(C_POINTER), TRUE )
	atom pnColumn  = allocate_data( sizeof(C_POINTER), TRUE )

	integer result = c_func( _sqlite3_get_table, {db,szSql,pazResult,pnRow,pnColumn,NULL} )

	if result = SQLITE_OK then

		atom azResult = peek_pointer( pazResult )
		integer nRow    = peek4s( pnRow )
		integer nColumn = peek4s( pnColumn )

		atom pResult = azResult
		sequence table = repeat( repeat(0,nColumn), nRow )

		for row = 1 to nRow do
			for col = 1 to nColumn do
				table[row][col] = peek_string( pResult )
				pResult += sizeof( C_POINTER )
			end for
		end for

		c_proc( _sqlite3_free_table, {azResult} )

		return table
	end if

	return result
end function


/*
** CAPI3REF: Memory Allocation Subsystem
**
** The SQLite core uses these three routines for all of its own
** internal memory allocation needs. "Core" in the previous sentence
** does not include operating-system specific [VFS] implementation.  The
** Windows VFS uses native malloc() and free() for some operations.
**
** ^The sqlite3_malloc() routine returns a pointer to a block
** of memory at least N bytes in length, where N is the parameter.
** ^If sqlite3_malloc() is unable to obtain sufficient free
** memory, it returns a NULL pointer.  ^If the parameter N to
** sqlite3_malloc() is zero or negative then sqlite3_malloc() returns
** a NULL pointer.
**
** ^The sqlite3_malloc64(N) routine works just like
** sqlite3_malloc(N) except that N is an unsigned 64-bit integer instead
** of a signed 32-bit integer.
**
** ^Calling sqlite3_free() with a pointer previously returned
** by sqlite3_malloc() or sqlite3_realloc() releases that memory so
** that it might be reused.  ^The sqlite3_free() routine is
** a no-op if is called with a NULL pointer.  Passing a NULL pointer
** to sqlite3_free() is harmless.  After being freed, memory
** should neither be read nor written.  Even reading previously freed
** memory might result in a segmentation fault or other severe error.
** Memory corruption, a segmentation fault, or other severe error
** might result if sqlite3_free() is called with a non-NULL pointer that
** was not obtained from sqlite3_malloc() or sqlite3_realloc().
**
** ^The sqlite3_realloc(X,N) interface attempts to resize a
** prior memory allocation X to be at least N bytes.
** ^If the X parameter to sqlite3_realloc(X,N)
** is a NULL pointer then its behavior is identical to calling
** sqlite3_malloc(N).
** ^If the N parameter to sqlite3_realloc(X,N) is zero or
** negative then the behavior is exactly the same as calling
** sqlite3_free(X).
** ^sqlite3_realloc(X,N) returns a pointer to a memory allocation
** of at least N bytes in size or NULL if insufficient memory is available.
** ^If M is the size of the prior allocation, then min(N,M) bytes
** of the prior allocation are copied into the beginning of buffer returned
** by sqlite3_realloc(X,N) and the prior allocation is freed.
** ^If sqlite3_realloc(X,N) returns NULL and N is positive, then the
** prior allocation is not freed.
**
** ^The sqlite3_realloc64(X,N) interfaces works the same as
** sqlite3_realloc(X,N) except that N is a 64-bit unsigned integer instead
** of a 32-bit signed integer.
**
** ^If X is a memory allocation previously obtained from sqlite3_malloc(),
** sqlite3_malloc64(), sqlite3_realloc(), or sqlite3_realloc64(), then
** sqlite3_msize(X) returns the size of that memory allocation in bytes.
** ^The value returned by sqlite3_msize(X) might be larger than the number
** of bytes requested when X was allocated.  ^If X is a NULL pointer then
** sqlite3_msize(X) returns zero.  If X points to something that is not
** the beginning of memory allocation, or if it points to a formerly
** valid memory allocation that has now been freed, then the behavior
** of sqlite3_msize(X) is undefined and possibly harmful.
**
** ^The memory returned by sqlite3_malloc(), sqlite3_realloc(),
** sqlite3_malloc64(), and sqlite3_realloc64()
** is always aligned to at least an 8 byte boundary, or to a
** 4 byte boundary if the [SQLITE_4_BYTE_ALIGNED_MALLOC] compile-time
** option is used.
**
** The pointer arguments to [sqlite3_free()] and [sqlite3_realloc()]
** must be either NULL or else pointers obtained from a prior
** invocation of [sqlite3_malloc()] or [sqlite3_realloc()] that have
** not yet been released.
**
** The application must not read or write any part of
** a block of memory after it has been released using
** [sqlite3_free()] or [sqlite3_realloc()].
*/

public function sqlite3_malloc( integer size )
	return c_func( _sqlite3_malloc, {size} )
end function

public function sqlite3_malloc64( atom size )
	return c_func( _sqlite3_malloc64, {size} )
end function

public function sqlite3_realloc( atom ptr, integer size )
	return c_func( _sqlite3_realloc, {ptr,size} )
end function

public function sqlite3_realloc64( atom ptr, atom size )
	return c_func( _sqlite3_realloc64, {ptr,size} )
end function

public procedure sqlite3_free( atom ptr )
	c_proc( _sqlite3_free, {ptr} )
end procedure

public function sqlite3_msize( atom ptr )
	return c_func( _sqlite3_msize, {ptr} )
end function


/*
** CAPI3REF: Memory Allocator Statistics
**
** SQLite provides these two interfaces for reporting on the status
** of the [sqlite3_malloc()], [sqlite3_free()], and [sqlite3_realloc()]
** routines, which form the built-in memory allocation subsystem.
**
** ^The [sqlite3_memory_used()] routine returns the number of bytes
** of memory currently outstanding (malloced but not freed).
** ^The [sqlite3_memory_highwater()] routine returns the maximum
** value of [sqlite3_memory_used()] since the high-water mark
** was last reset.  ^The values returned by [sqlite3_memory_used()] and
** [sqlite3_memory_highwater()] include any overhead
** added by SQLite in its implementation of [sqlite3_malloc()],
** but not overhead added by the any underlying system library
** routines that [sqlite3_malloc()] may call.
**
** ^The memory high-water mark is reset to the current value of
** [sqlite3_memory_used()] if and only if the parameter to
** [sqlite3_memory_highwater()] is true.  ^The value returned
** by [sqlite3_memory_highwater(1)] is the high-water mark
** prior to the reset.
*/

public function sqlite3_memory_used()
	return c_func( _sqlite3_memory_used, {} )
end function

public function sqlite3_memory_highwater( integer resetFlag = FALSE )
	return c_func( _sqlite3_memory_highwater, {resetFlag} )
end function


/*
** CAPI3REF: Pseudo-Random Number Generator
**
** SQLite contains a high-quality pseudo-random number generator (PRNG) used to
** select random [ROWID | ROWIDs] when inserting new records into a table that
** already uses the largest possible [ROWID].  The PRNG is also used for
** the built-in random() and randomblob() SQL functions.  This interface allows
** applications to access the same PRNG for other purposes.
**
** ^A call to this routine stores N bytes of randomness into buffer P.
** ^The P parameter can be a NULL pointer.
**
** ^If this routine has not been previously called or if the previous
** call had N less than one or a NULL pointer for P, then the PRNG is
** seeded using randomness obtained from the xRandomness method of
** the default [sqlite3_vfs] object.
** ^If the previous call to this routine had an N of 1 or more and a
** non-NULL P then the pseudo-randomness is generated
** internally and without recourse to the [sqlite3_vfs] xRandomness
** method.
*/

public function sqlite3_randomness( integer N )

	atom P = allocate_data( N, TRUE )
	c_proc( _sqlite3_randomness, {N,P} )

	return peek({ P, N })
end function


/*
** CAPI3REF: Compile-Time Authorization Callbacks
** METHOD: sqlite3
** KEYWORDS: {authorizer callback}
**
** ^This routine registers an authorizer callback with a particular
** [database connection], supplied in the first argument.
** ^The authorizer callback is invoked as SQL statements are being compiled
** by [sqlite3_prepare()] or its variants [sqlite3_prepare_v2()],
** [sqlite3_prepare_v3()], [sqlite3_prepare16()], [sqlite3_prepare16_v2()],
** and [sqlite3_prepare16_v3()].  ^At various
** points during the compilation process, as logic is being created
** to perform various actions, the authorizer callback is invoked to
** see if those actions are allowed.  ^The authorizer callback should
** return [SQLITE_OK] to allow the action, [SQLITE_IGNORE] to disallow the
** specific action but allow the SQL statement to continue to be
** compiled, or [SQLITE_DENY] to cause the entire SQL statement to be
** rejected with an error.  ^If the authorizer callback returns
** any value other than [SQLITE_IGNORE], [SQLITE_OK], or [SQLITE_DENY]
** then the [sqlite3_prepare_v2()] or equivalent call that triggered
** the authorizer will fail with an error message.
**
** When the callback returns [SQLITE_OK], that means the operation
** requested is ok.  ^When the callback returns [SQLITE_DENY], the
** [sqlite3_prepare_v2()] or equivalent call that triggered the
** authorizer will fail with an error message explaining that
** access is denied.
**
** ^The first parameter to the authorizer callback is a copy of the third
** parameter to the sqlite3_set_authorizer() interface. ^The second parameter
** to the callback is an integer [SQLITE_COPY | action code] that specifies
** the particular action to be authorized. ^The third through sixth parameters
** to the callback are either NULL pointers or zero-terminated strings
** that contain additional details about the action to be authorized.
** Applications must always be prepared to encounter a NULL pointer in any
** of the third through the sixth parameters of the authorization callback.
**
** ^If the action code is [SQLITE_READ]
** and the callback returns [SQLITE_IGNORE] then the
** [prepared statement] statement is constructed to substitute
** a NULL value in place of the table column that would have
** been read if [SQLITE_OK] had been returned.  The [SQLITE_IGNORE]
** return can be used to deny an untrusted user access to individual
** columns of a table.
** ^When a table is referenced by a [SELECT] but no column values are
** extracted from that table (for example in a query like
** "SELECT count(*) FROM tab") then the [SQLITE_READ] authorizer callback
** is invoked once for that table with a column name that is an empty string.
** ^If the action code is [SQLITE_DELETE] and the callback returns
** [SQLITE_IGNORE] then the [DELETE] operation proceeds but the
** [truncate optimization] is disabled and all rows are deleted individually.
**
** An authorizer is used when [sqlite3_prepare | preparing]
** SQL statements from an untrusted source, to ensure that the SQL statements
** do not try to access data they are not allowed to see, or that they do not
** try to execute malicious statements that damage the database.  For
** example, an application may allow a user to enter arbitrary
** SQL queries for evaluation by a database.  But the application does
** not want the user to be able to make arbitrary changes to the
** database.  An authorizer could then be put in place while the
** user-entered SQL is being [sqlite3_prepare | prepared] that
** disallows everything except [SELECT] statements.
**
** Applications that need to process SQL from untrusted sources
** might also consider lowering resource limits using [sqlite3_limit()]
** and limiting database size using the [max_page_count] [PRAGMA]
** in addition to using an authorizer.
**
** ^(Only a single authorizer can be in place on a database connection
** at a time.  Each call to sqlite3_set_authorizer overrides the
** previous call.)^  ^Disable the authorizer by installing a NULL callback.
** The authorizer is disabled by default.
**
** The authorizer callback must not do anything that will modify
** the database connection that invoked the authorizer callback.
** Note that [sqlite3_prepare_v2()] and [sqlite3_step()] both modify their
** database connections for the meaning of "modify" in this paragraph.
**
** ^When [sqlite3_prepare_v2()] is used to prepare a statement, the
** statement might be re-prepared during [sqlite3_step()] due to a
** schema change.  Hence, the application should ensure that the
** correct authorizer callback remains in place during the [sqlite3_step()].
**
** ^Note that the authorizer callback is invoked only during
** [sqlite3_prepare()] or its variants.  Authorization is not
** performed during statement evaluation in [sqlite3_step()], unless
** as stated in the previous paragraph, sqlite3_step() invokes
** sqlite3_prepare_v2() to reprepare a statement after a schema change.
*/

public function sqlite3_set_authorizer( atom db, sequence func, atom userData = NULL,
		integer func_id = routine_id(func) )

	atom func_cb = call_back( func_id )

	return c_func( _sqlite3_set_authorizer, {db,func_cb,userData} )
end function


/*
** CAPI3REF: Authorizer Return Codes
**
** The [sqlite3_set_authorizer | authorizer callback function] must
** return either [SQLITE_OK] or one of these two constants in order
** to signal SQLite whether or not the action is permitted.  See the
** [sqlite3_set_authorizer | authorizer documentation] for additional
** information.
**
** Note that SQLITE_IGNORE is also used as a [conflict resolution mode]
** returned from the [sqlite3_vtab_on_conflict()] interface.
*/

public constant
	SQLITE_DENY     = 1, /* Abort the SQL statement with an error */
	SQLITE_IGNORE   = 2, /* Don't allow access, but don't generate an error */
$


/*
** CAPI3REF: Authorizer Action Codes
**
** The [sqlite3_set_authorizer()] interface registers a callback function
** that is invoked to authorize certain SQL statement actions.  The
** second parameter to the callback is an integer code that specifies
** what action is being authorized.  These are the integer action codes that
** the authorizer callback may be passed.
**
** These action code values signify what kind of operation is to be
** authorized.  The 3rd and 4th parameters to the authorization
** callback function will be parameters or NULL depending on which of these
** codes is used as the second parameter.  ^(The 5th parameter to the
** authorizer callback is the name of the database ("main", "temp",
** etc.) if applicable.)^  ^The 6th parameter to the authorizer callback
** is the name of the inner-most trigger or view that is responsible for
** the access attempt or NULL if this access attempt is directly from
** top-level SQL code.
*/

public constant
	/************************************** 3rd ************ 4th ***********/
	SQLITE_CREATE_INDEX         =  1,   /* Index Name      Table Name      */
	SQLITE_CREATE_TABLE         =  2,   /* Table Name      NULL            */
	SQLITE_CREATE_TEMP_INDEX    =  3,   /* Index Name      Table Name      */
	SQLITE_CREATE_TEMP_TABLE    =  4,   /* Table Name      NULL            */
	SQLITE_CREATE_TEMP_TRIGGER  =  5,   /* Trigger Name    Table Name      */
	SQLITE_CREATE_TEMP_VIEW     =  6,   /* View Name       NULL            */
	SQLITE_CREATE_TRIGGER       =  7,   /* Trigger Name    Table Name      */
	SQLITE_CREATE_VIEW          =  8,   /* View Name       NULL            */
	SQLITE_DELETE               =  9,   /* Table Name      NULL            */
	SQLITE_DROP_INDEX           = 10,   /* Index Name      Table Name      */
	SQLITE_DROP_TABLE           = 11,   /* Table Name      NULL            */
	SQLITE_DROP_TEMP_INDEX      = 12,   /* Index Name      Table Name      */
	SQLITE_DROP_TEMP_TABLE      = 13,   /* Table Name      NULL            */
	SQLITE_DROP_TEMP_TRIGGER    = 14,   /* Trigger Name    Table Name      */
	SQLITE_DROP_TEMP_VIEW       = 15,   /* View Name       NULL            */
	SQLITE_DROP_TRIGGER         = 16,   /* Trigger Name    Table Name      */
	SQLITE_DROP_VIEW            = 17,   /* View Name       NULL            */
	SQLITE_INSERT               = 18,   /* Table Name      NULL            */
	SQLITE_PRAGMA               = 19,   /* Pragma Name     1st arg or NULL */
	SQLITE_READ                 = 20,   /* Table Name      Column Name     */
	SQLITE_SELECT               = 21,   /* NULL            NULL            */
	SQLITE_TRANSACTION          = 22,   /* Operation       NULL            */
	SQLITE_UPDATE               = 23,   /* Table Name      Column Name     */
	SQLITE_ATTACH               = 24,   /* Filename        NULL            */
	SQLITE_DETACH               = 25,   /* Database Name   NULL            */
	SQLITE_ALTER_TABLE          = 26,   /* Database Name   Table Name      */
	SQLITE_REINDEX              = 27,   /* Index Name      NULL            */
	SQLITE_ANALYZE              = 28,   /* Table Name      NULL            */
	SQLITE_CREATE_VTABLE        = 29,   /* Table Name      Module Name     */
	SQLITE_DROP_VTABLE          = 30,   /* Table Name      Module Name     */
	SQLITE_FUNCTION             = 31,   /* NULL            Function Name   */
	SQLITE_SAVEPOINT            = 32,   /* Operation       Savepoint Name  */
	SQLITE_COPY                 =  0,   /* No longer used */
	SQLITE_RECURSIVE            = 33,   /* NULL            NULL            */
$


/*
** CAPI3REF: Tracing And Profiling Functions
** METHOD: sqlite3
**
** These routines are deprecated. Use the [sqlite3_trace_v2()] interface
** instead of the routines described here.
**
** These routines register callback functions that can be used for
** tracing and profiling the execution of SQL statements.
**
** ^The callback function registered by sqlite3_trace() is invoked at
** various times when an SQL statement is being run by [sqlite3_step()].
** ^The sqlite3_trace() callback is invoked with a UTF-8 rendering of the
** SQL statement text as the statement first begins executing.
** ^(Additional sqlite3_trace() callbacks might occur
** as each triggered subprogram is entered.  The callbacks for triggers
** contain a UTF-8 SQL comment that identifies the trigger.)^
**
** The [SQLITE_TRACE_SIZE_LIMIT] compile-time option can be used to limit
** the length of [bound parameter] expansion in the output of sqlite3_trace().
**
** ^The callback function registered by sqlite3_profile() is invoked
** as each SQL statement finishes.  ^The profile callback contains
** the original statement text and an estimate of wall-clock time
** of how long that statement took to run.  ^The profile callback
** time is in units of nanoseconds, however the current implementation
** is only capable of millisecond resolution so the six least significant
** digits in the time are meaningless.  Future versions of SQLite
** might provide greater resolution on the profiler callback.  Invoking
** either [sqlite3_trace()] or [sqlite3_trace_v2()] will cancel the
** profile callback.
*/

deprecate
public function sqlite3_trace( atom db, sequence func, atom userData = NULL,
		integer func_id = routine_id(func) )

	atom func_cb = call_back( func_id )

	return c_func( _sqlite3_trace, {db,func_cb,userData} )
end function

deprecate
public function sqlite3_profile( atom db, sequence func, atom userData = NULL,
		integer func_id = routine_id(func) )

	atom func_cb = call_back( func_id )

	return c_func( _sqlite3_profile, {db,func_cb,userData} )
end function


/*
** CAPI3REF: SQL Trace Event Codes
** KEYWORDS: SQLITE_TRACE
**
** These constants identify classes of events that can be monitored
** using the [sqlite3_trace_v2()] tracing logic.  The M argument
** to [sqlite3_trace_v2(D,M,X,P)] is an OR-ed combination of one or more of
** the following constants.  ^The first argument to the trace callback
** is one of the following constants.
**
** New tracing constants may be added in future releases.
**
** ^A trace callback has four arguments: xCallback(T,C,P,X).
** ^The T argument is one of the integer type codes above.
** ^The C argument is a copy of the context pointer passed in as the
** fourth argument to [sqlite3_trace_v2()].
** The P and X arguments are pointers whose meanings depend on T.
**
** <dl>
** [[SQLITE_TRACE_STMT]] <dt>SQLITE_TRACE_STMT</dt>
** <dd>^An SQLITE_TRACE_STMT callback is invoked when a prepared statement
** first begins running and possibly at other times during the
** execution of the prepared statement, such as at the start of each
** trigger subprogram. ^The P argument is a pointer to the
** [prepared statement]. ^The X argument is a pointer to a string which
** is the unexpanded SQL text of the prepared statement or an SQL comment
** that indicates the invocation of a trigger.  ^The callback can compute
** the same text that would have been returned by the legacy [sqlite3_trace()]
** interface by using the X argument when X begins with "--" and invoking
** [sqlite3_expanded_sql(P)] otherwise.
**
** [[SQLITE_TRACE_PROFILE]] <dt>SQLITE_TRACE_PROFILE</dt>
** <dd>^An SQLITE_TRACE_PROFILE callback provides approximately the same
** information as is provided by the [sqlite3_profile()] callback.
** ^The P argument is a pointer to the [prepared statement] and the
** X argument points to a 64-bit integer which is the estimated of
** the number of nanosecond that the prepared statement took to run.
** ^The SQLITE_TRACE_PROFILE callback is invoked when the statement finishes.
**
** [[SQLITE_TRACE_ROW]] <dt>SQLITE_TRACE_ROW</dt>
** <dd>^An SQLITE_TRACE_ROW callback is invoked whenever a prepared
** statement generates a single row of result.
** ^The P argument is a pointer to the [prepared statement] and the
** X argument is unused.
**
** [[SQLITE_TRACE_CLOSE]] <dt>SQLITE_TRACE_CLOSE</dt>
** <dd>^An SQLITE_TRACE_CLOSE callback is invoked when a database
** connection closes.
** ^The P argument is a pointer to the [database connection] object
** and the X argument is unused.
** </dl>
*/

public constant
	SQLITE_TRACE_STMT    = 0x01,
	SQLITE_TRACE_PROFILE = 0x02,
	SQLITE_TRACE_ROW     = 0x04,
	SQLITE_TRACE_CLOSE   = 0x08,
$


/*
** CAPI3REF: SQL Trace Hook
** METHOD: sqlite3
**
** ^The sqlite3_trace_v2(D,M,X,P) interface registers a trace callback
** function X against [database connection] D, using property mask M
** and context pointer P.  ^If the X callback is
** NULL or if the M mask is zero, then tracing is disabled.  The
** M argument should be the bitwise OR-ed combination of
** zero or more [SQLITE_TRACE] constants.
**
** ^Each call to either sqlite3_trace() or sqlite3_trace_v2() overrides
** (cancels) any prior calls to sqlite3_trace() or sqlite3_trace_v2().
**
** ^The X callback is invoked whenever any of the events identified by
** mask M occur.  ^The integer return value from the callback is currently
** ignored, though this may change in future releases.  Callback
** implementations should return zero to ensure future compatibility.
**
** ^A trace callback is invoked with four arguments: callback(T,C,P,X).
** ^The T argument is one of the [SQLITE_TRACE]
** constants to indicate why the callback was invoked.
** ^The C argument is a copy of the context pointer.
** The P and X arguments are pointers whose meanings depend on T.
**
** The sqlite3_trace_v2() interface is intended to replace the legacy
** interfaces [sqlite3_trace()] and [sqlite3_profile()], both of which
** are deprecated.
*/

public function sqlite3_trace_v2( atom db, atom mask, sequence func, atom userData=NULL, integer func_id=routine_id(func) )
	return c_func( _sqlite3_trace_v2, {db,mask,call_back(func_id),userData} )
end function


/*
** CAPI3REF: Query Progress Callbacks
** METHOD: sqlite3
**
** ^The sqlite3_progress_handler(D,N,X,P) interface causes the callback
** function X to be invoked periodically during long running calls to
** [sqlite3_exec()], [sqlite3_step()] and [sqlite3_get_table()] for
** database connection D.  An example use for this
** interface is to keep a GUI updated during a large query.
**
** ^The parameter P is passed through as the only parameter to the
** callback function X.  ^The parameter N is the approximate number of
** [virtual machine instructions] that are evaluated between successive
** invocations of the callback X.  ^If N is less than one then the progress
** handler is disabled.
**
** ^Only a single progress handler may be defined at one time per
** [database connection]; setting a new progress handler cancels the
** old one.  ^Setting parameter X to NULL disables the progress handler.
** ^The progress handler is also disabled by setting N to a value less
** than 1.
**
** ^If the progress callback returns non-zero, the operation is
** interrupted.  This feature can be used to implement a
** "Cancel" button on a GUI progress dialog box.
**
** The progress handler callback must not do anything that will modify
** the database connection that invoked the progress handler.
** Note that [sqlite3_prepare_v2()] and [sqlite3_step()] both modify their
** database connections for the meaning of "modify" in this paragraph.
**
*/

public procedure sqlite3_progress_handler( atom db, integer n, sequence func, atom userData=NULL, integer func_id=routine_id(func) )
	c_proc( _sqlite3_progress_handler, {db,n,call_back(func_id),userData} )
end procedure


/*
** CAPI3REF: Opening A New Database Connection
** CONSTRUCTOR: sqlite3
**
** ^These routines open an SQLite database file as specified by the
** filename argument. ^The filename argument is interpreted as UTF-8 for
** sqlite3_open() and sqlite3_open_v2() and as UTF-16 in the native byte
** order for sqlite3_open16(). ^(A [database connection] handle is usually
** returned in *ppDb, even if an error occurs.  The only exception is that
** if SQLite is unable to allocate memory to hold the [sqlite3] object,
** a NULL will be written into *ppDb instead of a pointer to the [sqlite3]
** object.)^ ^(If the database is opened (and/or created) successfully, then
** [SQLITE_OK] is returned.  Otherwise an [error code] is returned.)^ ^The
** [sqlite3_errmsg()] or [sqlite3_errmsg16()] routines can be used to obtain
** an English language description of the error following a failure of any
** of the sqlite3_open() routines.
**
** ^The default encoding will be UTF-8 for databases created using
** sqlite3_open() or sqlite3_open_v2().  ^The default encoding for databases
** created using sqlite3_open16() will be UTF-16 in the native byte order.
**
** Whether or not an error occurs when it is opened, resources
** associated with the [database connection] handle should be released by
** passing it to [sqlite3_close()] when it is no longer required.
**
** The sqlite3_open_v2() interface works like sqlite3_open()
** except that it accepts two additional parameters for additional control
** over the new database connection.  ^(The flags parameter to
** sqlite3_open_v2() must include, at a minimum, one of the following
** three flag combinations:)^
**
** <dl>
** ^(<dt>[SQLITE_OPEN_READONLY]</dt>
** <dd>The database is opened in read-only mode.  If the database does not
** already exist, an error is returned.</dd>)^
**
** ^(<dt>[SQLITE_OPEN_READWRITE]</dt>
** <dd>The database is opened for reading and writing if possible, or reading
** only if the file is write protected by the operating system.  In either
** case the database must already exist, otherwise an error is returned.</dd>)^
**
** ^(<dt>[SQLITE_OPEN_READWRITE] | [SQLITE_OPEN_CREATE]</dt>
** <dd>The database is opened for reading and writing, and is created if
** it does not already exist. This is the behavior that is always used for
** sqlite3_open() and sqlite3_open16().</dd>)^
** </dl>
**
** In addition to the required flags, the following optional flags are
** also supported:
**
** <dl>
** ^(<dt>[SQLITE_OPEN_URI]</dt>
** <dd>The filename can be interpreted as a URI if this flag is set.</dd>)^
**
** ^(<dt>[SQLITE_OPEN_MEMORY]</dt>
** <dd>The database will be opened as an in-memory database.  The database
** is named by the "filename" argument for the purposes of cache-sharing,
** if shared cache mode is enabled, but the "filename" is otherwise ignored.
** </dd>)^
**
** ^(<dt>[SQLITE_OPEN_NOMUTEX]</dt>
** <dd>The new database connection will use the "multi-thread"
** [threading mode].)^  This means that separate threads are allowed
** to use SQLite at the same time, as long as each thread is using
** a different [database connection].
**
** ^(<dt>[SQLITE_OPEN_FULLMUTEX]</dt>
** <dd>The new database connection will use the "serialized"
** [threading mode].)^  This means the multiple threads can safely
** attempt to use the same database connection at the same time.
** (Mutexes will block any actual concurrency, but in this mode
** there is no harm in trying.)
**
** ^(<dt>[SQLITE_OPEN_SHAREDCACHE]</dt>
** <dd>The database is opened [shared cache] enabled, overriding
** the default shared cache setting provided by
** [sqlite3_enable_shared_cache()].)^
**
** ^(<dt>[SQLITE_OPEN_PRIVATECACHE]</dt>
** <dd>The database is opened [shared cache] disabled, overriding
** the default shared cache setting provided by
** [sqlite3_enable_shared_cache()].)^
**
** [[OPEN_NOFOLLOW]] ^(<dt>[SQLITE_OPEN_NOFOLLOW]</dt>
** <dd>The database filename is not allowed to be a symbolic link</dd>
** </dl>)^
**
** If the 3rd parameter to sqlite3_open_v2() is not one of the
** required combinations shown above optionally combined with other
** [SQLITE_OPEN_READONLY | SQLITE_OPEN_* bits]
** then the behavior is undefined.
**
** ^The fourth parameter to sqlite3_open_v2() is the name of the
** [sqlite3_vfs] object that defines the operating system interface that
** the new database connection should use.  ^If the fourth parameter is
** a NULL pointer then the default [sqlite3_vfs] object is used.
**
** ^If the filename is ":memory:", then a private, temporary in-memory database
** is created for the connection.  ^This in-memory database will vanish when
** the database connection is closed.  Future versions of SQLite might
** make use of additional special filenames that begin with the ":" character.
** It is recommended that when a database filename actually does begin with
** a ":" character you should prefix the filename with a pathname such as
** "./" to avoid ambiguity.
**
** ^If the filename is an empty string, then a private, temporary
** on-disk database will be created.  ^This private database will be
** automatically deleted as soon as the database connection is closed.
**
** [[URI filenames in sqlite3_open()]] <h3>URI Filenames</h3>
**
** ^If [URI filename] interpretation is enabled, and the filename argument
** begins with "file:", then the filename is interpreted as a URI. ^URI
** filename interpretation is enabled if the [SQLITE_OPEN_URI] flag is
** set in the third argument to sqlite3_open_v2(), or if it has
** been enabled globally using the [SQLITE_CONFIG_URI] option with the
** [sqlite3_config()] method or by the [SQLITE_USE_URI] compile-time option.
** URI filename interpretation is turned off
** by default, but future releases of SQLite might enable URI filename
** interpretation by default.  See "[URI filenames]" for additional
** information.
**
** URI filenames are parsed according to RFC 3986. ^If the URI contains an
** authority, then it must be either an empty string or the string
** "localhost". ^If the authority is not an empty string or "localhost", an
** error is returned to the caller. ^The fragment component of a URI, if
** present, is ignored.
**
** ^SQLite uses the path component of the URI as the name of the disk file
** which contains the database. ^If the path begins with a '/' character,
** then it is interpreted as an absolute path. ^If the path does not begin
** with a '/' (meaning that the authority section is omitted from the URI)
** then the path is interpreted as a relative path.
** ^(On windows, the first component of an absolute path
** is a drive specification (e.g. "C:").)^
**
** [[core URI query parameters]]
** The query component of a URI may contain parameters that are interpreted
** either by SQLite itself, or by a [VFS | custom VFS implementation].
** SQLite and its built-in [VFSes] interpret the
** following query parameters:
**
** <ul>
**   <li> <b>vfs</b>: ^The "vfs" parameter may be used to specify the name of
**     a VFS object that provides the operating system interface that should
**     be used to access the database file on disk. ^If this option is set to
**     an empty string the default VFS object is used. ^Specifying an unknown
**     VFS is an error. ^If sqlite3_open_v2() is used and the vfs option is
**     present, then the VFS specified by the option takes precedence over
**     the value passed as the fourth parameter to sqlite3_open_v2().
**
**   <li> <b>mode</b>: ^(The mode parameter may be set to either "ro", "rw",
**     "rwc", or "memory". Attempting to set it to any other value is
**     an error)^.
**     ^If "ro" is specified, then the database is opened for read-only
**     access, just as if the [SQLITE_OPEN_READONLY] flag had been set in the
**     third argument to sqlite3_open_v2(). ^If the mode option is set to
**     "rw", then the database is opened for read-write (but not create)
**     access, as if SQLITE_OPEN_READWRITE (but not SQLITE_OPEN_CREATE) had
**     been set. ^Value "rwc" is equivalent to setting both
**     SQLITE_OPEN_READWRITE and SQLITE_OPEN_CREATE.  ^If the mode option is
**     set to "memory" then a pure [in-memory database] that never reads
**     or writes from disk is used. ^It is an error to specify a value for
**     the mode parameter that is less restrictive than that specified by
**     the flags passed in the third parameter to sqlite3_open_v2().
**
**   <li> <b>cache</b>: ^The cache parameter may be set to either "shared" or
**     "private". ^Setting it to "shared" is equivalent to setting the
**     SQLITE_OPEN_SHAREDCACHE bit in the flags argument passed to
**     sqlite3_open_v2(). ^Setting the cache parameter to "private" is
**     equivalent to setting the SQLITE_OPEN_PRIVATECACHE bit.
**     ^If sqlite3_open_v2() is used and the "cache" parameter is present in
**     a URI filename, its value overrides any behavior requested by setting
**     SQLITE_OPEN_PRIVATECACHE or SQLITE_OPEN_SHAREDCACHE flag.
**
**  <li> <b>psow</b>: ^The psow parameter indicates whether or not the
**     [powersafe overwrite] property does or does not apply to the
**     storage media on which the database file resides.
**
**  <li> <b>nolock</b>: ^The nolock parameter is a boolean query parameter
**     which if set disables file locking in rollback journal modes.  This
**     is useful for accessing a database on a filesystem that does not
**     support locking.  Caution:  Database corruption might result if two
**     or more processes write to the same database and any one of those
**     processes uses nolock=1.
**
**  <li> <b>immutable</b>: ^The immutable parameter is a boolean query
**     parameter that indicates that the database file is stored on
**     read-only media.  ^When immutable is set, SQLite assumes that the
**     database file cannot be changed, even by a process with higher
**     privilege, and so the database is opened read-only and all locking
**     and change detection is disabled.  Caution: Setting the immutable
**     property on a database file that does in fact change can result
**     in incorrect query results and/or [SQLITE_CORRUPT] errors.
**     See also: [SQLITE_IOCAP_IMMUTABLE].
**
** </ul>
**
** ^Specifying an unknown parameter in the query component of a URI is not an
** error.  Future versions of SQLite might understand additional query
** parameters.  See "[query parameters with special meaning to SQLite]" for
** additional information.
**
** [[URI filename examples]] <h3>URI filename examples</h3>
**
** <table border="1" align=center cellpadding=5>
** <tr><th> URI filenames <th> Results
** <tr><td> file:data.db <td>
**          Open the file "data.db" in the current directory.
** <tr><td> file:/home/fred/data.db<br>
**          file:///home/fred/data.db <br>
**          file://localhost/home/fred/data.db <br> <td>
**          Open the database file "/home/fred/data.db".
** <tr><td> file://darkstar/home/fred/data.db <td>
**          An error. "darkstar" is not a recognized authority.
** <tr><td style="white-space:nowrap">
**          file:///C:/Documents%20and%20Settings/fred/Desktop/data.db
**     <td> Windows only: Open the file "data.db" on fred's desktop on drive
**          C:. Note that the %20 escaping in this example is not strictly
**          necessary - space characters can be used literally
**          in URI filenames.
** <tr><td> file:data.db?mode=ro&cache=private <td>
**          Open file "data.db" in the current directory for read-only access.
**          Regardless of whether or not shared-cache mode is enabled by
**          default, use a private cache.
** <tr><td> file:/home/fred/data.db?vfs=unix-dotfile <td>
**          Open file "/home/fred/data.db". Use the special VFS "unix-dotfile"
**          that uses dot-files in place of posix advisory locking.
** <tr><td> file:data.db?mode=readonly <td>
**          An error. "readonly" is not a valid option for the "mode" parameter.
** </table>
**
** ^URI hexadecimal escape sequences (%HH) are supported within the path and
** query components of a URI. A hexadecimal escape sequence consists of a
** percent sign - "%" - followed by exactly two hexadecimal digits
** specifying an octet value. ^Before the path or query components of a
** URI filename are interpreted, they are encoded using UTF-8 and all
** hexadecimal escape sequences replaced by a single byte containing the
** corresponding octet. If this process generates an invalid UTF-8 encoding,
** the results are undefined.
**
** <b>Note to Windows users:</b>  The encoding used for the filename argument
** of sqlite3_open() and sqlite3_open_v2() must be UTF-8, not whatever
** codepage is currently defined.  Filenames containing international
** characters must be converted to UTF-8 prior to passing them into
** sqlite3_open() or sqlite3_open_v2().
**
** <b>Note to Windows Runtime users:</b>  The temporary directory must be set
** prior to calling sqlite3_open() or sqlite3_open_v2().  Otherwise, various
** features that require the use of temporary files may fail.
**
** See also: [sqlite3_temp_directory]
*/

public function sqlite3_open( sequence filename )

	atom ppDb = allocate_data( sizeof(C_POINTER), TRUE )

	integer result = c_func( _sqlite3_open, {allocate_string(filename,TRUE),ppDb} )

	if result = SQLITE_OK then
		return {result,peek_pointer(ppDb)}
	end if

	return {result,NULL}
end function

public function sqlite3_open16( sequence filename )

	atom ppDb = allocate_data( sizeof(C_POINTER), TRUE )

	integer result = c_func( _sqlite3_open16, {allocate_wstring(filename,TRUE),ppDb} )

	if result = SQLITE_OK then
		return {result,peek_pointer(ppDb)}
	end if

	return {result,NULL}
end function

public function sqlite3_open_v2( sequence filename, integer flags, sequence vfs = "" )

	atom ppDb = allocate_data( sizeof(C_POINTER), TRUE )

	integer result = c_func( _sqlite3_open_v2, {allocate_string(filename,TRUE),ppDb,flags,allocate_string(vfs,TRUE)} )

	if result = SQLITE_OK then
		return {result,peek_pointer(ppDb)}
	end if

	return {result,NULL}
end function


/*
** CAPI3REF: Obtain Values For URI Parameters
**
** These are utility routines, useful to [VFS|custom VFS implementations],
** that check if a database file was a URI that contained a specific query
** parameter, and if so obtains the value of that query parameter.
**
** The first parameter to these interfaces (hereafter referred to
** as F) must be one of:
** <ul>
** <li> A database filename pointer created by the SQLite core and
** passed into the xOpen() method of a VFS implemention, or
** <li> A filename obtained from [sqlite3_db_filename()], or
** <li> A new filename constructed using [sqlite3_create_filename()].
** </ul>
** If the F parameter is not one of the above, then the behavior is
** undefined and probably undesirable.  Older versions of SQLite were
** more tolerant of invalid F parameters than newer versions.
**
** If F is a suitable filename (as described in the previous paragraph)
** and if P is the name of the query parameter, then
** sqlite3_uri_parameter(F,P) returns the value of the P
** parameter if it exists or a NULL pointer if P does not appear as a
** query parameter on F.  If P is a query parameter of F and it
** has no explicit value, then sqlite3_uri_parameter(F,P) returns
** a pointer to an empty string.
**
** The sqlite3_uri_boolean(F,P,B) routine assumes that P is a boolean
** parameter and returns true (1) or false (0) according to the value
** of P.  The sqlite3_uri_boolean(F,P,B) routine returns true (1) if the
** value of query parameter P is one of "yes", "true", or "on" in any
** case or if the value begins with a non-zero number.  The
** sqlite3_uri_boolean(F,P,B) routines returns false (0) if the value of
** query parameter P is one of "no", "false", or "off" in any case or
** if the value begins with a numeric zero.  If P is not a query
** parameter on F or if the value of P does not match any of the
** above, then sqlite3_uri_boolean(F,P,B) returns (B!=0).
**
** The sqlite3_uri_int64(F,P,D) routine converts the value of P into a
** 64-bit signed integer and returns that integer, or D if P does not
** exist.  If the value of P is something other than an integer, then
** zero is returned.
**
** The sqlite3_uri_key(F,N) returns a pointer to the name (not
** the value) of the N-th query parameter for filename F, or a NULL
** pointer if N is less than zero or greater than the number of query
** parameters minus 1.  The N value is zero-based so N should be 0 to obtain
** the name of the first query parameter, 1 for the second parameter, and
** so forth.
**
** If F is a NULL pointer, then sqlite3_uri_parameter(F,P) returns NULL and
** sqlite3_uri_boolean(F,P,B) returns B.  If F is not a NULL pointer and
** is not a database file pathname pointer that the SQLite core passed
** into the xOpen VFS method, then the behavior of this routine is undefined
** and probably undesirable.
**
** Beginning with SQLite [version 3.31.0] ([dateof:3.31.0]) the input F
** parameter can also be the name of a rollback journal file or WAL file
** in addition to the main database file.  Prior to version 3.31.0, these
** routines would only work if F was the name of the main database file.
** When the F parameter is the name of the rollback journal or WAL file,
** it has access to all the same query parameters as were found on the
** main database file.
**
** See the [URI filename] documentation for additional information.
*/

public function sqlite3_uri_parameter( sequence filename, sequence param )
	return peek_string( c_func( _sqlite3_uri_parameter, {allocate_string(filename,TRUE),
		allocate_string(param,TRUE)} ) )
end function

public function sqlite3_uri_boolean( sequence filename, sequence param, integer default )
	return c_func( _sqlite3_uri_boolean, {allocate_string(filename,TRUE),allocate_string(param,TRUE),
		default} )
end function

public function sqlite3_uri_int64( sequence filename, sequence param, atom default )
	return c_func( _sqlite3_uri_int64, {allocate_string(filename,TRUE),allocate_string(param,TRUE),
		default} )
end function

public function sqlite3_uri_key( sequence filename, integer n )
	return peek_string( c_func( _sqlite3_uri_key, {allocate_string(filename,TRUE),n} ) )
end function


/*
** CAPI3REF:  Translate filenames
**
** These routines are available to [VFS|custom VFS implementations] for
** translating filenames between the main database file, the journal file,
** and the WAL file.
**
** If F is the name of an sqlite database file, journal file, or WAL file
** passed by the SQLite core into the VFS, then sqlite3_filename_database(F)
** returns the name of the corresponding database file.
**
** If F is the name of an sqlite database file, journal file, or WAL file
** passed by the SQLite core into the VFS, or if F is a database filename
** obtained from [sqlite3_db_filename()], then sqlite3_filename_journal(F)
** returns the name of the corresponding rollback journal file.
**
** If F is the name of an sqlite database file, journal file, or WAL file
** that was passed by the SQLite core into the VFS, or if F is a database
** filename obtained from [sqlite3_db_filename()], then
** sqlite3_filename_wal(F) returns the name of the corresponding
** WAL file.
**
** In all of the above, if F is not the name of a database, journal or WAL
** filename passed into the VFS from the SQLite core and F is not the
** return value from [sqlite3_db_filename()], then the result is
** undefined and is likely a memory access violation.
*/

public function sqlite3_filename_database( sequence f )
	return peek_string( c_func( _sqlite3_filename_database, {allocate_string(f,TRUE)} ) )
end function

public function sqlite3_filename_journal( sequence f )
	return peek_string( c_func( _sqlite3_filename_journal, {allocate_string(f,TRUE)} ) )
end function

public function sqlite3_filename_wal( sequence f )
	return peek_string( c_func( _sqlite3_filename_wal, {allocate_string(f,TRUE)} ) )
end function

public function sqlite3_errcode( atom db )
	return c_func( _sqlite3_errcode, {db} )
end function

public function sqlite3_extended_errcode( atom db )
	return c_func( _sqlite3_extended_errcode, {db} )
end function

public function sqlite3_errmsg( atom db )
	return peek_string( c_func( _sqlite3_errmsg, {db} ) )
end function

public function sqlite3_errmsg16( atom db )
	return peek_wstring( c_func( _sqlite3_errmsg16, {db} ) )
end function

public function sqlite3_errstr( integer errcode )
	return peek_string( c_func( _sqlite3_errstr, {errcode} ) )
end function

public function sqlite3_limit( atom db, integer id, integer newval )
	return c_func( _sqlite3_limit, {db,id,newval} )
end function

public constant
	SQLITE_LIMIT_LENGTH                 =  0,
	SQLITE_LIMIT_SQL_LENGTH             =  1,
	SQLITE_LIMIT_COLUMN                 =  2,
	SQLITE_LIMIT_EXPR_DEPTH             =  3,
	SQLITE_LIMIT_COMPOUND_SELECT        =  4,
	SQLITE_LIMIT_VDBE_OP                =  5,
	SQLITE_LIMIT_FUNCTION_ARG           =  6,
	SQLITE_LIMIT_ATTACHED               =  7,
	SQLITE_LIMIT_LIKE_PATTERN_LENGTH    =  8,
	SQLITE_LIMIT_VARIABLE_NUMBER        =  9,
	SQLITE_LIMIT_TRIGGER_DEPTH          = 10,
	SQLITE_LIMIT_WORKER_THREADS         = 11,
$

deprecate
public function sqlite3_prepare( atom db, sequence sql )

	atom psqlite3_stmt = allocate_data( sizeof(C_POINTER), TRUE )

	integer result = c_func( _sqlite3_prepare, {db,allocate_string(sql,TRUE),length(sql),
		psqlite3_stmt,NULL} )

	if result = SQLITE_OK then
		return {result,peek_pointer(psqlite3_stmt)}
	end if

	return {result,NULL}
end function

public function sqlite3_prepare_v2( atom db, sequence sql )

	atom psqlite3_stmt = allocate_data( sizeof(C_POINTER), TRUE )

	integer result = c_func( _sqlite3_prepare_v2, {db,allocate_string(sql,TRUE),length(sql),
		psqlite3_stmt,NULL} )

	if result = SQLITE_OK then
		return {result,peek_pointer(psqlite3_stmt)}
	end if

	return {result,NULL}
end function

public function sqlite3_prepare_v3( atom db, sequence sql, integer prepflags )

	atom psqlite3_stmt = allocate_data( sizeof(C_POINTER), TRUE )

	integer result = c_func( _sqlite3_prepare_v3, {db,allocate_string(sql,TRUE),length(sql),prepflags,
		psqlite3_stmt,NULL} )

	if result = SQLITE_OK then
		return {result,peek_pointer(psqlite3_stmt)}
	end if

	return {result,NULL}
end function

public function sqlite3_prepare16( atom db, sequence sql )

	atom psqlite3_stmt = allocate_data( sizeof(C_POINTER), TRUE )

	integer result = c_func( _sqlite3_prepare16, {db,allocate_wstring(sql,TRUE),length(sql)*2,
		psqlite3_stmt,NULL} )

	if result = SQLITE_OK then
		return {result,peek_pointer(psqlite3_stmt)}
	end if

	return {result,NULL}
end function

public function sqlite3_prepare16_v2( atom db, sequence sql )

	atom psqlite3_stmt = allocate_data( sizeof(C_POINTER), TRUE )

	integer result = c_func( _sqlite3_prepare16_v2, {db,allocate_wstring(sql,TRUE),length(sql)*2,
		psqlite3_stmt,NULL} )

	if result = SQLITE_OK then
		return {result,peek_pointer(psqlite3_stmt)}
	end if

	return {result,NULL}
end function

public function sqlite3_prepare16_v3( atom db, sequence sql, integer prepflags )

	atom psqlite3_stmt = allocate_data( sizeof(C_POINTER), TRUE )

	integer result = c_func( _sqlite3_prepare16_v3, {db,allocate_wstring(sql,TRUE),length(sql)*2,
		prepflags,psqlite3_stmt,NULL} )

	if result = SQLITE_OK then
		return {result,peek_pointer(psqlite3_stmt)}
	end if

	return {result,NULL}
end function

public function sqlite3_sql( atom stmt )
	return peek_string( c_func( _sqlite3_sql, {stmt} ) )
end function

public function sqlite3_expanded_sql( atom stmt )

	atom ptr = c_func( _sqlite3_expanded_sql, {stmt} )

	if ptr then

		sequence str = peek_string( ptr )
		c_proc( _sqlite3_free, {ptr} )

		return str
	end if

	return ""
end function

public function sqlite3_stmt_readonly( atom stmt )
	return c_func( _sqlite3_stmt_readonly, {stmt} )
end function

public function sqlite3_stmt_isexplain( atom stmt )
	return c_func( _sqlite3_stmt_isexplain, {stmt} )
end function

public function sqlite3_stmt_busy( atom stmt )
	return c_func( _sqlite3_stmt_busy, {stmt} )
end function

public function sqlite3_bind_blob( atom stmt, object index, object blob, integer bytes = length(blob),
		sequence free_func = "", integer func_id = routine_id(free_func) )

	if sequence( index ) then
		index = machine:allocate_string( index, TRUE )
		index = c_func( _sqlite3_bind_parameter_index, {stmt,index} )
	end if

	atom func_cb = call_back( func_id )

	if sequence( blob ) then
		blob = allocate_data( blob, TRUE )
		func_cb = SQLITE_TRANSIENT
	end if

	return c_func( _sqlite3_bind_blob, {stmt,index,blob,bytes,func_cb} )
end function

public function sqlite3_bind_blob64( atom stmt, object index, atom blob, atom bytes,
		sequence free_func = "", integer func_id = routine_id(free_func) )

	if sequence( index ) then
		index = machine:allocate_string( index, TRUE )
		index = c_func( _sqlite3_bind_parameter_index, {stmt,index} )
	end if

	atom func_cb = call_back( func_id )

	if sequence( blob ) then
		blob = allocate_data( blob, TRUE )
		func_cb = SQLITE_TRANSIENT
	end if

	return c_func( _sqlite3_bind_blob64, {stmt,index,blob,bytes,func_cb} )
end function

public function sqlite3_bind_double( atom stmt, object index, atom value )

	if sequence( index ) then
		index = machine:allocate_string( index, TRUE )
		index = c_func( _sqlite3_bind_parameter_index, {stmt,index} )
	end if

	return c_func( _sqlite3_bind_double, {stmt,index,value} )
end function

public function sqlite3_bind_int( atom stmt, object index, integer value )

	if sequence( index ) then
		index = machine:allocate_string( index, TRUE )
		index = c_func( _sqlite3_bind_parameter_index, {stmt,index} )
	end if

	return c_func( _sqlite3_bind_int, {stmt,index,value} )
end function

public function sqlite3_bind_int64( atom stmt, object index, atom value )

	if sequence( index ) then
		index = machine:allocate_string( index, TRUE )
		index = c_func( _sqlite3_bind_parameter_index, {stmt,index} )
	end if

	return c_func( _sqlite3_bind_int64, {stmt,index,value} )
end function

public function sqlite3_bind_null( atom stmt, object index )

	if sequence( index ) then
		index = machine:allocate_string( index, TRUE )
		index = c_func( _sqlite3_bind_parameter_index, {stmt,index} )
	end if

	return c_func( _sqlite3_bind_null, {stmt,index} )
end function

public function sqlite3_bind_text( atom stmt, object index, sequence text )

	if sequence( index ) then
		index = machine:allocate_string( index, TRUE )
		index = c_func( _sqlite3_bind_parameter_index, {stmt,index} )
	end if

	atom ptext = machine:allocate_string( text, TRUE )

	return c_func( _sqlite3_bind_text, {stmt,index,ptext,length(text),SQLITE_TRANSIENT} )
end function

public function sqlite3_bind_text16( atom stmt, object index, sequence text )

	if sequence( index ) then
		index = machine:allocate_string( index, TRUE )
		index = c_func( _sqlite3_bind_parameter_index, {stmt,index} )
	end if

	atom ptext = machine:allocate_wstring( text, TRUE )

	return c_func( _sqlite3_bind_text16, {stmt,index,ptext,length(text),SQLITE_TRANSIENT} )
end function

public function sqlite3_bind_text64( atom stmt, object index, sequence text, integer encoding )

	if sequence( index ) then
		index = machine:allocate_string( index, TRUE )
		index = c_func( _sqlite3_bind_parameter_index, {stmt,index} )
	end if

	atom ptext

	if encoding = SQLITE_UTF8 then
		ptext = machine:allocate_string( text, TRUE )
	else -- SQLITE_UTF8, etc.
		ptext = machine:allocate_wstring( text, TRUE )
	end if

	return c_func( _sqlite3_bind_text64, {stmt,index,ptext,length(text),encoding} )
end function

public function sqlite3_bind_value( atom stmt, object index, atom value )

	if sequence( index ) then
		index = machine:allocate_string( index, TRUE )
		index = c_func( _sqlite3_bind_parameter_index, {stmt,index} )
	end if

	return c_func( _sqlite3_bind_value, {stmt,index,value} )
end function

public function sqlite3_bind_pointer( atom stmt, object index, atom data, sequence string,
		sequence free_func = "", integer func_id = routine_id(free_func) )

	if sequence( index ) then
		index = machine:allocate_string( index, TRUE )
		index = c_func( _sqlite3_bind_parameter_index, {stmt,index} )
	end if

	atom func_cb = call_back( func_id )

	return c_func( _sqlite3_bind_pointer, {stmt,index,data,allocate_string(string,TRUE),func_cb} )
end function

public function sqlite3_bind_zeroblob( atom stmt, object index, integer bytes )

	if sequence( index ) then
		index = machine:allocate_string( index, TRUE )
		index = c_func( _sqlite3_bind_parameter_index, {stmt,index} )
	end if

	return c_func( _sqlite3_bind_zeroblob, {stmt,index,bytes} )
end function

public function sqlite3_bind_zeroblob64( atom stmt, object index, atom bytes )

	if sequence( index ) then
		index = machine:allocate_string( index, TRUE )
		index = c_func( _sqlite3_bind_parameter_index, {stmt,index} )
	end if

	return c_func( _sqlite3_bind_zeroblob64, {stmt,index,bytes} )
end function

public function sqlite3_bind_parameter_count( atom stmt )
	return c_func( _sqlite3_bind_parameter_count, {stmt} )
end function

public function sqlite3_bind_parameter_name( atom stmt, integer index )
	return peek_string( c_func( _sqlite3_bind_parameter_name, {stmt,index} ) )
end function

public function sqlite3_bind_parameter_index( atom stmt, sequence name )

	atom pname = machine:allocate_string( name, TRUE )

	return c_func( _sqlite3_bind_parameter_index, {stmt,pname} )
end function

public function sqlite3_clear_bindings( atom stmt )
	return c_func( _sqlite3_clear_bindings, {stmt} )
end function

public constant
	SQLITE_PREPARE_PERSISTENT   = 0x01,
	SQLITE_PREPARE_NORMALIZE    = 0x02,
	SQLITE_PREPARE_NO_VTAB      = 0x04,
$

public function sqlite3_column_count( atom stmt )
	return c_func( _sqlite3_column_count, {stmt} )
end function

public function sqlite3_column_name( atom stmt, integer column )
	return peek_string( c_func( _sqlite3_column_name, {stmt,column} ) )
end function

public function sqlite3_column_name16( atom stmt, integer column )
	return peek_wstring( c_func( _sqlite3_column_name16, {stmt,column} ) )
end function

public function sqlite3_column_database_name( atom stmt, integer column )
	return peek_string( c_func( _sqlite3_column_database_name, {stmt,column} ) )
end function

public function sqlite3_column_database_name16( atom stmt, integer column )
	return peek_wstring( c_func( _sqlite3_column_database_name16, {stmt,column} ) )
end function

public function sqlite3_column_table_name( atom stmt, integer column )
	return peek_string( c_func( _sqlite3_column_table_name, {stmt,column} ) )
end function

public function sqlite3_column_table_name16( atom stmt, integer column )
	return peek_wstring( c_func( _sqlite3_column_table_name16, {stmt,column} ) )
end function

public function sqlite3_column_origin_name( atom stmt, integer column )
	return peek_string( c_func( _sqlite3_column_origin_name, {stmt,column} ) )
end function

public function sqlite3_column_origin_name16( atom stmt, integer column )
	return peek_wstring( c_func( _sqlite3_column_origin_name16, {stmt,column} ) )
end function

public function sqlite3_column_decltype( atom stmt, integer column )
	return peek_string( c_func( _sqlite3_column_decltype, {stmt,column} ) )
end function

public function sqlite3_column_decltype16( atom stmt, integer column )
	return peek_wstring( c_func( _sqlite3_column_decltype16, {stmt,column} ) )
end function

public function sqlite3_step( atom stmt )
	return c_func( _sqlite3_step, {stmt} )
end function

public function sqlite3_data_count( atom stmt )
	return c_func( _sqlite3_data_count, {stmt} )
end function

public constant
	SQLITE_INTEGER  = 1,
	SQLITE_FLOAT    = 2,
	SQLITE_TEXT     = 3,
	SQLITE_BLOB     = 4,
	SQLITE_NULL     = 5,
	SQLITE3_TEXT    = 3,
$

public function sqlite3_type_name( integer t )

	switch t do

		case SQLITE_INTEGER then
			return "SQLITE_INTEGER"

		case SQLITE_FLOAT then
			return "SQLITE_FLOAT"

		case SQLITE_TEXT then
			return "SQLITE_TEXT"

		case SQLITE_BLOB then
			return "SQLITE_BLOB"

		case SQLITE_NULL then
			return "SQLITE_NULL"

	end switch

	return "SQLITE_UNKNOWN"
end function

public function sqlite3_column_blob( atom stmt, integer column )

	atom ptr = c_func( _sqlite3_column_blob, {stmt,column} )

	if ptr then
		integer bytes = c_func( _sqlite3_column_bytes, {stmt,column} )
		return peek({ ptr, bytes })
	end if

	return {}
end function

public function sqlite3_column_double( atom stmt, integer column )
	return c_func( _sqlite3_column_double, {stmt,column} )
end function

public function sqlite3_column_int( atom stmt, integer column )
	return c_func( _sqlite3_column_int, {stmt,column} )
end function

public function sqlite3_column_int64( atom stmt, integer column )
	return c_func( _sqlite3_column_int64, {stmt,column} )
end function

public function sqlite3_column_text( atom stmt, integer column )

	atom ptr = c_func( _sqlite3_column_text, {stmt,column} )

	if ptr then
		integer bytes = c_func( _sqlite3_column_bytes, {stmt,column} )
		return peek({ ptr, bytes })
	end if

	return ""
end function

public function sqlite3_column_text16( atom stmt, integer column )

	atom ptr = c_func( _sqlite3_column_text16, {stmt,column} )

	if ptr then
		integer bytes = c_func( _sqlite3_column_bytes16, {stmt,column} )
		return peek({ ptr, bytes })
	end if

	return ""
end function

public function sqlite3_column_value( atom stmt, integer column )
	return c_func( _sqlite3_column_value, {stmt,column} )
end function

public function sqlite3_column_bytes( atom stmt, integer column )
	return c_func( _sqlite3_column_bytes, {stmt,column} )
end function

public function sqlite3_column_bytes16( atom stmt, integer column )
	return c_func( _sqlite3_column_bytes16, {stmt,column} )
end function

public function sqlite3_column_type( atom stmt, integer column )
	return c_func( _sqlite3_column_type, {stmt,column} )
end function

public function sqlite3_finalize( atom stmt )
	return c_func( _sqlite3_finalize, {stmt} )
end function

public function sqlite3_reset( atom stmt )
	return c_func( _sqlite3_reset, {stmt} )
end function

public function sqlite3_fetch_row( atom stmt )

	integer count = sqlite3_column_count( stmt )
	sequence row = repeat( NULL, count )

	for i = 1 to count do

		integer column_type = sqlite3_column_type( stmt, i-1 )

		switch column_type do

			case SQLITE_INTEGER then
				row[i] = sqlite3_column_int( stmt, i-1 )

			case SQLITE_FLOAT then
				row[i] = sqlite3_column_double( stmt, i-1 )

			case SQLITE_BLOB then
				row[i] = sqlite3_column_blob( stmt, i-1 )

			case SQLITE_TEXT then
				row[i] = sqlite3_column_text( stmt, i-1 )

		end switch

	end for

	return row
end function

public procedure sqlite3_assign_params( atom stmt, sequence params )

	if atom( params ) then
		params = {params}
	end if

	for i = 1 to length( params ) do

		object param_name
		object param_data
		object param_type

		if integer( params[i] ) then
			param_name = i
			param_data = params[i]
			param_type = SQLITE_INTEGER

		elsif atom( params[i] ) then
			param_name = i
			param_data = params[i]
			param_type = SQLITE_FLOAT

		elsif string( params[i] ) then
			param_name = i
			param_data = params[i]
			param_type = SQLITE_TEXT

		elsif length( params[i] ) = 0 then
			param_name = i
			param_data = params[i]
			param_type = SQLITE_TEXT

		elsif length( params[i] ) = 2 then
			param_name = params[i][1]
			param_data = params[i][2]

			if integer( param_data ) then
				param_type = SQLITE_INTEGER
			elsif atom( param_data ) then
				param_type = SQLITE_FLOAT
			elsif string( param_data ) then
				param_type = SQLITE_TEXT
			else
				param_type = SQLITE_BLOB
			end if

		elsif length( params[i] ) = 3 then
			param_name = params[i][1]
			param_data = params[i][2]
			param_type = params[i][3]

		elsif length( params[i] ) > 3 then
			param_name = i
			param_data = params[i]
			param_type = SQLITE_BLOB

		end if

		switch param_type do

			case SQLITE_INTEGER then
				sqlite3_bind_int( stmt, param_name, param_data )
			case SQLITE_FLOAT then
				sqlite3_bind_double( stmt, param_name, param_data )
			case SQLITE_TEXT then
				sqlite3_bind_text( stmt, param_name, param_data )
			case SQLITE_BLOB then
				sqlite3_bind_blob( stmt, param_name, param_data )

		end switch

	end for

end procedure

public function sqlite3_query_row( atom db, sequence sql, object params = {} )

	atom result, stmt
	{result,stmt} = sqlite3_prepare16_v2( db, sql )

	if result != SQLITE_OK then
		return {result,{}}
	end if

	if atom( params ) then
		params = {params}
	end if

	for i = 1 to length( params ) do

		if atom( params[i] ) or length( params[i] ) != 2 then
			params[i] = {params[i]}
		end if

		object param_value = params[i][1]
		integer param_type = SQLITE_NULL

		if length( params[i] ) = 2   then param_type  = params[i][2]
		elsif integer( param_value ) then param_type = SQLITE_INTEGER
		elsif atom( param_value )    then param_type = SQLITE_FLOAT
		elsif string( param_value )  then param_type = SQLITE_TEXT
		else                              param_type = SQLITE_BLOB
		end if

		switch param_type do
			case SQLITE_INTEGER then sqlite3_bind_int( stmt, i, param_value )
			case SQLITE_FLOAT   then sqlite3_bind_double( stmt, i, param_value )
			case SQLITE_TEXT    then sqlite3_bind_text( stmt, i, param_value )
			case SQLITE_BLOB    then sqlite3_bind_blob( stmt, i, param_value )
		end switch

	end for

	result = sqlite3_step( stmt )

	if result != SQLITE_ROW then
		sqlite3_finalize( stmt )
		return {result,{}}
	end if

	sequence row = sqlite3_fetch_row( stmt )

	sqlite3_finalize( stmt )

	return {SQLITE_DONE,row}
end function

public function sqlite3_query_rows( atom db, sequence sql, object params = {} )

	atom result, stmt
	{result,stmt} = sqlite3_prepare16_v2( db, sql )

	if result != SQLITE_OK then
		return {result,NULL}
	end if

	if atom( params ) then
		params = {params}
	end if

	for i = 1 to length( params ) do

		if atom( params[i] ) or length( params[i] ) != 2 then
			params[i] = {params[i]}
		end if

		object param_value = params[i][1]
		integer param_type = SQLITE_NULL

		if length( params[i] ) = 2   then param_type  = params[i][2]
		elsif integer( param_value ) then param_type = SQLITE_INTEGER
		elsif atom( param_value )    then param_type = SQLITE_FLOAT
		elsif string( param_value )  then param_type = SQLITE_TEXT
		else                              param_type = SQLITE_BLOB
		end if

		switch param_type do
			case SQLITE_INTEGER then sqlite3_bind_int( stmt, i, param_value )
			case SQLITE_FLOAT   then sqlite3_bind_double( stmt, i, param_value )
			case SQLITE_TEXT    then sqlite3_bind_text( stmt, i, param_value )
			case SQLITE_BLOB    then sqlite3_bind_blob( stmt, i, param_value )
		end switch

	end for

	sequence rows = {}

	while result = SQLITE_ROW with entry do
		rows = append( rows, sqlite3_fetch_row(stmt) )
	entry
		result = sqlite3_step( stmt )
	end while

	sqlite3_finalize( stmt )

	return {result,rows}
end function

public function sqlite3_query_map( atom db, sequence sql, object params = {} )

	atom result, stmt
	{result,stmt} = sqlite3_prepare16_v2( db, sql )

	if result != SQLITE_OK then
		return {result,NULL}
	end if

	sqlite3_assign_params( stmt, params )

	result = sqlite3_step( stmt )

	if result != SQLITE_ROW then
		sqlite3_finalize( stmt )
		return {result,NULL}
	end if

	object map = sqlite3_fetch_map( stmt )

	sqlite3_finalize( stmt )

	return {SQLITE_DONE,map}
end function

include mvc/logger.e

procedure sqlite3_cleanup_maps( sequence maps )

	for i = 1 to length( maps ) do
		log_trace( "delete map %d", maps[i] )
		delete( maps[i] )
	end for

end procedure

public function sqlite3_query_maps( atom db, sequence sql, object params = {} )

	atom result, stmt
	{result,stmt} = sqlite3_prepare16_v2( db, sql )

	if result != SQLITE_OK then
		return {result,{}}
	end if

	sqlite3_assign_params( stmt, params )

	sequence maps = {}

	while result = SQLITE_ROW with entry do
		maps = append( maps, sqlite3_fetch_map(stmt) )
	entry
		result = sqlite3_step( stmt )
	end while

	sqlite3_finalize( stmt )

	maps = delete_routine( maps, routine_id("sqlite3_cleanup_maps") )

	return {result,maps}
end function

public function sqlite3_fetch_map( atom stmt )

	integer count = sqlite3_column_count( stmt )

	map m = map:new()

	for i = 1 to count do

		integer column_type = sqlite3_column_type( stmt, i-1 )
		sequence column_name = sqlite3_column_name( stmt, i-1 )
		object column_value = NULL

		switch column_type do

			case SQLITE_INTEGER then
				column_value = sqlite3_column_int( stmt, i-1 )

			case SQLITE_FLOAT then
				column_value = sqlite3_column_double( stmt, i-1 )

			case SQLITE_BLOB then
				column_value = sqlite3_column_blob( stmt, i-1 )

			case SQLITE_TEXT then
				column_value = sqlite3_column_text( stmt, i-1 )

		end switch

		map:put( m, column_name, column_value )

	end for

	return m
end function

public function sqlite3_create_function( atom db, sequence name, integer args, sequence func,
		sequence step = "", sequence final = "", integer encoding = SQLITE_UTF8, atom userData = NULL,
		integer func_id = routine_id(func), integer step_id = routine_id(step),
		integer final_id = routine_id(final) )

	atom func_cb = call_back( func_id )
	atom step_cb = call_back( step_id )
	atom final_cb = call_back( final_id )

	return c_func( _sqlite3_create_function, {db,allocate_string(name,TRUE),
		args,encoding,userData,func_cb,step_cb,final_cb} )
end function

public function sqlite3_create_function16( atom db, sequence name, integer args, sequence func,
		sequence step = "", sequence final = "", integer encoding = SQLITE_UTF16, atom userData = NULL,
		integer func_id = routine_id(func), integer step_id = routine_id(step),
		integer final_id = routine_id(final) )

	atom func_cb = call_back( func_id )
	atom step_cb = call_back( step_id )
	atom final_cb = call_back( final_id )

	return c_func( _sqlite3_create_function16, {db,allocate_wstring(name,TRUE),
		args,encoding,userData,func_cb,step_cb,final_cb} )
end function

public function sqlite3_create_function_v2( atom db, sequence name, integer args, sequence func,
		sequence step = "", sequence final = "", sequence destroy = "", integer encoding = SQLITE_UTF8,
		atom userData = NULL, integer func_id = routine_id(func), integer step_id = routine_id(step),
		integer final_id = routine_id(final), integer destroy_id = routine_id(destroy) )

	atom func_cb = call_back( func_id )
	atom step_cb = call_back( step_id )
	atom final_cb = call_back( final_id )
	atom destroy_cb = call_back( destroy_id )

	return c_func( _sqlite3_create_function_v2, {db,allocate_string(name,TRUE),
		args,encoding,userData,func_cb,step_cb,final_cb,destroy_cb} )
end function

public function sqlite3_create_window_function( atom db, sequence name, integer args, sequence func,
		sequence step = "", sequence final = "", sequence value = "", sequence destroy = "",
		integer encoding = SQLITE_UTF8, atom userData = NULL, integer func_id = routine_id(func),
		integer step_id = routine_id(step), integer final_id = routine_id(final),
		integer value_id = routine_id(value), integer destroy_id = routine_id(destroy) )

	atom func_cb = call_back( func_id )
	atom step_cb = call_back( step_id )
	atom final_cb = call_back( final_id )
	atom destroy_cb = call_back( destroy_id )

	return c_func( _sqlite3_create_window_function, {db,allocate_string(name,TRUE),
		args,encoding,userData,func_cb,step_cb,final_cb,destroy_cb} )
end function

public constant
	SQLITE_UTF8             = 1,    /* IMP: R-37514-35566 */
	SQLITE_UTF16LE          = 2,    /* IMP: R-03371-37637 */
	SQLITE_UTF16BE          = 3,    /* IMP: R-51971-34154 */
	SQLITE_UTF16            = 4,    /* Use native byte order */
	SQLITE_ANY              = 5,    /* Deprecated */
	SQLITE_UTF16_ALIGNED    = 8,    /* sqlite3_create_collation only */
$

public constant SQLITE_DETERMINISTIC = 0x800

public function sqlite3_value_blob( atom value )
	return c_func( _sqlite3_value_blob, {value} )
end function

public function sqlite3_value_double( atom value )
	return c_func( _sqlite3_value_double, {value} )
end function

public function sqlite3_value_int( atom value )
	return c_func( _sqlite3_value_int, {value} )
end function

public function sqlite3_value_int64( atom value )
	return c_func( _sqlite3_value_int64, {value} )
end function

public function sqlite3_value_pointer( atom value, sequence string )
	return c_func( _sqlite3_value_pointer, {value,allocate_string(string,TRUE)} )
end function

public function sqlite3_value_text( atom value )

	atom ptr = c_func( _sqlite3_value_text, {value} )

	if ptr then
		atom bytes = c_func( _sqlite3_value_bytes, {value} )
		return peek({ ptr, bytes })
	end if

	return ""
end function

public function sqlite3_value_text16( atom value )

	atom ptr = c_func( _sqlite3_value_text16, {value} )

	if ptr then
		atom bytes = c_func( _sqlite3_value_bytes16, {value} )
		return peek({ ptr, bytes })
	end if

	return ""
end function

public function sqlite3_value_text16le( atom value )

	atom ptr = c_func( _sqlite3_value_text16le, {value} )

	if ptr then
		integer bytes = c_func( _sqlite3_value_bytes16, {value} )
		return peek({ ptr, bytes })
	end if

	return {}
end function

public function sqlite3_value_text16be( atom value )

	atom ptr = c_func( _sqlite3_value_text16be, {value} )

	if ptr then
		integer bytes = c_func( _sqlite3_value_bytes16, {value} )
		return peek({ ptr, bytes })
	end if

	return {}
end function

public function sqlite3_value_bytes( atom value )
	return c_func( _sqlite3_value_bytes, {value} )
end function

public function sqlite3_value_bytes16( atom value )
	return c_func( _sqlite3_value_bytes16, {value} )
end function

public function sqlite3_value_type( atom value )
	return c_func( _sqlite3_value_type, {value} )
end function

public function sqlite3_value_numeric_type( atom value )
	return c_func( _sqlite3_value_numeric_type, {value} )
end function

public function sqlite3_value_nochange( atom value )
	return c_func( _sqlite3_value_nochange, {value} )
end function

public function sqlite3_value_frombind( atom value )
	return c_func( _sqlite3_value_frombind, {value} )
end function

public function sqlite3_value_subtype( atom value )
	return c_func( _sqlite3_value_subtype, {value} )
end function

public function sqlite3_aggregate_context( atom context, atom bytes )
	return c_func( _sqlite3_aggregate_context, {context,bytes} )
end function

public function sqlite3_user_data( atom context )
	return c_func( _sqlite3_user_data, {context} )
end function

public function sqlite3_context_db_handle( atom context )
	return c_func( _sqlite3_context_db_handle, {context} )
end function

public function sqlite3_get_auxdata( atom context, integer n )
	return c_func( _sqlite3_get_auxdata, {context,n} )
end function

public procedure sqlite3_set_auxdata( atom context, integer n, atom data, sequence func = "",
		integer func_id = routine_id(func) )

	atom func_cb = call_back( func_id )

	c_proc( _sqlite3_set_auxdata, {context,n,data,func_cb} )
end procedure

public constant
	SQLITE_STATIC       =  0,
	SQLITE_TRANSIENT    = -1,
$

public procedure sqlite3_result_blob( atom context, object value, integer bytes = length(value),
		sequence func = "", integer func_id =  routine_id(func) )

	atom func_cb = call_back( func_id )
	integer cleanup = FALSE

	if length( func ) = 0 and func_cb = NULL then
		func_cb = SQLITE_TRANSIENT
		cleanup = TRUE
	end if

	if sequence( value ) then
		value = allocate_data( value, cleanup )
	end if

	c_proc( _sqlite3_result_blob, {context,value,bytes,func_cb} )

end procedure

public procedure sqlite3_result_blob64( atom context, object value, atom bytes = length(value),
		sequence func = "", integer func_id = routine_id(func) )

	atom func_cb = call_back( func_id )
	integer cleanup = FALSE

	if length( func ) = 0 and func_cb = NULL then
		func_cb = SQLITE_TRANSIENT
		cleanup = TRUE
	end if

	if sequence( value ) then
		value = allocate_data( value, cleanup )
	end if

	c_proc( _sqlite3_result_blob64, {context,value,bytes,func_cb} )

end procedure

public procedure sqlite3_result_double( atom context, atom value )
	c_proc( _sqlite3_result_double, {context,value} )
end procedure

public procedure sqlite3_result_error( atom context, sequence errmsg )
	c_proc( _sqlite3_result_error, {context,allocate_string(errmsg,TRUE),length(errmsg)} )
end procedure

public procedure sqlite3_result_error16( atom context, sequence errmsg )
	c_proc( _sqlite3_result_error16, {context,allocate_wstring(errmsg,TRUE),length(errmsg)*2} )
end procedure

public procedure sqlite3_result_error_toobig( atom context )
	c_proc( _sqlite3_result_error_toobig, {context} )
end procedure

public procedure sqlite3_result_error_nomem( atom context )
	c_proc( _sqlite3_result_error_nomem, {context} )
end procedure

public procedure sqlite3_result_error_code( atom context, integer errcode )
	c_proc( _sqlite3_result_error_code, {context,errcode} )
end procedure

public procedure sqlite3_result_int( atom context, atom value )
	c_proc( _sqlite3_result_int, {context,value} )
end procedure

public procedure sqlite3_result_int64( atom context, atom value )
	c_proc( _sqlite3_result_int64, {context,value} )
end procedure

public procedure sqlite3_result_null( atom context )
	c_proc( _sqlite3_result_null, {context} )
end procedure

public procedure sqlite3_result_text( atom context, sequence value, integer bytes = length(value),
		sequence func = "", integer func_id = routine_id(func) )

	atom func_cb = call_back( func_id )
	integer cleanup = FALSE

	if func_cb = NULL then
		func_cb = SQLITE_TRANSIENT
		cleanup = TRUE
	end if

	c_proc( _sqlite3_result_text, {context,allocate_string(value,cleanup),bytes,func_cb} )

end procedure

public procedure sqlite3_result_text64( atom context, sequence value, integer bytes = length(value)*2,
		sequence func = "", integer encoding = SQLITE_UTF8, integer func_id = routine_id(func) )

	atom func_cb = call_back( func_id )
	integer cleanup = FALSE

	if func_cb = NULL then
		func_cb = SQLITE_TRANSIENT
		cleanup = TRUE
	end if

	c_proc( _sqlite3_result_text64, {context,allocate_wstring(value,cleanup),bytes,func_cb,encoding} )

end procedure

public procedure sqlite3_result_text16le( atom context, sequence value, integer bytes = length(value),
		sequence func = "", integer func_id = routine_id(func) )

	atom func_cb = call_back( func_id )
	integer cleanup = FALSE

	if func_cb = NULL then
		func_cb = SQLITE_TRANSIENT
		cleanup = TRUE
	end if

	c_proc( _sqlite3_result_text16le, {context,allocate_data(value,cleanup),bytes,func_cb} )

end procedure


public procedure sqlite3_result_text16be( atom context, sequence value, integer bytes = length(value),
		sequence func = "", integer func_id = routine_id(func) )

	atom func_cb = call_back( func_id )
	integer cleanup = FALSE

	if func_cb = NULL then
		func_cb = SQLITE_TRANSIENT
		cleanup = TRUE
	end if

	c_proc( _sqlite3_result_text16be, {context,allocate_data(value,cleanup),bytes,func_cb} )

end procedure

public procedure sqlite3_result_value( atom context, atom value )
	c_proc( _sqlite3_result_value, {context,value} )
end procedure

public procedure sqlite3_result_pointer( atom context, atom pointer, sequence string, sequence func = "",
		integer func_id = routine_id(func) )

	atom func_cb = call_back( func_id )

	c_proc( _sqlite3_result_pointer, {context,pointer,allocate_string(string,TRUE),func_cb} )
end procedure

public procedure sqlite3_result_zeroblob( atom context, integer bytes )
	c_proc( _sqlite3_result_zeroblob, {context,bytes} )
end procedure

public function sqlite3_result_zeroblob64( atom context, atom bytes )
	return c_func( _sqlite3_result_zeroblob64, {context,bytes} )
end function

public procedure sqlite3_result_subtype( atom context, atom subtype )
	c_proc( _sqlite3_result_subtype, {context,subtype} )
end procedure

public function sqlite3_create_collation( atom db, sequence name, integer encoding, sequence compare_func,
		atom arg = NULL, integer compare_func_id = routine_id(compare_func) )

	return c_func( _sqlite3_create_collation, {db,allocate_string(name,TRUE),encoding,arg,
		call_back(compare_func_id)} )
end function

public function sqlite3_create_collation_v2( atom db, sequence name, integer encoding,
		sequence compare_func, sequence destroy_func, atom arg = NULL,
		integer compare_func_id = routine_id(compare_func),
		integer destroy_func_id = routine_id(destroy_func) )

	return c_func( _sqlite3_create_collation_v2, {db,allocate_string(name,TRUE),encoding,arg,
		call_back(compare_func_id),call_back(destroy_func_id)} )
end function

public function sqlite3_create_collation16( atom db, sequence name, integer encoding,
		sequence compare_func, atom arg = NULL, integer compare_func_id = routine_id(compare_func) )

	return c_func( _sqlite3_create_collation16, {db,allocate_wstring(name,TRUE),encoding,arg,
		call_back(compare_func_id)} )
end function

public function sqlite3_collation_needed( atom db, sequence func, atom arg = NULL,
		integer func_id = routine_id(func) )

	atom func_cb = call_back( func_id )

	return c_func( _sqlite3_collation_needed, {db,arg,func_cb} )
end function

public function sqlite3_collation_needed16( atom db, sequence func, atom arg = NULL,
		integer func_id = routine_id(func) )

	atom func_cb = call_back( func_id )

	return c_func( _sqlite3_collation_needed16, {db,arg,func_cb} )
end function

public function sqlite3_sleep( integer ms )
	return c_func( _sqlite3_sleep, {ms} )
end function

public sequence sqlite3_temp_directory = peek_string( _sqlite3_temp_directory )
public sequence sqlite3_data_directory = peek_string( _sqlite3_data_directory )

public function sqlite3_win32_set_directory( atom _type, sequence value )
	return c_func( _sqlite3_win32_set_directory, {_type,allocate_string(value,TRUE)} )
end function

public function sqlite3_win32_set_directory8( atom _type, sequence value )
	return c_func( _sqlite3_win32_set_directory8, {_type,allocate_string(value,TRUE)} )
end function

public function sqlite3_win32_set_directory16( atom _type, sequence value )
	return c_func( _sqlite3_win32_set_directory16, {_type,allocate_wstring(value,TRUE)} )
end function

public constant
	SQLITE_WIN32_DATA_DIRECTORY_TYPE = 1,
	SQLITE_WIN32_TEMP_DIRECTORY_TYPE = 2,
$

public function sqlite3_get_autocommit( atom db )
	return c_func( _sqlite3_get_autocommit, {db} )
end function

public function sqlite3_db_handle( atom sqlite3_stmt )
	return c_func( _sqlite3_db_handle, {sqlite3_stmt} )
end function

public function sqlite3_db_filename( atom db, sequence name )
	return peek_string( c_func( _sqlite3_db_filename, {db,allocate_string(name,TRUE)} ) )
end function

public function sqlite3_db_readonly( atom db, sequence name )
	return c_func( _sqlite3_db_readonly, {db,allocate_string(name,TRUE)} )
end function

public function sqlite3_next_stmt( atom db, atom stmt )
	return c_func( _sqlite3_next_stmt, {db,stmt} )
end function

public function sqlite3_commit_hook( atom db, sequence func, atom arg = NULL,
		integer func_id = routine_id(func) )

	atom func_cb = call_back( func_id )

	return c_func( _sqlite3_commit_hook, {db,func_cb,arg} )
end function

public function sqlite3_rollback_hook( atom db, sequence func, atom arg = NULL,
		integer func_id = routine_id(func) )

	atom func_cb = call_back( func_id )

	return c_func( _sqlite3_rollback_hook, {db,func_cb,arg} )
end function

public function sqlite3_enable_shared_cache( integer enable )
	return c_func( _sqlite3_enable_shared_cache, {enable} )
end function

public function sqlite3_release_memory( integer bytes )
	return c_func( _sqlite3_release_memory, {bytes} )
end function

public function sqlite3_db_release_memory( atom db )
	return c_func( _sqlite3_db_release_memory, {db} )
end function

deprecate
public procedure sqlite3_soft_heap_limit( atom limit )
	c_proc( _sqlite3_soft_heap_limit, {limit} )
end procedure

public function sqlite3_soft_heap_limit64( atom limit )
	return c_func( _sqlite3_soft_heap_limit64, {limit} )
end function

public function sqlite3_table_column_metadata( atom db, sequence db_name, sequence table_name,
		sequence column_name )

	atom zDbName     = allocate_string( db_name,     TRUE )
	atom zTableName  = allocate_string( table_name,  TRUE )
	atom zColumnName = allocate_string( column_name, TRUE )

	atom pzDataType  = allocate_data( sizeof(C_POINTER), TRUE )
	atom pzCollSeq   = allocate_data( sizeof(C_POINTER), TRUE )
	atom pNotNull    = allocate_data( sizeof(C_INT),     TRUE )
	atom pPrimaryKey = allocate_data( sizeof(C_INT),     TRUE )
	atom pAutoinc    = allocate_data( sizeof(C_INT),     TRUE )

	integer result = c_func( _sqlite3_table_column_metadata, {db,zDbName,zTableName,zColumnName,
		pzDataType,pzCollSeq,pNotNull,pPrimaryKey,pAutoinc} )

	if result = SQLITE_OK then

		sequence data_type  = peek_string( peek_pointer(pzDataType) )
		sequence coll_seq   = peek_string( peek_pointer(pzCollSeq) )
		integer not_null    = peek4s( pNotNull )
		integer primary_key = peek4s( pPrimaryKey )
		integer autoinc     = peek4s( pAutoinc )

		return {data_type,coll_seq,not_null,primary_key,autoinc}
	end if

	return result
end function

public function sqlite3_load_extension( atom db, sequence file, sequence proc = "" )
	return c_func( _sqlite3_load_extension, {db,allocate_string(file,TRUE),allocate_string(proc,TRUE)} )
end function

public function sqlite3_enable_load_extension( atom db, integer onoff )
	return c_func( _sqlite3_enable_load_extension, {db,onoff} )
end function

public function sqlite3_auto_extension( atom entry_point )
	return c_func( _sqlite3_auto_extension, {entry_point} )
end function

public function sqlite3_cancel_auto_extension( atom entry_point )
	return c_func( _sqlite3_cancel_auto_extension, {entry_point} )
end function

public procedure sqlite3_reset_auto_extension()
	c_proc( _sqlite3_reset_auto_extension, {} )
end procedure

public constant SQLITE_INDEX_SCAN_UNIQUE = 1

public constant
	SQLITE_INDEX_CONSTRAINT_EQ          =   2,
	SQLITE_INDEX_CONSTRAINT_GT          =   4,
	SQLITE_INDEX_CONSTRAINT_LE          =   8,
	SQLITE_INDEX_CONSTRAINT_LT          =  16,
	SQLITE_INDEX_CONSTRAINT_GE          =  32,
	SQLITE_INDEX_CONSTRAINT_MATCH       =  64,
	SQLITE_INDEX_CONSTRAINT_LIKE        =  65,
	SQLITE_INDEX_CONSTRAINT_GLOB        =  66,
	SQLITE_INDEX_CONSTRAINT_REGEXP      =  67,
	SQLITE_INDEX_CONSTRAINT_NE          =  68,
	SQLITE_INDEX_CONSTRAINT_ISNOT       =  69,
	SQLITE_INDEX_CONSTRAINT_ISNOTNULL   =  70,
	SQLITE_INDEX_CONSTRAINT_ISNULL      =  71,
	SQLITE_INDEX_CONSTRAINT_IS          =  72,
	SQLITE_INDEX_CONSTRAINT_FUNCTION    = 150,
$

public function sqlite3_create_module( atom db, sequence name, atom module, object client_data = NULL )
	return c_func( _sqlite3_create_module, {db,allocate_string(name,TRUE),module,client_data} )
end function

public function sqlite3_create_module_v2( atom db, sequence name, atom module, sequence func,
		object client_data = NULL, integer func_id = routine_id(func) )

	atom func_cb = call_back( func_id )

	return c_func( _sqlite3_create_module_v2, {db,allocate_string(name,TRUE),module,client_data,func_cb} )
end function

public function sqlite3_declare_vtab( atom db, sequence name )
	return c_func( _sqlite3_declare_vtab, {db,allocate_string(name,TRUE)} )
end function

public function sqlite3_overload_function( atom db, sequence name, integer args )
	return c_func( _sqlite3_overload_function, {db,allocate_string(name,TRUE),args} )
end function

public function sqlite3_blob_open( atom db, sequence db_name, sequence table_name, sequence column_name,
		atom rowid, integer flags = 0 )

	atom zDb     = allocate_string( db_name,     TRUE )
	atom zTable  = allocate_string( table_name,  TRUE )
	atom zColumn = allocate_string( column_name, TRUE )
	atom ppBlob  = allocate_data( sizeof(C_POINTER), TRUE )

	integer result = c_func( _sqlite3_blob_open, {db,zDb,zTable,zColumn,rowid,flags,ppBlob} )

	if result = SQLITE_OK then
		return peek_pointer( ppBlob )
	end if

	return NULL
end function

public function sqlite3_blob_reopen( atom blob, atom rowid )
	return c_func( _sqlite3_blob_reopen, {blob,rowid} )
end function

public function sqlite3_blob_close( atom blob )
	return c_func( _sqlite3_blob_close, {blob} )
end function

public function sqlite3_blob_bytes( atom blob )
	return c_func( _sqlite3_blob_bytes, {blob} )
end function

public function sqlite3_blob_read( atom blob, integer bytes, integer offset = 0 )

	atom buffer = allocate_data( bytes, TRUE )

	integer result = c_func( _sqlite3_blob_read, {blob,buffer,bytes,offset} )

	if result = SQLITE_OK then
		return peek({ buffer, bytes })
	end if

	return result
end function

public function sqlite3_blob_write( atom blob, sequence data, integer offset = 0 )
	return c_func( _sqlite3_blob_write, {blob,allocate_data(data,TRUE),length(data),offset} )
end function

public function sqlite3_vfs_find( sequence name )
	return c_func( _sqlite3_vfs_find, {allocate_string(name,TRUE)} )
end function

public function sqlite3_vfs_register( atom vfs, integer default )
	return c_func( _sqlite3_vfs_register, {vfs,default} )
end function

public function sqlite3_vfs_unregister( atom vfs )
	return c_func( _sqlite3_vfs_unregister, {vfs} )
end function

public function sqlite3_file_control( atom db, sequence name, integer op, atom data = NULL )
	return c_func( _sqlite3_file_control, {db,allocate_string(name,TRUE),op,data} )
end function

public function sqlite3_keyword_count()
	return c_func( _sqlite3_keyword_count, {} )
end function

public function sqlite3_keyword_name( integer func )

	atom ppName = allocate_data( sizeof(C_POINTER), TRUE )
	atom pLen   = allocate_data( sizeof(C_INT),     TRUE )

	integer result = c_func( _sqlite3_keyword_name, {func,ppName,pLen} )

	if result = SQLITE_OK then

		atom ptr = peek_pointer( ppName )
		integer len = peek4s( pLen )

		return peek({ ptr, len })
	end if

	return ""
end function

public function sqlite3_keyword_check( sequence keyword )
	return c_func( _sqlite3_keyword_check, {allocate_string(keyword,TRUE),length(keyword)} )
end function

public function sqlite3_status( integer op, integer resetFlag = FALSE )

	atom pCurrent   = allocate_data( sizeof(C_INT), TRUE )
	atom pHighwater = allocate_data( sizeof(C_INT), TRUE )

	integer result = c_func( _sqlite3_status, {op,pCurrent,pHighwater,resetFlag} )

	if result = SQLITE_OK then
		return { peek4s(pCurrent), peek4s(pHighwater) }
	end if

	return result
end function

public function sqlite3_status64( integer op, integer resetFlag = FALSE )

	atom pCurrent   = allocate_data( sizeof(C_LONGLONG), TRUE )
	atom pHighwater = allocate_data( sizeof(C_LONGLONG), TRUE )

	integer result = c_func( _sqlite3_status64, {op,pCurrent,pHighwater,resetFlag} )

	if result = SQLITE_OK then
		return { peek8s(pCurrent), peek8s(pHighwater) }
	end if

	return result
end function

public constant
	SQLITE_STATUS_MEMORY_USED           = 0,
	SQLITE_STATUS_PAGECACHE_USED        = 1,
	SQLITE_STATUS_PAGECACHE_OVERFLOW    = 2,
	SQLITE_STATUS_SCRATCH_USED          = 3, /* NOT USED */
	SQLITE_STATUS_SCRATCH_OVERFLOW      = 4, /* NOT USED */
	SQLITE_STATUS_MALLOC_SIZE           = 5,
	SQLITE_STATUS_PARSER_STACK          = 6,
	SQLITE_STATUS_PAGECACHE_SIZE        = 7,
	SQLITE_STATUS_SCRATCH_SIZE          = 8, /* NOT USED */
	SQLITE_STATUS_MALLOC_COUNT          = 9,
$

public function sqlite3_db_status( atom db, integer op, integer resetFlag = FALSE )

	atom pCurrent   = allocate_data( sizeof(C_INT), TRUE )
	atom pHighwater = allocate_data( sizeof(C_INT), TRUE )

	integer result = c_func( _sqlite3_status, {db,op,pCurrent,pHighwater,resetFlag} )

	if result = SQLITE_OK then
		return { peek4s(pCurrent), peek4s(pHighwater) }
	end if

	return result
end function

public constant
	SQLITE_DBSTATUS_LOOKASIDE_USED      =  0,
	SQLITE_DBSTATUS_CACHE_USED          =  1,
	SQLITE_DBSTATUS_SCHEMA_USED         =  2,
	SQLITE_DBSTATUS_STMT_USED           =  3,
	SQLITE_DBSTATUS_LOOKASIDE_HIT       =  4,
	SQLITE_DBSTATUS_LOOKASIDE_MISS_SIZE =  5,
	SQLITE_DBSTATUS_LOOKASIDE_MISS_FULL =  6,
	SQLITE_DBSTATUS_CACHE_HIT           =  7,
	SQLITE_DBSTATUS_CACHE_MISS          =  8,
	SQLITE_DBSTATUS_CACHE_WRITE         =  9,
	SQLITE_DBSTATUS_DEFERRED_FKS        = 10,
	SQLITE_DBSTATUS_CACHE_USED_SHARED   = 11,
	SQLITE_DBSTATUS_CACHE_SPILL         = 12,
$

public function sqlite3_stmt_status( atom stmt, integer op, integer resetFlag = FALSE )
	return c_func( _sqlite3_stmt_status, {stmt,op,resetFlag} )
end function

public constant
	SQLITE_STMTSTATUS_FULLSCAN_STEP =  1,
	SQLITE_STMTSTATUS_SORT          =  2,
	SQLITE_STMTSTATUS_AUTOINDEX     =  3,
	SQLITE_STMTSTATUS_VM_STEP       =  4,
	SQLITE_STMTSTATUS_REPREPARE     =  5,
	SQLITE_STMTSTATUS_RUN           =  6,
	SQLITE_STMTSTATUS_MEMUSED       = 99,
$

public function sqlite3_backup_init( atom destDb, sequence destName, atom srcDb, sequence srcName )
	return c_func( _sqlite3_backup_init, {destDb,allocate_string(destName,TRUE),srcDb,
		allocate_string(srcName,TRUE)} )
end function

public function sqlite3_backup_step( atom backup, integer page )
	return c_func( _sqlite3_backup_step, {backup,page} )
end function

public function sqlite3_backup_finish( atom backup )
	return c_func( _sqlite3_backup_finish, {backup} )
end function

public function sqlite3_backup_remaining( atom backup )
	return c_func( _sqlite3_backup_remaining, {backup} )
end function

public function  sqlite3_backup_pagecount( atom backup )
	return c_func( _sqlite3_backup_pagecount, {backup} )
end function

public function sqlite3_backup( atom source_db, sequence destination_file, integer step=1, sequence source_name="main", sequence destination_name="main" )

	atom result, destination_db
	{result,destination_db} = sqlite3_open( destination_file )

	if result != SQLITE_OK then
		return result
	end if

	atom backup = sqlite3_backup_init(
		destination_db,
		destination_name,
		source_db,
		source_name
	)

	if backup = NULL then
		return NULL
	end if

	result = SQLITE_OK

	while result = SQLITE_OK do
		result = sqlite3_backup_step( backup, step )
	end while

	sqlite3_backup_finish( backup )
	sqlite3_close( destination_db )

	return result
end function

public function sqlite3_wal_hook( atom db, sequence func, atom arg = NULL,
		integer func_id = routine_id(func) )

	atom func_cb = call_back( func_id )

	return c_func( _sqlite3_wal_hook, {db,func_cb,arg} )
end function

public function sqlite3_wal_autocheckpoint( atom db, integer num )
	return c_func( _sqlite3_wal_autocheckpoint, {db,num} )
end function

public function sqlite3_wal_checkpoint( atom db, sequence name )
	return c_func( _sqlite3_wal_checkpoint, {db,allocate_string(name,TRUE)} )
end function

public function sqlite3_wal_checkpoint_v2( atom db, sequence name, integer mode )

	atom pnLog  = allocate_data( sizeof(C_INT), TRUE )
	atom pnCkpt = allocate_data( sizeof(C_INT), TRUE )

	integer result = c_func( _sqlite3_wal_checkpoint_v2, {db,allocate_string(name,TRUE),mode,pnLog,
		pnCkpt} )

	if result = SQLITE_OK then
		return { peek4s(pnLog), peek4s(pnCkpt) }
	end if

	return result
end function

public constant
	SQLITE_CHECKPOINT_PASSIVE   = 0,  /* Do as much as possible w/o blocking */
	SQLITE_CHECKPOINT_FULL      = 1,  /* Wait for writers, then checkpoint */
	SQLITE_CHECKPOINT_RESTART   = 2,  /* Like FULL but wait for for readers */
	SQLITE_CHECKPOINT_TRUNCATE  = 3,  /* Like RESTART but also truncate WAL */
$

public function sqlite3_db_cacheflush( atom db )
	return c_func( _sqlite3_db_cacheflush, {db} )
end function

public function sqlite3_system_errno( atom db )
	return c_func( _sqlite3_system_errno, {db} )
end function

public function sqlite3_serialize( atom db, sequence schema, integer flags )

	atom piSize = allocate_data( sizeof(C_LONGLONG), TRUE )

	atom result = c_func( _sqlite3_serialize, {db,allocate_string(schema,TRUE),piSize,flags} )

	if result != NULL then
		atom size = peek8s( piSize )
		return peek({ result, size })
	end if

	return result
end function

public constant SQLITE_SERIALIZE_NOCOPY = 0x001

public function sqlite3_deserialize( atom db, sequence schema, sequence data, integer flags )
	return c_func( _sqlite3_deserialize, {db,allocate_string(schema,TRUE),allocate_data(data,TRUE),
		length(data),length(data),flags} )
end function

public constant
	SQLITE_DESERIALIZE_FREEONCLOSE  = 1, /* Call sqlite3_free() on close */
	SQLITE_DESERIALIZE_RESIZEABLE   = 2, /* Resize using sqlite3_realloc64() */
	SQLITE_DESERIALIZE_READONLY     = 4, /* Database is read-only */
$


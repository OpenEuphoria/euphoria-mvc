
namespace curl_easy

include std/dll.e
include std/machine.e
include std/convert.e
include std/error.e

constant TRUE = 1
constant FALSE = 0

public include curl.e

export constant
	_curl_easy_init         = define_c_func( libcurl, "+curl_easy_init", {},C_POINTER ),
--	_curl_easy_setopt       = define_c_func( libcurl, "+curl_easy_setopt", {C_POINTER,C_INT,C_POINTER}, C_INT ),
	_curl_easy_setopt_long  = define_c_func( libcurl, "+curl_easy_setopt", {C_POINTER,C_INT,C_LONG}, C_INT ),
	_curl_easy_setopt_ptr   = define_c_func( libcurl, "+curl_easy_setopt", {C_POINTER,C_INT,C_POINTER}, C_INT ),
	_curl_easy_setopt_off_t = define_c_func( libcurl, "+curl_easy_setopt", {C_POINTER,C_INT,C_OFF_T}, C_INT ),
	_curl_easy_perform      = define_c_func( libcurl, "+curl_easy_perform", {C_POINTER}, C_INT ),
	_curl_easy_cleanup      = define_c_proc( libcurl, "+curl_easy_cleanup", {C_POINTER} ),
	_curl_easy_getinfo      = define_c_func( libcurl, "+curl_easy_getinfo", {C_POINTER,C_INT,C_POINTER}, C_INT ),
	_curl_easy_duphandle    = define_c_func( libcurl, "+curl_easy_duphandle", {C_POINTER}, C_POINTER ),
	_curl_easy_reset        = define_c_proc( libcurl, "+curl_easy_reset", {C_POINTER} ),
	_curl_easy_recv         = define_c_func( libcurl, "+curl_easy_recv", {C_POINTER,C_POINTER,C_SIZE_T,C_POINTER}, C_INT ),
	_curl_easy_send         = define_c_func( libcurl, "+curl_easy_send", {C_POINTER,C_POINTER,C_SIZE_T,C_POINTER}, C_INT ),
$

/* Flag bits in the curl_blob struct: */
public constant
	CURL_BLOB_COPY      = 1,
	CURL_BLOB_NOCOPY    = 0,
$

ifdef BITS64 then

constant
	curl_blob__data     =  0, -- void*
	curl_blob__len      =  8, -- size_t
	curl_blob__flags    = 16, -- unsigned int
	SIZEOF_CURL_BLOB    = 24,
$

elsedef -- BITS32

constant
	curl_blob__data     =  0, -- void*
	curl_blob__len      =  4, -- size_t
	curl_blob__flags    =  8, -- unsigned int
	SIZEOF_CURL_BLOB    = 12,
$

end ifdef

/*
 * NAME curl_easy_init()
 *
 * DESCRIPTION
 *
 */
public function curl_easy_init()
	return c_func( _curl_easy_init, {} )
end function

/*
 * NAME curl_easy_setopt_long()
 *
 * DESCRIPTION
 *
 */
public function curl_easy_setopt_long( atom curl, integer option, atom param )

	if not curlopttype_long( option ) then
		error:crash( "Invalid option for curl_easy_setopt_long: %s (%d)\n",
			{curlopt_name(option),option} )
	end if

	return c_func( _curl_easy_setopt_long, {curl,option,param} )
end function

/*
 * NAME curl_easy_setopt_objptr()
 *
 * DESCRIPTION
 *
 */
public function curl_easy_setopt_objptr( atom curl, integer option, atom param )

	if not curlopttype_objectpoint( option ) then
		error:crash( "Invalid option for curl_easy_setopt_ptr: %s (%d)\n",
			{curlopt_name(option),option} )
	end if

	return c_func( _curl_easy_setopt_ptr, {curl,option,param} )
end function

/*
 * NAME curl_easy_setopt_func()
 *
 * DESCRIPTION
 *
 */
public function curl_easy_setopt_func( atom curl, integer option, atom param )

	if not curlopttype_functionpoint( option ) then
		error:crash( "Invalid option for curl_easy_setopt_func: %s (%d)\n",
			{curlopt_name(option),option} )
	end if

	return c_func( _curl_easy_setopt_ptr, {curl,option,param} )
end function

/*
 * NAME curl_easy_setopt_off_t()
 *
 * DESCRIPTION
 *
 */
public function curl_easy_setopt_off_t( atom curl, integer option, atom param )

	if not curlopttype_off_t( option ) then
		error:crash( "Invalid option for curl_easy_setopt_off_t: %s (%d)\n",
			{curlopt_name(option),option} )
	end if

	return c_func( _curl_easy_setopt_off_t, {curl,option,param} )
end function

/*
 * NAME curl_easy_setopt_blob()
 *
 * DESCRIPTION
 *
 */
public function curl_easy_setopt_blob( atom curl, integer option, atom blob_data, atom blob_len, atom blob_flags = CURL_BLOB_NOCOPY )

	if not curlopttype_blob( option ) then
		error:crash( "Invalid option for curl_easy_setopt_blob: %s (%d)\n",
			{curlopt_name(option),option} )
	end if

	atom param = allocate_data( SIZEOF_CURL_BLOB )
	poke_pointer( param + curl_blob__data,  blob_data )
	poke_pointer( param + curl_blob__len,   blob_len )
	poke_pointer( param + curl_blob__flags, blob_flags )

	integer result = c_func( _curl_easy_setopt_ptr, {curl,option,param} )

	free( param )

	return result
end function

/*
 * NAME curl_easy_setopt_string()
 *
 * DESCRIPTION
 *
 */
public function curl_easy_setopt_string( atom curl, integer option, object param )

	if not curlopttype_stringpoint( option ) then
		error:crash( "Invalid option for curl_easy_setopt_string: %s (%d)\n",
			{curlopt_name(option),option} )
	end if

	if sequence( param ) then

		if option = CURLOPT_POSTFIELDS then
			option = CURLOPT_COPYPOSTFIELDS
		end if

		param = allocate_string( param, TRUE )

	end if

	return c_func( _curl_easy_setopt_ptr, {curl,option,param} )
end function

/*
 * NAME curl_easy_setopt_slist()
 *
 * DESCRIPTION
 *
 */
public function curl_easy_setopt_slist( atom curl, integer option, atom param )

	if not curlopttype_slistpoint( option ) then
		error:crash( "Invalid option for curl_easy_setopt_slist: %s (%d)\n",
			{curlopt_name(option),option} )
	end if

	return c_func( _curl_easy_setopt_ptr, {curl,option,param} )
end function

/*
 * NAME curl_easy_setopt_cbptr()
 *
 * DESCRIPTION
 *
 */
public function curl_easy_setopt_cbptr( atom curl, integer option, atom param )

	if not curlopttype_cbpoint( option ) then
		error:crash( "Invalid option for curl_easy_setopt_cbptr: %s (%d)\n",
			{curlopt_name(option),option} )
	end if

	return c_func( _curl_easy_setopt_ptr, {curl,option,param} )
end function

/*
 * NAME curl_easy_setopt_values()
 *
 * DESCRIPTION
 *
 */
public function curl_easy_setopt_values( atom curl, integer option, atom param )

	if not curlopttype_values( option ) then
		error:crash( "Invalid option for curl_easy_setopt_values: %s (%d)\n",
			{curlopt_name(option),option} )
	end if

	return c_func( _curl_easy_setopt_long, {curl,option,param} )
end function

/*
 * NAME curl_easy_perform()
 *
 * DESCRIPTION
 *
 */
public function curl_easy_perform( atom curl )
	return c_func( _curl_easy_perform, {curl} )
end function

/*
 * NAME curl_easy_cleanup()
 *
 * DESCRIPTION
 *
 */
public procedure curl_easy_cleanup( atom curl )
	c_proc( _curl_easy_cleanup, {curl} )
end procedure

/*
 * NAME curl_easy_getinfo()
 *
 * DESCRIPTION
 *
 * Request internal information from the curl session with this function.  The
 * third argument MUST be a pointer to a long, a pointer to a char * or a
 * pointer to a double (as the documentation describes elsewhere).  The data
 * pointed to will be filled in accordingly and can be relied upon only if the
 * function returns CURLE_OK.  This function is intended to get used *AFTER* a
 * performed transfer, all results from this function are undefined until the
 * transfer is completed.
 */

/*
 * NAME curl_easy_getinfo_string()
 *
 * DESCRIPTION
 *
 */
public function curl_easy_getinfo_string( atom curl, integer option )

	if not curlinfo_string( option ) then
		error:crash( "Invalid option for curl_easy_getinfo_string: %s (%d)\n",
			{curlinfo_name(option),option} )
	end if

	atom param = allocate_data( sizeof(C_POINTER), TRUE )
	integer result = c_func( _curl_easy_getinfo, {curl,option,param} )

	if result = CURLE_OK then

		atom ptr = peek_pointer( param )
		sequence string = ""

		if ptr != NULL then
			string = peek_string( ptr )
		end if

		return {result,string}
	end if

	return {result,""}
end function

/*
 * NAME curl_easy_getinfo_long()
 *
 * DESCRIPTION
 *
 */
public function curl_easy_getinfo_long( atom curl, integer option )

	if not curlinfo_long( option ) then
		error:crash( "Invalid option for curl_easy_getinfo_long: %s (%d)\n",
			{curlinfo_name(option),option} )
	end if

	atom param = allocate_data( sizeof(C_LONG), TRUE )
	integer result = c_func( _curl_easy_getinfo, {curl,option,param} )

	if result = CURLE_OK then
		atom value = peek4s( param )
		return {result,value}
	end if

	return {result,0}
end function

/*
 * NAME curl_easy_getinfo_double()
 *
 * DESCRIPTION
 *
 */
public function curl_easy_getinfo_double( atom curl, integer option )

	if not curlinfo_double( option ) then
		error:crash( "Invalid option for curl_easy_getinfo_double: %s (%d)\n",
			{curlinfo_name(option),option} )
	end if

	atom param = allocate_data( sizeof(C_DOUBLE), TRUE )
	integer result = c_func( _curl_easy_getinfo, {curl,option,param} )

	if result = CURLE_OK then
		sequence bytes = peek({ param, sizeof(C_DOUBLE) })
		atom value = float64_to_atom( bytes )
		
		return {result,value}
	end if

	return {result,0}
end function

/*
 * NAME curl_easy_getinfo_slist()
 *
 * DESCRIPTION
 *
 */
public function curl_easy_getinfo_slist( atom curl, integer option )

	if not curlinfo_slist( option ) then
		error:crash( "Invalid option for curl_easy_getinfo_slist: %s (%d)\n",
			{curlinfo_name(option),option} )
	end if

	atom param = allocate_data( sizeof(C_POINTER), TRUE )
	integer result = c_func( _curl_easy_getinfo, {curl,option,param} )

	if result = CURLE_OK then
		atom slist = peek_pointer( param )
		sequence value = curl_slist_values( slist )
		
		return {result,value}
	end if

	return {result,{}}
end function

/*
 * NAME curl_easy_getinfo_socket()
 *
 * DESCRIPTION
 *
 */
public function curl_easy_getinfo_socket( atom curl, integer option )

	if not curlinfo_socket( option ) then
		error:crash( "Invalid option for curl_easy_getinfo_socket: %s (%d)\n",
			{curlinfo_name(option),option} )
	end if

	atom param = allocate_data( sizeof(C_LONG), TRUE )
	integer result = c_func( _curl_easy_getinfo, {curl,option,param} )

	if result = CURLE_OK then
		atom value = peek4s( param )
		return {result,value}
	end if

	return {result,NULL}
end function

/*
 * NAME curl_easy_getinfo_off_t()
 *
 * DESCRIPTION
 *
 */
public function curl_easy_getinfo_off_t( atom curl, integer option )

	if not curlinfo_off_t( option ) then
		error:crash( "Invalid option for curl_easy_getinfo_off_t: %s (%d)\n",
			{curlinfo_name(option),option} )
	end if

	atom param = allocate_data( sizeof(C_LONGLONG), TRUE )
	integer result = c_func( _curl_easy_getinfo, {curl,option,param} )

	if result = CURLE_OK then
		atom value = peek8s( param )
		return {result,value}
	end if

	return {result,0}
end function

/*
 * NAME curl_easy_duphandle()
 *
 * DESCRIPTION
 *
 * Creates a new curl session handle with the same options set for the handle
 * passed in. Duplicating a handle could only be a matter of cloning data and
 * options, internal state info and things like persistent connections cannot
 * be transferred. It is useful in multithreaded applications when you can run
 * curl_easy_duphandle() for each new thread to avoid a series of identical
 * curl_easy_setopt() invokes in every thread.
 */
public function curl_easy_duphandle( atom curl )
	return c_func( _curl_easy_duphandle, {curl} )
end function

/*
 * NAME curl_easy_reset()
 *
 * DESCRIPTION
 *
 * Re-initializes a CURL handle to the default values. This puts back the
 * handle to the same state as it was in when it was just created.
 *
 * It does keep: live connections, the Session ID cache, the DNS cache and the
 * cookies.
 */
public procedure curl_easy_reset( atom curl )
	c_proc( _curl_easy_reset, {curl} )
end procedure

/*
 * NAME curl_easy_recv()
 *
 * DESCRIPTION
 *
 * Receives data from the connected socket. Use after successful
 * curl_easy_perform() with CURLOPT_CONNECT_ONLY option.
 */
public function curl_easy_recv( atom curl, integer buflen )

	atom buffer = allocate_data( buflen, TRUE )
	atom lenaddr = allocate_data( sizeof(C_SIZE_T), TRUE )

	atom result = c_func( _curl_easy_recv, {curl,buffer,buflen,lenaddr} )

	if result = CURLE_OK then
		atom len = peek_pointer( lenaddr )
		return peek({ buffer, len })
	end if

	return result
end function

/*
 * NAME curl_easy_send()
 *
 * DESCRIPTION
 *
 * Sends data over the connected socket. Use after successful
 * curl_easy_perform() with CURLOPT_CONNECT_ONLY option.
 */
public function curl_easy_send( atom curl, sequence data )

	integer buflen = length( data )
	atom buffer = allocate_data( buflen, TRUE )
	atom lenaddr = allocate_data( sizeof(C_SIZE_T), TRUE )

	poke( buffer, data )

	atom result = c_func( _curl_easy_send, {curl,buffer,buflen,lenaddr} )

	if result = CURLE_OK then
		return peek_pointer( lenaddr )
	end if

	return 0
end function


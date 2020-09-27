
namespace curl_urlapi

include std/dll.e
include std/machine.e

constant TRUE = 1
constant FALSE = 0

public include curl.e

export constant
	_curl_url           = define_c_func( libcurl, "+curl_url", {}, C_POINTER ),
	_curl_url_cleanup   = define_c_proc( libcurl, "+curl_url_cleanup", {C_POINTER} ),
	_curl_url_dup       = define_c_func( libcurl, "+curl_url_dup", {C_POINTER}, C_POINTER ),
	_curl_url_get       = define_c_func( libcurl, "+curl_url_get", {C_POINTER,C_INT,C_POINTER,C_UINT}, C_INT ),
	_curl_url_set       = define_c_func( libcurl, "+curl_url_set", {C_POINTER,C_INT,C_STRING,C_UINT}, C_INT ),
$

public enum type CURLUcode
	CURLUE_OK = 0,
	CURLUE_BAD_HANDLE,         /*  1 */
	CURLUE_BAD_PARTPOINTER,    /*  2 */
	CURLUE_MALFORMED_INPUT,    /*  3 */
	CURLUE_BAD_PORT_NUMBER,    /*  4 */
	CURLUE_UNSUPPORTED_SCHEME, /*  5 */
	CURLUE_URLDECODE,          /*  6 */
	CURLUE_OUT_OF_MEMORY,      /*  7 */
	CURLUE_USER_NOT_ALLOWED,   /*  8 */
	CURLUE_UNKNOWN_PART,       /*  9 */
	CURLUE_NO_SCHEME,          /* 10 */
	CURLUE_NO_USER,            /* 11 */
	CURLUE_NO_PASSWORD,        /* 12 */
	CURLUE_NO_OPTIONS,         /* 13 */
	CURLUE_NO_HOST,            /* 14 */
	CURLUE_NO_PORT,            /* 15 */
	CURLUE_NO_QUERY,           /* 16 */
	CURLUE_NO_FRAGMENT         /* 17 */
end type

public enum type CURLUPart
	CURLUPART_URL = 0,
	CURLUPART_SCHEME,
	CURLUPART_USER,
	CURLUPART_PASSWORD,
	CURLUPART_OPTIONS,
	CURLUPART_HOST,
	CURLUPART_PORT,
	CURLUPART_PATH,
	CURLUPART_QUERY,
	CURLUPART_FRAGMENT,
	CURLUPART_ZONEID /* added in 7.65.0 */
end type

public constant
	CURLU_DEFAULT_PORT       =    1, --  (1<<0) /* return default port number */
	CURLU_NO_DEFAULT_PORT    =    2, --  (1<<1) /* act as if no port number was set,
                                     --            if the port number matches the
                                     --            default for the scheme */
	CURLU_DEFAULT_SCHEME     =    4, --  (1<<2) /* return default scheme if
                                     --            missing */
	CURLU_NON_SUPPORT_SCHEME =    8, --  (1<<3) /* allow non-supported scheme */
	CURLU_PATH_AS_IS         =   16, --  (1<<4) /* leave dot sequences */
	CURLU_DISALLOW_USER      =   32, --  (1<<5) /* no user+password allowed */
	CURLU_URLDECODE          =   64, --  (1<<6) /* URL decode on get */
	CURLU_URLENCODE          =  128, --  (1<<7) /* URL encode on set */
	CURLU_APPENDQUERY        =  256, --  (1<<8) /* append a form style part */
	CURLU_GUESS_SCHEME       =  512, --  (1<<9) /* legacy curl-style guessing */
	CURLU_NO_AUTHORITY       = 1024, -- (1<<10) /* Allow empty authority when the
                                     --            scheme is unknown. */
$

/*
 * curl_url() creates a new CURLU handle and returns a pointer to it.
 * Must be freed with curl_url_cleanup().
 */
public function curl_url()
	return c_func( _curl_url, {} )
end function

/*
 * curl_url_cleanup() frees the CURLU handle and related resources used for
 * the URL parsing. It will not free strings previously returned with the URL
 * API.
 */
public procedure curl_url_cleanup( atom handle )
	c_func( _curl_url_cleanup, {handle} )
end procedure

/*
 * curl_url_dup() duplicates a CURLU handle and returns a new copy. The new
 * handle must also be freed with curl_url_cleanup().
 */
public function curl_url_dup( atom handle )
	return c_func( _curl_url_dup, {handle} )
end function

/*
 * curl_url_get() extracts a specific part of the URL from a CURLU
 * handle. Returns error code. The returned pointer MUST be freed with
 * curl_free() afterwards.
 */
public function curl_url_get( atom handle, integer what, atom flags )

	atom part = allocate_data( sizeof(C_POINTER), TRUE )
	integer result = c_func( _curl_url_get, {handle,what,part,flags} )

	if result = CURLUE_OK then

		atom ptr = peek_pointer( part )
		sequence string = ""

		if ptr != NULL then
			string = peek_string( ptr )
			c_proc( _curl_free, {ptr} )
		end if

		return string
	end if

	return NULL
end function

/*
 * curl_url_set() sets a specific part of the URL in a CURLU handle. Returns
 * error code. The passed in string will be copied. Passing a NULL instead of
 * a part string, clears that part.
 */
public function curl_url_set( atom handle, integer what, object part, atom flags )

	if sequence( part ) then
		part = allocate_string( part, TRUE )
	end if

	return c_func( _curl_url_set, {handle,what,part,flags} )
end function

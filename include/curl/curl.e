
namespace curl

include std/dll.e
include std/machine.e
include std/convert.e
include std/error.e

constant TRUE = 1
constant FALSE = 0

ifdef LINUX then
	export atom libcurl = open_dll( "libcurl.so.4" )

elsifdef WINDOWS then

	ifdef BITS64 then
	export atom libcurl = open_dll({ "libcurl-x64.dll", "libcurl.dll" })

	elsedef
	export atom libcurl = open_dll( "libcurl.dll" )

	end ifdef

elsedef
	error:crash( "Platform not supported" )

end ifdef

export constant C_OFF_T = C_LONGLONG
export constant C_STRING = C_POINTER
export constant C_TIME_T = C_INT

export constant
	_curl_strequal          = define_c_func( libcurl, "+curl_strequal", {C_POINTER,C_POINTER}, C_INT ),
	_curl_strnequal         = define_c_func( libcurl, "+curl_strnequal", {C_POINTER,C_POINTER,C_SIZE_T}, C_INT ),
	_curl_mime_init         = define_c_func( libcurl, "+curl_mime_init", {C_POINTER}, C_POINTER ),
	_curl_mime_free         = define_c_proc( libcurl, "+curl_mime_free", {C_POINTER} ),
	_curl_mime_addpart      = define_c_func( libcurl, "+curl_mime_addpart", {C_POINTER}, C_POINTER ),
	_curl_mime_name         = define_c_func( libcurl, "+curl_mime_name", {C_POINTER,C_STRING}, C_INT ),
	_curl_mime_filename     = define_c_func( libcurl, "+curl_mime_filename", {C_POINTER,C_STRING}, C_INT ),
	_curl_mime_type         = define_c_func( libcurl, "+curl_mime_type", {C_POINTER,C_STRING}, C_INT ),
	_curl_mime_encoder      = define_c_func( libcurl, "+curl_mime_encoder", {C_POINTER,C_STRING}, C_INT ),
	_curl_mime_data         = define_c_func( libcurl, "+curl_mime_data", {C_POINTER,C_STRING,C_SIZE_T}, C_INT ),
	_curl_mime_data_cb      = define_c_func( libcurl, "+curl_mime_data_cb", {C_POINTER,C_OFF_T,C_POINTER,C_POINTER,C_POINTER,C_POINTER}, C_INT ),
	_curl_mime_subparts     = define_c_func( libcurl, "+curl_mime_subparts", {C_POINTER,C_POINTER}, C_INT ),
	_curl_mime_headers      = define_c_func( libcurl, "+curl_mime_headers", {C_POINTER,C_POINTER,C_INT}, C_INT ),
	_curl_formadd           = define_c_func( libcurl, "+curl_formadd", {C_POINTER,C_POINTER,C_POINTER}, C_INT ),
	_curl_formget           = define_c_func( libcurl, "+curl_formget", {C_POINTER,C_POINTER,C_POINTER}, C_INT ),
	_curl_formfree          = define_c_proc( libcurl, "+curl_formfree", {C_POINTER} ),
	_curl_getenv            = define_c_func( libcurl, "+curl_getenv", {C_STRING}, C_STRING ),
	_curl_version           = define_c_func( libcurl, "+curl_version", {}, C_STRING ),
	_curl_easy_escape       = define_c_func( libcurl, "+curl_easy_escape", {C_POINTER,C_STRING,C_INT}, C_STRING ),
	_curl_escape            = define_c_func( libcurl, "+curl_escape", {C_STRING,C_INT}, C_STRING ),
	_curl_easy_unescape     = define_c_func( libcurl, "+curl_easy_unescape", {C_POINTER,C_STRING,C_INT,C_POINTER}, C_STRING ),
	_curl_unescape          = define_c_func( libcurl, "+curl_unescape", {C_STRING,C_INT}, C_STRING ),
	_curl_free              = define_c_proc( libcurl, "+curl_free", {C_POINTER} ),
	_curl_global_init       = define_c_func( libcurl, "+curl_global_init", {C_LONG}, C_INT ),
	_curl_global_init_mem   = define_c_func( libcurl, "+curl_global_init_mem", {C_LONG,C_POINTER,C_POINTER,C_POINTER,C_POINTER,C_POINTER}, C_INT ),
	_curl_global_cleanup    = define_c_proc( libcurl, "+curl_global_cleanup", {}  ),
	_curl_global_sslset     = define_c_func( libcurl, "+curl_global_sslset", {C_INT,C_STRING,C_POINTER}, C_INT ),
	_curl_slist_append      = define_c_func( libcurl, "+curl_slist_append", {C_POINTER,C_STRING}, C_POINTER ),
	_curl_slist_free_all    = define_c_proc( libcurl, "+curl_slist_free_all", {C_POINTER} ),
	_curl_getdate           = define_c_func( libcurl, "+curl_getdate", {C_STRING,C_POINTER}, C_TIME_T ),
	_curl_share_init        = define_c_func( libcurl, "+curl_share_init", {}, C_POINTER ),
	_curl_share_setopt      = define_c_func( libcurl, "+curl_share_setopt", {C_POINTER,C_INT,C_POINTER}, C_INT ),
	_curl_share_cleanup     = define_c_func( libcurl, "+curl_share_cleanup", {C_POINTER}, C_INT ),
	_curl_version_info      = define_c_func( libcurl, "+curl_version_info", {C_POINTER}, C_POINTER ),
	_curl_easy_strerror     = define_c_func( libcurl, "+curl_easy_strerror", {C_INT}, C_STRING ),
	_curl_share_strerror    = define_c_func( libcurl, "+curl_share_strerror", {C_INT}, C_STRING ),
	_curl_easy_pause        = define_c_func( libcurl, "+curl_easy_pause", {C_POINTER, C_INT}, C_INT ),
$

/* enum for the different supported SSL backends */
public enum type curl_sslbackend
	CURLSSLBACKEND_NONE            =  0,
	CURLSSLBACKEND_OPENSSL         =  1,
	CURLSSLBACKEND_GNUTLS          =  2,
	CURLSSLBACKEND_NSS             =  3,
	CURLSSLBACKEND_OBSOLETE4       =  4, /* Was QSOSSL. */
	CURLSSLBACKEND_GSKIT           =  5,
	CURLSSLBACKEND_POLARSSL        =  6,
	CURLSSLBACKEND_WOLFSSL         =  7,
	CURLSSLBACKEND_SCHANNEL        =  8,
	CURLSSLBACKEND_SECURETRANSPORT =  9,
	CURLSSLBACKEND_AXTLS           = 10,
	CURLSSLBACKEND_MBEDTLS         = 11
end type

/* aliases for library clones and renames */
public constant
	CURLSSLBACKEND_LIBRESSL  = CURLSSLBACKEND_OPENSSL,
	CURLSSLBACKEND_BORINGSSL = CURLSSLBACKEND_OPENSSL,
$

/* deprecated names: */
public constant
	CURLSSLBACKEND_CYASSL    = CURLSSLBACKEND_WOLFSSL,
	CURLSSLBACKEND_DARWINSSL = CURLSSLBACKEND_SECURETRANSPORT,
$

public constant
	/* specified content is a file name */
	CURL_HTTPPOST_FILENAME      =   1, -- (1<<0)
	/* specified content is a file name */
	CURL_HTTPPOST_READFILE      =   2, -- (1<<1)
	/* name is only stored pointer do not free in formfree */
	CURL_HTTPPOST_PTRNAME       =   4, -- (1<<2)
	/* contents is only stored pointer do not free in formfree */
	CURL_HTTPPOST_PTRCONTENTS   =   8, -- (1<<3)
	/* upload file from buffer */
	CURL_HTTPPOST_BUFFER        =  16, -- (1<<4)
	/* upload file from pointer contents */
	CURL_HTTPPOST_PTRBUFFER     =  32, -- (1<<5)
	/* upload file contents by using the regular read callback to
       get the data and pass the given pointer as custom pointer */
	CURL_HTTPPOST_CALLBACK      =  64, -- (1<<6)
	/* use size in 'contentlen', added in 7.46.0 */
	CURL_HTTPPOST_LARGE       	= 128, -- (1<<7)
$

/* This is a return code for the progress callback that, when returned, will
   signal libcurl to continue executing the default progress function */
public constant CURL_PROGRESSFUNC_CONTINUE = #10000001

/* The maximum receive buffer size configurable via CURLOPT_BUFFERSIZE. */
public constant CURL_MAX_READ_SIZE = 524288

/* Tests have proven that 20K is a very bad buffer size for uploads on
   Windows, while 16K for some odd reason performed a lot better.
   The practical minimum is about 400 bytes since libcurl uses a buffer
   of this size as a scratch area (unrelated to network send operations). */
public constant CURL_MAX_WRITE_SIZE = 16384

/* The only reason to have a max limit for this is to avoid the risk of a bad
   server feeding libcurl with a never-ending header that will cause reallocs
   infinitely */
public constant CURL_MAX_HTTP_HEADER = (100*1024)

/* This is a magic return code for the write callback that, when returned,
   will signal libcurl to pause receiving on the current transfer. */
public constant CURL_WRITEFUNC_PAUSE = #10000001

/* enumeration of file types */
public enum type curlfiletype
	CURLFILETYPE_FILE         = 0,
	CURLFILETYPE_DIRECTORY    = 1,
	CURLFILETYPE_SYMLINK      = 2,
	CURLFILETYPE_DEVICE_BLOCK = 3,
	CURLFILETYPE_DEVICE_CHAR  = 4,
	CURLFILETYPE_NAMEDPIPE    = 5,
	CURLFILETYPE_SOCKET       = 6,
	CURLFILETYPE_DOOR         = 7,
	CURLFILETYPE_UNKNOWN      = 8
end type

public constant
	CURLFINFOFLAG_KNOWN_FILENAME   =   1, -- (1<<0)
	CURLFINFOFLAG_KNOWN_FILETYPE   =   2, -- (1<<1)
	CURLFINFOFLAG_KNOWN_TIME       =   4, -- (1<<2)
	CURLFINFOFLAG_KNOWN_PERM       =   8, -- (1<<3)
	CURLFINFOFLAG_KNOWN_UID        =  16, -- (1<<4)
	CURLFINFOFLAG_KNOWN_GID        =  32, -- (1<<5)
	CURLFINFOFLAG_KNOWN_SIZE       =  64, -- (1<<6)
	CURLFINFOFLAG_KNOWN_HLINKCOUNT = 128, -- (1<<7)
$

/* return codes for CURLOPT_CHUNK_BGN_FUNCTION */
public constant
	CURL_CHUNK_BGN_FUNC_OK   = 0,
	CURL_CHUNK_BGN_FUNC_FAIL = 1,
	CURL_CHUNK_BGN_FUNC_SKIP = 2,
$

/* return codes for CURLOPT_CHUNK_END_FUNCTION */
public constant
	CURL_CHUNK_END_FUNC_OK   = 0,
	CURL_CHUNK_END_FUNC_FAIL = 1,
$

/* return codes for FNMATCHFUNCTION */
public constant
	CURL_FNMATCHFUNC_MATCH   = 0,
	CURL_FNMATCHFUNC_NOMATCH = 1,
	CURL_FNMATCHFUNC_FAIL    = 2,
$

/* These are the return codes for the seek callbacks */
public constant
	CURL_SEEKFUNC_OK       = 0,
	CURL_SEEKFUNC_FAIL     = 1,
	CURL_SEEKFUNC_CANTSEEK = 2,
$

/* This is a return code for the read callback that, when returned, will
   signal libcurl to immediately abort the current transfer. */
public constant CURL_READFUNC_ABORT = #10000000

/* This is a return code for the read callback that, when returned, will
   signal libcurl to pause sending data on the current transfer. */
public constant CURL_READFUNC_PAUSE = #10000001

/* Return code for when the trailing headers' callback has terminated
   without any errors*/
public constant CURL_TRAILERFUNC_OK = 0

/* Return code for when was an error in the trailing header's list and we
   want to abort the request */
public constant CURL_TRAILERFUNC_ABORT = 1

public enum type curlsocktype
	CURL_SOCKTYPE_IPCXN  = 0, /* socket created for a specific IP connection */
	CURL_SOCKTYPE_ACCEPT = 1, /* socket created by accept() call */
	CURL_SOCKTYPE_LAST   = 2  /* never use */
end type

/* The return code from the sockopt_callback can signal information back
   to libcurl: */
public constant
	CURL_SOCKOPT_OK                = 0,
	CURL_SOCKOPT_ERROR             = 1, /* causes libcurl to abort and return
	                                       CURLE_ABORTED_BY_CALLBACK */
	CURL_SOCKOPT_ALREADY_CONNECTED = 2,
$


public enum type curlioerr
	CURLIOE_OK          = 0, /* I/O operation successful */
	CURLIOE_UNKNOWNCMD  = 1, /* command was unknown to callback */
	CURLIOE_FAILRESTART = 2, /* failed to restart the read */
	CURLIOE_LAST        = 3  /* never use */
end type

public enum type curliocmd
	CURLIOCMD_NOP         = 0, /* no operation */
	CURLIOCMD_RESTARTREAD = 1, /* restart the read stream from start */
	CURLIOCMD_LAST        = 2  /* never use */
end type

/* the kind of data that is passed to information_callback */
public enum type curl_infotype
	CURLINFO_TEXT = 0,
	CURLINFO_HEADER_IN,    /* 1 */
	CURLINFO_HEADER_OUT,   /* 2 */
	CURLINFO_DATA_IN,      /* 3 */
	CURLINFO_DATA_OUT,     /* 4 */
	CURLINFO_SSL_DATA_IN,  /* 5 */
	CURLINFO_SSL_DATA_OUT, /* 6 */
	CURLINFO_END
end type

public enum type CURLcode
	CURLE_OK = 0,
	CURLE_UNSUPPORTED_PROTOCOL,    /* 1 */
	CURLE_FAILED_INIT,             /* 2 */
	CURLE_URL_MALFORMAT,           /* 3 */
	CURLE_NOT_BUILT_IN,            /* 4 - [was obsoleted in August 2007 for
	                                  7.17.0, reused in April 2011 for 7.21.5] */
	CURLE_COULDNT_RESOLVE_PROXY,   /* 5 */
	CURLE_COULDNT_RESOLVE_HOST,    /* 6 */
	CURLE_COULDNT_CONNECT,         /* 7 */
	CURLE_WEIRD_SERVER_REPLY,      /* 8 */
	CURLE_REMOTE_ACCESS_DENIED,    /* 9 a service was denied by the server
                                      due to lack of access - when login fails
                                      this is not returned. */
	CURLE_FTP_ACCEPT_FAILED,       /* 10 - [was obsoleted in April 2006 for
                                      7.15.4, reused in Dec 2011 for 7.24.0]*/
	CURLE_FTP_WEIRD_PASS_REPLY,    /* 11 */
	CURLE_FTP_ACCEPT_TIMEOUT,      /* 12 - timeout occurred accepting server
                                      [was obsoleted in August 2007 for 7.17.0,
                                      reused in Dec 2011 for 7.24.0]*/
	CURLE_FTP_WEIRD_PASV_REPLY,    /* 13 */
	CURLE_FTP_WEIRD_227_FORMAT,    /* 14 */
	CURLE_FTP_CANT_GET_HOST,       /* 15 */
	CURLE_HTTP2,                   /* 16 - A problem in the http2 framing layer.
                                      [was obsoleted in August 2007 for 7.17.0,
                                      reused in July 2014 for 7.38.0] */
	CURLE_FTP_COULDNT_SET_TYPE,    /* 17 */
	CURLE_PARTIAL_FILE,            /* 18 */
	CURLE_FTP_COULDNT_RETR_FILE,   /* 19 */
	CURLE_OBSOLETE20,              /* 20 - NOT USED */
	CURLE_QUOTE_ERROR,             /* 21 - quote command failure */
	CURLE_HTTP_RETURNED_ERROR,     /* 22 */
	CURLE_WRITE_ERROR,             /* 23 */
	CURLE_OBSOLETE24,              /* 24 - NOT USED */
	CURLE_UPLOAD_FAILED,           /* 25 - failed upload "command" */
	CURLE_READ_ERROR,              /* 26 - couldn't open/read from file */
	CURLE_OUT_OF_MEMORY,           /* 27 */
	/* Note: CURLE_OUT_OF_MEMORY may sometimes indicate a conversion error
	         instead of a memory allocation error if CURL_DOES_CONVERSIONS
	         is defined
	 */
	CURLE_OPERATION_TIMEDOUT,      /* 28 - the timeout time was reached */
	CURLE_OBSOLETE29,              /* 29 - NOT USED */
	CURLE_FTP_PORT_FAILED,         /* 30 - FTP PORT operation failed */
	CURLE_FTP_COULDNT_USE_REST,    /* 31 - the REST command failed */
	CURLE_OBSOLETE32,              /* 32 - NOT USED */
	CURLE_RANGE_ERROR,             /* 33 - RANGE "command" didn't work */
	CURLE_HTTP_POST_ERROR,         /* 34 */
	CURLE_SSL_CONNECT_ERROR,       /* 35 - wrong when connecting with SSL */
	CURLE_BAD_DOWNLOAD_RESUME,     /* 36 - couldn't resume download */
	CURLE_FILE_COULDNT_READ_FILE,  /* 37 */
	CURLE_LDAP_CANNOT_BIND,        /* 38 */
	CURLE_LDAP_SEARCH_FAILED,      /* 39 */
	CURLE_OBSOLETE40,              /* 40 - NOT USED */
	CURLE_FUNCTION_NOT_FOUND,      /* 41 - NOT USED starting with 7.53.0 */
	CURLE_ABORTED_BY_CALLBACK,     /* 42 */
	CURLE_BAD_FUNCTION_ARGUMENT,   /* 43 */
	CURLE_OBSOLETE44,              /* 44 - NOT USED */
	CURLE_INTERFACE_FAILED,        /* 45 - CURLOPT_INTERFACE failed */
	CURLE_OBSOLETE46,              /* 46 - NOT USED */
	CURLE_TOO_MANY_REDIRECTS,      /* 47 - catch endless re-direct loops */
	CURLE_UNKNOWN_OPTION,          /* 48 - User specified an unknown option */
	CURLE_TELNET_OPTION_SYNTAX,    /* 49 - Malformed telnet option */
	CURLE_OBSOLETE50,              /* 50 - NOT USED */
	CURLE_OBSOLETE51,              /* 51 - NOT USED */
	CURLE_GOT_NOTHING,             /* 52 - when this is a specific error */
	CURLE_SSL_ENGINE_NOTFOUND,     /* 53 - SSL crypto engine not found */
	CURLE_SSL_ENGINE_SETFAILED,    /* 54 - can not set SSL crypto engine as
                                      default */
	CURLE_SEND_ERROR,              /* 55 - failed sending network data */
	CURLE_RECV_ERROR,              /* 56 - failure in receiving network data */
	CURLE_OBSOLETE57,              /* 57 - NOT IN USE */
	CURLE_SSL_CERTPROBLEM,         /* 58 - problem with the local certificate */
	CURLE_SSL_CIPHER,              /* 59 - couldn't use specified cipher */
	CURLE_PEER_FAILED_VERIFICATION,/* 60 - peer's certificate or fingerprint
                                      wasn't verified fine */
	CURLE_BAD_CONTENT_ENCODING,    /* 61 - Unrecognized/bad encoding */
	CURLE_LDAP_INVALID_URL,        /* 62 - Invalid LDAP URL */
	CURLE_FILESIZE_EXCEEDED,       /* 63 - Maximum file size exceeded */
	CURLE_USE_SSL_FAILED,          /* 64 - Requested FTP SSL level failed */
	CURLE_SEND_FAIL_REWIND,        /* 65 - Sending the data requires a rewind
                                      that failed */
	CURLE_SSL_ENGINE_INITFAILED,   /* 66 - failed to initialise ENGINE */
	CURLE_LOGIN_DENIED,            /* 67 - user, password or similar was not
                                      accepted and we failed to login */
	CURLE_TFTP_NOTFOUND,           /* 68 - file not found on server */
	CURLE_TFTP_PERM,               /* 69 - permission problem on server */
	CURLE_REMOTE_DISK_FULL,        /* 70 - out of disk space on server */
	CURLE_TFTP_ILLEGAL,            /* 71 - Illegal TFTP operation */
	CURLE_TFTP_UNKNOWNID,          /* 72 - Unknown transfer ID */
	CURLE_REMOTE_FILE_EXISTS,      /* 73 - File already exists */
	CURLE_TFTP_NOSUCHUSER,         /* 74 - No such user */
	CURLE_CONV_FAILED,             /* 75 - conversion failed */
	CURLE_CONV_REQD,               /* 76 - caller must register conversion
                                      callbacks using curl_easy_setopt options
                                      CURLOPT_CONV_FROM_NETWORK_FUNCTION,
                                      CURLOPT_CONV_TO_NETWORK_FUNCTION, and
                                      CURLOPT_CONV_FROM_UTF8_FUNCTION */
	CURLE_SSL_CACERT_BADFILE,      /* 77 - could not load CACERT file, missing
                                      or wrong format */
	CURLE_REMOTE_FILE_NOT_FOUND,   /* 78 - remote file not found */
	CURLE_SSH,                     /* 79 - error from the SSH layer, somewhat
                                      generic so the error message will be of
                                      interest when this has happened */
	CURLE_SSL_SHUTDOWN_FAILED,     /* 80 - Failed to shut down the SSL
                                      connection */
	CURLE_AGAIN,                   /* 81 - socket is not ready for send/recv,
                                      wait till it's ready and try again (Added
                                      in 7.18.2) */
	CURLE_SSL_CRL_BADFILE,         /* 82 - could not load CRL file, missing or
                                      wrong format (Added in 7.19.0) */
	CURLE_SSL_ISSUER_ERROR,        /* 83 - Issuer check failed.  (Added in
                                      7.19.0) */
	CURLE_FTP_PRET_FAILED,         /* 84 - a PRET command failed */
	CURLE_RTSP_CSEQ_ERROR,         /* 85 - mismatch of RTSP CSeq numbers */
	CURLE_RTSP_SESSION_ERROR,      /* 86 - mismatch of RTSP Session Ids */
	CURLE_FTP_BAD_FILE_LIST,       /* 87 - unable to parse FTP file list */
	CURLE_CHUNK_FAILED,            /* 88 - chunk callback reported error */
	CURLE_NO_CONNECTION_AVAILABLE, /* 89 - No connection available, the
                                      session will be queued */
	CURLE_SSL_PINNEDPUBKEYNOTMATCH,/* 90 - specified pinned public key did not
                                      match */
	CURLE_SSL_INVALIDCERTSTATUS,   /* 91 - invalid certificate status */
	CURLE_HTTP2_STREAM,            /* 92 - stream error in HTTP/2 framing layer
                                      */
	CURLE_RECURSIVE_API_CALL,      /* 93 - an api function was called from
                                      inside a callback */
	CURLE_AUTH_ERROR,              /* 94 - an authentication function returned an
                                      error */
	CURLE_HTTP3,                   /* 95 - An HTTP/3 layer problem */
	CURLE_QUIC_CONNECT_ERROR,      /* 96 - QUIC connection error */
	CURLE_PROXY,                   /* 97 - proxy handshake error */
	CURL_LAST /* never use! */
end type

ifdef not CURL_NO_OLDIES then /* define this to test if your app builds with all
	                             the obsolete stuff removed! */

public constant
	/* Previously obsolete error code re-used in 7.38.0 */
	CURLE_OBSOLETE16 = CURLE_HTTP2,

	/* Previously obsolete error codes re-used in 7.24.0 */
	CURLE_OBSOLETE10 = CURLE_FTP_ACCEPT_FAILED,
	CURLE_OBSOLETE12 = CURLE_FTP_ACCEPT_TIMEOUT,

	/*  compatibility with older names */
	CURLE_FTP_WEIRD_SERVER_REPLY = CURLE_WEIRD_SERVER_REPLY,

	/* The following were added in 7.62.0 */
	CURLE_SSL_CACERT = CURLE_PEER_FAILED_VERIFICATION,

	/* The following were added in 7.21.5, April 2011 */
	CURLE_UNKNOWN_TELNET_OPTION = CURLE_UNKNOWN_OPTION,

	/* The following were added in 7.17.1 */
	/* These are scheduled to disappear by 2009 */
	CURLE_SSL_PEER_CERTIFICATE = CURLE_PEER_FAILED_VERIFICATION,

	/* The following were added in 7.17.0 */
	/* These are scheduled to disappear by 2009 */
	CURLE_OBSOLETE                    = CURLE_OBSOLETE50, /* no one should be using this! */
	CURLE_BAD_PASSWORD_ENTERED        = CURLE_OBSOLETE46,
	CURLE_BAD_CALLING_ORDER           = CURLE_OBSOLETE44,
	CURLE_FTP_USER_PASSWORD_INCORRECT = CURLE_OBSOLETE10,
	CURLE_FTP_CANT_RECONNECT          = CURLE_OBSOLETE16,
	CURLE_FTP_COULDNT_GET_SIZE        = CURLE_OBSOLETE32,
	CURLE_FTP_COULDNT_SET_ASCII       = CURLE_OBSOLETE29,
	CURLE_FTP_WEIRD_USER_REPLY        = CURLE_OBSOLETE12,
	CURLE_FTP_WRITE_ERROR             = CURLE_OBSOLETE20,
	CURLE_LIBRARY_NOT_FOUND           = CURLE_OBSOLETE40,
	CURLE_MALFORMAT_USER              = CURLE_OBSOLETE24,
	CURLE_SHARE_IN_USE                = CURLE_OBSOLETE57,
	CURLE_URL_MALFORMAT_USER          = CURLE_NOT_BUILT_IN,

	CURLE_FTP_ACCESS_DENIED      = CURLE_REMOTE_ACCESS_DENIED,
	CURLE_FTP_COULDNT_SET_BINARY = CURLE_FTP_COULDNT_SET_TYPE,
	CURLE_FTP_QUOTE_ERROR        = CURLE_QUOTE_ERROR,
	CURLE_TFTP_DISKFULL          = CURLE_REMOTE_DISK_FULL,
	CURLE_TFTP_EXISTS            = CURLE_REMOTE_FILE_EXISTS,
	CURLE_HTTP_RANGE_ERROR       = CURLE_RANGE_ERROR,
	CURLE_FTP_SSL_FAILED         = CURLE_USE_SSL_FAILED,

	/* The following were added earlier */

	CURLE_OPERATION_TIMEOUTED = CURLE_OPERATION_TIMEDOUT,

	CURLE_HTTP_NOT_FOUND        = CURLE_HTTP_RETURNED_ERROR,
	CURLE_HTTP_PORT_FAILED      = CURLE_INTERFACE_FAILED,
	CURLE_FTP_COULDNT_STOR_FILE = CURLE_UPLOAD_FAILED,

	CURLE_FTP_PARTIAL_FILE        = CURLE_PARTIAL_FILE,
	CURLE_FTP_BAD_DOWNLOAD_RESUME = CURLE_BAD_DOWNLOAD_RESUME,

	/* This was the error code 50 in 7.7.3 and a few earlier versions, this
		is no longer used by libcurl but is instead public constantd here only to not
		make programs break */
	CURLE_ALREADY_COMPLETE = 99999,
$

end ifdef -- not CURL_NO_OLDIES

/*
 * Proxy error codes. Returned in CURLINFO_PROXY_ERROR if CURLE_PROXY was
 * return for the transfers.
 */
public enum type CURLproxycode
	CURLPX_OK = 0,
	CURLPX_BAD_ADDRESS_TYPE,
	CURLPX_BAD_VERSION,
	CURLPX_CLOSED,
	CURLPX_GSSAPI,
	CURLPX_GSSAPI_PERMSG,
	CURLPX_GSSAPI_PROTECTION,
	CURLPX_IDENTD,
	CURLPX_IDENTD_DIFFER,
	CURLPX_LONG_HOSTNAME,
	CURLPX_LONG_PASSWD,
	CURLPX_LONG_USER,
	CURLPX_NO_AUTH,
	CURLPX_RECV_ADDRESS,
	CURLPX_RECV_AUTH,
	CURLPX_RECV_CONNECT,
	CURLPX_RECV_REQACK,
	CURLPX_REPLY_ADDRESS_TYPE_NOT_SUPPORTED,
	CURLPX_REPLY_COMMAND_NOT_SUPPORTED,
	CURLPX_REPLY_CONNECTION_REFUSED,
	CURLPX_REPLY_GENERAL_SERVER_FAILURE,
	CURLPX_REPLY_HOST_UNREACHABLE,
	CURLPX_REPLY_NETWORK_UNREACHABLE,
	CURLPX_REPLY_NOT_ALLOWED,
	CURLPX_REPLY_TTL_EXPIRED,
	CURLPX_REPLY_UNASSIGNED,
	CURLPX_REQUEST_FAILED,
	CURLPX_RESOLVE_HOST,
	CURLPX_SEND_AUTH,
	CURLPX_SEND_CONNECT,
	CURLPX_SEND_REQUEST,
	CURLPX_UNKNOWN_FAIL,
	CURLPX_UNKNOWN_MODE,
	CURLPX_USER_REJECTED,
	CURLPX_LAST /* never use */
end type

/* this enum was added in 7.10 */
public enum type curl_proxytype
	CURLPROXY_HTTP            = 0, /* added in 7.10, new in 7.19.4 default is to use CONNECT HTTP/1.1 */
	CURLPROXY_HTTP_1_0        = 1, /* added in 7.19.4, force to use CONNECT HTTP/1.0  */
	CURLPROXY_HTTPS           = 2, /* added in 7.52.0 */
	CURLPROXY_SOCKS4          = 4, /* support added in 7.15.2, enum existed already in 7.10 */
	CURLPROXY_SOCKS5          = 5, /* added in 7.10 */
	CURLPROXY_SOCKS4A         = 6, /* added in 7.18.0 */
	CURLPROXY_SOCKS5_HOSTNAME = 7  /* Use the SOCKS5 protocol but pass along the host name rather than
	                                  the IP address. added in 7.18.0 */
end type

/*
 * Bitmasks for CURLOPT_HTTPAUTH and CURLOPT_PROXYAUTH options:
 *
 * CURLAUTH_NONE         - No HTTP authentication
 * CURLAUTH_BASIC        - HTTP Basic authentication (default)
 * CURLAUTH_DIGEST       - HTTP Digest authentication
 * CURLAUTH_NEGOTIATE    - HTTP Negotiate (SPNEGO) authentication
 * CURLAUTH_GSSNEGOTIATE - Alias for CURLAUTH_NEGOTIATE (deprecated)
 * CURLAUTH_NTLM         - HTTP NTLM authentication
 * CURLAUTH_DIGEST_IE    - HTTP Digest authentication with IE flavour
 * CURLAUTH_NTLM_WB      - HTTP NTLM authentication delegated to winbind helper
 * CURLAUTH_BEARER       - HTTP Bearer token authentication
 * CURLAUTH_ONLY         - Use together with a single other type to force no
 *                         authentication or just that single type
 * CURLAUTH_ANY          - All fine types set
 * CURLAUTH_ANYSAFE      - All fine types except Basic
 */

public constant
	CURLAUTH_NONE         =  0, -- ((unsigned long)0)
	CURLAUTH_BASIC        =  1, -- (((unsigned long)1)<<0)
	CURLAUTH_DIGEST       =  2, -- (((unsigned long)1)<<1)
	CURLAUTH_NEGOTIATE    =  4, -- (((unsigned long)1)<<2)
	/* Deprecated since the advent of CURLAUTH_NEGOTIATE */
	CURLAUTH_GSSNEGOTIATE = CURLAUTH_NEGOTIATE,
	/* Used for CURLOPT_SOCKS5_AUTH to stay terminologically correct */
	CURLAUTH_GSSAPI       = CURLAUTH_NEGOTIATE,
	CURLAUTH_NTLM         =  8, -- (((unsigned long)1)<<3)
	CURLAUTH_DIGEST_IE    = 16, -- (((unsigned long)1)<<4)
	CURLAUTH_NTLM_WB      = 32, -- (((unsigned long)1)<<5)
	CURLAUTH_BEARER       = 64, -- (((unsigned long)1)<<6)
	CURLAUTH_ONLY         = 2147483648, -- (((unsigned long)1)<<31)
	CURLAUTH_ANY          = not_bits(CURLAUTH_DIGEST_IE),
	CURLAUTH_ANYSAFE      = not_bits(or_bits(CURLAUTH_BASIC, CURLAUTH_DIGEST_IE)),
$

public constant
	CURLSSH_AUTH_ANY       = not_bits(0),  /* all types supported by the server */
	CURLSSH_AUTH_NONE      =  0,           /* none allowed, silly but complete */
	CURLSSH_AUTH_PUBLICKEY =  1, -- (1<<0) /* public/private key files */
	CURLSSH_AUTH_PASSWORD  =  2, -- (1<<1) /* password */
	CURLSSH_AUTH_HOST      =  4, -- (1<<2) /* host key files */
	CURLSSH_AUTH_KEYBOARD  =  8, -- (1<<3) /* keyboard interactive */
	CURLSSH_AUTH_AGENT     = 16, -- (1<<4) /* agent (ssh-agent, pageant...) */
	CURLSSH_AUTH_GSSAPI    = 32, -- (1<<5) /* gssapi (kerberos, ...) */
	CURLSSH_AUTH_DEFAULT   = CURLSSH_AUTH_ANY,
$

public constant
	CURLGSSAPI_DELEGATION_NONE        = 0,           /* no delegation (default) */
	CURLGSSAPI_DELEGATION_POLICY_FLAG = 1, -- (1<<0) /* if permitted by policy */
	CURLGSSAPI_DELEGATION_FLAG        = 2, -- (1<<1) /* delegate always */
$

public constant CURL_ERROR_SIZE = 256

public enum type curl_khtype
	CURLKHTYPE_UNKNOWN = 0,
	CURLKHTYPE_RSA1,
	CURLKHTYPE_RSA,
	CURLKHTYPE_DSS,
	CURLKHTYPE_ECDSA,
	CURLKHTYPE_ED25519
end type

/* this is the set of return values expected from the curl_sshkeycallback
   callback */
public enum type curl_khstat
	CURLKHSTAT_FINE_ADD_TO_FILE = 0,
	CURLKHSTAT_FINE,
	CURLKHSTAT_REJECT, /* reject the connection, return an error */
	CURLKHSTAT_DEFER,  /* do not accept it, but we can't answer right now so
                          this causes a CURLE_DEFER error but otherwise the
                          connection will be left intact etc */
  	CURLKHSTAT_FINE_REPLACE, /* accept and replace the wrong key*/
  	CURLKHSTAT_LAST    /* not for use, only a marker for last-in-list */
end type

public enum type curl_khmatch
	CURLKHMATCH_OK = 0, /* match */
	CURLKHMATCH_MISMATCH, /* host found, key mismatch! */
  	CURLKHMATCH_MISSING,  /* no matching host/key found */
  	CURLKHMATCH_LAST      /* not for use, only a marker for last-in-list */
end type

public enum type curl_usessl
	CURLUSESSL_NONE = 0, /* do not attempt to use SSL */
	CURLUSESSL_TRY,      /* try using SSL, proceed anyway otherwise */
	CURLUSESSL_CONTROL,  /* SSL for the control connection or fail */
	CURLUSESSL_ALL,      /* SSL for all communication or fail */
	CURLUSESSL_LAST      /* not an option, never use */
end type

/* Definition of bits for the CURLOPT_SSL_OPTIONS argument: */

/* - ALLOW_BEAST tells libcurl to allow the BEAST SSL vulnerability in the
   name of improving interoperability with older servers. Some SSL libraries
   have introduced work-arounds for this flaw but those work-arounds sometimes
   make the SSL communication fail. To regain functionality with those broken
   servers, a user can this way allow the vulnerability back. */
public constant CURLSSLOPT_ALLOW_BEAST = 1 -- (1<<0)

/* - NO_REVOKE tells libcurl to disable certificate revocation checks for those
   SSL backends where such behavior is present. */
public constant CURLSSLOPT_NO_REVOKE = 2 -- (1<<1)

/* - NO_PARTIALCHAIN tells libcurl to *NOT* accept a partial certificate chain
   if possible. The OpenSSL backend has this ability. */
public constant CURLSSLOPT_NO_PARTIALCHAIN = 4 -- (1<<2)

/* - REVOKE_BEST_EFFORT tells libcurl to ignore certificate revocation offline
   checks and ignore missing revocation list for those SSL backends where such
   behavior is present. */
public constant CURLSSLOPT_REVOKE_BEST_EFFORT = 8 -- (1<<3)

/* - CURLSSLOPT_NATIVE_CA tells libcurl to use standard certificate store of
   operating system. Currently implemented under MS-Windows. */
public constant CURLSSLOPT_NATIVE_CA = 16 -- (1<<4)

/* The default connection attempt delay in milliseconds for happy eyeballs.
   CURLOPT_HAPPY_EYEBALLS_TIMEOUT_MS.3 and happy-eyeballs-timeout-ms.d document
   this value, keep them in sync. */
public constant CURL_HET_DEFAULT = 200

/* The default connection upkeep interval in milliseconds. */
public constant CURL_UPKEEP_INTERVAL_DEFAULT = 60000

ifdef not CURL_NO_OLDIES then /* define this to test if your app builds with all
	                             the obsolete stuff removed! */

public enum type curl_ftpssl
	CURLFTPSSL_NONE = 0,
	CURLFTPSSL_TRY,
	CURLFTPSSL_CONTROL,
	CURLFTPSSL_ALL,
	CURLFTPSSL_LAST
end type

end ifdef -- not CURL_NO_OLDIES

/* parameter for the CURLOPT_FTP_SSL_CCC option */
public enum type curl_ftpccc
	CURLFTPSSL_CCC_NONE = 0, /* do not send CCC */
	CURLFTPSSL_CCC_PASSIVE,  /* Let the server initiate the shutdown */
	CURLFTPSSL_CCC_ACTIVE,   /* Initiate the shutdown */
	CURLFTPSSL_CCC_LAST      /* not an option, never use */
end type

/* parameter for the CURLOPT_FTPSSLAUTH option */
public enum type curl_ftpauth
	CURLFTPAUTH_DEFAULT = 0, /* let libcurl decide */
	CURLFTPAUTH_SSL,         /* use "AUTH SSL" */
	CURLFTPAUTH_TLS,         /* use "AUTH TLS" */
	CURLFTPAUTH_LAST         /* not an option, never use */
end type

/* parameter for the CURLOPT_FTP_CREATE_MISSING_DIRS option */
public enum type curl_ftpcreatedir
	CURLFTP_CREATE_DIR_NONE = 0, /* do NOT create missing dirs! */
	CURLFTP_CREATE_DIR,          /* (FTP/SFTP) if CWD fails, try MKD and then CWD
                                    again if MKD succeeded, for SFTP this does
                                    similar magic */
  	CURLFTP_CREATE_DIR_RETRY,    /* (FTP only) if CWD fails, try MKD and then CWD
                                    again even if MKD failed! */
  	CURLFTP_CREATE_DIR_LAST      /* not an option, never use */
end type

/* parameter for the CURLOPT_FTP_FILEMETHOD option */
public enum type curl_ftpmethod
	CURLFTPMETHOD_DEFAULT = 0, /* let libcurl pick */
	CURLFTPMETHOD_MULTICWD,    /* single CWD operation for each path part */
  	CURLFTPMETHOD_NOCWD,       /* no CWD at all */
	CURLFTPMETHOD_SINGLECWD,   /* one CWD to full dir, then work on file */
	CURLFTPMETHOD_LAST         /* not an option, never use */
end type

/* bitmask defines for CURLOPT_HEADEROPT */
public constant CURLHEADER_UNIFIED  = 0
public constant CURLHEADER_SEPARATE = 1 -- (1<<0)

/* CURLALTSVC_* are bits for the CURLOPT_ALTSVC_CTRL option */
public constant
	CURLALTSVC_IMMEDIATELY   = 1, -- (1<<0)
	CURLALTSVC_READONLYFILE =  4, -- (1<<2)
	CURLALTSVC_H1           =  8, -- (1<<3)
	CURLALTSVC_H2           = 16, -- (1<<4)
	CURLALTSVC_H3           = 32, -- (1<<5)
$

/* CURLPROTO_ defines are for the CURLOPT_*PROTOCOLS options */
public constant
	CURLPROTO_HTTP   =         1, -- (1<<0)
	CURLPROTO_HTTPS  =         2, -- (1<<1)
	CURLPROTO_FTP    =         4, -- (1<<2)
	CURLPROTO_FTPS   =         8, -- (1<<3)
	CURLPROTO_SCP    =        16, -- (1<<4)
	CURLPROTO_SFTP   =        32, -- (1<<5)
	CURLPROTO_TELNET =        64, -- (1<<6)
	CURLPROTO_LDAP   =       128, -- (1<<7)
	CURLPROTO_LDAPS  =       256, -- (1<<8)
	CURLPROTO_DICT   =       512, -- (1<<9)
	CURLPROTO_FILE   =      1024, -- (1<<10)
	CURLPROTO_TFTP   =      2048, -- (1<<11)
	CURLPROTO_IMAP   =      4096, -- (1<<12)
	CURLPROTO_IMAPS  =      8192, -- (1<<13)
	CURLPROTO_POP3   =     16384, -- (1<<14)
	CURLPROTO_POP3S  =     32768, -- (1<<15)
	CURLPROTO_SMTP   =     65536, -- (1<<16)
	CURLPROTO_SMTPS  =    131072, -- (1<<17)
	CURLPROTO_RTSP   =    262144, -- (1<<18)
	CURLPROTO_RTMP   =    524288, -- (1<<19)
	CURLPROTO_RTMPT  =   1048576, -- (1<<20)
	CURLPROTO_RTMPE  =   2097152, -- (1<<21)
	CURLPROTO_RTMPTE =   4194304, -- (1<<22)
	CURLPROTO_RTMPS  =   8388608, -- (1<<23)
	CURLPROTO_RTMPTS =  16777216, -- (1<<24)
	CURLPROTO_GOPHER =  33554432, -- (1<<25)
	CURLPROTO_SMB    =  67108864, -- (1<<26)
	CURLPROTO_SMBS   = 134217728, -- (1<<27)
	CURLPROTO_MQTT   = 268435456, -- (1<<28)
	CURLPROTO_ALL    = not_bits(0), /* enable everything */
$

/* long may be 32 or 64 bits, but we should never depend on anything else
   but 32 */
public constant
	CURLOPTTYPE_LONG          =     0,
	CURLOPTTYPE_OBJECTPOINT   = 10000,
	CURLOPTTYPE_FUNCTIONPOINT = 20000,
	CURLOPTTYPE_OFF_T         = 30000,
	CURLOPTTYPE_BLOB          = 40000,
$

public type curlopttype_long( integer x )
	return floor( x / 10000 ) = 0 -- floor( CURLOPTTYPE_LONG / 10000 )
end type

public type curlopttype_objectpoint( integer x )
	return floor( x / 10000 ) = 1 -- floor( CURLOPTTYPE_OBJECTPOINT / 10000 )
end type

public type curlopttype_functionpoint( integer x )
	return floor( x / 10000 ) = 2 -- floor( CURLOPTTYPE_FUNCTIONPOINT / 10000 )
end type

public type curlopttype_off_t( integer x )
	return floor( x / 10000 ) = 3 -- floor( CURLOPTTYPE_OFF_T / 10000 )
end type

public type curlopttype_blob( integer x )
	return floor( x / 10000 ) = 4 -- floor( CURLOPTTYPE_BLOB / 10000 )
end type

/* CURLOPT aliases that make no run-time difference */

/* *STRINGPOINT is an alias for OBJECTPOINT to allow tools to extract the
   string options from the header file */

/* 'char *' argument to a string with a trailing zero */
public constant CURLOPTTYPE_STRINGPOINT = CURLOPTTYPE_OBJECTPOINT

/* 'struct curl_slist *' argument */
public constant CURLOPTTYPE_SLISTPOINT = CURLOPTTYPE_OBJECTPOINT

/* 'void *' argument passed untouched to callback */
public constant CURLOPTTYPE_CBPOINT = CURLOPTTYPE_OBJECTPOINT

/* 'long' argument with a set of values/bitmask */
public constant CURLOPTTYPE_VALUES = CURLOPTTYPE_LONG

public type curlopttype_stringpoint( integer x )
	return curlopttype_objectpoint(x)
end type

public type curlopttype_slistpoint( integer x )
	return curlopttype_objectpoint(x)
end type

public type curlopttype_cbpoint( integer x )
	return curlopttype_objectpoint(x)
end type

public type curlopttype_values( integer x )
	return curlopttype_long(x)
end type

/*
 * All CURLOPT_* values.
 */

/* this should be as big or lager than CURLOPT_LASTENTRY */
constant CURLOPT_MAXVALUES = 300

sequence curlopt_names = repeat( 0, CURLOPT_MAXVALUES )

export function curlopt_name( integer opt )
	integer t = floor(opt / 10000)
	integer nu = opt - t * 10000
	return curlopt_names[nu]
end function

function CURLOPT( sequence na, integer t, integer nu )
	curlopt_names[nu] = na
	return t + nu
end function

public constant
	/* This is the FILE * or void * the regular output should be written to. */
	CURLOPT_WRITEDATA = CURLOPT("CURLOPT_WRITEDATA", CURLOPTTYPE_CBPOINT, 1),

	/* The full URL to get/put */
	CURLOPT_URL = CURLOPT("CURLOPT_URL", CURLOPTTYPE_STRINGPOINT, 2),

	/* Port number to connect to, if other than default. */
	CURLOPT_PORT = CURLOPT("CURLOPT_PORT", CURLOPTTYPE_LONG, 3),

	/* Name of proxy to use. */
	CURLOPT_PROXY = CURLOPT("CURLOPT_PROXY", CURLOPTTYPE_STRINGPOINT, 4),

	/* "user:password;options" to use when fetching. */
	CURLOPT_USERPWD = CURLOPT("CURLOPT_USERPWD", CURLOPTTYPE_STRINGPOINT, 5),

	/* "user:password" to use with proxy. */
	CURLOPT_PROXYUSERPWD = CURLOPT("CURLOPT_PROXYUSERPWD", CURLOPTTYPE_STRINGPOINT, 6),

	/* Range to get, specified as an ASCII string. */
	CURLOPT_RANGE = CURLOPT("CURLOPT_RANGE", CURLOPTTYPE_STRINGPOINT, 7),

	/* not used */

	/* Specified file stream to upload from (use as input): */
	CURLOPT_READDATA = CURLOPT("CURLOPT_READDATA", CURLOPTTYPE_CBPOINT, 9),

	/* Buffer to receive error messages in, must be at least CURL_ERROR_SIZE
	 * bytes big. */
	CURLOPT_ERRORBUFFER = CURLOPT("CURLOPT_ERRORBUFFER", CURLOPTTYPE_OBJECTPOINT, 10),

	/* Function that will be called to store the output (instead of fwrite). The
	 * parameters will use fwrite() syntax, make sure to follow them. */
	CURLOPT_WRITEFUNCTION = CURLOPT("CURLOPT_WRITEFUNCTION", CURLOPTTYPE_FUNCTIONPOINT, 11),

	/* Function that will be called to read the input (instead of fread). The
	 * parameters will use fread() syntax, make sure to follow them. */
	CURLOPT_READFUNCTION = CURLOPT("CURLOPT_READFUNCTION", CURLOPTTYPE_FUNCTIONPOINT, 12),

	/* Time-out the read operation after this amount of seconds */
	CURLOPT_TIMEOUT = CURLOPT("CURLOPT_TIMEOUT", CURLOPTTYPE_LONG, 13),

	/* If the CURLOPT_INFILE is used, this can be used to inform libcurl about
	 * how large the file being sent really is. That allows better error
	 * checking and better verifies that the upload was successful. -1 means
	 * unknown size.
	 *
	 * For large file support, there is also a _LARGE version of the key
	 * which takes an off_t type, allowing platforms with larger off_t
	 * sizes to handle larger files.  See below for INFILESIZE_LARGE.
	 */
	CURLOPT_INFILESIZE = CURLOPT("CURLOPT_INFILESIZE", CURLOPTTYPE_LONG, 14),

	/* POST static input fields. */
	CURLOPT_POSTFIELDS = CURLOPT("CURLOPT_POSTFIELDS", CURLOPTTYPE_OBJECTPOINT, 15),

	/* Set the referrer page (needed by some CGIs) */
	CURLOPT_REFERER = CURLOPT("CURLOPT_REFERER", CURLOPTTYPE_STRINGPOINT, 16),

	/* Set the FTP PORT string (interface name, named or numerical IP address)
	   Use i.e '-' to use default address. */
	CURLOPT_FTPPORT = CURLOPT("CURLOPT_FTPPORT", CURLOPTTYPE_STRINGPOINT, 17),

	/* Set the User-Agent string (examined by some CGIs) */
	CURLOPT_USERAGENT = CURLOPT("CURLOPT_USERAGENT", CURLOPTTYPE_STRINGPOINT, 18),

	/* If the download receives less than "low speed limit" bytes/second
	 * during "low speed time" seconds, the operations is aborted.
	 * You could i.e if you have a pretty high speed connection, abort if
	 * it is less than 2000 bytes/sec during 20 seconds.
	 */

	/* Set the "low speed limit" */
	CURLOPT_LOW_SPEED_LIMIT = CURLOPT("CURLOPT_LOW_SPEED_LIMIT", CURLOPTTYPE_LONG, 19),

	/* Set the "low speed time" */
	CURLOPT_LOW_SPEED_TIME = CURLOPT("CURLOPT_LOW_SPEED_TIME", CURLOPTTYPE_LONG, 20),

	/* Set the continuation offset.
	 *
	 * Note there is also a _LARGE version of this key which uses
	 * off_t types, allowing for large file offsets on platforms which
	 * use larger-than-32-bit off_t's.  Look below for RESUME_FROM_LARGE.
	 */
	CURLOPT_RESUME_FROM = CURLOPT("CURLOPT_RESUME_FROM", CURLOPTTYPE_LONG, 21),

	/* Set cookie in request: */
	CURLOPT_COOKIE = CURLOPT("CURLOPT_COOKIE", CURLOPTTYPE_STRINGPOINT, 22),

	/* This points to a linked list of headers, struct curl_slist kind. This
	   list is also used for RTSP (in spite of its name) */
	CURLOPT_HTTPHEADER = CURLOPT("CURLOPT_HTTPHEADER", CURLOPTTYPE_SLISTPOINT, 23),

	/* This points to a linked list of post entries, struct curl_httppost */
	CURLOPT_HTTPPOST = CURLOPT("CURLOPT_HTTPPOST", CURLOPTTYPE_OBJECTPOINT, 24),

	/* name of the file keeping your private SSL-certificate */
	CURLOPT_SSLCERT = CURLOPT("CURLOPT_SSLCERT", CURLOPTTYPE_STRINGPOINT, 25),

	/* password for the SSL or SSH private key */
	CURLOPT_KEYPASSWD = CURLOPT("CURLOPT_KEYPASSWD", CURLOPTTYPE_STRINGPOINT, 26),

	/* send TYPE parameter? */
	CURLOPT_CRLF = CURLOPT("CURLOPT_CRLF", CURLOPTTYPE_LONG, 27),

	/* send linked-list of QUOTE commands */
	CURLOPT_QUOTE = CURLOPT("CURLOPT_QUOTE", CURLOPTTYPE_SLISTPOINT, 28),

	/* send FILE * or void * to store headers to, if you use a callback it
	   is simply passed to the callback unmodified */
	CURLOPT_HEADERDATA = CURLOPT("CURLOPT_HEADERDATA", CURLOPTTYPE_CBPOINT, 29),

	/* point to a file to read the initial cookies from, also enables
	   "cookie awareness" */
	CURLOPT_COOKIEFILE = CURLOPT("CURLOPT_COOKIEFILE", CURLOPTTYPE_STRINGPOINT, 31),

	/* What version to specifically try to use.
	   See CURL_SSLVERSION defines below. */
	CURLOPT_SSLVERSION = CURLOPT("CURLOPT_SSLVERSION", CURLOPTTYPE_VALUES, 32),

	/* What kind of HTTP time condition to use, see defines */
	CURLOPT_TIMECONDITION = CURLOPT("CURLOPT_TIMECONDITION", CURLOPTTYPE_VALUES, 33),

	/* Time to use with the above condition. Specified in number of seconds
	   since 1 Jan 1970 */
	CURLOPT_TIMEVALUE = CURLOPT("CURLOPT_TIMEVALUE", CURLOPTTYPE_LONG, 34),

	/* 35 = OBSOLETE */

	/* Custom request, for customizing the get command like
	   HTTP: DELETE, TRACE and others
	   FTP: to use a different list command
	   */
	CURLOPT_CUSTOMREQUEST = CURLOPT("CURLOPT_CUSTOMREQUEST", CURLOPTTYPE_STRINGPOINT, 36),

	/* FILE handle to use instead of stderr */
	CURLOPT_STDERR = CURLOPT("CURLOPT_STDERR", CURLOPTTYPE_OBJECTPOINT, 37),

	/* 38 is not used */

	/* send linked-list of post-transfer QUOTE commands */
	CURLOPT_POSTQUOTE = CURLOPT("CURLOPT_POSTQUOTE", CURLOPTTYPE_SLISTPOINT, 39),

	 /* OBSOLETE, do not use! */
	CURLOPT_OBSOLETE40 = CURLOPT("CURLOPT_OBSOLETE40", CURLOPTTYPE_OBJECTPOINT, 40),

	/* talk a lot */
	CURLOPT_VERBOSE = CURLOPT("CURLOPT_VERBOSE", CURLOPTTYPE_LONG, 41),

	/* throw the header out too */
	CURLOPT_HEADER = CURLOPT("CURLOPT_HEADER", CURLOPTTYPE_LONG, 42),

	/* shut off the progress meter */
	CURLOPT_NOPROGRESS = CURLOPT("CURLOPT_NOPROGRESS", CURLOPTTYPE_LONG, 43),

	/* use HEAD to get http document */
	CURLOPT_NOBODY = CURLOPT("CURLOPT_NOBODY", CURLOPTTYPE_LONG, 44),

	/* no output on http error codes >= 400 */
	CURLOPT_FAILONERROR = CURLOPT("CURLOPT_FAILONERROR", CURLOPTTYPE_LONG, 45),

	/* this is an upload */
	CURLOPT_UPLOAD = CURLOPT("CURLOPT_UPLOAD", CURLOPTTYPE_LONG, 46),

	/* HTTP POST method */
	CURLOPT_POST = CURLOPT("CURLOPT_POST", CURLOPTTYPE_LONG, 47),

	/* bare names when listing directories */
	CURLOPT_DIRLISTONLY = CURLOPT("CURLOPT_DIRLISTONLY", CURLOPTTYPE_LONG, 48),

	/* Append instead of overwrite on upload! */
	CURLOPT_APPEND = CURLOPT("CURLOPT_APPEND", CURLOPTTYPE_LONG, 50),

	/* Specify whether to read the user+password from the .netrc or the URL.
	 * This must be one of the CURL_NETRC_* enums below. */
	CURLOPT_NETRC = CURLOPT("CURLOPT_NETRC", CURLOPTTYPE_VALUES, 51),

	/* use Location: Luke! */
	CURLOPT_FOLLOWLOCATION = CURLOPT("CURLOPT_FOLLOWLOCATION", CURLOPTTYPE_LONG, 52),

	 /* transfer data in text/ASCII format */
	CURLOPT_TRANSFERTEXT = CURLOPT("CURLOPT_TRANSFERTEXT", CURLOPTTYPE_LONG, 53),

	/* HTTP PUT */
	CURLOPT_PUT = CURLOPT("CURLOPT_PUT", CURLOPTTYPE_LONG, 54),

	/* 55 = OBSOLETE */

	/* DEPRECATED
	 * Function that will be called instead of the internal progress display
	 * function. This function should be defined as the curl_progress_callback
	 * prototype defines. */
	CURLOPT_PROGRESSFUNCTION = CURLOPT("CURLOPT_PROGRESSFUNCTION", CURLOPTTYPE_FUNCTIONPOINT, 56),

	/* Data passed to the CURLOPT_PROGRESSFUNCTION and CURLOPT_XFERINFOFUNCTION
	   callbacks */
	CURLOPT_XFERINFODATA = CURLOPT("CURLOPT_XFERINFODATA", CURLOPTTYPE_CBPOINT, 57),
	CURLOPT_PROGRESSDATA = CURLOPT_XFERINFODATA,

	/* We want the referrer field set automatically when following locations */
	CURLOPT_AUTOREFERER = CURLOPT("CURLOPT_AUTOREFERER", CURLOPTTYPE_LONG, 58),

	/* Port of the proxy, can be set in the proxy string as well with:
	   "[host]:[port]" */
	CURLOPT_PROXYPORT = CURLOPT("CURLOPT_PROXYPORT", CURLOPTTYPE_LONG, 59),

	/* size of the POST input data, if strlen() is not good to use */
	CURLOPT_POSTFIELDSIZE = CURLOPT("CURLOPT_POSTFIELDSIZE", CURLOPTTYPE_LONG, 60),

	/* tunnel non-http operations through a HTTP proxy */
	CURLOPT_HTTPPROXYTUNNEL = CURLOPT("CURLOPT_HTTPPROXYTUNNEL", CURLOPTTYPE_LONG, 61),

	/* Set the interface string to use as outgoing network interface */
	CURLOPT_INTERFACE = CURLOPT("CURLOPT_INTERFACE", CURLOPTTYPE_STRINGPOINT, 62),

	/* Set the krb4/5 security level, this also enables krb4/5 awareness.  This
	 * is a string, 'clear', 'safe', 'confidential' or 'private'.  If the string
	 * is set but doesn't match one of these, 'private' will be used.  */
	CURLOPT_KRBLEVEL = CURLOPT("CURLOPT_KRBLEVEL", CURLOPTTYPE_STRINGPOINT, 63),

	/* Set if we should verify the peer in ssl handshake, set 1 to verify. */
	CURLOPT_SSL_VERIFYPEER = CURLOPT("CURLOPT_SSL_VERIFYPEER", CURLOPTTYPE_LONG, 64),

	/* The CApath or CAfile used to validate the peer certificate
	   this option is used only if SSL_VERIFYPEER is true */
	CURLOPT_CAINFO = CURLOPT("CURLOPT_CAINFO", CURLOPTTYPE_STRINGPOINT, 65),

	/* 66 = OBSOLETE */
	/* 67 = OBSOLETE */

	/* Maximum number of http redirects to follow */
	CURLOPT_MAXREDIRS = CURLOPT("CURLOPT_MAXREDIRS", CURLOPTTYPE_LONG, 68),

	/* Pass a long set to 1 to get the date of the requested document (if
	   possible)! Pass a zero to shut it off. */
	CURLOPT_FILETIME = CURLOPT("CURLOPT_FILETIME", CURLOPTTYPE_LONG, 69),

	/* This points to a linked list of telnet options */
	CURLOPT_TELNETOPTIONS = CURLOPT("CURLOPT_TELNETOPTIONS", CURLOPTTYPE_SLISTPOINT, 70),

	/* Max amount of cached alive connections */
	CURLOPT_MAXCONNECTS = CURLOPT("CURLOPT_MAXCONNECTS", CURLOPTTYPE_LONG, 71),

	/* OBSOLETE, do not use! */
	CURLOPT_OBSOLETE72 = CURLOPT("CURLOPT_OBSOLETE72", CURLOPTTYPE_LONG, 72),

	/* 73 = OBSOLETE */

	/* Set to explicitly use a new connection for the upcoming transfer.
	   Do not use this unless you're absolutely sure of this, as it makes the
	   operation slower and is less friendly for the network. */
	CURLOPT_FRESH_CONNECT = CURLOPT("CURLOPT_FRESH_CONNECT", CURLOPTTYPE_LONG, 74),

	/* Set to explicitly forbid the upcoming transfer's connection to be re-used
	   when done. Do not use this unless you're absolutely sure of this, as it
	   makes the operation slower and is less friendly for the network. */
	CURLOPT_FORBID_REUSE = CURLOPT("CURLOPT_FORBID_REUSE", CURLOPTTYPE_LONG, 75),

	/* Set to a file name that contains random data for libcurl to use to
	   seed the random engine when doing SSL connects. */
	CURLOPT_RANDOM_FILE = CURLOPT("CURLOPT_RANDOM_FILE", CURLOPTTYPE_STRINGPOINT, 76),

	/* Set to the Entropy Gathering Daemon socket pathname */
	CURLOPT_EGDSOCKET = CURLOPT("CURLOPT_EGDSOCKET", CURLOPTTYPE_STRINGPOINT, 77),

	/* Time-out connect operations after this amount of seconds, if connects are
	   OK within this time, then fine... This only aborts the connect phase. */
	CURLOPT_CONNECTTIMEOUT = CURLOPT("CURLOPT_CONNECTTIMEOUT", CURLOPTTYPE_LONG, 78),

	/* Function that will be called to store headers (instead of fwrite). The
	 * parameters will use fwrite() syntax, make sure to follow them. */
	CURLOPT_HEADERFUNCTION = CURLOPT("CURLOPT_HEADERFUNCTION", CURLOPTTYPE_FUNCTIONPOINT, 79),

	/* Set this to force the HTTP request to get back to GET. Only really usable
	   if POST, PUT or a custom request have been used first.
	 */
	CURLOPT_HTTPGET = CURLOPT("CURLOPT_HTTPGET", CURLOPTTYPE_LONG, 80),

	/* Set if we should verify the Common name from the peer certificate in ssl
	 * handshake, set 1 to check existence, 2 to ensure that it matches the
	 * provided hostname. */
	CURLOPT_SSL_VERIFYHOST = CURLOPT("CURLOPT_SSL_VERIFYHOST", CURLOPTTYPE_LONG, 81),

	/* Specify which file name to write all known cookies in after completed
	   operation. Set file name to "-" (dash) to make it go to stdout. */
	CURLOPT_COOKIEJAR = CURLOPT("CURLOPT_COOKIEJAR", CURLOPTTYPE_STRINGPOINT, 82),

	/* Specify which SSL ciphers to use */
	CURLOPT_SSL_CIPHER_LIST = CURLOPT("CURLOPT_SSL_CIPHER_LIST", CURLOPTTYPE_STRINGPOINT, 83),

	/* Specify which HTTP version to use! This must be set to one of the
	   CURL_HTTP_VERSION* enums set below. */
	CURLOPT_HTTP_VERSION = CURLOPT("CURLOPT_HTTP_VERSION", CURLOPTTYPE_VALUES, 84),

	/* Specifically switch on or off the FTP engine's use of the EPSV command. By
	   default, that one will always be attempted before the more traditional
	   PASV command. */
	CURLOPT_FTP_USE_EPSV = CURLOPT("CURLOPT_FTP_USE_EPSV", CURLOPTTYPE_LONG, 85),

	/* type of the file keeping your SSL-certificate ("DER", "PEM", "ENG") */
	CURLOPT_SSLCERTTYPE = CURLOPT("CURLOPT_SSLCERTTYPE", CURLOPTTYPE_STRINGPOINT, 86),

	/* name of the file keeping your private SSL-key */
	CURLOPT_SSLKEY = CURLOPT("CURLOPT_SSLKEY", CURLOPTTYPE_STRINGPOINT, 87),

	/* type of the file keeping your private SSL-key ("DER", "PEM", "ENG") */
	CURLOPT_SSLKEYTYPE = CURLOPT("CURLOPT_SSLKEYTYPE", CURLOPTTYPE_STRINGPOINT, 88),

	/* crypto engine for the SSL-sub system */
	CURLOPT_SSLENGINE = CURLOPT("CURLOPT_SSLENGINE", CURLOPTTYPE_STRINGPOINT, 89),

	/* set the crypto engine for the SSL-sub system as default
	   the param has no meaning...
	 */
	CURLOPT_SSLENGINE_DEFAULT = CURLOPT("CURLOPT_SSLENGINE_DEFAULT", CURLOPTTYPE_LONG, 90),

	/* Non-zero value means to use the global dns cache */
	/* DEPRECATED, do not use! */
	CURLOPT_DNS_USE_GLOBAL_CACHE = CURLOPT("CURLOPT_DNS_USE_GLOBAL_CACHE", CURLOPTTYPE_LONG, 91),

	/* DNS cache timeout */
	CURLOPT_DNS_CACHE_TIMEOUT = CURLOPT("CURLOPT_DNS_CACHE_TIMEOUT", CURLOPTTYPE_LONG, 92),

	/* send linked-list of pre-transfer QUOTE commands */
	CURLOPT_PREQUOTE = CURLOPT("CURLOPT_PREQUOTE", CURLOPTTYPE_SLISTPOINT, 93),

	/* set the debug function */
	CURLOPT_DEBUGFUNCTION = CURLOPT("CURLOPT_DEBUGFUNCTION", CURLOPTTYPE_FUNCTIONPOINT, 94),

	/* set the data for the debug function */
	CURLOPT_DEBUGDATA = CURLOPT("CURLOPT_DEBUGDATA", CURLOPTTYPE_CBPOINT, 95),

	/* mark this as start of a cookie session */
	CURLOPT_COOKIESESSION = CURLOPT("CURLOPT_COOKIESESSION", CURLOPTTYPE_LONG, 96),

	/* The CApath directory used to validate the peer certificate
	   this option is used only if SSL_VERIFYPEER is true */
	CURLOPT_CAPATH = CURLOPT("CURLOPT_CAPATH", CURLOPTTYPE_STRINGPOINT, 97),

	/* Instruct libcurl to use a smaller receive buffer */
	CURLOPT_BUFFERSIZE = CURLOPT("CURLOPT_BUFFERSIZE", CURLOPTTYPE_LONG, 98),

	/* Instruct libcurl to not use any signal/alarm handlers, even when using
	   timeouts. This option is useful for multi-threaded applications.
	   See libcurl-the-guide for more background information. */
	CURLOPT_NOSIGNAL = CURLOPT("CURLOPT_NOSIGNAL", CURLOPTTYPE_LONG, 99),

	/* Provide a CURLShare for mutexing non-ts data */
	CURLOPT_SHARE = CURLOPT("CURLOPT_SHARE", CURLOPTTYPE_OBJECTPOINT, 100),

	/* indicates type of proxy. accepted values are CURLPROXY_HTTP (default),
	   CURLPROXY_HTTPS, CURLPROXY_SOCKS4, CURLPROXY_SOCKS4A and
	   CURLPROXY_SOCKS5. */
	CURLOPT_PROXYTYPE = CURLOPT("CURLOPT_PROXYTYPE", CURLOPTTYPE_VALUES, 101),

	/* Set the Accept-Encoding string. Use this to tell a server you would like
	   the response to be compressed. Before 7.21.6, this was known as
	   CURLOPT_ENCODING */
	CURLOPT_ACCEPT_ENCODING = CURLOPT("CURLOPT_ACCEPT_ENCODING", CURLOPTTYPE_STRINGPOINT, 102),

	/* Set pointer to private data */
	CURLOPT_PRIVATE = CURLOPT("CURLOPT_PRIVATE", CURLOPTTYPE_OBJECTPOINT, 103),

	/* Set aliases for HTTP 200 in the HTTP Response header */
	CURLOPT_HTTP200ALIASES = CURLOPT("CURLOPT_HTTP200ALIASES", CURLOPTTYPE_SLISTPOINT, 104),

	/* Continue to send authentication (user+password) when following locations,
	   even when hostname changed. This can potentially send off the name
	   and password to whatever host the server decides. */
	CURLOPT_UNRESTRICTED_AUTH = CURLOPT("CURLOPT_UNRESTRICTED_AUTH", CURLOPTTYPE_LONG, 105),

	/* Specifically switch on or off the FTP engine's use of the EPRT command (
	   it also disables the LPRT attempt). By default, those ones will always be
	   attempted before the good old traditional PORT command. */
	CURLOPT_FTP_USE_EPRT = CURLOPT("CURLOPT_FTP_USE_EPRT", CURLOPTTYPE_LONG, 106),

	/* Set this to a bitmask value to enable the particular authentications
	   methods you like. Use this in combination with CURLOPT_USERPWD.
	   Note that setting multiple bits may cause extra network round-trips. */
	CURLOPT_HTTPAUTH = CURLOPT("CURLOPT_HTTPAUTH", CURLOPTTYPE_VALUES, 107),

	/* Set the ssl context callback function, currently only for OpenSSL or
	   WolfSSL ssl_ctx, or mbedTLS mbedtls_ssl_config in the second argument.
	   The function must match the curl_ssl_ctx_callback prototype. */
	CURLOPT_SSL_CTX_FUNCTION = CURLOPT("CURLOPT_SSL_CTX_FUNCTION", CURLOPTTYPE_FUNCTIONPOINT, 108),

	/* Set the userdata for the ssl context callback function's third
	   argument */
	CURLOPT_SSL_CTX_DATA = CURLOPT("CURLOPT_SSL_CTX_DATA", CURLOPTTYPE_CBPOINT, 109),

	/* FTP Option that causes missing dirs to be created on the remote server.
	   In 7.19.4 we introduced the convenience enums for this option using the
	   CURLFTP_CREATE_DIR prefix.
	*/
	CURLOPT_FTP_CREATE_MISSING_DIRS = CURLOPT("CURLOPT_FTP_CREATE_MISSING_DIRS", CURLOPTTYPE_LONG, 110),

	/* Set this to a bitmask value to enable the particular authentications
	   methods you like. Use this in combination with CURLOPT_PROXYUSERPWD.
	   Note that setting multiple bits may cause extra network round-trips. */
	CURLOPT_PROXYAUTH = CURLOPT("CURLOPT_PROXYAUTH", CURLOPTTYPE_VALUES, 111),

	/* FTP option that changes the timeout, in seconds, associated with
	   getting a response.  This is different from transfer timeout time and
	   essentially places a demand on the FTP server to acknowledge commands
	   in a timely manner. */
	CURLOPT_FTP_RESPONSE_TIMEOUT = CURLOPT("CURLOPT_FTP_RESPONSE_TIMEOUT", CURLOPTTYPE_LONG, 112),
	CURLOPT_SERVER_RESPONSE_TIMEOUT = CURLOPT_FTP_RESPONSE_TIMEOUT,

	/* Set this option to one of the CURL_IPRESOLVE_* defines (see below) to
	   tell libcurl to resolve names to those IP versions only. This only has
	   affect on systems with support for more than one, i.e IPv4 _and_ IPv6. */
	CURLOPT_IPRESOLVE = CURLOPT("CURLOPT_IPRESOLVE", CURLOPTTYPE_VALUES, 113),

	/* Set this option to limit the size of a file that will be downloaded from
	   an HTTP or FTP server.
	   Note there is also _LARGE version which adds large file support for
	   platforms which have larger off_t sizes.  See MAXFILESIZE_LARGE below. */
	CURLOPT_MAXFILESIZE = CURLOPT("CURLOPT_MAXFILESIZE", CURLOPTTYPE_LONG, 114),

	/* See the comment for INFILESIZE above, but in short, specifies
	 * the size of the file being uploaded.  -1 means unknown.
	 */
	CURLOPT_INFILESIZE_LARGE = CURLOPT("CURLOPT_INFILESIZE_LARGE", CURLOPTTYPE_OFF_T, 115),

	/* Sets the continuation offset.  There is also a CURLOPTTYPE_LONG version
	 * of this; look above for RESUME_FROM.
	 */
	CURLOPT_RESUME_FROM_LARGE = CURLOPT("CURLOPT_RESUME_FROM_LARGE", CURLOPTTYPE_OFF_T, 116),

	/* Sets the maximum size of data that will be downloaded from
	 * an HTTP or FTP server.  See MAXFILESIZE above for the LONG version.
	 */
	CURLOPT_MAXFILESIZE_LARGE = CURLOPT("CURLOPT_MAXFILESIZE_LARGE", CURLOPTTYPE_OFF_T, 117),

	/* Set this option to the file name of your .netrc file you want libcurl
	   to parse (using the CURLOPT_NETRC option). If not set, libcurl will do
	   a poor attempt to find the user's home directory and check for a .netrc
	   file in there. */
	CURLOPT_NETRC_FILE = CURLOPT("CURLOPT_NETRC_FILE", CURLOPTTYPE_STRINGPOINT, 118),

	/* Enable SSL/TLS for FTP, pick one of:
	   CURLUSESSL_TRY     - try using SSL, proceed anyway otherwise
	   CURLUSESSL_CONTROL - SSL for the control connection or fail
	   CURLUSESSL_ALL     - SSL for all communication or fail
	*/
	CURLOPT_USE_SSL = CURLOPT("CURLOPT_USE_SSL", CURLOPTTYPE_VALUES, 119),

	/* The _LARGE version of the standard POSTFIELDSIZE option */
	CURLOPT_POSTFIELDSIZE_LARGE = CURLOPT("CURLOPT_POSTFIELDSIZE_LARGE", CURLOPTTYPE_OFF_T, 120),

	/* Enable/disable the TCP Nagle algorithm */
	CURLOPT_TCP_NODELAY = CURLOPT("CURLOPT_TCP_NODELAY", CURLOPTTYPE_LONG, 121),

	/* 122 OBSOLETE, used in 7.12.3. Gone in 7.13.0 */
	/* 123 OBSOLETE. Gone in 7.16.0 */
	/* 124 OBSOLETE, used in 7.12.3. Gone in 7.13.0 */
	/* 125 OBSOLETE, used in 7.12.3. Gone in 7.13.0 */
	/* 126 OBSOLETE, used in 7.12.3. Gone in 7.13.0 */
	/* 127 OBSOLETE. Gone in 7.16.0 */
	/* 128 OBSOLETE. Gone in 7.16.0 */

	/* When FTP over SSL/TLS is selected (with CURLOPT_USE_SSL), this option
	   can be used to change libcurl's default action which is to first try
	   "AUTH SSL" and then "AUTH TLS" in this order, and proceed when a OK
	   response has been received.
	   Available parameters are:
	   CURLFTPAUTH_DEFAULT - let libcurl decide
	   CURLFTPAUTH_SSL     - try "AUTH SSL" first, then TLS
	   CURLFTPAUTH_TLS     - try "AUTH TLS" first, then SSL
	*/
	CURLOPT_FTPSSLAUTH = CURLOPT("CURLOPT_FTPSSLAUTH", CURLOPTTYPE_VALUES, 129),

	CURLOPT_IOCTLFUNCTION = CURLOPT("CURLOPT_IOCTLFUNCTION", CURLOPTTYPE_FUNCTIONPOINT, 130),
	CURLOPT_IOCTLDATA = CURLOPT("CURLOPT_IOCTLDATA", CURLOPTTYPE_CBPOINT, 131),

	/* 132 OBSOLETE. Gone in 7.16.0 */
	/* 133 OBSOLETE. Gone in 7.16.0 */

	/* null-terminated string for pass on to the FTP server when asked for
	   "account" info */
	CURLOPT_FTP_ACCOUNT = CURLOPT("CURLOPT_FTP_ACCOUNT", CURLOPTTYPE_STRINGPOINT, 134),

	/* feed cookie into cookie engine */
	CURLOPT_COOKIELIST = CURLOPT("CURLOPT_COOKIELIST", CURLOPTTYPE_STRINGPOINT, 135),

	/* ignore Content-Length */
	CURLOPT_IGNORE_CONTENT_LENGTH = CURLOPT("CURLOPT_IGNORE_CONTENT_LENGTH", CURLOPTTYPE_LONG, 136),

	/* Set to non-zero to skip the IP address received in a 227 PASV FTP server
	   response. Typically used for FTP-SSL purposes but is not restricted to
	   that. libcurl will then instead use the same IP address it used for the
	   control connection. */
	CURLOPT_FTP_SKIP_PASV_IP = CURLOPT("CURLOPT_FTP_SKIP_PASV_IP", CURLOPTTYPE_LONG, 137),

	/* Select "file method" to use when doing FTP, see the curl_ftpmethod
	   above. */
	CURLOPT_FTP_FILEMETHOD = CURLOPT("CURLOPT_FTP_FILEMETHOD", CURLOPTTYPE_VALUES, 138),

	/* Local port number to bind the socket to */
	CURLOPT_LOCALPORT = CURLOPT("CURLOPT_LOCALPORT", CURLOPTTYPE_LONG, 139),

	/* Number of ports to try, including the first one set with LOCALPORT.
	   Thus, setting it to 1 will make no additional attempts but the first.
	*/
	CURLOPT_LOCALPORTRANGE = CURLOPT("CURLOPT_LOCALPORTRANGE", CURLOPTTYPE_LONG, 140),

	/* no transfer, set up connection and let application use the socket by
	   extracting it with CURLINFO_LASTSOCKET */
	CURLOPT_CONNECT_ONLY = CURLOPT("CURLOPT_CONNECT_ONLY", CURLOPTTYPE_LONG, 141),

	/* Function that will be called to convert from the
	   network encoding (instead of using the iconv calls in libcurl) */
	CURLOPT_CONV_FROM_NETWORK_FUNCTION = CURLOPT("CURLOPT_CONV_FROM_NETWORK_FUNCTION", CURLOPTTYPE_FUNCTIONPOINT, 142),

	/* Function that will be called to convert to the
	   network encoding (instead of using the iconv calls in libcurl) */
	CURLOPT_CONV_TO_NETWORK_FUNCTION = CURLOPT("CURLOPT_CONV_TO_NETWORK_FUNCTION", CURLOPTTYPE_FUNCTIONPOINT, 143),

	/* Function that will be called to convert from UTF8
	   (instead of using the iconv calls in libcurl)
	   Note that this is used only for SSL certificate processing */
	CURLOPT_CONV_FROM_UTF8_FUNCTION = CURLOPT("CURLOPT_CONV_FROM_UTF8_FUNCTION", CURLOPTTYPE_FUNCTIONPOINT, 144),

	/* if the connection proceeds too quickly then need to slow it down */
	/* limit-rate: maximum number of bytes per second to send or receive */
	CURLOPT_MAX_SEND_SPEED_LARGE = CURLOPT("CURLOPT_MAX_SEND_SPEED_LARGE", CURLOPTTYPE_OFF_T, 145),
	CURLOPT_MAX_RECV_SPEED_LARGE = CURLOPT("CURLOPT_MAX_RECV_SPEED_LARGE", CURLOPTTYPE_OFF_T, 146),

	/* Pointer to command string to send if USER/PASS fails. */
	CURLOPT_FTP_ALTERNATIVE_TO_USER = CURLOPT("CURLOPT_FTP_ALTERNATIVE_TO_USER", CURLOPTTYPE_STRINGPOINT, 147),

	/* callback function for setting socket options */
	CURLOPT_SOCKOPTFUNCTION = CURLOPT("CURLOPT_SOCKOPTFUNCTION", CURLOPTTYPE_FUNCTIONPOINT, 148),
	CURLOPT_SOCKOPTDATA = CURLOPT("CURLOPT_SOCKOPTDATA", CURLOPTTYPE_CBPOINT, 149),

	/* set to 0 to disable session ID re-use for this transfer, default is
	   enabled (== 1) */
	CURLOPT_SSL_SESSIONID_CACHE = CURLOPT("CURLOPT_SSL_SESSIONID_CACHE", CURLOPTTYPE_LONG, 150),

	/* allowed SSH authentication methods */
	CURLOPT_SSH_AUTH_TYPES = CURLOPT("CURLOPT_SSH_AUTH_TYPES", CURLOPTTYPE_VALUES, 151),

	/* Used by scp/sftp to do public/private key authentication */
	CURLOPT_SSH_PUBLIC_KEYFILE = CURLOPT("CURLOPT_SSH_PUBLIC_KEYFILE", CURLOPTTYPE_STRINGPOINT, 152),
	CURLOPT_SSH_PRIVATE_KEYFILE = CURLOPT("CURLOPT_SSH_PRIVATE_KEYFILE", CURLOPTTYPE_STRINGPOINT, 153),

	/* Send CCC (Clear Command Channel) after authentication */
	CURLOPT_FTP_SSL_CCC = CURLOPT("CURLOPT_FTP_SSL_CCC", CURLOPTTYPE_LONG, 154),

	/* Same as TIMEOUT and CONNECTTIMEOUT, but with ms resolution */
	CURLOPT_TIMEOUT_MS = CURLOPT("CURLOPT_TIMEOUT_MS", CURLOPTTYPE_LONG, 155),
	CURLOPT_CONNECTTIMEOUT_MS = CURLOPT("CURLOPT_CONNECTTIMEOUT_MS", CURLOPTTYPE_LONG, 156),

	/* set to zero to disable the libcurl's decoding and thus pass the raw body
	   data to the application even when it is encoded/compressed */
	CURLOPT_HTTP_TRANSFER_DECODING = CURLOPT("CURLOPT_HTTP_TRANSFER_DECODING", CURLOPTTYPE_LONG, 157),
	CURLOPT_HTTP_CONTENT_DECODING = CURLOPT("CURLOPT_HTTP_CONTENT_DECODING", CURLOPTTYPE_LONG, 158),

	/* Permission used when creating new files and directories on the remote
	   server for protocols that support it, SFTP/SCP/FILE */
	CURLOPT_NEW_FILE_PERMS = CURLOPT("CURLOPT_NEW_FILE_PERMS", CURLOPTTYPE_LONG, 159),
	CURLOPT_NEW_DIRECTORY_PERMS = CURLOPT("CURLOPT_NEW_DIRECTORY_PERMS", CURLOPTTYPE_LONG, 160),

	/* Set the behaviour of POST when redirecting. Values must be set to one
	   of CURL_REDIR* defines below. This used to be called CURLOPT_POST301 */
	CURLOPT_POSTREDIR = CURLOPT("CURLOPT_POSTREDIR", CURLOPTTYPE_VALUES, 161),

	/* used by scp/sftp to verify the host's public key */
	CURLOPT_SSH_HOST_PUBLIC_KEY_MD5 = CURLOPT("CURLOPT_SSH_HOST_PUBLIC_KEY_MD5", CURLOPTTYPE_STRINGPOINT, 162),

	/* Callback function for opening socket (instead of socket(2)). Optionally,
	   callback is able change the address or refuse to connect returning
	   CURL_SOCKET_BAD.  The callback should have type
	   curl_opensocket_callback */
	CURLOPT_OPENSOCKETFUNCTION = CURLOPT("CURLOPT_OPENSOCKETFUNCTION", CURLOPTTYPE_FUNCTIONPOINT, 163),
	CURLOPT_OPENSOCKETDATA = CURLOPT("CURLOPT_OPENSOCKETDATA", CURLOPTTYPE_CBPOINT, 164),

	/* POST volatile input fields. */
	CURLOPT_COPYPOSTFIELDS = CURLOPT("CURLOPT_COPYPOSTFIELDS", CURLOPTTYPE_OBJECTPOINT, 165),

	/* set transfer mode (;type=<a|i>) when doing FTP via an HTTP proxy */
	CURLOPT_PROXY_TRANSFER_MODE = CURLOPT("CURLOPT_PROXY_TRANSFER_MODE", CURLOPTTYPE_LONG, 166),

	/* Callback function for seeking in the input stream */
	CURLOPT_SEEKFUNCTION = CURLOPT("CURLOPT_SEEKFUNCTION", CURLOPTTYPE_FUNCTIONPOINT, 167),
	CURLOPT_SEEKDATA = CURLOPT("CURLOPT_SEEKDATA", CURLOPTTYPE_CBPOINT, 168),

	/* CRL file */
	CURLOPT_CRLFILE = CURLOPT("CURLOPT_CRLFILE", CURLOPTTYPE_STRINGPOINT, 169),

	/* Issuer certificate */
	CURLOPT_ISSUERCERT = CURLOPT("CURLOPT_ISSUERCERT", CURLOPTTYPE_STRINGPOINT, 170),

	/* (IPv6) Address scope */
	CURLOPT_ADDRESS_SCOPE = CURLOPT("CURLOPT_ADDRESS_SCOPE", CURLOPTTYPE_LONG, 171),

	/* Collect certificate chain info and allow it to get retrievable with
	   CURLINFO_CERTINFO after the transfer is complete. */
	CURLOPT_CERTINFO = CURLOPT("CURLOPT_CERTINFO", CURLOPTTYPE_LONG, 172),

	/* "name" and "pwd" to use when fetching. */
	CURLOPT_USERNAME = CURLOPT("CURLOPT_USERNAME", CURLOPTTYPE_STRINGPOINT, 173),
	CURLOPT_PASSWORD = CURLOPT("CURLOPT_PASSWORD", CURLOPTTYPE_STRINGPOINT, 174),

	  /* "name" and "pwd" to use with Proxy when fetching. */
	CURLOPT_PROXYUSERNAME = CURLOPT("CURLOPT_PROXYUSERNAME", CURLOPTTYPE_STRINGPOINT, 175),
	CURLOPT_PROXYPASSWORD = CURLOPT("CURLOPT_PROXYPASSWORD", CURLOPTTYPE_STRINGPOINT, 176),

	/* Comma separated list of hostnames defining no-proxy zones. These should
	   match both hostnames directly, and hostnames within a domain. For
	   example, local.com will match local.com and www.local.com, but NOT
	   notlocal.com or www.notlocal.com. For compatibility with other
	   implementations of this, .local.com will be considered to be the same as
	   local.com. A single * is the only valid wildcard, and effectively
	   disables the use of proxy. */
	CURLOPT_NOPROXY = CURLOPT("CURLOPT_NOPROXY", CURLOPTTYPE_STRINGPOINT, 177),

	/* block size for TFTP transfers */
	CURLOPT_TFTP_BLKSIZE = CURLOPT("CURLOPT_TFTP_BLKSIZE", CURLOPTTYPE_LONG, 178),

	/* Socks Service */
	/* DEPRECATED, do not use! */
	CURLOPT_SOCKS5_GSSAPI_SERVICE = CURLOPT("CURLOPT_SOCKS5_GSSAPI_SERVICE", CURLOPTTYPE_STRINGPOINT, 179),

	/* Socks Service */
	CURLOPT_SOCKS5_GSSAPI_NEC = CURLOPT("CURLOPT_SOCKS5_GSSAPI_NEC", CURLOPTTYPE_LONG, 180),

	/* set the bitmask for the protocols that are allowed to be used for the
	   transfer, which thus helps the app which takes URLs from users or other
	   external inputs and want to restrict what protocol(s) to deal
	   with. Defaults to CURLPROTO_ALL. */
	CURLOPT_PROTOCOLS = CURLOPT("CURLOPT_PROTOCOLS", CURLOPTTYPE_LONG, 181),

	/* set the bitmask for the protocols that libcurl is allowed to follow to,
	   as a subset of the CURLOPT_PROTOCOLS ones. That means the protocol needs
	   to be set in both bitmasks to be allowed to get redirected to. */
	CURLOPT_REDIR_PROTOCOLS = CURLOPT("CURLOPT_REDIR_PROTOCOLS", CURLOPTTYPE_LONG, 182),

	/* set the SSH knownhost file name to use */
	CURLOPT_SSH_KNOWNHOSTS = CURLOPT("CURLOPT_SSH_KNOWNHOSTS", CURLOPTTYPE_STRINGPOINT, 183),

	/* set the SSH host key callback, must point to a curl_sshkeycallback
	   function */
	CURLOPT_SSH_KEYFUNCTION = CURLOPT("CURLOPT_SSH_KEYFUNCTION", CURLOPTTYPE_FUNCTIONPOINT, 184),

	/* set the SSH host key callback custom pointer */
	CURLOPT_SSH_KEYDATA = CURLOPT("CURLOPT_SSH_KEYDATA", CURLOPTTYPE_CBPOINT, 185),

	/* set the SMTP mail originator */
	CURLOPT_MAIL_FROM = CURLOPT("CURLOPT_MAIL_FROM", CURLOPTTYPE_STRINGPOINT, 186),

	/* set the list of SMTP mail receiver(s) */
	CURLOPT_MAIL_RCPT = CURLOPT("CURLOPT_MAIL_RCPT", CURLOPTTYPE_SLISTPOINT, 187),

	/* FTP: send PRET before PASV */
	CURLOPT_FTP_USE_PRET = CURLOPT("CURLOPT_FTP_USE_PRET", CURLOPTTYPE_LONG, 188),

	/* RTSP request method (OPTIONS, SETUP, PLAY, etc...) */
	CURLOPT_RTSP_REQUEST = CURLOPT("CURLOPT_RTSP_REQUEST", CURLOPTTYPE_VALUES, 189),

	/* The RTSP session identifier */
	CURLOPT_RTSP_SESSION_ID = CURLOPT("CURLOPT_RTSP_SESSION_ID", CURLOPTTYPE_STRINGPOINT, 190),

	/* The RTSP stream URI */
	CURLOPT_RTSP_STREAM_URI = CURLOPT("CURLOPT_RTSP_STREAM_URI", CURLOPTTYPE_STRINGPOINT, 191),

	/* The Transport: header to use in RTSP requests */
	CURLOPT_RTSP_TRANSPORT = CURLOPT("CURLOPT_RTSP_TRANSPORT", CURLOPTTYPE_STRINGPOINT, 192),

	/* Manually initialize the client RTSP CSeq for this handle */
	CURLOPT_RTSP_CLIENT_CSEQ = CURLOPT("CURLOPT_RTSP_CLIENT_CSEQ", CURLOPTTYPE_LONG, 193),

	/* Manually initialize the server RTSP CSeq for this handle */
	CURLOPT_RTSP_SERVER_CSEQ = CURLOPT("CURLOPT_RTSP_SERVER_CSEQ", CURLOPTTYPE_LONG, 194),

	/* The stream to pass to INTERLEAVEFUNCTION. */
	CURLOPT_INTERLEAVEDATA = CURLOPT("CURLOPT_INTERLEAVEDATA", CURLOPTTYPE_CBPOINT, 195),

	/* Let the application define a custom write method for RTP data */
	CURLOPT_INTERLEAVEFUNCTION = CURLOPT("CURLOPT_INTERLEAVEFUNCTION", CURLOPTTYPE_FUNCTIONPOINT, 196),

	/* Turn on wildcard matching */
	CURLOPT_WILDCARDMATCH = CURLOPT("CURLOPT_WILDCARDMATCH", CURLOPTTYPE_LONG, 197),

	/* Directory matching callback called before downloading of an
	   individual file (chunk) started */
	CURLOPT_CHUNK_BGN_FUNCTION = CURLOPT("CURLOPT_CHUNK_BGN_FUNCTION", CURLOPTTYPE_FUNCTIONPOINT, 198),

	/* Directory matching callback called after the file (chunk)
	   was downloaded, or skipped */
	CURLOPT_CHUNK_END_FUNCTION = CURLOPT("CURLOPT_CHUNK_END_FUNCTION", CURLOPTTYPE_FUNCTIONPOINT, 199),

	/* Change match (fnmatch-like) callback for wildcard matching */
	CURLOPT_FNMATCH_FUNCTION = CURLOPT("CURLOPT_FNMATCH_FUNCTION", CURLOPTTYPE_FUNCTIONPOINT, 200),

	/* Let the application define custom chunk data pointer */
	CURLOPT_CHUNK_DATA = CURLOPT("CURLOPT_CHUNK_DATA", CURLOPTTYPE_CBPOINT, 201),

	/* FNMATCH_FUNCTION user pointer */
	CURLOPT_FNMATCH_DATA = CURLOPT("CURLOPT_FNMATCH_DATA", CURLOPTTYPE_CBPOINT, 202),

	/* send linked-list of name:port:address sets */
	CURLOPT_RESOLVE = CURLOPT("CURLOPT_RESOLVE", CURLOPTTYPE_SLISTPOINT, 203),

	/* Set a username for authenticated TLS */
	CURLOPT_TLSAUTH_USERNAME = CURLOPT("CURLOPT_TLSAUTH_USERNAME", CURLOPTTYPE_STRINGPOINT, 204),

	/* Set a password for authenticated TLS */
	CURLOPT_TLSAUTH_PASSWORD = CURLOPT("CURLOPT_TLSAUTH_PASSWORD", CURLOPTTYPE_STRINGPOINT, 205),

	/* Set authentication type for authenticated TLS */
	CURLOPT_TLSAUTH_TYPE = CURLOPT("CURLOPT_TLSAUTH_TYPE", CURLOPTTYPE_STRINGPOINT, 206),

	/* Set to 1 to enable the "TE:" header in HTTP requests to ask for
	   compressed transfer-encoded responses. Set to 0 to disable the use of TE:
	   in outgoing requests. The current default is 0, but it might change in a
	   future libcurl release.
	   libcurl will ask for the compressed methods it knows of, and if that
	   isn't any, it will not ask for transfer-encoding at all even if this
	   option is set to 1.
	*/
	CURLOPT_TRANSFER_ENCODING = CURLOPT("CURLOPT_TRANSFER_ENCODING", CURLOPTTYPE_LONG, 207),

	/* Callback function for closing socket (instead of close(2)). The callback
	   should have type curl_closesocket_callback */
	CURLOPT_CLOSESOCKETFUNCTION = CURLOPT("CURLOPT_CLOSESOCKETFUNCTION", CURLOPTTYPE_FUNCTIONPOINT, 208),
	CURLOPT_CLOSESOCKETDATA = CURLOPT("CURLOPT_CLOSESOCKETDATA", CURLOPTTYPE_CBPOINT, 209),

	/* allow GSSAPI credential delegation */
	CURLOPT_GSSAPI_DELEGATION = CURLOPT("CURLOPT_GSSAPI_DELEGATION", CURLOPTTYPE_VALUES, 210),

	/* Set the name servers to use for DNS resolution */
	CURLOPT_DNS_SERVERS = CURLOPT("CURLOPT_DNS_SERVERS", CURLOPTTYPE_STRINGPOINT, 211),

	/* Time-out accept operations (currently for FTP only) after this amount
	   of milliseconds. */
	CURLOPT_ACCEPTTIMEOUT_MS = CURLOPT("CURLOPT_ACCEPTTIMEOUT_MS", CURLOPTTYPE_LONG, 212),

	/* Set TCP keepalive */
	CURLOPT_TCP_KEEPALIVE = CURLOPT("CURLOPT_TCP_KEEPALIVE", CURLOPTTYPE_LONG, 213),

	/* non-universal keepalive knobs (Linux, AIX, HP-UX, more) */
	CURLOPT_TCP_KEEPIDLE = CURLOPT("CURLOPT_TCP_KEEPIDLE", CURLOPTTYPE_LONG, 214),
	CURLOPT_TCP_KEEPINTVL = CURLOPT("CURLOPT_TCP_KEEPINTVL", CURLOPTTYPE_LONG, 215),

	/* Enable/disable specific SSL features with a bitmask, see CURLSSLOPT_* */
	CURLOPT_SSL_OPTIONS = CURLOPT("CURLOPT_SSL_OPTIONS", CURLOPTTYPE_VALUES, 216),

	/* Set the SMTP auth originator */
	CURLOPT_MAIL_AUTH = CURLOPT("CURLOPT_MAIL_AUTH", CURLOPTTYPE_STRINGPOINT, 217),

	/* Enable/disable SASL initial response */
	CURLOPT_SASL_IR = CURLOPT("CURLOPT_SASL_IR", CURLOPTTYPE_LONG, 218),

	/* Function that will be called instead of the internal progress display
	 * function. This function should be defined as the curl_xferinfo_callback
	 * prototype defines. (Deprecates CURLOPT_PROGRESSFUNCTION) */
	CURLOPT_XFERINFOFUNCTION = CURLOPT("CURLOPT_XFERINFOFUNCTION", CURLOPTTYPE_FUNCTIONPOINT, 219),

	/* The XOAUTH2 bearer token */
	CURLOPT_XOAUTH2_BEARER = CURLOPT("CURLOPT_XOAUTH2_BEARER", CURLOPTTYPE_STRINGPOINT, 220),

	/* Set the interface string to use as outgoing network
	 * interface for DNS requests.
	 * Only supported by the c-ares DNS backend */
	CURLOPT_DNS_INTERFACE = CURLOPT("CURLOPT_DNS_INTERFACE", CURLOPTTYPE_STRINGPOINT, 221),

	/* Set the local IPv4 address to use for outgoing DNS requests.
	 * Only supported by the c-ares DNS backend */
	CURLOPT_DNS_LOCAL_IP4 = CURLOPT("CURLOPT_DNS_LOCAL_IP4", CURLOPTTYPE_STRINGPOINT, 222),

	/* Set the local IPv6 address to use for outgoing DNS requests.
	 * Only supported by the c-ares DNS backend */
	CURLOPT_DNS_LOCAL_IP6 = CURLOPT("CURLOPT_DNS_LOCAL_IP6", CURLOPTTYPE_STRINGPOINT, 223),

	/* Set authentication options directly */
	CURLOPT_LOGIN_OPTIONS = CURLOPT("CURLOPT_LOGIN_OPTIONS", CURLOPTTYPE_STRINGPOINT, 224),

	/* Enable/disable TLS NPN extension (http2 over ssl might fail without) */
	CURLOPT_SSL_ENABLE_NPN = CURLOPT("CURLOPT_SSL_ENABLE_NPN", CURLOPTTYPE_LONG, 225),

	/* Enable/disable TLS ALPN extension (http2 over ssl might fail without) */
	CURLOPT_SSL_ENABLE_ALPN = CURLOPT("CURLOPT_SSL_ENABLE_ALPN", CURLOPTTYPE_LONG, 226),

	/* Time to wait for a response to a HTTP request containing an
	 * Expect: 100-continue header before sending the data anyway. */
	CURLOPT_EXPECT_100_TIMEOUT_MS = CURLOPT("CURLOPT_EXPECT_100_TIMEOUT_MS", CURLOPTTYPE_LONG, 227),

	/* This points to a linked list of headers used for proxy requests only,
	   struct curl_slist kind */
	CURLOPT_PROXYHEADER = CURLOPT("CURLOPT_PROXYHEADER", CURLOPTTYPE_SLISTPOINT, 228),

	/* Pass in a bitmask of "header options" */
	CURLOPT_HEADEROPT = CURLOPT("CURLOPT_HEADEROPT", CURLOPTTYPE_VALUES, 229),

	/* The public key in DER form used to validate the peer public key
	   this option is used only if SSL_VERIFYPEER is true */
	CURLOPT_PINNEDPUBLICKEY = CURLOPT("CURLOPT_PINNEDPUBLICKEY", CURLOPTTYPE_STRINGPOINT, 230),

	/* Path to Unix domain socket */
	CURLOPT_UNIX_SOCKET_PATH = CURLOPT("CURLOPT_UNIX_SOCKET_PATH", CURLOPTTYPE_STRINGPOINT, 231),

	/* Set if we should verify the certificate status. */
	CURLOPT_SSL_VERIFYSTATUS = CURLOPT("CURLOPT_SSL_VERIFYSTATUS", CURLOPTTYPE_LONG, 232),

	/* Set if we should enable TLS false start. */
	CURLOPT_SSL_FALSESTART = CURLOPT("CURLOPT_SSL_FALSESTART", CURLOPTTYPE_LONG, 233),

	/* Do not squash dot-dot sequences */
	CURLOPT_PATH_AS_IS = CURLOPT("CURLOPT_PATH_AS_IS", CURLOPTTYPE_LONG, 234),

	/* Proxy Service Name */
	CURLOPT_PROXY_SERVICE_NAME = CURLOPT("CURLOPT_PROXY_SERVICE_NAME", CURLOPTTYPE_STRINGPOINT, 235),

	/* Service Name */
	CURLOPT_SERVICE_NAME = CURLOPT("CURLOPT_SERVICE_NAME", CURLOPTTYPE_STRINGPOINT, 236),

	/* Wait/don't wait for pipe/mutex to clarify */
	CURLOPT_PIPEWAIT = CURLOPT("CURLOPT_PIPEWAIT", CURLOPTTYPE_LONG, 237),

	/* Set the protocol used when curl is given a URL without a protocol */
	CURLOPT_DEFAULT_PROTOCOL = CURLOPT("CURLOPT_DEFAULT_PROTOCOL", CURLOPTTYPE_STRINGPOINT, 238),

	/* Set stream weight, 1 - 256 (default is 16) */
	CURLOPT_STREAM_WEIGHT = CURLOPT("CURLOPT_STREAM_WEIGHT", CURLOPTTYPE_LONG, 239),

	/* Set stream dependency on another CURL handle */
	CURLOPT_STREAM_DEPENDS = CURLOPT("CURLOPT_STREAM_DEPENDS", CURLOPTTYPE_OBJECTPOINT, 240),

	/* Set E-xclusive stream dependency on another CURL handle */
	CURLOPT_STREAM_DEPENDS_E = CURLOPT("CURLOPT_STREAM_DEPENDS_E", CURLOPTTYPE_OBJECTPOINT, 241),

	/* Do not send any tftp option requests to the server */
	CURLOPT_TFTP_NO_OPTIONS = CURLOPT("CURLOPT_TFTP_NO_OPTIONS", CURLOPTTYPE_LONG, 242),

	/* Linked-list of host:port:connect-to-host:connect-to-port,
	   overrides the URL's host:port (only for the network layer) */
	CURLOPT_CONNECT_TO = CURLOPT("CURLOPT_CONNECT_TO", CURLOPTTYPE_SLISTPOINT, 243),

	/* Set TCP Fast Open */
	CURLOPT_TCP_FASTOPEN = CURLOPT("CURLOPT_TCP_FASTOPEN", CURLOPTTYPE_LONG, 244),

	/* Continue to send data if the server responds early with an
	 * HTTP status code >= 300 */
	CURLOPT_KEEP_SENDING_ON_ERROR = CURLOPT("CURLOPT_KEEP_SENDING_ON_ERROR", CURLOPTTYPE_LONG, 245),

	/* The CApath or CAfile used to validate the proxy certificate
	   this option is used only if PROXY_SSL_VERIFYPEER is true */
	CURLOPT_PROXY_CAINFO = CURLOPT("CURLOPT_PROXY_CAINFO", CURLOPTTYPE_STRINGPOINT, 246),

	/* The CApath directory used to validate the proxy certificate
	   this option is used only if PROXY_SSL_VERIFYPEER is true */
	CURLOPT_PROXY_CAPATH = CURLOPT("CURLOPT_PROXY_CAPATH", CURLOPTTYPE_STRINGPOINT, 247),

	/* Set if we should verify the proxy in ssl handshake,
	   set 1 to verify. */
	CURLOPT_PROXY_SSL_VERIFYPEER = CURLOPT("CURLOPT_PROXY_SSL_VERIFYPEER", CURLOPTTYPE_LONG, 248),

	/* Set if we should verify the Common name from the proxy certificate in ssl
	 * handshake, set 1 to check existence, 2 to ensure that it matches
	 * the provided hostname. */
	CURLOPT_PROXY_SSL_VERIFYHOST = CURLOPT("CURLOPT_PROXY_SSL_VERIFYHOST", CURLOPTTYPE_LONG, 249),

	/* What version to specifically try to use for proxy.
	   See CURL_SSLVERSION defines below. */
	CURLOPT_PROXY_SSLVERSION = CURLOPT("CURLOPT_PROXY_SSLVERSION", CURLOPTTYPE_VALUES, 250),

	/* Set a username for authenticated TLS for proxy */
	CURLOPT_PROXY_TLSAUTH_USERNAME = CURLOPT("CURLOPT_PROXY_TLSAUTH_USERNAME", CURLOPTTYPE_STRINGPOINT, 251),

	/* Set a password for authenticated TLS for proxy */
	CURLOPT_PROXY_TLSAUTH_PASSWORD = CURLOPT("CURLOPT_PROXY_TLSAUTH_PASSWORD", CURLOPTTYPE_STRINGPOINT, 252),

	/* Set authentication type for authenticated TLS for proxy */
	CURLOPT_PROXY_TLSAUTH_TYPE = CURLOPT("CURLOPT_PROXY_TLSAUTH_TYPE", CURLOPTTYPE_STRINGPOINT, 253),

	/* name of the file keeping your private SSL-certificate for proxy */
	CURLOPT_PROXY_SSLCERT = CURLOPT("CURLOPT_PROXY_SSLCERT", CURLOPTTYPE_STRINGPOINT, 254),

	/* type of the file keeping your SSL-certificate ("DER", "PEM", "ENG") for
	   proxy */
	CURLOPT_PROXY_SSLCERTTYPE = CURLOPT("CURLOPT_PROXY_SSLCERTTYPE", CURLOPTTYPE_STRINGPOINT, 255),

	/* name of the file keeping your private SSL-key for proxy */
	CURLOPT_PROXY_SSLKEY = CURLOPT("CURLOPT_PROXY_SSLKEY", CURLOPTTYPE_STRINGPOINT, 256),

	/* type of the file keeping your private SSL-key ("DER", "PEM", "ENG") for
	   proxy */
	CURLOPT_PROXY_SSLKEYTYPE = CURLOPT("CURLOPT_PROXY_SSLKEYTYPE", CURLOPTTYPE_STRINGPOINT, 257),

	/* password for the SSL private key for proxy */
	CURLOPT_PROXY_KEYPASSWD = CURLOPT("CURLOPT_PROXY_KEYPASSWD", CURLOPTTYPE_STRINGPOINT, 258),

	/* Specify which SSL ciphers to use for proxy */
	CURLOPT_PROXY_SSL_CIPHER_LIST = CURLOPT("CURLOPT_PROXY_SSL_CIPHER_LIST", CURLOPTTYPE_STRINGPOINT, 259),

	/* CRL file for proxy */
	CURLOPT_PROXY_CRLFILE = CURLOPT("CURLOPT_PROXY_CRLFILE", CURLOPTTYPE_STRINGPOINT, 260),

	/* Enable/disable specific SSL features with a bitmask for proxy, see
	   CURLSSLOPT_* */
	CURLOPT_PROXY_SSL_OPTIONS = CURLOPT("CURLOPT_PROXY_SSL_OPTIONS", CURLOPTTYPE_LONG, 261),

	/* Name of pre proxy to use. */
	CURLOPT_PRE_PROXY = CURLOPT("CURLOPT_PRE_PROXY", CURLOPTTYPE_STRINGPOINT, 262),

	/* The public key in DER form used to validate the proxy public key
	   this option is used only if PROXY_SSL_VERIFYPEER is true */
	CURLOPT_PROXY_PINNEDPUBLICKEY = CURLOPT("CURLOPT_PROXY_PINNEDPUBLICKEY", CURLOPTTYPE_STRINGPOINT, 263),

	/* Path to an abstract Unix domain socket */
	CURLOPT_ABSTRACT_UNIX_SOCKET = CURLOPT("CURLOPT_ABSTRACT_UNIX_SOCKET", CURLOPTTYPE_STRINGPOINT, 264),

	/* Suppress proxy CONNECT response headers from user callbacks */
	CURLOPT_SUPPRESS_CONNECT_HEADERS = CURLOPT("CURLOPT_SUPPRESS_CONNECT_HEADERS", CURLOPTTYPE_LONG, 265),

	/* The request target, instead of extracted from the URL */
	CURLOPT_REQUEST_TARGET = CURLOPT("CURLOPT_REQUEST_TARGET", CURLOPTTYPE_STRINGPOINT, 266),

	/* bitmask of allowed auth methods for connections to SOCKS5 proxies */
	CURLOPT_SOCKS5_AUTH = CURLOPT("CURLOPT_SOCKS5_AUTH", CURLOPTTYPE_LONG, 267),

	/* Enable/disable SSH compression */
	CURLOPT_SSH_COMPRESSION = CURLOPT("CURLOPT_SSH_COMPRESSION", CURLOPTTYPE_LONG, 268),

	/* Post MIME data. */
	CURLOPT_MIMEPOST = CURLOPT("CURLOPT_MIMEPOST", CURLOPTTYPE_OBJECTPOINT, 269),

	/* Time to use with the CURLOPT_TIMECONDITION. Specified in number of
	   seconds since 1 Jan 1970. */
	CURLOPT_TIMEVALUE_LARGE = CURLOPT("CURLOPT_TIMEVALUE_LARGE", CURLOPTTYPE_OFF_T, 270),

	/* Head start in milliseconds to give happy eyeballs. */
	CURLOPT_HAPPY_EYEBALLS_TIMEOUT_MS = CURLOPT("CURLOPT_HAPPY_EYEBALLS_TIMEOUT_MS", CURLOPTTYPE_LONG, 271),

	/* Function that will be called before a resolver request is made */
	CURLOPT_RESOLVER_START_FUNCTION = CURLOPT("CURLOPT_RESOLVER_START_FUNCTION", CURLOPTTYPE_FUNCTIONPOINT, 272),

	/* User data to pass to the resolver start callback. */
	CURLOPT_RESOLVER_START_DATA = CURLOPT("CURLOPT_RESOLVER_START_DATA", CURLOPTTYPE_CBPOINT, 273),

	/* send HAProxy PROXY protocol header? */
	CURLOPT_HAPROXYPROTOCOL = CURLOPT("CURLOPT_HAPROXYPROTOCOL", CURLOPTTYPE_LONG, 274),

	/* shuffle addresses before use when DNS returns multiple */
	CURLOPT_DNS_SHUFFLE_ADDRESSES = CURLOPT("CURLOPT_DNS_SHUFFLE_ADDRESSES", CURLOPTTYPE_LONG, 275),

	/* Specify which TLS 1.3 ciphers suites to use */
	CURLOPT_TLS13_CIPHERS = CURLOPT("CURLOPT_TLS13_CIPHERS", CURLOPTTYPE_STRINGPOINT, 276),
	CURLOPT_PROXY_TLS13_CIPHERS = CURLOPT("CURLOPT_PROXY_TLS13_CIPHERS", CURLOPTTYPE_STRINGPOINT, 277),

	/* Disallow specifying username/login in URL. */
	CURLOPT_DISALLOW_USERNAME_IN_URL = CURLOPT("CURLOPT_DISALLOW_USERNAME_IN_URL", CURLOPTTYPE_LONG, 278),

	/* DNS-over-HTTPS URL */
	CURLOPT_DOH_URL = CURLOPT("CURLOPT_DOH_URL", CURLOPTTYPE_STRINGPOINT, 279),

	/* Preferred buffer size to use for uploads */
	CURLOPT_UPLOAD_BUFFERSIZE = CURLOPT("CURLOPT_UPLOAD_BUFFERSIZE", CURLOPTTYPE_LONG, 280),

	/* Time in ms between connection upkeep calls for long-lived connections. */
	CURLOPT_UPKEEP_INTERVAL_MS = CURLOPT("CURLOPT_UPKEEP_INTERVAL_MS", CURLOPTTYPE_LONG, 281),

	/* Specify URL using CURL URL API. */
	CURLOPT_CURLU = CURLOPT("CURLOPT_CURLU", CURLOPTTYPE_OBJECTPOINT, 282),

	/* add trailing data just after no more data is available */
	CURLOPT_TRAILERFUNCTION = CURLOPT("CURLOPT_TRAILERFUNCTION", CURLOPTTYPE_FUNCTIONPOINT, 283),

	/* pointer to be passed to HTTP_TRAILER_FUNCTION */
	CURLOPT_TRAILERDATA = CURLOPT("CURLOPT_TRAILERDATA", CURLOPTTYPE_CBPOINT, 284),

	/* set this to 1L to allow HTTP/0.9 responses or 0L to disallow */
	CURLOPT_HTTP09_ALLOWED = CURLOPT("CURLOPT_HTTP09_ALLOWED", CURLOPTTYPE_LONG, 285),

	/* alt-svc control bitmask */
	CURLOPT_ALTSVC_CTRL = CURLOPT("CURLOPT_ALTSVC_CTRL", CURLOPTTYPE_LONG, 286),

	/* alt-svc cache file name to possibly read from/write to */
	CURLOPT_ALTSVC = CURLOPT("CURLOPT_ALTSVC", CURLOPTTYPE_STRINGPOINT, 287),

	/* maximum age of a connection to consider it for reuse (in seconds) */
	CURLOPT_MAXAGE_CONN = CURLOPT("CURLOPT_MAXAGE_CONN", CURLOPTTYPE_LONG, 288),

	/* SASL authorisation identity */
	CURLOPT_SASL_AUTHZID = CURLOPT("CURLOPT_SASL_AUTHZID", CURLOPTTYPE_STRINGPOINT, 289),

	/* allow RCPT TO command to fail for some recipients */
	CURLOPT_MAIL_RCPT_ALLLOWFAILS = CURLOPT("CURLOPT_MAIL_RCPT_ALLLOWFAILS", CURLOPTTYPE_LONG, 290),

	/* the private SSL-certificate as a "blob" */
	CURLOPT_SSLCERT_BLOB = CURLOPT("CURLOPT_SSLCERT_BLOB", CURLOPTTYPE_BLOB, 291),
	CURLOPT_SSLKEY_BLOB = CURLOPT("CURLOPT_SSLKEY_BLOB", CURLOPTTYPE_BLOB, 292),
	CURLOPT_PROXY_SSLCERT_BLOB = CURLOPT("CURLOPT_PROXY_SSLCERT_BLOB", CURLOPTTYPE_BLOB, 293),
	CURLOPT_PROXY_SSLKEY_BLOB = CURLOPT("CURLOPT_PROXY_SSLKEY_BLOB", CURLOPTTYPE_BLOB, 294),
	CURLOPT_ISSUERCERT_BLOB = CURLOPT("CURLOPT_ISSUERCERT_BLOB", CURLOPTTYPE_BLOB, 295),

	/* Issuer certificate for proxy */
	CURLOPT_PROXY_ISSUERCERT = CURLOPT("CURLOPT_PROXY_ISSUERCERT", CURLOPTTYPE_STRINGPOINT, 296),
	CURLOPT_PROXY_ISSUERCERT_BLOB = CURLOPT("CURLOPT_PROXY_ISSUERCERT_BLOB", CURLOPTTYPE_BLOB, 297),

	/* the EC curves requested by the TLS client (RFC 8422, 5.1);
	 * OpenSSL support via 'set_groups'/'set_curves':
	 * https://www.openssl.org/docs/manmaster/man3/SSL_CTX_set1_groups.html
	 */
	CURLOPT_SSL_EC_CURVES = CURLOPT("CURLOPT_SSL_EC_CURVES", CURLOPTTYPE_STRINGPOINT, 298),

	CURLOPT_LASTENTRY = 299, /* the last unused */
$

public type CURLoption( integer x )
	return (0 < x) and (x < CURLOPT_LASTENTRY)
end type

ifdef not CURL_NO_OLDIES then /* define this to test if your app builds with all
                                 the obsolete stuff removed! */

public constant
	CURLOPT_ENCODING             = CURLOPT_ACCEPT_ENCODING,

	/* Provide defines for really old option names */
	CURLOPT_FILE        = CURLOPT_WRITEDATA, /* name changed in 7.9.7 */
	CURLOPT_INFILE      = CURLOPT_READDATA, /* name changed in 7.9.7 */
	CURLOPT_WRITEHEADER = CURLOPT_HEADERDATA,

	/* Since long deprecated options with no code in the lib that does anything
		with them. */
	CURLOPT_WRITEINFO   = CURLOPT_OBSOLETE40,
	CURLOPT_CLOSEPOLICY = CURLOPT_OBSOLETE72,

	/* Backwards compatibility with older names */
	/* These are scheduled to disappear by 2011 */

	/* This was added in version 7.19.1 */
	CURLOPT_POST301 = CURLOPT_POSTREDIR,

	/* These are scheduled to disappear by 2009 */

	/* The following were added in 7.17.0 */
	CURLOPT_SSLKEYPASSWD = CURLOPT_KEYPASSWD,
	CURLOPT_FTPAPPEND    = CURLOPT_APPEND,
	CURLOPT_FTPLISTONLY  = CURLOPT_DIRLISTONLY,
	CURLOPT_FTP_SSL      = CURLOPT_USE_SSL,

	/* The following were added earlier */
	CURLOPT_SSLCERTPASSWD = CURLOPT_KEYPASSWD,
	CURLOPT_KRB4LEVEL     = CURLOPT_KRBLEVEL,
$

end ifdef -- not CURL_NO_OLDIES

/* Below here follows defines for the CURLOPT_IPRESOLVE option. If a host
   name resolves addresses using more than one IP protocol version, this
   option might be handy to force libcurl to use a specific IP version. */
public constant
	CURL_IPRESOLVE_WHATEVER = 0, /* default, resolves addresses to all IP
                                    versions that your system allows */
	CURL_IPRESOLVE_V4       = 1, /* resolve to IPv4 addresses */
	CURL_IPRESOLVE_V6       = 2, /* resolve to IPv6 addresses */
$

/* three convenient "aliases" that follow the name scheme better */
public constant CURLOPT_RTSPHEADER = CURLOPT_HTTPHEADER

/* These enums are for use with the CURLOPT_HTTP_VERSION option. */
public constant
	CURL_HTTP_VERSION_NONE =  0, /* setting this means we don't care, and that we'd
	                                like the library to choose the best possible
	                                for us! */
	CURL_HTTP_VERSION_1_0  =  1, /* please use HTTP 1.0 in the request */
	CURL_HTTP_VERSION_1_1  =  2, /* please use HTTP 1.1 in the request */
	CURL_HTTP_VERSION_2_0  =  3, /* please use HTTP 2 in the request */
	CURL_HTTP_VERSION_2TLS =  4, /* use version 2 for HTTPS, version 1.1 for HTTP */
	CURL_HTTP_VERSION_2_PRIOR_KNOWLEDGE = 5, /* please use HTTP 2 without HTTP/1.1 Upgrade */
	CURL_HTTP_VERSION_3    = 30, /* Makes use of explicit HTTP/3 without fallback.
	                                Use CURLOPT_ALTSVC to enable HTTP/3 upgrade */
	CURL_HTTP_VERSION_LAST = 31, /* *ILLEGAL* http version */
$

/* Convenience definition simple because the name of the version is HTTP/2 and
   not 2.0. The 2_0 version of the enum name was set while the version was
   still planned to be 2.0 and we stick to it for compatibility. */
public constant CURL_HTTP_VERSION_2 = CURL_HTTP_VERSION_2_0

/*
 * Public API enums for RTSP requests
 */
 public constant
    CURL_RTSPREQ_NONE          =  0, /* first in list */
    CURL_RTSPREQ_OPTIONS       =  1,
    CURL_RTSPREQ_DESCRIBE      =  2,
    CURL_RTSPREQ_ANNOUNCE      =  3,
    CURL_RTSPREQ_SETUP         =  4,
    CURL_RTSPREQ_PLAY          =  5,
    CURL_RTSPREQ_PAUSE         =  6,
    CURL_RTSPREQ_TEARDOWN      =  7,
    CURL_RTSPREQ_GET_PARAMETER =  8,
    CURL_RTSPREQ_SET_PARAMETER =  9,
    CURL_RTSPREQ_RECORD        = 10,
    CURL_RTSPREQ_RECEIVE       = 11,
    CURL_RTSPREQ_LAST          = 12, /* last in list */
$

/* These enums are for use with the CURLOPT_NETRC option. */
public enum type CURL_NETRC_OPTION
	CURL_NETRC_IGNORED = 0, /* The .netrc will never be read.
                             * This is the default. */
	CURL_NETRC_OPTIONAL,    /* A user:password in the URL will be preferred
                             * to one in the .netrc. */
	CURL_NETRC_REQUIRED,    /* A user:password in the URL will be ignored.
                             * Unless one is set programmatically, the .netrc
                             * will be queried. */
	CURL_NETRC_LAST
end type

public constant
	CURL_SSLVERSION_DEFAULT = 0,
	CURL_SSLVERSION_TLSv1   = 1, /* TLS 1.x */
	CURL_SSLVERSION_SSLv2   = 2,
	CURL_SSLVERSION_SSLv3   = 3,
	CURL_SSLVERSION_TLSv1_0 = 4,
	CURL_SSLVERSION_TLSv1_1 = 5,
	CURL_SSLVERSION_TLSv1_2 = 6,
	CURL_SSLVERSION_TLSv1_3 = 7,
	CURL_SSLVERSION_LAST    = 8, /* never use, keep last */
$

public constant
	CURL_SSLVERSION_MAX_NONE    =      0,
	CURL_SSLVERSION_MAX_DEFAULT =  65536, -- (CURL_SSLVERSION_TLSv1   << 16),
	CURL_SSLVERSION_MAX_TLSv1_0 = 262144, -- (CURL_SSLVERSION_TLSv1_0 << 16),
	CURL_SSLVERSION_MAX_TLSv1_1 = 327680, -- (CURL_SSLVERSION_TLSv1_1 << 16),
	CURL_SSLVERSION_MAX_TLSv1_2 = 393216, -- (CURL_SSLVERSION_TLSv1_2 << 16),
	CURL_SSLVERSION_MAX_TLSv1_3 = 458752, -- (CURL_SSLVERSION_TLSv1_3 << 16),
	/* never use, keep last */
	CURL_SSLVERSION_MAX_LAST    = 524288, -- (CURL_SSLVERSION_LAST    << 16)
$

public constant -- CURL_TLSAUTH
	CURL_TLSAUTH_NONE = 0,
	CURL_TLSAUTH_SRP  = 1,
	CURL_TLSAUTH_LAST = 2, /* never use, keep last */
$

/* symbols to use with CURLOPT_POSTREDIR.
   CURL_REDIR_POST_301, CURL_REDIR_POST_302 and CURL_REDIR_POST_303
   can be bitwise ORed so that CURL_REDIR_POST_301 | CURL_REDIR_POST_302
   | CURL_REDIR_POST_303 == CURL_REDIR_POST_ALL */

public constant
	CURL_REDIR_GET_ALL  = 0,
	CURL_REDIR_POST_301 = 1,
	CURL_REDIR_POST_302 = 2,
	CURL_REDIR_POST_303 = 4,
	CURL_REDIR_POST_ALL = 7, -- (CURL_REDIR_POST_301|CURL_REDIR_POST_302|CURL_REDIR_POST_303)
$

public enum type curl_TimeCond
	CURL_TIMECOND_NONE = 0,
	CURL_TIMECOND_IFMODSINCE,
	CURL_TIMECOND_IFUNMODSINCE,
	CURL_TIMECOND_LASTMOD,
	CURL_TIMECOND_LAST
end type

/* Special size_t value signaling a null-terminated string. */
public constant CURL_ZERO_TERMINATED = (-1)

/* curl_strequal() and curl_strnequal() are subject for removal in a future
   release */

public function curl_strequal( sequence s1, sequence s2 )

	atom s1_addr = allocate_string( s1, TRUE )
	atom s2_addr = allocate_string( s2, TRUE )

	return c_func( _curl_strequal, {s1_addr,s2_addr} )
end function

public function curl_strnequal( sequence s1, sequence s2, atom n )

	atom s1_addr = allocate_string( s1, TRUE )
	atom s2_addr = allocate_string( s2, TRUE )

	return c_func( _curl_strnequal, {s1_addr,s2_addr,n} )
end function

/*
 * NAME curl_mime_init()
 *
 * DESCRIPTION
 *
 * Create a mime context and return its handle. The easy parameter is the
 * target handle.
 */
public function curl_mime_init( atom curl )
	return c_func( _curl_mime_init, {curl} )
end function

/*
 * NAME curl_mime_free()
 *
 * DESCRIPTION
 *
 * release a mime handle and its substructures.
 */
public procedure curl_mime_free( atom mime )
	c_proc( _curl_mime_free, {mime} )
end procedure

/*
 * NAME curl_mime_addpart()
 *
 * DESCRIPTION
 *
 * Append a new empty part to the given mime context and return a handle to
 * the created part.
 */
public function curl_mime_addpart( atom mime )
	return c_func( _curl_mime_addpart, {mime} )
end function

/*
 * NAME curl_mime_name()
 *
 * DESCRIPTION
 *
 * Set mime/form part name.
 */
public function curl_mime_name( atom mime, object name )

	if sequence( name ) then
		name = allocate_string( name, TRUE )
	end if

	return c_func( _curl_mime_name, {mime,name} )
end function

/*
 * NAME curl_mime_filename()
 *
 * DESCRIPTION
 *
 * Set mime part remote file name.
 */
public function curl_mime_filename( atom mime, object filename )

	if sequence( filename ) then
		filename = allocate_string( filename, TRUE )
	end if

	return c_func( _curl_mime_filename, {mime,filename} )
end function

/*
 * NAME curl_mime_type()
 *
 * DESCRIPTION
 *
 * Set mime part type.
 */
public function curl_mime_type( atom mime, object mimetype )

	if sequence( mimetype ) then
		mimetype = allocate_string( mimetype, TRUE )
	end if

	return c_func( _curl_mime_type, {mime,mimetype} )
end function

/*
 * NAME curl_mime_encoder()
 *
 * DESCRIPTION
 *
 * Set mime data transfer encoder.
 */
public function curl_mime_encoder( atom mime, object encoding )

	if sequence( encoding ) then
		encoding = allocate_string( encoding, TRUE )
	end if

	return c_func( _curl_mime_encoder, {mime,encoding} )
end function

/*
 * NAME curl_mime_data()
 *
 * DESCRIPTION
 *
 * Set mime part data source from memory data,
 */
public function curl_mime_data( atom mime, object data, atom datasize = length(data) )

	if sequence( data ) then
		datasize = length( data )
		atom ptr = allocate_data( datasize, TRUE )
		poke( ptr, data )
		data = ptr
	end if

	return c_func( _curl_mime_data, {mime,data,datasize} )
end function

/*
 * NAME curl_mime_data_cb()
 *
 * DESCRIPTION
 *
 * Set mime part data source from callback function.
 */
public function curl_mime_data_cb( atom mime, atom datasize, atom readfunc, atom seekfunc, atom freefunc, atom arg = NULL )
	return c_func( _curl_mime_data_cb, {mime,datasize,readfunc,seekfunc,freefunc,arg} )
end function

/*
 * NAME curl_mime_subparts()
 *
 * DESCRIPTION
 *
 * Set mime part data source from subparts.
 */
public function curl_mime_subparts( atom part, atom subparts )
	return c_func( _curl_mime_subparts, {part,subparts} )
end function

/*
 * NAME curl_mime_headers()
 *
 * DESCRIPTION
 *
 * Set mime part headers.
 */
public function curl_mime_headers( atom part, atom headers, integer take_ownership )
	return c_func( _curl_mime_headers, {part,headers,take_ownership} )
end function

public enum type CURLformoption
	CURLFORM_NOTHING = 0,    /********* the first one is unused ************/
	CURLFORM_COPYNAME,
	CURLFORM_PTRNAME,
	CURLFORM_NAMELENGTH,
	CURLFORM_COPYCONTENTS,
	CURLFORM_PTRCONTENTS,
	CURLFORM_CONTENTSLENGTH,
	CURLFORM_FILECONTENT,
	CURLFORM_ARRAY,
	CURLFORM_OBSOLETE,
	CURLFORM_FILE,

	CURLFORM_BUFFER,
	CURLFORM_BUFFERPTR,
	CURLFORM_BUFFERLENGTH,
	CURLFORM_CONTENTTYPE,
	CURLFORM_CONTENTHEADER,
	CURLFORM_FILENAME,
	CURLFORM_END,
	CURLFORM_OBSOLETE2,

	CURLFORM_STREAM,
	CURLFORM_CONTENTLEN, /* added in 7.46.0, provide a curl_off_t length */

	CURLFORM_LASTENTRY /* the last unused */
end type

/* use this for multipart formpost building */
/* Returns code for curl_formadd()
 *
 * Returns:
 * CURL_FORMADD_OK             on success
 * CURL_FORMADD_MEMORY         if the FormInfo allocation fails
 * CURL_FORMADD_OPTION_TWICE   if one option is given twice for one Form
 * CURL_FORMADD_NULL           if a null pointer was given for a char
 * CURL_FORMADD_MEMORY         if the allocation of a FormInfo struct failed
 * CURL_FORMADD_UNKNOWN_OPTION if an unknown option was used
 * CURL_FORMADD_INCOMPLETE     if the some FormInfo is not complete (or error)
 * CURL_FORMADD_MEMORY         if a curl_httppost struct cannot be allocated
 * CURL_FORMADD_MEMORY         if some allocation for string copying failed.
 * CURL_FORMADD_ILLEGAL_ARRAY  if an illegal option is used in an array
 *
 ***************************************************************************/
public enum type CURLFORMcode
	CURL_FORMADD_OK = 0, /* first, no error */
	CURL_FORMADD_MEMORY,
	CURL_FORMADD_OPTION_TWICE,
	CURL_FORMADD_NULL,
	CURL_FORMADD_UNKNOWN_OPTION,
	CURL_FORMADD_INCOMPLETE,
	CURL_FORMADD_ILLEGAL_ARRAY,
	CURL_FORMADD_DISABLED, /* libcurl was built with this disabled */
	CURL_FORMADD_LAST /* last */
end type

/*
 * NAME curl_formadd()
 *
 * DESCRIPTION
 *
 * Pretty advanced function for building multi-part formposts. Each invoke
 * adds one part that together construct a full post. Then use
 * CURLOPT_HTTPPOST to send it off to libcurl.
 */
public function curl_formadd( atom httppost, atom last_post, atom param )
	return c_func( _curl_formadd, {httppost,last_post,param} )
end function

/*
 * NAME curl_formget()
 *
 * DESCRIPTION
 *
 * Serialize a curl_httppost struct built with curl_formadd().
 * Accepts a void pointer as second argument which will be passed to
 * the curl_formget_callback function.
 * Returns 0 on success.
 */
public function curl_formget( atom form, atom arg, atom appendfunc )
	return c_func( _curl_formget, {form,arg,appendfunc} )
end function

/*
 * NAME curl_formfree()
 *
 * DESCRIPTION
 *
 * Free a multipart formpost previously built with curl_formadd().
 */
public procedure curl_formfree( atom form )
	c_proc( _curl_formfree, {form} )
end procedure

/*
 * NAME curl_getenv()
 *
 * DESCRIPTION
 *
 * Returns a malloc()'ed string that MUST be curl_free()ed after usage is
 * complete. DEPRECATED - see lib/README.curlx
 */
public function curl_getenv( sequence variable )

	atom addr = allocate_string( variable, TRUE )

	atom result = c_func( _curl_getenv, {addr} )
	sequence string = ""

	if result != NULL then
		string = peek_string( result )
		c_proc( _curl_free, {result} )
	end if

	return string
end function

/*
 * NAME curl_version()
 *
 * DESCRIPTION
 *
 * Returns a static ascii string of the libcurl version.
 */
public function curl_version()

	atom result = c_func( _curl_version, {} )
	sequence string = ""

	if result != NULL then
		string = peek_string( result )
	end if

	return string
end function

/*
 * NAME curl_easy_escape()
 *
 * DESCRIPTION
 *
 * Escapes URL strings (converts all letters consider illegal in URLs to their
 * %XX versions). This function returns a new allocated string or NULL if an
 * error occurred.
 */
public function curl_easy_escape( atom handle, sequence str, integer len = length(str) )

	atom addr = allocate_string( str, TRUE )

	atom result = c_func( _curl_easy_escape, {handle,addr,len} )
	sequence string = ""

	if result != NULL then
		string = peek_string( result )
		c_proc( _curl_free, {result} )
	end if

	return string
end function

/* the previous version: */
deprecate
public function curl_escape( sequence str, integer len = length(str) )

	atom addr = allocate_string( str, TRUE )

	atom result = c_func( _curl_escape, {addr,len} )
	sequence string = ""

	if result != NULL then
		string = peek_string( result )
		c_proc( _curl_free, {result} )
	end if

	return string
end function

/*
 * NAME curl_easy_unescape()
 *
 * DESCRIPTION
 *
 * Unescapes URL encoding in strings (converts all %XX codes to their 8bit
 * versions). This function returns a new allocated string or NULL if an error
 * occurred.
 * Conversion Note: On non-ASCII platforms the ASCII %XX codes are
 * converted into the host encoding.
 */
public function curl_easy_unescape( atom handle, sequence str, integer len = length(str) )

	atom addr = allocate_string( str, TRUE )
	atom outlength = allocate_data( sizeof(C_INT), TRUE )
	mem_set( outlength, NULL, sizeof(C_INT) )

	atom result = c_func( _curl_easy_unescape, {handle,addr,len,outlength} )
	sequence string = ""

	if result != NULL then
		len = peek4s( outlength )
		string = peek({ result, len })
		c_proc( _curl_free, {result} )
	end if

	return string
end function

/* the previous version */
deprecate
public function curl_unescape( sequence str, integer len = length(str) )

	atom addr = allocate_string( str, TRUE )

	atom result = c_func( _curl_unescape, {addr,len} )
	sequence string = ""

	if result != NULL then
		string = peek_string( result )
		c_proc( _curl_free, {result} )
	end if

	return string
end function

/*
 * NAME curl_free()
 *
 * DESCRIPTION
 *
 * Provided for de-allocation in the same translation unit that did the
 * allocation. Added in libcurl 7.10
 */
public procedure curl_free( atom p )
	c_proc( _curl_free, {p} )
end procedure

/*
 * NAME curl_global_init()
 *
 * DESCRIPTION
 *
 * curl_global_init() should be invoked exactly once for each application that
 * uses libcurl and before any call of other libcurl functions.
 *
 * This function is not thread-safe!
 */
public function curl_global_init( atom flags = CURL_GLOBAL_DEFAULT )
	return c_func( _curl_global_init, {flags} )
end function

/*
 * NAME curl_global_init_mem()
 *
 * DESCRIPTION
 *
 * curl_global_init() or curl_global_init_mem() should be invoked exactly once
 * for each application that uses libcurl.  This function can be used to
 * initialize libcurl and set user defined memory management callback
 * functions.  Users can implement memory management routines to check for
 * memory leaks, check for mis-use of the curl library etc.  User registered
 * callback routines will be invoked by this library instead of the system
 * memory management routines like malloc, free etc.
 */
public function curl_global_init_mem( atom flags, atom mallocfunc, atom freefunc, atom reallocfunc, atom strdupfunc, atom callocfunc )
	return c_func( _curl_global_init_mem, {flags,mallocfunc,freefunc,reallocfunc,strdupfunc,callocfunc} )
end function

/*
 * NAME curl_global_cleanup()
 *
 * DESCRIPTION
 *
 * curl_global_cleanup() should be invoked exactly once for each application
 * that uses libcurl
 */
public procedure curl_global_cleanup()
	c_proc( _curl_global_cleanup, {} )
end procedure

/*
 * NAME curl_global_sslset()
 *
 * DESCRIPTION
 *
 * When built with multiple SSL backends, curl_global_sslset() allows to
 * choose one. This function can only be called once, and it must be called
 * *before* curl_global_init().
 *
 * The backend can be identified by the id (e.g. CURLSSLBACKEND_OPENSSL). The
 * backend can also be specified via the name parameter (passing -1 as id).
 * If both id and name are specified, the name will be ignored. If neither id
 * nor name are specified, the function will fail with
 * CURLSSLSET_UNKNOWN_BACKEND and set the "avail" pointer to the
 * NULL-terminated list of available backends.
 *
 * Upon success, the function returns CURLSSLSET_OK.
 *
 * If the specified SSL backend is not available, the function returns
 * CURLSSLSET_UNKNOWN_BACKEND and sets the "avail" pointer to a NULL-terminated
 * list of available SSL backends.
 *
 * The SSL backend can be set only once. If it has already been set, a
 * subsequent attempt to change it will result in a CURLSSLSET_TOO_LATE.
 */

public function curl_global_sslset( atom id, object name = NULL, atom avail = NULL )

	if sequence( name ) then
		name = allocate_string( name, TRUE )
	end if

	return c_func( _curl_global_sslset, {id,name,avail})
end function

public enum type CURLsslset
	CURLSSLSET_OK = 0,
	CURLSSLSET_UNKNOWN_BACKEND,
	CURLSSLSET_TOO_LATE,
	CURLSSLSET_NO_BACKENDS /* libcurl was built without any SSL support */
end type

/* linked-list structure for the CURLOPT_QUOTE option (and other) */

ifdef BITS64 then

constant
	curl_slist__data  =  0, -- char*
	curl_slist__next  =  8, -- struct curl_slist*
	SIZEOF_CURL_SLIST = 16,
$

elsedef -- BITS32

constant
	curl_slist__data  = 0, -- char*
	curl_slist__next  = 4, -- struct curl_slist*
	SIZEOF_CURL_SLIST = 8,
$

end ifdef

/*
 * NAME curl_slist_append()
 *
 * DESCRIPTION
 *
 * Appends a string to a linked list. If no list exists, it will be created
 * first. Returns the new list, after appending.
 */
public function curl_slist_append( atom slist, sequence string )

	atom addr = allocate_string( string, TRUE )

	return c_func( _curl_slist_append, {slist,addr} )
end function

/*
 * NAME curl_slist_free_all()
 *
 * DESCRIPTION
 *
 * free a previously built curl_slist.
 */
public procedure curl_slist_free_all( atom slist )
	c_proc( _curl_slist_free_all, {slist} )
end procedure

/*
 * NAME curl_slist_values()
 *
 * DESCRIPTION
 *
 * Returns a sequence of all values in the list.
 */
public function curl_slist_values( atom slist )

	sequence values = {}

	while slist != NULL do

		object data = peek_pointer( slist + curl_slist__data )
		sequence str = ""

		if data != NULL then
			str = peek_string( data )
		end if

		values = append( values, str )

		slist = peek_pointer( slist + curl_slist__next )
	end while

	return values
end function

/*
 * NAME curl_getdate()
 *
 * DESCRIPTION
 *
 * Returns the time, in seconds since 1 Jan 1970 of the time string given in
 * the first argument. The time argument in the second parameter is unused
 * and should be set to NULL.
 */
public function curl_getdate( sequence datestring, atom now = NULL )

	atom addr = allocate_string( datestring, TRUE )

	return c_func( _curl_getdate, {addr,now} )
end function

public constant
	CURLINFO_STRING   = #100000,
	CURLINFO_LONG     = #200000,
	CURLINFO_DOUBLE   = #300000,
	CURLINFO_SLIST    = #400000,
	CURLINFO_SOCKET   = #500000,
	CURLINFO_OFF_T    = #600000,
	CURLINFO_MASK     = #0FFFFF,
	CURLINFO_TYPEMASK = #F00000,
$

public type curlinfo_string( integer x )
	return and_bits( x, CURLINFO_TYPEMASK ) = CURLINFO_STRING
end type

public type curlinfo_long( integer x )
	return and_bits( x, CURLINFO_TYPEMASK ) = CURLINFO_LONG
end type

public type curlinfo_double( integer x )
	return and_bits( x, CURLINFO_TYPEMASK ) = CURLINFO_DOUBLE
end type

public type curlinfo_slist( integer x )
	return and_bits( x, CURLINFO_TYPEMASK ) = CURLINFO_SLIST
end type

public type curlinfo_socket( integer x )
	return and_bits( x, CURLINFO_TYPEMASK ) = CURLINFO_SOCKET
end type

public type curlinfo_off_t( integer x )
	return and_bits( x, CURLINFO_TYPEMASK ) = CURLINFO_OFF_T
end type

sequence curlinfo_names = {
	"CURLINFO_EFFECTIVE_URL",
	"CURLINFO_RESPONSE_CODE",
	"CURLINFO_TOTAL_TIME",
	"CURLINFO_NAMELOOKUP_TIME",
	"CURLINFO_CONNECT_TIME",
	"CURLINFO_PRETRANSFER_TIME",
	"CURLINFO_SIZE_UPLOAD",
	"CURLINFO_SIZE_DOWNLOAD",
	"CURLINFO_SPEED_DOWNLOAD",
	"CURLINFO_SPEED_UPLOAD",
	"CURLINFO_HEADER_SIZE",
	"CURLINFO_REQUEST_SIZE",
	"CURLINFO_SSL_VERIFYRESULT",
	"CURLINFO_FILETIME",
	"CURLINFO_CONTENT_LENGTH_DOWNLOAD",
	"CURLINFO_CONTENT_LENGTH_UPLOAD",
	"CURLINFO_STARTTRANSFER_TIME",
	"CURLINFO_CONTENT_TYPE",
	"CURLINFO_REDIRECT_TIME",
	"CURLINFO_REDIRECT_COUNT",
	"CURLINFO_PRIVATE",
	"CURLINFO_HTTP_CONNECTCODE",
	"CURLINFO_HTTPAUTH_AVAIL",
	"CURLINFO_PROXYAUTH_AVAIL",
	"CURLINFO_OS_ERRNO",
	"CURLINFO_NUM_CONNECTS",
	"CURLINFO_SSL_ENGINES",
	"CURLINFO_COOKIELIST",
	"CURLINFO_LASTSOCKET",
	"CURLINFO_FTP_ENTRY_PATH",
	"CURLINFO_REDIRECT_URL",
	"CURLINFO_PRIMARY_IP",
	"CURLINFO_APPCONNECT_TIME",
	"CURLINFO_CERTINFO",
	"CURLINFO_CONDITION_UNMET",
	"CURLINFO_RTSP_SESSION_ID",
	"CURLINFO_RTSP_CLIENT_CSEQ",
	"CURLINFO_RTSP_SERVER_CSEQ",
	"CURLINFO_RTSP_CSEQ_RECV",
	"CURLINFO_PRIMARY_PORT",
	"CURLINFO_LOCAL_IP",
	"CURLINFO_LOCAL_PORT",
	"CURLINFO_TLS_SESSION",
	"CURLINFO_ACTIVESOCKET",
	"CURLINFO_TLS_SSL_PTR",
	"CURLINFO_HTTP_VERSION",
	"CURLINFO_PROXY_SSL_VERIFYRESULT",
	"CURLINFO_PROTOCOL",
	"CURLINFO_SCHEME",
	"CURLINFO_TOTAL_TIME_T",
	"CURLINFO_NAMELOOKUP_TIME_T",
	"CURLINFO_CONNECT_TIME_T",
	"CURLINFO_PRETRANSFER_TIME_T",
	"CURLINFO_STARTTRANSFER_TIME_T",
	"CURLINFO_REDIRECT_TIME_T",
	"CURLINFO_APPCONNECT_TIME_T",
	"CURLINFO_RETRY_AFTER",
	"CURLINFO_EFFECTIVE_METHOD",
	"CURLINFO_PROXY_ERROR"
}

export function curlinfo_name( integer opt )
	integer nu = and_bits(opt,CURLINFO_MASK)
	return curlopt_names[nu]
end function

public enum type CURLINFO
	CURLINFO_NONE                    =       0,
	CURLINFO_EFFECTIVE_URL           = #100001, -- CURLINFO_STRING +  1,
	CURLINFO_RESPONSE_CODE           = #200002, -- CURLINFO_LONG   +  2,
	CURLINFO_TOTAL_TIME              = #300003, -- CURLINFO_DOUBLE +  3,
	CURLINFO_NAMELOOKUP_TIME         = #300004, -- CURLINFO_DOUBLE +  4,
	CURLINFO_CONNECT_TIME            = #300005, -- CURLINFO_DOUBLE +  5,
	CURLINFO_PRETRANSFER_TIME        = #300006, -- CURLINFO_DOUBLE +  6,
	CURLINFO_SIZE_UPLOAD             = #300007, -- CURLINFO_DOUBLE +  7,
	CURLINFO_SIZE_DOWNLOAD           = #300008, -- CURLINFO_DOUBLE +  8,
	CURLINFO_SPEED_DOWNLOAD          = #300009, -- CURLINFO_DOUBLE +  9,
	CURLINFO_SPEED_UPLOAD            = #30000A, -- CURLINFO_DOUBLE + 10,
	CURLINFO_HEADER_SIZE             = #20000B, -- CURLINFO_LONG   + 11,
	CURLINFO_REQUEST_SIZE            = #20000C, -- CURLINFO_LONG   + 12,
	CURLINFO_SSL_VERIFYRESULT        = #20000D, -- CURLINFO_LONG   + 13,
	CURLINFO_FILETIME                = #20000E, -- CURLINFO_LONG   + 14,
	CURLINFO_CONTENT_LENGTH_DOWNLOAD = #30000F, -- CURLINFO_DOUBLE + 15,
	CURLINFO_CONTENT_LENGTH_UPLOAD   = #300010, -- CURLINFO_DOUBLE + 16,
	CURLINFO_STARTTRANSFER_TIME      = #300011, -- CURLINFO_DOUBLE + 17,
	CURLINFO_CONTENT_TYPE            = #100012, -- CURLINFO_STRING + 18,
	CURLINFO_REDIRECT_TIME           = #300013, -- CURLINFO_DOUBLE + 19,
	CURLINFO_REDIRECT_COUNT          = #200014, -- CURLINFO_LONG   + 20,
	CURLINFO_PRIVATE                 = #100015, -- CURLINFO_STRING + 21,
	CURLINFO_HTTP_CONNECTCODE        = #200016, -- CURLINFO_LONG   + 22,
	CURLINFO_HTTPAUTH_AVAIL          = #200017, -- CURLINFO_LONG   + 23,
	CURLINFO_PROXYAUTH_AVAIL         = #200018, -- CURLINFO_LONG   + 24,
	CURLINFO_OS_ERRNO                = #200019, -- CURLINFO_LONG   + 25,
	CURLINFO_NUM_CONNECTS            = #20001A, -- CURLINFO_LONG   + 26,
	CURLINFO_SSL_ENGINES             = #40001B, -- CURLINFO_SLIST  + 27,
	CURLINFO_COOKIELIST              = #40001C, -- CURLINFO_SLIST  + 28,
	CURLINFO_LASTSOCKET              = #20001D, -- CURLINFO_LONG   + 29,
	CURLINFO_FTP_ENTRY_PATH          = #10001E, -- CURLINFO_STRING + 30,
	CURLINFO_REDIRECT_URL            = #10001F, -- CURLINFO_STRING + 31,
	CURLINFO_PRIMARY_IP              = #100020, -- CURLINFO_STRING + 32,
	CURLINFO_APPCONNECT_TIME         = #300021, -- CURLINFO_DOUBLE + 33,
	CURLINFO_CERTINFO                = #400022, -- CURLINFO_SLIST  + 34,
	CURLINFO_CONDITION_UNMET         = #200023, -- CURLINFO_LONG   + 35,
	CURLINFO_RTSP_SESSION_ID         = #100024, -- CURLINFO_STRING + 36,
	CURLINFO_RTSP_CLIENT_CSEQ        = #200025, -- CURLINFO_LONG   + 37,
	CURLINFO_RTSP_SERVER_CSEQ        = #200026, -- CURLINFO_LONG   + 38,
	CURLINFO_RTSP_CSEQ_RECV          = #200027, -- CURLINFO_LONG   + 39,
	CURLINFO_PRIMARY_PORT            = #200028, -- CURLINFO_LONG   + 40,
	CURLINFO_LOCAL_IP                = #100029, -- CURLINFO_STRING + 41,
	CURLINFO_LOCAL_PORT              = #20002A, -- CURLINFO_LONG   + 42,
	CURLINFO_TLS_SESSION             = #40002B, -- CURLINFO_SLIST  + 43,
	CURLINFO_ACTIVESOCKET            = #50002C, -- CURLINFO_SOCKET + 44,
	CURLINFO_TLS_SSL_PTR             = #40002D, -- CURLINFO_SLIST  + 45,
	CURLINFO_HTTP_VERSION            = #20002E, -- CURLINFO_LONG   + 46,
	CURLINFO_PROXY_SSL_VERIFYRESULT  = #20002F, -- CURLINFO_LONG   + 47,
	CURLINFO_PROTOCOL                = #200030, -- CURLINFO_LONG   + 48,
	CURLINFO_SCHEME                  = #100031, -- CURLINFO_STRING + 49,
	CURLINFO_TOTAL_TIME_T            = #600032, -- CURLINFO_OFF_T  + 50,
	CURLINFO_NAMELOOKUP_TIME_T       = #600033, -- CURLINFO_OFF_T  + 51,
	CURLINFO_CONNECT_TIME_T          = #600034, -- CURLINFO_OFF_T  + 52,
	CURLINFO_PRETRANSFER_TIME_T      = #600035, -- CURLINFO_OFF_T  + 53,
	CURLINFO_STARTTRANSFER_TIME_T    = #600036, -- CURLINFO_OFF_T  + 54,
	CURLINFO_REDIRECT_TIME_T         = #600037, -- CURLINFO_OFF_T  + 55,
	CURLINFO_APPCONNECT_TIME_T       = #600038, -- CURLINFO_OFF_T  + 56,
	CURLINFO_RETRY_AFTER             = #600039, -- CURLINFO_OFF_T  + 57,
	CURLINFO_EFFECTIVE_METHOD        = #10003A, -- CURLINFO_STRING + 58,
	CURLINFO_PROXY_ERROR             = #20003B, -- CURLINFO_LONG   + 59,
	CURLINFO_LASTONE                 =      59
end type

/* CURLINFO_RESPONSE_CODE is the new name for the option previously known as
   CURLINFO_HTTP_CODE */
public constant CURLINFO_HTTP_CODE = CURLINFO_RESPONSE_CODE

public enum type curl_closepolicy
	CURL_CLOSEPOLICY_NONE = 0, /* first, never use this */
	CURL_CLOSEPOLICY_OLDEST,
	CURL_CLOSEPOLICY_LEAST_RECENTLY_USED,
	CURL_CLOSEPOLICY_LEAST_TRAFFIC,
	CURL_CLOSEPOLICY_SLOWEST,
	CURL_CLOSEPOLICY_CALLBACK,
	CURL_CLOSEPOLICY_LAST /* last, never use this */
end type

public constant
	CURL_GLOBAL_SSL       = 1, -- (1<<0) /* no purpose since since 7.57.0 */
	CURL_GLOBAL_WIN32     = 2, -- (1<<1)
	CURL_GLOBAL_ALL       = 3, -- (CURL_GLOBAL_SSL|CURL_GLOBAL_WIN32)
	CURL_GLOBAL_NOTHING   = 0,
	CURL_GLOBAL_DEFAULT   = CURL_GLOBAL_ALL,
	CURL_GLOBAL_ACK_EINTR = 4, -- (1<<2),
$
/*****************************************************************************
 * Setup defines, protos etc for the sharing stuff.
 */

public enum type curl_lock_data
	CURL_LOCK_DATA_NONE = 0,
	/*  CURL_LOCK_DATA_SHARE is used internally to say that
     *  the locking is just made to change the internal state of the share
     *  itself.
     */
	CURL_LOCK_DATA_SHARE,
	CURL_LOCK_DATA_COOKIE,
	CURL_LOCK_DATA_DNS,
	CURL_LOCK_DATA_SSL_SESSION,
	CURL_LOCK_DATA_CONNECT,
	CURL_LOCK_DATA_LAST
end type

/* Different lock access types */
public enum type curl_lock_access
	CURL_LOCK_ACCESS_NONE   = 0, /* unspecified action */
	CURL_LOCK_ACCESS_SHARED = 1, /* for read perhaps */
	CURL_LOCK_ACCESS_SINGLE = 2, /* for write perhaps */
	CURL_LOCK_ACCESS_LAST        /* never use */
end type

public enum type CURLSHcode
	CURLSHE_OK = 0,       /* all is fine */
	CURLSHE_BAD_OPTION,   /* 1 */
	CURLSHE_IN_USE,       /* 2 */
	CURLSHE_INVALID,      /* 3 */
	CURLSHE_NOMEM,        /* 4 out of memory */
	CURLSHE_NOT_BUILT_IN, /* 5 feature not present in lib */
	CURLSHE_LAST          /* never use */
end type

public enum type CURLSHoption
	CURLSHOPT_NONE = 0,   /* don't use */
	CURLSHOPT_SHARE,      /* specify a data type to share */
	CURLSHOPT_UNSHARE,    /* specify which data type to stop sharing */
	CURLSHOPT_LOCKFUNC,   /* pass in a 'curl_lock_function' pointer */
	CURLSHOPT_UNLOCKFUNC, /* pass in a 'curl_unlock_function' pointer */
	CURLSHOPT_USERDATA,   /* pass in a user data pointer used in the lock/unlock
							 callback functions */
	CURLSHOPT_LAST        /* never use */
end type

public function curl_share_init()
	return c_func( _curl_share_init, {} )
end function

public function curl_share_setopt( atom handle, atom option, atom param )
	return c_func( _curl_share_setopt, {handle,option,param} )
end function

public function curl_share_cleanup( atom handle )
	return c_func( _curl_share_cleanup, {handle} )
end function

/****************************************************************************
 * Structures for querying information about the curl library at runtime.
 */

public enum type CURLversion
	CURLVERSION_FIRST = 0,
	CURLVERSION_SECOND,
	CURLVERSION_THIRD,
	CURLVERSION_FOURTH,
	CURLVERSION_FIFTH,
	CURLVERSION_SIXTH,
	CURLVERSION_SEVENTH,
	CURLVERSION_EIGHTH,
	CURLVERSION_LAST /* never actually use this */
end type

/* The 'CURLVERSION_NOW' is the symbolic name meant to be used by
   basically all programs ever that want to get version information. It is
   meant to be a built-in version number for what kind of struct the caller
   expects. If the struct ever changes, we redefine the NOW to another enum
   from above. */
public constant CURLVERSION_NOW = CURLVERSION_EIGHTH

public constant
	CURL_VERSION_IPV6         =         1, --  (1<<0) /* IPv6-enabled */
	CURL_VERSION_KERBEROS4    =         2, --  (1<<1) /* Kerberos V4 auth is supported (deprecated) */
	CURL_VERSION_SSL          =         4, --  (1<<2) /* SSL options are present */
	CURL_VERSION_LIBZ         =         8, --  (1<<3) /* libz features are present */
	CURL_VERSION_NTLM         =        16, --  (1<<4) /* NTLM auth is supported */
	CURL_VERSION_GSSNEGOTIATE =        32, --  (1<<5) /* Negotiate auth is supported (deprecated) */
	CURL_VERSION_DEBUG        =        64, --  (1<<6) /* Built with debug capabilities */
	CURL_VERSION_ASYNCHDNS    =       128, --  (1<<7) /* Asynchronous DNS resolves */
	CURL_VERSION_SPNEGO       =       256, --  (1<<8) /* SPNEGO auth is supported */
	CURL_VERSION_LARGEFILE    =       512, --  (1<<9) /* Supports files larger than 2GB */
	CURL_VERSION_IDN          =      1024, -- (1<<10) /* Internationized Domain Names are supported */
	CURL_VERSION_SSPI         =      2048, -- (1<<11) /* Built against Windows SSPI */
	CURL_VERSION_CONV         =      4096, -- (1<<12) /* Character conversions supported */
	CURL_VERSION_CURLDEBUG    =      8192, -- (1<<13) /* Debug memory tracking supported */
	CURL_VERSION_TLSAUTH_SRP  =     16384, -- (1<<14) /* TLS-SRP auth is supported */
	CURL_VERSION_NTLM_WB      =     32768, -- (1<<15) /* NTLM delegation to winbind helper is supported */
	CURL_VERSION_HTTP2        =     65536, -- (1<<16) /* HTTP2 support built-in */
	CURL_VERSION_GSSAPI       =    131072, -- (1<<17) /* Built against a GSS-API library */
	CURL_VERSION_KERBEROS5    =    262144, -- (1<<18) /* Kerberos V5 auth is supported */
	CURL_VERSION_UNIX_SOCKETS =    524288, -- (1<<19) /* Unix domain sockets support */
	CURL_VERSION_PSL          =   1048576, -- (1<<20) /* Mozilla's Public Suffix List, used for cookie domain verification */
	CURL_VERSION_HTTPS_PROXY  =   2097152, -- (1<<21) /* HTTPS-proxy support built-in */
	CURL_VERSION_MULTI_SSL    =   4194304, -- (1<<22) /* Multiple SSL backends available */
	CURL_VERSION_BROTLI       =   8388608, -- (1<<23) /* Brotli features are present. */
	CURL_VERSION_ALTSVC       =  16777216, -- (1<<24) /* Alt-Svc handling built-in */
	CURL_VERSION_HTTP3        =  33554432, -- (1<<25) /* HTTP3 support built-in */
	CURL_VERSION_ZSTD         =  67108864, -- (1<<26) /* zstd features are present */
	CURL_VERSION_UNICODE      = 134217728, -- (1<<27) /* Unicode support on Windows */
$

/*
 * NAME curl_version_info()
 *
 * DESCRIPTION
 *
 * This function returns a pointer to a static copy of the version info
 * struct. See above.
 */
public function curl_version_info( atom age = CURLVERSION_NOW )
	return c_func( _curl_version_info, {age} )
end function

/*
 * NAME curl_easy_strerror()
 *
 * DESCRIPTION
 *
 * The curl_easy_strerror function may be used to turn a CURLcode value
 * into the equivalent human readable error string.  This is useful
 * for printing meaningful error messages.
 */
public function curl_easy_strerror( atom errornum )

	atom result = c_func( _curl_easy_strerror, {errornum} )
	sequence string = ""

	if result != NULL then
		string = peek_string( result )
	end if

	return string
end function

/*
 * NAME curl_share_strerror()
 *
 * DESCRIPTION
 *
 * The curl_share_strerror function may be used to turn a CURLSHcode value
 * into the equivalent human readable error string.  This is useful
 * for printing meaningful error messages.
 */
public function curl_share_strerror( atom errornum )

	atom result = c_func( _curl_share_strerror, {errornum} )
	sequence string = ""

	if result != NULL then
		string = peek_string( result )
	end if

	return string
end function

/*
 * NAME curl_easy_pause()
 *
 * DESCRIPTION
 *
 * The curl_easy_pause function pauses or unpauses transfers. Select the new
 * state by setting the bitmask, use the convenience defines below.
 *
 */
public function curl_easy_pause( atom handle, integer bitmask )
	return c_func( _curl_easy_pause, {handle,bitmask} )
end function

public constant
	CURLPAUSE_RECV      = 1, -- (1<<0)
	CURLPAUSE_RECV_CONT = 0, -- (0)
	CURLPAUSE_SEND      = 2, -- (1<<2)
	CURLPAUSE_SEND_CONT = 0, -- (0)
	CURLPAUSE_ALL       = 3, -- (CURLPAUSE_RECV|CURLPAUSE_SEND)
	CURLPAUSE_CONT      = 0, -- (CURLPAUSE_RECV_CONT|CURLPAUSE_SEND_CONT)
$


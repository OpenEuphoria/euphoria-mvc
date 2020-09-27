
namespace replit_db

include std/dll.e
include std/error.e
include std/eumem.e
include std/net/url.e
include std/sequence.e
include std/types.e

include curl/easy.e
include mvc/strbuf.e
include mvc/utils.e

public sequence REPLIT_DB_URL = getenv( "REPLIT_DB_URL" )

if length( REPLIT_DB_URL ) = 0 then
	error:crash( "REPLIT_DB_URL not available" )
end if

public integer REPLIT_DB_VERBOSE

ifdef REPLIT_DB_VERBOSE then
	REPLIT_DB_VERBOSE = TRUE
elsedef
	REPLIT_DB_VERBOSE = FALSE
end ifdef

public function replit_db_set( sequence key, sequence value )

	atom curl = curl_easy_init()

	key = url:encode( key )
	value = url:encode( value )

	sequence postfields = sprintf( "%s=%s", {key,value} )

	curl_easy_setopt( curl, CURLOPT_URL, REPLIT_DB_URL )
	curl_easy_setopt( curl, CURLOPT_VERBOSE, REPLIT_DB_VERBOSE )
	curl_easy_setopt( curl, CURLOPT_COPYPOSTFIELDS, postfields )
	curl_easy_setopt( curl, CURLOPT_POST, TRUE )

	integer result = curl_easy_perform( curl )

	curl_easy_cleanup( curl )

	return result
end function

public function replit_db_get( sequence key )

	atom strbuf = strbuf_init()
	atom curl = curl_easy_init()

	key = url:encode( key )

	sequence request_url = sprintf( "%s/%s", {REPLIT_DB_URL,key} )

	curl_easy_setopt( curl, CURLOPT_URL, request_url )
	curl_easy_setopt( curl, CURLOPT_VERBOSE, REPLIT_DB_VERBOSE )
	curl_easy_setopt( curl, CURLOPT_WRITEFUNCTION, STRBUF_WRITE_FUNC )
	curl_easy_setopt( curl, CURLOPT_WRITEDATA, strbuf )

	object result = curl_easy_perform( curl )
	if result = CURLE_OK then
		result = strbuf_value( strbuf )
		result = url:decode( result )
	end if

	curl_easy_cleanup( curl )
	strbuf_free( strbuf )

	return result
end function

public function replit_db_del( sequence key )

	atom curl = curl_easy_init()

	key = url:encode( key )

	sequence request_url = sprintf( "%s/%s", {REPLIT_DB_URL,key} )

	curl_easy_setopt( curl, CURLOPT_URL, request_url )
	curl_easy_setopt( curl, CURLOPT_VERBOSE, REPLIT_DB_VERBOSE )
	curl_easy_setopt( curl, CURLOPT_CUSTOMREQUEST, "DELETE" )

	integer result = curl_easy_perform( curl )

	curl_easy_cleanup( curl )

	return result
end function

public function replit_db_list( sequence prefix )

	atom strbuf = strbuf_init()
	atom curl = curl_easy_init()

	prefix = url:encode( prefix )

	sequence request_url = sprintf( "%s?prefix=%s", {REPLIT_DB_URL,prefix} )

	curl_easy_setopt( curl, CURLOPT_URL, request_url )
	curl_easy_setopt( curl, CURLOPT_VERBOSE, REPLIT_DB_VERBOSE )
	curl_easy_setopt( curl, CURLOPT_WRITEFUNCTION, STRBUF_WRITE_FUNC )
	curl_easy_setopt( curl, CURLOPT_WRITEDATA, strbuf )

	object result = curl_easy_perform( curl )
	if result = CURLE_OK then

		result = strbuf_value( strbuf )
		result = stdseq:split( result, "\n" )

		for i = 1 to length( result ) do
			result[i] = url:decode( result[i] )
		end for
		
	end if

	curl_easy_cleanup( curl )
	strbuf_free( strbuf )

	return result
end function

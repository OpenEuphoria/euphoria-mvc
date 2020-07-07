
namespace headers

include std/map.e
include std/text.e
include std/types.e

include mvc/logger.e

-- name -> value headers
export map m_headers = map:new()

--
-- Shorthand for set_header()
--
public procedure header( sequence header_name, object header_value, object data = {} )
	set_header( header_name, header_value, data )
end procedure

--
-- Set an outgoing header value.
--
public procedure set_header( sequence header_name, object header_value, object data = {} )

	header_name = text:proper( header_name )

	if atom( header_value ) then
		header_value = sprint( header_value )

	elsif string( header_value ) then
		header_value = sprintf( header_value, data )

	elsif sequence_array( header_value ) and length( header_value ) = 1 then
		header_value = map:get( m_headers, header_name, {} ) & {header_value}

	end if

	map:put( m_headers, header_name, header_value )

end procedure

--
-- Get a header value.
--
public function get_header( sequence header_name, sequence default = "" )
	return map:get( m_headers, header_name, default )
end function

--
-- Unset a header.
--
public procedure unset_header( sequence header_name )

	map:remove( m_headers, header_name )

end procedure

--
-- Clear all headers.
--
public procedure clear_headers()

	map:clear( m_headers )

end procedure

--
-- Format headers into one string.
--
public function format_headers()

	sequence headers_data = ""
	sequence keys = map:keys( m_headers )

	for i = 1 to length( keys ) do

		object value = map:get( m_headers, keys[i] )
		log_trace( "key = %s, value = %s", {keys[i],value} )

		if sequence_array( value ) then
			for j = 1 to length( value ) do
				headers_data &= sprintf( "%s: %s\r\n", {keys[i],value[j]} )
			end for
		else
			if atom( value ) then value = sprint( value ) end if
			headers_data &= sprintf( "%s: %s\r\n", {keys[i],value} )
		end if

	end for

	return headers_data
end function


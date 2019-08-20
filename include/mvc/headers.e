
namespace headers

include std/map.e
include std/text.e
include std/types.e

include mvc/logger.e
include mvc/hooks.e

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

	integer task_id = task_self()
	header_name = text:proper( header_name )

	if atom( header_value ) then
		header_value = sprint( header_value )

	elsif string( header_value ) then
		header_value = sprintf( header_value, data )

	elsif sequence_array( header_value ) and length( header_value ) = 1 then
		header_value = map:nested_get( m_headers, {task_id,header_name}, {} ) & header_value

	end if

	map:nested_put( m_headers, {task_id,header_name}, header_value )

end procedure

--
-- Get a header value.
--
public function get_header( sequence header_name, sequence default = "" )

	integer task_id = task_self()
	object task_map = map:get( m_headers, task_id, map:new() )

	return map:get( task_map, header_name, default )
end function

--
-- Unset a header.
--
public procedure unset_header( sequence header_name )

	integer task_id = task_self()
	object task_map = map:get( m_headers, task_id, map:new() )

	map:remove( task_map, header_name )

end procedure

--
-- Format headers into one string.
--
public function format_headers()

	integer exit_code = 0
	integer task_id = task_self()

	sequence headers_data = ""

	exit_code = run_hooks( HOOK_HEADERS_START )
	if exit_code then return "" end if

	object task_map = map:get( m_headers, task_id, map:new() )
	sequence keys = map:keys( task_map )

	for i = 1 to length( keys ) do

		object value = map:get( task_map, keys[i] )

		if sequence_array( value ) then
			for j = 1 to length( value ) do
				headers_data &= sprintf( "%s: %s\r\n", {keys[i],value[j]} )
			end for
		else
			if atom( value ) then value = sprint( value ) end if
			headers_data &= sprintf( "%s: %s\r\n", {keys[i],value} )
		end if

	end for

	exit_code = run_hooks( HOOK_HEADERS_END )
	if exit_code then return "" end if

	return headers_data
end function


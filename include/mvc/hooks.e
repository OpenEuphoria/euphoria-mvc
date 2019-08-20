
namespace hooks

--
-- Hooks
--

enum
	HOOK_NAME,
	HOOK_LIST

sequence m_hooks = {}

public constant
	HOOK_APP_START      = new_hook_type( "app_start"      ),
	HOOK_APP_END        = new_hook_type( "app_end"        ),
	HOOK_REQUEST_START  = new_hook_type( "request_start"  ),
	HOOK_REQUEST_END    = new_hook_type( "request_end"    ),
	HOOK_HEADERS_START  = new_hook_type( "headers_start"  ),
	HOOK_HEADERS_END    = new_hook_type( "headers_end"    ),
	HOOK_RESPONSE_START = new_hook_type( "response_start" ),
	HOOK_RESPONSE_END   = new_hook_type( "response_end"   ),
$

--
-- Add new hook type.
--
public function new_hook_type( sequence name )

	sequence list = {}
	m_hooks = append( m_hooks, {name,list} )

	return length( m_hooks )
end function

--
-- Return a hook name.
--
public function get_hook_name( integer hook_type )
	return m_hooks[hook_type][HOOK_NAME]
end function

--
-- Insert a new hook.
--
public procedure insert_hook( integer hook_type, sequence func_name = get_hook_name(hook_type), integer func_id = routine_id(func_name) )
	m_hooks[hook_type][HOOK_LIST] = append( m_hooks[hook_type][HOOK_LIST], {func_name,func_id} )
end procedure

--
-- Run a list of hooks.
--
public function run_hooks( integer hook_type )

	object func_name, func_id
	integer exit_code = 0

	sequence hook_name = m_hooks[hook_type][HOOK_NAME]
	sequence hook_list = m_hooks[hook_type][HOOK_LIST]

	for i = 1 to length( hook_list ) do
		{func_name,func_id} = hook_list[i]

		exit_code = call_func( func_id, {} )
		if exit_code then exit end if

	end for

	return exit_code
end function


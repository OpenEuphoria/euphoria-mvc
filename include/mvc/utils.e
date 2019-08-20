
namespace utils

include std/convert.e
include std/get.e
without warning

include mvc/logger.e

--
-- Better environment variables
--

public enum
	AS_STRING = 0, -- basically does nothing, environment variables are already strings
	AS_INTEGER,    -- converts string to integer
	AS_NUMBER,     -- converts string to atom
	AS_OBJECT      -- converts string to object, e.g. "{1,2,3}" -> {1,2,3}

function as_default( integer as_type )

	if as_type = AS_STRING then
		return ""
	end if

	return 0
end function

function to_object( object val, object default )

	integer status
	object result

	{status,result} = stdget:value( val )

	if status != GET_SUCCESS then
		log_warn( "Failed to parse string %s as object", {val} )
		return default
	end if

	return result
end function

--
-- Look up an environment variable and optionally convert it to another type.
--
override function getenv( sequence env_name, integer env_type = AS_STRING, object default = as_default(env_type) )

	log_trace( "env_name = %s", {env_name} )
	log_trace( "env_type = %s", {env_type} )

	object env_value = eu:getenv( env_name )

	if atom( env_value ) then
		log_warn( "Environment variable %s not found!", {env_name} )
		env_value = default

	elsif env_type = AS_STRING then
		env_value = to_string( env_value )

	elsif env_type = AS_INTEGER then
		env_value = to_integer( env_value )

	elsif env_type = AS_NUMBER then
		env_value = to_number( env_value )

	elsif env_type = AS_OBJECT then
		env_value = to_object( env_value, default )

	end if

	log_trace( "env_value = %s", {env_value} )

	return env_value
end function


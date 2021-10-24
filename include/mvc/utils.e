
namespace utils

include std/dll.e
include std/machine.e
include std/convert.e
include std/get.e
include std/sequence.e
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

	object status, result
	{status,result} = stdget:value( val )

	if status != GET_SUCCESS then
		log_error( "Could not parse string: %s", {val} )
		return default
	end if

	return result
end function

--
-- Look up an environment variable and optionally convert it to another type.
--
override function getenv( sequence env_name, integer env_type = AS_STRING, object default = as_default(env_type) )
	log_trace( "env_name=%s, env_type=%s, default=%s", {env_name,env_type,default} )

	object env_value = eu:getenv( env_name )

	if atom( env_value ) then
		log_warn( "Environment variable not found: %s", {env_name} )
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

--
-- A faster/simpler decoding function than what's in std/net/url.e
--
public function url_decode( sequence str )
	log_trace( "str=%s", {str} )

	atom ptr = allocate_string( str )

    atom input = ptr
    atom output = ptr
	atom count = 0
	integer ch = 0

    while 1 do

        ch = peek( input )
        input += 1

        if ch = '+' then
            ch = ' '

        elsif ch = '%' then
            ch = hex_text( peek({input,2}) )
            input += 2

        end if

        poke( output, ch )
        output += 1

        if ch = '\0' then
            exit
        end if

        count += 1

    end while

    str = peek({ ptr, count })

	free( ptr )

	log_trace( "str=%s", {str} )

    return str
end function

constant M_DIR=22

--
-- A faster/simpler locating function that what's in std/filesys.e
--
public function locate_file( sequence names )
	log_trace( "names=%s", {names} )

ifdef WINDOWS then
	integer pathsep = ';'
	integer slash = '\\'
elsedef
	integer pathsep = ':'
	integer slash = '/'
end ifdef

	sequence path = getenv( "PATH" )
	log_trace( "PATH=%s", {path} )

	sequence paths = stdseq:split( path, pathsep )
	log_trace( "paths=%s", {paths} )

	if length( names ) and integer( names[1] ) then
		names = {names}
		log_trace( "names=%s", {names} )
	end if

	object d
	sequence result = ""

	for i = 1 to length( names ) do
		for j = 1 to length( paths ) do

			path = paths[j] & slash & names[i]
			d = machine_func( M_DIR, path )

			if sequence( d ) and length( d ) = 1 then
				result = path
				exit
			end if

		end for
	end for

	log_trace( "result=%s", {result} )

	return result
end function

ifdef WINDOWS then

constant SW_SHOWNORMAL = 1
constant shell32 = open_dll( "shell32.dll" )
constant xShellExecuteA = define_c_func( shell32, "ShellExecuteA", {C_HANDLE,C_POINTER,C_POINTER,C_POINTER,C_POINTER,C_INT}, C_HANDLE )

end ifdef

--
-- Start a url with the default browser.
--
public procedure start_url( sequence url )
	log_trace( "url = %s", {url} )

ifdef WINDOWS then

	c_func( xShellExecuteA, {hwnd,allocate_string("open",TRUE),allocate_string(url,TRUE),NULL,NULL,SW_SHOWNORMAL} )

elsifdef LINUX then

	sequence command = locate_file({ "sensible-browser", "xdg-open", "gnome-open", "kde-open", "x-www-browser" })
	log_trace( "command = %s", {command} )

	if length( command ) then
		system( sprintf(`%s "%s"`,{command,url}), 2 )
	end if

end ifdef

end procedure


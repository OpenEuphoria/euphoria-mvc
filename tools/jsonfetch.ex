--
-- This is a simple utility to query JSON files using mvc/json.e
--

include std/io.e
include mvc/json.e

procedure main()

    sequence cmd = command_line()
    if length( cmd ) < 4 then
        return
    end if

    sequence json = json_parse_file( cmd[3] )
    if json[J_TYPE] = JSON_NONE then
        printf( STDERR, "%s\n", {json_last_error()} )
        return
    end if

    object value = json_fetch( json, cmd[4] )
    if atom( value ) then
        printf( STDERR, "Key \"%s\" not found\n", {cmd[4]} )
    else
        printf( STDOUT, "%s = ", {cmd[4]} )
        puts( STDOUT, json_markup(value) )
    end if

end procedure

main()

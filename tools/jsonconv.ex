--
-- This is a simple utility to convert JSON files to Euphoria markup for use with mvc/json.e
--

include std/io.e
include mvc/json.e

export procedure main()

    sequence cmd = command_line()
    if length( cmd ) < 3 then
        return
    end if

    sequence json = json_parse_file( cmd[3] )
    if json[J_TYPE] = JSON_NONE then
        printf( STDERR, "%s\n", {json_last_error} )
        return
    end if

    puts( STDOUT, json_markup(json) )

end procedure

main()

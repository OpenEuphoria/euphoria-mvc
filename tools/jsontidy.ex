--
-- This is a simple utility to read JSON files and "pretty print" them using mvc/json.e
--

include std/io.e
include mvc/json.e

constant TRUE = 1
constant FALSE = 0

export procedure main()

    sequence data = {}
    sequence cmd = command_line()

    if length( cmd ) = 2 then
        data = read_file( STDIN )
    else
        data = read_file( cmd[3] )
    end if

    if length( data ) then

        data = json_parse( data )

        if data[J_TYPE] = JSON_NONE then
            printf( STDERR, "\"%s\"\n", {json_last_error()} )
            abort( 1 )
        end if

        json_print(
            STDOUT, -- file_name
            data,   -- json_object
            FALSE,  -- sorted_keys
            TRUE    -- white_space
        )

    end if

end procedure

main()

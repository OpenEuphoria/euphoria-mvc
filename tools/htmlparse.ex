--
-- This is a simple utility to read HTML files and display the parsed content.
--

include std/io.e
include mvc/html.e

procedure main()

    sequence data = {}
    sequence cmd = command_line()

    if length( cmd ) = 2 then
        data = read_file( STDIN )
    else
        data = read_file( cmd[3] )
    end if

    if length( data ) then

        data = html_parse( data )

        if data[ELEM_TYPE] != HTML_DOCUMENT then
            printf( STDERR, "\"%s\"\n", {data[ELEM_DATA]} )
            abort( 1 )
        end if

        html_print( STDOUT, data )

    end if

end procedure

main()

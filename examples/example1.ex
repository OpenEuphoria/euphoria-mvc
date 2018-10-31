--
-- This is just a basic example of the template engine.
--

include mvc/template.e

include std/filesys.e
include std/search.e
if search:ends( "examples", current_dir() ) then
	-- make sure we can find our templates
	-- if we're in the 'examples' directory
	set_template_path( "../templates" )
end if

procedure main()

	sequence response = {
		{ "title", "Example 1" },
		{ "list", {"one","two","three","four","five"} },
		{ "start",  1 },
		{ "stop",  10 },
		{ "step",   2 }
	}

	sequence data = render_template( "example1.html", response )

	puts( 1, data )

end procedure

main()

include mvc/template.e

set_template_path( "../templates" )

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

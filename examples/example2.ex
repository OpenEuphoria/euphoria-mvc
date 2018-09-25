--
-- This is a more advanced example showing how to use functions from within templates.
--

include std/map.e
include mvc/template.e

include std/filesys.e
include std/search.e
if search:ends( "examples", current_dir() ) then
	-- make sure we can find our templates
	-- if we're in the 'examples' directory
	set_template_path( "../templates" )
end if

--
-- Mockaroo - Random Data Generator and API Mocking Tool
-- https://www.mockaroo.com/
--

sequence data = {
	{
		{"id", 1},
		{"first_name", "Mommy"},
		{"last_name", "Mewburn"},
		{"email_address", "mmewburn0@oakley.com"},
		{"job_title", "Business Systems Development Analyst"},
		{"ip_address", "245.131.117.235"}
	},
	{
		{"id", 2},
		{"first_name", "Malinda"},
		{"last_name", "Yemm"},
		{"email_address", "myemm1@goodreads.com"},
		{"job_title", "Social Worker"},
		{"ip_address", "110.26.43.251"}
	},
	{
		{"id", 3},
		{"first_name", "Clywd"},
		{"last_name", "Firpi"},
		{"email_address", "cfirpi2@gov.uk"},
		{"job_title", "VP Quality Control"},
		{"ip_address", "248.104.29.229"}
	},
	{
		{"id", 4},
		{"first_name", "Val"},
		{"last_name", "Blumire"},
		{"email_address", "vblumire3@storify.com"},
		{"job_title", "Assistant Media Planner"},
		{"ip_address", "25.92.61.88"}
	},
	{
		{"id", 5},
		{"first_name", "Devon"},
		{"last_name", "Rayburn"},
		{"email_address", "drayburn4@ed.gov"},
		{"job_title", "Legal Assistant"},
		{"ip_address", "116.184.91.39"}
	},
	{
		{"id", 6},
		{"first_name", "Solomon"},
		{"last_name", "Degnen"},
		{"email_address", "sdegnen5@berkeley.edu"},
		{"job_title", "Administrative Officer"},
		{"ip_address", "231.120.1.199"}
	},
	{
		{"id", 7},
		{"first_name", "Nate"},
		{"last_name", "Helm"},
		{"email_address", "nhelm6@harvard.edu"},
		{"job_title", "Nuclear Power Engineer"},
		{"ip_address", "8.93.124.215"}
	},
	{
		{"id", 8},
		{"first_name", "Sayre"},
		{"last_name", "Bento"},
		{"email_address", "sbento7@tripod.com"},
		{"job_title", "Graphic Designer"},
		{"ip_address", "66.112.225.9"}
	},
	{
		{"id", 9},
		{"first_name", "Windham"},
		{"last_name", "Westpfel"},
		{"email_address", "wwestpfel8@telegraph.co.uk"},
		{"job_title", "Chemical Engineer"},
		{"ip_address", "101.248.79.10"}
	},
	{
		{"id", 10},
		{"first_name", "Timmy"},
		{"last_name", "Bedells"},
		{"email_address", "tbedells9@networksolutions.com"},
		{"job_title", "Senior Financial Analyst"},
		{"ip_address", "32.160.175.23"}
	}
}

procedure main()

	sequence user_list = {}

	for i = 1 to length( data ) do
		user_list &= { map:new_from_kvpairs(data[i]) }
	end for

	object response = map:new()
	map:put( response, "title", "Example 2" )
	map:put( response, "user_list", user_list )

	sequence content = render_template( "example2.html", response )
	puts( 1, content )

end procedure

main()

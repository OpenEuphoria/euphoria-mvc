
namespace html

include std/filesys.e
include std/io.e
include std/pretty.e
include std/text.e
include std/types.e

public constant HTML_ERROR = (-1)

public enum
	HTML_NONE = 0,
-- external
	HTML_DOCUMENT,
	HTML_DOCTYPE,
	HTML_COMMENT,
	HTML_OPEN,
	HTML_CLOSE,
	HTML_VOID,
	HTML_TEXT,
-- internal
	HTML_ATTRIBUTE,
	HTML_NAME,
	HTML_STRING,
$

public enum ELEM_TYPE, ELEM_DATA
public enum TAG_NAME, TAG_ATTR
public enum ATTR_NAME, ATTR_VALUE

public function html_type_name( integer elem_type )

	if elem_type = HTML_ERROR then
		return "HTML_ERROR"
	end if

	sequence type_name

	switch elem_type do
		case HTML_NONE      then type_name = "HTML_NONE"
	-- external
		case HTML_DOCUMENT  then type_name = "HTML_DOCUMENT"
		case HTML_DOCTYPE   then type_name = "HTML_DOCTYPE"
		case HTML_COMMENT   then type_name = "HTML_COMMENT"
		case HTML_OPEN      then type_name = "HTML_OPEN"
		case HTML_CLOSE     then type_name = "HTML_CLOSE"
		case HTML_VOID      then type_name = "HTML_VOID"
		case HTML_TEXT      then type_name = "HTML_TEXT"
	-- internal
		case HTML_ATTRIBUTE then type_name = "HTML_ATTRIBUTE"
		case HTML_NAME      then type_name = "HTML_NAME"
		case HTML_STRING    then type_name = "HTML_STRING"
	end switch

	return type_name
end function

sequence PRETTY_OPTIONS = PRETTY_DEFAULT
PRETTY_OPTIONS[DISPLAY_ASCII] = 2
PRETTY_OPTIONS[LINE_BREAKS] = 0

public procedure html_print( integer fn, sequence elements, integer indent = 0, integer width = 2 )

	sequence padding = repeat( ' ', indent*width )

	if length( elements ) = 2 and integer( elements[1] ) and sequence( elements[2] ) then
		elements = {elements}
	end if

	for i = 1 to length( elements ) do

		integer elem_type = elements[i][ELEM_TYPE]
		sequence elem_data = elements[i][ELEM_DATA]

		puts( fn, padding )
		printf( fn, "%s:", {html_type_name(elem_type)} )

		switch elem_type do

			case HTML_DOCUMENT then

				puts( fn, " {" )

				for j = 1 to length( elem_data ) do
					puts( fn, EOL )
					html_print( fn, elem_data[j], indent+1, width )
					if j < length( elem_data ) then
						puts( fn, "," )
					end if
				end for

				if length( elem_data ) then
					puts( fn, EOL  & padding )
				end if

				puts( fn, "}" )

			case HTML_OPEN, HTML_VOID then

				sequence tag_name = elem_data[TAG_NAME]
				sequence tag_attr = elem_data[TAG_ATTR]

				printf( fn, " \"%s\" {", {tag_name} )

				for j = 1 to length( tag_attr ) do
					puts( fn, EOL )
					html_print( fn, {HTML_ATTRIBUTE,tag_attr[j]}, indent+1, width )
					if j < length( tag_attr ) then
						puts( fn, "," )
					end if
				end for

				if length( tag_attr ) then
					puts( fn, EOL & padding )
				end if

				puts( fn, "}" )

			case HTML_CLOSE then

				sequence tag_name = elem_data[TAG_NAME]
				printf( fn, " \"%s\"", {tag_name} )

			case HTML_ATTRIBUTE then

				sequence attr_name = elem_data[ATTR_NAME]
				sequence attr_value = elem_data[ATTR_VALUE]
				printf( fn, " %s=\"%s\"", {attr_name,attr_value} )

			case else
				pretty_print( fn, elem_data, PRETTY_OPTIONS )

		end switch

		if i < length( elements ) then
			puts( fn, "," )
		end if

	end for

end procedure

public sequence html_last_error = ""

export procedure html_error( sequence msg, object data = {} )
	html_last_error = sprintf( msg, data )
end procedure

export function html_match( sequence needle, sequence haystack, integer start = 1, integer match_case = FALSE )

	integer stop = start + length( needle ) - 1

	if stop <= length( haystack ) then
		sequence sample = haystack[start..stop]

		if not match_case then
			needle = text:lower( needle )
			sample = text:lower( sample )
		end if

		return equal( needle, sample )
	end if

	return FALSE
end function

export function html_match_any( sequence needles, sequence haystack, integer start = 1, integer match_case = TRUE )

	for i = 1 to length( needles ) do

		if atom( needles[i] ) then
			needles[i] = {needles[i]}
		end if

		if html_match( needles[i], haystack, start, match_case ) then
			return TRUE
		end if

	end for

	return FALSE
end function

export function html_skip_whitespace( sequence html, integer start )

	integer i = start

	while i <= length( html ) and t_space( html[i] ) do
		i += 1
	end while

	return i
end function

export function html_parse_name( sequence html, integer start )

	sequence name = ""
	integer i = html_skip_whitespace( html, start )

	while i <= length( html ) do

		if find( html[i], "=> \r\n\t" ) then
			exit
		end if

		name &= html[i]

		i += 1
	end while

	return {HTML_NAME,name,i}
end function

export function html_parse_text( sequence html, integer start )

	sequence text = ""
	integer i = html_skip_whitespace( html, start )

	while i <= length( html ) do

		if html[i] = '<' then
			exit
		end if

		text &= html[i]

		i += 1
	end while

	text = trim_tail( text )

	return {HTML_TEXT,text,i}
end function

export function html_parse_string( sequence html, integer start )

	sequence value = ""
	integer i = html_skip_whitespace( html, start )

	if not html_match_any( `'"`, html, i ) then
		html_error( "html_parse_string(): Expected string at position %d", i )
		return {HTML_ERROR,html_last_error,0}
	end if

	i += 1

	while i <= length( html ) do

		if html[i] = html[start] then
			i += 1
			exit
		end if

		value &= html[i]

		i += 1
	end while

	return {HTML_STRING,value,i}
end function

export function html_parse_doctype( sequence html, integer start )

	sequence doctype = ""
	integer i = html_skip_whitespace( html, start )

	if not html_match( "<!doctype", html, i ) then
		html_error( "html_parse_doctype(): Expected doctype at position %d", i )
		return {HTML_ERROR,html_last_error,0}
	end if

	i = html_skip_whitespace( html, i+9 ) -- length("<!doctype") = 9

	while i <= length( html ) do

		if html[i] = '>' then
			i += 1
			exit
		end if

		doctype &= html[i]

		i += 1
	end while

	doctype = trim_tail( doctype )

	return {HTML_DOCTYPE,doctype,i}
end function

export function html_parse_comment( sequence html, integer start )

	sequence comment = ""
	integer i = html_skip_whitespace( html, start )

	if not html_match( "<!--", html, i ) then
		html_error( "html_parse_comment(): Expected comment at position %d", i )
		return {HTML_ERROR,html_last_error,0}
	end if

	i = html_skip_whitespace( html, i+4 ) -- length("<!--") = 4

	while i <= length( html ) do

		if html_match( "-->", html, i ) then
			i += 3 -- length("-->") = 3
			exit
		end if

		comment &= html[i]
		i += 1

	end while

	comment = trim_tail( comment )

	return {HTML_COMMENT,comment,i}
end function

export function html_parse_attribute( sequence html, integer start )

	integer i = html_skip_whitespace( html, start )
	integer last_i = i

	integer name_type = 0
	sequence attr_name = ""

	last_i = i
	{name_type,attr_name,i} = html_parse_name( html, i )

	if name_type != HTML_NAME then
		html_error( "html_parse_attr(): Expected name at position %d", last_i )
		return {HTML_ERROR,html_last_error,0}
	end if

	attr_name = text:lower( attr_name )

	integer value_type = 0
	sequence attr_value = ""

	i = html_skip_whitespace( html, i )

	if i <= length( html ) and html[i] = '=' then

		i = html_skip_whitespace( html, i+1 )

		if html_match_any( `'"`, html, i ) then

			last_i = i
			{value_type,attr_value,i} = html_parse_string( html, i )

			if value_type != HTML_STRING then
				html_error( "html_parse_attr(): Expected string at position %d", last_i )
				return {HTML_ERROR,html_last_error,0}
			end if

		else

			last_i = i
			{value_type,attr_value,i} = html_parse_name( html, i )

			if value_type != HTML_NAME then
				html_error( "html_parse_attr(): Expected value at position %d", last_i )
				return {HTML_ERROR,html_last_error,0}
			end if

		end if

	end if

	return {HTML_ATTRIBUTE,{attr_name,attr_value},i}
end function

export function html_parse_tag( sequence html, integer start )

	integer i = html_skip_whitespace( html, start )
	integer last_i = i

	if i <= length( html ) and html[i] != '<' then
		html_error( "html_parse_tag(): Expected '<' at position %d", i )
		return {HTML_ERROR,html_last_error,0}
	end if

	i += 1

	integer tag_type = HTML_OPEN

	if i <= length( html ) and html[i] = '/' then
		tag_type = HTML_CLOSE
		i += 1
	end if

	integer name_type
	sequence tag_name

	last_i = i
	{name_type,tag_name,i} = html_parse_name( html, i )

	if name_type != HTML_NAME then
		html_error( "html_parse_tag(): Expected name at position %d", last_i )
		return {HTML_ERROR,html_last_error,0}
	end if

	tag_name = text:lower( tag_name )

	i = html_skip_whitespace( html, i )

	sequence tag_attr = {}

	while i <= length( html ) do

		if html[i] = '>' then
			i += 1
			exit
		end if

		if tag_type = HTML_CLOSE then

			html_error( "html_parse_tag(): Expected '>' at position %d", i )
			return {HTML_ERROR,html_last_error,0}

		elsif html[i] = '/' then
			i += 1

			if i <= length( html ) and html[i] = '>' then
				tag_type = HTML_VOID
				i += 1
				exit
			end if

			html_error( "html_parse_tag(): Expected '>' at position %d", i )
			return {HTML_ERROR,html_last_error,0}

		end if

		integer attr_type
		sequence attr_value

		last_i = i
		{attr_type,attr_value,i} = html_parse_attribute( html, i )

		if attr_type != HTML_ATTRIBUTE then
			html_error( "html_parse_tag(): Expected attribute at position %d", last_i )
			return {HTML_ERROR,html_last_error,0}
		end if

		tag_attr = append( tag_attr, attr_value )

		--i += 1
	end while

	return {tag_type,{tag_name,tag_attr},i}
end function

public function html_parse_element( sequence html, integer start )

	integer i = html_skip_whitespace( html, start )

	if i <= length( html ) then

		if html[i] = '<' then

			if html_match( "<!doctype", html, i ) then
				return html_parse_doctype( html, i )

			elsif html_match( "<!--", html, i ) then
				return html_parse_comment( html, i )

			else
				return html_parse_tag( html, i )

			end if

		end if

		return html_parse_text( html, i )
	end if

	return {HTML_NONE,{},i}
end function

public function html_parse( sequence html, integer start = 1 )

	sequence elements = {}

	integer i = html_skip_whitespace( html, start )

	html_last_error = ""

	while i <= length( html ) do

		integer elem_type
		sequence elem_data

		{elem_type,elem_data,i} = html_parse_element( html, i )

		if elem_type = HTML_NONE then
			exit

		elsif elem_type = HTML_ERROR then
			return {elem_type,elem_data}

		end if

		elements = append( elements, {elem_type,elem_data} )

	end while

	return {HTML_DOCUMENT,elements}
end function

public function html_parse_file( sequence file )

	if file_exists( file ) then
		return html_parse( read_file(file), 1 )
	end if

	html_last_error = sprintf( "File not found: %s", {file} )

	return {HTML_ERROR,html_last_error}
end function

public function html_get_attribute( sequence attr_list, sequence attr_name, integer match_case = FALSE )

	if not match_case then
		attr_name = text:lower( attr_name )
	end if

	for i = 1 to length( attr_list ) do

		if length( attr_list[i] ) != 2 then
			continue
		end if

		if not match_case then
			attr_list[i][1] = text:lower( attr_list[i][1] )
		end if

		if equal( attr_list[i][1], attr_name ) then
			return attr_list[i][2]
		end if

	end for
	
	return ""
end function

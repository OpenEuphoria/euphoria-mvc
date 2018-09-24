
namespace template

include std/convert.e
include std/error.e
include std/filesys.e
include std/get.e
include std/io.e
include std/map.e
include std/pretty.e
include std/regex.e
include std/search.e
include std/text.e
include std/types.e
include std/utils.e

constant NULL = 0
constant EOL2 = EOL & EOL

--
-- Token Management
--

constant TOKEN_START = 3    -- skip the first two tokens
integer  token_count = 0    -- number of tokens defined
sequence token_names = {}   -- list of token names
sequence token_regex = {}   -- list of token regexs

--
-- Return the name of a given token type.
--
public function get_token_name( integer ttype )
	return token_names[ttype]
end function

--
-- Define a new token type.
--
public function new_token( sequence name, object regex = NULL )

	if sequence( regex ) then
		regex = regex:new( regex )
	end if

	token_names = append( token_names, name )
	token_regex = append( token_regex, regex )

	token_count += 1

	return token_count
end function

--
-- Built-in token types.
--
public constant
	T_UNKNOWN       = new_token( "T_UNKNOWN" ),
	T_FRAGMENT      = new_token( "T_FRAGMENT" ),
	T_EXPRESSION	= new_token( "T_EXPRESSION",  `^{{\s*(.+?)\s*}}$` ),
	T_COMMENT       = new_token( "T_COMMENT",     `^{#\s*(.+?)\s*#}$` ),
	T_EXTENDS       = new_token( "T_EXTENDS",     `^{%\s*extends\s+(.+?)\s*%}$` ),
	T_BLOCK         = new_token( "T_BLOCK",       `^{%\s*block\s+(.+?)\s*%}$` ),
	T_ENDBLOCK      = new_token( "T_ENDBLOCK",    `^{%\s*end\s+block\s*%}$` ),
	T_IF            = new_token( "T_IF",          `^{%\s*if\s+(.+?)\s*%}$` ),
	T_ELSIF         = new_token( "T_ELSIF",       `^{%\s*elsif\s+(.+?)\s*%}$` ),
	T_ELSE          = new_token( "T_ELSE",        `^{%\s*else\s*%}$` ),
	T_ENDIF         = new_token( "T_ENDIF",       `^{%\s*end\s+if\s*%}$` ),
	T_FOR           = new_token( "T_FOR",         `^{%\s*for\s+(.+?)\s*%}$` ),
	T_ENDFOR        = new_token( "T_ENDFOR",      `^{%\s*end\s+for\s*%}$` ),
$

--
-- Global template management.
--

sequence template_path = current_dir() & SLASH & "templates"

--
-- Set the global template path.
--
public procedure set_template_path( sequence path )
	template_path = path
end procedure

--
-- Global function management.
--

map m_functions = map:new()

--
-- Register a global function.
--
public procedure add_function( sequence func_name, sequence params = {}, integer func_id = routine_id(func_name) )
	map:put( m_functions, func_name, {params,func_id} )
end procedure

--
-- Call a global function.
--
public function call_funcion( sequence func_name, sequence values = {} )

	sequence params
	integer func_id

	{params,func_id} = map:get( m_functions, func_name, {{},-1} )

	if func_id = -1 or length(params) != length(values) then
		return 0
	end if

	return call_func( func_id, values )
end function

--
-- Template token lexer.
--

constant re_tokens = regex:new( `({{.+?}}|{%.+?%}|{#.+?#})` )

public enum TTYPE, TDATA, TTREE

--
-- Turn a template into a list of tokens.
--
public function token_lexer( sequence text )

	sequence tokens = {}
	integer last_pos = 1

	sequence token, match
	integer start, stop
	object ttype, tdata, ttemp

	sequence matches = regex:all_matches(
		re_tokens, text, 1, STRING_OFFSETS )

	for i = 1 to length( matches ) do
		match = matches[i][1]

		start = match[2]
		stop  = match[3]

		if last_pos < start then

			ttype = T_FRAGMENT
			tdata = text[last_pos..start-1]
			token = { ttype, tdata, {} }
			tokens = append( tokens, token )

		end if

		ttype = T_UNKNOWN
		tdata = {}

		for j = TOKEN_START to token_count do

			if regex:is_match( token_regex[j], match[1] ) then
				ttemp = regex:matches( token_regex[j], match[1] )

				ttype = j
				if length( ttemp ) > 1 then
					tdata = ttemp[2]
				end if

				exit
			end if

		end for

		token = { ttype, tdata, {} }
		tokens = append( tokens, token )

		last_pos = stop + 1

	end for

	if last_pos <= length( text ) then

		ttype = T_FRAGMENT
		tdata = text[last_pos..$]
		token = { ttype, tdata, {} }
		tokens = append( tokens, token )

	end if

	return tokens
end function

--
-- Turn a list of tokens into an abstract syntax tree.
--
public function token_parser( sequence tokens, integer start = 1, sequence exit_tokens = {} )

	sequence tree = {}
	integer i = start

	sequence token, temp

	while i <= length( tokens ) do
		token = tokens[i]

		if find( token[TTYPE], exit_tokens ) then
			-- skip the final exit token
			i += ( token[TTYPE] = exit_tokens[$] )
			return {tree,i}
		end if

		temp = token[TTREE]
		i += 1

		switch token[TTYPE] do

			case T_BLOCK then
				{temp,i} = token_parser( tokens, i, {T_ENDBLOCK} )

			case T_IF then
				{temp,i} = token_parser( tokens, i, {T_ELSIF,T_ELSE,T_ENDIF} )

			case T_ELSIF then
				{temp,i} = token_parser( tokens, i, {T_ELSE,T_ENDIF} )

			case T_ELSE then
				{temp,i} = token_parser( tokens, i, {T_ENDIF} )

			case T_FOR then
				{temp,i} = token_parser( tokens, i, {T_ENDFOR} )

		end switch

		token[TTREE] = temp
		tree = append( tree, token )

	end while

	if start = 1 then
		return tree
	end if

	return {tree,i}
end function

constant re_variable = regex:new( `^([_a-zA-Z][_a-zA-Z0-9]*)$` )
constant re_function = regex:new( `^([_a-zA-Z][_a-zA-Z0-9]*)\((.+)\)$` )

--
-- Parse a variable or function or literal value.
--
public function parse_value( sequence data, object response )

	if regex:is_match( re_variable, data ) then
		-- parse a variable and get its value

		sequence matches = regex:matches( re_variable, data )
		sequence var_name = matches[2]

		return map:get( response, var_name )

	elsif regex:is_match( re_function, data ) then
		-- parse and call a function, and return its value

		sequence matches = regex:matches( re_function, data )
		sequence func_name = matches[2]
		sequence func_params = matches[3]

		func_params = keyvalues( func_params )

		for i = 1 to length( func_params ) do
			func_params[i] = parse_value( func_params[i][2], response )
		end for

		return call_funcion( func_name, func_params )

	else
		-- parse and return a literal value

		return defaulted_value( data, 0 )

	end if

	return 0
end function

--
-- Render a fragment token.
--
public function render_fragment( sequence tree, integer i, object response )

	sequence data = tree[i][TDATA]

	-- collapse multiple line breaks
	while match( EOL2, data ) do
		data = match_replace( EOL2, data, EOL )
	end while

	return {data,i+1}
end function

--
-- Render an expression token.
--
public function render_expression( sequence tree, integer i, object response )

	object value = parse_value( tree[i][TDATA], response )

	if atom( value ) then
		value = sprint( value )
	end if

	return {value,i+1}
end function

--
-- Render an if block.
--
public function render_if( sequence tree, integer i, object response )

	sequence output = ""

	while i <= length( tree ) do

		switch tree[i][TTYPE] do

			case T_IF, T_ELSIF then

				object value = parse_value( tree[i][TDATA], response )
				if not equal( value, 0 ) then

					{output,?} = render_block( tree, i, response )
					exit

				end if


			case T_ELSE then

				{output,?} = render_block( tree, i, response )
				exit

		end switch

		i += 1

	end while

	-- exhaust any remaining elsif/else statements
	while i <= length( tree ) and find( tree[i][TTYPE], {T_ELSIF,T_ELSE} ) do
		i += 1
	end while

	return {output,i}
end function

constant re_foritem   = regex:new( `^(\w+)\s+in\s+(\w+)$` )
constant re_forloop   = regex:new( `^(\w+)\s+=\s+(\w+)\s+to\s+(\w+)$` )
constant re_forloopby = regex:new( `^(\w+)\s+=\s+(\w+)\s+to\s+(\w+)\s+by\s+(\w+)$` )

--
-- Render a for block.
--
public function render_for( sequence tree, integer i, object response )

	sequence data = tree[i][TDATA]

	sequence output = ""
	sequence temp = {}

	if regex:is_match( re_foritem, data ) then
		-- parse 'for item in list' block

		sequence matches = regex:matches( re_foritem, data )

		sequence item_name = matches[2]
		sequence list_name = matches[3]

		object list_value = parse_value( list_name, response )

		if not sequence( list_value ) then
			error:crash( "expected object '%s' is not a sequence", {list_name} )
		end if

		for j = 1 to length( list_value ) do
			object item_value = list_value[j]

			map:put( response, item_name, item_value )
			{temp,?} = render_block( tree, i, response )

			output &= temp

		end for

		map:remove( response, item_name )

	elsif regex:is_match( re_forloop, data ) then
		-- parse 'for i = m to n' block

		sequence matches = regex:matches( re_forloop, data )

		sequence iter_name  = matches[2]
		sequence start_name = matches[3]
		sequence stop_name  = matches[4]

		object start_value = parse_value( start_name, response )
		object stop_value = parse_value( stop_name, response )

		for iter_value = start_value to stop_value do

			map:put( response, iter_name, iter_value )
			{temp,?} = render_block( tree, i, response )

			output &= temp

		end for

		map:remove( response, iter_name )

	elsif regex:is_match( re_forloopby, data ) then
		-- parse 'for i = m to n by z' block

		sequence matches = regex:matches( re_forloopby, data )

		sequence iter_name  = matches[2]
		sequence start_name = matches[3]
		sequence stop_name  = matches[4]
		sequence by_name    = matches[5]

		object start_value = parse_value( start_name, response )
		object stop_value = parse_value( stop_name, response )
		object by_value = parse_value( by_name, response )

		if equal( by_value, 0 ) then
			return {output,i+1}
		end if

		for iter_value = start_value to stop_value by by_value do

			map:put( response, iter_name, iter_value )
			{temp,?} = render_block( tree, i, response )

			output &= temp

		end for

		map:remove( response, iter_name )

	end if

	return {output,i+1}
end function

--
-- Render a token.
--
public function render_token( sequence tree, integer i, object response )

	switch tree[i][TTYPE] do

		case T_FRAGMENT then
			return render_fragment( tree, i, response )

		case T_EXPRESSION then
			return render_expression( tree, i, response )

		case T_BLOCK then
			return render_block( tree, i, response )

		case T_IF then
			return render_if( tree, i, response )

		case T_FOR then
			return render_for( tree, i, response )

	end switch

	return {"",i+1}
end function

--
-- Render a token block.
--
public function render_block( sequence tree, integer i, object response )

	sequence output = ""
	sequence temp = ""

	integer j = 1
	sequence subtree = tree[i][TTREE]

	while j <= length( subtree ) do
		{temp,j} = render_token( subtree, j, response )
		output &= temp
	end while

	return {output,i+1}
end function

--
-- Extend a template through its parent.
--
public function extend_template( sequence filename, sequence tree )

	map blocks = map:new()

	for i = 1 to length( tree ) do
		-- collect block names from the template

		if tree[i][TTYPE] = T_BLOCK then
			sequence block_name = text:trim( tree[i][TDATA], '"' )
			map:put( blocks, block_name, tree[i][TTREE] )
		end if

	end for

	if not search:begins( template_path & SLASH, filename ) then
		filename = template_path & SLASH & filename
	end if

	sequence text = read_file( filename )
	sequence tokens = token_lexer( text )

	tree = token_parser( tokens )

	delete( tokens )
	delete( text )

	integer i = 1
	sequence temp = {}

	while i <= length( tree ) do
		if tree[i][TTYPE] = T_BLOCK then
			-- insert the matching block here

			sequence block_name = tree[i][TDATA]

			temp = map:get( blocks, block_name, {} )
			tree = tree[1..i-1] & temp & tree[i+1..$]

			i += length( temp )

		end if

		i += 1
	end while

	return tree
end function

--
-- Render a template.
--
public function render_template( sequence filename, object response = {} )

	if not search:begins( template_path & SLASH, filename ) then
		filename = template_path & SLASH & filename
	end if

	object text = read_file( filename )
	if atom( text ) then
		error:crash( "could not read template: %s", {filename} )
	end if

	sequence tokens = token_lexer( text )
	sequence tree = token_parser( tokens )

	delete( tokens )
	delete( text )

	for i = 1 to length( tree ) do
		-- look for a master template

		if tree[i][TTYPE] = T_EXTENDS then

			filename = tree[i][TDATA]
			tree = extend_template( filename, tree )
			exit

		end if

	end for

	-- allow reponse to be "key=value, ..." string
	if string( response ) then
		response = text:keyvalues( response )
	end if

	-- allow response to be { {"key","value"}, ... } sequence
	if sequence( response ) then
		response = map:new_from_kvpairs( response )
	end if

	integer i = 1
	sequence output = ""
	sequence temp = ""

	while i <= length( tree ) do
		{temp,i} = render_token( tree, i, response )
		output &= temp
	end while

	return output
end function

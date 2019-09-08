
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
include std/sequence.e
include std/text.e
include std/types.e
include std/utils.e

include mvc/logger.e

constant NULL = 0

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
	if valid_index( ttype, token_names ) then
		return token_names[ttype]
	end if
	return ""
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

map m_template_cache = map:new()

object template_path = getenv( "TEMPLATE_PATH" )

if atom( template_path ) then
	template_path = current_dir() & SLASH & "templates"
end if

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

enum
	FUNC_PARAMS,
	FUNC_DEFAULT,
	FUNC_ID

type default_param( object x )
	return sequence( x )
	   and length( x ) = 2
	   and string( x[1] )
	   and object( x[2] )
end type

--
-- Register a global function.
--
public procedure add_function( sequence func_name, sequence params = {}, integer func_id = routine_id(func_name) )

    if func_id = -1 then
        log_error( "function %s not found", {func_name} )
        error:crash( "function %s not found", {func_name} )
    end if

    if not map:has( m_functions, func_name ) then
		map:put( m_functions, func_name, {params,func_id} )
		log_debug( "Registered function %s with params %s at routine id %d", {func_name,params,func_id} )
	end if

end procedure

--
-- Call a global function.
--
public function call_function( sequence func_name, sequence values = {} )

	sequence params
	integer func_id

	{params,func_id} = map:get( m_functions, func_name, {{},-1} )

	if func_id = -1 then
		log_error( "function %s not found", {func_name} )
		error:crash( "function %s not found", {func_name} )
	end if

	integer start = length( values ) + 1
	integer stop = length( params )

	for i = start to stop do

		if not default_param( params[i] ) then
			log_error( "function %s does not provide a default value for param %s", {func_name,params[i]} )
			error:crash( "function %s does not provide a default value for param %s", {func_name,params[i]} )
		end if

		values = append( values, params[i][2] )

	end for

	return call_func( func_id, values )
end function

--
-- Built-in functions
--

--
-- atom()
--
function _atom( object x )
	return atom( x )
end function

--
-- integer()
--
function _integer( object x )
	return integer( x )
end function

--
-- sequence()
--
function _sequence( object x )
	return sequence( x )
end function

--
-- object()
--
function _object( object x )
	return object( x )
end function

--
-- equal()
--
function _equal( object a, object b )
    return equal( a, b )
end function

--
-- not_equal()
--
function _not_equal( object a, object b )
    return not equal( a, b )
end function

--
-- length()
--
function _length( object x )
	return length( x )
end function

--
-- not()
--
function _not( object x )
	return equal( x, 0 ) or equal( x, "" )
end function

--
-- and()
--
function _and( object a, object b )
	return a and b
end function

--
-- or()
--
function _or( object a, object b )
	return a or b
end function

--
-- xor()
--
function _xor( object a, object b )
	return a xor b
end function

--
-- pretty()
--
function _pretty( object x, object p )
	return pretty_sprint( x, p )
end function

add_function( "atom",      {"x"},     routine_id("_atom") )
add_function( "integer",   {"x"},     routine_id("_integer") )
add_function( "sequence",  {"x"},     routine_id("_sequence") )
add_function( "object",    {"x"},     routine_id("_object") )
add_function( "equal",     {"a","b"}, routine_id("_equal") )
add_function( "not_equal", {"a","b"}, routine_id("_not_equal") )
add_function( "length",    {"x"},     routine_id("_length") )
add_function( "not",       {"x"},     routine_id("_not") )
add_function( "and",       {"a","b"}, routine_id("_and") )
add_function( "or",        {"a","b"}, routine_id("_or") )
add_function( "xor",       {"a","b"}, routine_id("_xor") )
add_function( "pretty",    {"x",{"p",PRETTY_DEFAULT}}, routine_id("_pretty") )

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

	object matches = regex:all_matches(
		re_tokens, text, 1, STRING_OFFSETS )

	if atom( matches ) then
		return {
			{ T_FRAGMENT, text, {} }
		}
	end if

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

constant re_variable = regex:new( `^([\w\.]+)(\[(?:[\w\"\'\.]|\]\[)+\])?$` )
constant re_function = regex:new( `^([_a-zA-Z][_a-zA-Z0-9]+)\((.*)\)$` )

--
-- Parse a variable or function or literal value.
--
public function parse_value( sequence data, object response )

	object var_value = 0

	if regex:is_match( re_variable, data ) then
		-- parse a variable and get its value

		sequence matches = regex:matches( re_variable, data )
		sequence var_name = matches[2]

		if find( '.', var_name ) then

			sequence var_list = stdseq:split( var_name, '.' )
			var_value = map:nested_get( response, var_list, "" )

		elsif map:has( response, var_name ) then
			var_value = map:get( response, var_name )

		end if

		if length( matches ) = 3 and matches[3][1] = '[' and matches[3][$] = ']' then
			-- variable has subscript

			sequence subscript = stdseq:split( matches[3][2..$-1], "][" )

			for i = 1 to length( subscript ) do

				subscript[i] = parse_value( subscript[i], response )

				if valid_index( var_value, subscript[i] ) then
					var_value = var_value[subscript[i]]
				end if

			end for

		end if

	elsif regex:is_match( re_function, data ) then
		-- parse and call a function, and return its value

		sequence matches = regex:matches( re_function, data )

		sequence func_name = matches[2]
		sequence func_params = matches[3]

		func_params = keyvalues( func_params, ",", "=", "\"" )

		for i = 1 to length( func_params ) do
			func_params[i] = parse_value( func_params[i][2], response )
		end for

		var_value = call_function( func_name, func_params )

	else
		-- parse and return a literal value

		if search:begins( "'", data ) and search:ends( "'", data ) then
			-- swap single quotes to double
			data = '"' & data[2..$-1] & '"'
		end if

		var_value = defaulted_value( data, 0 )

	end if

	return var_value
end function

--
-- Render a fragment token.
--
public function render_fragment( sequence tree, integer i, object response )

	sequence data = tree[i][TDATA]

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

				if not equal( value, 0 ) and not equal( value, "" ) then
					{output,i} = render_block( tree, i, response )
					exit
				end if

			case T_ELSE then

				{output,i} = render_block( tree, i, response )
				exit

			case else
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

constant re_foritem   = regex:new( `^(\w+)\s+in\s+([\w\.]+)(\[(?:[\w\"\'\.]|\]\[)+\])?$` )
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

		sequence list_name = matches[3]
		object list_value = parse_value( list_name, response )

		if not sequence( list_value ) then
			error:crash( "expected object '%s' is not a sequence", {list_name} )
		end if

		sequence item_name = matches[2]
		integer previous_index = map:get( response, "current_index", 0 )

		for j = 1 to length( list_value ) do
			map:put( response, "current_index", j )

			object item_value = list_value[j]

			map:put( response, item_name, item_value )
			{temp,?} = render_block( tree, i, response )

			output &= temp

		end for

		map:remove( response, item_name )

		if previous_index != 0 then
			map:put( response, "current_index", previous_index )
		else
			map:remove( response, "current_index" )
		end if

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
-- Parse template text.
--
public function parse_template( sequence text, object response = {} )

	sequence tokens = token_lexer( text )
	sequence tree = token_parser( tokens )

	for i = 1 to length( tree ) do
		-- look for a master template

		if tree[i][TTYPE] = T_EXTENDS then

			sequence filename = tree[i][TDATA]
			tree = extend_template( dequote(filename), tree )

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

--
-- Render a template.
--
public function render_template( sequence filename, object response = {} )

	if not search:begins( template_path & SLASH, filename ) then
		filename = template_path & SLASH & filename
	end if

	object text = map:get( m_template_cache, filename, 0 )

	if atom( text ) then
		text = read_file( filename )
		map:put( m_template_cache, filename, text )
	end if

	if atom( text ) then
		log_error( "could not read template: %s", {filename} )
		error:crash( "could not read template: %s", {filename} )
	end if

	return parse_template( text, response )
end function


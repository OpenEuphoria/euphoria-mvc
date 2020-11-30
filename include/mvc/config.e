
namespace config

include std/convert.e
include std/filesys.e
include std/io.e
--include std/map.e
include std/pretty.e
include std/search.e
include std/sequence.e
include std/text.e
include std/types.e

include mvc/logger.e
include mvc/mapdbg.e as map

export constant DEFAULT_CATEGORY = "default"
export constant DEFAULT_SEPARATOR = '.'
export constant DEFAULT_VALUE = ""

-- configuration state
object m_config = map:new()
object m_comment = map:new()
sequence m_category = {DEFAULT_CATEGORY}
integer m_saved = TRUE

-- pretty print options
sequence m_pretty_options = PRETTY_DEFAULT
m_pretty_options[DISPLAY_ASCII] = 2 -- print all strings as ASCII
m_pretty_options[LINE_BREAKS]   = 0 -- do not break lines

public procedure clear_config()

	if not m_saved then
		log_warn( "Clearing unsaved configuration!" )
	end if

	map:clear( m_config )
	map:clear( m_comment )
	m_category = {DEFAULT_CATEGORY}
	m_saved = TRUE

end procedure

public function config_saved()
	return m_saved
end function

public function load_config( object filename )

	integer fn, close_fn

	if integer( filename ) then
		fn = filename
		close_fn = FALSE

		if fn = STDIN then
			filename = "STDIN"
		end if

	elsif string( filename ) then
		fn = open( filename, "r" )
		close_fn = TRUE

		if fn = -1 then
			log_error( "Could not read filename %s", {filename} )
			return FALSE
		end if

	else
		log_error( "File name as not an integer or string" )
		return FALSE

	end if

	clear_config()

	log_trace( "Reading file %s", {filename} )

	sequence comments = {}
	sequence category = DEFAULT_CATEGORY

	while TRUE do

		object line = gets( fn )
		if atom( line ) then
			exit
		end if

		line = text:trim( line )
		if length( line ) = 0 then
			continue
		end if

		if search:begins( ";", line ) then

			line = text:trim_head( line, "; " )
			log_trace( "Reading comment %s", {line} )

			comments = append( comments, line )

		elsif search:begins( "[", line ) and search:ends( "]", line ) then

			line = text:trim( line, "[] \t" )
			log_trace( "Reading category %s", {line} )

			category = line

			if not find( category, m_category ) then
				m_category = append( m_category, category )
			end if

			if length( comments ) then
				log_trace( "Storing comments %s to %s", {comments,{category,""}} )
				map:nested_put( m_comment, {category,""}, comments )
				comments = {}
			end if

		elsif find( '=', line ) and length( category ) != 0 then

			sequence pairs = text:keyvalues(
				line,   -- source
				"",     -- pair_delim
				":=",   -- kv_delim
				"'\"",  -- quotes
				"",     -- whitespace
				TRUE    -- haskeys
			)

			for i = 1 to length( pairs ) do

				log_trace( "Reading key %s", {pairs[i]} )

				object key, value
				{key,value} = pairs[i]

				object temp, error
				{temp,error} = to_number( value, TRUE )

				if not error then
					value = temp
				end if

				log_trace( "Storing value %s to %s", {value,key} )
				map:nested_put( m_config, {category,key}, value )

				if length( comments ) then
					log_trace( "Storing comments %s to %s", {comments,{category,key}} )
					map:nested_put( m_comment, {category,key}, comments )
					comments = {}
				end if

			end for

		end if

	end while

	if length( comments ) then
		log_trace( "Storing comments %s to %s", {comments,{""}} )
		map:nested_put( m_comment, {""}, comments )
		comments = {}
	end if

	if close_fn then
		close( fn )
	end if

	ifdef MAPDBG then
		print_map( m_config, 1 )
		print_map( m_comment, 1 )
	end ifdef

	return TRUE
end function

public function save_config( object filename, integer mark_saved=TRUE, integer write_empty=FALSE )

	integer fn, close_fn

	if integer( filename ) then
		fn = filename
		close_fn = FALSE

		if fn = STDOUT then
			filename = "STDOUT"
		elsif fn = STDERR then
			filename = "STDERR"
		end if

	elsif string( filename ) then
		fn = open( filename, "w" )
		close_fn = TRUE

		if fn = -1 then
			log_error( "Could not write filename %s", {filename} )
			return FALSE
		end if

	else
		log_error( "File name as not an integer or string" )
		return FALSE

	end if

	sequence comments = {}

	log_trace( "Writing file %s", {filename} )

	for i = 1 to length( m_category ) do

		object category = m_category[i]

		if not string( category ) then
			log_error( "Key for config category %d is not a string", {i} )
			continue
		end if

		log_trace( "Writing category %s", {category} )

		comments = map:nested_get( m_comment, {category,""}, {} )

		for j = 1 to length( comments ) do
			puts( fn, "; " )
			puts( fn, comments[j] )
			puts( fn, EOL )
		end for

		object submap = map:get( m_config, category )

		if not map( submap ) then
			log_error( "Value for config category %d %s is not a map", {i,category} )
			continue
		end if

		sequence subpairs = map:pairs( submap )

		if length( subpairs ) or write_empty then
			printf( fn, "[%s]", {category} )
			puts( fn, EOL )
		end if

		for j = 1 to length( subpairs ) do

			object key, value
			{key,value} = subpairs[j]

			if not string( key ) then
				log_error( "Key for config item %d in category %s is not a string: %s", {j,category,key} )
				log_trace( "subpairs[%d] = %s", {j,subpairs[j]} )
				continue
			end if

			log_trace( "Writing key %s", {key} )

			comments = map:nested_get( m_comment, {category,key}, {} )
			log_trace( "Reading comments %s from %s", {comments,{category,key}} )

			for k = 1 to length( comments ) do
				puts( fn, "; " )
				puts( fn, comments[k] )
				puts( fn, EOL )
			end for

			printf( fn, "%s=", {key} )
			pretty_print( fn, value, m_pretty_options )
			puts( fn, EOL )

		end for

		if i < length( m_category ) then
			puts( fn, EOL )
		end if

	end for

	comments = map:nested_get( m_comment, {""}, {} )

	if length( comments ) then
		puts( fn, EOL )
	end if

	for j = 1 to length( comments ) do
		puts( fn, "; " )
		puts( fn, comments[j] )
		puts( fn, EOL )
	end for

	if close_fn then
		close( fn )
	end if

	if mark_saved then
		m_saved = TRUE
	end if

	return TRUE
end function

function translate_keys( sequence keys, object sep=DEFAULT_SEPARATOR )

	sequence orig = keys

	if string( keys ) then
		keys = stdseq:split( keys, sep )
	end if

	if length( keys ) = 0 then
		keys = {DEFAULT_CATEGORY,""}
	elsif length( keys ) = 1 then
		keys = {DEFAULT_CATEGORY,keys[1]}
	elsif length( keys ) != 2 then
		keys = {keys[1],stdseq:join(keys[2..$],sep)}
	end if

	if not equal( keys, orig ) then
		log_trace( "Translated keys %s to %s", {orig,keys} )
	end if

	return keys
end function

public function has_comment( sequence keys, object sep=DEFAULT_SEPARATOR )

	if equal( keys, "" ) then
		keys = {""}
	elsif not equal( keys, {""} ) then
		keys = translate_keys( keys, sep )
	end if

	object submap = map:get( m_comment, keys[1], 0 )

	if map( submap ) then
		return map:has( submap, keys[2] )
	end if

	return FALSE
end function

public function has_config( sequence keys, object sep=DEFAULT_SEPARATOR )

	keys = translate_keys( keys, sep )

	object submap = map:get( m_config, keys[1], 0 )

	if map( submap ) then
		return map:has( submap, keys[2] )
	end if

	return FALSE
end function

public function get_comment( sequence keys, integer one_string=FALSE, object sep=DEFAULT_SEPARATOR )

	if equal( keys, "" ) then
		keys = {""}
	elsif not equal( keys, {""} ) then
		keys = translate_keys( keys, sep )
	end if

	sequence comments = map:nested_get( m_comment, keys, {} )

	if one_string then
		comments = stdseq:join( comments, EOL )
	end if

	return comments
end function

public function get_config( sequence keys, object default=DEFAULT_VALUE, object sep=DEFAULT_SEPARATOR )

	keys = translate_keys( keys, sep )

	return map:nested_get( m_config, keys, default )
end function

public procedure set_comment( sequence keys, sequence comment, object sep=DEFAULT_SEPARATOR )

	if equal( keys, "" ) then
		keys = {""}
	elsif not equal( keys, {""} ) then
		keys = translate_keys( keys, sep )
	end if

	if string( comment ) and find( EOL, comment ) then
		comment = stdseq:split( EOL, comment )
	end if

	map:nested_put( m_comment, keys, comment )
	m_saved = FALSE

end procedure

public procedure set_config( sequence keys, object value, object sep=DEFAULT_SEPARATOR )

	keys = translate_keys( keys, sep )

	map:nested_put( m_config, keys, value )
	m_saved = FALSE

end procedure

public procedure unset_comment( sequence keys, object sep=DEFAULT_SEPARATOR )

	sequence category, key
	{category,key} = translate_keys( keys, sep )

	object submap = map:get( m_comment, category, 0 )

	if map( submap ) then
		map:remove( submap, key )
		m_saved = FALSE
	end if

end procedure

public procedure unset_config( sequence keys, object sep=DEFAULT_SEPARATOR )

	sequence category, key
	{category,key} = translate_keys( keys, sep )

	object submap = map:get( m_config, category, 0 )

	if map( submap ) then
		map:remove( submap, key )
		m_saved = FALSE
	end if

end procedure



namespace config

include std/convert.e
include std/filesys.e
include std/io.e
include std/map.e
include std/search.e
include std/sequence.e
include std/text.e
include std/types.e

map m_config = map:new()

public function load_config( object filename )

	map:clear( m_config )

	if sequence( filename ) then
		filename = open( filename, "r", TRUE )
		if filename = -1 then
			return FALSE
		end if
	end if

	sequence category= ""
	sequence pairs, key
	object value, temp
	integer error

	object line = gets( filename )
	while sequence( line ) do

		line = text:trim( line )
		if length( line ) = 0 then
			line = gets( filename )
			continue
		end if

		if search:begins( "[", line ) and search:ends( "]", line ) then
			category = line[2..$-1]

		elsif find( '=', line ) and length( category ) != 0 then

			pairs = keyvalues( line )

			for i = 1 to length( pairs ) do

				{key,value} = pairs[i]
				{temp,error} = to_number( value, TRUE )

				if not error then value = temp end if
				map:nested_put( m_config, {category,key}, value )

			end for

		end if

		line = gets( filename )
	end while

	return TRUE
end function

public function save_config( object filename )

	if sequence( filename ) then
		filename = open( filename, "w", TRUE )
		if filename = -1 then
			return FALSE
		end if
	end if

	sequence keys = map:keys( m_config )

	for i = 1 to length( keys ) do

		map submap = map:get( m_config, keys[i] )

		sequence subkeys = map:keys( submap )
		printf( filename, "[%s]" & EOL, {keys[i]} )

		for j = 1 to length( subkeys ) do

			object value = map:get( submap, subkeys[j], "" )

			if atom( value ) then value = sprint( value ) end if
			printf( filename, "%s = %s" & EOL, {subkeys[j],value} )

		end for

		puts( filename, EOL )

	end for

	return TRUE
end function

public function has_config( sequence category, sequence key )
	return map:has( m_config, category ) and map:has( map:get(m_config,category), key )
end function

public function get_config( sequence category, sequence key, object default = "" )
	return map:nested_get( m_config, {category,key}, default )
end function

public procedure set_config( sequence category, sequence key, object value )
	map:nested_put( m_config, {category,key}, value )
end procedure


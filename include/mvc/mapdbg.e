
namespace mapdbg

ifdef not MAPDBG then

public include std/map.e

elsedef

include std/eumem.e
include std/filesys.e
include std/io.e
include std/pretty.e
include std/regex.e
include std/search.e
include std/map.e as stdmap
include mvc/logger.e
without inline

ifdef EUI then
include euphoria/debug/debug.e
end ifdef

--constant re_mapdef = regex:new( `(?:\w+\s+)*(\w+)\s+(\w+)\s*=\s*(\w+):(\w+)\(.*` )
--constant re_mapdef = regex:new( `(?:\w+\s+)*(\w+)\s+(\w+)\s*=\s*(?:(\w+):)*(\w+)\(.*` )
constant re_mapdef = regex:new( `\s*(?:\w+\s+)*(?:(\w+)\s+)?(\w+)\s*=\s*(?:(\w+):)*(\w+)\(.*` )

constant m_mapdef = stdmap:new()
put_mapdef( m_mapdef, "new" )

enum
	MAPDEF_ID,
	MAPDEF_NAME,
	MAPDEF_FILE,
	MAPDEF_LINE

function shorten_path( sequence path )

	sequence INCLUDE_PATHS = include_paths( 0 )

	for i = 1 to length( INCLUDE_PATHS ) do

		sequence include_path = canonical_path( INCLUDE_PATHS[i] )

		if search:begins( include_path, path ) then
			path = path[length(include_path)+1..$]
			exit
		end if

	end for

	return path
end function

function read_mapdef( sequence routine_name, sequence file_name, integer line_no )

	sequence map_name = ""
	sequence map_file = ""
	integer map_line = 0

	sequence lines = read_lines( file_name )

	for i = line_no to 1 by -1 do

		if regex:is_match( re_mapdef, lines[i] ) then
			sequence matches = regex:matches( re_mapdef, lines[i] )
			log_debug( "lines[%d] = %s", {i,matches} )

			sequence def_vartype   = matches[2]
			sequence def_varname   = matches[3]
			sequence def_namespace = matches[4]
			sequence def_funcname  = matches[5]

			if equal( routine_name, def_funcname ) then
				map_name = def_varname
				map_file = file_name
				map_line = i
				exit
			end if

		end if

	end for

	if length( map_file ) then
		map_file = shorten_path( map_file )
	end if

	return {map_name,map_file,map_line}
end function

function add_mapdef( atom m )

	if stdmap:has( m_mapdef, m ) then
		return stdmap:get( m_mapdef, m )
	end if

	sequence map_name = ""
	sequence map_file = ""
	integer map_line = 0

ifdef EUI then

	sequence cs = debug:call_stack()

	for i = 1 to length( cs ) do
		log_trace( "cs[%d] = %s", {i,cs[i]} )
	end for

	-- called routine
	sequence routine_name = cs[2][CS_ROUTINE_NAME]

	-- calling routine
	sequence file_name = cs[3][CS_FILE_NAME]
	integer  line_no   = cs[3][CS_LINE_NO]

	file_name = canonical_path( file_name )

	log_debug( "Looking for map near %s:%d", {file_name,line_no} )
	{map_name,map_file,map_line} = read_mapdef( routine_name, file_name, line_no )

	if length( map_name ) then
		log_debug( "Found map %s at %s:%d", {map_name,file_name,map_line} )
	else
		log_debug( "Could not find map near %s:%d", {file_name,line_no} )
	end if

end ifdef

	if length( map_name ) = 0 then
		map_name = sprintf( "map #%d", m )
	end if

	sequence mapdef = {m,map_name,map_file,map_line}
	log_debug( "ADD, map_id=%d, map_name=%s, map_file=%s, map_line=%d", mapdef )

	stdmap:put( m_mapdef, m, mapdef )

	return mapdef
end function

procedure del_mapdef( atom m )

	if stdmap:has( m_mapdef, m ) then

		sequence mapdef = stdmap:get( m_mapdef, m )
		log_debug( "DEL, map_id=%d, map_name=%s, map_file=%s, map_line=%d", mapdef )

		stdmap:remove( m_mapdef, m )

	end if

end procedure

function get_mapdef( atom m )

	if stdmap:has( m_mapdef, m ) then
		return stdmap:get( m_mapdef, m )
	end if

	return {m,sprintf("map #%d",m),"",0}
end function

procedure put_mapdef( atom m, sequence routine_name )

	sequence map_name = ""
	sequence map_file = ""
	integer map_line = 0

ifdef EUI then

	sequence cs = debug:call_stack()

	sequence file_name = cs[$][CS_FILE_NAME]
	integer  line_no   = cs[$][CS_LINE_NO]

	file_name = canonical_path( file_name )

	log_debug( "Looking for map near %s:%d", {file_name,line_no} )
	{map_name,map_file,map_line} = read_mapdef( routine_name, file_name, line_no )

	if length( map_name ) then
		log_debug( "Found map %s at %s:%d", {map_name,file_name,map_line} )
	else
		log_debug( "Could not find map near %s:%d", {file_name,line_no} )
	end if

end ifdef

	if length( map_name ) = 0 then
		map_name = sprintf( "map #%d", m )
	end if

	sequence mapdef = {m,map_name,map_file,map_line}

	stdmap:put( m_mapdef, m, mapdef )
	stdmap:put( m_mapdef, map_name, m )

end procedure


sequence pretty_options = PRETTY_DEFAULT
pretty_options[DISPLAY_ASCII] = 2
pretty_options[LINE_BREAKS  ] = 0

enum
	MAP_SIZE,
	MAP_SLOTS,
	MAP_MAX

enum
	SLOT_HASH,
	SLOT_KEY,
	SLOT_VALUE

public procedure print_map( atom m, integer nested=0, integer indent=pretty_options[INDENT], integer column=pretty_options[START_COLUMN] )

	if not map( m ) then
		log_warn( "Value m (%s) proved to print_map() is not a map", {m} )
		return
	end if

	sequence mapdef = get_mapdef( m )

	sequence map_name = mapdef[MAPDEF_NAME]
	sequence map_file = mapdef[MAPDEF_FILE]
	integer  map_line = mapdef[MAPDEF_LINE]

	sequence padding = repeat( ' ', (column-1)*indent )

	puts( 1, padding )

if length( map_file ) = 0 and map_line = 0 then
	printf( 1, "%s = {", {map_name} )
else
	printf( 1, "%s@%s:%d (map #%d) = {", {map_name,map_file,map_line,m} )
end if

	atom     map_size  = ram_space[m][MAP_SIZE]
	sequence map_slots = ram_space[m][MAP_SLOTS]
	atom     map_max   = ram_space[m][MAP_MAX]

	if length( map_slots ) then

		pretty_options[START_COLUMN] += 1
		padding = repeat( ' ', (column)*indent )

		for i = 1 to length( map_slots ) do

			if equal( map_slots[i], {-2,0,0} ) then
				continue
			end if

			atom slot_hash = map_slots[i][SLOT_HASH]
			object slot_key = map_slots[i][SLOT_KEY]
			object slot_val = map_slots[i][SLOT_VALUE]

			puts( 1, "\n" & padding )
			printf( 1, "%4d: {0x%08x,", {i,slot_hash} )
			pretty_print( 1, slot_key, pretty_options )
			puts( 1, "," )

			if stdmap:map( slot_val ) and nested != 0 then
				print_map( slot_val, nested-1, indent, column+1 )
			else
				pretty_print( 1, slot_val, pretty_options )
			end if

			puts( 1, "}" )

			if i < length( map_slots ) then
				puts( 1, "," )
			end if

		end for

		pretty_options[START_COLUMN] -= 1
		padding = repeat( ' ', (column-1)*indent )

		puts( 1, "\n" & padding )

	end if

	puts( 1, "}\n" )

end procedure

public procedure print_maps()

	for i = 1 to length( ram_space ) do
		if stdmap:map( i ) then
			print_map( i )
		end if
	end for

end procedure

public constant
	PUT      = stdmap:PUT,
	ADD      = stdmap:ADD,
	SUBTRACT = stdmap:SUBTRACT,
	MULTIPLY = stdmap:MULTIPLY,
	DIVIDE   = stdmap:DIVIDE,
	APPEND   = stdmap:APPEND,
	CONCAT   = stdmap:CONCAT,
	LEAVE    = stdmap:LEAVE

public type map( object m )
	return stdmap:map( m )
end type

constant DEFAULT_SIZE = 8

public function calc_hash( object key_p, integer max_hash_p )
	return stdmap:calc_hash( key_p, max_hash_p )
end function

public procedure rehash( map the_map_p, integer requested_size_p = 0 )
	stdmap:rehash( the_map_p, requested_size_p )
end procedure

public function new( integer initial_size_p = DEFAULT_SIZE )

	atom m = stdmap:new( initial_size_p )

	add_mapdef( m )

	return delete_routine( m, routine_id("del_mapdef") )
end function

public function new_extra( object the_map_p, integer initial_size_p = DEFAULT_SIZE )

	atom m = stdmap:new_extra( the_map_p, initial_size_p )

	add_mapdef( m )

	return delete_routine( m, routine_id("del_mapdef") )
end function

public function compare( map map_1_p, map map_2_p, integer scope_p = 'd' )
	return stdmap:compare( map_1_p, map_2_p, scope_p )
end function

public function has( map the_map_p, object key )
	return stdmap:has( the_map_p, key )
end function

public function get( map the_map_p, object key, object default = 0 )
	return stdmap:get( the_map_p, key, default )
end function

public function nested_get( map the_map_p, sequence the_keys_p, object default_value_p = 0 )
	return stdmap:nested_get( the_map_p, the_keys_p, default_value_p )
end function

public procedure put( map the_map_p, object key, object val, object op = PUT )
	stdmap:put( the_map_p, key, val, op )
end procedure

public procedure nested_put( map the_map_p, sequence the_keys_p, object the_value_p, integer operation_p = PUT )
	stdmap:nested_put( the_map_p, the_keys_p, the_value_p, operation_p )
end procedure

public procedure remove( map the_map_p, object key )
	stdmap:remove( the_map_p, key )
end procedure

public procedure clear( map the_map_p )
	stdmap:clear( the_map_p )
end procedure

public function size( map the_map_p )
	return stdmap:size( the_map_p )
end function

public constant
	NUM_ENTRIES     = stdmap:NUM_ENTRIES,
	NUM_IN_USE      = stdmap:NUM_IN_USE,
	NUM_BUCKETS     = stdmap:NUM_BUCKETS,
	LARGEST_BUCKET  = stdmap:LARGEST_BUCKET,
	SMALLEST_BUCKET = stdmap:SMALLEST_BUCKET,
	AVERAGE_BUCKET  = stdmap:AVERAGE_BUCKET,
	STDEV_BUCKET    = stdmap:STDEV_BUCKET

public function statistics( map the_map_p )
	return stdmap:statistics( the_map_p )
end function

public function keys( map the_map_p, integer sorted_result = 0 )
	return stdmap:keys( the_map_p, sorted_result )
end function

public function values( map the_map, object keys=0, object default_values=0 )
	return stdmap:values( the_map, keys, default_values )
end function

public function pairs( map the_map, integer sorted_result = 0 )
	return stdmap:pairs( the_map, sorted_result )
end function

public procedure optimize( map the_map_p )
	stdmap:optimize( the_map_p )
end procedure

public function load_map( object input_file_name )
	return stdmap:load_map( input_file_name )
end function

public constant
	SM_TEXT = stdmap:SM_TEXT,
	SM_RAW  = stdmap:SM_RAW

public function save_map( map the_map_, object file_name_p, integer type_ = SM_TEXT )
	return stdmap:save_map( the_map_, file_name_p, type_ )
end function

public function copy( map source_map, object dest_map=0, integer put_operation = PUT )
	return stdmap:copy( source_map, dest_map, put_operation )
end function

public function new_from_kvpairs( sequence kv_pairs )

	atom m = stdmap:new_from_kvpairs( kv_pairs )

	add_mapdef( m )

	return delete_routine( m, routine_id("del_mapdef") )
end function

public function new_from_string( sequence kv_string )

	atom m = stdmap:new_from_string( kv_string )

	add_mapdef( m )

	return delete_routine( m, routine_id("del_mapdef") )
end function

public function for_each( map source_map, integer user_rid, object user_data = 0, integer in_sorted_order = 0, integer signal_boundary = 0 )
	return stdmap:for_each( source_map, user_rid, user_data, in_sorted_order, signal_boundary )
end function

end ifdef -- MAPDBG
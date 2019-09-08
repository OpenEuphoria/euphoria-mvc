
namespace model

include std/convert.e
include std/error.e
include std/map.e
include std/math.e
include std/pretty.e
include std/search.e
include std/sequence.e
include std/text.e
include std/types.e

include mvc/logger.e
include mvc/database.e

sequence model_names = {}
sequence model_fields = {}

constant MODEL_NAME = "!MODEL_NAME!"   -- registered model name (string)
constant MODEL_TYPE = "!MODEL_TYPE!"   -- registered model type (integer)
constant MODEL_DIRTY = "!MODEL_DIRTY!" -- list of fields needing update

public enum
    FIELD_NAME,
    FIELD_TYPE,
    FIELD_VALUE,
    FIELD_COUNT = 3,
$

public enum
    NONE = 0,
    INTEGER,
    REAL,
    TEXT,
    BLOB,
    DATETIME,
    TIMESTAMP,
$

public constant TYPE_NAMES = {
    "INTEGER",
    "REAL",
    "TEXT",
    "BLOB",
    "DATETIME",
    "TIMESTAMP"
}

public constant
    AUTO_INCREMENT     = #0100,
    NOT_NULL           = #0200,
    PRIMARY_KEY        = #0400,
    UNIQUE             = #0800,
$

public constant DEFAULT_ID = or_all({ INTEGER, AUTO_INCREMENT, PRIMARY_KEY })

constant TYPE_MASK     = #00FF
constant OPTION_MASK   = #FF00

constant FIELD_DEFAULT = {
    "NULL", -- FIELD_NAME
    NONE,   -- FIELD_TYPE
    0       -- FIELD_VALUE
}

public type valid_field_name( object x )

    return sequence( x )
       and length( x ) > 1
       and t_identifier( x )
       and not equal( x, "NULL" )

end type

public type valid_field_type( object x )

    integer field_type = and_bits( x, TYPE_MASK )

    return equal( field_type, INTEGER )
        or equal( field_type, REAL )
        or equal( field_type, TEXT )
        or equal( field_type, BLOB )
        or equal( field_type, DATETIME )
        or equal( field_type, TIMESTAMP )

end type

public type valid_field_option( object x )

    integer field_option = and_bits( x, OPTION_MASK )

    return equal( field_option, AUTO_INCREMENT )
        or equal( field_option, NOT_NULL )
        or equal( field_option, PRIMARY_KEY )
        or equal( field_option, UNIQUE )

end type

public type valid_id( object x )

    return integer( x )
       and 1 <= x
       and x <= length( model_names )

end type

public type valid_name( object x )
    return find( x, model_names ) != 0
end type

public type valid_field( object x )

    return sequence( x )
       and length( x ) = FIELD_COUNT
       and valid_field_name( x[FIELD_NAME] )
       and valid_field_type( x[FIELD_TYPE] )

end type

public type valid_model( object x )

    return map( x )
       and map:has( x, MODEL_NAME )
       and map:has( x, MODEL_TYPE )

end type

public type valid_param( object x )

    return sequence( x )
       and length( x ) = 2
       and valid_field_name( x[1] )

end type

public function define( sequence model_name, sequence field_list )

    if valid_name( model_name ) then
        error:crash( "attempt to redefine model '%s'", {model_name} )
    end if

    for i = 1 to length( field_list ) do

        integer len = length( field_list[i] )

        if len < FIELD_COUNT then
            field_list[i] &= FIELD_DEFAULT[len+1..$]
        end if

        if not valid_field( field_list[i] ) then
            error:crash( "field %d of model '%s' is not valid", {i,model_name} )
        end if

    end for

    model_names = append( model_names, model_name )
    model_fields = append( model_fields, field_list )

    log_debug( "Registered model %s with fields %s", {model_name,vslice(field_list,1)} )

    return length( model_names )
end function

public function init( integer model_type )

    if not valid_id( model_type ) then
        error:crash( "invalid model type: %d", {model_type} )
    end if

    sequence model_name = model_names[model_type]
    sequence field_list = model_fields[model_type]

	atom result = db_query( """
		SELECT 1
		  FROM `%s`
		 LIMIT 1
	""", {model_name} )

    if result != -1 then
        return TRUE
    end if

    sequence column_list = {}

    for i = 1 to length( field_list ) do

        sequence field_name = field_list[i][FIELD_NAME]
        integer field_type = and_bits( field_list[i][FIELD_TYPE], TYPE_MASK )
        integer field_option = and_bits( field_list[i][FIELD_TYPE], OPTION_MASK )

        sequence column_type = TYPE_NAMES[field_type]

        integer not_null = and_bits( field_option, NOT_NULL ) = NOT_NULL
        integer auto_increment = and_bits( field_option, AUTO_INCREMENT ) = AUTO_INCREMENT
        integer primary_key = and_bits( field_option, PRIMARY_KEY ) = PRIMARY_KEY
        integer unique = and_bits( field_option, UNIQUE ) = UNIQUE

        if not_null then
            column_type &= " NOT NULL"
        end if

        if auto_increment then
            column_type &= " AUTO_INCREMENT"
        end if

        if primary_key then
            column_type &= " PRIMARY KEY"
        elsif unique then
            column_type &= " UNIQUE"
        end if

        sequence column_spec = sprintf( "`%s` %s", {field_name,column_type} )
        column_list = append( column_list, column_spec )

    end for

    sequence columns = stdseq:join( column_list, ", " )
    sequence query = sprintf( "CREATE TABLE `%s` (%s)", {model_name,columns} )

    result = db_query( query )

    if result != -1 then
        return TRUE
    end if

    sequence error = db_error()
    printf( 2, "%s\n", {error} )

    return FALSE
end function

public function new( integer model_type, sequence params = {} )

    if not valid_id( model_type ) then
        error:crash( "invalid model type: %d", {model_type} )
    end if

    sequence model_name = model_names[model_type]
    sequence field_list = model_fields[model_type]

    object model = map:new()
    map:put( model, MODEL_NAME, model_name )
    map:put( model, MODEL_TYPE, model_type )

    for i = 1 to length( field_list ) do

        sequence field_name = field_list[i][FIELD_NAME]
        object field_value = field_list[i][FIELD_VALUE]

        map:put( model, field_name, field_value )

    end for

    for i = 1 to length( params ) do

        if not valid_param( params[i] ) then
            error:crash( "param %d if model '%s' is not valid", {i,model_name} )
        end if

        sequence field_name = params[i][1]
        object field_value = params[i][2]

        map:put( model, field_name, field_value )

    end for

    return model
end function

public function get( object model, sequence name, object default = 0 )
    return map:get( model, name, default )
end function

public procedure set( object model, sequence name, object value )

    integer model_type = map:get( model, MODEL_TYPE, 0 )
    sequence field_list = model_fields[model_type]

    sequence dirty = map:get( model, MODEL_DIRTY, {} )
    if not find( name, dirty ) then
        map:put( model, MODEL_DIRTY, name, APPEND )
    end if

    map:put( model, name, value )

end procedure

public function fixup_query( sequence query, object params = {} )

	if length( query ) = 0 then
		return "WHERE TRUE"
	end if

	query = text:trim( query )
	sequence first_word = ""

	integer space = find( ' ', query )
	if space then
		first_word = text:upper( query[1..space-1] )
	end if

	if not find( first_word, {"SELECT","WHERE","ORDER","GROUP","LIMIT"} ) then
		query = "WHERE " & query
	end if

	query = find_replace( '\t', query, ' ' )
	query = find_replace( '\r', query, ' ' )
	query = find_replace( '\n', query, ' ' )
	query = match_replace( "   ", query, " " )
	query = match_replace( "  ", query, " " )

	return sprintf( query, params )
end function

public function count_of( integer model_type, sequence query = "", object params = {} )

    if not valid_id( model_type ) then
        error:crash( "invalid model type: %d", {model_type} )
    end if

    sequence model_name = model_names[model_type]
    sequence fixed_query = fixup_query( query, params )

	atom result = db_query( """
		SELECT COUNT(*) AS count
		  FROM `%s`
		  %s
	""", {model_name,fixed_query} )

	if result = -1 then
		return -1
	end if

	sequence row_data = db_fetch()

	return to_integer( row_data[1] )
end function

public function do_fetch( integer model_type, sequence query, object params )

    if not valid_id( model_type ) then
        error:crash( "invalid model type: %d", {model_type} )
    end if

    sequence model_name = model_names[model_type]
    sequence field_list = model_fields[model_type]

    sequence column_names = vslice( field_list, FIELD_NAME )
    sequence column_types = vslice( field_list, FIELD_TYPE )

    sequence columns = "`" & stdseq:join( column_names, "`,`" ) & "`"
    sequence fixed_query = fixup_query( query, params )

    atom result = db_query( """
		SELECT %s
		  FROM `%s`
		  %s
	""", {columns,model_name,fixed_query} )

    if result = -1 then
        log_error( "Error: " & db_error() )
    end if

    return {result,column_names,column_types}
end function

public function fetch_one( integer model_type, sequence query, object params = {} )

    atom result
    sequence column_names
    sequence column_types

    {result,column_names,column_types} = do_fetch( model_type, query, params )

    if result = -1 then
        return 0
    end if

    sequence row_data = db_fetch( result )

    if length( row_data ) = 0 then
        return 0
    end if

    object model = model:new( model_type )

    for i = 1 to length( column_names ) do

        sequence field_name = column_names[i]
        integer  field_type = column_types[i]
        object field_value = row_data[i]

        if and_bits( field_type, TYPE_MASK ) = INTEGER then
            field_value = to_integer( field_value )

        elsif and_bits( field_type, TYPE_MASK ) = REAL then
            field_value = to_number( field_value )

        end if

        map:put( model, field_name, field_value )

    end for

    db_free( result )

    return model
end function

public function fetch_all( integer model_type, sequence query = "", object params = {} )

    atom result
    sequence column_names
    sequence column_types

    {result,column_names,column_types} = do_fetch( model_type, query, params )

    if result = -1 then
        return {}
    end if

    sequence models = {}
    sequence row_data = db_fetch( result )

    while length( row_data ) do

        object model = model:new( model_type )

        for i = 1 to length( column_names ) do

            sequence field_name = column_names[i]
            integer  field_type = column_types[i]
            object field_value = row_data[i]

            if and_bits( field_type, TYPE_MASK ) = INTEGER then
                field_value = to_integer( field_value )

            elsif and_bits( field_type, TYPE_MASK ) = REAL then
                field_value = to_number( field_value )

            end if

            map:put( model, field_name, field_value )

        end for

        models = append( models, model )

        row_data = db_fetch( result )
    end while

    db_free( result )

    return models
end function

public function store( object model )

    integer model_type   = map:get( model, MODEL_TYPE, 0 )
    sequence model_name  = map:get( model, MODEL_NAME, "" )
    sequence model_ditry = map:get( model, MODEL_DIRTY, {} )

    if model_type = 0 or length( model_name ) = 0 then
        return 0
    end if

    sequence field_list = model_fields[model_type]

    return 0
end function

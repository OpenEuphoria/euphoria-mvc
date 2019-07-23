
namespace logger

include std/console.e
include std/datetime.e
include std/filesys.e
include std/io.e
include std/graphics.e
include std/pretty.e
include std/sequence.e
include std/text.e
include std/types.e

ifdef EUI then
include euphoria/debug/debug.e
end ifdef

public enum
	LOG_OFF = 0,
	LOG_ERROR,
	LOG_WARN,
	LOG_INFO,
	LOG_DEBUG,
	LOG_TRACE,
	LOG_ALL

sequence log_title = repeat( "", LOG_ALL )
log_title[LOG_ERROR] = "ERROR"
log_title[LOG_WARN ] = "WARN"
log_title[LOG_INFO ] = "INFO"
log_title[LOG_DEBUG] = "DEBUG"
log_title[LOG_TRACE] = "TRACE"

sequence log_color = repeat( 0, LOG_ALL )
log_color[LOG_ERROR] = RED
log_color[LOG_WARN ] = YELLOW
log_color[LOG_INFO ] = WHITE
log_color[LOG_DEBUG] = GREEN
log_color[LOG_TRACE] = BLUE

constant DEFAULT_FORMAT = "%Y/%m/%d %H:%M:%S"
constant DEFAULT_COLOR  = GRAY
constant DEFAULT_OUTPUT = {STDERR}

ifdef LOG_TRACE then
	constant DEFAULT_LEVEL = LOG_TRACE

elsifdef LOG_DEBUG then
	constant DEFAULT_LEVEL = LOG_DEBUG

elsifdef LOG_INFO then
	constant DEFAULT_LEVEL = LOG_INFO

elsifdef LOG_WARN then
	constant DEFAULT_LEVEL = LOG_WARN

elsifdef LOG_ERROR then
	constant DEFAULT_LEVEL = LOG_ERROR

elsedef
	constant DEFAULT_LEVEL = LOG_INFO

end ifdef

integer  m_date_color   = DEFAULT_COLOR
sequence m_date_format  = DEFAULT_FORMAT
integer  m_log_level    = DEFAULT_LEVEL
sequence m_log_output   = DEFAULT_OUTPUT

public procedure set_date_color( integer color = DEFAULT_COLOR )
	m_date_color = color
end procedure

public procedure set_date_format( sequence format = DEFAULT_FORMAT )
	m_date_format = format
end procedure

public procedure set_log_level( integer level = DEFAULT_LEVEL )
	m_log_level = level
end procedure

public procedure set_log_output( object file = DEFAULT_OUTPUT )

	if atom( file ) or string( file ) then
		file = {file}
	end if

	sequence name = file

	for i = 1 to length( file ) do
		if integer( file[i] ) then

			if file[i] = STDOUT then
				name[i] = "STDOUT"

			elsif file[i] = STDERR then
				name[i] = "STDERR"

			else
				name[i] = sprintf( "file #%d", file[i] )

			end if

		elsif sequence( file[i] ) then

			-- default append
			sequence mode = "a"

			if file[i][1] = '!' then
				-- force overwrite
				file[i] = file[i][2..$]
				mode = "w"
			end if

			name[i] = file[i]
			file[i] = open( name[i], mode, TRUE )

		end if
	end for

	m_log_output = file

	for i = 1 to length( name ) do
		log_info( "Logging to %s", {name[i]} )
	end for

end procedure

public function get_timestamp()
	return datetime:format( datetime:now(), m_date_format )
end function

public procedure set_color( integer fn, integer color )

	if fn = STDERR or fn = STDOUT then
		text_color( color )
	end if

end procedure

sequence pretty_options = PRETTY_DEFAULT
pretty_options[DISPLAY_ASCII] =      2  -- display as "string" when all integers of a sequence are in ASCII range
pretty_options[INDENT       ] =      2  -- amount to indent for each level of sequence nesting -- default: 2
pretty_options[START_COLUMN ] =      1  -- column we are starting at -- default: 1
pretty_options[WRAP         ] =      0  -- approximate column to wrap at -- default: 78
pretty_options[INT_FORMAT   ] =    "%d" -- format to use for integers -- default: "%d"
pretty_options[FP_FORMAT    ] = "%.10g" -- format to use for floating-point numbers -- default: "%.10g"
pretty_options[MIN_ASCII    ] =     32  -- minimum value for printable ASCII -- default: 32
pretty_options[MAX_ASCII    ] =    127  -- maximum value for printable ASCII -- default: 127
pretty_options[MAX_LINES    ] =     32  -- maximum number of lines to output -- default: 1 billion
pretty_options[LINE_BREAKS  ] =  FALSE  -- line breaks between elements -- default: TRUE

public procedure log_message( integer level, sequence msg, object data = {} )

	if not equal( data, {} ) then

		if atom( data ) then
			data = {data}
		end if

		integer i = 0
		integer index = find( '%', msg )

		while index != 0 and index < length(msg) do

			i += msg[index+1] != '%'

			if msg[index+1] = 's' then -- %s format
				data[i] = pretty_sprint( data[i], pretty_options )
			end if

			index = find( '%', msg, index+1 )
		end while

		msg = sprintf( msg, data )

	end if

ifdef EUI then

	-- we can only support call_stack() in the interpreter so
	-- if you translate your app, you'll lose the caller info

	sequence cs = debug:call_stack()

	sequence routine_name = cs[3][CS_ROUTINE_NAME]
	sequence file_name    = cs[3][CS_FILE_NAME]
	integer  line_no      = cs[3][CS_LINE_NO]

	file_name = filename( file_name )

end ifdef

	sequence msg_lines = split( msg, "\n" )
	sequence current_timestamp = get_timestamp()

	for i = 1 to length( msg_lines ) do

		msg_lines[i] = text:trim_tail( msg_lines[i] )

		for j = 1 to length( m_log_output ) do

			integer fn = m_log_output[j]

			-- write current timestamp
			set_color( fn, m_date_color )
			printf( fn, "%s", {current_timestamp} )

			-- write log level title (WARN, etc.)
			set_color( fn, log_color[level] )
			printf( fn, " %5s", {log_title[level]} )

		ifdef EUI then

			-- write padding to indicate the stack depth
			puts( fn, repeat(' ',length(cs)-2) )

			-- write calling file/line
			set_color( fn, MAGENTA )
			printf( fn, "%s@%s:%d", {routine_name,file_name,line_no} )

		end ifdef

			-- write log message
			set_color( fn, WHITE )
			printf( fn, " %s\n", {msg_lines[i]} )

		end for
	end for

end procedure

public procedure log_error( sequence msg, object data = {} )

	if m_log_level >= LOG_ERROR then
		log_message( LOG_ERROR, msg, data )
	end if

end procedure

public procedure log_warn( sequence msg, object data = {} )

	if m_log_level >= LOG_WARN then
		log_message( LOG_WARN, msg, data )
	end if

end procedure

public procedure log_info( sequence msg, object data = {} )

	if m_log_level >= LOG_INFO then
		log_message( LOG_INFO, msg, data )
	end if

end procedure

public procedure log_debug( sequence msg, object data = {} )

	if m_log_level >= LOG_DEBUG then
		log_message( LOG_DEBUG, msg, data )
	end if

end procedure

public procedure log_trace( sequence msg, object data = {} )

	if m_log_level >= LOG_TRACE then
		log_message( LOG_TRACE, msg, data )
	end if

end procedure


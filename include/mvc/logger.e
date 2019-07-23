
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

--set_log_output()

public function get_timestamp()
	return datetime:format( datetime:now(), m_date_format )
end function

public procedure set_color( integer fn, integer color )

	if fn = STDERR or fn = STDOUT then
		text_color( color )
	end if

end procedure

public procedure log_message( integer level, sequence msg, object data = {} )

	if not equal( data, {} ) then

		if atom( data ) then
			data = {data}
		end if

		for i = 1 to length( data ) do
			if sequence( data[i] ) and not string( data[i] ) then
				data[i] = pretty_sprint( data[i], {2} )
			end if
		end for

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

			-- write current date
			set_color( fn, m_date_color )
			printf( fn, "%s ", {current_timestamp} )

			-- write log level title
			set_color( fn, log_color[level] )
			printf( fn, "%s ", {log_title[level]} )

		ifdef EUI then

			-- write calling file/line
			set_color( fn, MAGENTA )
			printf( fn, "%s@%s:%d ", {routine_name,file_name,line_no} )

		end ifdef

			-- write log message
			set_color( fn, WHITE )
			printf( fn, "%s\n", {msg_lines[i]} )

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



namespace logger

include std/console.e
include std/datetime.e
include std/io.e
include std/graphics.e
include std/sequence.e
include std/text.e
include std/types.e

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
log_color[LOG_TRACE] = MAGENTA

constant DEFAULT_FORMAT = "%Y/%m/%d %H:%M:%S"
constant DEFAULT_COLOR  = GRAY
constant DEFAULT_LEVEL  = LOG_INFO
constant DEFAULT_OUTPUT = {STDERR}

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
	
	for i = 1 to length( file ) do
		if sequence( file[i] ) then
			
			-- default append
			sequence mode = "a"
			
			if file[i][1] = '!' then
				-- force overwrite
				file[i] = file[i][2..$]
				mode = "w"
			end if
			
			file[i] = open( file[i], mode, TRUE )
			
		end if
	end for
	
	m_log_output = file
	
end procedure

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
		msg = sprintf( msg, data )
	end if

	sequence msg_lines = split( msg, "\n" )
	sequence current_timestamp = get_timestamp()

	for i = 1 to length( msg_lines ) do
		for j = 1 to length( m_log_output ) do

			integer fn = m_log_output[j]

			-- write current date
			set_color( fn, m_date_color )
			puts( fn, current_timestamp & " " )

			-- write log level title
			set_color( fn, log_color[level] )
			puts( fn, log_title[level] & " " )

			-- write log message
			set_color( fn, WHITE )
			puts( fn, text:trim(msg_lines[i]) & "\n" )

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


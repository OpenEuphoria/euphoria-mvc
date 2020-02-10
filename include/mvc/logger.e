
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
	LOG_VERBOSE = -1, -- special flag for extra verbosity
	----------
	LOG_OFF = 0,
	LOG_ERROR,
	LOG_WARN,
	LOG_INFO,
	LOG_DEBUG,
	LOG_TRACE,
	----------
	LOG_ALL -- this should always be the last item

sequence log_title = repeat( "", LOG_ALL-1 )
log_title[LOG_ERROR] = "ERROR"
log_title[LOG_WARN ] = "WARN"
log_title[LOG_INFO ] = "INFO"
log_title[LOG_DEBUG] = "DEBUG"
log_title[LOG_TRACE] = "TRACE"

sequence log_color = repeat( 0, LOG_ALL-1 )
log_color[LOG_ERROR] = RED
log_color[LOG_WARN ] = YELLOW
log_color[LOG_INFO ] = WHITE
log_color[LOG_DEBUG] = GREEN
log_color[LOG_TRACE] = BLUE

constant DEFAULT_DATE_COLOR  = GRAY
constant DEFAULT_DATE_FORMAT = "%Y/%m/%d %H:%M:%S"
constant DEFAULT_STACK_COLOR = MAGENTA
constant DEFAULT_STACK_INDENT = FALSE
constant DEFAULT_LOG_COLOR   = WHITE
constant DEFAULT_LOG_OUTPUT = {STDERR}

--
-- Default log level can be set via command line, e.g. eui -D LOG_TRACE myapp.ex
--

ifdef LOG_TRACE then
	constant DEFAULT_LOG_LEVEL = LOG_TRACE

elsifdef LOG_DEBUG then
	constant DEFAULT_LOG_LEVEL = LOG_DEBUG

elsifdef LOG_INFO then
	constant DEFAULT_LOG_LEVEL = LOG_INFO

elsifdef LOG_WARN then
	constant DEFAULT_LOG_LEVEL = LOG_WARN

elsifdef LOG_ERROR then
	constant DEFAULT_LOG_LEVEL = LOG_ERROR

elsedef
	constant DEFAULT_LOG_LEVEL = LOG_INFO

end ifdef

ifdef LOG_VERBOSE then
	constant DEFAULT_LOG_VERBOSE = TRUE

elsedef
	constant DEFAULT_LOG_VERBOSE = FALSE

end ifdef

integer  m_date_color   = DEFAULT_DATE_COLOR
sequence m_date_format  = DEFAULT_DATE_FORMAT
integer  m_stack_color  = DEFAULT_STACK_COLOR
integer  m_stack_indent = DEFAULT_STACK_INDENT
integer  m_log_color    = DEFAULT_LOG_COLOR
integer  m_log_level    = DEFAULT_LOG_LEVEL
integer  m_log_verbose  = DEFAULT_LOG_VERBOSE
sequence m_log_output   = DEFAULT_LOG_OUTPUT

--
-- The date column should be a subdued color to call out the other information.
--
public function set_date_color( integer color = DEFAULT_DATE_COLOR )
	integer orig_color = m_date_color
	m_date_color = color
	return orig_color
end function

--
-- The date column should be sortable, but we may want other formats available.
--
public function set_date_format( sequence format = DEFAULT_DATE_FORMAT )
	sequence orig_format = m_date_format
	m_date_format = format
	return orig_format
end function

--
-- This is the call stack column color, should also be a bit subdued.
--
public function set_stack_color( integer color = DEFAULT_STACK_COLOR )
	integer orig_color = m_stack_color
	m_stack_color = color
	return orig_color
end function

--
-- Turns on call stack indenting.
--
public function set_stack_indent( integer indent = DEFAULT_STACK_INDENT )
	integer orig_indent = m_stack_indent
	m_stack_indent = indent
	return orig_indent
end function

--
-- This is the default log message color. Usually just WHITE to match the default console.
--
public function set_log_color( integer color = DEFAULT_LOG_COLOR )
	integer orig_color = m_log_color
	m_log_color = color
	return orig_color
end function

--
-- Log level can also be set by ifdef (see above).
--
public function set_log_level( integer level = DEFAULT_LOG_LEVEL )
	integer orig_level = m_log_level
	m_log_level = level
	return orig_level
end function

--
-- Set an additional level of verbosity for logging.
-- This is best used for additional LOG_TRACE output, i.e. larger variables.
--
public function set_log_verbose( integer verbose = DEFAULT_LOG_VERBOSE ) -- a call to set_log_verbose() should enable
	integer orig_verbose = m_log_verbose
	m_log_verbose = verbose
	return orig_verbose
end function

--
-- Set log output to one or more file handle or file name.
-- If you specify a file name, use "!" to force overwrite.
-- e.g. set_log_output({ STDERR, "!myfile.log" })
--
public function set_log_output( object file = DEFAULT_LOG_OUTPUT )

	sequence orig_output = m_log_output

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

			-- default to append mode
			sequence mode = "a"

			if file[i][1] = '!' then
				-- force overwrite
				file[i] = file[i][2..$]
				mode = "w"
			end if

			name[i] = file[i]
			file[i] = open( name[i], mode, TRUE ) -- auto_close = TRUE

		end if
	end for

	m_log_output = file

	for i = 1 to length( name ) do
		log_info( "Logging to %s", {name[i]} )
	end for

	return orig_output
end function

--
-- Get a formatted timestamp.
--
public function get_timestamp( datetime dt = datetime:now() )
	return datetime:format( dt, m_date_format )
end function

--
-- Set the output text color.
--
public procedure set_color( integer fn, integer color )

	if fn = STDERR or fn = STDOUT then
		-- only set for console output
		text_color( color )
	end if

end procedure

sequence m_pretty_options = PRETTY_DEFAULT
m_pretty_options[DISPLAY_ASCII] =      2  -- display as "string" when all integers of a sequence are in ASCII range
m_pretty_options[INDENT       ] =      2  -- amount to indent for each level of sequence nesting -- default: 2
m_pretty_options[START_COLUMN ] =      1  -- column we are starting at -- default: 1
m_pretty_options[WRAP         ] =      0  -- approximate column to wrap at -- default: 78
m_pretty_options[INT_FORMAT   ] =    "%d" -- format to use for integers -- default: "%d"
m_pretty_options[FP_FORMAT    ] = "%.10g" -- format to use for floating-point numbers -- default: "%.10g"
m_pretty_options[MIN_ASCII    ] =     32  -- minimum value for printable ASCII -- default: 32
m_pretty_options[MAX_ASCII    ] =    127  -- maximum value for printable ASCII -- default: 127
m_pretty_options[MAX_LINES    ] =     32  -- maximum number of lines to output -- default: 1 billion
m_pretty_options[LINE_BREAKS  ] =  FALSE  -- line breaks between elements -- default: TRUE

--
-- Override the default pretty_print() options.
--
public function set_pretty_options( sequence pretty_options )
	sequence orig_options = m_pretty_options
	m_pretty_options = pretty_options
	return orig_options
end function

ifdef EUI then

--
-- We're going to need to filter these out of the call stack.
--
constant LOG_ROUTINES = {
	"call_stack",
	"log_message",
	"log_error",
	"log_warn",
	"log_info",
	"log_debug",
	"log_trace"
}

end ifdef

--
-- All purpose message logging function.
--
public procedure log_message( integer level, sequence msg, object data = {}, integer flags = 0 )

	if and_bits( flags, LOG_VERBOSE ) = LOG_VERBOSE and m_log_verbose != TRUE then
		-- verbose mode requested but not enabled, so just give up
		return
	end if

	if atom( data ) then
		data = {data}
	end if

	-- convert anything that's meant to be a string into its pretty printed version
	-- this will strip new lines, add quotes, escape characters, etc. for better output

	if not equal( data, {} ) then

		integer i = 0
		integer index = find( '%', msg )

		while index != 0 and index < length(msg) do

			if not find( msg[index+1], "dxosefg%" ) then
				index = find( '%', msg, index+1 )
				continue
			end if

			i += 1

			if msg[index+1] = 's' then -- %s format
				data[i] = pretty_sprint( data[i], m_pretty_options )
			end if

			index = find( '%', msg, index+1 )
		end while

		msg = sprintf( msg, data )

	end if

ifdef EUI then

	-- we can only support call_stack() in the interpreter so if you translate your app,
	-- you'll lose access to the call stack information. so debug in the interpeter!

	sequence cs = debug:call_stack()

	-- filter out the leading calls to our own routines
	while length( cs ) and find( cs[1][CS_ROUTINE_NAME], LOG_ROUTINES ) do
		cs = cs[2..$]
	end while

	sequence routine_name = cs[1][CS_ROUTINE_NAME]
	sequence file_name    = cs[1][CS_FILE_NAME]
	integer  line_no      = cs[1][CS_LINE_NO]

	-- strip full path to just file name
	file_name = filename( file_name )

end ifdef

	-- split message into lines and log each one separately
	sequence msg_lines = split( msg, "\n" )

	-- print the same timestamp for each line of output
	sequence current_timestamp = get_timestamp()

	for i = 1 to length( msg_lines ) do

		-- trim whitespace from the right side of the string, but
		-- not the left. user might want to indent on their own
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

			if m_stack_indent then
				-- write padding to indicate the stack depth
				puts( fn, repeat(' ',length(cs)-1) )
			else
				-- just a single space to add a gap
				puts( fn, " " )
			end if

			-- write routine_name:file_name@line_no
			set_color( fn, m_stack_color )
			printf( fn, "%s@%s:%d", {routine_name,file_name,line_no} )

		end ifdef

			-- write log message
			set_color( fn, m_log_color )
			printf( fn, " %s\n", {msg_lines[i]} )

		end for
	end for

end procedure

--
-- Log an ERROR message.
--
public procedure log_error( sequence msg, object data = {}, integer flags = 0 )

	integer log_level = m_log_level

ifdef LOG_ERROR then
	log_level = LOG_ERROR
end ifdef

	if log_level >= LOG_ERROR then
		log_message( LOG_ERROR, msg, data, flags )
	end if

end procedure

--
-- Log a WARN message.
--
public procedure log_warn( sequence msg, object data = {}, integer flags = 0 )

	integer log_level = m_log_level

ifdef LOG_WARN then
	log_level = LOG_WARN
end ifdef

	if log_level >= LOG_WARN then
		log_message( LOG_WARN, msg, data, flags )
	end if

end procedure

--
-- Log an INFO message.
--
public procedure log_info( sequence msg, object data = {}, integer flags = 0 )

	integer log_level = m_log_level

ifdef LOG_INFO then
	log_level = LOG_INFO
end ifdef

	if log_level >= LOG_INFO then
		log_message( LOG_INFO, msg, data, flags )
	end if

end procedure

--
-- Log a DEBUG message.
--
public procedure log_debug( sequence msg, object data = {}, integer flags = 0 )

	integer log_level = m_log_level

ifdef LOG_DEBUG then
	log_level = LOG_DEBUG
end ifdef

	if log_level >= LOG_DEBUG then
		log_message( LOG_DEBUG, msg, data, flags )
	end if

end procedure

--
-- Log a TRACE message.
--
public procedure log_trace( sequence msg, object data = {}, integer flags = 0 )

	integer log_level = m_log_level

ifdef LOG_TRACE then
	log_level = LOG_TRACE
end ifdef

	if log_level >= LOG_TRACE then
		log_message( LOG_TRACE, msg, data, flags )
	end if

end procedure


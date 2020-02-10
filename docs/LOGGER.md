# Logger

## Concepts

The logger library provides routines to log runtime messages at various levels and adds some fancy text coloring.

## Logging levels

Each log level inherits the level above it, so `LOG_INFO` includes warn, error, etc. Each level corresponds to a logger function.

- `LOG_OFF`
- `LOG_ERROR`
- `LOG_WARN`
- `LOG_INFO` *(default)*
- `LOG_DEBUG`
- `LOG_TRACE`

## Preprocessor

The log levels above can be set via preprocessor keywords, to immediately change the logging level of your application.

    > eui -D LOG_TRACE myapp.ex

## Stack tracing

Euphoria 4.1 includes some built-in debugging routines, namely `call_stack()` which returns (you guessed it!) *the current application call stack*.

The logger routines will utilize this information if it is available (interpreted only) to show where the log message originated.

## Logger routines

### log_debug

`include mvc/logger.e`  
`public procedure log_debug( sequence msg, object data = {}, integer flags = 0 )`

Shorthand for `log_message( LOG_DEBUG, ... )`. See `log_message()` for details.

### log_error

`include mvc/logger.e`  
`public procedure log_error( sequence msg, object data = {}, integer flags = 0 )`

Shorthand for `log_message( LOG_ERROR, ... )`. See `log_message()` for details.

### log_info

`include mvc/logger.e`  
`public procedure log_info( sequence msg, object data = {}, integer flags = 0 )`

Shorthand for `log_message( LOG_INFO, ... )`. See `log_message()` for details.

### log_message

`include mvc/logger.e`  
`public procedure log_message( integer level, sequence msg, object data = {}, integer flags = 0 )`

All purpose message logging function.

**Parameters**

- **`level`** - one of the available logging levels
  - `LOG_ERROR`
  - `LOG_WARN`
  - `LOG_INFO`
  - `LOG_DEBUG`
  - `LOG_TRACE`
- **`msg`** - the log message to output, supports `printf()` formats
- **`data`** - data to be passed to message in `printf()` style
- **`flags`** - reserved for future use

**Notes**

- Call stack information can only be retrieved in the interpreter and will not be displayed in other modes.
- Multi-line messages will be displayed as separate log lines, but each line will have the same timestamp.
- All values to be printed as `%s` will first be pretty-printed. Therefore you do not need to quote strings in `msg`.

### log_trace

`include mvc/logger.e`  
`public procedure log_trace( sequence msg, object data = {}, integer flags = 0 )`

Shorthand for `log_message( LOG_TRACE, ... )`. See `log_message()` for details.

### log_warn

`include mvc/logger.e`  
`public procedure log_warn( sequence msg, object data = {}, integer flags = 0 )`

Shorthand for `log_message( LOG_WARN, ... )`.  See `log_message()` for details.

### set_date_color

`include mvc/logger.`  
`public function set_date_color( integer color = DEFAULT_DATE_COLOR )`

Sets the date string color.

**Parameters**

- **`color`** - the color for the date string, `DEFAULT_DATE_COLOR` is `GRAY`

**Returns**

The previously set date color.

### set_date_format

`include mvc/logger.e`  
`public function set_date_format( sequence format = DEFAULT_DATE_FORMAT )`

Sets the datef format string.

**Parameters**

- **`format`** - the format for the date string, `DEFAULT_DATE_FORMAT` is `"%Y/%m/%d %H:%M:%S"`

**Returns**

The previously set date format.

### set_log_color

`include mvc/logger.e`  
`public function set_log_color( integer color = DEFAULT_LOG_COLOR )`

Sets the normal output color.

**Parameters**

- **`color`** - the color for normal output, `DEFAULT_LOG_COLOR` is `WHITE`

**Returns**

The previously set normal output color.

### set_log_level

`include mvc/logger.e`  
`public function set_log_level( integer level = DEFAULT_LOG_LEVEL )`

**Parameters**

- **`level`** - the log level to set, `DEFAULT_LOG_LEVEL` is `LOG_INFO`

**Returns**

The previously set log level.

### set_log_output

`include mvc/logger.e`  
`public function set_log_output( object file = DEFAULT_LOG_OUTPUT )`

Set log output to one or more file handle or file name.

**Parameters**

- **`file`** - one or more file names or handles, `DEFAULT_LOG_OUTPUT` is `STDERR`

**Returns**

The previous log output values.

### set_stack_color

`include mvc/logger.e`  
`public function set_stack_color( integer color = DEFAULT_STACK_COLOR )`

Sets the stack trace color.

**Parameters**

- **`color`** - the color for the stack trace, `DEFAULT_STACK_COLOR` is `MAGENTA`

**Returns**

The previously set stack trace color.

### set_stack_indent

`include mvc/logger.e`  
`public function set_stack_indent( integer indent = DEFAULT_STACK_INDENT )`

Turns on call stack indenting. When printing the call stack, the left margin will be indented with one space for each level deep in the stack.

This may or may not provide useful indentation depending on your application, since levels in between may or may not be displayed.

**Parameters**

- **`indent`** - enable call stack indent, `DEFAULT_STACK_INDENT` is `FALSE`

**Returns**

The previous indent value.


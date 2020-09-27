# String Buffer

## Overview

The string buffer library is used to read and write strings efficiently directly in memory.

### Basic Usage

You can use the string buffer as a simple append-only string builder.

    atom strbuf = strbuf_init()

    strbuf_append( strbuf, "It was the best of times,\n" )
    strbuf_append( strbuf, "it was the worst of times,\n" )
    strbuf_append( strbuf, "it was the age of wisdom,\n" )
    strbuf_append( strbuf, "it was the age of foolishness,\n" )
    strbuf_append( strbuf, "it was the epoch of belief,\n" )
    strbuf_append( strbuf, "it was the epoch of incredulity,\n" )

    sequence text = strbuf_value( strbuf )

    strbuf_free( strbuf )

### Advanced Usage

You can use the string buffer like a random-access text file.

    atom strbuf = strbuf_init()

    strbuf_write( strbuf, "ABCDEF" )
    strbuf_write( strbuf, "GHIJKL" )
    strbuf_write( strbuf, "MNOPQR" )

    strbuf_seek( strbuf, 9 )

    sequence str = strbuf_read( strbuf, 6 )
    -- str is "JKLMNO"

    strbuf_free( strbuf )

## Functions

- [`strbuf_init`](#strbuf_init)
- [`strbuf_free`](#strbuf_free)
- [`strbuf_resize`](#strbuf_resize)
- [`strbuf_read`](#strbuf_read)
- [`strbuf_write`](#strbuf_write)
- [`strbuf_append`](#strbuf_append)
- [`strbuf_clear`](#strbuf_clear)
- [`strbuf_reset`](#strbuf_reset)
- [`strbuf_length`](#strbuf_length)
- [`strbuf_size`](#strbuf_size)
- [`strbuf_seek`](#strbuf_seek)
- [`strbuf_where`](#strbuf_where)
- [`strbuf_value`](#strbuf_value)

## Constants

- [`STRBUF_READ_FUNC`](#STRBUF_READ_FUNC)
- [`STRBUF_WRITE_FUNC`](#STRBUF_WRITE_FUNC)

### strbuf_init

`include mvc/strbuf.e`  
`public function strbuf_init( atom init_size = 0, integer cleanup = FALSE )`

Allocate a new string buffer.

**Parameters**

- **`init_size`** - the initial size of the buffer.
- **`cleanup`** - set this to `TRUE` to automatically free the buffer when it goes out of scope.

**Returns**

A memory handle to the new string buffer.

### strbuf_free

`include mvc/strbuf.e`  
`public procedure strbuf_free( atom strbuf )`

Free an existing string buffer.

**Parameters**

- **`strbuf`** - an existing string buffer handle.

### strbuf_resize

`include mvc/strbuf.e`  
`public function strbuf_resize( atom strbuf, atom size )`

Resize the string buffer to accommodate the new size. You generally don't need to call this as the buffer will grow dynamically.

**Parameters**

- **`strbuf`** - an existing string buffer handle.
- **`size`** - the new size for the buffer.

**Returns**

Returns the new internal buffer address. This is used for internal purposes only.

### strbuf_read

`include mvc/strbuf.e`  
`public function strbuf_read( atom strbuf, integer len = 0, atom buffer = NULL )`

Read from the current position and advance the position by the length read.

**Parameters**

- **`strbuf`** - an existing string buffer handle.
- **`len`** - the optional number of bytes to be read.
- **`buffer`** - an external memory buffer address.

**Returns**

* If **len** is zero, the rest of the string buffer will be read entirely.
* If **len** is less than the available buffer, only the remaining bytes will be read.
* If **buffer** is `NULL`, this will return a sequence of the requested bytes.
* If **buffer** is not `NULL`, this will copy the requested bytes into the buffer and return the number of bytes copied.

### strbuf_write

`include mvc/strbuf.e`  
`public function strbuf_write( atom strbuf, object data, integer len = length(data) )`

Write from the current position and advance the position by the length written.

**Parameters**

- **`strbuf`** - an existing string buffer handle.
- **`data`** - sequence of bytes, or an external memory buffer address.
- **`len`** - the optional number of bytes to be read.

**Returns**

* If **data** is a sequence, poke the sequence of bytes into memory.
* If **data** is an atom, copy **len** bytes from that memory address.

### strbuf_append

`include mvc/strbuf.e`  
`public procedure strbuf_append( atom strbuf, sequence string )`

Append data to the end of the buffer *without* advancing the position.

**Parameters**

- **`strbuf`** - an existing string buffer handle.
- **`string`** - the string to append to the buffer.

### strbuf_clear

`include mvc/strbuf.e`  
`public procedure strbuf_clear( atom strbuf )`

Clear the string buffer and reset the position.

**Parameters**

- **`strbuf`** - an existing string buffer handle.

### strbuf_reset

`include mvc/strbuf.e`  
`public procedure strbuf_reset( atom strbuf )`

Reset the position of the buffer (but don't clear it).

**Parameters**

- **`strbuf`** - an existing string buffer handle.

### strbuf_length

`include mvc/strbuf.e`  
`public function strbuf_length( atom strbuf )`

Get the current length of the string in the buffer.

**Parameters**

- **`strbuf`** - an existing string buffer handle.

**Returns**

Returns the current length of the string in the buffer.

### strbuf_size

`include mvc/strbuf.e`  
`public function strbuf_size( atom strbuf )`

Gets the entire allocated size of the buffer.

**Parameters**

- **`strbuf`** - an existing string buffer handle.

**Returns**

Returns the entire allocated size of the buffer.

### strbuf_seek

`include mvc/strbuf.e`  
`public function strbuf_seek( atom strbuf, atom offset )`

Move the current position of the buffer.

**Parameters**

- **`strbuf`** - an existing string buffer handle.
- **`offset`** - the requested new position for the buffer.

**Returns**

Returns `TRUE` if the buffer position was moved to **offset**.

### strbuf_where

`include mvc/strbuf.e`  
`public function strbuf_where( atom strbuf )`

Gets the current read/write position of the buffer.

**Parameters**

- **`strbuf`** - an existing string buffer handle.

**Returns**

Return the current read/write position of the buffer.

### strbuf_value

`include mvc/strbuf.e`  
`public function strbuf_value( atom strbuf )`

Gets the entire value of the buffer, ignoring the position.

**Parameters**

- **`strbuf`** - an existing string buffer handle.

**Returns**

Returns the entire value of the buffer.

### STRBUF_READ_FUNC

This is a special function address for reading data with libcurl. A read function is used when you want to provide data *to* libcurl. Set the `CURLOPT_READFUNCTION` to `STRBUF_READ_FUNC` and then set `CURLOPT_READDATA` to the address of your string buffer.

**Notes**

Don't forget to reset the buffer position with [strbuf_reset](#strbuf_reset) if you've already used [strbuf_write](#strbuf_write) to put data into the buffer and you want libcurl to read it again from the beginning. You can also use [strbuf_append](#strbuf_append) to write data without advancing the position.

    include curl/easy.e
    include mvc/strbuf.e

    atom strbuf = strbuf_init()
    strbuf_append( strbuf, "This is the string data I want libcurl to use." )

    curl_easy_setopt( curl, CURLOPT_READFUNCTION, STRBUF_READ_FUNC )
    curl_easy_setopt( curl, CURLOPT_READDATA, strbuf )

    strbuf_free( strbuf )

### STRBUF_WRITE_FUNC

A special function for writing data with libcurl. A write function is used when you want to receive data *from* libcurl. Set the `CURLOPT_WRITEFUNCTION` to `STRBUF_WRITE_FUNC` and then set `CURLOPT_WRITEDATA` to the address of your string buffer.

    include curl/easy.e
    include mvc/strbuf.e

    atom strbuf = strbuf_init()

    curl_easy_setopt( curl, CURLOPT_WRITEFUNCTION, STRBUF_WRITE_FUNC )
    curl_easy_setopt( curl, CURLOPT_WRITEDATA, strbuf )

    sequence data = strbuf_value( strbuf )

    strbuf_free( strbuf )

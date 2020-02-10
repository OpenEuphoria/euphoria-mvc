# Headers

## Header routines

### header

`include mvc/headers.e`  
`public procedure header( sequence name, object value, object data = {} )`

Shorthand for `set_header()`

### clear_headers

`include mvc/headers.e`  
`public procedure clear_headers()`

Clear all headers in the application.

### get_header

`include mvc/headers.e`  
`public function get_header( sequence name, sequence default = "" )`

Get a header value.

**Parameters**

- **`name`** - the name of the header
- **`default`** - the default value to return if **`name`** is not set

### set_header

`include mvc/headers.e`  
`public procedure set_header( sequence name, object value, object data = {} )`

You can set multiple headers by setting the value as sequence of one or more strings. This is used internally by [set_cookie()](COOKIE.md#set_cookie).

**Parameters**

- **`name`** - the name of the header
- **`value`** - the value of the header
- **`data`** - optional data, which treats **`value`** like a `printf()` statement

### unset_header

`include mvc/headers.e`  
`public procedure unset_header( sequence header_name )`

Unset a single header.


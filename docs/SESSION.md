# Sessions

## Concepts

Sessions are server-side snippits of data referenced by a single "session_id" cookie sent to the user.

This is especially helpful for storing things like the current user, or for caching data between requests.

**Note:** you must call **`session_start()`** before trying to get or set session variables.

## Session routines

### get_session

`include mvc/session.e`  
`public function get_session( sequence name, object default = 0 )`

Returns the value of a given session variable, or the specified default value.

**Parameters**

- **`name`** - the name of the session variable
- **default`** - the default value to return if `name` is not found

### set_session

`include mvc/session.e`  
`public procedure set_session( sequence name, object value )`

Sets the value of a given session variable.

**Parameters**

- **`name`** - the name of the session variable
- **`value`** - the value to set for the variable

### session_start

`include mvc/session.e`  
`public function session_start()`

Loads the current session from disk or starts a new session if none exists.


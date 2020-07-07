# Utilities

## Utility routines

* [`getenv`](#getenv)

### getenv

`include mvc/utils.e`  
`public function getenv( sequence name, integer as_type = AS_STRING, object default = as_default(as_type) )`

An improved version of the built-in **`getenv()`**. You can automatically return a number instead of a string.

**Parameters**

- **`name`** - the name of the environment variables
- **`as_type`** - the requested type to return:
  - **`AS_STRING`** - returns the value as a string, default is `""`
  - **`AS_INTEGER`** - returns the value as an integer, default is `0`
  - **`AS_NUMBER`** - returns the value as any type of number, default is `0.0`
- **`default`** - the default value to return


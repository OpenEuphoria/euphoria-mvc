# Hooks

## About hooks

Hooks are used to tie into various parts of the application lifecycle.

## Available hooks

- `HOOK_APP_START` - while the app is starting, only called once
  - `HOOK_REQUEST_START` - while a request is starting, called for each request
    - `HOOK_RESPONSE_START` - before a route handler runs, called for each request
    - `HOOK_RESPONSE_END` - after a route handler completes, called for each request
    - `HOOK_HEADERS_START` - before headers are formatted to be sent, called for each request
    - `HOOK_HEADERS_END` - after headers have been sent, called for each request
  - `HOOK_REQUEST_END` - after a request completes, called for each request
- `HOOK_APP_END` - before the app exits, only called once

## Hook routines

* [`get_hook_name`](#get_hook_name)
* [`insert_hook`](#insert_hook)
* [`new_hook_type`](#new_hook_type)
* [`run_hooks`](#run_hooks)

### new_hook_type

`include mvc/hooks.e`  
`public function new_hook_type( sequence name )`

Add new hook type.

**Parameters**

* **`name`** - the name of the hook. This should be the default routine name.

**Returns**

A new hook ID, an `integer` that should be used with `insert_hook`.

**Remarks**

You shouldn't really need to be registering new hooks. This is mostly used internally by the server and application routines.

### get_hook_name

`include mvc/hooks.e`  
`public function get_hook_name( integer hook_type )`

Return a hook name.

**Parameters**

* **`hook_type`** - the hook ID returned from `new_hook_type`

**Returns**

A `sequence`, the name of the hook.

### insert_hook

`include mvc/hooks.e`  
`public procedure insert_hook( integer hook_type, sequence func_name = get_hook_name(hook_type), integer func_id = routine_id(func_name) )`

Insert a new hook.

**Parameters**

* **`hook_type`** - the hook ID returned from `new_hook_type`.
* **`func_name`** - the name of the routine to be called.
* **`func_id`** - the ID of the routine to be called.

### run_hooks

`include mvc/hooks.e`  
`public function run_hooks( integer hook_type )`

Run a list of hooks.

**Parameters**

* **`hook_type`** - the ID of the hooks to be run.

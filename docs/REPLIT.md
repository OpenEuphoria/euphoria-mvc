# Repl.it Database

If you're running Euphoria MVC on [Repl.it](https://repl.it) you can take advantage of their built-in key/value [database](https://docs.repl.it/misc/database).

This is a very simply wrapper for their API using the libcurl wrapper provided in this framework.

## Variables

- [`REPLIT_DB_URL`](#REPLIT_DB_URL)
- [`REPLIT_DB_VERBOSE`](#REPLIT_DB_VERBOSE)

### REPLIT_DB_URL

This is the URL to the database API. This value is required so if you are not in a Repl.it environment `REPLIT_DB_URL` will be empty and including `db/replit.e` will cause your application to crash on startup.

### REPLIT_DB_VERBOSE

Set this to `TRUE` to enable verbose output during the libcurl calls made by the functions below. This is helpful for debugging to see what's going on under the hood. You can also pass `-D REPLIT_DB_VERBOSE` on the command line.

## Functions

- [`replit_db_set`](#replit_db_set)
- [`replit_db_get`](#replit_db_get)
- [`replit_db_del`](#replit_db_del)
- [`replit_db_list`](#replit_db_list)

### replit_db_set

`include db/replit.e`  
`public function replit_db_set( sequence key, sequence value )`

Store a key/value pair in the database.

**Example**

    integer result = replit_db_set( "<key>", "<value>" )

### replit_db_get

`include db/replit.e`  
`public function replit_db_get( sequence key )`

Get a value from the database with the given key.

**Example**

    object value = replit_db_get( "<key>" )
    if integer( value ) then
        -- something went wrong
    end if

### replit_db_del

`include db/replit.e`  
`public function replit_db_del( sequence key )`

Delete a value from the database with the given key.

**Example**

    integer result = replit_db_del( "<key>" )
    if value != CURLE_OK then
    	-- something went wrong
    end if

### replit_db_list

`include db/replit.e`  
`public function replit_db_list( sequence prefix )`

Return a list of keys matching the given prefix.

**Example**

    object result = replit_db_list( "<prefix>" )
    if integer( result ) then
        -- something went wrong
    end if

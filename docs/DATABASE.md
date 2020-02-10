# Database

## Concepts

This database library provides a light abstraction layer over any number of third-party database libraries. It doesn't actually perform any database operations itself. You must include *at least one* database plugin library for this to library to work correctly.

## Example

    include mvc/database.e
    include mvc/db_mysql.e
    
    atom conn = db_connect( "mysql://user:password@localhost/mydb" )
    atom result = db_query( "SELECT * FROM mytable" )
    
    object row = db_fetch( result )
    while sequence( row ) do
        row = db_fetch( result )
    end while
    
    db_free( result )
    db_disconnect()

## Global connection

You'll notice in the above example that `conn` isn't actually reused by any of the other database routines. That's because each call to `db_connect()` will update the *global connection state* for your application and, as long as you only need one connection, you don't need to continue passing `conn` around to other routines. You can also use `db_select()` to update the global connection state at any time, or pass `conn` manually as the last parameter of each database routine.

## Database protocols

Each plugin must register a unique "protocol" for use in the `db_connect()` connection URL. To remain consistent, this should be the same string as found in the plugin file name, e.g. `db_mysql.e` registers `mysql` as its protocol.

## Database libraries

Include at least one of these libraries to in order to connect to a database. Currently only the MySQL is implemented. Third-party wrappers are stored in the `db/` directory and shared libraries (.so, .dll) should be placed in the `bin/` directory whenever necessary (usually just on Windows).

- [ ] `mvc/db_eusql.e`
- [x] `mvc/db_mysql.e`
- [ ] `mvc/db_postgres.e`
- [ ] `mvc/db_sqlite.e`

## Database routines

### add_protocol

`include mvc/database.e`  
`public function add_protocol( sequence proto )`

Adds a new protocol handler. Used internally by database libraries.

**Parameters**

- **`proto`** - the protocol name to register

**Returns**

The unique ID of the registered protocol.

### add_handler

`include mvc/database.e`  
`public procedure add_handler( integer proto_id, integer func_id, integer rtn_id )`

Adds a new function handler. Used internally by database libraries.

**Parameters**

- **`proto_id`** - the protocol ID registered by `add_protocol()`
- **`func_id`** - the database function ID
  - `DB_CONNECT`
  - `DB_DISCONNECT`
  - `DB_TABLE_EXISTS`
  - `DB_QUERY`
  - `DB_FETCH`
  - `DB_FREE`
  - `DB_ERROR`
  - `DB_INSERT_ID`
  - `DB_AFFECTED_ROWS`
- **`rtn_id`** - the routine ID of the function for this protocol and ID

### db_affected_rows

`include mvc/database.e`  
`public function db_affected_rows( atom conn = current_conn )`

Get the number of rows affected by the last query.

**Parameters**

- **`conn`** the database connection handle

**Returns**

Depends on the underlying database. Should return the number of rows affected by the last query.

### db_connect

`include mvc/database.e`  
`public function db_connect( sequence url, integer timeout = DEFAULT_TIMEOUT )`

Connect to a database.

**Parameters**

- **`url`** - a connection URL in the format `protocol://username:password@hostname/database`
- **`timeout`** - the connection timeout in milliseconds (default is `5000`)

**Returns**

The connection handle, or `NULL` if a connection could not be made. Also stores this as the global connection state.

### db_disconnect

`include mvc/database.e`  
`public procedure db_disconnect( atom conn = current_conn )`

Disconnect from a database.

**Parameters**

- **`conn`** - the connection handle to disconnect

### db_error

`include mvc/database.e`  
`public function db_error( atom conn = current_conn )`

Returns the last error from the database.

**Parameters**

- __none__

**Returns**

Depends on the underlying database. Should return a sequence containing the description of the last error.

### db_fetch

`include mvc/database.e`  
`public function db_fetch( atom result, atom conn = current_conn )`

Fetch the next row from the query result.

**Parameters**

- **`result`** - the query result handle
- **`conn`** the database connection handle

**Returns**

Depends on the underlying database. Should return a sequence of row fields or `NULL` when there are no more rows in the result.

### db_free

`include mvc/database.e`  
`public procedure db_free( atom result, atom conn = current_conn )`

Free the query results.

**Parameters**

- **`result`** - the query result handle
- **`conn`** the database connection handle

### db_insert_id

`include mvc/database.e`  
`public function db_insert_id( atom conn = current_conn )`

Get the last inserted row ID value.

**Parameters**

- **`conn`** the database connection handle

**Returns**

Depends on the underlying database. Should return the last inserted row ID value.

### db_query

`include mvc/database.e`  
`public function db_query( sequence query, object params = {}, atom conn = current_conn )`

Execute a database query.

**Parameters**

- **`query`** - the databse query to execute
- **`params`** - parameters to be used in the query
- **`conn`** - the database connection handle

**Returns**

Depends on the underlying database. Usually returns a result handle for `SELECT` queries to be used with `db_fetch()`, or the number of affected rows for `INSERT`, `UPDATE`, and `DELETE` queries. Will return `-1` if there was an internal error.

### db_select

`include mvc/database.e`  
`public function db_select( atom conn )`

Select another already connected database.

**Parameters**

- **`conn`** - the connection handle to select as the global connection

**Returns**

Returns `TRUE` if the database connection handle was changed.


# Models

## Concepts

Models provide an abstract and code-oriented way to access your application data. First you **define** a model by describing its fields and data types. Then you can **create**, **fetch**, **store**, and **delete** models without having to build SQL queries.

## Example

To define a model, you provide the underlying table name and a list of fields and data types.

    include mvc/model.e
    
    constant USER_MODEL = model:define( "users", {
        { "id",         INTEGER },
        { "name",       TEXT },
        { "email",      TEXT },
        { "last_login", DATETIME }
    })

Create the table for this model (optional).

    model:init( USERS_MODEL )

Then you can create a new object based on that model and store it in the database.

    object user = model:new( USER_MODEL )
    model:set( user, "name", "John Smith" )
    model:set( user, "email", "john.smith@example.com" )
    model:set( user, "last_login", datetime:now() )
    model:store( user )

You can fetch individual models from the database.

    object user = model:fetch_one( USER_MODEL, "id = 1" )

Or you can fetch a collection of models.

    sequence users = model:fetch_all( USER_MODEL, "name LIKE 'John'" )

And you can also delete models.

    model:delete( user )

## Model routines

### count_of

`include mvc/model.e`  
`public function count_of( integer model_type, sequence query = "", object params = {} )`

Get the number of items matching the query.

**Parameters**

- **`model_type`** - the model ID created by `define()`
- **`query`** - the query, or blank to count all items
- **`params`** - parameters passed into the query

**Returns**

The number of items matching the query.

### define

`include mvc/model.e`  
`public function define( sequence model_name, sequence field_list )`

Define a new model.

**Parameters**

- **`model_name`** - the name of the model, specifically the underlying table name
- **`field_list`** - a list of one or more fields, each containing `{ "name", data_type }`

**Returns**

The new model ID for use in other model routines.

### delete

`include mvc/model.e`  
`public function delete( object model )`

Delete a model from the database.

**Parameters**

- **`model`** - the model object

**Returns**

Returns `TRUE` if the model was deleted or `FALSE` if something went wrong.

### fetch_all

`include mvc/model.e`  
`public function fetch_all( integer model_type, sequence query = "", object params = {} )`

Fetch all models matching the query.

**Parameters**

- **`model_type`** - the model ID created by `define()`
- **`query`** - the query for a specific model
- **`params`** - parameters passed into the query

**Returns**

A sequence containing all the models matching the query, or an empty sequence if no results were found.

### fetch_one

`include mvc/model.e`  
`public function fetch_one( integer model_type, sequence query, object params = {} )`

Fetch a single model matching the query.

**Parameters**

- **`model_type`** - the model ID created by `define()`
- **`query`** - the query for a specific model
- **`params`** - parameters passed into the query

**Returns**

A single model if the query returned one result, or `NULL` if no results were found.

## get

`include mvc/model.e`  
`public function get( object model, sequence name, object default = 0 )`

Gets a value from the model.

**Parameters**

- **`model`** - the model object
- **`name`** - the name of the value
- **`default`** - the value to return if `name` is not set

**Returns**

Returns the value for `name` stored in the model, or the `default` value.

### init

`include mvc/model.e`  
`public function init( integer model_type )`

Create the table for the given model.

**Parameters**

- **`model_type`** - the model ID created by `define()`

**Returns**

Returns `TRUE` if the table was created sucessfully.

### new

`include mvc/model.e`  
`public function new( integer model_type, sequence params = {} )`

Create a new object for the given model. The object will not be created in the database until you call `store()`

**Parameters**

- **`model_type`** - the model ID created by `define()`
- **`params`** - an optional set of key/value pairs to store in the object

**Returns**

The new model ID.

## set

`include mvc/model.e`  
`public procedure set( object model, sequence name, object value )`

Set a value in the model.

**Parameters**

- **`model`** - the model object
- **`name`** - the name of the value
- **`value`** - the value to set

### store

`include mvc/model.e`  
`public function store( object model )`

Stores a model in the database. It will be inserted if it does not exist, or updated if it does exist.

**Parameters**

- **`model`** - the model object

**Returns**

Returns the ID value of the model on success, or `NULL` if something went wrong.

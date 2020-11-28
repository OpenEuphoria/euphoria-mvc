# Configs

## Concepts

Configuration files are stored in INI style format. Traditionally, `.cfg` or `.ini` should be used as the file extension.

**Example**

    ; this is the first category
    [category]
    key1 = 12345
    key2 = "string"
    
    ; this is the second category
    [category two]
    key1 = 99999
    key2 = 54321
    
    ; this is an extra comment

**State**

Currently, the configuration is loaded into memory and can be updated and then written back to a file. Only one configuration "state" exists, as this is expected to be used for your whole application.

**Categories**

Each line contained in brackets `[]` designates a category in the config file. If there is no category sepcified, or if key/value pairs exist before a given category, the category `"default"` is used instead.

**Keys/Values**

Keys can be expressed using strings with dot notation by default (or any other separator if necessary) or as a sequence of strings. The first part of the string preceding the separate is the category, and the remaining part is the key name.

For example, these configurations are the same:

    -- use default "." separator
    set_config( "database.name", "mydatabase" )

    -- use "/" as separator
    set_config( "database/name", "mydatabase", "/" )

    -- use a sequence of strings
    set_config( {"database","name"}, "mydatabase" )

This would set the key/value pair to `name="mydatabase"` in the `[database]` category.

    [database]
    name="mydatabase"

**Comments**

Configuration files support comments. Any line that starts with `;` is considered a comment. Comments are associated with each category heading or key/value pair, or with the end of the file, and will be written back out when saving. Comments at the end of the file are referenced with an empty key `""` or `{""}`.

Building on the example above:

    set_comment( "database", "\nThe database settings\n\n" )
    set_comment( "database.name", "name of the database" )
    set_comment( {""}, "A comment at the end of the file" )

This would add the following comments to the config file:

    ;
    ; The database settings
    ;
    [database]
    ; name of the database
    name="mydatabase"
    
    ; A comment at the end of the file

## Config routines

**Saving/Loading**

* [`clear_config`](#clear_config)
* [`config_saved`](#config_saved)
* [`load_config`](#load_config)
* [`save_config`](#save_config)

**Set/Get Comments**

* [`get_comment`](#get_comment)
* [`has_comment`](#has_comment)
* [`set_comment`](#set_comment)
* [`unset_comment`](#unset_comment)

**Set/Get Values**

* [`get_config`](#get_config)
* [`has_config`](#has_config)
* [`set_config`](#set_config)
* [`unset_config`](#unset_config)

### clear_config

`include mvc/config.e`  
`public procedure clear_config()`

Clears the current configuration state.

**Parameters**

- _none_

**Remarks**

This will issue a warning if the configuration had not been saved. Remember to check the state of the configuration with [`config_saved`](#config_saved).

### config_saved

`include mvc/config.e`  
`public procedure config_saved()`

Returns `TRUE` of the configuration is currently saved, or `FALSE` otherwise.

**Parameters**

- _none_

### get_comment

`include mvc/config.e`  
`public function get_comment( sequence keys, integer one_string=FALSE, object sep=DEFAULT_SEPARATOR )`

Reads a comment from the current configuration.

**Parameters**

- **`keys`** - the category and key to read from the configuration
- **`one_string`**
  - if `TRUE`, return a string of EOL-separated comments
  - if `FALSE`, return a sequence of separate comment lines
- **`sep`** - the separator to use when splitting the keys string

**Remarks**

Comments at the end of the file are referenced with an empty key `""` or `{""}`.

### get_config

`include mvc/config.e`  
`public function get_config( sequence keys, object default=DEFAULT_VALUE, object sep=DEFAULT_SEPARATOR )`

Reads a key value from the current configuration.

**Parameters**

- **`keys`** - the category and key to read from the configuration
- **`default`** - the default value to return if the key is not found
- **`sep`** - the separator to use when splitting the keys string

### has_comment

`include mvc/config.e`  
`public function has_comment( sequence keys, object sep=DEFAULT_SEPARATOR )`

Returns `TRUE` if a comment is currently set for the keys.

**Parameters**

- **`keys`** - the category and key to read from the configuration
- **`sep`** - the separator to use when splitting the keys string

**Remarks**

Comments at the end of the file are referenced with an empty key `""` or `{""}`.

### has_config

`include mvc/config.e`  
`public function has_config( sequence keys, object sep=DEFAULT_SEPARATOR )`

Returns `TRUE` if a value is currently set for the keys.

**Parameters**

- **`keys`** - the category and key to read from the configuration
- **`sep`** - the separator to use when splitting the keys string

### load_config

`include mvc/config.e`  
`public function load_config( object filename )`

Loads the configuration from a file and returns TRUE on success or FALSE on failure.

**Parameters**

- **`filename`** - the name of a file, or an already open file number

### save_config

`include mvc/config.e`  
`public function save_config( object filename, integer mark_saved=TRUE, integer write_empty=FALSE )`

Saves the configuration to a file. Returns TRUE on success or FALSE on failure.

**Parameters**

- **`filename`** - the name of a file, or an already open file number
- **`mark_saved`** - mark the configuration as saved after writing the file
- **`write_empty`** - write headings for categories that have no keys

### set_comment

`include mvc/config.e`  
`public procedure set_comment( sequence keys, sequence comment, object sep=DEFAULT_SEPARATOR )`

Stores a comment into the current configuration.

**Note:** changes are not saved until you call [`save_config`](#save_config).

**Parameters**

- **`keys`** - the category and key to set in the configuration
- **`comment`** - the comment to set in the configuration
- **`sep`** - the separator to use when splitting the keys string

**Remarks**

Comments at the end of the file are referenced with an empty key `""` or `{""}`.

### set_config

`include mvc/config.e`  
`public procedure set_config( sequence keys, object value, object sep=DEFAULT_SEPARATOR )`

Stores a key value into the current configuration.

**Note:** changes are not saved until you call [`save_config`](#save_config).

**Parameters**

- **`keys`** - the category and key to set in the configuration
- **`value`** - the value to set in the configuration
- **`sep`** - the separator to use when splitting the keys string

### unset_comment

`include mvc/config.e`  
`public procedure unset_comment( sequence keys, object sep=DEFAULT_SEPARATOR )`

Removes a comment from the configuration.

**Note:** changes are not saved until you call [`save_config`](#save_config).

**Parameters**

- **`keys`** - the category and key to set in the configuration
- **`sep`** - the separator to use when splitting the keys string

**Remarks**

Comments at the end of the file are referenced with an empty key `""` or `{""}`.

### unset_config

`include mvc/config.e`  
`public procedure unset_config( sequence keys, object sep=DEFAULT_SEPARATOR )`

Removes a key value from the configuration.

**Note:** changes are not saved until you call [`save_config`](#save_config).

**Parameters**

- **`keys`** - the category and key to set in the configuration
- **`sep`** - the separator to use when splitting the keys string


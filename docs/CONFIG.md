# Config

## Concepts

Config files are stored in INI format.

    [category]
    key1 = 12345
    key2 = "string"

    [category two]
    key1 = 99999
    key2 = 54321

Currently, the configuration is loaded into memory and can be updated and then written back.

Only one configuration "state" exists, as this is expected to be used for your whole application.

If necessary, this can be ammeded to provide multi-config operation and maintain compatability.

## Config routines

### load_config

`include mvc/config.e`  
`public function load_config( object filename )`

Loads the configuration from a file and returns TRUE on success or FALSE on failure.

**Parameters**

- **`filename`** - the name of a file, or an already open file number

### save_config

`include mvc/config.e`  
`public function save_config( object filename )`

Saves the configuration to a file. Returns TRUE on success or FALSE on failure.

**Parameters**

- **`filename`** - the name of a file, or an already open file number

### get_config

`include mvc/config.e`  
`public function get_config( sequence category, sequence key, object default = "" )`

Reads a key value from the current configuration.

**Parameters**

- **`category`** - the category heading, e.g. "[category]"
- **`key`** - the key to read from the configuration
- **`default`** - the default value to return if the key is not found

### set_config

`include mvc/config.e`  
`public function set_config( sequence category, sequence key, object value )`

Stores a key value into the current configuration.

**Note:** changes are not saved until you call `save_config()`.

**Parameters**

- **`category`** - the category heading, e.g. "[category]"
- **`key`** - the key to set in the configuration
- **`value`** - the value to set in the configuration

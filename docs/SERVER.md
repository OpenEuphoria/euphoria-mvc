# Server

## Caution

This is a built-in HTTP server for *development* purposes only. It is not production ready and it may never be.

That being said, it does do just enough to bootstrap Euphoria MVC application development out of the box.

The server makes heavy use of the [logger](LOGGER.md) routines and will show a lot of output if `LOG_TRACE` is enabled.

## Example

    include mvc/app.e
    include mvc/server.e
    include mvc/template.e
    include std/map.e

    function index( object request )

        object response = map:new()
        map:put( response, "title", "My First App" )
        map:put( response, "message", "Hello, world!" )

        return render_template( "index.html", response )
    end function
    app:route( "/", "index" )

    server:start()

## Server routines

### start

`include mvc/server.e`  
`public procedure start( sequence listen_addr = DEFAULT_ADDR, integer listen_port = DEFAULT_PORT )`

Sets up the HTTP server and starts listening for incoming connections.

**Parameters**

- **`listen_addr`** - the address to listen on, `DEFAULT_ADDR` is `"localhost"`
- **`listen_port`** - the TCP port to listen on, `DEFAULT_PORT` is `5000`

### stop

`include mvc/server.e`  
`public procedure stop()`

Stop the server after the next request is completed. You can also press `Ctrl+C` from the console to stop the server.

**Parameters**

- __none__


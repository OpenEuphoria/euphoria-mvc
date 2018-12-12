# Application

## Example

    #!/usr/local/bin/eui

    include mvc/app.e
    include mvc/template.e
    include std/map.e

    function index( object request )

        map response = map:new()
        map:put( response, "title", "Hello, world!" )

        return render_template( "index.html", response )
    end function
    app:route( "/index" )

    app:run()

## Concepts

Thera are a few concepts you'll need to understand in order to build your application correctly.

- I'd recommend that you be familiar with basic HTTP concepts, like GET and POST and status codes. This will be helpful later.
- Key concepts are indicated below in **bold**. Keep these in mind, as your application will be built around these concepts.

### Framework

The **framework** is this project, Euphoria MVC. I'll refer to it simply as "the framework" for the sake of brevity.

### Route

A **route** is a static or dynamic path requested by the user's browser and is passed to a **handler** function by the framework.

###  Handler

A **handler** is a function that accepts a **request** object, performs some logic, and returns the content to be returned to the browser.

### Request

A **request** is a map object that holds the incoming data from the web server, which includes:

- environment variables
- route variables
- GET query data
- POST form data

### Namespace

The framework defines each module with its own namespace. In the case of application routing, using the **`app:`** namespace adds some clarity your code that might otherwise look ambiguous.

### Response

An optional map object that holds the outgoing data for **`render_template()`**. Templates can then access these variables for displaying data.

### Templates

Templates are pre-defined text blocks that contain some basic logic for formatting your **response** data. See [TEMPLATE.md](TEMPLATE.md) for details.

## Defining routes

Routes are static or dynamic paths requested by the browser as part of a URL. In `https://github.com/OpenEuphoria/Euphoria`, the path is `/OpenEuphoria/Euphoria`.

### Static routes

You can route a static path to your handler by just specifying the path. This is show in the example above as **`app:route( "/index" )`**.

### Dynamic routes

You can also route dynamic paths that will accept variables and pass them to your **handler** function.

If you wanted to handle the GitHub URL above, you could could specify the route as `/<username>/<project>`.

Then any URL matching that structure will parse out the **`username`** and **`project`** variables and pass them to your **handler** via its **request** object.

## Application routines

### getenv

`include mvc/app.e`__
`public function getenv( sequence name, integer as_type = AS_STRING, object default = as_default(as_type) )`

An improved version of the built-in **`getenv()`**. You can automatically return a number instead of a string.

**Parameters**

- **`name`** - the name of the environment variables
- **`as_type`** - the requested type to return:
  - **`AS_STRING`** - returns the value as a string, default is `""`
  - **`AS_INTEGER`** - returns the value as an integer, default is `0`
  - **`AS_NUMBER`** - returns the value as any type of number, default is `0.0`
- **`default`** - the default value to return

### header

`include mvc/app.e`__
`public procedure header( sequence name, object value, object data = {} )`

Sets an outgoing header value. Headers must be set before your **handler** function returns its **response** data.

- **`name`** - the name of the header
- **`value`** - the value of the header
- **`data`** - optional data, which treats **`value`** like a `printf()` statement

### redirect

`include mvc/app.e`__
`public function redirect( sequence url, integer code = 302 )`

Returns an HTTP redirect code to send the browser to the provided URL. Also puts a link on the page in case the redirect does not work. We recommend using **`url_for()`** for this.

- **`url`** - the url to send to the browser, this can be relative
- **`code`** - the HTTP response code to return to the browser

### route

`include mvc/app.e`  
`public procedure route( sequence path, sequence name = get_route_name(path), integer func_id = routine_id(name) )`

Assign a route path to a handler function. The **`route()`** function will automatically convert your **`path`** to a **`name`** and then lookup that function.

**Parameters**

- **`path`** - route path, see [Defining routes](#defining-routes) for details
- **`name`** - route name, used mostly by **`url_for()`**.
- **`func_id`** - the routine_id() of the handler function

### run

`include mvc/app.e`__
`public procedure run()`

Entry point for the application. Call this routine after you've set up all your routes.

**Parameters**

- __none__

### url_for

`include mvc/app.e`__
`public function url_for( sequence name, object response = {} )`

Builds a URL from a route using the optional response object.

**Parameters**

- **`name`** - the name of requested the route url
- **`response`** - the optional response object containing variables for the URL


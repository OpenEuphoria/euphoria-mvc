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

### Routes

A **route** is a static or dynamic path requested by the user's browser and is passed to a **handler** function by the framework.

###  Handlers

A **handler** is a function that accepts a **request** object, performs some logic, and returns the content to be rendered to the browser.

### Requests

A **request** is a map object that holds the incoming data from the web server, which includes:

- environment variables
- route variables
- GET query data
- POST form data

### Responses

An optional map object that holds the outgoing data for **`render_template()`**. Templates can then access these variables for displaying data.

### Templates

Templates are pre-defined text blocks that contain some basic logic for formatting your **response** data. See [TEMPLATE.md](TEMPLATE.md) for details.

## Defining routes

Routes are static or dynamic paths requested by the browser as part of a URL. In `https://github.com/OpenEuphoria/Euphoria`, the path is `/OpenEuphoria/Euphoria`.

### Static routes

You can route a static path to your handler by just specifying the path. This is show in the example above as **`app:route( "/index" )`**.

### Dynamic routes

You can also route dynamic paths that will accept variables and pass them to your **handler** function. If you wanted to handle the GitHub URL above, you could could specify the route as `/<username>/<project>`. Then any URL matching that structure will parse out the **username** and **project** variables and pass them to your **handler** via its **request** object. You can also require variables by a specific type using `<name:type>`. Valid types are `atom`, `integer`, `string`, and `object`, or an regular expression pattern.

### Default route

By default, any route that isn't found results in a 404 error. You can override this behavior by providing a default route. Simply set the path to the route with `"*"` and the handler will be called if, any only if, all other defined routes have been exhausted. You can still return an error page using `response_code()`.

### Error pages

The application provides a simple built-in HTML template for rendering HTTP response error codes (4xx). You can override this template on a *per-error code basis* by calling `set_error_page()`.

    <!DOCTYPE html>
    <html>
    <head>
      <title>{{ title }}</title>
    </head>
    <body>
      <h1>{{ title }}</h1>
      <p>{{ message }}</p>
      <hr>
      <p><em>{{ signature }}</em></p>
      </body>
    </html>

### Server signature

When running applications via CGI, the web server will pass its identity signature via the environment variable `SERVER_SIGNATURE`. You can override this value by calling `set_server_signature()` in your application.

## Application routines

* [`download_file`](#download_file)
* [`get_current_route`](#get_current_route)
* [`get_current_path`](#get_current_path)
* [`redirect`](#redirect)
* [`response_code`](#response_code)
* [`route`](#route)
* [`run`](#run)
* [`send_file`](#send_file)
* [`set_error_page`](#set_error_page)
* [`set_server_signature`](#set_server_signature)
* [`url_for`](#url_for)

### download_file

`include mvc/app.e`  
`public function download_file( sequence filename, sequence path=filename )`

Sends the appropriate MIME type for the file and tells the browser to force a download, and then returns the raw file data.

**Parameters**

- **`filename`** - the filename to send to the browser
- **`path`** - path to the file to send, if different from the filename

**Remarks**

Download file will send the `Content-Disposition` header telling the browser that the file is an _attachment_, prompting it to be downloaded. If you just want to send file data to the browser, use [`send_file`](#send_file) instead.

### get_current_route

`include mvc/app.e`  
`public function get_current_route()`

Return the current route name.

**Parameters**

- __none__

**Remarks**

The value returned from this function is only valid in a route handler. Do not call this function elsewhere.

### get_current_path

`include mvc/app.e`  
`public function get_current_path()`

Return the current route path.

**Parameters**

- __none__

**Remarks**

The value returned from this function is only valid in a route handler. Do not call this function elsewhere.

### redirect

`include mvc/app.e`  
`public function redirect( sequence url, integer code = 302 )`

Sets the appropriate HTTP header to trigger a redirect and returns the response page content to send the browser. Also puts a link on the page in case the redirect does not work. We recommend using **`url_for()`** for this.

**Parameters**

- **`url`** - the url to send to the browser, this can be relative
- **`code`** - the HTTP response code to return to the browser (default `302`)

### response_code

`include mvc/app.e`  
`public function response_code( integer code, sequence status = "", sequence message = "" )`

Sets the appropriate HTTP header for the response code and returns the response page content to send to the browser.

**Parameters**

- **`code`** - the HTTP status code to return (e.g. `404`)
- **`status`** - an optional status description (e.g. `"Not Found"`)
- **`message`** - an optional status message

**Remarks**

The default response code is `200 OK` for routes that exist and `404 Not Found` for routes that do not. This is used internally by [`redirect`](#redirect).

### route

`include mvc/app.e`  
`public procedure route( sequence path, sequence name = get_route_name(path), sequence methods = {"GET"}, integer func_id = routine_id(name) )`

Assign a route path to a handler function. The **`route()`** function will automatically convert your **`path`** to a **`name`** and then lookup that function.

**Parameters**

- **`path`** - route path, see [Defining routes](#defining-routes) for details
- **`name`** - route name, used to find your function and by * [`url_for`](#url_for)
- **`methods`** - valid methods for this route, default is just `"GET"`
- **`func_id`** - the routine_id() of the handler function

### run

`include mvc/app.e`  
`public procedure run()`

Entry point for the application when running in CGI. Call this routine after you've set up all your routes.

**Parameters**

- __none__

### send_file

`include mvc/app.e`  
`public function send_file( sequence path )`

Sends the appropriate MIME type for the file and returns the raw file data.

**Parameters**

- **`path`** - path to the file data to send

**Remarks**

This should be used when you need to return the content of a local file to the browser. This is useful for providing static files that are not served by your web server, or when using the development server provided in Euphoria MVC.

### set_error_page

`include mvc/app.e`  
`public procedure set_error_page( integer error_code, sequence error_page )`

Set the error page template defined for the response code. The `error_page` content will be sent whenever `error_code` is sent to [`response_code`](#response_code).

**Parameters**

- **`error_code`** - the HTTP error code for this page
- **`error_page`** - the HTML template to render for this page

**Remarks**

Your error_page content can be a template and will be rendered with the following variables:

- **`title`** - the title of the message is always the HTTP error code and status, e.g. `"404 Not Found"`
- **`status`** - the status message as defined by the error code, or provided via [`response_code`](#response_code), e.g. `"Not Found"`
- **`message`** - a brief message provided via [`response_code`](#response_code)
- **`signature`** - the server's signature, from the `SERVER_SIGNATURE` environment variable

### set_server_signature

`include mvc/app.e`  
`public procedure set_server_signature( sequence signature, object data = {} )`

Override the default `SERVER_SIGNATURE` environment variable.

**Parameters**

- **`signature`** - the new signature to display
- **`data`** - this data will be `printf`'d into the signature value

**Remarks**

This is used internally by the Euphoria MVC [SERVER.md](development server).

### url_for

`include mvc/app.e`  
`public function url_for( sequence name, object response = {} )`

Builds a URL from a route using the optional response object.

**Parameters**

- **`name`** - the name of requested the route url
- **`response`** - the optional response object containing variables for the URL

**Remarks**

The response object must contain matching keys for variables specified in your route. See [Defining routes](#defining-routes) for details.

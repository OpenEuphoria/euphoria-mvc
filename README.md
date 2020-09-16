# Euphoria MVC

**Euphoria MVC** is a model-view-controller application framework for [Euphoria](https://githubc.com/OpenEuphoria/Euphoria).

## Project status

This project is in the very early stages of development. Things can and will break or change until we reach a stable release.

## Features

### [Templates](docs/TEMPLATE.md)

Build your views in HTML and then render your data to the page.

### [Routing](docs/APP.md)

Automatically route static or dynamic paths to handler functions.

### [Database](docs/DATABASE.md)

Execute queries on any (well, most) database systems from one codebase.

### [Models](docs/MODEL.md)

Easily store and fetch Euphoria data via object-relation mapping (ORM).

### [Server](docs/SERVER.md)

Includes a built-in development server so you can get started right away.

### [JSON](docs/JSON.md)

Developing web applications requires speaking JSON.

### [CURL](docs/CURL.md)

Web applications may need to speak to the outside world.

### [Config](docs/CONFIG.md)

Load and store data in configuration (INI-like) files.

### [Cookies](docs/COOKIE.md)

Store snippits of data with your end users.

### [Sessions](docs/SESSION.md)

Store more data locally with minimal cookies.

### [Logger](docs/LOGGER.md)

Output runtime messages to the console in fancy colored text!

### [Mimetype](docs/MIMETYPE.md)

A quick-and-dirty table of MIME types based on file extension.

### [Utils](docs/UTILS.md)

Other miscellaneous functions.

## Getting Started

This example will use the built-in development server to quickly start your project. 

### Write your layout template

Save this as `templates/layout.html`.

    <!DOCTYPE html>
    <html>
    <head>
      <title>{{ title }}</title>
    </head>
    <body>
      {% block content %}
        {# your content will end up here #}
      {% end block %}
    </body>
    </html>

### Write your page template

Save this as `templates/index.html`.

    {% extends "layout.html" %}

    {% block content %}
      {# this will replace the block with
      same name in the layout template #}

      <h1>{{ title }}</h1>
      <p>{{ message }}</p>

      {# these are just comments, btw #}
    {% end block %}

### Write your application

Save this as `index.esp`.

    #!/usr/local/bin/eui

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

    -- "/" is the URL path, "index" is the name of the route
    -- route() will find the matching routine automatically

    server:start()

    -- the server runs on http://localhost:5000/ by default

### Run your application

    > eui index.esp

Open your web browser to your application URL at `http://localhost:5000/`

## Installation

This example assumes you are running Apache 2.4 on Linux and that you've already got a basic working web server.

### Download Euphoria

    wget "http://sourceforge.net/projects/rapideuphoria/files/Euphoria/4.1.0-beta2/euphoria-4.1.0-Linux-x64-57179171dbed.tar.gz/download" -O euphoria-4.1.0-Linux-x64-57179171dbed.tar.gz
    sudo tar xzf euphoria-4.1.0-Linux-x64-57179171dbed.tar.gz -C /usr/local/

### Install Euphoria

    cd /usr/local/bin/
    sudo find /usr/local/euphoria-4.1.0-Linux-x64/bin/ -type f -executable -exec ln -s {} \;

### Get Euphoria MVC

Check out euphoria-mvc into your project directory

    git clone https://github.com/openeuphoria/euphoria-mvc

Or if you're already using git, check out as a submodule.

    git add submodule https://github.com/openeuphoria/euphoria-mvc

### Configure Euphoria

Update your `eu.cfg` to use euphoria-mvc/include.

    [all]
    -i euphoria-mvc/include

### Update .htaccess

Tell Apache you want it to execute Euphoria scripts and use index.esp as the index.

    AddHandler cgi-script .esp
    Options +ExecCGI
    DirectoryIndex index.esp

    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^(.*)$ index.esp/$1 [L,NS]

You can also add a block like this to keep snoopers out of certain files:

    <Files ~ ".cfg$|.err$|.edb$">
	    Deny from all
    </Files>

Although the ideal solution would be to store sensitive data outside of your web root.

### Run your application

Change the last line of your application from `server:start()` to `app:run()`.

Then open your web browser to your web server's IP address or host name.


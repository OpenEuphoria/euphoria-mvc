# Euphoria MVC

**Euphoria MVC** is a [model-view-controller](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller) application framework for [Euphoria](https://github.com/OpenEuphoria/euphoria).

## Project status

This project is still in the very early stages of development. Things can and will break or change until we reach a stable release. Documentation is not yet complete. Please see [CONTRIBUTING](CONTRIBUTING.md) for details on how to submit bug reports, feature requests, or if you'd like to contribute to the project directly.

## Features

### Stable modules

These modules are fairly mature and operational.

* [mvc/app.e](docs/APP.md) -- application routing
* [mvc/config.e](docs/CONFIG.md) -- configuration files
* [mvc/headers.e](docs/HEADERS.md) -- send HTTP headers
* [mvc/logger.e](docs/LOGGER.md) -- console and file logging
* [mvc/mimetype.e](docs/MIMETYPE.md) -- MIME type database
* [mvc/server.e](docs/SERVER.md) -- development web server
* [mvc/template.e](docs/TEMPLATE.md) -- document templates
* [mvc/utils.e](docs/UTILS.md) -- miscellaneous utilities

### Work in progress

These modules function as-is but still need some improvements.

* [mvc/cookie.e](docs/COOKIE.md) -- manage HTTP cookies
* [mvc/creole.e](docs/CREOLE.md) -- Creole markup to HTML
* [mvc/database.e](docs/DATABASE.md) -- database connections
  * [mvc/db_mysql.e](docs/DATABASE.md#mysql)
  * [mvc/db_sqlite3.e](docs/DATABASE.md#sqlite3)
* [mvc/mapdbg.e](docs/MAPDBG.md) -- debugging for std/map.e
* [mvc/session.e](docs/SESSION.md) -- manage HTTP sessions
* [mvc/strbuf.e](docs/STRBUF.md) -- string buffer (for CURL)

### Experimental

These modules are not yet stablized and are subject to change.

* [mvc/hooks.e](docs/HOOKS.md) -- hooks for mvc/app.e
* [mvc/html.e](docs/HTML.md) -- HTML parser
* [mvc/json.e](docs/JSON.md) -- JSON parser
* [mvc/model.e](docs/MODEL.md) -- database object mapping

### Third-party

These modules are based on third-party libraries or services.

* [curl/curl.e](docs/CURL.md) -- wrapper for libcurl
* [db/mysql.e](docs/MYSQL.md) -- wrapper for libmysqlclient or libmariadb
* [db/replit.e](docs/REPLIT.md) -- wrapper for [Repl.it Database](https://docs.repl.it/misc/database)
* [db/sqlite3.e](docs/SQLITE.md) -- wrapper for libsqlite3

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

    cd ~/Downloads
    wget "https://sourceforge.net/projects/rapideuphoria/files/Euphoria/4.1.0-beta2/euphoria-4.1.0-Linux-x64-57179171dbed.tar.gz/download" -O euphoria-4.1.0-Linux-x64-57179171dbed.tar.gz
    sudo tar xzf euphoria-4.1.0-Linux-x64-57179171dbed.tar.gz -C /usr/local/

### Install Euphoria

    cd /usr/local/bin/
    sudo find /usr/local/euphoria-4.1.0-Linux-x64/bin/ -type f -executable -exec ln -vs {} \;

### Install Euphoria MVC

    sudo git clone https://github.com/OpenEuphoria/euphoria-mvc /opt/OpenEuphoria/euphoria-mvc
    sudo chown -vR www-root:www-root /opt/OpenEuphoria/euphoria-mvc

### Update your web root

    cd /var/www/html
    printf "[all]\n-i /opt/OpenEuphoria/euphoria-mvc/include\n" | sudo tee eu.cfg

Move your `index.esp` and other project files to this directory.

### Add CGI handler

Tell Apache you want it to execute Euphoria scripts and use index.esp as the index. This would generally go into a `<Directory>` directive in the site's configuration file, or directly into the local `.htaccess` file.

    # Add CGI handler for index.esp
    AddHandler cgi-script .esp
    DirectoryIndex index.esp
    Options +ExecCGI

    # Send all non-existant paths to index.esp
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^(.*)$ index.esp/$1 [L,NS]

You can also add a block like this to keep snoopers out of certain files:

    <Files ~ ".(cfg|err|edb)$">
	    Deny from all
    </Files>

Although the ideal solution would be to store sensitive data outside of your web root.

### Run your application

Change the last line of your application from `server:start()` to `app:run()`.

Then open your web browser to your web server's IP address or host name.


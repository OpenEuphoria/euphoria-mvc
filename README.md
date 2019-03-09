# Euphoria MVC

**Euphoria MVC** is a model-view-controller framework for [Euphoria](https://githubc.com/OpenEuphoria/Euphoria).

## Project status

This project is in the very early stages of development. Things can and will break or change until we reach a stable release.

## Features

### [Templates](docs/TEMPLATE.md)

Build your views in HTML and then render your data to the page.

### [Routing](docs/APP.md)

Automatically route static or dynamic paths to handler functions.

### Database

Execute queries on any (well, most) database systems from one codebase.

### Models

_(Coming soon!)_  
Easily store and fetch Euphoria data via object-relation mapping (ORM).

## Getting Started

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

### Write your template.

Save this as `templates/index.html`.

    <!DOCTYPE html>
    <html>
    <head>
      <title>{{ title }}</title>
    </head>
    <body>
      <h1>{{ title }}</h1>
      <p>{{ message }}</p>
    </body>
    </html>

### Write your application.

Save this as `index.esp`.

    #!/usr/local/bin/eui

    include mvc/app.e
    include mvc/template.e
    include std/map.e

    function index( object request )

        map response = map:new()
        map:put( response, "title", "My First App" )
        map:put( response, "message", "Hello, world!" )

        return render_template( "index.html", response )
    end function
    app:route( "/", "index" )
    
    -- "/" is the URL path, "index" is the name of the route
    -- route() will find the matching routine automatically
    
    app:run()

### Run your application

Open your web browser to your application URL.

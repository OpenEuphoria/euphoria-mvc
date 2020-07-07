
include mvc/app.e
include mvc/logger.e
include mvc/server.e
include mvc/template.e
include std/map.e

set_template_path( "../templates" )

function user_id( object request )
    
    integer id = map:get( request, "id", -1 )
    
    map response = map:new()
    map:put( response, "title", "User" )
    map:put( response, "id", id )
    
    return render_template( "user.html", response )
end function
app:route( "/user/<id:integer>", "user_id" )

function user_name( object request )
    
    sequence name = map:get( request, "name", "undefined" )
    
    map response = map:new()
    map:put( response, "title", "User" )
    map:put( response, "name", name )
    
    return render_template( "user.html", response )
end function
app:route( "/user/<name:string>", "user_name" )

function index( object request )
    
    map response = map:new()
    map:put( response, "title", "Index" )
    map:put( response, "message", "Hello, world!" )
    
    return render_template( "index.html", response )
end function
app:route( "/index", "index" )
app:route( "/", "root",, routine_id("index") )

set_log_level( LOG_ALL )
server:start()

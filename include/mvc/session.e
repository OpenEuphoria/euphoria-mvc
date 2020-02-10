
namespace session

include std/convert.e
include std/error.e
include std/filesys.e
include std/map.e

include mvc/app.e
include mvc/cookie.e
include mvc/hooks.e

constant SESSION_CHARS = "abcdefghijklmnopqrstuvwxyz" &
	"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

object session_path = getenv( "SESSION_PATH" )

if atom( session_path ) then
	session_path = current_dir() & SLASH & "session"
end if

map m_session

public function new_session_id( integer len = 32 )

	integer max = length( SESSION_CHARS )
	sequence session_id = repeat( 0, len )

	for i = 1 to len do
		session_id[i] = SESSION_CHARS[rand(max)]
	end for

	return session_id
end function

public function write_session()

	if file_type( session_path ) != FILETYPE_DIRECTORY then

		if create_directory( session_path ) = 0 then
			error:crash( "Could not create %s", {session_path} )
		end if

	end if

	if not object( m_session ) then
		error:crash( "Session not started" )
	end if

	sequence session_id = map:get( m_session, "session_id", "" )
	if length( session_id ) = 0 then
		session_id = new_session_id()
		map:put( m_session, "session_id", session_id )
	end if

	sequence session_file = session_path & SLASH & session_id
	integer result = save_map( m_session, session_file, SM_TEXT )

	if result = -1 then
		error:crash( "Could not write session" )
	end if

	set_cookie( "session_id", session_id )

	return 0
end function

public procedure session_start()

	object session_map = map:new()
	sequence session_id, session_file

	if atom( dir(session_path) ) then
		log_error( "Could not find session path: %s", {session_path} )
		return
	end if

	session_id = get_cookie( "session_id", "" )
	session_file = session_path & SLASH & session_id

	if length( session_id ) = 0 then

		session_id = new_session_id()
		session_file = session_path & SLASH & session_id

		if file_exists( session_file ) then
			delete_file( session_file )
		end if

	end if

	if file_exists( session_file ) then
		session_map = load_map( session_file )
	end if

	if object( m_session ) then
		delete( m_session )
	end if

	m_session = session_map

	insert_hook( HOOK_REQUEST_END, "write_session" )

end procedure

public function get_session( sequence name, object default = 0 )

	if not object( m_session ) then
		error:crash( "Session not started" )
	end if

	return map:get( m_session, name, default )
end function

public procedure set_session( sequence name, object value )

	if not object( m_session ) then
		error:crash( "Session not started" )
	end if

	if equal( name, "session_id" ) then
		error:crash( "Cannot set session_id" )
	end if

	map:put( m_session, name, value )

end procedure


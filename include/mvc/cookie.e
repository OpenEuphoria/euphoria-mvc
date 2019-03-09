
namespace cookie

include std/datetime.e
include std/map.e
include std/text.e

include mvc/app.e

map m_cookie

--
-- Parse HTTP_COOKIE and cache it in a map.
--
public procedure parse_cookie()

    if not object( m_cookie ) then

        sequence http_cookie = app:getenv( "HTTP_COOKIE" )
        sequence cookie_pairs = keyvalues( http_cookie, ";", "=", "\"" )

        m_cookie = map:new_from_kvpairs( cookie_pairs )

    end if

end procedure

--
-- Returns a properly formatted cookie date.
--
public function get_cookie_date( object dt )

    if atom( dt ) then
        -- unix timestamp
        dt = datetime:from_unix( dt )

    elsif not datetime( dt ) then
        -- string format
        dt = datetime:parse( dt )

    end if

    if datetime( dt ) then
        dt = datetime:format( dt, "%a, %d %b %Y %H:%M:%S GMT" )
    end if

    return dt
end function

public enum
    SameSite_Strict = 1,
    SameSite_Lax = 0

public function get_samesite_value( object same_site )

    if equal( same_site, SameSite_Lax ) then
        return "Lax"

    elsif equal( same_site, SameSite_Strict ) then
        return "Strict"

    end if

    return same_site
end function

--
-- Returns a list of incoming cookie names.
--
public function get_cookies()

    parse_cookie()

    return map:keys( m_cookie )
end function

--
-- Parses the incoming cookie and looks up a value.
--
public function get_cookie( sequence name, object default = 0 )

    parse_cookie()

    return map:get( m_cookie, name, default )
end function

--
-- Sets an outgoing cookie and its options.
--
public procedure set_cookie( sequence name, object value = "", object expiry = "", object max_age = "",
    object domain = "", object path = "", object secure = "", object http_only = "", object same_site = "" )

    if atom( value ) then value = sprint( value ) end if
    sequence cookie = sprintf( "%s=%s", {name,value} )

    if not equal( expiry, "" ) then
        expiry = get_cookie_date( expiry )
        cookie &= sprintf( "; Expiry=%s", {expiry} )
    end if

    if not equal( max_age, "" ) then
        cookie &= sprintf( "; Max-Age=%d", {max_age} )
    end if

    if not equal( domain, "" ) then
        cookie &= sprintf( "; Domain=%s", {domain} )
    end if

    if not equal( path, "" ) then
        cookie &= sprintf( "; Path=%s", {path} )
    end if

    if not equal( secure, "" ) then
        cookie &= "; Secure"
    end if

    if not equal( http_only, "" ) then
        cookie &= "; HttpOnly"
    end if

    if not equal( same_site, "" ) then
        same_site = get_samesite_value( same_site )
        cookie &= sprintf( "; SameSite=%s", {same_site} )
    end if

    header( "Set-Cookie", {cookie} )

end procedure


# Cookies

## Concepts

Cookies are a pretty simple concept. You can set values when sending a **response**, and the browser will return them in the next **request**.

Rather than going into the specifics here, I recommend reading more here: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie

## Cookie routines

### get_cookies

`include mvc/cookie.e`  
`public function get_cookies()`

Returns a sequence containing all of the cookies sent in the **request**.

### get_cookies

`include mvc/cookie.e`__
`public function get_cookie( sequence name, object default = 0 )`

Returns the value of a given cookie, or the specified default value.

**Parameters**

- **`name`** - the name of the cookie
- **`default`** - the default value

### set_cookie

`include mvc/cookie.`__
`public procedure set_cookie( sequence name, object value = "", object expiry = "", object max_age = "",`  
`    object domain = "", object path = "", object secure = "", object http_only = "", object same_site = "" )`

Sets the value of a cookie. See the **Set-Cookie** documentation for details.

**Parameters**

- **`name`** - the name of the cookie
- **`value`** - the value of the cookie
- **`expiry`** - the maximum lifetime of the cookie as a timestamp
- **`max_age`** - number of seconds until the cookie expires
- **`domain`** - specifies those hosts to which the cookie will be sent
- **`path`** - indicates a URL path that must exist in the requested resource before sending the cookie header
- **`secure`** - a secure cookie will only be sent to the server when a request is made using SSL and the HTTPS protocol
- **`http_only`** - HTTP-only cookies aren't accessible via JavaScript or other internal APIs to prevent cross-site scripting (XSS)
- **`same_site`** - allows servers to assert that a cookie ought not to be sent along with cross-site requests, which provides some
protection against cross-site request forgery attacks (CSRF).

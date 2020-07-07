# MIME database

This is a quick-and-dirty MIME type lookup based on this list: [Incomplete list of MIME types](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Complete_list_of_MIME_types).

## MIME routines

* [`get_mime_type`](#get_mime_type)

### get_mime_type

`include mvc/mimetype.e`  
`public function get_mime_type( sequence path, sequence default = DEFAULT_MIME_TYPE )`

Returns the MIME type for the given file path, based on its extension.

**Parameters**

- **`path`** - the file path
- **`default`** - the default MIME type, ``DEFAULT_MIME_TYPE` is `"application/octet-stream"`

**Notes**

- You may want to specify `"text/plain"` as `default` if you're *sure* your content is plain text.

**Returns**

The MIME type for the given file, or `default` if the extension was not found.

# CURL Information

These are the available options for **[curl_easy_getinfo](CURL.md#curl_easy_getinfo)**.

## Available Information

### CURLINFO_EFFECTIVE_METHOD

`curl_easy_getinfo_string( atom handle, CURLINFO_EFFECTIVE_METHOD )`

In cases when you've asked libcurl to follow redirects, the method may very well not be the same method the first request would use.

### CURLINFO_EFFECTIVE_URL

`curl_easy_getinfo_string( atom handle, CURLINFO_EFFECTIVE_URL )`

In cases when you've asked libcurl to follow redirects, it may very well not be the same value you set with **[CURLOPT_URL](CURLOPT.md#CURLOPT_URL)**.

### CURLINFO_RESPONSE_CODE

`curl_easy_getinfo_long( atom handle, CURLINFO_RESPONSE_CODE )`

Returns the last received HTTP, FTP or SMTP response code. The returned value will be zero if no server response code has been received. Note that a proxy's CONNECT response should be read with **[CURLINFO_HTTP_CONNECTCODE](#CURLINFO_HTTP_CONNECTCODE)** and not this.

### CURLINFO_HTTP_CONNECTCODE

`curl_easy_getinfo_long( atom handle, CURLINFO_HTTP_CONNECTCODE )`

Returns the last received HTTP proxy response code to a CONNECT request. The returned value will be zero if no such response code was available.

### CURLINFO_HTTP_VERSION

`curl_easy_getinfo_long( atom handle, CURLINFO_HTTP_VERSION )`

Returns the version used in the last http connection. The returned value will be `CURL_HTTP_VERSION_1_0`, `CURL_HTTP_VERSION_1_1`, `CURL_HTTP_VERSION_2_0`, `CURL_HTTP_VERSION_3` or `0` if the version can't be determined.


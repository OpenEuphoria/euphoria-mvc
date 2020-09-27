# CURL Options

These are the available options for **[curl_easy_setopt](CURL.md#curl_easy_setopt)**.

## Behavior Options

### CURLOPT_VERBOSE

`curl_easy_setopt_long( atom handle, CURLOPT_VERBOSE, atom onoff )`

Set the **onoff** parameter to `TRUE` to make the library display a lot of verbose information about its operations on this handle. Very useful for libcurl and/or protocol debugging and understanding. The verbose information will be sent to stderr, or the stream set with **[CURLOPT_STDERR](#CURLOPT_STDERR)**.

You hardly ever want this set in production use, you will almost always want this when you debug/report problems.

To also get all the protocol data sent and received, consider using the **[CURLOPT_DEBUGFUNCTION](#CURLOPT_DEBUGFUNCTION)**.

### CURLOPT_HEADER

`curl_easy_setopt_long( atom handle, CURLOPT_HEADER, atom onoff )`

Pass the long value **onoff** set to `TRUE` to ask libcurl to include the headers in the write callback (**[CURLOPT_WRITEFUNCTION](#CURLOPT_WRITEFUNCTION)**). This option is relevant for protocols that actually have headers or other meta-data (like HTTP and FTP).

When asking to get the headers passed to the same callback as the body, it is not possible to accurately separate them again without detailed knowledge about the protocol in use.

Further: the **[CURLOPT_WRITEFUNCTION](#CURLOPT_WRITEFUNCTION)** callback is limited to only ever get a maximum of `CURL_MAX_WRITE_SIZE` bytes passed to it (16KB), while a header can be longer and the **[CURLOPT_HEADERFUNCTION](#CURLOPT_HEADERFUNCTION)** supports getting called with headers up to `CURL_MAX_HTTP_HEADER` bytes big (100KB).

It is often better to use **[CURLOPT_HEADERFUNCTION](#CURLOPT_HEADERFUNCTION)** to get the header data separately.

While named confusingly similar, **[CURLOPT_HTTPHEADER](#CURLOPT_HTTPHEADER)** is used to set custom HTTP headers!

### CURLOPT_NOPROGRESS

`curl_easy_setopt_long( atom handle, CURLOPT_NOPROGRESS, atom onoff )`

If **onoff** is to `TRUE`, it tells the library to shut off the progress meter completely for requests done with this handle. It will also prevent the **[CURLOPT_XFERINFOFUNCTION](#CURLOPT_XFERINFOFUNCTION)** or **[CURLOPT_PROGRESSFUNCTION](#CURLOPT_PROGRESSFUNCTION)** from getting called.

### CURLOPT_NOSIGNAL

`curl_easy_setopt_long( atom handle, CURLOPT_NOSIGNAL, atom onoff )`

If **onoff** is `TRUE`, libcurl will not use any functions that install signal handlers or any functions that cause signals to be sent to the process. This option is here to allow multi-threaded unix applications to still set/use all timeout options etc, without risking getting signals.

If this option is set and libcurl has been built with the standard name resolver, timeouts will not occur while the name resolve takes place. Consider building libcurl with the c-ares or threaded resolver backends to enable asynchronous DNS lookups, to enable timeouts for name resolves without the use of signals.

Setting **CURLOPT_NOSIGNAL** to `TRUE` makes libcurl NOT ask the system to ignore SIGPIPE signals, which otherwise are sent by the system when trying to send data to a socket which is closed in the other end. libcurl makes an effort to never cause such SIGPIPEs to trigger, but some operating systems have no way to avoid them and even on those that have there are some corner cases when they may still happen, contrary to our desire. In addition, using **CURLAUTH_NTLM_WB** authentication could cause a SIGCHLD signal to be raised.

### CURLOPT_WILDCARDMATCH

`curl_easy_setopt_long( atom handle, CURLOPT_WILDCARDMATCH, atom onoff )`

Set **onoff** to `TRUE` if you want to transfer multiple files according to a file name pattern. The pattern can be specified as part of the **[CURLOPT_URL](#CURLOPT_URL)** option, using an fnmatch-like pattern (Shell Pattern Matching) in the last part of URL (file name).

By default, libcurl uses its internal wildcard matching implementation. You can provide your own matching function by the **[CURLOPT_FNMATCH_FUNCTION](#CURLOPT_FNMATCH_FUNCTION)** option.

This feature is only supported for FTP download.

A brief introduction of its syntax follows:

*** - ASTERISK**

`ftp://example.com/some/path/*.txt` (for all txt's from the root directory).

Only two asterisks are allowed within the same pattern string.

**? - QUESTION MARK**

Question mark matches any (exactly one) character.

`ftp://example.com/some/path/photo?.jpeg`

**[ - BRACKET EXPRESSION**

The left bracket opens a bracket expression. The question mark and asterisk have no special meaning in a bracket expression. Each bracket expression ends by the right bracket and matches exactly one character. Some examples follow:

**[a-zA-Z0-9]** or **[f-gF-G]** - character interval

**[abc]** - character enumeration

**[^abc]** or **[!abc]** - negation

**[[:name:]]** class expression. Supported classes are **alnum**, **lower**, **space**, **alpha**, **digit**, **print**, **upper**, **blank**, **graph**, **xdigit**.

**[][-!^]** - special case - matches only '-', ']', '[', '!' or '^'. These characters have no special purpose.

**[\[\]\\]** - escape syntax. Matches '[', ']' or '´.

Using the rules above, a file name pattern can be constructed:

`ftp://example.com/some/path/[a-z[:upper:]\\].jpeg`


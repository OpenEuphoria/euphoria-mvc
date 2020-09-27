# CURL

## Overview

The CURL wrapper provided with Euphoria MVC wraps most of the [libcurl](https://curl.haxx.se/download.html) library as of verison 7.72.0 (19 Aug 2020).

This documentation only covers the [easy interface](https://curl.haxx.se/libcurl/c/libcurl-easy.html) for the time being. Most of it has been copied directly from the curl man pages.

Plase make sure you're using the native platform version of Euphoria 4.1 (i.e. 64-bit Euphoria on 64-bit Windows or Linux).

## Installation

### Windows

I recommend using the [curl-for-win](https://github.com/curl/curl-for-win) binaries by Viktor Szakats available here:

**curl 7.72.0**

| Platform | Size    | Link |
| -------- | ------- | ---- |
| Win32    | 3.03 MB | [curl-7.72.0-win32-mingw.zip](https://bintray.com/vszakats/generic/download_file?file_path=curl-7.72.0-win32-mingw.zip) |
| Win64    | 3.31 MB | [curl-7.72.0-win64-mingw.zip](https://bintray.com/vszakats/generic/download_file?file_path=curl-7.72.0-win64-mingw.zip) |

You'll also need the OpenSSL dependencies, available from same author:

**OpenSSL 1.1.1g**

| Platform | Size    | Link |
| -------- | ------- | ---- |
| Win32    | 3.76 MB | [openssl-1.1.1g-win32-mingw.zip](https://bintray.com/vszakats/generic/download_file?file_path=openssl-1.1.1g-win32-mingw.zip) |
| Win64    | 4.26 MB | [openssl-1.1.1g-win64-mingw.zip](https://bintray.com/vszakats/generic/download_file?file_path=openssl-1.1.1g-win64-mingw.zip)

You just need the DLL files from the packages above. Copy **libcurl.dll**, **libssl-1_1.dll**, and **libcrypto-1_1.dll** into your `C:\Euphoria\bin` directory. (For Win64, these DLL files will include `-x64` in the file name, e.g. **libcurl-x64.dll**.) And that's it!

### Linux

Your Linux distribution very likely already has libcurl installed on the system. If not you can probably `apt-get install libcurl` or `yum install libcurl` or whatver is applicable to your system. This wrapper may not work with very old versions of libcurl, so your mileage may vary. If not, you may be able to build the latest versions from source.

## Easy interface

### Description

When using libcurl's "easy" interface you init your session and get a handle (often referred to as an "easy handle"), which you use as input to the easy interface functions you use. Use **[curl_easy_init](#curl_easy_init)** to get the handle.

You continue by setting all the options you want in the upcoming transfer, the most important among them is the URL itself (you can't transfer anything without a specified URL as you may have figured out yourself). You might want to set some callbacks as well that will be called from the library when data is available etc. **[curl_easy_setopt](#curl_easy_setopt)** is used for all this.

**[CURLOPT_URL](CURLOPT.md#CURLOPT_URL)** is only option you really must set, as otherwise there can be no transfer. Another commonly used option is **[CURLOPT_VERBOSE](CURLOPT.md#CURLOPT_VERBOSE)** that will help you see what libcurl is doing under the hood, very useful when debugging for example. The **[curl_easy_setopt](#curl_easy_setopt)** man page has a full index of the over 200 available options.

If you at any point would like to blank all previously set options for a single easy handle, you can call **[curl_easy_reset](#curl_easy_reset)** and you can also make a clone of an easy handle (with all its set options) using **[curl_easy_duphandle](#curl_easy_duphandle)**.

When all is setup, you tell libcurl to perform the transfer using **[curl_easy_perform](#curl_easy_perform)**. It will then do the entire operation and won't return until it is done (successfully or not).

After the transfer has been made, you can set new options and make another transfer, or if you're done, cleanup the session by calling **[curl_easy_cleanup](#curl_easy_cleanup)**. If you want persistent connections, you don't cleanup immediately, but instead run ahead and perform other transfers using the same easy handle.

### Example

    atom curl = curl_easy_init()
    if curl then
        integer result
        curl_easy_setopt_string( curl, CURLOPT_URL, "https://example.com" )
        result = curl_easy_perform( curl )
        curl_easy_cleanup( curl )
    end if

### Functions

- [`curl_easy_init`](#curl_easy_init)
- [`curl_easy_cleanup`](#curl_easy_cleanup)
- [`curl_easy_setopt`](#curl_easy_setopt)
- [`curl_easy_perform`](#curl_easy_perform)
- [`curl_easy_getinfo`](#curl_easy_getinfo)
- [`curl_easy_reset`](#curl_easy_reset)

### curl_easy_init

`include curl/easy.e`  
`public function curl_easy_init()`

This function must be the first function to call, and it returns a CURL easy handle that you must use as input to other functions in the easy interface. This call **MUST** have a corresponding call to **[curl_easy_cleanup](#curl_easy_cleanup)** when the operation is complete.

**Returns**

If this function returns `NULL`, something went wrong and you cannot use the other curl functions. 

### curl_easy_cleanup

`include curl/easy.e`  
`public procedure curl_easy_cleanup( atom curl )`

This function must be the last function to call for an easy session. It is the opposite of the **[curl_easy_init](#curl_easy_init)** function and must be called with the same handle as input that a **[curl_easy_init](#curl_easy_init)** call returned.

This might close all connections this handle has used and possibly has kept open until now - unless it was attached to a multi handle while doing the transfers. Don't call this function if you intend to transfer more files, re-using handles is a key to good performance with libcurl.

Occasionally you may get your progress callback or header callback called from within **curl_easy_cleanup** (if previously set for the handle using **[curl_easy_setopt](#curl_easy_setopt)**). Like if libcurl decides to shut down the connection and the protocol is of a kind that requires a command/response sequence before disconnect. Examples of such protocols are FTP, POP3 and IMAP.

Any use of the **handle** after this function has been called and have returned, is illegal. **curl_easy_cleanup** kills the handle and all memory associated with it!

Passing in a `NULL` pointer in handle will make this function return immediately with no action.

### curl_easy_setopt

`include curl/easy.e`  
`public function curl_easy_setopt( atom curl, integer option, object param )`

**curl_easy_setopt** is used to tell libcurl how to behave. By setting the appropriate options, the application can change libcurl's behavior. All options are set with an option followed by a parameter. That parameter can be a **long**, a **function pointer**, an **object pointer**, or a **curl_off_t**, depending on what the specific option expects. In order to accommodate these various types, there is no plain **curl_easy_setopt** function in this wrapper. Instead, there is a separate function for each option type:

- `curl_easy_setopt_long( atom curl, integer option, atom param )`
- `curl_easy_setopt_func( atom curl, integer option, atom param )`
- `curl_easy_setopt_objptr( atom curl, integer option, atom param )`
- `curl_easy_setopt_off_t( atom curl, integer option, atom param )`
- `curl_easy_setopt_string( atom curl, integer option, object param )`

Read this manual carefully as bad input values may cause libcurl to behave badly! Some basic typechecking is set up in each version of **curl_easy_setopt** listed above to help prevent unwanted behavior. You can only set one option in each function call. A typical application uses many **curl_easy_setopt** calls in the setup phase.

Options set with this function call are valid for all forthcoming transfers performed using this handle. The options are not in any way reset between transfers, so if you want subsequent transfers with different options, you must change them between the transfers. You can optionally reset all options back to internal default with **[curl_easy_reset](#curl_easy_reset)**.

Strings passed to libcurl are copied by the library; thus the string storage associated to the pointer argument may be overwritten after **curl_easy_setopt** returns. The only exception to this rule is really **[CURLOPT_POSTFIELDS](CURLOPT.md#CURLOPT_POSTFIELDS)**, but the alternative that copies the string **[CURLOPT_COPYPOSTFIELDS](CURLOPT.md#CURLOPT_COPYPOSTFIELDS)** has some usage characteristics you need to read up on.

The order in which the options are set does not matter.

The **handle** is the return code from a **[curl_easy_init](#curl_easy_init)** or **[curl_easy_duphandle](#curl_easy_duphandle)** call.

See **[CURL Options](CURLOPT.md)** for a full list of available options.

### curl_easy_perform

`include curl/easy.e` 
`public function curl_easy_perform( atom curl )`

Invoke this function after **[curl_easy_init](#curl_easy_init)** and all the **[curl_easy_setopt](#curl_easy_setopt)** calls are made, and will perform the transfer as described in the options. It must be called with the same **handle** as input as the **[curl_easy_init](#curl_easy_init)** call returned.

**curl_easy_perform** performs the entire request in a blocking manner and returns when done, or if it failed. For non-blocking behavior, see **curl_multi_perform**.

You can do any amount of calls to **curl_easy_perform** while using the same **handle**. If you intend to transfer more than one file, you are even encouraged to do so. libcurl will then attempt to re-use the same connection for the following transfers, thus making the operations faster, less CPU intense and using less network resources. Just note that you will have to use **[curl_easy_setopt](#curl_easy_setopt)** between the invokes to set options for the following **curl_easy_perform**.

You must never call this function simultaneously from two places using the same **handle**. Let the function return first before invoking it another time. If you want parallel transfers, you must use several curl **handles**.

**Returns**

**CURLE_OK** `(0)` means everything was ok, non-zero means an error occurred as <curl/curl.h> defines - see libcurl-errors. If the **[CURLOPT_ERRORBUFFER](CURLOPT.md#CURLOPT_ERRORBUFFER)** was set with **[curl_easy_setopt](#curl_easy_setopt)** there will be a readable error message in the error buffer when non-zero is returned.

### curl_easy_getinfo

`include curl/easy.e` 
`public function curl_easy_getinfo( atom curl, integer option )`

Request internal information from the curl session with this function. The return value may be a **long**, a **string**, a **curl_slist**, or a **double** (as this documentation describes further down). In order to accommodate these various types, there is no plain **curl_easy_getinfo** function in this wrapper. Instead, there is a separate function for each option type:

- `public function curl_easy_getinfo_long( atom curl, integer option )`
- `public function curl_easy_getinfo_string( atom curl, integer option )`
- `public function curl_easy_getinfo_slist( atom curl, integer option )`
- `public function curl_easy_getinfo_double( atom curl, integer option )`

**Returns**

The return value will always be `{result,value}` but you should ensure `result` is **CURLE_OK** `(0)` before relying on `value` to be correct. Although `value` will always be of the type specified by the function name. Use this function AFTER a performed transfer if you want to get transfer related data.

You should not free the memory returned by this function unless it is explicitly mentioned in this manual.

**Notes**

See **[CURL Info](CURLINFO.md)** for a full list of available information options.

### curl_easy_reset

`include curl/easy.e` 
`public procedure curl_easy_reset( atom curl )`

Re-initializes all options previously set on a specified CURL handle to the default values. This puts back the handle to the same state as it was in when it was just created with **[curl_easy_init](#curl_easy_init)**.

It does not change the following information kept in the handle: live connections, the Session ID cache, the DNS cache, the cookies, the shares or the alt-svc cache.



namespace strbuf

include std/dll.e
include std/machine.e

constant TRUE = 1
constant FALSE = 0

ifdef BITS64 then

constant
	strbuf__value  =  0, -- char*
	strbuf__alloc  =  8, -- unsigned int
	strbuf__offset = 12, -- unsigned int
	strbuf__curlen = 16, -- unsigned int
	SIZEOF_STRBUF  = 20,
$

elsedef -- BITS32

constant
	strbuf__value  =  0, -- char*
	strbuf__alloc  =  4, -- unsigned int
	strbuf__offset =  8, -- unsigned int
	strbuf__curlen = 12, -- unsigned int
	SIZEOF_STRBUF  = 16,
$

end ifdef

constant STRBUF_INIT_SIZE = 512
constant STRBUF_GROW_SIZE = 256

--
-- Allocate a new string buffer.
--
public function strbuf_init( atom init_size = 0, integer cleanup = FALSE )

	atom strbuf, value, alloc, offset, curlen

	if init_size = 0 then
		init_size = STRBUF_INIT_SIZE
	end if

	alloc = init_size
	offset = 0
	curlen = 0

	value = allocate_data( alloc )
	mem_set( value, alloc, NULL )

	strbuf = allocate_data( SIZEOF_STRBUF )
	poke_pointer( strbuf + strbuf__value,  value )
	       poke4( strbuf + strbuf__alloc,  alloc )
	       poke4( strbuf + strbuf__offset, offset )
	       poke4( strbuf + strbuf__curlen, curlen )

	if cleanup then
		strbuf = delete_routine( strbuf, routine_id("strbuf_free") )
	end if

	return strbuf
end function

--
-- Free an existing string buffer.
--
public procedure strbuf_free( atom strbuf )

	if strbuf != NULL then

		atom value = peek_pointer( strbuf + strbuf__value )
		atom alloc = peek4u( strbuf + strbuf__alloc )

		if value != NULL then
			free( value )
		end if

		free( strbuf )

	end if

end procedure

--
-- Resize the string buffer to accommodate the new size.
--
public function strbuf_resize( atom strbuf, atom size )

	atom value  = peek_pointer( strbuf + strbuf__value )
	atom alloc  =       peek4u( strbuf + strbuf__alloc )
	atom curlen =       peek4u( strbuf + strbuf__curlen )

	atom temp = allocate_data( size )

	mem_copy( temp, value, curlen )
	mem_set( temp+curlen, size-curlen, NULL )

	free( value )

	poke_pointer( strbuf + strbuf__value, temp )
	       poke4( strbuf + strbuf__alloc, size )

	return temp
end function

--
-- Read from the current position and advance the position by the length read.
--
-- * If 'buffer' is NULL, this will return a sequence of the requested bytes.
-- * If 'buffer' is not NULL, this will copy the requested bytes into the buffer
--   and return the number of bytes copied.
-- * If 'len' is zero, the rest of the string buffer will be read entirely.
-- * If 'len' is less than the available buffer, only the remaining bytes will
--   be read.
--
public function strbuf_read( atom strbuf, atom buffer = NULL, integer len = 0 )

	if strbuf != NULL then

		atom value  = peek_pointer( strbuf + strbuf__value )
		atom alloc  =       peek4u( strbuf + strbuf__alloc )
		atom offset =       peek4u( strbuf + strbuf__offset )
		atom curlen =       peek4u( strbuf + strbuf__curlen )

		atom req = offset + len

		if len = 0 or req > curlen then
			len = curlen - offset
			req = offset + len
		end if

		poke4( strbuf + strbuf__offset, req )

		if buffer = NULL then
			return peek({ value+offset, len })

		else
			mem_copy( buffer, value+offset, len )

		end if

		return len
	end if

	return 0
end function

--
-- Write from the current position.
--
-- * If 'data' is a sequence, poke the sequence of bytes into memory.
-- * If 'data' is an atom, copy 'len' bytes from that memory address.
--
public function strbuf_write( atom strbuf, object data, integer len = length(data) )

	if strbuf != NULL then

		atom value  = peek_pointer( strbuf + strbuf__value )
		atom alloc  =       peek4u( strbuf + strbuf__alloc )
		atom offset =       peek4u( strbuf + strbuf__offset )
		atom curlen =       peek4u( strbuf + strbuf__curlen )

		atom req = offset + len

		if req > alloc then

			atom size = STRBUF_GROW_SIZE * (floor(req/STRBUF_GROW_SIZE)+1)
			value = strbuf_resize( strbuf, size )

		end if

		if sequence( data ) then
			poke( value+offset, data )
		else
			mem_copy( value+offset, data, len )
		end if

		poke4( strbuf + strbuf__curlen, req )
		poke4( strbuf + strbuf__offset, req )

		return len
	end if

	return 0
end function

--
-- Append data to the end of the buffer without advancing the position.
--
public procedure strbuf_append( atom strbuf, sequence string )

	if strbuf != NULL then

		atom value  = peek_pointer( strbuf + strbuf__value )
		atom alloc  =       peek4u( strbuf + strbuf__alloc )
		atom curlen =       peek4u( strbuf + strbuf__curlen )

		atom req = curlen + length( string )

		if req > alloc then

			atom size = STRBUF_GROW_SIZE * (floor(req/STRBUF_GROW_SIZE)+1)
			value = strbuf_resize( strbuf, size )

		end if

		poke( value+curlen, string )
		poke4( strbuf + strbuf__curlen, req )

	end if

end procedure

--
-- Clear the string buffer and reset the position.
--
public procedure strbuf_clear( atom strbuf )

	if strbuf != NULL then

		atom value  = peek_pointer( strbuf + strbuf__value )
		atom curlen =       peek4u( strbuf + strbuf__curlen )

		if value != NULL then
			mem_set( value, curlen, NULL )
		end if

		poke4( strbuf + strbuf__curlen, 0 )
		poke4( strbuf + strbuf__offset, 0 )

	end if

end procedure

--
-- Reset the position of the buffer (but don't clear it).
--
public procedure strbuf_reset( atom strbuf )

	if strbuf != NULL then
		poke4( strbuf + strbuf__offset, 0 )
	end if

end procedure

--
-- Return the current length of the string in the buffer.
--
public function strbuf_length( atom strbuf )

	if strbuf != NULL then
		return peek4u( strbuf + strbuf__curlen )
	end if

	return 0
end function

--
-- Return the entire allocated size of the buffer.
--
public function strbuf_size( atom strbuf )

	if strbuf != NULL then
		return peek4u( strbuf + strbuf__alloc )
	end if

	return 0
end function

--
-- Return the current read/write position of the buffer.
--
public function strbuf_where( atom strbuf )

	if strbuf != NULL then
		return peek4u( strbuf + strbuf__offset )
	end if

	return 0
end function

--
-- Return the entire value of the buffer (ignoring the position).
--
public function strbuf_value( atom strbuf )

	if strbuf != NULL then

		atom value  = peek_pointer( strbuf + strbuf__value )
		atom curlen =       peek4u( strbuf + strbuf__curlen )

		if value != NULL and curlen != 0 then
			return peek({ value, curlen })
		end if

	end if

	return ""
end function

/* This is a return code for the read callback that, when returned, will
   signal libcurl to immediately abort the current transfer. */
constant CURL_READFUNC_ABORT = #10000000

--
-- A special function for reading data with libcurl. A read function is used
-- when you want to provide data *to* libcurl. Don't forget to reset the buffer
-- position if you've used strbuf_write() to put data in the buffer and you want
-- libcurl to read from the beginning. You can use strbuf_append() to write data
-- without advancing the position.
--
-- atom strbuf = strbuf_init()
-- strbuf_append( strbuf, "This is the string data I want libcurl to use." )
--
-- curl_easy_setopt_func( curl, CURLOPT_READFUNCTION, STRBUF_READ_FUNC )
-- curl_easy_setopt_cbptr( curl, CURLOPT_READDATA, strbuf )
--
-- strbuf_free( strbuf )
--
function strbuf_read_func( atom ptr, atom size, atom nitems, atom strbuf )

	if ptr and size and nitems and strbuf then
		return strbuf_read( strbuf, ptr, size*nitems )
	end if

	return CURL_READFUNC_ABORT
end function

constant strbuf_read_func_id = routine_id( "strbuf_read_func" )
constant strbuf_read_func_cb = call_back( strbuf_read_func_id )

public constant STRBUF_READ_FUNC = strbuf_read_func_cb

--
-- A special function for writing data with libcurl. A write function is used
-- when you want to receive data *from* libcurl.
--
-- atom strbuf = strbuf_init()
--
-- curl_easy_setopt_func( curl, CURLOPT_WRITEFUNCTION, STRBUF_WRITE_FUNC )
-- curl_easy_setopt_cbptr( curl, CURLOPT_WRITEDATA, strbuf )
--
-- sequence data = strbuf_value( strbuf )
--
-- strbuf_free( strbuf )
--
function strbuf_write_func( atom ptr, atom size, atom nmemb, atom strbuf )

	if ptr and size and nmemb and strbuf then
		return strbuf_write( strbuf, ptr, size*nmemb )
	end if

	return 0
end function

constant strbuf_write_func_id = routine_id( "strbuf_write_func" )
constant strbuf_write_func_cb = call_back( strbuf_write_func_id )

public constant STRBUF_WRITE_FUNC = strbuf_write_func_cb

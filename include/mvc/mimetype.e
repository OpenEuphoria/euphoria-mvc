
namespace mimetype

include std/filesys.e
--include std/map.e
include std/text.e

include mvc/mapdbg.e as map

--
-- Incomplete list of MIME types
-- https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Complete_list_of_MIME_types
--

map m_mime_types = map:new_from_kvpairs({
	{ "epub",  "application/epub+zip" },           -- Electronic publication (EPUB)
	{ "jar",   "application/java-archive" },       -- Java Archive (JAR)
	{ "json",  "application/json" },               -- JSON format
	{ "jsonld", "application/ld+json" },           -- JSON-LD format
	{ "doc",   "application/msword" },             -- Microsoft Word
	{ "bin",   "application/octet-stream" },       -- Any kind of binary data
	{ "ogx",   "application/ogg" },                -- OGG
	{ "pdf",   "application/pdf" },                -- Adobe Portable Document Format (PDF)
	{ "rtf",   "application/rtf" },                -- Rich Text Format (RTF)
	{ "azw",   "application/vnd.amazon.ebook" },   -- Amazon Kindle eBook format
	{ "xls",   "application/vnd.ms-excel" },       -- Microsoft Excel
	{ "eot",   "application/vnd.ms-fontobject" },  -- MS Embedded OpenType fonts
	{ "ppt",   "application/vnd.ms-powerpoint" },  -- Microsoft PowerPoint
	{ "vsd",   "application/vnd.visio" },          -- Microsoft Visio
	{ "7z",    "application/x-7z-compressed" },    -- 7-zip archive
	{ "abw",   "application/x-abiword" },          -- AbiWord document
	{ "bz",    "application/x-bzip" },             -- BZip archive
	{ "bz2",   "application/x-bzip2" },            -- BZip2 archive
	{ "csh",   "application/x-csh" },              -- C-Shell script
	{ "arc",   "application/x-freearc" },          -- Archive document (multiple files embedded)
	{ "sh",    "application/x-sh" },               -- Bourne shell script
	{ "swf",   "application/x-shockwave-flash" },  -- Small web format (SWF) or Adobe Flash document
	{ "tar",   "application/x-tar" },              -- Tape Archive (TAR)
	{ "xul",   "application/vnd.mozilla.xul+xml" },-- XUL
	{ "rar",   "application/x-rar-compressed" },   -- RAR archive
	{ "xhtml", "application/xhtml+xml" },          -- XHTML
	{ "xml",   "application/xml" },                -- XML
	{ "zip",   "application/zip" },                -- ZIP archive
	{ "aac",   "audio/aac" },                      -- AAC audio
	{ "mid",   "audio/midi audio/x-midi" },        -- Musical Instrument Digital Interface (MIDI)
	{ "midi",  "audio/midi audio/x-midi" },        -- Musical Instrument Digital Interface (MIDI)
	{ "mp3",   "audio/mpeg" },                     -- MP3 audio
	{ "oga",   "audio/ogg" },                      -- OGG audio
	{ "wav",   "audio/wav" },                      -- Waveform Audio Format
	{ "weba",  "audio/webm" },                     -- WEBM audio
	{ "otf",   "font/otf" },                       -- OpenType font
	{ "ttf",   "font/ttf" },                       -- TrueType Font
	{ "woff",  "font/woff" },                      -- Web Open Font Format (WOFF)
	{ "woff2", "font/woff2" },                     -- Web Open Font Format (WOFF)
	{ "bmp",   "image/bmp" },                      -- Windows OS/2 Bitmap Graphics
	{ "gif",   "image/gif" },                      -- Graphics Interchange Format (GIF)
	{ "webp",  "image/webp" },                     -- WEBP image
	{ "jpeg",  "image/jpeg" },                     -- JPEG images
	{ "jpg",   "image/jpeg" },                     -- JPEG images
	{ "png",   "image/png" },                      -- Portable Network Graphics
	{ "svg",   "image/svg+xml" },                  -- Scalable Vector Graphics (SVG)
	{ "tif",   "image/tiff" },                     -- Tagged Image File Format (TIFF)
	{ "tiff",  "image/tiff" },                     -- Tagged Image File Format (TIFF)
	{ "ico",   "image/vnd.microsoft.icon" },       -- Icon format
	{ "ics",   "text/calendar" },                  -- iCalendar format
	{ "css",   "text/css" },                       -- Cascading Style Sheets (CSS)
	{ "csv",   "text/csv" },                       -- Comma-separated values (CSV)
	{ "htm",   "text/html" },                      -- HyperText Markup Language (HTML)
	{ "html",  "text/html" },                      -- HyperText Markup Language (HTML)
	{ "js",    "text/javascript" },                -- JavaScript
	{ "mjs",   "text/javascript" },                -- JavaScript module
	{ "txt",   "text/plain" },                     -- Text, (generally ASCII or ISO 8859-n)
	{ "3gp",   "video/3gpp" },                     -- 3GPP audio/video container
	{ "3g2",   "video/3gpp2" },                    -- 3GPP2 audio/video container
	{ "ts",    "video/mp2t" },                     -- MPEG transport stream
	{ "mpeg",  "video/mpeg" },                     -- MPEG Video
	{ "ogv",   "video/ogg" },                      -- OGG video
	{ "webm",  "video/webm" },                     -- WEBM video
	{ "avi",   "video/x-msvideo" },                -- AVI: Audio Video Interleave
	{ "mpkg",  "application/vnd.apple.installer+xml" },  -- Apple Installer Package
	{ "odp",   "application/vnd.oasis.opendocument.presentation" }, -- OpenDocument presentation document
	{ "ods",   "application/vnd.oasis.opendocument.spreadsheet" }, -- OpenDocument spreadsheet document
	{ "odt",   "application/vnd.oasis.opendocument.text" }, -- OpenDocument text document
	{ "pptx",  "application/vnd.openxmlformats-officedocument.presentationml.presentation" }, -- Microsoft PowerPoint (OpenXML)
	{ "xlsx",  "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" }, -- Microsoft Excel (OpenXML)
	{ "docx",  "application/vnd.openxmlformats-officedocument.wordprocessingml.document" } -- Microsoft Word (OpenXML)
})

constant DEFAULT_MIME_TYPE = "application/octet-stream"

public function get_mime_type( sequence path, sequence default_mime_type = DEFAULT_MIME_TYPE )
	sequence ext = fileext( path )
	return map:get( m_mime_types, text:lower(ext), default_mime_type )
end function


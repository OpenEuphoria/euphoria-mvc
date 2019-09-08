
namespace creole

ifdef UNITTEST then
include std/unittest.e
end ifdef

include std/get.e
include std/sequence.e as seq
include std/search.e as search
include std/text.e
include std/math.e
include std/map.e
include std/types.e
include std/sort.e
include std/map.e
include std/filesys.e

include euphoria/syncolor.e

object gDebug gDebug = 0
public enum     -- Action Codes for the Generator
	HostID,             -- (1) id of application hosting this parser
	OptReparseHeadings, -- "" don't reparse, anything then reparse.
	InternalLink,       -- internal link
	QualifiedLink,      -- A link with a file name and an anchor point within that file
	InterWikiLink,      -- Inter wiki link
	InterWikiLinkError, -- Inter wiki link w/o a valid definition
	NormalLink,         -- normal link
	InternalImage,      -- internal image
	InterWikiImage,     -- interwiki image
	NormalImage,        -- (10) normal image
	Heading,            -- headings
	OrderedList,        -- An ordered (numbered) list
	UnorderedList,      -- An unordered (bullet) list
	ListItem,           -- An item in a list
	ItalicText,         -- italized text
	BoldText,           -- bolded text
	MonoText,           -- monospace font text
	UnderlineText,      -- underlined text
	Superscript,        -- superscripted text
	Subscript,          -- (20) subscripted text
	StrikeText,         -- striked out text
	InsertText,         -- Inserted text
	ColorText,          -- colored text
	CodeExample,        -- program code example
	TableDef,           -- entire table
	TableHead,          -- table header
	TableBody,          -- table body
	HeaderRow,          -- table header row
	HeaderCell,         -- table header cell
	NormalRow,          -- table body row
	NormalCell,         -- table body cell
	NonBreakSpace,      -- (30) non-breaking space
	ForcedNewLine,      -- break the line now
	HorizontalLine,     -- a line across the display
	NoWikiBlock,        -- block style no wiki parsed text
	NoWikiInline,       -- inline style no wiki parsed text
	DefinitionList,     -- A set of definitions
	BeginIndent,        -- Start a new indentation level
	EndIndent,          -- End the current indentation level
	Paragraph,          -- defines a paragraph
	Division,           -- defines a division
	Document,           -- (40) defines a document
	Bookmark,           -- define a bookmark
	Sanitize,           -- Ensure input has no illegal characters
	SanitizeURL,        -- Ensure URL has no illegal characters
	PassThru,           -- Raw text is being asked for.
	CamelCase,          -- Convert a CamelCase word to normal text
	Plugin,             -- A plugin has been called for
	ContextChange,		-- A new !!CONTEXT: record found.
	Comment,			-- A comment
	Quoted,				-- A quoted section
	LastActionCode      -- (50)

public enum     -- Action Codes for the Creole
	Get_Headings,       -- returns all the headings and their bookmarks
	Get_CurrentHeading, -- returns the heading last processed and its bookmark
	Get_CurrentLevels,  -- returns a sequence of the current heading level
	Get_Macro,          -- returns the requested macro's definition
	Get_Bookmarks,      -- returns all the known bookmarks
	Get_Elements,       -- returns all the known elements
	Get_Context,        -- returns the current context value.
	Get_Styles,         -- returns the style stack
	Set_Macro,          -- stores the supplied macro
	Set_Option,         -- sets the supplied option
	Disallow,           -- Turn off specific markup parsing
	Allow,              -- Turn on specific markup parsing
	CO_MaxNumLevel,     -- Depth of heading levels to number
	CO_UpperCase,       -- Set of characters that are the uppercase ones.
	CO_LowerCase,       -- Set of characters that are the lowercase ones.
	CO_SpecialWordChars,-- Set of characters that are also allowed in 'words'
	CO_Digits,          -- Set of characters that are the digits.
	CO_CodeColors,      -- Set of ten strings that are the colors for source code.
	CO_Protocols,       -- Set of protocols that are recognized as linkable.
	CO_SplitLevel,      -- Set the heading level at which to split into separate files.
	CO_SplitName,       -- Set the file prefix for the split files.
	CO_AllowMacros,     -- Set the flag to allow/disallow macros.
	CO_Verbose,         -- Set the verbose flag
	MU_Bold,			-- Allow/Disallow bold markup
	MU_Italic,			-- Allow/Disallow italic markup
	MU_Monospace,		-- Allow/Disallow monospace markup
	MU_Underline,		-- Allow/Disallow underline markup
	MU_Superscript,		-- Allow/Disallow superscript markup
	MU_Subscript,		-- Allow/Disallow subscript markup
	MU_Strikethru,		-- Allow/Disallow strikethru markup
	MU_Insert,			-- Allow/Disallow insert markup
	MU_CamelCase,		-- Allow/Disallow camel case detection
	LastCreoleActionCode


enum    -- Temporary embedded tags
	TAG_ENDFILE =  -100,
	TAG_PLUGIN,
	TAG_STARTPARA,
	TAG_ENDPARA,
	TAG_UNRESOLVED,
	TAG_TABLE_BAR,
	$

constant kLeadIn = "=*/<{#[\n\\-|~!_:^,+`;>%@&"
constant kDecorTag = "*/#_^,-+"
constant kDecorAction = {
			BoldText,       -- *
			ItalicText,     -- /
			MonoText,       -- #
			UnderlineText,  -- _
			Superscript,    -- ^
			Subscript,      -- ,
			StrikeText,     -- -
			InsertText,     -- +
			0
			}

constant vLineBeginings = {"#", "*","=","|", "{{{","<eucode>", ":", ">", "----\n", "%(", "%%"}

integer  vParser_rid
integer  vFinal_Generator_rid
integer  vMacro_Processor_rid
integer  vMaxNumLevel = 0
integer  vSplitLevel = 0
integer  vAllowMacros = 0
integer  vAllowCamelCase = 1
sequence vAllowedDecorations = "*/#_^,-+"
sequence vSplitName = "file"
sequence vOutputFile = {}
integer  vExplicitOutput = 0
sequence vReparseHeading
sequence vHostID
sequence vProtocols
sequence vUpperCase
sequence vLowerCase
sequence vAllLetters
sequence vWordChars
sequence vNameChars
sequence vSpecialWordChars
sequence vDigits
sequence vWhiteSpace
sequence vUnresolved = {}
sequence vHeadingNums = {}
sequence vCurrentContext = ""
sequence vCurrentNamespace = ""
sequence vRawContext = ""
sequence vStyle = {"default"}
integer  vVerbose = 0

constant vHonorifics = {"mr", "mrs", "miss", "ms", "dr", "sir"}
constant vTLD = {
"aero","asia","biz","cat","com","coop","edu","gov","info","int",
"jobs","mil","mobi","museum","name","net","org","pro","tel","travel"
			}
			
constant vCountry_TLD = -- These must be kept in ascending order.
{
"ac","ad","ae","af","ag","ai","al","am","an","ao","aq","ar","as",
"at","au","aw","ax","az","ba","bb","bd","be","bf","bg","bh","bi",
"bj","bm","bn","bo","br","bs","bt","bv","bw","by","bz","ca","cc",
"cd","cf","cg","ch","ci","ck","cl","cm","cn","co","cr","cu","cv",
"cx","cy","cz","de","dj","dk","dm","do","dz","ec","ee","eg","er",
"es","et","eu","fi","fj","fk","fm","fo","fr","ga","gb","gd","ge",
"gf","gg","gh","gi","gl","gm","gn","gp","gq","gr","gs","gt","gu",
"gw","gy","hk","hm","hn","hr","ht","hu","id","ie","il","im","in",
"io","iq","ir","is","it","je","jm","jo","jp","ke","kg","kh","ki",
"km","kn","kp","kr","kw","ky","kz","la","lb","lc","li","lk","lr",
"ls","lt","lu","lv","ly","ma","mc","md","me","mg","mh","mk","ml",
"mm","mn","mo","mp","mq","mr","ms","mt","mu","mv","mw","mx","my",
"mz","na","nc","ne","nf","ng","ni","nl","no","np","nr","nu","nz",
"om","pa","pe","pf","pg","ph","pk","pl","pm","pn","pr","ps","pt",
"pw","py","qa","re","ro","rs","ru","rw","sa","sb","sc","sd","se",
"sg","sh","si","sj","sk","sl","sm","sn","so","sr","st","su","sv",
"sy","sz","tc","td","tf","tg","th","tj","tk","tl","tm","tn","to",
"tp","tr","tt","tv","tw","tz","ua","ug","uk","us","uy","uz","va",
"vc","ve","vg","vi","vn","vu","wf","ws","ye","yt","yu","za","zm",
"zw"}
						
-- Elements: This contains a list of interesting elements discovered during
--           the parsing. They are in the order of being found, thus we can
--           use this to do relative positioning processing.
--    format: [1] = Type.
--                   'b' --> A bookmark
--                   'p' --> A plugin
--            [2] = Pointer to Type record. This is an index into the relevant
--                  sequence containing records of 'Type'.
sequence vElements = {}

-- Plugins: This contains a list of plugins.
--    format: [1] = Parameters from the <<>> tag.
--                  The first parameter is the Plugin name, then remainder
--                  are key-value pairs.
--            [2] = The subcontext id. Contains the value of the !!CONTEXT:
--                  tag that occured prior to this bookmark.
--            [3] = The name of the generated output file. If blank, there is
--                  no file spliting being done.
--            [4] = Pointer to the Element sequence for this plugin.
sequence vPluginList = {}


-- Bookmarks: This contains a list of bookmarks.
--    format: [1] = Type
--                   'h' --> A heading tag auto-generated bookmark
--            [2] = Pointer to Type record. This is an index into the relevant
--                  sequence containing records of 'Type'.
--            [3] = The bookmark name.
--            [4] = The subcontext id. Contains the value of the !!CONTEXT:
--                  tag that occured prior to this bookmark.
--            [5] = The name of the generated output file. If blank, there is
--                  no file spliting being done.
--            [6] = Pointer to the Element sequence for this bookmark.
--            [7] = The name cleaned up for finding purposes
sequence vBookMarks = {}
public enum
	BM_TYPE,
	BM_POINTER,
	BM_NAME,
	BM_SUBCONTEXT_ID,
	BM_FILENAME,
	BM_ELEMENT_PTR,
	BM_CLEAN_NAME,  -- processed by find_bookmark
	BM_GETHEADINGS, -- BM_NAME..BM_ELEMENT_PTR
	BM_ELEMENTS, -- type='h' BM_NAME..BM_FILENAME
	             -- type='p' BM_POINTER..BM_ELEMENT_PTR
	$

-- Headings: This contains a list of headings found.
--    format: [1] = Depth (level)
--            [2] = Text (including numbering if applicable)
sequence vHeadings = {}
sequence vHeadingBMIndex = {}

public enum 
	H_DEPTH,
	H_TEXT

sequence vCodeColors

object vMacros

------------------------------------------------------------------------------
procedure init()
------------------------------------------------------------------------------
	
	vReparseHeading = ""
	vHostID = ""
	vProtocols = {
				"HTTP:",
				"FTP:",
				"FILE:",
				"HTTPS:",
				"SVN:",
				"GOPHER:",
				"IRC:",
				"NEWS:",
				"NTTP:",
				"MAILTO:"
				}

	vCodeColors = {
			"normal",
			"comment",
			"keyword",
			"builtin",
			"string",
			"bracket1",
			"bracket2",
			"bracket3",
			"bracket4",
			"bracket5"
			}

	set_colors({
			{"NORMAL", 1},
			{"COMMENT", 2},
			{"KEYWORD", 3},
			{"BUILTIN", 4},
			{"STRING", 5},
			{"BRACKET", {6, 7, 8, 9, 10}}
		})

	vUpperCase = "ESTRADIOBCFGHKLMNPUVWJYQZX"
	vLowerCase = lower(vUpperCase)
	vAllLetters = vUpperCase & vLowerCase
	vDigits    = "0123456789"
	vSpecialWordChars = "_"
	vWordChars = vAllLetters & vSpecialWordChars
	vNameChars  = vWordChars & vDigits
	vWhiteSpace = " \t"

	vPluginList = {}
	vBookMarks = {}
	vHeadings = {}
	vHeadingNums = {}
	vMacros = map:new()

--	object base_options = map:load_map( locate_file("creole.opts") )
--	if map(base_options) then
--		vProtocols = map:get( base_options, "protocols", vProtocols)
--		vCodeColors = map:get( base_options, "codecolors", vCodeColors)
--	end if

end procedure
init()

-- looks for a string of alphanumeric chars enclosed in parenthesis
-- If found, returns a sequence {START, END}
-- If not found, returns 0
------------------------------------------------------------------------------
function find_paren_end(sequence pText)
------------------------------------------------------------------------------
	integer lStart
	integer lEnd

	lStart = find('(', pText)
	if lStart = 0 then
		return 0
	end if
	
	lEnd = find(')', pText, lStart + 1)
	if lEnd = 0 then
		return 0
	end if
	if not t_alnum( pText[lStart+1 .. lEnd - 1]) then
		return 0
	end if
	
	return {lStart, lEnd}
end function

-- looks for the end of the current word.
-- If found, returns an integer with the index of the last character in the word.
------------------------------------------------------------------------------
function find_word(sequence pText, integer pStart = 1)
------------------------------------------------------------------------------
	for i = pStart to length(pText) do
		if not t_alnum(pText[i]) then
			return i - 1
		end if
	end for
	
	return length(pText)
end function


-- looks for common url formats: X.X.X and X.X.X.X
-- If found, returns a sequence {{START, END}, {word1_start, word1_end}, ..., {wordn_start, wordn_end}}
-- If not found, returns 0
------------------------------------------------------------------------------
function find_url(sequence pText, integer pStart)
------------------------------------------------------------------------------

	sequence lRes
	integer lStart
	integer lEnd
	integer lPos
	
	if length(pText) - pStart < 7 then
		-- The minimum length of any text to contain a valid URL is 7 characters.
		return 0 
	end if
	
	lPos = pStart - 1
	
	while lPos < length(pText) do
		lRes = {{0,0}}
		lStart = lPos
		-- Find first white space, then skip over it.
		for i = lPos + 1 to length(pText) do
			if t_space(pText[i]) then
				lPos = i
				exit
			end if
		end for
		if lPos = lStart then
			lPos += 1
		end if
		for i = lPos to length(pText) do
			if not t_space(pText[i]) then
				lPos = i
				exit
			end if
		end for
		if lPos = lStart then
			return 0
		end if
		
		while length(lRes) < 5 do
			lStart = lPos
			lEnd = find_word(pText, lStart)
	
			if lEnd < lStart then
				lEnd += 1
				exit  -- Not at the start of a word
			end if
			
			lRes = append(lRes, {lStart, lEnd})
			lPos = lEnd + 2
			
			if lEnd = length(pText) then
				exit -- Must be the last word 'cos we ran out of text.
			end if
			
			if not equal(pText[lEnd + 1], '.') then
				exit -- Found a terminating non-dot, so no more words.
			end if
			
			
		end while
	
		if length(lRes) < 4 or length(lRes) > 5 then
			lPos = lEnd
			continue
		end if
		
		return lRes
	end while
	
	return 0
end function


-- returns a string containing only characters in vNameChars and in pExtra.
------------------------------------------------------------------------------
function cleanup( sequence pText, sequence pExtra = "")
------------------------------------------------------------------------------
	integer lPos
	sequence lChars

	lChars = vNameChars & pExtra
	lPos = 0

	for i = 1 to length(pText) do
		if eu:find( pText[i], lChars) > 0 then
			lPos +=1
			if lPos < i then
				pText[lPos] = pText[i]
			end if
		end if
	end for
	
	if lPos != length(pText) then
		return lower(pText[1..lPos])
	else
		return lower(pText)
	end if
end function

ifdef UNITTEST then
test_equal("cleanup 1", "abcdefghi123", cleanup(" a(b)--c ** D !EFg `\thi 1.23$"))
test_equal("cleanup 2", "a(b)cdefghi123", cleanup(" a(b)--c ** D !EFg `\thi 1.23$", "()"))
end ifdef


-- Returns the index to the next character to be processed.
------------------------------------------------------------------------------
function find_eol(sequence pString, integer pFrom=1, integer pIgnoreComment = 0)
------------------------------------------------------------------------------
	integer lStart
	integer lEOL
	integer lLogEOL
	integer lEOS
	integer lFirstComment

	if pFrom > length(pString) then
		return pFrom
	end if

	if pFrom < 1 then
		lEOL = 1
	else
		lEOL = pFrom
	end if

	while lEOL <= length(pString) and pString[lEOL] != '\n' do
		lEOL += 1
	end while
	lLogEOL = lEOL
	if lEOL > length(pString) then
		lEOL -= 1
	end if

	if not pIgnoreComment then
		-- Backtrack to see if there is any comments on this line.
		lFirstComment = match("!!", pString[pFrom .. lEOL])
		if lFirstComment != 0 then
			lLogEOL = pFrom
			if lFirstComment != pFrom then
				while lLogEOL < lEOL do
					if lLogEOL > 1 and pString[lLogEOL-1] = '~' then
						lLogEOL += 1
						continue
					end if

					if pString[lLogEOL] = '!' then
						if pString[lLogEOL + 1] = '!' then
								exit
						end if
					end if
					lLogEOL += 1
				end while
			end if
		end if
	end if

	return lLogEOL
end function
ifdef UNITTEST then
test_equal("find_eol 1", 1, find_eol(""))
test_equal("find_eol 2", 2, find_eol("a\n"))
test_equal("find_eol 3", 4, find_eol("a  \n"))
test_equal("find_eol 4", 2, find_eol("a\n\n"))
test_equal("find_eol 5", 1, find_eol("\na\n"))
test_equal("find_eol 6", 3, find_eol("  \na\n"))
test_equal("find_eol 7", 1, find_eol("\n a \n"))
test_equal("find_eol 8", 6, find_eol("n a n"))
test_equal("find_eol 1a", 2, find_eol("", 2))
test_equal("find_eol 2a", 2, find_eol("a\n", 2))
test_equal("find_eol 3a", 4, find_eol("a  \n", 2))
test_equal("find_eol 4a", 2, find_eol("a\n\n", 2))
test_equal("find_eol 5a", 3, find_eol("\na\n", 2))
test_equal("find_eol 6a", 3, find_eol("  \na\n", 2))
test_equal("find_eol 7a", 5, find_eol("\n a \n", 2))
test_equal("find_eol 8a", 6, find_eol("n a n", 2))
test_equal("find_eol 1b", 1, find_eol("!!"))
test_equal("find_eol 2b", 2, find_eol("a!!\n"))
test_equal("find_eol 3b", 2, find_eol("a!!  \n"))
test_equal("find_eol 4b", 2, find_eol("a!!\n\n"))
test_equal("find_eol 5b", 1, find_eol("\n!!a\n"))
test_equal("find_eol 6b", 3, find_eol("  !!\na\n"))
test_equal("find_eol 7b", 1, find_eol("\n!! a \n"))
test_equal("find_eol 8b", 2, find_eol("n!! a n"))
end ifdef

------------------------------------------------------------------------------
function find_nonspace(sequence pString, integer pFrom = 1)
------------------------------------------------------------------------------
	if pFrom < 1 then
		pFrom = 1
	end if
	while pFrom <= length(pString) and eu:find(pString[pFrom]," \t") != 0 do
		pFrom += 1
	end while
	return pFrom
end function
ifdef UNITTEST then
test_equal("find_nonspace 1", 1, find_nonspace(""))
test_equal("find_nonspace 2", 4, find_nonspace("   "))
test_equal("find_nonspace 3", 4, find_nonspace("\t  "))
test_equal("find_nonspace 4", 1, find_nonspace("a\t  "))
test_equal("find_nonspace 5", 1, find_nonspace("a  "))
test_equal("find_nonspace 6", 1, find_nonspace("abc"))
test_equal("find_nonspace 7", 2, find_nonspace(" abc"))
test_equal("find_nonspace 8", 9, find_nonspace(" \t \t \t\t abc"))
test_equal("find_nonspace 1a", 3, find_nonspace("", 3))
test_equal("find_nonspace 2a", 4, find_nonspace("   ", 3))
test_equal("find_nonspace 3a", 4, find_nonspace("\t  ", 3))
test_equal("find_nonspace 4a", 5, find_nonspace("a\t  ", 3))
test_equal("find_nonspace 5a", 4, find_nonspace("a  ", 3))
test_equal("find_nonspace 6a", 3, find_nonspace("abc", 3))
test_equal("find_nonspace 7a", 3, find_nonspace(" abc", 3))
test_equal("find_nonspace 8a", 9, find_nonspace(" \t \t \t\t abc", 3))
end ifdef

------------------------------------------------------------------------------
function find_bookmark(sequence pBMText, sequence pDisplayText, sequence pContext, integer pHere, 
	object pNameSpace)
------------------------------------------------------------------------------
	sequence lCleanBMText
	sequence lCleanDisplayText
	sequence lCleanStored
	sequence lCleanStoredAlt
	sequence lPossibles = {}

	lCleanBMText = cleanup(pBMText)
	lCleanDisplayText = cleanup(pDisplayText)

	-- First, look through the bookmarks in the supplied context.
	-- Next, look through the bookmarks out of the supplied context.
	for x = 1 to 2 do
		for i = 1 to length(vBookMarks) do
			
			if sequence(vBookMarks[i][BM_POINTER]) then
				lCleanStoredAlt = cleanup(vBookMarks[i][BM_POINTER])
			else
				lCleanStoredAlt = ""
			end if
			if x = 1 then
				if not equal(vBookMarks[i][BM_SUBCONTEXT_ID], pContext) then
					continue
				end if
			else -- x = 2 
				if equal(vBookMarks[i][BM_SUBCONTEXT_ID], pContext) then
					continue
				end if
			end if
			if equal(pBMText, vBookMarks[i][BM_NAME]) then
				return i
			end if

			if (equal(vBookMarks[BM_FILENAME],pNameSpace) or atom(pNameSpace)) and
				equal(pDisplayText, vBookMarks[i][BM_NAME]) then
				return i
			end if
			
			if sequence( vBookMarks[i][BM_CLEAN_NAME] ) then
				lCleanStored = vBookMarks[i][BM_CLEAN_NAME]
			else
				lCleanStored = cleanup(vBookMarks[i][3])
				if lCleanStored[1] = '_' then
					integer pos
					pos = find_from('_', lCleanStored, 2)
					if pos != 0 then
						lCleanStored = lCleanStored[pos+1 .. $]
					end if
				end if
				vBookMarks[i][BM_CLEAN_NAME] = lCleanStored
			end if
			
			if equal(lCleanBMText, lCleanStored) then
				return i
			end if

			if equal(lCleanBMText, lCleanStoredAlt) then
				return i
			end if

			if length(lCleanDisplayText) > 0 then

				if equal(lCleanDisplayText, lCleanStored) then
					return i
				end if

				if equal(lCleanDisplayText, lCleanStoredAlt) then
					return i
				end if

-- 				if length(lCleanStored) - length(lCleanDisplayText) <= 4 then
-- 					if match(lCleanDisplayText, lCleanStored) then
-- 						lPossibles = append(lPossibles, {abs(i - pHere), length(lCleanStored) - length(lCleanDisplayText),lCleanStored, i})
-- 					end if
-- 				end if
-- 				if not equal(lCleanStoredAlt, lCleanStored) then
-- 					if length(lCleanStoredAlt) - length(lCleanDisplayText) <= 4 then
-- 						if match(lCleanDisplayText, lCleanStoredAlt) then
-- 							lPossibles = append(lPossibles, {abs(i - pHere),length(lCleanStoredAlt) - length(lCleanDisplayText), lCleanStoredAlt, i})
-- 						end if
-- 					end if
-- 				end if

				if match(lCleanDisplayText, lCleanStored) then
					lPossibles = append(lPossibles, {sim_index(lCleanDisplayText, lCleanStored), length(lCleanStored) - length(lCleanDisplayText),lCleanStored, i})
				end if
				if match(lCleanDisplayText, lCleanStoredAlt) then
					lPossibles = append(lPossibles, {sim_index(lCleanDisplayText, lCleanStoredAlt), length(lCleanStoredAlt) - length(lCleanDisplayText),lCleanStoredAlt, i})
				end if
			end if

			if not equal(lCleanBMText, lCleanDisplayText) then

				if equal(lCleanBMText, lCleanStored) then
					return i
				end if

				if equal(lCleanBMText, lCleanStoredAlt) then
					return i
				end if

-- 				if length(lCleanStored) - length(lCleanBMText) <= 4 then
-- 					if match(lCleanBMText, lCleanStored) then
-- 						lPossibles = append(lPossibles, {abs(i - pHere), length(lCleanStored) - length(lCleanBMText), lCleanStored, i})
-- 					end if
-- 				end if
-- 				if not equal(lCleanStoredAlt, lCleanStored) then
-- 					if length(lCleanStoredAlt) - length(lCleanBMText) <= 4 then
-- 						if match(lCleanBMText, lCleanStoredAlt) then
-- 							lPossibles = append(lPossibles, {abs(i - pHere), length(lCleanStoredAlt) - length(lCleanBMText), lCleanStoredAlt, i})
-- 						end if
-- 					end if
-- 				end if

				if match(lCleanBMText, lCleanStored) then
					lPossibles = append(lPossibles, {sim_index(lCleanBMText, lCleanStored), length(lCleanStored) - length(lCleanBMText),lCleanStored, i})
				end if
				
				if match(lCleanBMText, lCleanStoredAlt) then
					lPossibles = append(lPossibles, {sim_index(lCleanBMText, lCleanStoredAlt), length(lCleanStoredAlt) - length(lCleanBMText),lCleanStoredAlt, i})
				end if
			end if
		end for
	end for


	if length(lPossibles) = 0 then
		return 0
	end if
	if length(lPossibles) > 1 then
		lPossibles = sort_columns(lPossibles, {1, 2, -3})
	end if
	if vVerbose then
		printf(1, "assumed match '%s' with '%s'\n", {pBMText, lPossibles[1][3]})
	end if
	return lPossibles[1][4]
end function

------------------------------------------------------------------------------
function has_leading_chars(sequence pString, integer pFrom = 1, sequence pAllowed = " \t")
------------------------------------------------------------------------------
	pFrom -= 1

	while pFrom > 0 and eu:find(pString[pFrom], pAllowed) > 0 do
		pFrom -= 1
	end while

	if pFrom < 1 or pString[pFrom] = '\n' then
		return 1
	end if

	return 0

end function
ifdef UNITTEST then
test_equal("has_leading_chars 1", 1, has_leading_chars(" \tabc\t ", 1))
test_equal("has_leading_chars 2", 1, has_leading_chars(" \tabc\t ", 2))
test_equal("has_leading_chars 3", 1, has_leading_chars(" \tabc\t ", 3))
test_equal("has_leading_chars 4", 0, has_leading_chars(" \tabc\t ", 4))
test_equal("has_leading_chars 5", 0, has_leading_chars(" \tabc\t ", 5))
test_equal("has_leading_chars 6", 0, has_leading_chars(" \tabc\t ", 6))
test_equal("has_leading_chars 7", 0, has_leading_chars(" \tabc\t ", 7))
test_equal("has_leading_chars 8", 1, has_leading_chars(" \ta\nc\t ", 5))
test_equal("has_leading_chars 9", 0, has_leading_chars(" \ta\nc\t ", 6))
test_equal("has_leading_chars A", 1, has_leading_chars(" \ta\n\ta ", 6))
end ifdef

------------------------------------------------------------------------------
function has_trailing_chars(sequence pString, integer pFrom, sequence pAllowed = " \t")
------------------------------------------------------------------------------
	pFrom += 1
	while pFrom <= length(pString) and eu:find(pString[pFrom], pAllowed) > 0 do
		pFrom += 1
	end while

	if pFrom > length(pString) then
		return 1
	end if

	if pString[pFrom] = '\n' then
		return 1
	end if

	return 0

end function
ifdef UNITTEST then
test_equal("has_trailing_chars 1", 0, has_trailing_chars(" \tabc\t ", 1))
test_equal("has_trailing_chars 2", 0, has_trailing_chars(" \tabc\t ", 2))
test_equal("has_trailing_chars 3", 0, has_trailing_chars(" \tabc\t ", 3))
test_equal("has_trailing_chars 4", 0, has_trailing_chars(" \tabc\t ", 4))
test_equal("has_trailing_chars 5", 1, has_trailing_chars(" \tabc\t ", 5))
test_equal("has_trailing_chars 6", 1, has_trailing_chars(" \tabc\t ", 6))
test_equal("has_trailing_chars 7", 1, has_trailing_chars(" \tabc\t ", 7))
test_equal("has_trailing_chars 8", 0, has_trailing_chars(" \ta \n c\t ", 5))
test_equal("has_trailing_chars 9", 0, has_trailing_chars(" \ta \n c\t ", 6))
test_equal("has_trailing_chars A", 1, has_trailing_chars(" \ta \na \n", 6))
test_equal("has_trailing_chars B", 1, has_trailing_chars("\n", 1))
end ifdef


------------------------------------------------------------------------------
function compare_prev(sequence pSubString, sequence pString, integer pFrom)
------------------------------------------------------------------------------
	integer lLen

	if length(pSubString) = 0 then
		return 0
	end if

	if atom(pSubString[1]) then
		pSubString = {pSubString}
	end if

	for i = 1 to length(pSubString) do
		lLen = length(pSubString[i])
		if pFrom > lLen then
			if equal(upper(pString[pFrom - lLen .. pFrom - 1]), upper(pSubString[i])) then
				return i
			end if
		end if
	end for
	return 0
end function

------------------------------------------------------------------------------
function compare_next(sequence pSubString, sequence pString, integer pFrom)
------------------------------------------------------------------------------
	integer lLen

	if length(pSubString) = 0 then
		return 0
	end if

	if atom(pSubString[1]) then
		pSubString = {pSubString}
	end if

	for i = 1 to length(pSubString) do
		lLen = length(pSubString[i])
		if pFrom + lLen <= length(pString) then
			if equal(upper(pString[pFrom + 1 .. pFrom + lLen]), upper(pSubString[i])) then
				return i
			end if
		end if
	end for
	return 0
end function

------------------------------------------------------------------------------
function compare_begin(sequence pSubString, sequence pString)
------------------------------------------------------------------------------
	if length(pSubString) = 0 then
		return 0
	end if

	return compare_next(pSubString, pString, 0)
end function

------------------------------------------------------------------------------
function compare_end(sequence pSubString, sequence pString)
------------------------------------------------------------------------------
	integer lLen

	if length(pSubString) = 0 then
		return 0
	end if

	if atom(pSubString[1]) then
		pSubString = {pSubString}
	end if

	for i = 1 to length(pSubString) do
		lLen = length(pSubString[i]) - 1
		if length(pString) > lLen then
			if equal(upper(pString[$ - lLen .. $ ]), upper(pSubString[i])) then
				return i
			end if
		end if
	end for
	return 0
end function

------------------------------------------------------------------------------
function get_to_eol(sequence pString, integer pFrom, integer pTrimmed = 1)
------------------------------------------------------------------------------
	integer lPos
	integer lEndPos
	sequence lText

	if pFrom > length(pString) then
		return {pFrom, ""}
	end if
	lEndPos = find_eol(pString, pFrom)
	lPos = lEndPos - 1

	lText = pString[pFrom .. lPos]
	if pTrimmed then
		lText = trim(lText)
	end if
	return {lEndPos, lText}
end function
ifdef UNITTEST then
test_equal("get_to_eol 1", {9, "ab cd ef"}, get_to_eol("ab cd ef\ngh hi\n\n", 1))
test_equal("get_to_eol 2", {9, ""}, get_to_eol("ab cd ef\ngh hi\n\n", 9))
test_equal("get_to_eol 3", {15, "gh hi"}, get_to_eol("ab cd ef\ngh hi\n\n", 10))
test_equal("get_to_eol 4", {15, ""}, get_to_eol("ab cd ef\ngh hi\n\n", 15))
test_equal("get_to_eol 5", {25, ""}, get_to_eol("ab cd ef\ngh hi\n\n", 25))
test_equal("get_to_eol 6", {13, "  ab cd ef\t\t"}, get_to_eol("  ab cd ef\t\t\ngh hi\n\n", 1, 0))
end ifdef

-- This returns a Logical line. This can span multiple physical lines.
-- A logical line ends when it finds a physical line that begins with one
-- of the FrontDelim entries or a physical line that ends with one of the
-- BackDelim entries, or a blank line.
-- This also returns an index to the next character after the logical line.

------------------------------------------------------------------------------
function get_logical_line(sequence pString, integer pFrom, sequence pFrontDelim, sequence pBackDelim, integer pTrimmed = 1)
------------------------------------------------------------------------------
	sequence lNewLine
	integer lPos
	integer lNewPos
	sequence lLine

	lLine = ""
	lPos = pFrom
	while 1 do
		lNewLine = get_to_eol(pString, lPos, pTrimmed)
		if length(lNewLine[2]) > 0 then
			lNewPos = lNewLine[1]
			lNewLine = lNewLine[2]
			if length(pFrontDelim) > 0 and compare_begin(pFrontDelim, lNewLine) > 0 then
				-- This line begins with a delimiter so is the start of the next logical line.
				if length(lLine) > 0 then
					-- We don't update the next position so this line is re-read
					-- in the next iteration.
					exit
				else
					lLine = lNewLine
					lPos = lNewPos+1
				end if
			else
				-- The line is a continuaton of the previous cell.
				lPos = lNewPos + 1
				if length(lLine) > 0 then
					lLine &= '\n'
				end if
				lLine &= lNewLine
			end if

			if length(pBackDelim) > 0 and compare_end(pBackDelim, lLine) > 0 then
				-- We got a completed logical line.
				exit
			end if
		else
			-- A blank line signals the end of a logical line.
			exit
		end if
	end while

	return {lPos, lLine}
end function

------------------------------------------------------------------------------
procedure add_bookmark(integer pType, object pTypeLink, sequence pText)
------------------------------------------------------------------------------
	sequence lNewBM
	integer lElement_No
	integer lBM_No

	lElement_No = length(vElements) + 1
	lBM_No = length(vBookMarks) + 1
	if length(vOutputFile) > 0 then
		lNewBM =  {pType, pTypeLink, pText, vCurrentContext, vOutputFile[$], lElement_No, 0, 0, 0}
	else
		lNewBM =  {pType, pTypeLink, pText, vCurrentContext, "", lElement_No, 0, 0, 0}
	end if
	
	lNewBM[BM_GETHEADINGS] = lNewBM[BM_NAME..BM_ELEMENT_PTR]
	if pType = 'h' then
		lNewBM[BM_ELEMENTS] = lNewBM[BM_NAME..BM_FILENAME]
	else
		lNewBM[BM_ELEMENTS] = lNewBM[BM_POINTER..BM_ELEMENT_PTR]
	end if
	vBookMarks = append(vBookMarks, lNewBM)
	vElements = append(vElements, {'b', lBM_No})
end procedure

------------------------------------------------------------------------------
function Generate_Final( integer pAction, sequence pParms = {})
------------------------------------------------------------------------------
	sequence lText

	lText = call_func(vFinal_Generator_rid, {pAction, pParms, vCurrentContext})

	return lText
end function

------------------------------------------------------------------------------
function get_camel_case(sequence pRawText, atom pFrom)
------------------------------------------------------------------------------
	sequence lText
	integer lPos
	integer lChar
	integer lUC
	integer lLC
	integer lDigits
	integer lLast

	-- CamelCase words are ...
	--     Begin with Upper case
	--     Must more than one upper case
	--     Second upper case must be after first lower case
	--     Must have at least one lower case
	--     Can have digits but only after the first lower case
	--     Last must either lowercase or digit
	--     Cannot be prefixed by '.'
	--  e.g.
	--     AbCa (yes)
	--     AbC  (no)
	--     AbC2 (yes)
	--     ABc  (no)
	--     A22  (no)
	--     Abcd (no)
	--     AbcdEgh (yes)
	--     AbcdE12 (yes)

	if not vAllowCamelCase then
		return {-2}
	end if

	if pFrom > 1 then
		if pRawText[pFrom - 1] = '~' then
			return {-1} -- Escaped CamelCase
		end if
		if pRawText[pFrom - 1] = '.' then
			return {-1} -- Dot prefixed
		end if
	end if

	lText = ""
	lUC = 0
	lPos = pFrom
	lLC = 0
	lDigits = 0
	lLast = 0
	while lPos <= length(pRawText) do
		lChar = pRawText[lPos]
		if eu:find(lChar, vUpperCase) > 0 then
			if (lPos = pFrom) or (lLC > 0) then
				lText &= lChar
				lUC += 1
				lLast = 0
			else
				exit
			end if
		elsif eu:find(lChar, vLowerCase) > 0 then
			if lUC > 0 then
				lText &= lChar
				lLC += 1
				lLast = 1
			else
				exit
			end if
		elsif eu:find(lChar, vDigits) > 0 then
			if lLC > 0 then
				lText &= lChar
				lDigits += 1
				lLast = 1
			else
				exit
			end if
		else
			exit
		end if

		lPos += 1
	end while

	if length(lText) = 0 or
		lLast = 0 or
		lLC < 1 or
		lUC < 2
	then
		return {-1} -- Not a camel case word.
	end if

	return {lPos - 1, lText}
end function

------------------------------------------------------------------------------
function get_plugin(sequence pRawText, atom pFrom)
------------------------------------------------------------------------------
	sequence lText
	integer lEndPos
	integer lPos
	sequence lNameChars
	sequence lPluginName
	sequence lPluginParms
	sequence lPluginKV

	lPos = pFrom + 2
	lEndPos = match_from(">>", pRawText, lPos)
	if lEndPos = 0 then
		return {0, lPos - 1, "<<"}
	end if

	lText = trim(pRawText[lPos .. lEndPos - 1])
	if length(lText) = 0 then
		return {0, lEndPos + 1, "<<>>"}
	end if

	-- Grab plugin name
	lPos = 1
	while lPos <= length(lText) do
		if eu:find(lText[lPos], vNameChars) = 0 then
			exit
		end if
		lPos += 1
	end while
	lPluginName = lText[1 .. lPos - 1]
	if length(lPluginName) = 0 then
		return {0, lEndPos + 1, "<<"}
	end if

	-- Get parms
	lPluginKV = keyvalues(lText[lPos .. $])

	-- Build Param Text
	lPluginParms = lPluginName & -1
	for i = 1 to length(lPluginKV) do
		if length(lPluginKV[i]) = 2 then
			lPluginParms &= lower(lPluginKV[i][1]) & -2
			lPluginParms &= lPluginKV[i][2] & -1
		end if
	end for

	return {1, lEndPos + 1, lPluginParms[1 .. $ - 1]}
end function

------------------------------------------------------------------------------
function get_options(sequence pRawText, atom pFrom)
------------------------------------------------------------------------------
	sequence lText
	integer lEndPos
	integer lPos
	sequence lValue
	sequence lKV

	lText = get_to_eol(pRawText, pFrom + 2)
	lEndPos = lText[1]

	lKV = keyvalues(lText[2])
	
	lText = ""
	for i = 1 to length(lKV) do
		switch lower(lKV[i][1]) do
			case "maxnumlevel" then
				lValue = value(lKV[i][2])
				if lValue[1] = GET_SUCCESS and floor(lValue[2]) >= 0 then
					vMaxNumLevel = floor(lValue[2])
				end if

			case "uppercase" then
				vUpperCase = lKV[i][2]

			case "lowercase" then
				vLowerCase = lKV[i][2]

			case "digits" then
				vDigits = lKV[i][2]

			case "specialwordchars" then
				vSpecialWordChars = lKV[i][2]

			case "style" then
				vStyle = append(vStyle,lKV[i][2])

			case "codecolors" then
				lValue = lKV[i][2]
				for j = 1 to length(lValue) do
					lPos = eu:find(lower(lValue[j][1]), {
						"normal", "comment", "keyword", "builtin", "string",
						"bracket1", "bracket2", "bracket3", "bracket4", "bracket5"
							})

					if lPos > 0 then
						vCodeColors[lPos] = lValue[j][2]
					end if
				end for

			case "protocols" then
				vProtocols = upper(lKV[i][2])
				for j = 1 to length(vProtocols) do
					if vProtocols[j][$] != ':' then
						vProtocols[j] &= ':'
					end if
				end for

			case "splitlevel" then
				if vExplicitOutput = 0 then
					lValue = value(lKV[i][2])
					if lValue[1] = GET_SUCCESS and floor(lValue[2]) >= 0 then
						if vSplitLevel = 0 then
							vOutputFile = append(vOutputFile, sprintf("%s_%04d", {vSplitName, length(vOutputFile)+1}))
						end if
						vSplitLevel = floor(lValue[2])
					end if
				end if

			case "output" then
				sequence tempfn = lKV[i][2]
				vExplicitOutput = 1
				if length(tempfn) > 0 then
					tempfn = match_replace('/', tempfn, '_') -- Unix style delim
					tempfn = match_replace('\\', tempfn, '_') -- Windows style delim
					tempfn = match_replace('.', tempfn, '_')
					tempfn = match_replace('<', tempfn, '_')
					tempfn = match_replace('>', tempfn, '_')
					ifdef WINDOWS then
							tempfn = match_replace('?', tempfn, '_')
							tempfn = match_replace('*', tempfn, '_')
							tempfn = match_replace(':', tempfn, '_')
					end ifdef
					
					vOutputFile = append(vOutputFile, tempfn)
					if length(vOutputFile) > 1 then
						lText = {TAG_ENDPARA, TAG_ENDFILE}
					end if
				end if
											
			case "splitname" then
				if vExplicitOutput = 0 then
					vSplitName = lKV[i][2]
				end if

			case "disallow" then
				for j = 1 to length(lKV[i][2]) do
					switch lower(lKV[i][2][j]) do
					case "bold" then
						vAllowedDecorations = seq:remove_all('*', vAllowedDecorations)

					case "italic" then
						vAllowedDecorations = seq:remove_all('/', vAllowedDecorations)

					case "monospace" then
						vAllowedDecorations = seq:remove_all('#', vAllowedDecorations)

					case "underline" then
						vAllowedDecorations = seq:remove_all('_', vAllowedDecorations)

					case "superscript" then
						vAllowedDecorations = seq:remove_all('^', vAllowedDecorations)

					case "subscript" then
						vAllowedDecorations = seq:remove_all(',', vAllowedDecorations)

					case "strikethru" then
						vAllowedDecorations = seq:remove_all('-', vAllowedDecorations)

					case "insert" then
						vAllowedDecorations = seq:remove_all('+', vAllowedDecorations)

					case "camelcase" then
						vAllowCamelCase = 0

					end switch
				end for

			case "allow" then
				for j = 1 to length(lKV[i][2]) do
					switch lower(lKV[i][2][j]) do
					case "bold" then
						vAllowedDecorations = seq:add_item('*', vAllowedDecorations)

					case "italic" then
						vAllowedDecorations = seq:add_item('/', vAllowedDecorations)

					case "monospace" then
						vAllowedDecorations = seq:add_item('#', vAllowedDecorations)

					case "underline" then
						vAllowedDecorations = seq:add_item('_', vAllowedDecorations)

					case "superscript" then
						vAllowedDecorations = seq:add_item('^', vAllowedDecorations)

					case "subscript" then
						vAllowedDecorations = seq:add_item(',', vAllowedDecorations)

					case "strikethru" then
						vAllowedDecorations = seq:add_item('-', vAllowedDecorations)

					case "insert" then
						vAllowedDecorations = seq:add_item('+', vAllowedDecorations)

					case "camelcase" then
						vAllowCamelCase = 1

					end switch
				end for

		end switch
	end for

	return {lEndPos - 1, lText}
end function

------------------------------------------------------------------------------
function get_macro_definition(sequence pRawText, atom pFrom)
------------------------------------------------------------------------------
	sequence lText
	integer lEndPos
	integer lPos
	sequence lMacroName
	sequence lMacroDefn
	sequence lNameChars

	lPos = pFrom + 3
	lEndPos = match_from(")@", pRawText, lPos)
	if lEndPos = 0 then
		return {0, lPos - 1, "@@("}
	end if

	lText = trim(pRawText[lPos .. lEndPos - 1])
	if length(lText) = 0 then
		return {0, lEndPos + 1, "@@()@"}
	end if

	-- Grab macro name
	lPos = 1
	while lPos <= length(lText) do
		if eu:find(lText[lPos], vNameChars) = 0 then
			exit
		end if
		lPos += 1
	end while
	lMacroName = upper(lText[1 .. lPos - 1])
	if length(lMacroName) = 0 then
		return {0, lEndPos + 1, "@@("}
	end if

	-- Get definition
	lMacroDefn = trim(lText[lPos + 1 .. $])

	return {1, lEndPos + 1, lMacroName, lMacroDefn}
end function

------------------------------------------------------------------------------
function get_macro_usage(sequence pRawText, atom pFrom, sequence pRecurse)
------------------------------------------------------------------------------
	integer lEndPos
	integer lStartPos
	integer lPos
	integer lChar
	integer lLevel
	integer lQuote
	integer lInWord
	integer lArg
	sequence lText
	sequence lValue
	sequence lMacroName
	sequence lMacroDefn
	sequence lMacroArgs
	sequence lMacroText
	sequence lNameChars
	sequence lRest


	lPos = pFrom + 3
	lLevel = 1
	lText = ""
	lQuote = 0
	while lLevel > 0 and lPos <= length(pRawText) do
		lChar = pRawText[lPos]

		if eu:find(lChar, "\"'`") != 0 then
			if lChar = lQuote then
				-- End of quoted span
				lQuote = 0
				lChar = -1
			elsif lQuote = 0 then
				-- Start of quoted span
				lQuote = lChar
				lChar = -1
			end if
		elsif lChar = '(' then
			lLevel += 1
		elsif lChar = ')' then
			lLevel -= 1
			if lLevel = 0 then
				lChar = -1
			end if
		end if

		if lChar > 0 then
			lText &= lChar
		end if

		lPos += 1
	end while

	lEndPos = lPos
	lText = trim(lText)
	if length(lText) = 0 then
		return {lEndPos + 1, "$$("}
	end if

	-- Grab macro name
	lPos = 1
	while lPos <= length(lText) do
		if eu:find(lText[lPos], vNameChars) = 0 then
			exit
		end if
		lPos += 1
	end while
	lMacroName = upper(lText[1 .. lPos - 1])
	if length(lMacroName) = 0 then
		return {lEndPos + 1, "$$("}
	end if

	-- Get Arguments
	lMacroText = trim(lText[lPos .. $])
	lMacroArgs = {lMacroText}
	lPos = 1
	lQuote = 0
	lInWord = 0
	lText = ""
	lRest = ""
	while lPos <= length(lMacroText) do
		lChar = lMacroText[lPos]
		if length(lMacroArgs) > 1 then
			lRest &= lChar
		end if
		if eu:find(lChar, "\"'`") != 0 then
			if lChar = lQuote then
				-- End of quoted span
				lQuote = 0
				lChar = -1
			elsif lQuote = 0 then
				-- Start of quoted span
				lQuote = lChar
				lChar = -1
			end if
		elsif not lQuote then
			if eu:find(lChar, " \t\n") > 0 then
				lChar = -1
				if lInWord then
					lInWord = 0
					if length(lText) > 0 then
						lMacroArgs = append(lMacroArgs, lText)
						lText = ""
					end if
				end if
			end if
		end if

		if lChar > 0 then
			lInWord = 1
			lText &= lChar
		end if

		lPos += 1
	end while
	if length(lText) > 0 then
		lMacroArgs = append(lMacroArgs, lText)
	end if
	lMacroArgs = append(lMacroArgs, trim(lRest))

	-- Get definition
	lMacroDefn = map:get(vMacros, lMacroName, lMacroText)

	-- Replace any parameters in the definition with data from the arguments.
	lPos = 1
	while lPos <= length(lMacroDefn) do
		if lMacroDefn[lPos] = '$' then
			if lPos = 1 or lMacroDefn[lPos-1] != '$' then
				if lPos < length(lMacroDefn) and lMacroDefn[lPos + 1] = '(' then
					-- Found a parameter, so extract it for examination.
					lStartPos = lPos
					lText = ""
					lPos += 2
					while lPos <= length(lMacroDefn) and lMacroDefn[lPos] != ')' do
						lText &= lMacroDefn[lPos]
						lPos += 1
					end while
					lText = trim(lText)

					-- Now see what sort of parameter we got.
					if equal(lText, "+") then
						lValue = lMacroArgs[$]

					elsif equal(lText, "$") then
						lValue = lMacroArgs[$-1]
					else
						lValue = value(lText)
						if lValue[1] = GET_SUCCESS then
							lArg = lValue[2] + 1
							if lArg >= 1 and lArg <= length(lMacroArgs) - 1 then
								lValue = lMacroArgs[lArg]
							else
								lValue = ""
							end if
						else
							lValue = ""
						end if
					end if
					lMacroDefn = lMacroDefn[1 .. lStartPos - 1] &
								 lValue &
								 lMacroDefn[lPos + 1 .. $]
					lPos += length(lValue) - (lPos - lStartPos + 1)
				end if
			end if
		end if
		lPos += 1

	end while


	-- Avoid endless recursion, so only recurse if the previous input is
	-- different from the next input.
	if not equal(pRecurse, lMacroDefn) then
		lMacroDefn = call_func(vMacro_Processor_rid, {lMacroDefn, lMacroDefn})
	else
		lMacroDefn = ""
	end if

	return {lEndPos-1 , lMacroDefn}
end function

------------------------------------------------------------------------------
function get_passthru(sequence pRawText, atom pFrom)
------------------------------------------------------------------------------
	sequence lText
	integer lEndPos
	integer lStartPos
	integer lNewPos
	integer lFoundEnd

	lStartPos = pFrom + 2
	lEndPos = lStartPos
	loop do
		lEndPos = match_from("``", pRawText, lEndPos + 1)
		lFoundEnd = 1

		if lEndPos = 0 then
			-- Missing end-of-nowiki tag so return begining tag as literal text.
			return {lStartPos-1, "``"}
		end if

		if pRawText[lEndPos - 1] = '~' then
			lFoundEnd = 0 -- because end tag not at start of a line.
		end if
		until lFoundEnd = 1
	end loop

	lNewPos = lEndPos + 2
	while lNewPos <= length(pRawText) and pRawText[lNewPos] = '`' do
		lNewPos += 1
	end while
	lEndPos = lNewPos - 2

	lText = pRawText[lStartPos .. lEndPos - 1]
	-- Convert any escaped `` tags
	lText = search:match_replace("~``", lText, "``")

	lText = Generate_Final(PassThru, lText)
	return {lNewPos-1, lText}
end function

------------------------------------------------------------------------------
function get_heading(sequence pRawText, atom pFrom)
------------------------------------------------------------------------------
	sequence lText
	sequence lNums
	integer lLevel
	integer lStartPos
	integer lChar
	sequence lBookMark
	sequence lAliasText

	lLevel = 0
	lStartPos = 0
	lText = ""
	pFrom -= 1

	-- Find start of actual text + calculate level.
	while pFrom < length(pRawText) do
		pFrom += 1
		lChar = pRawText[pFrom]
		if lChar = '=' then
			lLevel += 1
		else
			exit
		end if

	end while

	-- Collect text until optional ending '=' or newline, which ever is first.
	lStartPos = pFrom
	while pFrom < length(pRawText) do
		pFrom += 1
		lChar = pRawText[pFrom]
		if lChar = '=' or lChar = '\n' then
			lText = pRawText[lStartPos .. pFrom-1]
			exit
		end if

	end while

	-- Remove rest of line
	lAliasText = ""
	while lChar != '\n' and pFrom < length(pRawText) do
		lAliasText &= lChar
		pFrom += 1
		lChar = pRawText[pFrom]
	end while
	lAliasText = cleanup(lAliasText)

	if length(vReparseHeading) != 0 then
		lText = call_func(vParser_rid, {lText, 1})
	end if
	lText = trim(lText)

	if length(vHeadingNums) < lLevel then
		vHeadingNums &= repeat(0, lLevel - length(vHeadingNums))
	end if
	vHeadingNums[lLevel] += 1
	for i = lLevel + 1 to length(vHeadingNums) do
		vHeadingNums[i] = 0
	end for
	lNums = ""
	if lLevel <= vMaxNumLevel then
		for i = 1 to lLevel do
			lNums &= sprintf("%d", vHeadingNums[i])
			if i < lLevel then
				lNums &= "."
			else
				lNums &= " "
			end if
		end for
	end if

	vHeadings = append(vHeadings, {lLevel, lNums & lText})
	lBookMark = sprintf("_%d_%s", {length(vBookMarks), cleanup(lText)})
	
	lText = Generate_Final(Comment, vRawContext) &
	        Generate_Final(Bookmark, lBookMark)  &
	        Generate_Final(Heading, {lLevel, lNums & lText})
	if vExplicitOutput = 0 and vSplitLevel > 0 and lLevel <= vSplitLevel then
		lText = TAG_ENDFILE & lText
		vOutputFile = append(vOutputFile, sprintf("%s_%04d", {vSplitName, length(vOutputFile)+1}))
	end if

	add_bookmark('h', length(vHeadings), lBookMark)
	vHeadingBMIndex = append(vHeadingBMIndex, length(vBookMarks))
	
	if length(lAliasText) > 0 then
		lBookMark = sprintf("_%d_%s", {length(vBookMarks), lAliasText})
		add_bookmark('h', length(vHeadings), lBookMark)
	end if
	
	return {pFrom-1, lText}
end function

------------------------------------------------------------------------------
function get_decoration(sequence pRawText, atom pFrom)
------------------------------------------------------------------------------
	sequence lText
	integer lStartPos
	integer lEndPos
	integer lChar
	integer lType

	if pFrom > length(pRawText) then
		return {pFrom, ""}
	end if

	-- Entry has pFrom at first char after lead-in tag.
	lStartPos = 0
	lEndPos = -1
	lText = ""
	lType = pRawText[pFrom]
	if not eu:find(lType, vAllowedDecorations) then
		return {pFrom, {lType}}
	end if

	-- Collect text until ending double-type or double-newline, which ever is first.
	lStartPos = pFrom + 2
	pFrom += 1

	while pFrom < length(pRawText) do
		pFrom += 1
		lChar = pRawText[pFrom]
		if lChar = lType then
			if lType = '/' then -- Special handling for italic for URLs
				if compare_next({"/"}, pRawText, pFrom) > 0 and
				   compare_prev(vProtocols, pRawText, pFrom) > 0 then
					pFrom += 1
					continue
				end if
			end if

			lEndPos = pFrom
			while lEndPos < length(pRawText) do
				lEndPos += 1
				lChar = pRawText[lEndPos]
				if lChar != lType then exit end if
			end while

			if lEndPos = pFrom then
				continue
			end if

			if pRawText[lEndPos] != lType then
				if lEndPos = pFrom + 1 then
					continue
				end if
				lEndPos -= 1
			end if
			lText = pRawText[lStartPos .. lEndPos-2]
			pFrom = lEndPos
			exit

		elsif lChar = '\n' then
			if has_trailing_chars(pRawText, pFrom + 1) then
				lEndPos = pFrom - 1
				lText = pRawText[lStartPos .. lEndPos]
				pFrom -= 1
				exit
			end if

		end if

	end while

	if lEndPos = -1 then
		-- No matching end tag, so beginning tag is not to be used as a tag
		lText = {lType, lType}
		if lStartPos <= length(pRawText) then
			pFrom = lStartPos - 1
		else
			pFrom = lStartPos
		end if
	elsif length(lText) > 0 then
			lText = call_func(vParser_rid, {lText, 1})
			lType = eu:find(lType, kDecorTag)
			lText = Generate_Final(kDecorAction[lType], {lText})
	end if
	return {pFrom, lText}
end function


------------------------------------------------------------------------------
function get_definitionlist(sequence pRawText, atom pFrom)
------------------------------------------------------------------------------
	integer lStartDef
	integer lStartTerm
	integer lEndDef
	integer lEndTerm
	integer lLastItem
	sequence lTerm
	sequence lDef
	sequence lItems
	integer lChar
	sequence lText
	sequence lExtract

	lText = ""
	lStartTerm = 0
	lStartDef = 0
	lEndTerm = 0
	lEndDef = 0
	lLastItem = 0
	lItems = {}
	pFrom -= 1

	while pFrom <= length(pRawText) do
		if pFrom < length(pRawText) then
			pFrom += 1
			lChar = pRawText[pFrom]
			switch lChar label "EachChar" do
				case ';' then
					if has_leading_chars(pRawText, pFrom) then
						if lStartDef != 0 then
							-- A new item is starting, so close off the previous one.
							pFrom -= 1
							lEndDef = pFrom
						else
							if lStartTerm = 0 then
								-- Start collecting the term text
								lStartTerm = pFrom + 1
							else
								-- No definition for the term!
								pFrom -= 1
								lEndTerm = pFrom
								lStartDef = pFrom
								lEndDef = lStartDef - 1
							end if
						end if
					end if
					break

				case ':' then
					if lStartDef = 0 then
						if has_trailing_chars(pRawText, pFrom) then
							-- Don't treat this as the start of the term's definition.
							break "EachChar"
						end if

						if lStartTerm = 0 then
							-- No term but we have a definition starting!
							pFrom -= 1
							lStartTerm = pFrom
							lEndTerm = lStartDef - 1
						else
							-- We have a term so now we start collecting definition text.
							lEndTerm = pFrom - 1
							lStartDef = pFrom + 1
						end if
					end if
					break

				case '\n' then
					if pFrom < length(pRawText) then
						if has_trailing_chars(pRawText, pFrom) then
							lLastItem = pFrom
						end if
					else
						lLastItem = pFrom
					end if

					break

				case '~' then
					if pFrom < length(pRawText) then
						-- skip over next character.
						pFrom += 1
					end if
					break

				case '`' then
					if pFrom < length(pRawText) then
						if pRawText[pFrom+1] = '`' then
							-- skip over passthru text
							lExtract = get_passthru(pRawText, pFrom)
							pFrom = lExtract[1]
						end if
					end if
					break

				case else
					break
			end switch
		else
			lLastItem = pFrom
		end if

		if lLastItem then
			-- The item is followed by a blank line, so end the list
			if lStartTerm > 0 and lEndTerm = 0 then
				lEndTerm = pFrom-1
			end if
			if lStartDef > 0 and lEndDef = 0 then
				lEndDef = pFrom-1
			end if
		end if

		if lEndDef != 0 and lEndTerm != 0 then
			-- Got it all now.
			lTerm = trim(pRawText[lStartTerm .. lEndTerm])
			lDef  = trim(pRawText[lStartDef .. lEndDef])
			lItems = append(lItems,
				{call_func(vParser_rid, {lTerm, 1}),
				 call_func(vParser_rid, {lDef, 1})
				 })
			lStartTerm = 0
			lStartDef = 0
			lEndTerm = 0
			lEndDef = 0
		end if

		if lLastItem != 0 then
			exit
		end if
	end while

	if length(lItems) > 0 then
		lText = Generate_Final(DefinitionList, lItems)
	end if

	return {pFrom, lText}
end function

------------------------------------------------------------------------------
function get_eucode(sequence pRawText, atom pFrom)
------------------------------------------------------------------------------
	integer lEndPos
	integer lStartPos
	integer lFinal
	integer lEndCode
	sequence lColorSegments
	sequence lText
	sequence lLine
	object lPattern
	integer leadline

	syncolor:reset()

	pFrom += length("<eucode>")

	lFinal = eu:match("</eucode>", pRawText, pFrom)
	if lFinal = 0 then
		lFinal = eu:match("\n\n", pRawText, pFrom)
		if lFinal = 0 then
			lEndCode = length(pRawText)
			lFinal = length(pRawText) + 1
		else
			lEndCode = lFinal
			lFinal += 2
		end if
	else
		lEndCode = lFinal
		lFinal += length("</eucode>")
	end if

	if lFinal > 0 then

		lEndPos = pFrom
		if lEndPos <= length(pRawText) then
			if pRawText[lEndPos] = '\n' then
				lEndPos += 1
			end if
		end if
		lStartPos = lEndPos

		lText = ""
		lLine = ""
		leadline = 1
		while lEndPos < lEndCode do
			if pRawText[lEndPos] = '\n' then
				lLine = pRawText[lStartPos .. lEndPos]
			elsif (lEndPos + 1 = lEndCode) then
				lLine = pRawText[lStartPos .. lEndPos] & '\n'
			end if
			if leadline and length(lLine) > 0 then
				lStartPos = lEndPos + 1
				lLine = trim(lLine)
				leadline = 0
			end if
			lEndPos += 1
			if length(lLine) > 0 then
				lColorSegments = SyntaxColor(lLine)
				for i = 1 to length(lColorSegments) do
						if length(trim(lColorSegments[i][2])) > 0 then
							lText &= Generate_Final(ColorText,
										{vCodeColors[lColorSegments[i][1]],
										 Generate_Final(Sanitize, { 1, lColorSegments[i][2] })})
						else
							lText &= lColorSegments[i][2]
						end if
				end for
				lText &= '\n'
				lStartPos = lEndPos

				lLine = ""
			end if

		end while
		lText = TAG_ENDPARA & Generate_Final(CodeExample, {lText}) & TAG_STARTPARA
	else
		lText = ""
		lFinal = pFrom
	end if
	return {lFinal - 1, lText}
end function

------------------------------------------------------------------------------
function get_list(sequence pRawText, atom pFrom)
------------------------------------------------------------------------------
	sequence lText
	integer lStartPos
	integer lEndPos
	integer lNextPos

	integer lHead
	integer lTail
	integer lStartOrdered = -1
	integer lEndOrdered = -11
	integer lStartUnordered = -2
	integer lEndUnordered = -12
	integer lStartItem = -3
	integer lEndItem = -13
	integer lNewLevel
	integer lCurLevel
	integer lType
	sequence lCodeStack
	integer lCode
	sequence lLine
	sequence lNextLine
	integer lPos
	sequence lInItem = {}

	lStartPos = 0
	lEndPos = 0
	lCurLevel = 0
	lText = ""
	lCodeStack = {}
	lLine = ""

	lNextPos = pFrom
	while 1 do
		lLine = get_logical_line(pRawText, lNextPos, vLineBeginings, {})
		if length(lLine[2]) = 0 then
			-- A blank line signals the end of the list block
			lEndPos = lNextPos - 1
			exit
		end if
		
		if eu:find(lLine[2][1], "#*") = 0 then
			-- A line not starting with a list tag signals the end of the list block.
			lEndPos = lNextPos - 1
			exit
		end if
		
		lNextPos = lLine[1]
		lLine = lLine[2]

		-- Count level
		lNewLevel = 0
		lType = lLine[1]
		lPos = 1
		while lPos <= length(lLine) and lLine[lPos] = lType do
			lNewLevel += 1
			lPos += 1
		end while

		-- What type of list have we got
		if lType = '#' then
			lCode = 'o' -- Ordered List
			lHead = lStartOrdered
			lTail = lEndOrdered
		else
			lCode = 'u' -- Unordered List
			lHead = lStartUnordered
			lTail = lEndUnordered
		end if

		-- Start/End levels
		if lNewLevel > lCurLevel then
			-- Going up to a new level
			while lNewLevel > lCurLevel do
				if length(lInItem) > 0 then
					if lInItem[$] = 0 then
						lText &= lStartItem
						lInItem[$] = 1
					end if
				end if
				lText &= lHead
				lInItem &= 0
				lCurLevel += 1
				lCodeStack &= lTail				
			end while

		elsif lNewLevel < lCurLevel then
			-- Going back to a lower level
			while lNewLevel < lCurLevel do
				lTail = lCodeStack[$]
				if lInItem[$] then
					lText &= lEndItem
				end if
				lText &= lTail
				lCurLevel -= 1
				lCodeStack = lCodeStack[1..$-1]
				lInItem = lInItem[1..$-1]
			end while
			
		elsif lTail != lCodeStack[$] then
			-- Change of list type on same level.
			lText &= lCodeStack[$]
			if lInItem[$] then
				lText &= lEndItem
			end if
			lText &= lHead
			lInItem[$] = 0
			lCodeStack[$] = lTail
		end if

		if lInItem[$] then
			lText &= lEndItem
		end if
		lText &= lStartItem
		lInItem[$] = 1

		-- Locate end of current item.
		-- * Next line is either blank or starts with a list item, heading,
		--   Table, or NoWiki

		while 1 do
			lNextLine = get_logical_line(pRawText, lNextPos, vLineBeginings, {})
			lNextLine[2] = trim(lNextLine[2])
			if length(lNextLine[2]) = 0 then
				exit
			end if

			if compare_begin({"**", "##"}, lNextLine[2]) > 0 then
				-- Line begins with a double
				if length(lNextLine[2]) >= 3 then
					if eu:find(lNextLine[2][3], lNextLine[2][1] & " \t") = 0 then
						--  but its not followed by a space so it's part of the same item.
						lNextPos = lNextLine[1]
						lNextLine[2] = ' ' & lNextLine[2]
					else
						--  but it's followed by a space so it's a new item.
						exit
					end if
				else
					-- Short line, so its an item.
					exit
				end if
			end if


			if compare_begin( vLineBeginings, lNextLine[2]) > 0 then
				-- Skip over leading white space
				while lNextPos < length(pRawText) and eu:find(pRawText[lNextPos], vWhiteSpace) do
					lNextPos += 1
				end while
				-- Check if next line is also a list item
				if eu:find(pRawText[lNextPos], "#*") = 0 then
					lNextPos = lNextPos - 1
				end if
				exit
			end if

			if length(lLine) > 0 then
				lLine &= '\n'
			end if
			lLine &= lNextLine[2]
		end while

		lPos = 1
		while lPos < length(lLine) and lLine[lPos] = lType do
			lPos += 1
		end while
		lText &= call_func(vParser_rid, {trim(lLine[lPos .. $]), 1})

	end while


	while length(lCodeStack) > 0 do
		lTail = lCodeStack[$]
		if lInItem[$] then
			lText &= lEndItem
		end if
		lText &= lTail
		lCodeStack = lCodeStack[1..$-1]
		lInItem = lInItem[1 .. $-1]
	end while
	lCodeStack = Generate_Final(ListItem, {255})
	lPos = eu:find(255, lCodeStack)
	lText = search:match_replace(lStartItem, lText, lCodeStack[1 .. lPos - 1], 0)
	lText = search:match_replace(lEndItem, lText, lCodeStack[lPos + 1 .. $], 0)

	lCodeStack = Generate_Final(OrderedList, {255})
	lPos = eu:find(255, lCodeStack)
	lText = search:match_replace(lStartOrdered, lText, lCodeStack[1 .. lPos - 1], 0)
	lText = search:match_replace(lEndOrdered, lText, lCodeStack[lPos + 1 .. $], 0)

	lCodeStack = Generate_Final(UnorderedList, {255})
	lPos = eu:find(255, lCodeStack)
	lText = search:match_replace(lStartUnordered, lText, lCodeStack[1 .. lPos - 1], 0)
	lText = search:match_replace(lEndUnordered, lText, lCodeStack[lPos + 1 .. $], 0)

	return {lNextPos, TAG_ENDPARA & lText & TAG_STARTPARA}
end function

------------------------------------------------------------------------------
function get_nowiki(sequence pRawText, atom pFrom)
------------------------------------------------------------------------------
	sequence lText
	integer lEndPos
	integer lStartPos
	integer lNewPos
	integer lType
	integer lFoundEnd

	lType = 0 -- assume a block type
	lStartPos = pFrom + 3
	-- Now determing what sort of nowiki this could be:- inline or block
	if pFrom > 1 and pRawText[pFrom - 1] != '\n' then
		lType = 1 -- inline because start tag not at start of a line.
	end if

	if lType = 0 then
		for i = lStartPos to length(pRawText) do
			if eu:find(pRawText[i], " \t\n") = 0 then
				lType = 1
				exit
			elsif pRawText[i] = '\n' then
				exit
			end if
		end for
	end if

	lEndPos = lStartPos
	loop do
		lEndPos = match_from("}}}", pRawText, lEndPos + 1)
		lFoundEnd = 1

		if lEndPos = 0 then
			-- Missing end-of-nowiki tag so return begining tag as literal text.
			return {lStartPos-1, "{{{"}
		end if
		if lType != 1 then -- a block type
			-- Must find a block end tag and not an inline one.
			if not has_leading_chars(pRawText, lEndPos) then
				lFoundEnd = 0 -- because end tag not at start of a line.
			end if
			if not has_trailing_chars(pRawText, lEndPos+2) then
				lFoundEnd = 0 -- because end tag not on a line by itself.
			end if
		end if
		until lFoundEnd = 1
	end loop

	lNewPos = lEndPos + 3
	while lNewPos <= length(pRawText) and pRawText[lNewPos] = '}' do
		lNewPos += 1
	end while
	lEndPos = lNewPos - 3

	-- Now determing what sort of nowiki this is:- inline or block
	if lType != 1 and not has_leading_chars(pRawText, lEndPos) then
		lType = 1 -- inline because end tag not at start of a line.
	end if
	if lType != 1 and not has_trailing_chars( pRawText, lEndPos + 2) then
		lType = 1 -- inline because end tag not on a line by itself.
	end if

	if lType != 1 then
		if pRawText[lEndPos - 1] = ' ' then
			lEndPos -= 1 -- eat leading space at block style end
		end if
		while lStartPos < lEndPos and pRawText[lStartPos]  = ' ' do
			lStartPos += 1 -- eat leading spaces in block style.
		end while
		if pRawText[lStartPos] = '\n' then
			lStartPos += 1 -- eat first new-line in block style.
		end if
	end if

	if lType = 0 then
		lText = Generate_Final(NoWikiBlock, {Generate_Final(Sanitize, { 1, pRawText[lStartPos .. lEndPos - 1] })})
	else
 		lText = Generate_Final(NoWikiInline, {Generate_Final(Sanitize, { 0, trim(pRawText[lStartPos .. lEndPos - 1]) })})
	end if


	return {lNewPos-1, lText}
end function

------------------------------------------------------------------------------
function get_linebroken(sequence pRawText, atom pFrom)
------------------------------------------------------------------------------
	sequence lText
	integer lEndPos
	integer lStartPos
	integer lNewPos

	lStartPos = pFrom + 3
	lEndPos = match_from("]]]", pRawText, lStartPos + 1)

	if lEndPos = 0 or pRawText[lEndPos - 1] = '~' then
		-- Missing end-of-linebroken tag so return begining tag as literal text.
		return {lStartPos-1, "[[["}
	end if

	lNewPos = lEndPos + 3
	while lNewPos <= length(pRawText) and pRawText[lNewPos] = ']' do
		lNewPos += 1
	end while
	lEndPos = lNewPos - 3

	lText = match_replace("\n", pRawText[lStartPos .. lEndPos - 1], "\\\\\n")
	if length(lText) = 0 then
		lText = `\\`
	elsif lText[$] != '\n' then
		lText &= `\\`
	end if
	
	lText = call_func(vParser_rid, {lText, 0})
	
	--Generate_Final(NoWikiBlock, {Generate_Final(Sanitize,{ 0, pRawText[lStartPos .. lEndPos - 1] })})

	return {lNewPos-1, lText}
end function

------------------------------------------------------------------------------
function get_link(sequence pRawText, atom pFrom)
------------------------------------------------------------------------------
	sequence lText
	integer lEndPos
	integer lEOL
	integer lPos
	integer lParseText
	sequence lURL
	sequence lDisplayText

	lParseText = 1
	-- Collect everything up the to the next "]]" on the same line.
	lEOL = find_eol(pRawText, pFrom + 2)
	if lEOL > length(pRawText) then
		lEOL -= 1
	end if
	lEndPos = match("]]", pRawText[pFrom + 2 .. lEOL])
	if lEndPos = 0 then
		-- No end tag so don't treat this as a link.
		return {pFrom, "["}
	end if
	lEndPos += pFrom + 1

	-- Pull out the whole link tag and data

	lText = trim(pRawText[pFrom + 2 .. lEndPos - 1])
	if length(lText) = 0 then
		return {lEndPos + 1, ""}
	end if

	lPos = rmatch("->", lText, 0)
	if lPos > 0 then
		lURL = dequote(trim(lText[lPos + 2 .. $]))
		lDisplayText = trim(lText[1 .. lPos - 1])
		if length(lDisplayText) > 0 and lDisplayText[1] = ':' then
			lURL = ':' & lURL
			lDisplayText = lDisplayText[2..$]
		end if
		lDisplayText = dequote(lDisplayText)
	else
		lPos = eu:find('|', lText)
		integer lPosR = length(lText)
		if lPos = 0 then
			lPos = eu:find('"', lText)
			if lPos != 0 then
				lPosR = eu:find_from('"', lText, lPos + 1 )
				if lPosR != 0 then
					lPosR -= 1
				else
					lPos = 0
				end if
			end if
		end if
		
		if lPos = 0 and find_any(".:/", lText) != 0 then
			if length(lText) > 0 and lText[1] != ':' then
				lPos = eu:find(' ', lText)
				lParseText = 0
			end if
		end if

		if lPos = 0 then
			lURL = lText
			lDisplayText = lText
		else
			lURL = trim(lText[1 .. lPos - 1])
			lDisplayText = trim(lText[lPos + 1 .. lPosR])
			-- See if I need to swap them.
			if eu:find(':', lURL) = 0 and eu:find(':', lDisplayText) != 0 then
				lText = lURL
				lURL = lDisplayText
				lDisplayText = lText
				-- lURL >< lDisplayText
			end if
		end if
	end if

	if length(lURL) > 0 then
		lURL = Generate_Final(SanitizeURL, { lURL })	
		lPos = eu:find(':', lURL) + begins('/', lURL)
		if lPos = 0 then
			
			-- Internal link.
			lText = Generate_Final(InternalLink, { lURL, call_func(vParser_rid, { lDisplayText, 2 })})

		else
			if match("://", lURL) > 0 or match("mailto:", lURL) = 1 or begins('/', lURL) then
				-- assume it is an normal link
				if lParseText then
					lText = Generate_Final(NormalLink, {lURL, call_func(vParser_rid, {lDisplayText, 2})})
				else
					lText = Generate_Final(NormalLink, {lURL, lDisplayText})
				end if
			else
				if lURL[1] = ':' then
					-- a local link
					if equal(lURL, lDisplayText) then
						lDisplayText = lDisplayText[2 ..$]
					end if
					lURL = cleanup(lURL[2..$])
					-- Now we have to resolve this to some bookmark in these documents,
					-- but we can't do that until after all the bookmarks have been
					-- processed. So for now, just insert a placemarker and defer
					-- resolution to just before we hand back the documents.
					integer colon_loc = 0
					if length(lURL)>=2 then
						colon_loc = find_from(':',lURL,2)
					end if
					if colon_loc then
						sequence namespace = lURL[2..colon_loc]	
						lURL = lURL[colon_loc+1..$]
						vUnresolved = append(vUnresolved, {lURL, lDisplayText, vCurrentContext, length(vElements)+1, namespace})
					else					
						vUnresolved = append(vUnresolved, {lURL, lDisplayText, vCurrentContext, length(vElements)+1, vCurrentNamespace})
					end if
					lText = {TAG_UNRESOLVED, length(vUnresolved)}
					vElements = append(vElements, {'u', length(vUnresolved)})
				else
					-- assume it is an Interwiki link
					lText = Generate_Final(InterWikiLink, {lURL, lDisplayText})
				end if
			end if

		end if
	else
		lText = ""
	end if

	return {lEndPos+1, lText}
end function

------------------------------------------------------------------------------
function get_quoted(sequence pRawText, atom pFrom)
------------------------------------------------------------------------------
	sequence lText
	integer lStartPos
	integer lEndPos
	integer lAltEnd
	sequence lName 
	integer lBodyStart
	integer lBodyEnd
	integer lDepth
	integer lNextPos 

	-- Entry has pFrom at first char after lead-in tag.
	if pFrom > length(pRawText) then
		return {pFrom, ""}
	end if

	lText = ""
	
	-- Find complete open quote tag, isolating the 'name' component
	lStartPos = pFrom + 6
	if lStartPos < length(pRawText) then
		if find(pRawText[lStartPos], "\t ") then
			lStartPos += 1
		elsif pRawText[lStartPos] != ']' then
			return {0}
		end if
	end if
	
	lEndPos = lStartPos - 1
	lAltEnd = 0
	lName = ""
	while lEndPos < length(pRawText) do
		lEndPos += 1
		
		if pRawText[lEndPos] = ']' then
			lName = Generate_Final(Sanitize,{ 0, trim(pRawText[lStartPos .. lEndPos - 1]) })
			exit
		end if
		
		if find(pRawText[lEndPos], "\t ") then
			lAltEnd = lEndPos
			continue
		end if
		
		if pRawText[lEndPos] = '\n' then
			if lAltEnd != 0 then
				lEndPos = lAltEnd
			end if
			lName = Generate_Final(Sanitize, { 0, trim(pRawText[lStartPos .. lEndPos - 1]) })
			exit
		end if
	end while
	
	-- Find matching close quote tag.
	-- If none found, assume there should be one just prior to the next open quote tag,
	-- and if there is no other open quote tag, assume the end tag is after the supplied text.
	lBodyStart = lEndPos + 1
	lBodyEnd = lBodyStart - 1
	lDepth = 1
	lNextPos = 0
	while lBodyEnd < length(pRawText) do
		lBodyEnd += 1
		
		if pRawText[lBodyEnd] = '[' then
			if begins("[quote", pRawText[lBodyEnd .. $]) then
				lDepth += 1
				lBodyEnd += 6
				continue
			end if
			
			if begins("[/quote]", pRawText[lBodyEnd .. $]) then
				lDepth -= 1
				if lDepth > 0 then
					lBodyEnd += 7
					continue
				end if
				-- Matching end tag found.
				lBodyEnd -= 1
				lNextPos = lBodyEnd + 8
				lText = pRawText[lBodyStart .. lBodyEnd]
				exit
			end if
			
			if begins("[[", pRawText[lBodyEnd .. $]) then
				lBodyEnd += 1
				continue
			end if
			
		end if		
		
	end while
		
	if lNextPos = 0 then
		-- No matching end tag found.
		return {0}
	end if		
			
	if length(lText) > 0 then
			lText = call_func(vParser_rid, {lText, 0})
			lText = Generate_Final(Quoted, {lName, lText})
	end if
	return {lNextPos, lText}
end function


------------------------------------------------------------------------------
function get_division(sequence pRawText, integer pFrom)
------------------------------------------------------------------------------
	integer lPos
	integer lChar
	sequence lText
	integer lDepth

	lPos = pFrom + 2
	lText = ""
	lDepth = 1

	while lPos <= length(pRawText) and lDepth > 0 do
		lChar = pRawText[lPos]

		if lChar = '~' then
			if lPos != length(pRawText) then
				lPos += 1
				lChar = pRawText[lPos]
			end if

		elsif lChar = '%' then
			if lPos != length(pRawText) then
				if pRawText[lPos + 1] = '(' then
					lDepth += 1
				end if
			end if

		elsif lChar = ')' then
			if lPos != length(pRawText) then
				if pRawText[lPos + 1] = '%' then

					lDepth -= 1
					lChar = -1
					lPos += 1
				end if
			end if
		end if

		if lChar > 0 then
			lText &= lChar
		end if

		lPos += 1
	end while

	lText = call_func(vParser_rid, {lText, 2})
	lText = Generate_Final(Division, {vStyle[$], lText})
	vStyle = vStyle[1..$-1]

	return {lPos - 1, lText}
end function

------------------------------------------------------------------------------
function get_image(sequence pRawText, atom pFrom)
------------------------------------------------------------------------------
	sequence lText
	integer lEndPos
	integer lEOL
	integer lPos
	sequence lURL
	sequence lLinkText

	-- Collect everything up the to the next "}}" on the same line.
	lEOL = find_eol(pRawText, pFrom + 2)
	if lEOL > length(pRawText) then
		lEOL -= 1
	end if
	lEndPos = match("}}", pRawText[pFrom + 2 .. lEOL])
	if lEndPos = 0 then
		-- No end tag so don't treat this as a link.
		return {pFrom, "{"}
	end if
	lEndPos += pFrom + 1

	lText = trim(pRawText[pFrom + 2 .. lEndPos - 1])
	if length(lText) = 0 then
		return {lEndPos + 1, ""}
	end if

	lPos = rmatch("->", lText, 0)
	if lPos > 0 then
		lURL = trim(lText[lPos + 2 .. $])
		lLinkText = trim(lText[1 .. lPos - 1])
	else
		lPos = eu:find('|', lText)
		if lPos = 0 then
			lPos = eu:find(' ', lText)
		end if
		if lPos = 0 then
			lURL = lText
			lLinkText = lText
		else
			lURL = trim(lText[1 .. lPos - 1])
			lLinkText = trim(lText[lPos + 1 .. $])
			-- See if I need to swap them.
			if eu:find(':', lURL) = 0 and eu:find(':', lLinkText) != 0 then
				lText = lURL
				lURL = lLinkText
				lLinkText = lText
			end if
		end if
	end if

	if length(lURL) > 0 then
		lPos = eu:find(':', lURL)
		if lPos = 0 then
			-- Internal link.
			lText = Generate_Final(InternalImage, {lURL, lLinkText})

		else
			if match("://", lURL) > 0 then
				-- assume it is an normal link
				lText = Generate_Final(NormalImage, {lURL, lLinkText})
			else
				-- assume it is an Interwiki link
				lText = Generate_Final(InterWikiImage, {lURL, lLinkText})
			end if

		end if
	else
		lText = ""
	end if

	return {lEndPos+1, lText}
end function

------------------------------------------------------------------------------
function get_bookmark(sequence pRawText, integer pFrom)
------------------------------------------------------------------------------
	integer lPos
	integer lChar
	sequence lDisplayText
	sequence lReferenceText
	sequence lBookMarkText

	lPos = pFrom + 2
	lDisplayText = ""
	lReferenceText  = ""
	lBookMarkText = ""

	while lPos <= length(pRawText) do
		lChar = pRawText[lPos]
		if eu:find(lChar, "|]\n") > 0 then
			exit
		end if

		if lChar = '~' then
			if lPos != length(pRawText) then
				lPos += 1
				lChar = pRawText[lPos]
			end if
		end if

		lBookMarkText &= lChar
		lPos += 1
	end while

	if lChar = '|' then
		lPos += 1
		while lPos <= length(pRawText) do
			lChar = pRawText[lPos]
			if eu:find(lChar, "]\n") > 0 then
				exit
			end if

			if lChar = '~' then
				if lPos != length(pRawText) then
					lPos += 1
					lChar = pRawText[lPos]
				end if
			end if

			lReferenceText &= lChar
			lPos += 1
		end while
	else
		lReferenceText = lBookMarkText
	end if

	if lChar = ']' then
		lPos += 1
	end if

	lBookMarkText = cleanup(lBookMarkText)

	lReferenceText = trim(lReferenceText)

	if length(lReferenceText) > 0 then
		lDisplayText = call_func(vParser_rid, {lReferenceText, 2})
	end if

	if length(lBookMarkText) > 0 then
		lDisplayText = Generate_Final(Bookmark, lBookMarkText) & lDisplayText
		add_bookmark('a', lReferenceText, lBookMarkText)
	else
		lDisplayText = ""
	end if
	return {lPos - 1, lDisplayText}
end function

------------------------------------------------------------------------------
function convert_url(sequence pText, object pMatch)
------------------------------------------------------------------------------
	sequence lResult
	sequence lURL
	sequence lRawURL
	integer lFrom
	integer lTo
	integer lChar
	sequence tld
	sequence lFound = {}

	lResult = pText
	loop do
	
		lFrom = pMatch[2][1]
		lTo  = pMatch[$][2]
		lRawURL = lResult[lFrom .. lTo]
		-- Check that the top-level-domain is reasonable.
		if length(pMatch) = 5 then
			-- we might have a country-abbrev.
			if pMatch[5][2] - pMatch[5][1] != 1 then
				-- Country codes are exactly 2-chars long.
				pMatch = 0
			else
				tld = lResult[pMatch[5][1] .. pMatch[5][2]]
				if binary_search(lower(tld), vCountry_TLD) <= 0 then
					pMatch = 0
				end if
			end if
		end if
		
		-- Check the tld
		if sequence(pMatch) then
			tld = lResult[pMatch[4][1] .. pMatch[4][2]]
			if eu:find(lower(tld), vTLD) = 0 then
				pMatch = 1
			end if
		end if
		
		-- The first two words both cannot be one char long.
		if sequence(pMatch) then
			if pMatch[2][1] = pMatch[2][2] and
			   pMatch[3][1] = pMatch[3][2] then
			   	pMatch = 2
			end if
		end if
		
		if sequence(pMatch) then
			for i = 2 to length(pMatch) do
				if eu:find(lResult[pMatch[i][1]], vDigits) then
					pMatch = 3
					exit
				end if
			end for
		end if
		
		-- Check for honorifics in first word
		if sequence(pMatch) then
			tld = lResult[pMatch[2][1] .. pMatch[2][2]]
			if eu:find(lower(tld), vHonorifics) != 0 then
				pMatch = 4
			end if
		end if
		
		if sequence(pMatch) then
			-- Scan forward after the potential URL to find the real end, allowing
			-- for various arguments that might follow a url.
			while lTo < length(lResult) do
				lTo += 1
				lChar = lResult[lTo]
				if eu:find(lChar, " ,!:;'\n\t\"\\|]") > 0 then
					lTo -= 1
					exit
				end if
				if lChar = '~' then
					if lTo < length(lResult) then
						lTo += 1
						lChar = lResult[lTo]
					end if
				end if
			end while
		
			lRawURL = lResult[lFrom .. lTo]
		end if
		if atom(pMatch) then
			lURL =  lRawURL
		else
			lURL = Generate_Final(NormalLink, {"http://" & lRawURL, lRawURL})
		end if
		lFound = append(lFound, lURL)
		lURL = {length(lFound) + 9999}

		lResult = lResult[1 .. lFrom-1] & lURL & lResult[lTo+1 .. $]

		pMatch = find_url(lResult, lFrom + 1)
		
		until atom(pMatch)
	end loop

	for i = 1 to length(lFound) do
		lFrom = eu:find(i + 9999, lResult)
		lResult = lResult[1 .. lFrom - 1] & lFound[i] & lResult[lFrom + 1 .. $]
	end for
	return lResult
end function

------------------------------------------------------------------------------
function get_url(sequence pRawText, atom pFrom, integer pMarkup = 1)
------------------------------------------------------------------------------
	integer lPos
	integer lChar
	sequence lURL

	lPos = find_from(':', pRawText, pFrom) + 1
	lURL = pRawText[pFrom .. lPos-1]

	while lPos <= length(pRawText) label "main" do
		lChar = pRawText[lPos]
		if eu:find(lChar, " ,!:;'\n\t\"\\|]") > 0 then
			exit
		end if
		if lChar = '~' then
			if lPos < length(pRawText) then
				lPos += 1
				lChar = pRawText[lPos]
			end if
		end if
		lURL &= lChar
		lPos += 1
	end while

	lURL = trim(lURL)
	if length(lURL) > 0 and lURL[$] = '.' then
		lURL = lURL[1 .. $ - 1]
		lPos -= 1
	end if

	if pMarkup then
		lURL = Generate_Final(NormalLink, {lURL, lURL})
	end if
	return {lPos - 1, lURL}
end function

------------------------------------------------------------------------------
function get_table(sequence pRawText, atom pFrom)
------------------------------------------------------------------------------
	sequence lText
	sequence lHead
	sequence lBody
	integer lPos
	sequence lHeaders
	sequence lCells
	sequence lLine
	integer lCellType
	integer lColumn
	integer lRow
	integer lMode
	integer lHeadingLine
	integer lCI
	integer lCJ
	sequence lRowText
	sequence lNewLine
	integer lTableLinecnt

	-- Collect all the table definition before outputing anything.
	lHeaders = {}
	lCells = {}
	lPos = pFrom
	lMode = 'H' -- assume horizontal, until proven otherwise.
	lRow = 0
	lTableLinecnt = 0

	while length(lLine) > 0 with entry do
		-- Convert all escaped bars with special tag.
		lCI = 1
		lCJ = match("~|", lLine, lCI)
		while lCJ != 0 do
			lLine = replace(lLine, TAG_TABLE_BAR, lCJ, lCJ + 1)
			lCI = lCJ + 1
			lCJ = match("~|", lLine, lCI)
		end while
		
		
		lText = ""
		lCellType = '?'
		lHeadingLine = 0

		lCI = 0
		while lCI < length(lLine) do
			lCI += 1
			if lCI = 1 then
				if lMode = 'H' then
					lColumn = 0
				end if
				if lLine[lCI] = '|' then
					-- ignore leading bar
					continue
				end if
			end if

			if lCellType = '?' then
				if lLine[lCI] = '=' or (lLine[lCI] = '|' and lTableLinecnt = 1) then	-- Can only have a header on the first table definition line.
					lHeadingLine = 1
					lCellType = 'h'
					if length(lHeaders) > 0 then
						if length(lCells) > 0 then
							lMode = 'V' -- Now in vertical mode
							lColumn = 0
							lRow = 0
						end if
					end if
				else
					if lHeadingLine then
						lCellType = 'h'
						lText &= lLine[lCI]
						if length(lHeaders) > 0 then
							if length(lCells) > 0 then
								lMode = 'V' -- Now in vertical mode
								lColumn = 0
								lRow = 0
							end if
						end if
					else
						-- We have a cell
						lCellType = 'c'
						lCI -= 1
					end if
				end if
			else
				if lLine[lCI] = '|' then
					-- end of cell
					lText = call_func(vParser_rid, {lText, 1})
					if lCellType = 'h' then
						lHeaders = append(lHeaders, lText)
					else
						lColumn += 1
						if lMode = 'H' then
							if lColumn = 1 then
								-- start a new row
								lCells = append(lCells, {})
								lRow += 1
							end if
							lCells[$] = append(lCells[$], lText)
						else
							lRow += 1
							if lRow > length(lCells) then
								lCells = append(lCells, {})
							end if
							lCells[lRow] = append(lCells[lRow], lText)
						end if
					end if
					lCellType = '?'
					lText = ""
				else
					lText &= lLine[lCI]
				end if
			end if
		end while

	 entry  -- << loop entry point -------
		lNewLine = get_logical_line(pRawText, lPos, {"|"}, {"|"})
		lLine = lNewLine[2]
		if length(lLine) > 0 and lLine[1] != '|' then
			-- new line doesn't start with a bar, so end the current table.
			lLine = ""
		else
			lPos = lNewLine[1]
			lTableLinecnt += 1
	
			-- Append a bar if one not at end already.
			if length(lLine) > 0 and lLine[$] != '|' then
				lLine &= '|'
			end if
		end if
	end while

	-- Convert any escaped bars back to real bars.
	for i = 1 to length(lHeaders) do
		lHeaders[i] = find_replace(TAG_TABLE_BAR, lHeaders[i], '|')
	end for
	for i = 1 to length(lCells) do
		for j = 1 to length(lCells[i]) do
			lCells[i][j] = find_replace(TAG_TABLE_BAR, lCells[i][j], '|')
		end for
	end for
	
	-- Generate final for the table now.
	lHead = ""
	if length(lHeaders) > 0 then
		lRowText = ""
		for i = 1 to length(lHeaders) do
			lRowText &= Generate_Final(HeaderCell, {lHeaders[i]})
		end for
		lHead &= Generate_Final(HeaderRow, {lRowText})
	end if
	lHead = Generate_Final(TableHead, {lHead})

	lBody = ""
	for i = 1 to length(lCells) do
		lRowText = ""
		for j = 1 to length(lCells[i]) do
			if length(lCells[i][j]) > 0 then
				lRowText &= Generate_Final(NormalCell, {lCells[i][j]})
			else
				lRowText &= Generate_Final(NormalCell,
							{Generate_Final(NonBreakSpace,{})})
			end if
		end for
		lBody &= Generate_Final(NormalRow, {lRowText})
	end for
	lBody = Generate_Final(TableBody, {lBody})

	lText = TAG_ENDPARA & Generate_Final(TableDef, {lHead & lBody}) & TAG_STARTPARA

	return {lPos-1, lText}
end function

------------------------
public function process_macros(sequence pRawText, sequence pRecurse)
------------------------
	integer lPos
	integer lChar
	sequence lFinalForm
	sequence lText
	sequence lExtract

	integer lPrevIsWord
	integer lIndentLevel

	lFinalForm = ""
	lPrevIsWord = 0
	lIndentLevel = 0


	lText = ""

	lPos = 0
	while lPos < length(pRawText) do
		lPos += 1
		lChar = pRawText[lPos]
		if eu:find(lChar, "@$") = 0 then
			lText &= lChar
			continue
		end if

		switch lChar do

			case '@' then   -- Define macro
				if has_leading_chars(pRawText, lPos) then
					if compare_next({"@("}, pRawText, lPos) > 0 then
						lExtract = get_macro_definition(pRawText, lPos)
						lPos = lExtract[2]
						if lExtract[1] = 0 then
							lText &= lExtract[3]
						else
							map:put(vMacros, lExtract[3], lExtract[4])
						end if
						lChar = -1
					end if
				end if

				break

			case '$' then   -- Use macro
				if compare_next({"$("}, pRawText, lPos) > 0 then
					lExtract = get_macro_usage(pRawText, lPos, pRecurse)
					lPos = lExtract[1]
					if vAllowMacros then
						lText &= lExtract[2]
					end if
					lChar = -1
				end if
				break

		end switch

		if lChar > 0 then
			lText &= lChar
		end if

	end while
	return lText
end function
vMacro_Processor_rid = routine_id("process_macros")

------------------------
function update_paragraphs(sequence pText)
------------------------
	sequence lParaStart
	sequence lParaEnd
	integer  lStartLen
	integer  lEndLen
	integer  lSourcePos
	integer  lTargetPos
	integer  lHoldPos
	integer  lTempPos
	sequence lUpdatedText
	object   lChar
	integer  lDepth

	lParaStart = Generate_Final(Paragraph, {-1})
	lSourcePos = eu:find(-1, lParaStart)

	lParaEnd = lParaStart[lSourcePos + 1 .. $]
	lParaStart = lParaStart[1 .. lSourcePos - 1]
	lStartLen = length(lParaStart) - 1
	lEndLen = length(lParaEnd) - 1

	lSourcePos = 0
	lTargetPos = 0
	for i = 1 to length(pText) do
		if pText[i] = TAG_STARTPARA then
			lSourcePos += 1
		elsif pText[i] = TAG_ENDPARA then
			lTargetPos += 1
		end if
	end for

	if lSourcePos = 0 and lTargetPos = 0 then
		-- No paragraphs to deal with.
		return pText
	end if

	lUpdatedText = repeat(' ', length(pText) +
							 lStartLen * lSourcePos +
							 lEndLen  * lTargetPos
							 )

	lSourcePos = 1
	lTargetPos = 1
	lDepth = 0
	while lSourcePos <= length(pText) do
		lChar = pText[lSourcePos]
		if not integer(lChar) then
			lUpdatedText[lTargetPos] = lChar
			lTargetPos += 1
			lSourcePos += 1
			continue
		end if

		if lChar = TAG_STARTPARA then
			lHoldPos = lSourcePos
			lSourcePos += 1
			while lSourcePos <= length(pText) and eu:find(pText[lSourcePos], " \t\n") do
				lSourcePos += 1
			end while
			if lSourcePos <= length(pText) then
				if pText[lSourcePos] = TAG_ENDPARA then
					-- Found an empty paragraph, so delete it.
					lTargetPos -= 1
				else

					-- Insert the para start
					lTempPos = lTargetPos + lStartLen
					lUpdatedText[lTargetPos .. lTempPos] = lParaStart
					lTargetPos = lTempPos + 1
					lDepth += 1

					-- Copy rest verbatim
					lHoldPos += 1
					lTempPos = lTargetPos + lSourcePos - lHoldPos
					lUpdatedText[lTargetPos .. lTempPos]
								= pText[lHoldPos .. lSourcePos]
					lTargetPos = lTempPos
				end if
			else
				-- Last one is empty, so delete it.

				lTargetPos -= 1
			end if

		elsif lChar = TAG_ENDPARA then
			lTempPos = lTargetPos + lEndLen
			lUpdatedText[lTargetPos .. lTempPos] = lParaEnd
			lTargetPos = lTempPos
			lDepth -= 1

		elsif lChar = '\n' then
			lHoldPos = lSourcePos
			lSourcePos += 1
			while lSourcePos <= length(pText) and pText[lSourcePos] = '\n' do
				lSourcePos += 1
			end while
			if lSourcePos <= length(pText) then
				if pText[lSourcePos] = TAG_ENDPARA then
					-- Located a series of newlines ending with a lone ENDPARA,
					-- all of this gets replaced by a single newline.
					lUpdatedText[lTargetPos] = '\n'
				elsif pText[lSourcePos] = TAG_STARTPARA then
					-- Located a series of newlines ending with a STARTPARA,
					-- all the newlines of this gets replaced by a single newline.
					lUpdatedText[lTargetPos] = '\n'
					lSourcePos -= 1
				else
					-- Copy it verbatim
					lTempPos = lTargetPos + lSourcePos - lHoldPos
					lUpdatedText[lTargetPos .. lTempPos]
								= pText[lHoldPos .. lSourcePos]
					lTargetPos = lTempPos
				end if
			else
				-- Lose trailing newlines
			end if
		else
			lUpdatedText[lTargetPos] = lChar
		end if

		lTargetPos += 1
		lSourcePos += 1
	end while

	while lDepth > 0 do
		lUpdatedText &= repeat(' ', length(lParaEnd))
		lTempPos = lTargetPos + lEndLen
		lUpdatedText[lTargetPos .. lTempPos] = lParaEnd
		lTargetPos = lTempPos
		lDepth -= 1
	end while		
	return lUpdatedText[1 .. lTargetPos - 1]
end function

------------------------
public function parse_text(sequence pRawText, integer pSpan = 0)
------------------------
	integer lPos
	integer lChar
	integer lIsList
	integer lEOL
	integer lMark
	integer lPrevIsWord
	integer lIsWord
	integer lNewIndent
	integer lNewPos
	integer lIndentLevel = 0
	sequence lFinalForm
	sequence lText
	object lExtract
	sequence lNewPlugin

	lFinalForm = ""
	lPrevIsWord = 0


	if pSpan = 0 then
		lText = {TAG_STARTPARA}
	else
		lText = ""
	end if

	lPos = 0
	while lPos < length(pRawText) do
		lPos += 1
		lChar = pRawText[lPos]
		lIsWord = eu:find(lChar, vAllLetters)
		if eu:find(lChar, kLeadIn) = 0 then
			if lIsWord and not lPrevIsWord then
				-- Might be a CamelCase word coming up.
				if pSpan != 2 then
					lExtract = get_camel_case(pRawText, lPos)
					if lExtract[1] > 0 then
						-- Found a CamelCase word.
						lFinalForm &= Generate_Final(Sanitize, { 0, lText })
						lFinalForm &= Generate_Final(InternalLink, {lExtract[2], Generate_Final(CamelCase,lExtract[2])})
						lPos = lExtract[1]
						lPrevIsWord = lIsWord
						lText = ""
						continue
					end if
				end if
			end if
			lText &= lChar
			lPrevIsWord = lIsWord
			continue
		end if

		lPrevIsWord = lIsWord
		if length(lText) > 0 then
			lText = Generate_Final(Sanitize, { 0, lText })

			-- Check for short-form urls.
			if eu:find('.', lText) then
				lExtract = find_url(lText, 1)
				if sequence(lExtract) then
					lText = convert_url(lText, lExtract)
				end if
			end if

			lFinalForm &= lText
			lText = ""
		end if

		switch lChar label "Tagger" do
			case '=' then   -- Headings

				if has_leading_chars(pRawText, lPos) then

					if not pSpan then
						lText &= TAG_ENDPARA
						lExtract = get_heading(pRawText, lPos)
						lPos = lExtract[1]
						lText &= lExtract[2]

						lText &= TAG_STARTPARA
						lChar = -1
					end if

				end if

				break

			case '*', '#' then   -- Bullet, Numbered Lists and Bold
				-- Look backwards to see if only spaces precede this on the same line.
				if pSpan != 1 then
					if has_leading_chars(pRawText, lPos) then
						-- Might be a list, unless its monospaced.
						lIsList = 1
						if lPos + 2 <= length(pRawText) then
							if pRawText[lPos + 1] = lChar then
								if eu:find(pRawText[lPos + 2], " \t" & lChar) = 0 then
									lIsList = 0
								end if
							end if
						end if

						if lIsList then
							lExtract = get_list(pRawText, lPos)
							lPos = lExtract[1]
							lText &= lExtract[2] & TAG_ENDPARA & TAG_STARTPARA
							lChar = -1
							break "Tagger"
						end if
					end if
				end if

				fallthru
			case '/' then   -- Italics
				if lChar = '/' and compare_prev(vProtocols, pRawText, lPos) != 0 then
					break "Tagger"
				end if

				fallthru
			case '_', '^', ',', '+' then   -- Underline, Superscript, Subscript, Inserted
				if compare_next({{lChar}}, pRawText, lPos) > 0 then
					lExtract = get_decoration(pRawText, lPos)
					lPos = lExtract[1]
					lText &= lExtract[2]
					lChar = -1
				end if
				break

			case '&' then   -- Non-breaking space?
				if compare_next({"&"}, pRawText, lPos) > 0 then
					lPos += 1
					lText &= Generate_Final(NonBreakSpace,{})
					lChar = -1
				end if
				break

			case '~' then   -- Escape
				if lPos < length(pRawText) then
					lChar = pRawText[lPos + 1]
					if eu:find(lChar, " \t\n") = 0 then
						-- escape potential markup characters.
						if eu:find(lChar, kLeadIn) != 0 then
							lPos += 1
						else
							lMark = compare_next(vProtocols, pRawText, lPos)
							if lMark > 0 then
								if lPos + length(vProtocols[lMark]) <= length(pRawText)
								then -- escape this URL
									lExtract = get_url(pRawText, lPos + 1, 0 )
									lPos = lExtract[1]
									lText &= lExtract[2]
									lChar = -1
								else
									lChar = '~'
								end if
							else

								lExtract = get_camel_case(pRawText[lPos + 1 .. $], 1)
								if lExtract[1] < 0 then
									lChar = '~'
								else
									lChar = lExtract[2][1]
									lPos += 1
									lPrevIsWord = 1
								end if
							end if
						end if
					else
						if lPos = 1 or eu:find(pRawText[lPos - 1]," \t\n") != 0 then
							lChar = '~'
						end if

					end if
				end if
				break

			case ';' then   -- Definition List
				if pSpan = 0 and has_leading_chars(pRawText, lPos) then
					lExtract = get_definitionlist(pRawText, lPos)
					lPos = lExtract[1]
					lText &= lExtract[2]
					lChar = -1
				end if
				break

			case '<' then   -- Plugin,EUCODE colorization, or un-indent.
				if pSpan = 0 then
					sequence temps
					temps = pRawText[lPos .. lPos + 3]
					if compare_next({"\n", `\\`, ` \\`, " \n"}, pRawText, lPos) > 0 then
						-- Reduce indentation
						lText = Generate_Final(EndIndent, {})
						lIndentLevel -= 1
						lChar = -1
					end if
				end if
				
				if pSpan != 4 and compare_next({"<"}, pRawText, lPos) > 0 then
					lExtract = get_plugin(pRawText, lPos)
					lPos = lExtract[2]
					if lExtract[1] = 0 then
						lText &= lExtract[3]
					else
						if length(vOutputFile) > 0 then
							lNewPlugin =  {lExtract[3], vCurrentContext, vOutputFile[$], length(vElements) + 1}
						else
							lNewPlugin =  {lExtract[3], vCurrentContext, "", length(vElements) + 1}
						end if
						vPluginList = append(vPluginList, lNewPlugin)
						vElements = append(vElements, {'p', length(vPluginList)})
						lText &= {TAG_PLUGIN, length(vPluginList)}
					end if
					lChar = -1
				end if

				if has_leading_chars(pRawText, lPos) and
				   compare_next({"eucode>"}, pRawText, lPos) > 0
				then
					lExtract = get_eucode(pRawText, lPos)
					lPos = lExtract[1]
					lText &= lExtract[2]
					lChar = -1
				end if
				break

			case '%' then   -- Set Runtime Option or Division

				if has_leading_chars(pRawText, lPos) and
					compare_next({"%"}, pRawText, lPos) > 0
				then
					lExtract = get_options(pRawText, lPos)
					lPos = lExtract[1]
					lText &= lExtract[2]
					lChar = -1
					break "Tagger"
				end if

				if compare_next({"("}, pRawText, lPos) > 0 then
					lExtract = get_division(pRawText, lPos)
					lPos = lExtract[1]
					lText &= lExtract[2]
					lChar = -1
				end if
				break

			case '{' then   -- Nowiki or image
				if compare_next({"{{"}, pRawText, lPos) > 0 then
					lExtract = get_nowiki(pRawText, lPos)
					lPos = lExtract[1]
					lText &= lExtract[2]
					lChar = -1
					break "Tagger"
				end if

				if compare_next({"{"}, pRawText, lPos) != 0 then
					lExtract = get_image(pRawText, lPos)
					lPos = lExtract[1]
					lText &= lExtract[2]
					lChar =-1
				end if

				break

			case '`' then   -- Passthru
				if compare_next({"`"}, pRawText, lPos) > 0 then
					if lPos + 2 <= length(pRawText) then
						lExtract = get_passthru(pRawText, lPos)
						lPos = lExtract[1]
						lText &= lExtract[2]
						lChar = -1
					else
						lChar = -1
						lPos += 2
					end if
				end if

				break

			case '[' then   -- link or quoted section
				if compare_next({"[["}, pRawText, lPos) > 0 then
					lExtract = get_linebroken(pRawText, lPos)
					lPos = lExtract[1]
					lText &= lExtract[2]
					lChar = -1
					break "Tagger"
				end if
				
				if compare_next({"["}, pRawText, lPos) != 0 then
					lExtract = get_link(pRawText, lPos)
					lPos = lExtract[1]
					lText &= lExtract[2]
					lChar =-1
				end if
				
				if compare_next({"quote"}, pRawText, lPos) > 0 then
					lExtract = get_quoted(pRawText, lPos)
					if lExtract[1] > 0 then
						lPos = lExtract[1]
						lText &= TAG_ENDPARA & lExtract[2] & TAG_STARTPARA
						lChar = -1
					end if
					break "Tagger"
				end if
				
				break

			case '\\' then  -- Break Line
				if compare_next({"\\"}, pRawText, lPos) != 0 then
					lText &= Generate_Final(ForcedNewLine,{})
					lPos += 1
					lChar =-1
				end if

				break

			case '\n' then  -- paragraph
				if has_trailing_chars( pRawText, lPos ) then
					lText &= TAG_ENDPARA
					while lIndentLevel > 0 do
						lText &= Generate_Final(EndIndent, {})
						lIndentLevel -= 1
					end while
					lText &= TAG_STARTPARA
					lPos = find_eol(pRawText, lPos + 1)
				end if
				lChar =' '
				break

			case '-' then   -- Horizontal line or strikeout text
				if compare_next({"---"}, pRawText, lPos) > 0 then
					-- Look backwards to see if only spaces precede this on the same line.
					if not has_leading_chars(pRawText, lPos) then
						break "Tagger"
					end if

					-- Look forwards to see if only spaces or/and dashes follow this on the same line.
					if not has_trailing_chars(pRawText, lPos + 3, " \t-") then
						break "Tagger"
					end if

					lChar = -1
					lPos = find_eol(pRawText, lPos + 4)
					if not pSpan then
						lText &= TAG_ENDPARA
					end if
					lText &= Generate_Final(HorizontalLine, {})
					break "Tagger"
				end if

				if compare_next({"-"}, pRawText, lPos) > 0 then

					lExtract = get_decoration(pRawText, lPos)
					lPos = lExtract[1]
					lText &= lExtract[2]
					lChar = -1
				end if

				break

			case '|' then   -- table

					if pSpan != 0 or not has_leading_chars(pRawText, lPos) then
						break "Tagger"
					end if

					lExtract = get_table(pRawText, lPos )
					lPos = lExtract[1]
					lText &= lExtract[2]
					lChar = -1
				break

			case ':' then   -- URL or indented text
				if pSpan != 2 then
					lMark = compare_prev(vProtocols, pRawText, lPos + 1)
					if lMark > 0 then
						lExtract = get_url(pRawText, lPos + 1 - length(vProtocols[lMark]) )
						lPos = lExtract[1]
						lFinalForm = lFinalForm[1 .. $ - length(vProtocols[lMark]) + 1]
						lText &= lExtract[2]
						lChar = -1
						break "Tagger"
					end if
				end if

				if pSpan = 0 then
					if has_leading_chars(pRawText, lPos) then
						lNewPos = lPos
						while lNewPos < length(pRawText) do
							lNewPos += 1
							if pRawText[lNewPos] != ':' then
								exit
							end if
						end while
						lNewIndent = lNewPos - lPos
						if lIndentLevel < lNewIndent then
							while lIndentLevel < lNewIndent do
								lText &= Generate_Final(BeginIndent, {})
								lIndentLevel += 1
							end while
						elsif lIndentLevel > lNewIndent then
							while lIndentLevel > lNewIndent do
								lText &= Generate_Final(EndIndent, {})
								lIndentLevel -= 1
							end while
						else
							lText &= Generate_Final(ForcedNewLine,{})
						end if
						lChar = -1
						lPos = lNewPos - 1

					end if
				end if
				break

			case '>' then   -- indented text or section start
				if pSpan = 0 and has_leading_chars(pRawText, lPos) then
					lNewPos = lPos
					while lNewPos < length(pRawText) do
						lNewPos += 1
						if pRawText[lNewPos] != '>' then
							exit
						end if
					end while
					lNewIndent = lNewPos - lPos

					if lIndentLevel < lNewIndent then
						while lIndentLevel < lNewIndent do
							lText &= Generate_Final(BeginIndent, {})
							lIndentLevel += 1
						end while
					elsif lIndentLevel > lNewIndent then
						while lIndentLevel > lNewIndent do
							lText &= Generate_Final(EndIndent, {})
							lIndentLevel -= 1
						end while
					else
						lText &= Generate_Final(ForcedNewLine,{})
					end if
					lChar = -1
					lPos = lNewPos - 1

				end if

				break

			case '@' then   -- ad hoc bookmark
				if compare_next({"["}, pRawText, lPos) > 0 then
					lExtract = get_bookmark(pRawText, lPos)
					lPos = lExtract[1]
					lText &= lExtract[2]
					lChar = -1
				end if
				break

			case '!' then   -- wiki comment
				if compare_next({"!"}, pRawText, lPos) > 0 then
					if compare_next({"CONTEXT:"}, pRawText, lPos + 1) > 0 then
						object out
						lExtract = get_to_eol(pRawText, lPos + 10)
						vRawContext = lExtract[2]
						out = find_paren_end(vRawContext)
						if sequence(out) then
							vCurrentNamespace = vRawContext[out[1] + 1 .. out[2] - 1] 
							vRawContext = vRawContext[1..out[1]-1] & vRawContext[out[2]+1..$]
						end if
						vCurrentContext = cleanup(lExtract[2], "/\\.")
						add_bookmark('a', vCurrentContext, cleanup(lExtract[2]))
						lText &= Generate_Final(ContextChange, vRawContext)
						lPos = lExtract[1]-1
					else
						lPos = find_eol(pRawText, lPos+2)
					end if
					lChar = -1
				end if
				break

		end switch

		lFinalForm &= lText
		lText = ""

		if lChar > 0 then
			if length(lFinalForm) = 0 then
				lFinalForm &= Generate_Final(Sanitize, { 0, { lChar } })
			elsif lChar = ' ' then
				if eu:find(lFinalForm[$], " \t\n") = 0 then
					lFinalForm &= ' '
				end if
			else
				lFinalForm &= Generate_Final(Sanitize, { 0, { lChar } })
			end if
		end if


	end while
	lFinalForm &= Generate_Final(Sanitize, { 0, lText })

	if not pSpan or eu:find(TAG_STARTPARA, lFinalForm) then
		-- Remove any empty paragraphs.
		lFinalForm = update_paragraphs(lFinalForm)
	end if

	while lIndentLevel > 0 do
		lText &= Generate_Final(EndIndent, {})
		lIndentLevel -= 1
	end while
	
	if not pSpan then
		if length(lFinalForm) > 1 then
			if lFinalForm[$] != '\n' then
				lFinalForm &= '\n'
			end if
		end if
	end if

	return lFinalForm
end function

vParser_rid = routine_id("parse_text")

--------------------------------------------------------------------------------
public function creole_parse(object pRawText, object pFinalForm_Generator = -1, object pContext = "")
--------------------------------------------------------------------------------
	sequence lText
	integer lPos
	integer lFrom
	integer lFileNo
	integer lIdx
	integer lHdIdx
	integer lLevel
	sequence lPluginResult
	sequence lMultiText

	if integer(pRawText) then
		lText = ""
		switch pRawText do
			case Get_Headings then
					-- This returns a list of headings in the form of ...
					--     [1] = Depth (level)
					--     [2] = Text (including numbering if applicable)
					--     [3] = The bookmark name.
					--     [4] = The subcontext id. Contains the value of the !!CONTEXT:
					--           tag that occured prior to this bookmark.
					--     [5] = The name of the generated output file. If blank, there is
					--           no file spliting being done.
					--     [6] = Pointer to the Element sequence for the bookmark
					--           associated with the heading.
				for i = 1 to length(vHeadings) do
					if vHeadings[i][H_DEPTH] > pContext then
						continue
					end if
					lText = append( lText, vHeadings[i] & vBookMarks[vHeadingBMIndex[i]][BM_GETHEADINGS] )
				end for
				break

			case Get_CurrentLevels then
				if length(pContext) then
					integer lEx = pContext[1]
					integer lDepth = pContext[2]
					sequence lHeading
					for j = lEx to 1 by -1 do
						if vElements[j][1] = 'b' then
							lIdx = vElements[j][2]
							if vBookMarks[lIdx][1] = 'h' then
								lHdIdx = vBookMarks[lIdx][2]
								lHeading = vHeadings[lHdIdx]
								lText = split( lHeading[2], ' ')
								lText = split( lText[1], '.' )
								for k = 1 to length( lText ) do
									lText[k] = value( lText[k] )
									lText[k] = lText[k][2]
								end for
								if lDepth < 0 or lDepth = length( lText ) then
									exit
								end if
							end if
						end if
					end for
					
				end if
				
			case Get_CurrentHeading then
					-- This returns the heading immediately prior to 'element'
					-- supplied in the 'pContext' parameter.
					--     [1] = Depth (level)
					--     [2] = Text (including numbering if applicable)
					--     [3] = The bookmark name.
					--     [4] = The subcontext id. Contains the value of the !!CONTEXT:
					--           tag that occured prior to this bookmark.
					--     [5] = The name of the generated output file. If blank, there is
					--           no file spliting being done.
					--     [6] = Pointer to the Element sequence for the bookmark
					--           associated with the heading.

				for j = pContext to 1 by -1 do
					if vElements[j][1] = 'b' then
						lIdx = vElements[j][2]
						if vBookMarks[lIdx][1] = 'h' then
							lHdIdx = vBookMarks[lIdx][2]
							lText = vHeadings[lHdIdx] & vBookMarks[BM_GETHEADINGS]
							exit
						end if
					end if
				end for
				break

			case Get_Elements then
					-- This returns a list of elements in the form of ...
					--     [1] = Type ('h', 'p')
					-- for type 'h' (headings)
					--     [2] = Depth (level)
					--     [3] = Text (including numbering if applicable)
					--     [4] = The bookmark name
					--     [5] = The subcontext id. Contains the value of the !!CONTEXT:
					--           tag that occured prior to this bookmark.
					--     [6] = The name of the generated output file. If blank, there is
					--           no file spliting being done.
					-- for type 'p' (plugin)
					--     [2] = The plugin name
					--     [3] = The parameters
					--     [4] = 0 (element not used yet)
					--     [5] = The subcontext id. Contains the value of the !!CONTEXT:
					--           tag that occured prior to this bookmark.
					--     [6] = The name of the generated output file. If blank, there is
					--           no file spliting being done.
				for i = 1 to length(vElements) do
					if vElements[i][1] = 'b' then
						lIdx = vElements[i][2]
						if vBookMarks[lIdx][BM_TYPE] = 'h' then
							lHdIdx = vBookMarks[lIdx][BM_POINTER]
							lText = append(lText,
								'h' & vHeadings[lHdIdx] &
								vBookMarks[lIdx][BM_ELEMENTS])
						end if
					elsif vElements[i][1] = 'p' then
						lText = append(lText,
								'p' & vPluginList[vElements[i][2]]
								)
					end if
				end for

				break

			case Get_Bookmarks then
					-- This returns a list of elements in the form of ...
					--     [1] = Type ('h' - heading, 'a' - anchor)
					--     [2] = Depth (heading level)
					--     [3] = Display Text (including numbering if applicable)
					--     [4] = The bookmark name
					--     [5] = The subcontext id. Contains the value of the !!CONTEXT:
					--           tag that occured prior to this bookmark.
					--     [6] = The name of the generated output file. If blank, there is
					--           no file spliting being done.
					--     [7] = Element number.
				lLevel = 0
				for i = 1 to length(vElements) do
					if vElements[i][1] = 'b' then
						lIdx = vElements[i][2]
						if vBookMarks[lIdx][BM_TYPE] = 'h' then
							lHdIdx = vBookMarks[lIdx][BM_POINTER]
							lLevel = vHeadings[lHdIdx][H_DEPTH]
							lText = append(lText,
								'h' & vHeadings[lHdIdx] &
								vBookMarks[lIdx][BM_ELEMENTS])
						elsif vBookMarks[lIdx][BM_TYPE] = 'a' then
							lText = append(lText,
								'a' & lLevel &
								vBookMarks[lIdx][BM_ELEMENTS])
						end if
					end if
				end for

				break

			case Get_Context then
				lText = vCurrentContext
				break

			case Get_Styles then
				lText = vStyle
				break

			case Get_Macro then
				lText = map:get(vMacros, upper(trim(pFinalForm_Generator)), "")
				if equal(pContext,0) then
					lText = call_func(vMacro_Processor_rid, { lText, "" })
				end if
				break

			case Set_Macro then
				map:put(vMacros, upper(trim(pFinalForm_Generator)), pContext)
				break

			case Disallow then
				switch pFinalForm_Generator do
					case MU_Bold then
						vAllowedDecorations = seq:remove_all('*', vAllowedDecorations)
						break

					case MU_Italic then
						vAllowedDecorations = seq:remove_all('/', vAllowedDecorations)
						break

					case MU_Monospace then
						vAllowedDecorations = seq:remove_all('#', vAllowedDecorations)
						break

					case MU_Underline then
						vAllowedDecorations = seq:remove_all('_', vAllowedDecorations)
						break

					case MU_Superscript then
						vAllowedDecorations = seq:remove_all('^', vAllowedDecorations)
						break

					case MU_Subscript then
						vAllowedDecorations = seq:remove_all(',', vAllowedDecorations)
						break

					case MU_Strikethru then
						vAllowedDecorations = seq:remove_all('-', vAllowedDecorations)
						break

					case MU_Insert then
						vAllowedDecorations = seq:remove_all('+', vAllowedDecorations)
						break

					case MU_CamelCase then
						vAllowCamelCase = 0
						break

				end switch
				break

			case Allow then
				switch pFinalForm_Generator do
					case MU_Bold then
						vAllowedDecorations = seq:add_item('*', vAllowedDecorations)
						break

					case MU_Italic then
						vAllowedDecorations = seq:add_item('/', vAllowedDecorations)
						break

					case MU_Monospace then
						vAllowedDecorations = seq:add_item('#', vAllowedDecorations)
						break

					case MU_Underline then
						vAllowedDecorations = seq:add_item('_', vAllowedDecorations)
						break

					case MU_Superscript then
						vAllowedDecorations = seq:add_item('^', vAllowedDecorations)
						break

					case MU_Subscript then
						vAllowedDecorations = seq:add_item(',', vAllowedDecorations)
						break

					case MU_Strikethru then
						vAllowedDecorations = seq:add_item('-', vAllowedDecorations)
						break

					case MU_Insert then
						vAllowedDecorations = seq:add_item('+', vAllowedDecorations)
						break

					case MU_CamelCase then
						vAllowCamelCase = 1
						break

				end switch
				break

			case Set_Option then
				switch pFinalForm_Generator do
				case CO_MaxNumLevel then
						if integer(pContext) and pContext >= 0 then
							vMaxNumLevel = pContext
						end if
						break

				case CO_UpperCase then
						if t_bytearray(pContext) then
							vUpperCase = pContext
						end if
						break

				case CO_LowerCase then
						if t_bytearray(pContext) then
							vLowerCase = pContext
						end if
						break

				case CO_SpecialWordChars then
						if t_bytearray(pContext) then
							vSpecialWordChars = pContext
						end if
						break

				case CO_Digits then
						if t_bytearray(pContext) then
							vDigits = pContext
						end if
						break

				case CO_CodeColors then
						if sequence(pContext) and length(pContext) = 10 then
							for i = 1 to 10 do
								if t_bytearray(pContext[i]) = 0 then
									break
								end if
							end for
							vCodeColors = pContext
						end if
						break

				case CO_Protocols then
						if sequence(pContext) then
							for i = 1 to length(pContext) do
								if t_bytearray(pContext[i]) = 0 then
									break
								end if
							end for
							vProtocols = upper(pContext )
							for i = 1 to length(vProtocols) do
								if pContext[i][$] != ':' then
									pContext[i] &= ':'
								end if
							end for

						end if
						break

				case CO_SplitLevel then
						if integer(pContext) and pContext >= 0 then
							if vSplitLevel = 0 then
								vOutputFile = append(vOutputFile, sprintf("%s_%04d", {vSplitName, length(vOutputFile)+1}))
							end if
							vSplitLevel = pContext
						end if
						break

				case CO_SplitName then
						if t_bytearray(pContext) and length(pContext) > 0 then
							vSplitName = pContext
						end if
						break

				case CO_AllowMacros then

						if eu:find(pContext, {1, "yes", "YES", "on", "ON", "1", "Y", "y", "true", "TRUE"}) then
							vAllowMacros = 1
						else
							vAllowMacros = 0
						end if
						break

				case CO_Verbose then
						vVerbose = 1
						
				case else
					break

				end switch

				break

			case else
				break

		end switch

		return lText

	else
		if pFinalForm_Generator <  0 then
			return "*ERROR* No Final Form Generator supplied."
		end if

		vFinal_Generator_rid = pFinalForm_Generator

		if atom(pContext) then
			vCurrentContext = sprintf("%g", pContext)
		else
			vCurrentContext = pContext
		end if


		vHostID = Generate_Final(HostID)
		vReparseHeading = Generate_Final(OptReparseHeadings)
		vSplitLevel = 0
		vOutputFile = {}

		-- Standardise line endings
		lFrom = 1
		integer has_nl = eu:find('\n', pRawText)
		while 1 do
			lPos = find_from('\r', pRawText, lFrom)
			if lPos = 0 then
				exit
			end if
			
			if lPos < length(pRawText) then
				if pRawText[lPos + 1] = '\n' then
					pRawText[lPos] = ' '
				elsif has_nl = 0 then
					pRawText[lPos] = '\n'
				else
					pRawText[lPos] = ' '
				end if
			end if
			lFrom = lPos + 1
		end while
		if vVerbose then
			puts(1, "Processing macros.\n")
		end if
		lText = process_macros( pRawText, "" )

		if length(lText) > 0 then
			-- Ensure that the last line of text actually has a line-end character.
			if lText[$] != '\n' then
				lText &= '\n'
			end if
		end if
		
		if vVerbose then
			printf(1, "Processing text (%d bytes).\n", length(lText))
		end if

		lText = parse_text( lText )

		-- Resolve any local links.
		if vVerbose then
			puts(1, "Processing local links.\n")
		end if
		lFrom = 1
		for i = 1 to length(vUnresolved) do
			if vVerbose then
				printf(1, "Local Link #%5d of %5d (%s)\n", {i,length(vUnresolved),vUnresolved[i][2]})
			end if
			lIdx = find_bookmark(vUnresolved[i][1], vUnresolved[i][2], vUnresolved[i][3], vUnresolved[i][4],
			vUnresolved[i][5])
			if lIdx = 0 then
				lPluginResult = Generate_Final(InternalLink,{"unresolved", vUnresolved[i][2]})
				if vVerbose then
					printf(1, "Unresolved link='%s' display='%s' context='%s'\n", vUnresolved[i][1..3])
				end if
			else

				sequence lFileName
				if length(vBookMarks[lIdx][5]) != 0 then
					lFileName = filebase(vBookMarks[lIdx][5])
				else
					lFileName = filebase(vBookMarks[lIdx][4])
				end if
				lPluginResult = Generate_Final(QualifiedLink, {lFileName,
													vBookMarks[lIdx][3], vUnresolved[i][2]})
			end if

			lPos = match_from({TAG_UNRESOLVED, i}, lText, lFrom)
			if lPos > 0 then
				lText = replace( lText, lPluginResult, lPos, lPos + 1 )
				lFrom += length(lPluginResult) - 2
			end if
		end for

		-- Run any plugins now
		if vVerbose then
			puts(1, "Processing plugins.\n")
		end if
		lPluginResult = repeat(' ', length(vPluginList))
		integer lPluginLength = 0

		for i = 1 to length(vPluginList) do
			if vVerbose then
				printf(1, "Generating plugin #%5d of %5d\n", {i,length(vPluginList)})
			end if
			lPluginResult[i] = Generate_Final(Plugin, vPluginList[i])
			if length(lPluginResult[i]) < 2 then
				lPluginResult[i] &= repeat(' ', 2 - length(lPluginResult[i]))
			end if
			lPluginLength += length(lPluginResult[i])
		end for
		
		integer lEndPos = length(lText)

		lFrom = 1
		lText &= repeat(' ', lPluginLength - (2 * length(vPluginList)))

		for i = 1 to length(vPluginList) do
			lPos = match_from({TAG_PLUGIN, i}, lText, lFrom)
			if vVerbose then
				printf(1, "Inserting plugin #%5d of %5d\n", {i,length(vPluginList)})
			end if
			if lPos > 0 then
				lText[lPos + length(lPluginResult[i]) .. lEndPos + length(lPluginResult[i]) - 2 ] = lText[lPos + 2 .. lEndPos]
				lText[lPos .. lPos + length(lPluginResult[i]) - 1] = lPluginResult[i]
				lFrom = lPos + length(lPluginResult[i])
				lEndPos += length(lPluginResult[i]) - 2
			end if
		end for

		if length(vOutputFile) > 0 then
			if vVerbose then
				puts(1, "Splitting into files.\n")
			end if
			lMultiText = {}
			lFrom = 1
			lFileNo = 1

			while lPos != 0 with entry do
				if lPos > lFrom then
					if vVerbose then
						printf(1, "Creating file #%d\n", lFileNo)
					end if
					lMultiText = append(lMultiText, {vOutputFile[lFileNo],
						Generate_Final(Document,{lText[lFrom .. lPos - 1],vOutputFile[lFileNo] })})
				end if
				lFrom = lPos + 1
				lFileNo += 1
			  entry
				lPos = find_from(TAG_ENDFILE, lText, lFrom)
			end while
			if vVerbose then
				printf(1, "Creating file #%d\n", lFileNo)
			end if
			lMultiText = append(lMultiText, {vOutputFile[lFileNo],
				Generate_Final(Document,{lText[lFrom .. $],vOutputFile[lFileNo]})})
			return lMultiText
		else
			return Generate_Final(Document, {lText, ""})
		end if
	end if
end function



include std/map.e
include std/unittest.e
include mvc/json.e

--
-- JSON Example
-- https://json.org/example.html
--

map json_cache = map:new()

procedure test_compare( sequence name, object expected )

    if not map:has( json_cache, name ) then
        map:put( json_cache, name, json_parse_file(name) )
    end if

    object outcome = map:get( json_cache, name )
    test_equal( name, 0, json_compare(expected,outcome) )

end procedure

procedure test_fetch( sequence name, sequence key, object expected )

    if not map:has( json_cache, name ) then
        map:put( json_cache, name, json_parse_file(name) )
    end if

    object outcome = map:get( json_cache, name )
    test_equal( name & "/" &  key, expected, json_fetch(outcome,key) )

end procedure

set_test_verbosity( TEST_SHOW_ALL )

test_compare( "glossary.json", {JSON_OBJECT, {
    {"glossary", {JSON_OBJECT, {
        {"title", {JSON_STRING, "example glossary"}},
        {"GlossDiv", {JSON_OBJECT, {
            {"title", {JSON_STRING, "S"}},
            {"GlossList", {JSON_OBJECT, {
                {"GlossEntry", {JSON_OBJECT, {
                    {"ID", {JSON_STRING, "SGML"}},
                    {"SortAs", {JSON_STRING, "SGML"}},
                    {"GlossTerm", {JSON_STRING, "Standard Generalized Markup Language"}},
                    {"Acronym", {JSON_STRING, "SGML"}},
                    {"Abbrev", {JSON_STRING, "ISO 8879:1986"}},
                    {"GlossDef", {JSON_OBJECT, {
                        {"para", {JSON_STRING, "A meta-markup language, used to create markup languages such as DocBook."}},
                        {"GlossSeeAlso", {JSON_ARRAY, {
                            {JSON_STRING, "GML"},
                            {JSON_STRING, "XML"}
                        }}}
                    }}},
                    {"GlossSee", {JSON_STRING, "markup"}}
                }}}
            }}}
        }}}
    }}}
}} )

test_fetch( "glossary.json", "glossary.title", {JSON_STRING, "example glossary"} )
test_fetch( "glossary.json", "glossary.GlossDiv.title", {JSON_STRING,"S"} )
test_fetch( "glossary.json", "glossary.GlossDiv.GlossList.GlossEntry.ID", {JSON_STRING, "SGML"} )
test_fetch( "glossary.json", "glossary.GlossDiv.GlossList.GlossEntry.SortAs", {JSON_STRING, "SGML"} )
test_fetch( "glossary.json", "glossary.GlossDiv.GlossList.GlossEntry.GlossTerm", {JSON_STRING, "Standard Generalized Markup Language"} )
test_fetch( "glossary.json", "glossary.GlossDiv.GlossList.GlossEntry.Acronym", {JSON_STRING, "SGML"} )
test_fetch( "glossary.json", "glossary.GlossDiv.GlossList.GlossEntry.Abbrev", {JSON_STRING, "ISO 8879:1986"} )
test_fetch( "glossary.json", "glossary.GlossDiv.GlossList.GlossEntry.GlossDef.para", {JSON_STRING, "A meta-markup language, used to create markup languages such as DocBook."} )
test_fetch( "glossary.json", "glossary.GlossDiv.GlossList.GlossEntry.GlossDef.GlossSeeAlso", {JSON_ARRAY, { {JSON_STRING,"GML"}, {JSON_STRING,"XML"} }} )
test_fetch( "glossary.json", "glossary.GlossDiv.GlossList.GlossEntry.GlossSee", {JSON_STRING, "markup"} )

test_compare( "menu1.json", {JSON_OBJECT, {
    {"menu", {JSON_OBJECT, {
        {"id", {JSON_STRING, "file"}},
        {"value", {JSON_STRING, "File"}},
        {"popup", {JSON_OBJECT, {
            {"menuitem", {JSON_ARRAY, {
                {JSON_OBJECT, {
                    {"value", {JSON_STRING, "New"}},
                    {"onclick", {JSON_STRING, "CreateNewDoc()"}}
                }},
                {JSON_OBJECT, {
                    {"value", {JSON_STRING, "Open"}},
                    {"onclick", {JSON_STRING, "OpenDoc()"}}
                }},
                {JSON_OBJECT, {
                    {"value", {JSON_STRING, "Close"}},
                    {"onclick", {JSON_STRING, "CloseDoc()"}}
                }}
            }}}
        }}}
    }}}
}} )

test_compare( "menu2.json", {JSON_OBJECT, {
    {"menu", {JSON_OBJECT, {
        {"header", {JSON_STRING, "SVG Viewer"}},
        {"items", {JSON_ARRAY, {
            {JSON_OBJECT, {
                {"id", {JSON_STRING, "Open"}}
            }},
            {JSON_OBJECT, {
                {"id", {JSON_STRING, "OpenNew"}},
                {"label", {JSON_STRING, "Open New"}}
            }},
            {JSON_PRIMITIVE, "null"},
            {JSON_OBJECT, {
                {"id", {JSON_STRING, "ZoomIn"}},
                {"label", {JSON_STRING, "Zoom In"}}
            }},
            {JSON_OBJECT, {
                {"id", {JSON_STRING, "ZoomOut"}},
                {"label", {JSON_STRING, "Zoom Out"}}
            }},
            {JSON_OBJECT, {
                {"id", {JSON_STRING, "OriginalView"}},
                {"label", {JSON_STRING, "Original View"}}
            }},
            {JSON_PRIMITIVE, "null"},
            {JSON_OBJECT, {
                {"id", {JSON_STRING, "Quality"}}
            }},
            {JSON_OBJECT, {
                {"id", {JSON_STRING, "Pause"}}
            }},
            {JSON_OBJECT, {
                {"id", {JSON_STRING, "Mute"}}
            }},
            {JSON_PRIMITIVE, "null"},
            {JSON_OBJECT, {
                {"id", {JSON_STRING, "Find"}},
                {"label", {JSON_STRING, "Find..."}}
            }},
            {JSON_OBJECT, {
                {"id", {JSON_STRING, "FindAgain"}},
                {"label", {JSON_STRING, "Find Again"}}
            }},
            {JSON_OBJECT, {
                {"id", {JSON_STRING, "Copy"}}
            }},
            {JSON_OBJECT, {
                {"id", {JSON_STRING, "CopyAgain"}},
                {"label", {JSON_STRING, "Copy Again"}}
            }},
            {JSON_OBJECT, {
                {"id", {JSON_STRING, "CopySVG"}},
                {"label", {JSON_STRING, "Copy SVG"}}
            }},
            {JSON_OBJECT, {
                {"id", {JSON_STRING, "ViewSVG"}},
                {"label", {JSON_STRING, "View SVG"}}
            }},
            {JSON_OBJECT, {
                {"id", {JSON_STRING, "ViewSource"}},
                {"label", {JSON_STRING, "View Source"}}
            }},
            {JSON_OBJECT, {
                {"id", {JSON_STRING, "SaveAs"}},
                {"label", {JSON_STRING, "Save As"}}
            }},
            {JSON_PRIMITIVE, "null"},
            {JSON_OBJECT, {
                {"id", {JSON_STRING, "Help"}}
            }},
            {JSON_OBJECT, {
                {"id", {JSON_STRING, "About"}},
                {"label", {JSON_STRING, "About Adobe CVG Viewer..."}}
            }}
        }}}
    }}}
}} )

test_compare( "web-app.json", {JSON_OBJECT, {
    {"web-app", {JSON_OBJECT, {
        {"servlet", {JSON_ARRAY, {
            {JSON_OBJECT, {
                {"servlet-name", {JSON_STRING, "cofaxCDS"}},
                {"servlet-class", {JSON_STRING, "org.cofax.cds.CDSServlet"}},
                {"init-param", {JSON_OBJECT, {
                    {"configGlossary:installationAt", {JSON_STRING, "Philadelphia, PA"}},
                    {"configGlossary:adminEmail", {JSON_STRING, "ksm@pobox.com"}},
                    {"configGlossary:poweredBy", {JSON_STRING, "Cofax"}},
                    {"configGlossary:poweredByIcon", {JSON_STRING, "/images/cofax.gif"}},
                    {"configGlossary:staticPath", {JSON_STRING, "/content/static"}},
                    {"templateProcessorClass", {JSON_STRING, "org.cofax.WysiwygTemplate"}},
                    {"templateLoaderClass", {JSON_STRING, "org.cofax.FilesTemplateLoader"}},
                    {"templatePath", {JSON_STRING, "templates"}},
                    {"templateOverridePath", {JSON_STRING, ""}},
                    {"defaultListTemplate", {JSON_STRING, "listTemplate.htm"}},
                    {"defaultFileTemplate", {JSON_STRING, "articleTemplate.htm"}},
                    {"useJSP", {JSON_PRIMITIVE, "false"}},
                    {"jspListTemplate", {JSON_STRING, "listTemplate.jsp"}},
                    {"jspFileTemplate", {JSON_STRING, "articleTemplate.jsp"}},
                    {"cachePackageTagsTrack", {JSON_NUMBER, 200}},
                    {"cachePackageTagsStore", {JSON_NUMBER, 200}},
                    {"cachePackageTagsRefresh", {JSON_NUMBER, 60}},
                    {"cacheTemplatesTrack", {JSON_NUMBER, 100}},
                    {"cacheTemplatesStore", {JSON_NUMBER, 50}},
                    {"cacheTemplatesRefresh", {JSON_NUMBER, 15}},
                    {"cachePagesTrack", {JSON_NUMBER, 200}},
                    {"cachePagesStore", {JSON_NUMBER, 100}},
                    {"cachePagesRefresh", {JSON_NUMBER, 10}},
                    {"cachePagesDirtyRead", {JSON_NUMBER, 10}},
                    {"searchEngineListTemplate", {JSON_STRING, "forSearchEnginesList.htm"}},
                    {"searchEngineFileTemplate", {JSON_STRING, "forSearchEngines.htm"}},
                    {"searchEngineRobotsDb", {JSON_STRING, "WEB-INF/robots.db"}},
                    {"useDataStore", {JSON_PRIMITIVE, "true"}},
                    {"dataStoreClass", {JSON_STRING, "org.cofax.SqlDataStore"}},
                    {"redirectionClass", {JSON_STRING, "org.cofax.SqlRedirection"}},
                    {"dataStoreName", {JSON_STRING, "cofax"}},
                    {"dataStoreDriver", {JSON_STRING, "com.microsoft.jdbc.sqlserver.SQLServerDriver"}},
                    {"dataStoreUrl", {JSON_STRING, "jdbc:microsoft:sqlserver://LOCALHOST:1433;DatabaseName=goon"}},
                    {"dataStoreUser", {JSON_STRING, "sa"}},
                    {"dataStorePassword", {JSON_STRING, "dataStoreTestQuery"}},
                    {"dataStoreTestQuery", {JSON_STRING, "SET NOCOUNT ON;select test='test';"}},
                    {"dataStoreLogFile", {JSON_STRING, "/usr/local/tomcat/logs/datastore.log"}},
                    {"dataStoreInitConns", {JSON_NUMBER, 10}},
                    {"dataStoreMaxConns", {JSON_NUMBER, 100}},
                    {"dataStoreConnUsageLimit", {JSON_NUMBER, 100}},
                    {"dataStoreLogLevel", {JSON_STRING, "debug"}},
                    {"maxUrlLength", {JSON_NUMBER, 500}}
                }}}
            }},
            {JSON_OBJECT, {
                {"servlet-name", {JSON_STRING, "cofaxEmail"}},
                {"servlet-class", {JSON_STRING, "org.cofax.cds.EmailServlet"}},
                {"init-param", {JSON_OBJECT, {
                    {"mailHost", {JSON_STRING, "mail1"}},
                    {"mailHostOverride", {JSON_STRING, "mail2"}}
                }}}
            }},
            {JSON_OBJECT, {
                {"servlet-name", {JSON_STRING, "cofaxAdmin"}},
                {"servlet-class", {JSON_STRING, "org.cofax.cds.AdminServlet"}}
            }},
            {JSON_OBJECT, {
                {"servlet-name", {JSON_STRING, "fileServlet"}},
                {"servlet-class", {JSON_STRING, "org.cofax.cds.FileServlet"}}
            }},
            {JSON_OBJECT, {
                {"servlet-name", {JSON_STRING, "cofaxTools"}},
                {"servlet-class", {JSON_STRING, "org.cofax.cms.CofaxToolsServlet"}},
                {"init-param", {JSON_OBJECT, {
                    {"templatePath", {JSON_STRING, "toolstemplates/"}},
                    {"log", {JSON_NUMBER, 1}},
                    {"logLocation", {JSON_STRING, "/usr/local/tomcat/logs/CofaxTools.log"}},
                    {"logMaxSize", {JSON_STRING, ""}},
                    {"dataLog", {JSON_NUMBER, 1}},
                    {"dataLogLocation", {JSON_STRING, "/usr/local/tomcat/logs/dataLog.log"}},
                    {"dataLogMaxSize", {JSON_STRING, ""}},
                    {"removePageCache", {JSON_STRING, "/content/admin/remove?cache=pages&id="}},
                    {"removeTemplateCache", {JSON_STRING, "/content/admin/remove?cache=templates&id="}},
                    {"fileTransferFolder", {JSON_STRING, "/usr/local/tomcat/webapps/content/fileTransferFolder"}},
                    {"lookInContext", {JSON_NUMBER, 1}},
                    {"adminGroupID", {JSON_NUMBER, 4}},
                    {"betaServer", {JSON_PRIMITIVE, "true"}}
                }}}
            }}
        }}},
        {"servlet-mapping", {JSON_OBJECT, {
            {"cofaxCDS", {JSON_STRING, "/"}},
            {"cofaxEmail", {JSON_STRING, "/cofaxutil/aemail/*"}},
            {"cofaxAdmin", {JSON_STRING, "/admin/*"}},
            {"fileServlet", {JSON_STRING, "/static/*"}},
            {"cofaxTools", {JSON_STRING, "/tools/*"}}
        }}},
        {"taglib", {JSON_OBJECT, {
            {"taglib-uri", {JSON_STRING, "cofax.tld"}},
            {"taglib-location", {JSON_STRING, "/WEB-INF/tlds/cofax.tld"}}
        }}}
    }}}
}} )

test_compare( "widget.json", {JSON_OBJECT, {
    {"widget", {JSON_OBJECT, {
        {"debug", {JSON_STRING, "on"}},
        {"window", {JSON_OBJECT, {
            {"title", {JSON_STRING, "Sample Konfabulator Widget"}},
            {"name", {JSON_STRING, "main_window"}},
            {"width", {JSON_NUMBER, 500}},
            {"height", {JSON_NUMBER, 500}}
        }}},
        {"image", {JSON_OBJECT, {
            {"src", {JSON_STRING, "Images/Sun.png"}},
            {"name", {JSON_STRING, "sun1"}},
            {"hOffset", {JSON_NUMBER, 250}},
            {"vOffset", {JSON_NUMBER, 250}},
            {"alignment", {JSON_STRING, "center"}}
        }}},
        {"text", {JSON_OBJECT, {
            {"data", {JSON_STRING, "Click Here"}},
            {"size", {JSON_NUMBER, 36}},
            {"style", {JSON_STRING, "bold"}},
            {"name", {JSON_STRING, "text1"}},
            {"hOffset", {JSON_NUMBER, 250}},
            {"vOffset", {JSON_NUMBER, 100}},
            {"alignment", {JSON_STRING, "center"}},
            {"onMouseUp", {JSON_STRING, "sun1.opacity = (sun1.opacity / 100) * 90;"}}
        }}}
    }}}
}} )

test_report()

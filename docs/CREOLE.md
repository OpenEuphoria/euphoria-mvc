# Creole

This is the creole parser library lifted from the OpenEuphoria [Creole](https://github.com/OpenEuphoria/creole) project, and has been slightly updated and bundled for use in Euphoria MVC.

## Creole routines

* [`creole_parse`](#creole_parse)

### creole_parse

`include mvc/creole.e`  
`public function creole_parse( object pRawText, object pFinalForm_Generator = -1, object pContext = "" )`

Parses Creole markup and returns plain HTML.

**Parameters**

* **`pRawText`**
* **`pFinalForm_Generator`**
* **`pContext`**


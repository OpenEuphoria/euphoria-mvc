# Templates

## Example

    <!DOCTYPE html>
    <html>
    <head>
      <title>{{title}}</title>
    </head>
    <body>
      <h1>{{title}}</h1>
    </body>
    </html>

## Comments

A **comment** is any text enclosed in `{# .. #}` tags. These will be stripped out of your template before being rendered.

## Expressions

An **expression** is any value enclosed in `{{ .. }}` tags. Expressions can be a variable name, a function call, or a literal value.

**Notes**

- The expression parser is very simple and only expects *one expression* per block. If you need to evaluate a complex expression,
  use `add_function()` to register a custom function that will perform the expression and return the result.
- The expression parser *is recursive* so it should understand *nested* expressions, like `not( equal( length(x), 0 ) )`, although
  it's still adviseable to limit the depth of these expressions and utlize functions for complex logic.

### Dot notation

Map properties can be retrieved using dot notation, e.g. `item.property`.

## Functions

You can register **functions** that can be called by the template parser to perform some complex logic, data lookup, etc. and then
return a value to be rendered into the output. The following functions are provided by default:

### Object functions

* **atom( object x )** -- Returns `TRUE` if `object x` is an `atom`.
* **integer( object x )** -- Returns `TRUE` if `object x` is an `integer`.
* **sequence( object x )** -- Returns `TRUE` if `object x` is a `sequence`.
* **object( object x )** -- Returns `TRUE` if `object x` is an `object`.
* **isset( object x )** -- Returns `TRUE` if `object x` is set in the current response.

### Boolean functions

* **equal( object a, object b )** -- Returns `TRUE` if `object a` equals `object b`.
* **not_equal( object a, object b )** -- Returns `TRUE` if `object a` does *not* equal `object b`.
* **length( object x )** -- Returns the length of `object x`.
* **not( object x )** -- Returns the opposite boolean value of `object x`.

### Math functions

* **and( object a, object b )** -- Returns the boolean result of `object a` and `object b`.
* **or( object a, object b )** -- Returns the boolean result of `object a` or `object b`.
* **xor( object a, object b )** -- Returns the boolean result of `object a` xor `object b`.

### Formatting functions

* **format( object x, object p )** -- Returns a formatted string via `text:format()`.
* **pretty( object x, object p = PRETTY_DEFAULT )** -- Returns a formatted string via `pretty_print()`.
* **sprintf( object x, object d )** -- Returns a formatted string via `eu:sprintf()`.

### Math functions

* **add( object a, object b )** -- Returns the value of `object a` plus `object b`.
* **subtract( object a, object b )** -- Returns the value of `object a` minus `object b`.
* **multiply( object a, object b )** -- Returns the value of `object a` times `object b`.
* **divide( object a, object b )** -- Returns the value of `object a` divided by `object b`.

### Datetime functions

* **format_date( object d, object f="%Y-%m-%d" )** -- Returns a formatted date via `datetime:format()`.
* **format_time( object d, object f="%H:%M:%S" )** -- Returns a formatted time via `datetime:format()`.
* **dt( object d, object f="%Y-%m-%d %H:%M:%S" )** -- Returns a formatted datetime via `datetime:format()`.

### Conversion functions

* **to_integer( object x, object d=0 )** -- Converts an object to an integer via `convert:to_integer()`.
* **to_number( object x, object p=0 )** -- Converts an object to a number via `convert:to_number()`.
* **to_string( object x, object q=0, object e='"' )** -- Converts an object to a string via `convert:to_string()`.

## Statements

A **statement** is one of the following enclosed in `{% .. %}` tags.

### if

**if** ... **elsif** ... **else** ... **end if**

    {% if expression then %}
        <p>content if true</p>
    {% elsif expression then %}
        <p>another possibly true expression</p>
    {% else %}
        <p>content if false</p>
    {% end if %}

### for

**for** _variable_ **=** _expression_ **to** _expression_ **do**

    <ul>
    {% for i = 1 to 10 do %}
      <li>Item {{i}}</li>
    {% end for %}
    </ul>

**for** _variable_ **=** _expression_ **to** _expression_ **by** _expression_ **do**

    <ul>
    {% for i = 1 to 10 by 2 do %}
      <li>Item {{i}}</li>
    {% end for %}
    </ul>

**for** _variable_ **in** _expression_ **do**

    <table>
      <tr>
        <th>Name</th>
        <th>Size</th>
        <th>Type</th>
        <th>Last modified</th>
      </tr>
    {# we assume list is a sequence of maps #}
    {% for item in list do %}
      <tr>
        <td>{{item.name}}</td>
        <td>{{item.size}}</td>
        <td>{{item.type}}</td>
        <td>{{item.last_modified}}</td>
      </tr>
    {% end for %}
    </table>

### collapse

**collapse**

A collapse statement will collapse all lengths of whitespace to a single space and remove any leading and trailing whitespace.
This is helpful when you want to add line breaks and indents to your template statements for clarity, but have the output be
returned without any additional of the formatting.

If you have this code in your template:

    <title>{% collapse %}
        {% if isset(page_title) %}
          {{ page_title }} -
        {% end if %}
        {{ site_title }}
    {% end collapse %}</title>

This is the output if `page_title` is set:

    <title>Page Title - Site Title</title>

And this is the output if `page_title` is not set:

    <title>Site Title</title>

### extends

**extends** _filename_

The extends statement allows for parent/child relationships between templates. You can define a single parent "layout" template,
and then *extend* that template in all your other templates.

    {% extends "layout.html" %}

### block

**block** _name_

Blocks are named sections used between templates. Blocks in your layout template shoudld be empty, as they will be replaced by
matching blocks from the page template.

If this is your layout template:

    <body>
      <section name="content">
      {% block content %}{% end block %}
      </section>
    </body>

And this is your page template:

    {% extends "layout.html" %}
    {% block content %}
        <p>This is where my content goes!</p>
    {% end block %}

Then your rendered template will look something like this:

    <body>
      <section name="content">
        <p>This is where my content goes!</p>
      </section>
    </body>

## Jinja compatibility

The follow statement keywords can be used for compatibility with Jinja:

| Euphoria MVC | Jinja        |
| ------------ | ------------ |
| **do**       | _not used_   |
| **end for**  | **endfor**   |
| **end if**   | **endif**    |
| **elsif**    | **elif**     |
| **then**     | _not used_   |

## Template routines

* [`add_function`](#add_function)
* [`render_template`](#render_template)
* [`set_template_path`](#set_template_path)

### add_function

`include mvc/template.e`  
`public procedure add_function( sequence func_name, sequence params = {}, integer func_id  = routine_id(func_name) )`

Add a function that can be called from an **expression**.

**Parameters**

- **`func_name`** - name of the function to add
- **`params`** - list of parameter names
- **`func_id`** - the routine_id() of the function

### render_template

`include mvc/template.e`  
`public function render_template( sequence filename, object response = {}, integer free_response = TRUE )`

Render a template with the given response object.

**Parameters**

- **`template`** - your template file name
- **`response`** - your map or sequence of template values
- **`free_reponse`** - whether or not your `response` object should be freed by calling `delete()`

**Returns**

The completely rendered output from the template file.

### set_template_path

`include mvc/template.e`  
`public procedure set_template_path( sequence path )`

Sets the path to where template files live. By default, this is just `templates` in the current directory.

**Parameters**

- **`path`** - path to where template files live


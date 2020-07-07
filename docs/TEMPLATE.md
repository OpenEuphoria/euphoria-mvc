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

## Concepts

### Comments

A **comment** is any text enclosed in `{# .. #}` tags. These will be stripped out of your template before being rendered.

### Expressions

An **expression** is any value enclosed in `{{ .. }}` tags. Expressions can be a variable name, a function call, or a literal value.

**Notes**

- The expression parser is very simple and only expects *one expression* per block. If you need to evaluate a complex expression, use `add_function()` to register a custom function that will perform the expression and return the result.
- The expression parser *is recursive* so it should understand *nested* expressions, like `not( equal( length(x), 0 ) )`, although it's still adviseable to limit the depth of these expressions and utlize functions for complex logic.

### Dot notation

Map properties can be retrieved using dot notation, e.g. `item.property`.

### Functions

You can register **functions** that can be called by the template parser to perform some complex logic, data lookup, etc. and then return a value to be rendered into the output.

The following functions are provided by default:

* `atom( object x )`
* `integer( object x )`
* `sequence( object x )`
* `object( object x )`
* `equal( object a, object b )`
* `not_equal( object a, object b )`
* `length( object x )`
* `not( object x )`
* `and( object a, object b )`
* `or( object a, object b )`
* `xor( object a, object b )`
* `pretty( object x, object p = PRETTY_DEFAULT )` -- pretty print an object

### Statements

A **statement** is one of the following enclosed in `{% .. %}` tags.

**if**

    {% if expression %}
        <p>content if true</p>
    {% elsif expression %}
        <p>another possibly true expression</p>
    {% else %}
        <p>content if false</p>
    {% end if %}

**for _expression_ to _expresion_**

    <ul>
    {% for i = 1 to 10 %}
      <li>Item {{i}}</li>
    {% end for %}
    </ul>

**for _expression_ to _expression_ by _expression_**

    <ul>
    {% for i = 1 to 10 by 2 %}
      <li>Item {{i}}</li>
    {% end for %}
    </ul>

**for _variable_ in _expression_**

    <table>
      <tr>
        <th>Name</th>
        <th>Size</th>
        <th>Type</th>
        <th>Last modified</th>
      </tr>
    {# we assume list is a sequence of maps #}
    {% for item in list %}
      <tr>
        <td>{{item.name}}</td>
        <td>{{item.size}}</td>
        <td>{{item.type}}</td>
        <td>{{item.last_modified}}</td>
      </tr>
    {% end for %}
    </table>

**extends**

The extends statement allows for parent/child relationships between templates. You can define a single parent "layout" template, and then *extend* that template in all your other templates.

    {% extends "layout.html" %}

**block**

Blocks are named sections used between templates. Blocks in your layout template shoudld be empty, as they will be replaced by matching blocks from the page template.

If this is your layout template:

    <body>
      <section name="content">
      {% block content %}{% end block %}
      </section>
    </body>

And this is your page template:

    {% extends layout.html %}
    {% block content %}
        <p>This is where my content goes!</p>
    {% end block %}

Then your rendered template will look something like this:

    <body>
      <section name="content">
        <p>This is where my content goes!</p>
      </section>
    </body>

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


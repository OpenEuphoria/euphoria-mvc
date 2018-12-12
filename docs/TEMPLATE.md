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

A **comment** is any text enclosed in `{# .. #}` tags.

### Expressions

An **expression** is any value enclosed in `{{ .. }}` tags.

Expressions can be a variable name, a function call, or a literal value.

Map properties can be retrieved using dot notation, e.g. `item.property`.

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

**block**

Blocks are named sections used between templates. Blocks in your layout template shoudld be empty, as they will be replaced by matching blocks from the primary template.

If this is your layout:

    <body>
      <section name="content">
      {% block content %}{% end block %}
      </section>
    </body>

And this is your primary template:

    {% extends layout.html %}
    {% block content %}
        <p>This is where my content goes!</p>
    {% end block %}

Then your rendered template will look like this:

    <body>
      <section name="content">
        <p>This is where my content goes!</p>
      </section>
    </body>

## Template routines

### add_function

`include mvc/template.e`  
`add_function( sequence func_name, sequence params, integer func_id )`

Add a function that can be called from an **expression**.

**Parameters**

- **`func_name`** - name of the function to add
- **`params`** - list of parameter names
- **`func_id`** - the routine_id() of the function

### render_template

`include mvc/template.e`  
`public function render_template( sequence template, object response )`

Render a template with the given response object.

**Parameters**

- **`template`** - your template file name
- **`response`** - your map or sequence of template values

### set_template_path

`include mvc/template.e`  
`public procedure set_template_path( sequence path )`

Sets the path to where template files live. By default, this is just `templates` in the current directory.

**Parameters**

- **`path`** - path to where template files live


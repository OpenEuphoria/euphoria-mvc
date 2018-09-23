# Templates

## Example

    <!DOCTYPE html>
    <html>
    <head>
      <title>{{title}</title>
    </head>
    <body>
      <h1>{{title}}</h1>
    </body>
    </html>

## Template routines

### render_template

`include mvc/template.e`  
`public function render_template( sequence template, object response )`

- **`template`** - your template file name
- **`response`** - your map or sequence of template values

## Comment block

A comment is any text enclosed in `{# .. #}` tags.

## Expression block

An expression block is any value enclosed in `{{ .. }}` tags.

Expressions can be a variable name, a function call, or a literal value.

## Statement blocks

Statement blocks are enclosed in `{% .. %}` tags.

### if statement

    {% if expression %}
    <p>content if true</p>
    {% elsif expression %}
    <p>another possibly true expression</p>
    {% else %}
    <p>content if false</p>
    {% end if %}

### for statement

A couting loop

    <ul>
    {% for i = 1 to 10 %}
      <li>Item {{i}}</li>
    {% end for %}
    </ul>

A couting loop with steps

    <ul>
    {% for i = 1 to 10 by 2 %}
      <li>Item {{i}}</li>
    {% end for %}
    </ul>

An item list loop

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

### extends statement

The extends statement allows for parent/child relationships between templates. You can define a single parent "layout" template, and then *extend* that template in all your other templates.

### block statement

Blocks are named sections used between templates. Blocks in your layout template shoudld be empty, as they will be replaced by matching blocks from the original template.

**Layout template**

    <section name="content">
    {% block content %}{% end block %}
    </section>

**Orignal template**

    {% extends layout.html %}
    {% block content %}
    <p>This is where my content goes!</p>
    {% end block %}


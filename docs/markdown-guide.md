# GUÍA DE MARKDOWN

Nota: esta guía está totalmente basada en la guía de [DaringFireball](https://daringfireball.net/projects/markdown/syntax). y traducida al español.

## ELEMENTOS EN BLOQUE

### ENCABEZADOS

Markdown admite dos estilos de encabezados, Setext y atx.

Los encabezados de estilo de texto están "subrayados" usando signos de igual (para encabezados de primer nivel) y guiones (para encabezados de segundo nivel). Por ejemplo:

    This is an H1
    =============

    This is an H2
    -------------
Cualquier número de subrayado = 's o' funcionará.

Los encabezados de estilo Atx usan 1-6 caracteres hash al comienzo de la línea, correspondientes a los niveles de encabezado 1-6. Por ejemplo:

    # This is an H1
    
    ## This is an H2
    
    ###### This is an H6
    
Opcionalmente, puede "cerrar" los encabezados de estilo atx. Esto es puramente cosmético; puede usarlo si cree que se ve mejor. Los hashes de cierre ni siquiera necesitan coincidir con el número de hashes utilizados para abrir el encabezado. (El número de hashes de apertura determina el nivel del encabezado):

    # This is an H1 #
    
    ## This is an H2 ##
    
    ### This is an H3 ######

### CITAS EN BLOQUE

Markdown utiliza caracteres de estilo de correo electrónico > para comillas en bloque. Si está familiarizado con citar pasajes de texto en un mensaje de correo electrónico, entonces sabe cómo crear una cita en bloque en Markdown. Se ve mejor si ajusta firmemente el texto y pone un > antes de cada línea:


    > This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,
    > consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
    > Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.
    > 
    > Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse
    > id sem consectetuer libero luctus adipiscing.
    Markdown allows you to be lazy and only put the > before the first line of a hard-wrapped paragraph:
    
    > This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,
    consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
    Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.
    
    > Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse
    id sem consectetuer libero luctus adipiscing.

Las citas en bloque se pueden anidar (es decir, una cita en bloque en una cita en bloque) agregando niveles adicionales de >:
    
    > This is the first level of quoting.
    >
    > > This is nested blockquote.
    >
    > Back to the first level.

Las citas en bloque pueden contener otros elementos de Markdown, incluidos encabezados, listas y bloques de código:

    > ## This is a header.
    > 
    > 1.   This is the first list item.
    > 2.   This is the second list item.
    > 
    > Here's some example code:
    > 
    >     return shell_exec("echo $input | $markdown_script");

Cualquier editor de texto decente debería facilitar las citas al estilo del correo electrónico. Por ejemplo, con BBEdit, puede hacer una selección y elegir Aumentar Nivel de Cita en el menú Texto.

### LISTS

Markdown admite listas ordenadas (numeradas) y no ordenadas (con viñetas).

Las listas desordenadas utilizan asteriscos, más y guiones - de manera intercambiable - como marcadores de lista:

    *   Red
    *   Green
    *   Blue

es equivalente a:

    +   Red
    +   Green
    +   Blue

y:

    -   Red
    -   Green
    -   Blue

Las listas ordenads usan numeros seguidas de puntos:

    1.  Bird
    2.  McHale
    3.  Parish

Es importante tener en cuenta que los números que usas para marcar la lista no tienen efecto en la salida HTML que Markdown produce. El HTML Markdown que produce la lista anterior es:

    <ol>
    <li>Bird</li>
    <li>McHale</li>
    <li>Parish</li>
    </ol>

Si en cambio escribiste la lista en Markdown así:

    1.  Bird
    1.  McHale
    1.  Parish

o incluso:

    3. Bird
    1. McHale
    8. Parish

obtendrías exactamente la misma salida HTML. El punto es que, si lo deseas, puedes usar números ordinales en sus listas de Markdown ordenadas, para que los números en su fuente coincidan con los números en su HTML publicado. Pero si quieres ser flojo, no tienes que hacerlo.

Sin embargo, si utilizas la numeración de la lista diferida, aún debes comenzar la lista con el número 1. En algún momento en el futuro, Markdown puede admitir el inicio de listas ordenadas en un número arbitrario.

Los marcadores de lista generalmente comienzan en el margen izquierdo, pero pueden estar indentados por hasta tres espacios. Los marcadores de lista deben ir seguidos de uno o más espacios o una pestaña.
To make lists look nice, you can wrap items with hanging indents:

    *   Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
        Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi,
        viverra nec, fringilla in, laoreet vitae, risus.
    *   Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
        Suspendisse id sem consectetuer libero luctus adipiscing.

Pero si quieres ser flojo, no tienes que:

    *   Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
    Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi,
    viverra nec, fringilla in, laoreet vitae, risus.
    *   Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
    Suspendisse id sem consectetuer libero luctus adipiscing.

Si los elementos de la lista están separados por líneas en blanco, Markdown ajustará los elementos en etiquetas `<p>` en la salida HTML. Por ejemplo, esta entrada:

    *   Bird
    *   Magic

Se convertirá en:

    <ul>
    <li>Bird</li>
    <li>Magic</li>
    </ul>

Pero esto:

    *   Bird
    
    *   Magic

Se convertirá en:

    <ul>
    <li><p>Bird</p></li>
    <li><p>Magic</p></li>
    </ul>

Los elementos de la lista pueden consistir en múltiples párrafos. Cada párrafo posterior en un elemento de la lista debe estar sangrado por 4 espacios o una pestaña:

    1.  This is a list item with two paragraphs. Lorem ipsum dolor
        sit amet, consectetuer adipiscing elit. Aliquam hendrerit
        mi posuere lectus.
    
        Vestibulum enim wisi, viverra nec, fringilla in, laoreet
        vitae, risus. Donec sit amet nisl. Aliquam semper ipsum
        sit amet velit.
    
    2.  Suspendisse id sem consectetuer libero luctus adipiscing.

Se ve bien si indentas cada línea de los párrafos posteriores, pero aquí nuevamente, Markdown te permitirá ser perezoso:

    *   This is a list item with two paragraphs.
    
        This is the second paragraph in the list item. You're
    only required to indent the first line. Lorem ipsum dolor
    sit amet, consectetuer adipiscing elit.
    
    *   Another item in the same list.

Para colocar una cita en bloque dentro de un elemento de la lista, los delimitadores de la cita (>) en bloque deben indentarse:

    *   A list item with a blockquote:
    
        > This is a blockquote
        > inside a list item.
    To put a code block within a list item, the code block needs to be indented twice — 8 spaces or two tabs:
    
    *   A list item with a code block:
    
            <code goes here>

Vale la pena señalar que es posible activar una lista ordenada por accidente, escribiendo algo como esto:

    1986. What a great season.
    In other words, a number-period-space sequence at the beginning of a line. To avoid this, you can backslash-escape the period:
    
    1986\. What a great season.

### CODE BLOCKS

Los bloques de código formateados previamente se utilizan para escribir sobre código fuente de programación o marcado. En lugar de formar párrafos normales, las líneas de un bloque de código se interpretan literalmente. Markdown envuelve un bloque de código en las etiquetas `<pre>` y `<code>`.

Para producir un bloque de código en Markdown, simplemente sangra cada línea del bloque por al menos 4 espacios o 1 pestaña. Por ejemplo, dada esta entrada:

    This is a normal paragraph:
    
        This is a code block.

Markdown generará:

    <p>This is a normal paragraph:</p>
    
    <pre><code>This is a code block.
    </code></pre>

Se elimina un nivel de sangría, 4 espacios o 1 pestaña, de cada línea del bloque de código. Por ejemplo, esto:

    Here is an example of AppleScript:
    
        tell application "Foo"
            beep
        end tell

Se convertirá en:

    <p>Here is an example of AppleScript:</p>
    
    <pre><code>tell application "Foo"
        beep
    end tell
    </code></pre>

Un bloque de código continúa hasta que alcanza una línea que no está sangrada (o al final del artículo).

Dentro de un bloque de código, los símbolos (&) y los corchetes angulares (<y>) se convierten automáticamente en entidades HTML. Esto hace que sea muy fácil incluir un código fuente HTML de ejemplo usando Markdown: simplemente péguelo e indentifíquelo, y Markdown se encargará de la molestia de codificar los símbolos y los corchetes angulares. Por ejemplo, esto:

    <div class="footer">
        &copy; 2004 Foo Corporation
    </div>

Se convertirá en:

    <pre><code>&lt;div class="footer"&gt;
        &amp;copy; 2004 Foo Corporation
    &lt;/div&gt;
    </code></pre>

La sintaxis de Markdown normal no se procesa dentro de los bloques de código. Por ejemplo, los asteriscos son solo asteriscos literales dentro de un bloque de código. Esto significa que también es fácil usar Markdown para escribir sobre la sintaxis propia de Markdown.

### REGLAS HORIZONTALES

Puede producir una etiqueta de regla horizontal `(<hr />)` colocando tres o más guiones, asteriscos o guiones bajos en una línea por sí mismos. Si lo desea, puede usar espacios entre los guiones o asteriscos. Cada una de las siguientes líneas producirá una regla horizontal:

    * * *
    
    ***
    
    *****
    
    - - -
    
    ---------------------------------------

## ELEMENTOS SPAN

### LINKS

Markdown admite dos estilos de enlaces: en línea y de referencia.

En ambos estilos, el texto del enlace está delimitado por [corchetes].

Para crear un enlace en línea, use un conjunto de paréntesis regulares inmediatamente después del corchete de cierre del texto del enlace. Dentro de los paréntesis, coloque la URL donde desea que apunte el enlace, junto con un título opcional para el enlace, entre comillas. Por ejemplo:

    This is [an example](http://example.com/ "Title") inline link.
    
    [This link](http://example.net/) has no title attribute.

Producirá:

    <p>This is <a href="http://example.com/" title="Title">
    an example</a> inline link.</p>
    
    <p><a href="http://example.net/">This link</a> has no
    title attribute.</p>

Si se refiere a un recurso local en el mismo servidor, puede usar rutas relativas:

    See my [About](/about/) page for details.   

Los enlaces de estilo de referencia usan un segundo conjunto de corchetes, dentro del cual coloca una etiqueta de su elección para identificar el enlace:

    This is [an example][id] reference-style link.

Opcionalmente, puede usar un espacio para separar los conjuntos de corchetes:

    This is [an example] [id] reference-style link.

Luego, en cualquier parte del documento, define su etiqueta de enlace de esta manera, en una línea por sí misma:

    [id]: http://example.com/  "Optional Title Here"

Es decir:

- Corchetes que contienen el identificador de enlace (opcionalmente sangrado del margen izquierdo usando hasta tres espacios);
- seguido de dos puntos;
- seguido de uno o más espacios (o pestañas);
- seguido de la URL del enlace;
- opcionalmente seguido por un atributo de título para el enlace, entre comillas dobles o simples, o entre paréntesis.

Las siguientes tres definiciones de enlace son equivalentes:

    [foo]: http://example.com/  "Optional Title Here"
    [foo]: http://example.com/  'Optional Title Here'
    [foo]: http://example.com/  (Optional Title Here)

NOTA: Hay un error conocido en Markdown.pl 1.0.1 que evita que se usen comillas simples para delimitar los títulos de los enlaces.

La URL del enlace puede, opcionalmente, estar entre corchetes angulares:

    [id]: <http://example.com/>  "Optional Title Here"

Puede colocar el atributo de título en la siguiente línea y usar espacios o pestañas adicionales para el relleno, que tiende a verse mejor con URL más largas:

    [id]: http://example.com/longish/path/to/resource/here
        "Optional Title Here"

Las definiciones de enlace solo se usan para crear enlaces durante el procesamiento de Markdown, y se eliminan de su documento en la salida HTML.

Los nombres de definición de enlace pueden consistir en letras, números, espacios y signos de puntuación, pero no distinguen entre mayúsculas y minúsculas. P.ej. estos dos enlaces:

    [link text][a]
    [link text][A]

son equivalentes

El acceso directo implícito al nombre del enlace le permite omitir el nombre del enlace, en cuyo caso el texto del enlace se usa como nombre. Simplemente use un conjunto vacío de corchetes; por ejemplo, para vincular la palabra "Google" al sitio web google.com, simplemente puede escribir:

    [Google][]

Y luego defina el enlace:

    [Google]: http://google.com/

Como los nombres de los enlaces pueden contener espacios, este acceso directo incluso funciona para varias palabras en el texto del enlace:

    Visit [Daring Fireball][] for more information.

Y entonces, define el link:

    [Daring Fireball]: http://daringfireball.net/

Las definiciones de enlace se pueden colocar en cualquier parte de su documento Markdown. Se tiende a ponerlos inmediatamente después de cada párrafo en el que se usan, pero si lo desea, puede ponerlos todos al final de su documento, como notas a pie de página.

Aquí hay un ejemplo de enlaces de referencia en acción:

    I get 10 times more traffic from [Google] [1] than from
    [Yahoo] [2] or [MSN] [3].
    
      [1]: http://google.com/        "Google"
      [2]: http://search.yahoo.com/  "Yahoo Search"
      [3]: http://search.msn.com/    "MSN Search"

Usando el acceso directo de nombre de enlace implícito, en su lugar podría escribir:

    I get 10 times more traffic from [Google][] than from
    [Yahoo][] or [MSN][].

      [google]: http://google.com/        "Google"
      [yahoo]:  http://search.yahoo.com/  "Yahoo Search"
      [msn]:    http://search.msn.com/    "MSN Search"

Los dos ejemplos anteriores producirán la siguiente salida HTML:

    <p>I get 10 times more traffic from <a href="http://google.com/"
    title="Google">Google</a> than from
    <a href="http://search.yahoo.com/" title="Yahoo Search">Yahoo</a>
    or <a href="http://search.msn.com/" title="MSN Search">MSN</a>.</p>

A modo de comparación, aquí está el mismo párrafo escrito con el estilo de enlace en línea de Markdown:

    I get 10 times more traffic from [Google](http://google.com/ "Google")
    than from [Yahoo](http://search.yahoo.com/ "Yahoo Search") or
    [MSN](http://search.msn.com/ "MSN Search").

El punto de los enlaces de estilo de referencia no es que sean más fáciles de escribir. El punto es que con los enlaces de estilo de referencia, la fuente de su documento es mucho más legible. Compare los ejemplos anteriores: usando enlaces de estilo de referencia, el párrafo en sí solo tiene 81 caracteres de longitud; con enlaces de estilo en línea, tiene 176 caracteres; y como HTML sin procesar, tiene 234 caracteres. En el HTML sin formato, hay más marcado que texto.

Con los enlaces de estilo de referencia de Markdown, un documento fuente se parece mucho más a la salida final, tal como se representa en un navegador. Al permitirle mover los metadatos relacionados con el marcado fuera del párrafo, puede agregar enlaces sin interrumpir el flujo narrativo de su prosa.

### ÉNFASIS

Markdown trata los asteriscos (*) y los guiones bajos (_) como indicadores de énfasis. El texto envuelto con uno * o _ se envolverá con una etiqueta HTML `<em>`; los dobles * ’o _’s se envolverán con una etiqueta HTML `<strong>`. Por ejemplo, esta entrada:

    *single asterisks*
    
    _single underscores_
    
    **double asterisks**
    
    __double underscores__

producirá:

    <em>single asterisks</em>
    
    <em>single underscores</em>
    
    <strong>double asterisks</strong>
    
    <strong>double underscores</strong>

Puedes usar el estilo que prefieras; La única restricción es que se debe usar el mismo carácter para abrir y cerrar un intervalo de énfasis.

El énfasis se puede usar en medio de una palabra:

    un*frigging*believable

Pero si rodea un * o _ con espacios, se tratará como un asterisco literal o guión bajo.

Para producir un asterisco literal o un guión bajo en una posición donde de otro modo se usaría como un delimitador de énfasis, puede hacer una barra invertida para escapar de él:

    \*this text is surrounded by literal asterisks\*

Para indicar un intervalo de código, envuélvalo con comillas de retroceso (`). A diferencia de un bloque de código preformateado, un intervalo de código indica código dentro de un párrafo normal. Por ejemplo:

    Use the `printf()` function.

producirá:

    <p>Use the <code>printf()</code> function.</p>

Para incluir un carácter de retroceso literal dentro de un intervalo de código, puede usar múltiples retrocesos como delimitadores de apertura y cierre:

    ``There is a literal backtick (`) here.``

que producirá esto:

    <p><code>There is a literal backtick (`) here.</code></p>

Los delimitadores de retroceso que rodean un tramo de código pueden incluir espacios, uno después de la apertura, uno antes del cierre. Esto le permite colocar caracteres de retroceso literal al principio o al final de un intervalo de código:

    A single backtick in a code span: `` ` ``
    
    A backtick-delimited string in a code span: `` `foo` ``

producirá:

    <p>A single backtick in a code span: <code>`</code></p>
    
    <p>A backtick-delimited string in a code span: <code>`foo`</code></p>

Con una extensión de código, los signos de unión y los corchetes angulares se codifican automáticamente como entidades HTML, lo que facilita la inclusión de ejemplos de etiquetas HTML. Markdown convertirá esto:

    Please don't use any `<blink>` tags.

en:

    <p>Please don't use any <code>&lt;blink&gt;</code> tags.</p>

Puedes escribir esto:

    `&#8212;` is the decimal-encoded equivalent of `&mdash;`.

para producir:

    <p><code>&amp;#8212;</code> is the decimal-encoded
    equivalent of <code>&amp;mdash;</code>.</p>

### IMÁGENES

Es cierto que es bastante difícil diseñar una sintaxis "natural" para colocar imágenes en un formato de documento de texto sin formato.

Markdown utiliza una sintaxis de imagen que pretende parecerse a la sintaxis de los enlaces, lo que permite dos estilos: en línea y de referencia.

La sintaxis de la imagen en línea se ve así:

    ![Alt text](/path/to/img.jpg)
    
    ![Alt text](/path/to/img.jpg "Optional title")

Es decir:

- Un signo de exclamación:!;
- seguido de un conjunto de corchetes, que contiene el texto del atributo alt para la imagen;
- seguido de un conjunto de paréntesis, que contiene la URL o la ruta a la imagen, y un atributo de título opcional entre comillas dobles o simples.

La sintaxis de la imagen de estilo de referencia se ve así:

    ![Alt text][id]

Donde "id" es el nombre de una referencia de imagen definida. Las referencias de imagen se definen utilizando una sintaxis idéntica a las referencias de enlace:

    [id]: url/to/image  "Optional title attribute"

Al escribir estas líneas, Markdown no tiene sintaxis para especificar las dimensiones de una imagen; Si esto es importante para usted, simplemente puede usar etiquetas HTML normales `<img>`.

## MISCELÁNEO
### LINKS AUTOMÁTICOS

Markdown admite un estilo de acceso directo para crear enlaces "automáticos" para URL y direcciones de correo electrónico: simplemente rodee la URL o la dirección de correo electrónico con corchetes angulares. Lo que esto significa es que si desea mostrar el texto real de una URL o dirección de correo electrónico, y también hacer que sea un enlace en el que se pueda hacer clic, puede hacer esto:

    <http://example.com/>

Markdown convertirá esto en:

    <a href="http://example.com/">http://example.com/</a>

Los enlaces automáticos para direcciones de correo electrónico funcionan de manera similar, excepto que Markdown también realizará un poco de codificación aleatoria de entidades decimales y hexadecimales para ayudar a ocultar su dirección de los robots de spam que recolectan direcciones. Por ejemplo, Markdown convertirá esto:

    <address@example.com>

en algo como esto:

    <a href="&#x6D;&#x61;i&#x6C;&#x74;&#x6F;:&#x61;&#x64;&#x64;&#x72;&#x65;
    &#115;&#115;&#64;&#101;&#120;&#x61;&#109;&#x70;&#x6C;e&#x2E;&#99;&#111;
    &#109;">&#x61;&#x64;&#x64;&#x72;&#x65;&#115;&#115;&#64;&#101;&#120;&#x61;
    &#109;&#x70;&#x6C;e&#x2E;&#99;&#111;&#109;</a>

que se mostrará en un navegador como un enlace en el que se puede hacer clic en "dirección@ejemplo.com".

(Este tipo de truco de codificación de entidades realmente engañará a muchos, si no a la mayoría, a los robots de recolección de direcciones, pero definitivamente no los engañará a todos. Es mejor que nada, pero una dirección publicada de esta manera probablemente comenzará a recibir correo no deseado.)

### ESCAPE DE BARRA INVERTIDA

Markdown le permite usar escapes de barra invertida para generar caracteres literales que de otro modo tendrían un significado especial en la sintaxis de formato de Markdown. Por ejemplo, si desea rodear una palabra con asteriscos literales (en lugar de una etiqueta HTML `<em>`), puede usar barras invertidas antes de los asteriscos, de esta manera:

    \*literal asterisks\*

Markdown proporciona escapes de barra invertida para los siguientes caracteres:

    \   barra invertida
    `   retroceso
    *   asterisco
    _   guion bajo
    {}  llaves
    []  corchetes
    ()  paréntesis
    #   símbolo de hash
    +   signo más
    -   signo menos (guión)
    .   punto
    !   signo de exclamación

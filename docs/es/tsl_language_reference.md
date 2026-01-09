# TSL (TheShowLang) - Referencia completa del lenguaje

¡Bienvenido a TSL! Es un lenguaje de programación imperativo moderno con soporte para funciones, variables, arreglos, estructuras, enumeraciones y control de flujo. Esta guía te enseñará todo lo que necesitas saber para escribir programas en TSL.

## Tabla de contenido
1. [Hola Mundo](#hola-mundo)
2. [Variables](#variables)
3. [Tipos de datos](#tipos-de-datos)
4. [Condiciones](#condiciones)
5. [Bucles](#bucles)
6. [Funciones](#funciones)
7. [Arreglos](#arreglos)
8. [Estructuras](#estructuras)
9. [Enumeraciones](#enumeraciones)
10. [Punteros](#punteros)
11. [Entrada/Salida](#entradasalida)
12. [Ejemplos avanzados](#ejemplos-avanzados)

---

## Hola Mundo

Cada programa TSL comienza con una función principal llamada `Eric`. Este es el punto de entrada de tu programa.

```tsl
Deschodt Eric() -> int
    peric("Hello, World!")
    deschodt 0
```

**Desglose:**
- `Deschodt` - palabra clave para definir una función
- `Eric()` - la función principal (sin parámetros)
- `-> int` - anotación del tipo de retorno
- `peric(...)` - función de impresión (salida a la consola)
- `deschodt 0` - declaración de retorno (código de salida 0)

Cuando ejecutes este programa, imprimirá: `¡Hola, Mundo!`

---

## Variables

Las variables almacenan los valores de datos. TSL es un lenguaje estáticamente tipado, así que debes declarar el tipo de cada variable.

### Declaración de variable básica

```tsl
Deschodt Eric() -> int
    eric x -> int              desnote declare integer x (non initialisé)
    eric y = 10 -> int         desnote declare and initialize y = 10
    x = 5                      desnote assign value to x
    eric z = x + y -> int      desnote declare and initialize z = 15

    peric("x = {x}, y = {y}, z = {z}")
    deschodt 0
```

**Salida:**
```
x = 5, y = 10, z = 15
```

**Sintaxis:**
- `eric varname -> type` - declarar una variable
- `eric varname = value -> type` - declarar e inicializar
- Interpolación de cadenas: usa `{variable}` dentro de las cadenas para insertar valores

---

## Tipos de datos

TSL soporta los siguientes tipos de datos primitivos:

| Tipo | Descripción | Ejemplo |
|------|-------------|---------|
| `int` | Entero con signo de 32 bits | `5`, `-10`, `0` |
| `float` | Número en punto flotante | `3.14`, `-2.5` |
| `string` | Cadena de texto | `"Hola"`, `"TSL"` |
| `char` | Carácter único | `'a'`, `'Z'` |
| `bool` | Valor booleano | `#t` (verdadero), `#f` (falso) |
| `void` | Ningún valor | Usado para funciones sin retorno |
| `int[]` | Arreglo de enteros | `[1, 2, 3]` |
| `string[]` | Arreglo de cadenas | `["a", "b"]` |
| `type*` | Puntero a un tipo | `int*`, `string*` |

---

## Condiciones

Controla el flujo del programa en función de las condiciones usando `erif` (if) y `deschelse` (else).

### Instrucción If

```tsl
Deschodt Eric() -> int
    eric age = 20 -> int

    erif (age >= 18):
        peric("Majeur")
    deschelse:
        peric("Mineur")

    deschodt 0
```

**Salida:**
```
Majeur
```

**Operadores de comparación:**
- `==` - igual
- `!=` - no igual
- `<` - menor que
- `>` - mayor que
- `<=` - menor o igual que
- `>=` - mayor o igual que

**Operadores lógicos:**
- `&&` - Y
- `||` - O
- `!` - NO

---

## Bucles

TSL proporciona dos tipos de bucles: `aer` (for-in) y `darius` (while).

### Bucle For

Usa `aer` para iterar sobre un rango o colección:

```tsl
Deschodt Eric() -> int
    peric("For loop:")
    aer i in range(0, 5):
        peric("i = {i}")

    deschodt 0
```

**Salida:**
```
For loop:
i = 0
i = 1
i = 2
i = 3
i = 4
```

**Control de Bucle:**
- `deschontinue` - saltar a la siguiente iteración
- `deschreak` - salir del bucle

```tsl
aer i in range(0, 10):
    erif (i == 3):
        deschontinue        desnote skip when i = 3
    erif (i == 7):
        deschreak           desnote exit when i = 7
    peric("i = {i}")
```

### Boucle While

Utiliza `darius` para bucles basados en condiciones:

```tsl
Deschodt Eric() -> int
    eric x = 0 -> int
    darius (x < 3):
        peric("x = {x}")
        x = x + 1

    deschodt 0
```

It seems that you haven't provided the Markdown chunk you want to be translated into Spanish (ES). Please share the content, and I'll be happy to assist you with the translation while adhering to the specified requirements.
```
x = 0
x = 1
x = 2
```

---

## Funciones

Las funciones te permiten reutilizar el código y organizar tu programa.

### Definición de Función

```tsl
Deschodt addition(a -> int, b -> int) -> int
    deschodt a + b

Deschodt Eric() -> int
    eric result = addition(5, 7) -> int
    peric("Result: {result}")
    deschodt 0
```

**Salida:**
```
Result: 12
```

**Sintaxis:**
- `Deschodt funcname(param1 -> type1, param2 -> type2) -> returntype`
- `deschodt value` - devuelve un valor de una función
- Las funciones deben tener tipos de retorno explícitos
- Todos los parámetros deben tener anotaciones de tipo

---

## Arreglos

Los arreglos almacenan múltiples valores del mismo tipo.

### Declaración e Inicialización de Arreglos

```tsl
Deschodt Eric() -> int
    eric nums -> int[]
    nums[0] = 1
    nums[1] = 2
    nums[2] = 3
    nums[100] = 50

    aer i in range(0, 101):
        peric("nums[{i}] = {nums[i]}")

    deschodt 0
```

**Puntos clave:**
- Declara con `varname -> type[]`
- Accede a los elementos con `arr[index]`
- Los arreglos son indexados desde 0
- Puedes establecer cualquier índice (arreglos dispersos)
- Usa `range(start, end)` para iterar (va de start a end-1)

---

## Estructuras

Las estructuras te permiten agrupar datos relacionados. 

### Definición y uso de estructuras

```tsl
destruct Person:
    name -> string
    age -> int

Deschodt Eric() -> int
    eric p -> Person
    p.name = "Alice"
    p.age = 25

    peric("Name: {p.name}, Age: {p.age}")
    deschodt 0
```

**Salida:**
```
Name: Alice, Age: 25
```

**Sintaxis:**
- `destruct StructName:` - define una estructura
- Los campos están indentados y tipados
- `eric var -> StructName` - declara una variable de estructura
- `var.field` - accede a los miembros de la estructura
- `var.field = value` - establece los miembros de la estructura

---

## Enumeraciones

Las enumeraciones definen un conjunto de constantes nombradas.

### Definición y Uso de Enum

```tsl
desnum Day:
    Monday
    Tuesday
    Wednesday

Deschodt Eric() -> int
    eric d = Tuesday -> Day
    peric("Day = {d}")
    deschodt 0
```

**Salida:**
```
Day = 1
```

**Puntos clave:**
- `desnum EnumName:` - define un enum
- Los valores de enumeración se asignan automáticamente a enteros (0, 1, 2, ...)
- Las enumeraciones proporcionan seguridad de tipo y legibilidad

---

## Punteros

Los punteros te permiten hacer referencia y modificar valores a través de las direcciones.

### Declaración de puntero y uso

```tsl
Deschodt increment(ptr -> int*) -> void
    *ptr = *ptr + 1

Deschodt Eric() -> int
    eric n = 10 -> int
    increment(&n)
    peric("n = {n}")
    deschodt 0
```

It seems that you haven't provided the Markdown chunk that you would like to have translated into Spanish (ES). Please share the content, and I'll be happy to assist you with the translation while adhering to your specified requirements.
```
n = 11
```

**Sintaxis:**
- `type*` - puntero a un tipo
- `&var` - obtener la dirección de la variable (referencia)
- `*ptr` - desreferenciar puntero (obtener valor)
- Utiliza punteros para pasar variables por referencia

---

## Entrada/Salida

### Impresión

Usa `peric()` para mostrar texto:

```tsl
eric x = 42 -> int
eric name = "Alice" -> string
peric("Value: {x}, Name: {name}")
```

**Características:**
- Interpolación de cadenas con `{variable}`
- Funciona con todos los tipos de datos
- Se pueden imprimir múltiples valores en líneas separadas

---

## Ejemplos Avanzados

### Ejemplo: Cálculo de Factorial

```tsl
Deschodt factorial(n -> int) -> int
    erif (n <= 1):
        deschodt 1
    deschelse:
        deschodt n * factorial(n - 1)

Deschodt Eric() -> int
    eric val = 5 -> int
    peric("factorial({val}) = {factorial(val)}")
    deschodt 0
```

It seems that you haven't provided the Markdown chunk that needs to be translated. Please share the text you'd like me to translate into Spanish (ES), and I'll be happy to assist you!
```
factorial(5) = 120
```

### Ejemplo: Sumar Array

```tsl
Deschodt sum(arr -> int[], size -> int) -> int
    eric total = 0 -> int
    aer i in range(0, size):
        total = total + arr[i]
    deschodt total

Deschodt Eric() -> int
    eric values -> int[4]
    values[0] = 4
    values[1] = 7
    values[2] = 2
    values[3] = 9

    eric res = sum(values, 4) -> int
    peric("Sum = {res}")
    deschodt 0
```

It seems that you haven't provided the Markdown chunk to translate. Please share the text you'd like me to translate into Spanish (ES), and I'll be happy to assist you!
```
Sum = 22
```

### Ejemplo: Tableros Multidimensionales

```tsl
Deschodt Eric() -> int
    eric matrix -> int[]
    matrix[0] -> int[]
    matrix[0][0] = 1
    matrix[0][1] = 2
    matrix[1] -> int[]
    matrix[1][0] = 3
    matrix[1][1] = 4

    aer i in range(0, 2):
        aer j in range(0, 2):
            peric("matrix[{i}][{j}] = {matrix[i][j]}")

    deschodt 0
```

I'm sorry, but it seems that you haven't provided the Markdown chunk that you would like me to translate into Spanish (ES). Please share the text, and I'll be happy to assist you with the translation while adhering to your specified requirements.
```
matrix[0][0] = 1
matrix[0][1] = 2
matrix[1][0] = 3
matrix[1][1] = 4
```

---

## REPL Interactivo

También puedes escribir código TSL de forma interactiva usando el REPL:

### Ejecución en una sola línea
Simplemente escribe el código y presiona Enter - se ejecuta de inmediato:

```
> (+ 5 3)
8
> (define x 42)
> (* x 2)
84
```

### Bloques de Código de Múltiples Líneas
Para código más extenso, usa `:code` ... `:end`:

```
> :code
code> Deschodt factorial(n -> int) -> int
code>     erif (n <= 1):
code>         deschodt 1
code>     deschelse:
code>         deschodt n * factorial(n - 1)
code> peric(factorial(5))
:end
120
```

---

## Consejos y Mejores Prácticas

1. **Seguridad de Tipos**: Siempre declara los tipos de variables. TSL detectará errores de tipo en el momento del análisis.

2. **Convención de Nombres**: Usa nombres en inglés o descriptivos para mayor claridad.

3. **Valores de Retorno**: Cada función debe devolver explícitamente un valor usando `deschodt`.

4. **Memoria**: Ten cuidado con los punteros; asegúrate de un acceso a memoria válido.

5. **Límites de Bucle**: Siempre usa `range()` con límites adecuados para evitar bucles infinitos.

6. **Interpolación de Cadenas**: Usa `{var}` en cadenas para que la salida sea legible.

7. **Comentarios**: El lenguaje soporta `desnote` para comentarios en código TSL.

---

## Errores Comunes y Soluciones

| Error | Causa | Solución |
|-------|-------|----------|
| "Error de análisis" | Sintaxis inválida | Verifica los corchetes y la indentación |
| "La variable X no está vinculada" | Uso de variable no definida | Declárala primero con `eric` |
| Desajuste de tipo | Asignación de tipo incorrecto | Verifica la anotación de tipo de la variable |
| División por cero | Dividiendo por 0 | Añade una verificación antes de la división |
| Índice de matriz fuera de límites | Accediendo a un índice inválido | Usa `range()` para una iteración segura |

---

## Resumen

TSL es un lenguaje práctico para aprender conceptos de programación:
- **Variables** te permiten almacenar datos
- **Condiciones** controlan el flujo de ejecución
- **Bucles** repiten código
- **Funciones** organizan y reutilizan el código
- **Arreglos & Estructuras** organizan datos complejos
- **Punteros** permiten programación basada en referencias

Comienza con programas simples y añade complejidad gradualmente. ¡Feliz codificación!

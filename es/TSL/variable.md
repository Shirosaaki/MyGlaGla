# Variables - Almacenar datos

Las variables te permiten almacenar y manipular datos en tu programa. TSL es **estáticamente tipado**, lo que significa que cada variable tiene un tipo de dato específico que no puede cambiar.

## Declaración de variable básica

### Declarar sin inicialización

```tsl
eric x -> int
eric name -> string
eric value -> float
```

Variables declaradas de esta manera existen pero tienen valores indefinidos. Debes asignarles un valor antes de usarlas.

### Declarar con inicialización

```tsl
eric x = 5 -> int
eric name = "Alice" -> string
eric pi = 3.14 -> float
```

Ceci déclare et assigne une valeur en une étape.

## Tipos de datos

TSL soporta estos tipos primitivos:

| Tipo | Descripción | Ejemplos |
|------|-------------|----------|
| `int` | Entero con signo de 32 bits | `42`, `-10`, `0` |
| `float` | Número de punto flotante | `3.14`, `-2.5`, `0.0` |
| `string` | Cadena de texto | `"Hello"`, `"TSL"` |
| `char` | Carácter único | `'a'`, `'Z'`, `'!'` |
| `bool` | Valor booleano | `#t` (true), `#f` (false) |

## Asignación de valores

Una vez declarada, asigne nuevos valores con `=` :

```tsl
Deschodt Eric() -> int
    eric x = 10 -> int
    x = 20              desnote reassign x to 20
    x = x + 5           desnote x is now 25
    
    peric("x = {x}")
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into Spanish (ES).
```
x = 25
```

## Alcance de las variables

Las variables existen desde la declaración hasta el final de su bloque :

```tsl
Deschodt Eric() -> int
    eric x = 1 -> int
    peric("x = {x}")    desnote x is accessible here
    
    erif (#t):
        eric y = 2 -> int
        peric("y = {y}")    desnote y is accessible here
    
    desnote y no longer exists here - would cause error
    
    deschodt 0
```

## Convenciones de nomenclatura

Elija nombres claros y descriptivos :

```tsl
desnote Bons noms de variables
eric totalPrice -> float
eric userAge -> int
eric isValid -> bool

desnote Éviter les noms peu clairs
eric x -> int           desnote trop vague
eric asdf -> string     desnote sans sens
eric a1b2c3 -> float    desnote difficile à retenir
```

## Usar variables en expresiones

Las variables funcionan en las operaciones aritméticas y lógicas :

```tsl
Deschodt Eric() -> int
    eric a = 10 -> int
    eric b = 3 -> int
    eric sum = a + b -> int
    eric product = a * b -> int
    
    peric("Sum: {sum}")         desnote Sum: 13
    peric("Product: {product}") desnote Product: 30
    
    deschodt 0
```

## Interpolación de Cadenas

Inserta valores de variables en cadenas usando `{variable}`:

```tsl
Deschodt Eric() -> int
    eric name = "Bob" -> string
    eric age = 25 -> int
    eric height = 1.75 -> float
    
    peric("Name: {name}")                      desnote Name: Bob
    peric("Age: {age}")                        desnote Age: 25
    peric("Height: {height} meters")           desnote Height: 1.75 meters
    peric("{name} is {age} years old")         desnote Bob is 25 years old
    
    deschodt 0
```

## Conversión de Tipos

Para convertir entre tipos:

```tsl
desnote Float to int (loses decimals)
eric f = 3.7 -> float
eric i = (cast int f) -> int    desnote i is now 3

desnote Int to float (adds .0)
eric i = 42 -> int
eric f = (cast float i) -> float desnote f is now 42.0
```

## Errores comunes

### Olvidar la anotación de tipo
```tsl
eric x = 5      desnote ERROR - missing type
eric x = 5 -> int desnote CORRECT
```

### Desfase de tipo
```tsl
eric x = "hello" -> int  desnote ERROR - string can't be int
eric x = "hello" -> string desnote CORRECT
```

### Usando Variable No Definida
```tsl
peric("{y}")     desnote ERROR - y was never declared
eric y = 0 -> int
peric("{y}")     desnote CORRECT
```

## Ejemplo Completo

```tsl
Deschodt Eric() -> int
    desnote Declare and initialize variables
    eric firstName = "Alice" -> string
    eric lastName = "Smith" -> string
    eric birthYear = 1995 -> int
    eric currentYear = 2024 -> int
    
    desnote Calculate age
    eric age = currentYear - birthYear -> int
    
    desnote Use string interpolation
    peric("Name: {firstName} {lastName}")
    peric("Age: {age}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into Spanish (ES).
```
Name: Alice Smith
Age: 29
```

## Étapes siguientes

- Aprende sobre **[Condiciones](condition.md)** para tomar decisiones basadas en variables
- Explora **[Listas](lists.md)** para almacenar múltiples valores
- Consulta **[Funciones](functions.md)** para pasar y devolver variables

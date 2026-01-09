# Hola Mundo - Comenzando con TSL

## Tu primer programa

El programa TSL más simple imprime "¡Hola, Mundo!":

```tsl
Deschodt Eric() -> int
    peric("Salut, monde !")
    deschodt 0
```

Cuando ejecutas este programa, muestra:
```
Salut, monde !
```

## Comprender el código

### `Deschodt` - Declaración de función
- `Deschodt` es la palabra clave para definir una función
- Cada programa TSL necesita una función `Eric` (el punto de entrada)
- Piénsalo como `main()` en C o Java

### `Eric()` - Función principal
- `Eric` es el nombre especial de la función principal
- Los paréntesis `()` indican que no tiene parámetros
- Es aquí donde tu programa comienza a ejecutarse

### `-> int` - Tipo de retorno
- Especifica que la función retorna un entero
- `0` indica la ejecución exitosa (estándar en la mayoría de los sistemas)
- Otros tipos de retorno podrían ser `string`, `float`, `void`, etc.

### `peric(...)` - Salida de impresión
- `peric` significa "imprimir"
- Toma un argumento de cadena
- Imprime en la consola y añade una nueva línea
- Puede usar la interpolación de cadena con `{variable}`

### `deschodt` - Declaración de retorno
- `deschodt` significa "retornar"
- Sale de la función y devuelve un valor
- `deschodt 0` retorna el código de salida 0 (éxito)

## Ejecución de tu programa

### Compilar y ejecutar
```bash
./glados < hello.tsl
```

### REPL interactivo
```bash
./glados
> :code
|Deschodt Eric() -> int
|    peric("Salut, monde !")
|    deschodt 0
|:end
Salut, monde !
```

## Variantes

### Impresión de varias líneas
```tsl
Deschodt Eric() -> int
    peric("Line 1")
    peric("Line 2")
    peric("Line 3")
    deschodt 0
```

Sortie:
```
Line 1
Line 2
Line 3
```

### Utilizar la interpolación de cadenas
```tsl
Deschodt Eric() -> int
    eric name = "Alice" -> string
    peric("Hello, {name}!")
    deschodt 0
```

Sortie:
```
Hello, Alice!
```

### Códigos de retorno diferentes
```tsl
Deschodt Eric() -> int
    erif (someCondition):
        deschodt 1    desnote error exit
    deschelse:
        deschodt 0    desnote success exit
```

## Étapes siguientes

Ahora que comprendes la estructura básica, explora:
1. **[Variables](variable.md)** - Almacenar y manipular datos
2. **[Condiciones](condition.md)** - Tomar decisiones en tu código
3. **[Bucles](loops.md)** - Repetir acciones
4. **[Funciones](functions.md)** - Organizar el código reutilizable

¡Buen código!

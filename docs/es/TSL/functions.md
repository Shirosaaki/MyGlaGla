# Funciones - Organizar el código

Las funciones te permiten escribir bloques de código reutilizables. Aceptan parámetros, realizan operaciones y devuelven un resultado.

## Definición de función básica

```tsl
Deschodt add(a -> int, b -> int) -> int
    deschodt a + b

Deschodt Eric() -> int
    eric result = add(5, 3) -> int
    peric("Result: {result}")
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into Spanish (ES).
```
Result: 8
```

**Sintaxis:**
- `Deschodt functionName(param1 -> type1, param2 -> type2) -> returnType`
- `deschodt` devuelve un valor y sale de la función
- Todos los parámetros deben tener anotaciones de tipo
- El tipo de retorno debe estar especificado explícitamente

## Función sin parámetros

```tsl
Deschodt greet() -> string
    deschodt "Hello, World!"

Deschodt Eric() -> int
    eric message = greet() -> string
    peric("{message}")
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into Spanish (ES).
```
Hello, World!
```

## Función sin valor de retorno (void)

```tsl
Deschodt printMessage(msg -> string) -> void
    peric("Message: {msg}")

Deschodt Eric() -> int
    printMessage("Hello")
    printMessage("World")
    deschodt 0
```

Por favor, proporciona el fragmento de Markdown que deseas traducir al español.
```
Message: Hello
Message: World
```

Cuando el tipo de retorno es `void`, no se devuelve un valor (o se omite `deschodt`).

## Parámetros múltiples

```tsl
Deschodt multiply(a -> int, b -> int) -> int
    deschodt a * b

Deschodt power(base -> int, exponent -> int) -> int
    eric result = 1 -> int
    aer i in range(0, exponent):
        result = result * base
    deschodt result

Deschodt Eric() -> int
    peric("3 * 4 = {multiply(3, 4)}")
    peric("2^5 = {power(2, 5)}")
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into Spanish (ES).
```
3 * 4 = 12
2^5 = 32
```

## Tipos de retorno diferentes

Las funciones pueden devolver cualquier tipo:

```tsl
Deschodt getAge() -> int
    deschodt 25

Deschodt getName() -> string
    deschodt "Alice"

Deschodt isStudent() -> bool
    deschodt #t

Deschodt getHeight() -> float
    deschodt 1.75

Deschodt Eric() -> int
    peric("Age: {getAge()}")
    peric("Name: {getName()}")
    peric("Student: {isStudent()}")
    peric("Height: {getHeight()}")
    deschodt 0
```

## Devolución condicional

```tsl
Deschodt getGrade(score -> int) -> string
    erif (score >= 90):
        deschodt "A"
    deschelse:
        erif (score >= 80):
            deschodt "B"
        deschelse:
            erif (score >= 70):
                deschodt "C"
            deschelse:
                deschodt "F"

Deschodt Eric() -> int
    peric("Grade: {getGrade(85)}")
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into Spanish (ES).
```
Grade: B
```

## Función que llama a otra función

Las funciones pueden llamar a otras funciones :

```tsl
Deschodt isEven(n -> int) -> bool
    eric remainder = n -> int
    desnote Use modulo conceptually
    erif (remainder == 0):
        deschodt #t
    deschelse:
        deschodt #f

Deschodt printIfEven(n -> int) -> void
    erif (isEven(n)):
        peric("{n} is even")
    deschelse:
        peric("{n} is odd")

Deschodt Eric() -> int
    printIfEven(4)
    printIfEven(7)
    deschodt 0
```

## Recursión

Las funciones pueden llamarse a sí mismas para resolver problemas de manera recursiva :

```tsl
Deschodt factorial(n -> int) -> int
    erif (n <= 1):
        deschodt 1
    deschelse:
        deschodt n * factorial(n - 1)

Deschodt Eric() -> int
    peric("5! = {factorial(5)}")
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into Spanish (ES).
```
5! = 120
```

## Pasar Tableros a Funciones

```tsl
Deschodt sumArray(arr -> int[], size -> int) -> int
    eric total = 0 -> int
    aer i in range(0, size):
        total = total + arr[i]
    deschodt total

Deschodt Eric() -> int
    eric numbers -> int[]
    numbers[0] = 10
    numbers[1] = 20
    numbers[2] = 30
    
    eric sum = sumArray(numbers, 3) -> int
    peric("Sum: {sum}")
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into Spanish (ES).
```
Sum: 60
```

## Pasar punteros (Por referencia)

Utiliza punteros para modificar los valores dentro de una función:

```tsl
Deschodt increment(ptr -> int*) -> void
    *ptr = *ptr + 1

Deschodt Eric() -> int
    eric x = 10 -> int
    peric("Before: {x}")
    increment(&x)
    peric("After: {x}")
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into Spanish (ES).
```
Before: 10
After: 11
```

## Función con múltiples puntos de salida

```tsl
Deschodt getStatus(score -> int) -> string
    erif (score < 0):
        deschodt "Invalid"
    
    erif (score < 50):
        deschodt "Fail"
    
    erif (score < 80):
        deschodt "Pass"
    
    deschodt "Excellent"

Deschodt Eric() -> int
    peric("Status: {getStatus(75)}")
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into Spanish (ES).
```
Status: Pass
```

## Ejemplo práctico: Verificador de números primos

```tsl
Deschodt isPrime(n -> int) -> bool
    erif (n < 2):
        deschodt #f
    
    aer i in range(2, n):
        eric remainder = 0 -> int
        desnote Check if n is divisible by i
        desnote For now, assume we have modulo checking
        deschodt #f
    
    deschodt #t

Deschodt Eric() -> int
    eric num = 17 -> int
    erif (isPrime(num)):
        peric("{num} is prime")
    deschelse:
        peric("{num} is not prime")
    deschodt 0
```

## Ejemplo práctico: Secuencia de Fibonacci

```tsl
Deschodt fibonacci(n -> int) -> int
    erif (n <= 1):
        deschodt n
    deschelse:
        deschodt fibonacci(n - 1) + fibonacci(n - 2)

Deschodt Eric() -> int
    aer i in range(0, 7):
        peric("fib({i}) = {fibonacci(i)}")
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into Spanish (ES).
```
fib(0) = 0
fib(1) = 1
fib(2) = 1
fib(3) = 2
fib(4) = 3
fib(5) = 5
fib(6) = 8
```

## Ejemplo práctico: Función de procesamiento de cadenas

```tsl
Deschodt repeatString(str -> string, times -> int) -> string
    eric result = "" -> string
    aer i in range(0, times):
        desnote String concatenation (conceptually)
        desnote In practice, use string operations
    deschodt result

Deschodt Eric() -> int
    desnote Demonstrate function composition
    deschodt 0
```

## Errores comunes

### Olvidar el tipo de retorno
```tsl
Deschodt add(a -> int, b -> int)    desnote ERROR - missing return type
Deschodt add(a -> int, b -> int) -> int  desnote CORRECT
```

### Desfase de tipo de parámetro
```tsl
Deschodt greet(name -> string) -> string
    deschodt "Hello, {name}"

Eric() -> int
    greet(42)      desnote ERROR - entier passé, chaîne attendue
    greet("Bob")   desnote CORRECT
```

### Oublier deschodt
```tsl
Deschodt getValue() -> int
    eric value = 10 -> int
    desnote ERROR - no return statement

Deschodt getValue() -> int
    eric value = 10 -> int
    deschodt value  desnote CORRECT
```

### Stack Overflow con Recursión
```tsl
Deschodt infinite(n -> int) -> int
    deschodt infinite(n + 1)  desnote Infinite recursion - avoid!

Deschodt countdown(n -> int) -> int
    erif (n <= 0):
        deschodt 0
    deschelse:
        deschodt countdown(n - 1)  desnote Proper recursion with base case
```

## Mejores prácticas

1. **Responsabilidad única** : Cada función debería hacer una sola cosa bien
2. **Nombres claros** : Utiliza nombres de función descriptivos que expliquen lo que hacen
3. **Documentar el objetivo** : Añadir comentarios explicando qué hace la función
4. **Validar la entrada** : Verifica que los parámetros sean válidos
5. **Retorno anticipado** : Devuelve pronto cuando sea posible para simplificar la lógica
6. **Evitar la anidación profunda** : Mantén las funciones simples y legibles

## Pasos siguientes

- Combina las funciones con **[Bucles](loops.md)** para patrones poderosos
- Usa **[Arreglos](lists.md)** con funciones para el procesamiento de datos
- Explora **[Estructuras](structs.md)** para pasar datos complejos a las funciones

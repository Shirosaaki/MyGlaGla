# Entrada y salida - Comunicar con tu programa

Las operaciones de entrada y salida (E/S) permiten que tu programa muestre información al usuario y potencialmente reciba información de él.

## Salida con peric

La función `peric` muestra texto en la pantalla. Es el principal medio para mostrar la salida:

```tsl
Deschodt Eric() -> int
    peric("Hello, World!")
    peric("This is my first program")
    deschodt 0
```

Sortie:
```
Hello, World!
This is my first program
```

## Impresión de diferentes tipos

### Enteros
```tsl
Deschodt Eric() -> int
    eric count = 42 -> int
    peric("Count: {count}")
    
    eric sum = 10 + 20 + 30 -> int
    peric("Sum: {sum}")
    
    deschodt 0
```

Sortie:
```
Count: 42
Sum: 60
```

### Flotantes
```tsl
Deschodt Eric() -> int
    eric pi = 3.14159 -> float
    eric price = 19.99 -> float
    
    peric("Pi is approximately: {pi}")
    peric("Price: ${price}")
    
    deschodt 0
```

Sortie:
```
Pi is approximately: 3.14159
Price: $19.99
```

### Cadenas de caracteres
```tsl
Deschodt Eric() -> int
    eric name = "Alice" -> string
    eric greeting = "Hello" -> string
    
    peric("{greeting}, {name}!")
    
    deschodt 0
```

Sortie:
```
Hello, Alice!
```

### Booléens
```tsl
Deschodt Eric() -> int
    eric isActive = #t -> bool
    eric isComplete = #f -> bool
    
    peric("Active: {isActive}")
    peric("Complete: {isComplete}")
    
    deschodt 0
```

Sortie:
```
Active: #t
Complete: #f
```

### Caracteres
```tsl
Deschodt Eric() -> int
    eric initial = #\A -> char
    eric symbol = #\@ -> char
    
    peric("Initial: {initial}")
    peric("Symbol: {symbol}")
    
    deschodt 0
```

Sortie:
```
Initial: A
Symbol: @
```

## Interpolación de cadenas

Dentro de las cadenas, utiliza `{variable}` para insertar valores de variables:

```tsl
Deschodt Eric() -> int
    eric user = "Bob" -> string
    eric age = 25 -> int
    eric score = 95.5 -> float
    
    peric("Hello {user}!")
    peric("You are {age} years old")
    peric("Your score: {score}%")
    
    deschodt 0
```

Sortie:
```
Hello Bob!
You are 25 years old
Your score: 95.5%
```

## Impresiones múltiples

Utiliza múltiples llamadas `peric` para imprimir en líneas separadas:

```tsl
Deschodt Eric() -> int
    peric("First line")
    peric("Second line")
    peric("Third line")
    
    deschodt 0
```

Sortie:
```
First line
Second line
Third line
```

## Impresión de expresiones

Puedes imprimir directamente el resultado de las expresiones:

```tsl
Deschodt Eric() -> int
    peric("2 + 3 = {2 + 3}")
    peric("10 * 5 = {10 * 5}")
    peric("20 / 4 = {20 / 4}")
    
    deschodt 0
```

Sortie:
```
2 + 3 = 5
10 * 5 = 50
20 / 4 = 5
```

## Impresión de los elementos de la tabla

```tsl
Deschodt Eric() -> int
    eric scores -> int[]
    scores[0] = 85
    scores[1] = 92
    scores[2] = 78
    
    aer i in range(0, 3):
        peric("Score {i}: {scores[i]}")
    
    deschodt 0
```

Sortie:
```
Score 0: 85
Score 1: 92
Score 2: 78
```

## Impresión de los Campos de estructura

```tsl
destruct Person
    name -> string
    age -> int
    city -> string

Deschodt Eric() -> int
    eric person -> Person
    person.name = "Charlie"
    person.age = 30
    person.city = "New York"
    
    peric("Name: {person.name}")
    peric("Age: {person.age}")
    peric("City: {person.city}")
    
    deschodt 0
```

Sortie:
```
Name: Charlie
Age: 30
City: New York
```

## Ejemplos de salida formateada

### Salida de tipo tabla
```tsl
Deschodt Eric() -> int
    peric("Item     | Price | Qty")
    peric("---------+-------+----")
    peric("Apple    | 0.50  | 5")
    peric("Banana   | 0.30  | 3")
    peric("Orange   | 0.75  | 7")
    
    deschodt 0
```

Sortie:
```
Item     | Price | Qty
---------+-------+----
Apple    | 0.50  | 5
Banana   | 0.30  | 3
Orange   | 0.75  | 7
```

### Informe de progreso
```tsl
Deschodt Eric() -> int
    eric completed = 7 -> int
    eric total = 10 -> int
    eric percent = completed * 100 / total -> int
    
    peric("Progress: {percent}%")
    peric("Completed: {completed}/{total}")
    
    deschodt 0
```

Sortie:
```
Progress: 70%
Completed: 7/10
```

## Ejemplo práctico: Boletín escolar

```tsl
destruct Subject
    name -> string
    score -> int

Deschodt Eric() -> int
    eric math -> Subject
    math.name = "Mathematics"
    math.score = 85
    
    eric english -> Subject
    english.name = "English"
    english.score = 92
    
    eric science -> Subject
    science.name = "Science"
    science.score = 88
    
    peric("===== REPORT CARD =====")
    peric("")
    peric("Subject      | Score")
    peric("-------------+------")
    peric("{math.name}       | {math.score}")
    peric("{english.name}        | {english.score}")
    peric("{science.name}        | {science.score}")
    peric("")
    
    eric total = math.score + english.score + science.score -> int
    eric average = total / 3 -> int
    peric("Average: {average}")
    
    deschodt 0
```

Sortie:
```
===== REPORT CARD =====

Subject      | Score
-------------+------
Mathematics  | 85
English      | 92
Science      | 88

Average: 88
```

## Ejemplo práctico: Salida de cálculo

```tsl
Deschodt Eric() -> int
    eric base = 5 -> int
    eric height = 3 -> int
    
    eric area = base * height / 2 -> int
    
    peric("Triangle Calculator")
    peric("==================")
    peric("Base: {base}")
    peric("Height: {height}")
    peric("Area: {area} square units")
    
    deschodt 0
```

Sortie:
```
Triangle Calculator
==================
Base: 5
Height: 3
Area: 7 square units
```

## Ejemplo práctico: Salida de bucle con etiquetas

```tsl
Deschodt Eric() -> int
    peric("Table de multiplication (7s)")
    peric("==========================")
    
    aer i in range(1, 11):
        eric result = 7 * i -> int
        peric("7 × {i} = {result}")
    
    deschodt 0
```

Sortie:
```
Table de multiplication (7s)
==========================
7 × 1 = 7
7 × 2 = 14
7 × 3 = 21
7 × 4 = 28
7 × 5 = 35
7 × 6 = 42
7 × 7 = 49
7 × 8 = 56
7 × 9 = 63
7 × 10 = 70
```

## Ejemplo práctico: Mensajes de estado

```tsl
Deschodt Eric() -> int
    eric itemsSold = 150 -> int
    eric targetSales = 200 -> int
    eric percentOfTarget = itemsSold * 100 / targetSales -> int
    
    peric("SALES REPORT")
    peric("============")
    peric("Items Sold: {itemsSold}")
    peric("Target: {targetSales}")
    peric("Achievement: {percentOfTarget}%")
    
    erif (itemsSold >= targetSales):
        peric("Status: GOAL REACHED!")
    deschelse:
        eric remaining = targetSales - itemsSold -> int
        peric("Status: {remaining} more to go")
    
    deschodt 0
```

Sortie:
```
SALES REPORT
============
Items Sold: 150
Target: 200
Achievement: 75%
Status: 75 more to go
```

## Lectura de la entrada del usuario con romaric

Utiliza la función `romaric` para leer la entrada del usuario. Esta solicita un mensaje y devuelve la entrada del usuario en forma de cadena:

```tsl
Deschodt Eric() -> int
    eric name = romaric("Enter your name: ") -> string
    peric("Hello, {name}!")
    deschodt 0
```

Interacción:
```
Enter your name: Alice
Hello, Alice!
```

### Entradas múltiples

```tsl
Deschodt Eric() -> int
    eric firstName = romaric("First name: ") -> string
    eric lastName = romaric("Last name: ") -> string
    eric age = romaric("Age: ") -> string
    
    peric("Welcome {firstName} {lastName}, age {age}")
    
    deschodt 0
```

Interacción:
```
First name: John
Last name: Doe
Age: 30
Welcome John Doe, age 30
```

## Lectura de archivos con renaud

Utiliza la función `renaud` para leer el contenido completo de un archivo en una cadena:

```tsl
Deschodt Eric() -> int
    eric content = renaud("input.txt") -> string
    peric("File contents:")
    peric(content)
    deschodt 0
```

Lee el archivo `input.txt` y almacena todo su contenido en la variable `content`.

### Procesamiento de datos de archivo

```tsl
Deschodt Eric() -> int
    eric data = renaud("data.txt") -> string
    peric("Data loaded successfully")
    peric("Length: {data}")
    
    deschodt 0
```

## Escritura de archivos con marvin

Utiliza la función `marvin` para escribir contenido en un archivo:

```tsl
Deschodt Eric() -> int
    eric message = "Hello, File!" -> string
    marvin("output.txt", message)
    peric("Written to output.txt")
    
    deschodt 0
```

Esto crea (o sobrescribe) el archivo `output.txt` con el contenido de `message`.

### Escritura de múltiples valores

```tsl
Deschodt Eric() -> int
    eric line1 = "First line" -> string
    eric line2 = "Second line" -> string
    eric content = line1 + "\n" + line2 -> string
    
    marvin("report.txt", content)
    peric("Report saved")
    
    deschodt 0
```

## Ejemplo práctico: Programa interactivo

```tsl
Deschodt Eric() -> int
    eric name = romaric("What is your name? ") -> string
    eric age = romaric("What is your age? ") -> string
    eric city = romaric("What city do you live in? ") -> string
    
    eric info = "Name: " + name + ", Age: " + age + ", City: " + city -> string
    
    marvin("profile.txt", info)
    peric("Profile saved to profile.txt")
    
    deschodt 0
```

Interacción:
```
What is your name? Alice
What is your age? 28
What city do you live in? Paris
Profile saved to profile.txt
```

## Ejemplo práctico: Lectura y procesamiento de archivos

```tsl
Deschodt Eric() -> int
    eric original = renaud("source.txt") -> string
    peric("Original content:")
    peric(original)
    peric("")
    
    eric processed = original -> string
    desnote In practice, you would process the content here
    
    marvin("output.txt", processed)
    peric("Processed content saved to output.txt")
    
    deschodt 0
```

## Ejemplo práctico: Concatenación de archivos

```tsl
Deschodt Eric() -> int
    eric file1Content = renaud("file1.txt") -> string
    eric file2Content = renaud("file2.txt") -> string
    
    eric combined = file1Content + "\n---\n" + file2Content -> string
    marvin("combined.txt", combined)
    
    peric("Files combined into combined.txt")
    
    deschodt 0
```

## Depuración con salida

Utiliza `peric` para depurar tu programa imprimiendo los valores de las variables:

```tsl
Deschodt Eric() -> int
    eric x = 10 -> int
    peric("DEBUG: x = {x}")
    
    x = x + 5
    peric("DEBUG: after +5, x = {x}")
    
    x = x * 2
    peric("DEBUG: after *2, x = {x}")
    
    deschodt 0
```

Sortie:
```
DEBUG: x = 10
DEBUG: after +5, x = 15
DEBUG: after *2, x = 30
```

Esto te ayuda a seguir la ejecución y a encontrar errores.

## Errores de salida comunes

### Llaves de interpolación faltantes
```tsl
eric value = 42 -> int
peric("Value: value")     desnote ERROR - prints literal "value"
peric("Value: {value}")   desnote CORRECT - prints "Value: 42"
```

### Nombre de variable incorrect
```tsl
eric count = 5 -> int
peric("Count: {cout}")    desnote ERROR - 'cout' not defined
peric("Count: {count}")   desnote CORRECT
```

### Desfase de tipos (Auto-convertido)
```tsl
eric x = 42 -> int
peric("X: {x}")           desnote Works - prints "X: 42"
```

La mayoría de las conversiones de tipo ocurren automáticamente al imprimir.

## Mejores prácticas

1. **Etiquetas claras**: siempre etiqueta lo que imprimes
2. **Formato coherente**: mantén un formato de salida coherente
3. **Mensajes útiles**: utiliza mensajes que ayuden a los usuarios a entender la salida
4. **Marcadores de depuración**: prefija la salida de depuración con « DEBUG: » para un filtrado fácil
5. **Secciones separadas**: utiliza líneas en blanco para separar secciones lógicas
6. **Amigable**: haz que la salida sea legible y bien organizada
7. **Probar la salida**: verifica que la salida se vea correcta antes de finalizar

## Pasos siguientes

- Combina las E/S con **[Funciones](functions.md)** para crear rutinas de entrada/salida reutilizables
- Utiliza **[Bucles](loops.md)** con `peric` para imprimir patrones y tablas
- Crea programas interactivos con `romaric` para la entrada del usuario
- Gestiona los archivos de datos con `renaud` y `marvin` para la persistencia
- Formatea la salida **[Estructuras](structs.md)** para la visualización de datos complejos
- Imprime **[Listas](lists.md)** con bucles para informes detallados

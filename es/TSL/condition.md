# Condiciones - Tomar decisiones

Las condiciones permiten que tu programa tome decisiones y ejecute código diferente basado en las condiciones. Usa las instrucciones `if` (si) y `else` (sino).

## Instrucción If básica

```tsl
Deschodt Eric() -> int
    eric age = 20 -> int

    erif (age >= 18):
        peric("Vous êtes un adulte")
    
    deschodt 0
```

Si la condición es verdadera, el bloque de código se ejecuta. De lo contrario, se ignora.

## Instrucción If-Else

```tsl
Deschodt Eric() -> int
    eric age = 15 -> int

    erif (age >= 18):
        peric("Majeur")        desnote adulte
    deschelse:
        peric("Mineur")        desnote mineur
    
    deschodt 0
```

Sortie :
```
Mineur
```

## Operadores de comparación

Utiliza estos para crear condiciones:

| Operador | Significado | Ejemplo |
|----------|-------------|---------|
| `==` | Igual a | `x == 5` |
| `!=` | No igual a | `x != 5` |
| `<` | Menor que | `x < 10` |
| `>` | Mayor que | `x > 0` |
| `<=` | Menor o igual que | `x <= 5` |
| `>=` | Mayor o igual que | `x >= 18` |

## Operadores lógicos

Combina múltiples condiciones:

| Operador | Significado | Ejemplo |
|----------|-------------|---------|
| `&&` | Y (ambos verdaderos) | `(edad >= 18) && (puntuación > 75)` |
| `\|\|` | O (al menos uno verdadero) | `(día == 0) \|\| (día == 6)` |
| `!` | NO (invertir verdadero/falso) | `!(x == 0)` |

## Ejemplos de operadores lógicos

### Y - Ambas condiciones deben ser verdaderas

```tsl
Deschodt Eric() -> int
    eric age = 25 -> int
    eric score = 85 -> int
    
    erif ((age >= 18) && (score >= 80)):
        peric("Eligible for the job!")
    deschelse:
        peric("Not eligible")
    
    deschodt 0
```

Sure, please provide the Markdown chunk you'd like me to translate into Spanish (ES).
```
Eligible for the job!
```

### O - Al menos una condición debe ser verdadera

```tsl
Deschodt Eric() -> int
    eric day = 0 -> int     desnote 0 = Sunday
    
    erif ((day == 0) || (day == 6)):
        peric("It's the weekend!")
    deschelse:
        peric("It's a weekday")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into Spanish (ES).
```
It's the weekend!
```

### NO - Invertir una condición

```tsl
Deschodt Eric() -> int
    eric isRaining = #f
    
    erif (!(isRaining)):
        peric("Let's go outside!")
    deschelse:
        peric("Stay inside")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into Spanish (ES).
```
Let's go outside!
```

## Imbricación de condiciones

Puedes anidar instrucciones `erif` unas dentro de otras para decisiones más complejas:

```tsl
Deschodt Eric() -> int
    eric age = 25 -> int
    eric hasLicense = #t
    
    erif (age >= 18):
        erif (hasLicense):
            peric("You can drive")
        deschelse:
            peric("Get a license first")
    deschelse:
        peric("You must be 18 to drive")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into Spanish (ES).
```
You can drive
```

## Alternativas a las anidaciones profundas

En lugar de utilizar instrucciones if-else profundamente anidadas, utiliza múltiples condiciones:

```tsl
Deschodt classify(age -> int) -> string
    erif (age < 13):
        deschodt "Child"
    deschelse:
        erif ((age >= 13) && (age < 18)):
            deschodt "Teenager"
        deschelse:
            erif (age >= 18):
                deschodt "Adult"
            deschelse:
                deschodt "Unknown"

Deschodt Eric() -> int
    eric age = 16 -> int
    eric category = classify(age) -> string
    peric("Category: {category}")
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into Spanish (ES).
```
Category: Teenager
```

## Ejemplo concreto: Calculadora de notas

```tsl
Deschodt Eric() -> int
    eric score = 85 -> int
    eric grade -> string
    
    erif (score >= 90):
        grade = "A"
    deschelse:
        erif (score >= 80):
            grade = "B"
        deschelse:
            erif (score >= 70):
                grade = "C"
            deschelse:
                erif (score >= 60):
                    grade = "D"
                deschelse:
                    grade = "F"
    
    peric("Score: {score} -> Grade: {grade}")
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into Spanish (ES).
```
Score: 85 -> Grade: B
```

## Ejemplo: Opción múltiple con if-else

```tsl
Deschodt Eric() -> int
    eric day = 2 -> int
    eric dayName -> string
    
    erif (day == 0):
        dayName = "Monday"
    deschelse:
        erif (day == 1):
            dayName = "Tuesday"
        deschelse:
            erif (day == 2):
                dayName = "Wednesday"
            deschelse:
                dayName = "Other"
    
    peric("Day: {dayName}")
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like to have translated into Spanish (ES).
```
Day: Wednesday
```

## Errores comunes

### Usar `=` en lugar de `==`
```tsl
erif (x = 5):       desnote ERREUR - affectation, pas comparaison
erif (x == 5):      desnote CORRECT - comparaison
```

### Olvidar los paréntesis
```tsl
erif age >= 18:     desnote ERROR - missing parentheses
erif (age >= 18):   desnote CORRECT
```

### Olvidar deschelse
```tsl
erif (x == 5):
    peric("x is 5")
desnote deschelse is optional - no error here
```

## Étapes siguientes

- Aprende **[Bucles](loops.md)** para repetir código según condiciones
- Explora **[Funciones](functions.md)** para organizar la lógica condicional
- Descubre **[Arreglos](lists.md)** e itera con condiciones

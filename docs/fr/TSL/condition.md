# Conditions - Prendre des décisions

Les conditions vous permettent à votre programme de prendre des décisions et d'exécuter du code différent basé sur les conditions. Utilisez les instructions `erif` (si) et `deschelse` (sinon).

## Instruction If de base

```tsl
Deschodt Eric() -> int
    eric age = 20 -> int

    erif (age >= 18):
        peric("Vous êtes un adulte")
    
    deschodt 0
```

Si la condition est vraie, le bloc de code s'exécute. Sinon, il est ignoré.

## Instruction If-Else

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

## Opérateurs de comparaison

Use these to create conditions:

| Operator | Meaning | Example |
|----------|---------|---------|
| `==` | Equal to | `x == 5` |
| `!=` | Not égal to | `x != 5` |
| `<` | Less than | `x < 10` |
| `>` | Greater than | `x > 0` |
| `<=` | Less than or égal | `x <= 5` |
| `>=` | Greater than or égal | `x >= 18` |

## Opérateurs logiques

Combine multiple conditions:

| Operator | Meaning | Example |
|----------|---------|---------|
| `&&` | ET (les deux vrais) | `(age >= 18) && (score > 75)` |
| `\|\|` | OU (au moins un vrai) | `(day == 0) \|\| (day == 6)` |
| `!` | NON (inverser vrai/faux) | `!(x == 0)` |

## Exemples d'opérateurs logiques

### AND - Les deux conditions doivent être vraies

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

Output:
```
Eligible for the job!
```

### OR - Au moins une condition doit être vraie

```tsl
Deschodt Eric() -> int
    eric day = 0 -> int     desnote 0 = Sunday
    
    erif ((day == 0) || (day == 6)):
        peric("It's the weekend!")
    deschelse:
        peric("It's a weekday")
    
    deschodt 0
```

Output:
```
It's the weekend!
```

### NOT - Inverser une condition

```tsl
Deschodt Eric() -> int
    eric isRaining = #f
    
    erif (!(isRaining)):
        peric("Let's go outside!")
    deschelse:
        peric("Stay inside")
    
    deschodt 0
```

Output:
```
Let's go outside!
```

## Imbrication des conditions

Vous pouvez imbriquer des instructions `erif` les unes dans les autres pour des décisions plus complexes:

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

Output:
```
You can drive
```

## Alternatives aux imbrications profondes

Au lieu d'utiliser des instructions if-else profondément imbriquées, utilisez plusieurs conditions :

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

Output:
```
Category: Teenager
```

## Exemple concret : Calculateur de notes

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

Output:
```
Score: 85 -> Grade: B
```

## Exemple : Choix multiple avec if-else

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

Output:
```
Day: Wednesday
```

## Erreurs courantes

### Utiliser `=` au lieu de `==`
```tsl
erif (x = 5):       desnote ERREUR - affectation, pas comparaison
erif (x == 5):      desnote CORRECT - comparaison
```

### Oublier les parenthèses
```tsl
erif age >= 18:     desnote ERROR - missing parentheses
erif (age >= 18):   desnote CORRECT
```

### Oublier deschelse
```tsl
erif (x == 5):
    peric("x is 5")
desnote deschelse is optional - no error here
```

## Étapes suivantes

- Learn **[Boucles](loops.md)** to repeat code based on conditions
- Explore **[Fonctions](functions.md)** to organize conditional logic
- Discover **[Tableaux](lists.md)** and iterate with conditions

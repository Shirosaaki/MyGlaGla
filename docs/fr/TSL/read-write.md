# Entrée et sortie - Communiquer avec votre programme

Les opérations d'entrée et de sortie (E/S) permettent à votre programme d'afficher des informations à l'utilisateur et potentiellement de recevoir des informations de lui.

## Sortie avec peric

La fonction `peric` affiche du texte à l'écran. C'est le principal moyen d'afficher la sortie :

```tsl
Deschodt Eric() -> int
    peric("Hello, World!")
    peric("This is my first program")
    deschodt 0
```

Sortie :
```
Hello, World!
This is my first program
```

## Impression de différents types

### Entiers
```tsl
Deschodt Eric() -> int
    eric count = 42 -> int
    peric("Count: {count}")
    
    eric sum = 10 + 20 + 30 -> int
    peric("Sum: {sum}")
    
    deschodt 0
```

Sortie :
```
Count: 42
Sum: 60
```

### Flottants
```tsl
Deschodt Eric() -> int
    eric pi = 3.14159 -> float
    eric price = 19.99 -> float
    
    peric("Pi is approximately: {pi}")
    peric("Price: ${price}")
    
    deschodt 0
```

Sortie :
```
Pi is approximately: 3.14159
Price: $19.99
```

### Chaînes de caractères
```tsl
Deschodt Eric() -> int
    eric name = "Alice" -> string
    eric greeting = "Hello" -> string
    
    peric("{greeting}, {name}!")
    
    deschodt 0
```

Sortie :
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

Sortie :
```
Active: #t
Complete: #f
```

### Caractères
```tsl
Deschodt Eric() -> int
    eric initial = #\A -> char
    eric symbol = #\@ -> char
    
    peric("Initial: {initial}")
    peric("Symbol: {symbol}")
    
    deschodt 0
```

Sortie :
```
Initial: A
Symbol: @
```

## Interpolation de chaînes

À l'intérieur des chaînes, utilisez `{variable}` pour insérer des valeurs de variables :

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

Sortie :
```
Hello Bob!
You are 25 years old
Your score: 95.5%
```

## Impressions multiples

Utilisez plusieurs appels `peric` pour imprimer sur des lignes séparées :

```tsl
Deschodt Eric() -> int
    peric("First line")
    peric("Second line")
    peric("Third line")
    
    deschodt 0
```

Sortie :
```
First line
Second line
Third line
```

## Impression d'expressions

Vous pouvez imprimer directement le résultat des expressions :

```tsl
Deschodt Eric() -> int
    peric("2 + 3 = {2 + 3}")
    peric("10 * 5 = {10 * 5}")
    peric("20 / 4 = {20 / 4}")
    
    deschodt 0
```

Sortie :
```
2 + 3 = 5
10 * 5 = 50
20 / 4 = 5
```

## Impression des éléments du tableau

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

Sortie :
```
Score 0: 85
Score 1: 92
Score 2: 78
```

## Impression des Champs de structure

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

Sortie :
```
Name: Charlie
Age: 30
City: New York
```

## Exemples de sortie formatée

### Sortie de type tableau
```tsl
Deschodt Eric() -> int
    peric("Item     | Price | Qty")
    peric("---------+-------+----")
    peric("Apple    | 0.50  | 5")
    peric("Banana   | 0.30  | 3")
    peric("Orange   | 0.75  | 7")
    
    deschodt 0
```

Sortie :
```
Item     | Price | Qty
---------+-------+----
Apple    | 0.50  | 5
Banana   | 0.30  | 3
Orange   | 0.75  | 7
```

### Rapport d'avancement
```tsl
Deschodt Eric() -> int
    eric completed = 7 -> int
    eric total = 10 -> int
    eric percent = completed * 100 / total -> int
    
    peric("Progress: {percent}%")
    peric("Completed: {completed}/{total}")
    
    deschodt 0
```

Sortie :
```
Progress: 70%
Completed: 7/10
```

## Exemple pratique : Bulletin scolaire

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

Sortie :
```
===== REPORT CARD =====

Subject      | Score
-------------+------
Mathematics  | 85
English      | 92
Science      | 88

Average: 88
```

## Exemple pratique : Sortie de calcul

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

Sortie :
```
Triangle Calculator
==================
Base: 5
Height: 3
Area: 7 square units
```

## Exemple pratique : Sortie de boucle avec des étiquettes

```tsl
Deschodt Eric() -> int
    peric("Table de multiplication (7s)")
    peric("==========================")
    
    aer i in range(1, 11):
        eric result = 7 * i -> int
        peric("7 × {i} = {result}")
    
    deschodt 0
```

Sortie :
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

## Exemple pratique : Messages d'état

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

Sortie :
```
SALES REPORT
============
Items Sold: 150
Target: 200
Achievement: 75%
Status: 75 more to go
```

## Lecture de l'entrée utilisateur avec romaric

Utilisez la fonction `romaric` pour lire l'entrée de l'utilisateur. Elle invite avec un message et renvoie l'entrée de l'utilisateur sous forme de chaîne :

```tsl
Deschodt Eric() -> int
    eric name = romaric("Enter your name: ") -> string
    peric("Hello, {name}!")
    deschodt 0
```

Interaction :
```
Enter your name: Alice
Hello, Alice!
```

### Entrées multiples

```tsl
Deschodt Eric() -> int
    eric firstName = romaric("First name: ") -> string
    eric lastName = romaric("Last name: ") -> string
    eric age = romaric("Age: ") -> string
    
    peric("Welcome {firstName} {lastName}, age {age}")
    
    deschodt 0
```

Interaction :
```
First name: John
Last name: Doe
Age: 30
Welcome John Doe, age 30
```

## Lecture de fichiers avec renaud

Utilisez la fonction `renaud` pour lire l'intégralité du contenu d'un fichier dans une chaîne :

```tsl
Deschodt Eric() -> int
    eric content = renaud("input.txt") -> string
    peric("File contents:")
    peric(content)
    deschodt 0
```

Cela lit le fichier `input.txt` et stocke son contenu entier dans la variable `content`.

### Traitement des données de fichier

```tsl
Deschodt Eric() -> int
    eric data = renaud("data.txt") -> string
    peric("Data loaded successfully")
    peric("Length: {data}")
    
    deschodt 0
```

## Écriture de fichiers avec marvin

Utilisez la fonction `marvin` pour écrire du contenu dans un fichier :

```tsl
Deschodt Eric() -> int
    eric message = "Hello, File!" -> string
    marvin("output.txt", message)
    peric("Written to output.txt")
    
    deschodt 0
```

Cela crée (ou écrase) le fichier `output.txt` avec le contenu de `message`.

### Écriture de plusieurs valeurs

```tsl
Deschodt Eric() -> int
    eric line1 = "First line" -> string
    eric line2 = "Second line" -> string
    eric content = line1 + "\n" + line2 -> string
    
    marvin("report.txt", content)
    peric("Report saved")
    
    deschodt 0
```

## Exemple pratique : Programme interactif

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

Interaction :
```
What is your name? Alice
What is your age? 28
What city do you live in? Paris
Profile saved to profile.txt
```

## Exemple pratique : Lecture et traitement de fichiers

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

## Exemple pratique : Concaténation de fichiers

```tsl
Deschodt Eric() -> int
    eric file1Content = renaud("file1.txt") -> string
    eric file2Content = renaud("file2.txt") -> string
    
    eric combined = file1Content + "\n---\n" + file2Content -> string
    marvin("combined.txt", combined)
    
    peric("Files combined into combined.txt")
    
    deschodt 0
```

## Débogage avec la sortie

Utilisez `peric` pour déboguer votre programme en imprimant les valeurs des variables :

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

Sortie :
```
DEBUG: x = 10
DEBUG: after +5, x = 15
DEBUG: after *2, x = 30
```

Cela vous aide à suivre l'exécution et à trouver des erreurs.

## Erreurs de sortie courantes

### Accolades d'interpolation manquantes
```tsl
eric value = 42 -> int
peric("Value: value")     desnote ERROR - prints literal "value"
peric("Value: {value}")   desnote CORRECT - prints "Value: 42"
```

### Nom de variable incorrect
```tsl
eric count = 5 -> int
peric("Count: {cout}")    desnote ERROR - 'cout' not defined
peric("Count: {count}")   desnote CORRECT
```

### Décalage de typees (Auto-converted)
```tsl
eric x = 42 -> int
peric("X: {x}")           desnote Works - prints "X: 42"
```

La plupart des conversions de type se produisent automatiquement lors de l'impression.

## Meilleures pratiques

1. **Étiquettes claires** : étiquetez toujours ce que vous imprimez
2. **Formatage cohérent** : conservez un format de sortie cohérent
3. **Messages utiles** : utilisez des messages qui aident les utilisateurs à comprendre la sortie
4. **Marqueurs de débogage** : préfixez la sortie de débogage avec « DEBUG : » pour un filtrage facile
5. **Sections séparées** : utilisez des lignes vides pour séparer les sections logiques
6. **Convivial** : rendez la sortie lisible et bien organisée
7. **Tester la sortie** : vérifiez que la sortie semble correcte avant de finaliser

## Étapes suivantes

- Combinez les E/S avec **[Fonctions](functions.md)** pour créer des routines d'entrée/sortie réutilisables
- Utilisez **[Boucles](loops.md)** avec `peric` pour imprimer des motifs et des tableaux
- Créez des programmes interactifs avec `romaric` pour l'entrée utilisateur
- Gérez les fichiers de données avec `renaud` et `marvin` pour la persistance
- Formatez la sortie **[Structures](structs.md)** pour l'affichage de données complexes
- Imprimez **[Tableaux](lists.md)** avec des boucles pour des rapports détaillés

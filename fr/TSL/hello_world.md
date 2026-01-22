# Hello World - Démarrage avec TSL

## Votre premier programme

Le programme TSL le plus simple imprime "Hello, World!":

```tsl
Deschodt Eric() -> int
    peric("Salut, monde !")
    deschodt 0
```

Quand vous exécutez ce programme, il affiche:
```
Salut, monde !
```

## Comprendre le code

### `Deschodt` - Déclaration de fonction
- `Deschodt` est le mot-clé pour définir une fonction
- Chaque programme TSL a besoin an `Eric` function (the point d'entrée)
- Pensez-le comme `main()` in C or Java

### `Eric()` - Fonction principale
- `Eric` est le nom spécial de la fonction principale
- The parentheses `()` indiquent qu'il n'a pas de paramètres
- C'est ici que votre programme commence à s'exécuter

### `-> int` - Type de retour
- Spécifie que la fonction retourne an integer
- `0` indique l'exécution réussie (standard dans la plupart des systèmes)
- D'autres types de retour pourraient être `string`, `float`, `void`, etc.

### `peric(...)` - Sortie d'impression
- `peric` signifie "print" (in French: "écrire")
- Prend un argument de chaîne
- Imprime à la console and ajoute une nouvelle ligne
- Peut utiliser l'interpolation de chaîne avec `{variable}`

### `deschodt` - Déclaration de retour
- `deschodt` signifie "return" (in French: "descendre" → down)
- Quitte la fonction and retourne une valeur
- `deschodt 0` retourne le code de sortie 0 (success)

## Exécution de votre programme

### Compiler et exécuter
```bash
./glados < hello.tsl
```

### REPL interactif
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

### Impression de plusieurs lignes
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

### Utiliser l'interpolation de chaîne
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

### Codes de retour différents
```tsl
Deschodt Eric() -> int
    erif (someCondition):
        deschodt 1    desnote error exit
    deschelse:
        deschodt 0    desnote success exit
```

## Étapes suivantes

Maintenant que vous comprenez la structure de base, explorez:
1. **[Variables](variable.md)** - Stocker et manipuler les données
2. **[Conditions](condition.md)** - Prendre des décisions dans votre code
3. **[Boucles](loops.md)** - Répéter les actions
4. **[Fonctions](functions.md)** - Organiser le code réutilisable

Bon codage!

# GLaDOS LISP Test Suite

Ce dossier contient une suite de tests complète pour l'interpréteur LISP GLaDOS.

## Structure des tests

```
files_test/
├── atoms/           # Tests des atomes (entiers, booléens, symboles)
├── lists/           # Tests du parsing des listes
├── errors/          # Tests d'erreur (doivent retourner exit code 84)
├── lambda/          # Tests des fonctions lambda
├── define/          # Tests des définitions et bindings
├── builtins/        # Tests des fonctions builtin (+, -, *, div, mod, eq?, <)
├── conditionals/    # Tests des expressions conditionnelles (if)
├── complex/         # Tests de programmes complexes
├── edge_cases/      # Tests des cas limites
├── run_tests.sh     # Script d'exécution automatique des tests
└── README.md        # Ce fichier
```

## Utilisation

### Exécuter tous les tests automatiquement

```bash
cd /path/to/GlaGla
chmod +x files_test/run_tests.sh
./files_test/run_tests.sh ./glados
```

### Exécuter un test individuellement

```bash
./glados < files_test/complex/factorial.scm
echo $?  # Vérifier le code de retour
```

## Catégories de tests

### 1. Atoms (`atoms/`)
- Entiers positifs, négatifs, zéro
- Grands entiers (64 bits)
- Booléens `#t` et `#f`
- Symboles simples

### 2. Lists (`lists/`)
- Listes vides
- Listes simples
- Listes imbriquées
- Espaces, tabs, retours à la ligne

### 3. Errors (`errors/`) - Doivent retourner exit code 84
- Variable non définie
- Parenthèses manquantes/en trop
- Division/modulo par zéro
- Mauvais nombre d'arguments
- Types incorrects
- Syntaxe invalide pour define/lambda/if
- Appel de non-procédure

### 4. Lambda (`lambda/`)
- Lambda simple
- Lambda sans arguments
- Lambda avec un argument
- Appel immédiat de lambda
- Lambda assigné à variable
- Lambdas imbriqués
- Closures
- Shadowing
- Lambda comme argument
- Lambda retournant lambda (currying)

### 5. Define (`define/`)
- Define simple
- Define avec expression
- Define de booléens
- Defines multiples
- Defines chaînés
- Fonctions nommées
- Redéfinition

### 6. Builtins (`builtins/`)
- `+` : addition
- `-` : soustraction
- `*` : multiplication
- `div` : division entière
- `mod` : modulo
- `eq?` : égalité
- `<` : strictement inférieur
- Opérations imbriquées

### 7. Conditionals (`conditionals/`)
- if avec branche vraie
- if avec branche fausse
- if avec comparaisons
- if imbriqués
- if avec eq?
- if avec lambda
- if chaînés

### 8. Complex Programs (`complex/`)
- Factorielle (récursive)
- Factorielle (tail-recursive)
- Fibonacci
- PGCD (GCD)
- Puissance
- Valeur absolue
- Max/Min
- Somme de 1 à n
- is-even/is-odd
- Fonctions d'ordre supérieur
- Opérateurs de comparaison (>, <=, >=, !=)

### 9. Edge Cases (`edge_cases/`)
- Valeur unique
- Expressions multiples
- Noms de symboles longs
- Caractères spéciaux dans symboles
- Imbrication profonde
- Identités arithmétiques
- Grandes computations
- Récursion profonde
- Commentaires
- Whitespace mixte

## Résultats attendus

Chaque fichier de test contient un commentaire en première ligne indiquant le résultat attendu :
- Tests normaux : retour de la valeur attendue avec exit code 0
- Tests d'erreur : exit code 84

## Ajout de nouveaux tests

Pour ajouter un nouveau test :
1. Créer un fichier `.scm` dans le dossier approprié
2. Ajouter un commentaire en première ligne : `; Test: Description - Expected output: X`
3. Ajouter l'appel correspondant dans `run_tests.sh`

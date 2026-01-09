# Contribuer à GLADOS

Merci de votre intérêt à contribuer à GLADOS ! Ce document fournit des directives et des instructions pour contribuer au projet.

## Table des matières

- [Code de conduite](#code-de-conduite)
- [Premiers pas](#premiers-pas)
- [Flux de travail de développement](#flux-de-travail-de-développement)
- [Normes de codage](#normes-de-codage)
- [Directives de commit](#directives-de-commit)
- [Processus de demande de tirage](#processus-de-demande-de-tirage)
- [Signalement des problèmes](#signalement-des-problèmes)

---

## Code de conduite

### Nos normes

- **Soyez respectueux** : Traitez tout le monde avec respect et gentillesse
- **Soyez constructif** : Fournissez des commentaires et des suggestions utiles
- **Soyez collaboratif** : Travaillez ensemble pour améliorer le projet
- **Soyez inclusif** : Accueillez les contributeurs de tous niveaux

### Comportement inacceptable

- Harcèlement, discrimination ou commentaires offensants
- Trolling, insultes ou remarques désobligeantes
- Publication d'informations privées d'autrui
- Tout comportement inapproprié dans un cadre professionnel

---

## Premiers pas

### Prérequis

1. **Installer les outils requis** :
   - Git
   - GHC (Glasgow Haskell Compiler) >= 8.10
   - Stack (outil de construction Haskell)
   - Make

2. **Fork le dépôt** sur GitHub

3. **Clonez votre fork** :
   ```bash
   git clone git@github.com:YOUR_USERNAME/GlaGla.git
   cd GlaGla
   ```

4. **Ajouter un remote upstream** :
   ```bash
   git remote add upstream git@github.com:LaTableSurGit/GlaGla.git
   ```

5. **Installer les dépendances** :
   ```bash
   stack setup
   stack build
   ```

### Se familiariser

- Lire la [Documentation technique](TECHNICAL.md)
- Parcourir le [Guide de l'utilisateur](user_guide.md)
- Vérifier les [problèmes existants](https://github.com/LaTableSurGit/GlaGla/issues)
- Exécuter les programmes d'exemple dans `examples/`

---

## Flux de travail de développement

### 1. Créer une branche

Créez toujours une nouvelle branche pour votre travail :

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

Conventions de nommage des branches :
- `feature/` - Nouvelles fonctionnalités
- `fix/` - Corrections de bugs
- `docs/` - Mises à jour de la documentation
- `refactor/` - Refactorisation du code
- `test/` - Ajouts/améliorations de tests

### 2. Apporter vos modifications

- Écrire un code propre et lisible
- Suivre les [normes de codage](#normes-de-codage)
- Ajouter des commentaires pour la logique complexe
- Mettre à jour la documentation si nécessaire

### 3. Tester vos modifications

```bash
# Run tests
make run_test

# Run style checker
./tools/tsl_style_checker.sh

# Test manually
./glados < examples/example1.tslang
```

### 4. Commiter vos modifications

Suivre les [directives de commit](#directives-de-commit) :

```bash
git add .
git commit -m "feat: add new feature description"
```

### 5. Garder votre branche à jour

```bash
# Fetch upstream changes
git fetch upstream

# Rebase on upstream main
git rebase upstream/main

# Or merge if you prefer
git merge upstream/main
```

### 6. Pousser et créer une PR

```bash
git push origin feature/your-feature-name
```

Ensuite, créez une Pull Request sur GitHub.

---

## Normes de codage

### Style de code Haskell

#### Conventions de nommage

```haskell
-- Functions and variables: camelCase
parseExpression :: String -> Maybe Ast
currentValue :: Int

-- Types and constructors: PascalCase
data ExpressionType = IntType | BoolType
newtype Environment = Environment (Map String Value)

-- Constants: camelCase or UPPER_CASE for truly constant values
maxIterations :: Int
maxIterations = 1000
```

#### Formatage

```haskell
-- 4 spaces for indentation (no tabs)
myFunction :: Int -> String -> IO ()
myFunction count message = do
    putStrLn message
    if count > 0
        then do
            myFunction (count - 1) message
        else
            return ()

-- Line length: try to keep under 80 characters
-- Break long function signatures
longFunctionName 
    :: VeryLongTypeName 
    -> AnotherLongType 
    -> Maybe Result

-- Align list elements
myList = 
    [ element1
    , element2
    , element3
    ]

-- Use qualified imports for common modules
import qualified Data.Map as Map
import qualified Data.Set as Set
```

#### Documentation

```haskell
-- | Brief one-line description
--
-- Longer description with more details.
-- Can span multiple lines.
--
-- Arguments:
-- * First argument description
-- * Second argument description
--
-- Example:
-- >>> calculateSum [1, 2, 3]
-- 6
calculateSum :: [Int] -> Int
calculateSum = sum
```

#### Bonnes pratiques

```haskell
-- Use explicit type signatures
goodFunction :: Int -> String
goodFunction x = show x

-- Avoid partial functions when possible
safeDivide :: Int -> Int -> Maybe Int
safeDivide _ 0 = Nothing
safeDivide x y = Just (x `div` y)

-- Use pattern matching
processResult :: Either String Int -> String
processResult (Left err) = "Error: " ++ err
processResult (Right val) = "Success: " ++ show val

-- Use let/where for readability
complexCalculation :: Int -> Int
complexCalculation x = result
  where
    intermediate = x * 2
    result = intermediate + 10

-- Prefer pure functions
-- Good: pure function
double :: Int -> Int
double x = x * 2

-- Avoid when possible: impure function with side effects
badPrintDouble :: Int -> IO Int
badPrintDouble x = do
    let result = x * 2
    print result  -- Side effect
    return result
```

### Structure du module

```haskell
{-
-- EPITECH PROJECT, 2025
-- Module Name
-- File description:
-- Description of what this module does
-}

-- Module declaration with exports
module ModuleName (
    -- * Types
    MyType(..),
    OtherType,
    
    -- * Functions
    mainFunction,
    helperFunction
) where

-- Imports grouped and sorted
import Control.Monad (when, unless)
import Data.Maybe (fromMaybe)
import qualified Data.Map as Map

-- Type definitions
data MyType = Constructor1 | Constructor2

-- Function implementations
mainFunction :: Int -> String
mainFunction = undefined
```

---

## Directives de commit

### Format du message de commit

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type

- `feat` : Nouvelle fonctionnalité
- `fix` : Correction de bug
- `docs` : Documentation uniquement
- `style` : Formatage, points-virgules manquants, etc.
- `refactor` : Restructuration du code
- `test` : Ajout ou mise à jour de tests
- `chore` : Tâches de maintenance

### Exemples

```bash
# Simple feature
git commit -m "feat(parser): add support for hexadecimal literals"

# Bug fix with body
git commit -m "fix(vm): correct stack overflow in recursive calls

The call stack wasn't being properly managed when handling
deeply nested function calls. Added proper bounds checking."

# Breaking change
git commit -m "feat(ast)!: change function definition syntax

BREAKING CHANGE: Function definitions now require explicit
return type annotations."
```

### Meilleures pratiques de commit

- **Garder les commits atomiques** : Un changement logique par commit
- **Écrire des messages clairs** : Expliquer quoi et pourquoi, pas comment
- **Référencer les problèmes** : Inclure `#issue-number` dans le message de commit
- **Tester avant de commiter** : S'assurer que le code compile et que les tests passent

---

## Processus de demande de tirage

### Avant de soumettre

- [ ] Le code compile sans erreurs
- [ ] Tous les tests passent (`make run_test`)
- [ ] Le vérificateur de style passe (`./tools/tsl_style_checker.sh`)
- [ ] Documentation mise à jour (si applicable)
- [ ] Exemples mis à jour (si ajout de nouvelles fonctionnalités)
- [ ] Les messages de commit suivent les directives

### Modèle de PR

Lors de la création d'une PR, inclure :

```markdown
## Description
Brève description des changements

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Changes Made
- List specific changes
- Be detailed but concise

## Testing
- Describe how you tested
- Include test cases added

## Screenshots (if applicable)
Add screenshots for UI changes

## Related Issues
Fixes #123
Relates to #456

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] Tests pass
- [ ] No new warnings
```

### Processus de révision

1. **Vérifications automatisées** : CI/CD exécute des tests et des vérifications de style
2. **Revue de code** : Les mainteneurs examinent votre code
3. **Commentaires** : Répondre à toutes les modifications demandées
4. **Approbation** : Une fois approuvée, votre PR sera fusionnée

### Répondre aux commentaires

- Être réactif aux commentaires
- Apporter les modifications demandées dans de nouveaux commits
- Re-demander une révision après les modifications
- Être ouvert aux suggestions et à la discussion

---

## Signalement des problèmes

### Avant de créer un problème

1. **Rechercher les problèmes existants** : Votre problème existe peut-être déjà
2. **Vérifier la documentation** : La réponse pourrait être dans la documentation
3. **Reproduire le bug** : S'assurer qu'il est cohérent

### Modèle de rapport de bug

```markdown
## Bug Description
Description claire et concise du bug

## To Reproduce
Steps to reproduce:
1. Run command '...'
2. Input '...'
3. See error

## Expected Behavior
What you expected to happen

## Actual Behavior
What actually happened

## Environment
- OS: [e.g., Ubuntu 22.04]
- GHC version: [e.g., 9.0.2]
- Stack version: [e.g., 2.7.5]
- GLADOS version: [e.g., 0.4.1.0]

## Additional Context
- Error messages
- Stack traces
- Screenshots
- Related issues
```

### Modèle de demande de fonctionnalité

```markdown
## Feature Description
Description claire de la fonctionnalité

## Motivation
Why is this feature needed?
What problem does it solve?

## Proposed Solution
How should this feature work?

## Alternatives Considered
Other approaches you've thought about

## Additional Context
Any other relevant information
```

---

## Domaines nécessitant une contribution

### Haute priorité

- **Backend LLVM** : Compléter le backend du compilateur
- **Système de types** : Améliorer l'inférence de type
- **Messages d'erreur** : Meilleur rapport d'erreurs
- **Bibliothèque standard** : Ajouter des fonctions intégrées
- **Documentation** : Documentation API avec Haddock

### Bonnes premières contributions

Rechercher les problèmes étiquetés `good-first-issue` :
- Améliorations de la documentation
- Programmes d'exemple
- Couverture des tests
- Commentaires de code
- Corrections de style

### Contributions avancées

Pour les contributeurs expérimentés :
- Optimisation de la VM
- Collecte des déchets
- Compilation JIT
- Protocole de serveur de langage (LSP)
- Implémentation du débogueur

---

## Des questions ?

- **Problèmes GitHub** : Pour les bugs et les fonctionnalités
- **Discussions GitHub** : Pour les questions et les idées
- **Demandes de tirage** : Pour les contributions de code

## Reconnaissance

Les contributeurs seront reconnus dans :
- CHANGELOG.md
- README du projet
- Notes de version

Merci de contribuer à GLADOS ! 🚀

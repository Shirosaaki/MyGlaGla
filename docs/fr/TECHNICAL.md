# Documentation technique

## Table des matières

- [Aperçu de l'architecture](#architecture-overview)
- [Structure du projet](#project-structure)
- [Composants principaux](#core-components)
- [Configuration du développement](#development-setup)
- [Directives de contribution](#contributing-guidelines)
- [Style de code](#code-style)
- [Tests](#testing)
- [Système de construction](#build-system)

---

## Aperçu de l'architecture

GLADOS est un compilateur et un interpréteur pour TheShowLang (TSL), un langage de programmation personnalisé. Le projet est écrit en Haskell et suit un pipeline de compilation multi-étapes :

```
Source Code → Parser → AST → Compiler/Evaluator → Bytecode → VM
```

### Principales caractéristiques

- **Prise en charge du double analyseur**: Syntaxes TheShow et Lisp
- **Système de types**: Inférence de type de base avec annotations de type facultatives
- **Modes d'exécution**:
  - Console REPL interactive
  - Compilation par lots en LLVM IR
  - Compilation en bytecode et exécution VM
- **Fonctionnalités du langage**: Variables, fonctions, lambdas, flux de contrôle, tableaux, structures, pointeurs

---

## Structure du projet

```
.
├── app/                    # Point d'entrée de l'application
│   └── Main.hs            # Interface CLI et répartiteur de mode
├── src/                   # Code source de la bibliothèque principale
│   ├── AST.hs            # Définitions de l'arbre de syntaxe abstraite
│   ├── Bytecode.hs       # Jeu d'instructions bytecode
│   ├── Compiler.hs       # Compilateur LLVM IR
│   ├── Console.hs        # REPL interactif
│   ├── Loader.hs         # Chargeur/désassembleur de bytecode
│   ├── Parser.hs         # Répartiteur d'analyseur
│   ├── VM.hs             # Machine virtuelle
│   ├── Lib.hs            # Point d'entrée de la bibliothèque
│   ├── Lisp/
│   │   └── Parser.hs     # Analyseur de syntaxe Lisp
│   └── Theshow/
│       └── Parser.hs     # Analyseur de syntaxe TheShow
├── test/                  # Suite de tests
│   ├── Spec.hs           # Point d'entrée des tests
│   └── files_test/       # Fichiers de test
├── examples/              # Exemples de programmes TSL
├── docs/                  # Documentation
├── tools/                 # Outils de développement
├── package.yaml          # Configuration du package Stack
└── glados.cabal          # Fichier cabal généré
```

---

## Composants principaux

### 1. Analyseur (`src/Parser.hs`, `src/Theshow/Parser.hs`, `src/Lisp/Parser.hs`)

**Objectif**: Convertir le texte du code source en S-expressions

**Fonctions clés**:
- `parseSExpr :: String -> Maybe SExpr` - Analyser une seule expression
- `parseSExprMultiple :: String -> Maybe [SExpr]` - Analyser plusieurs expressions
- `setUseLisp :: Bool -> IO ()` - Basculer entre les analyseurs TheShow et Lisp

**Implémentation**:
- Utilise Megaparsec pour l'analyse
- Sélection de l'analyseur au moment de l'exécution via `IORef`
- Les deux analyseurs produisent le même type de données `SExpr`

**Exemple de flux**:
```haskell
-- Syntaxe TheShow
"(define x 42)" → SList [SSymbol "define", SSymbol "x", SInt 42]

-- Syntaxe Lisp (avec l'indicateur -l)
"(define x 42)" → SList [SSymbol "define", SSymbol "x", SInt 42]
```

### 2. AST (`src/AST.hs`)

**Objectif**: Définir et évaluer l'arbre de syntaxe abstraite

**Types clés**:

```haskell
data SExpr = SInt Int | SFloat Double | SBool Bool | SString String 
           | SChar Char | SSymbol String | SList [SExpr]

data Ast = Define String (Maybe Type) Ast
         | AstInt Int | AstFloat Double | AstBool Bool
         | Call Ast [Ast]
         | AstLambda [String] Ast
         | IfElse Ast Ast Ast
         | While Ast Ast
         | For String Ast Ast
         | ArrayAccess Ast Ast
         -- ... et plus
```

**Fonctions clés**:
- `sexprToAST :: SExpr -> Env -> Either String Ast` - Convertir S-expression en AST
- `evalAST :: Ast -> Env -> EvalResult` - Évaluer AST dans l'environnement donné

**Environnement (`Env`)**:
- Alias de type : `type Env = Map.Map String Ast`
- Stocke les liaisons de variables et les définitions de fonctions
- Transmis récursivement via l'évaluation

### 3. Compilateur (`src/Compiler.hs`)

**Objectif**: Compiler AST en LLVM IR (travail en cours)

**Fonctions clés**:
- `compileModuleLLVM :: Ast -> String` - Générer LLVM IR
- `compileToLL :: a -> b -> IO ()` - Écrire LLVM IR dans un fichier
- `compileToObject :: String -> String -> IO ()` - Compiler en fichier objet

**État actuel**: Implémentation de stub, la compilation LLVM n'est pas entièrement implémentée

**Analyse de type**:
- `collectVarTypes :: Ast -> Map.Map String Type -> Map.Map String Type`
- Effectue une inférence de type simple
- Identifie les types de variables à partir des affectations et des définitions

### 4. Bytecode (`src/Bytecode.hs`)

**Objectif**: Définir le jeu d'instructions bytecode

**Jeu d'instructions**:

```haskell
data Instruction
    = PUSH Int32        -- Push value to stack
    | POP               -- Pop from stack
    | ADD | SUB | MUL | DIV | MOD  -- Arithmetic
    | LT | EQ           -- Comparisons
    | JUMP Int32        -- Unconditional jump
    | JUMP_IF_FALSE Int32  -- Conditional jump
    | CALL Int32        -- Function call
    | RET               -- Return from function
    | LOAD_VAR Int32    -- Load variable
    | STORE_VAR Int32   -- Store variable
    | PRINT             -- Output
    | HALT              -- Stop execution
```

**Sérialisation**:
- `serializeInstruction :: Instruction -> BS.ByteString`
- `deserializeInstruction :: BS.ByteString -> Maybe Instruction`
- Format binaire pour les fichiers bytecode

### 5. Machine virtuelle (`src/VM.hs`)

**Objectif**: Exécuter les instructions bytecode

**État de la VM**:

```haskell
data VMState = VMState
    { stack :: [VMValue]
    , pc :: Int                    -- Program counter
    , callStack :: [CallFrame]
    , globals :: Map.Map String VMValue
    , locals :: [VMValue]
    , program :: [Instruction]
    , halted :: Bool
    , outputs :: [String]
    }

data VMValue
    = VMInt Int32 | VMBool Bool | VMString String
    | VMClosure Int32 Int32 [VMValue]
    | VMVoid
```

**Exécution**:
- `runVM :: [Instruction] -> VMState` - Initialiser et exécuter la VM
- `execBytecode :: VMState -> VMState` - Exécuter une seule étape
- Architecture basée sur la pile

### 6. Console (`src/Console.hs`)

**Objectif**: REPL interactif pour TheShowLang

**Fonctions clés**:
- `runConsole :: IO ()` - Démarrer le mode interactif
- `runBatch :: [SExpr] -> IO ()` - Exécuter des expressions par lots

**Fonctionnalités**:
- Utilise Haskeline pour l'édition de ligne
- Environnement persistant entre les expressions
- Gestion et affichage des erreurs

---

## Configuration du développement

### Prérequis

- **GHC**: Glasgow Haskell Compiler (>= 8.10)
- **Stack**: Outil de construction Haskell
- **Make**: Automatisation de la construction

### Installation

```bash
# Cloner le référentiel
git clone git@github.com:LaTableSurGit/GlaGla.git
cd GlaGla

# Configurer la pile Haskell
stack setup

# Construire le projet
make build

# Ou utiliser stack directement
stack build
```

### Exécution

```bash
# REPL interactif
./glados

# Exécuter le fichier
./glados < examples/example1.tslang

# Compiler en LLVM IR
./glados -S output.ll < input.tslang

# Exécuter le bytecode
./glados -x bytecode.bc

# Utiliser la syntaxe Lisp
./glados -l < lisp_file.lisp
```

---

## Directives de contribution

### Pour commencer

1. **Forker le référentiel**
2. **Créer une branche de fonctionnalité**: `git checkout -b feature/votre-fonctionnalité`
3. **Lire le guide de style de code**: Voir [coding_style/TSL-style.md](../coding_style/TSL-style.md)
4. **Effectuer vos modifications**
5. **Ajouter des tests** pour les nouvelles fonctionnalités
6. **Exécuter les tests**: `make run_test`
7. **Vérifier le style**: `./tools/tsl_style_checker.sh`
8. **Commit avec des messages clairs**
9. **Pousser et créer une demande de tirage**

### Domaines de contribution

#### Haute priorité

- **Backend du compilateur LLVM**: Compléter la génération LLVM IR dans `Compiler.hs`
- **Inférence de type**: Améliorer le système de types dans l'évaluateur AST
- **Bibliothèque standard**: Ajouter des fonctions intégrées (mathématiques, manipulation de chaînes, E/S)
- **Messages d'erreur**: Meilleur rapport d'erreurs avec les numéros de ligne et le contexte
- **Optimiseur de bytecode**: Implémenter des passes d'optimisation de bytecode

#### Priorité moyenne

- **Débogueur**: Débogueur interactif pour la VM bytecode
- **Système de paquets**: Mécanisme d'importation/exportation de modules
- **Gestion de la mémoire**: Collecteur de déchets pour la VM
- **Compilation JIT**: Compilation à la volée pour les chemins de code chauds

#### Documentation

- **Documentation API**: Commentaires Haddock pour tous les modules
- **Tutoriel de langage**: Tutoriels TSL conviviaux pour les débutants
- **Exemples de programmes**: Exemples de programmes plus complexes
- **Diagrammes d'architecture**: Représentation visuelle du pipeline de compilation

### Ajout de nouvelles fonctionnalités

#### Ajout d'un nouveau nœud AST

1. **Définir le nœud** dans `src/AST.hs`:
   ```haskell
   data Ast = ...
            | VotreNouveauNœud String Ast
            | ...
   ```

2. **Ajouter une logique d'analyse** dans `src/Theshow/Parser.hs` et/ou `src/Lisp/Parser.hs`

3. **Ajouter une évaluation** dans `src/AST.hs` dans la fonction `evalAST`:
   ```haskell
   evalAST (VotreNouveauNœud nom expr) env = do
       -- Votre logique d'évaluation
       evalAST expr env
   ```

4. **Ajouter une compilation bytecode** (facultatif) dans `src/Bytecode.hs`

5. **Ajouter des tests** dans `test/Spec.hs`

#### Ajout d'une nouvelle instruction

1. **Définir l'instruction** dans `src/Bytecode.hs`:
   ```haskell
   data Instruction = ...
                    | VOTRE_INSTRUCTION Int32
                    | ...
   ```

2. **Ajouter une sérialisation**:
   ```haskell
   serializeInstruction VOTRE_INSTRUCTION val = ...
   deserializeInstruction ... = VOTRE_INSTRUCTION <$> ...
   ```

3. **Implémenter l'exécution** dans `src/VM.hs`:
   ```haskell
   step state@VMState{...} =
       case program !! pc of
           VOTRE_INSTRUCTION val -> ...
   ```

---

## Style de code

### Directives de style Haskell

Suivez le [Guide de style TSL](../coding_style/TSL-style.md) pour des règles détaillées. Points clés :

#### Formatage

```haskell
-- Noms de fonctions : camelCase
evalExpression :: Ast -> Env -> EvalResult

-- Noms de types : PascalCase
data MonTypePersonnalisé = Constructeur1 | Constructeur2

-- Constantes : UPPER_CASE (si vraiment constant)
tailleMaximalePile :: Int
tailleMaximalePile = 1024

-- Indentation : 4 espaces
fonction :: Int -> String
fonction x =
    let résultat = x + 1
    in show résultat
```

#### Documentation

```haskell
-- | Brève description de la fonction
--
-- Explication détaillée si nécessaire
--
-- Exemple :
-- >>> maFonction 5
-- 10
maFonction :: Int -> Int
maFonction x = x * 2
```

#### Structure du module

```haskell
{-
-- EPITECH PROJECT, 2025
-- Nom du module
-- Description du fichier :
-- Brève description
-}

module NomDuModule (
    -- * Types exportés
    MonType(..),
    
    -- * Fonctions exportées
    maFonction,
    monAutreFonction
) where

import qualified Data.Map as Map
import Control.Monad (when)

-- Implémentation
```

### Style TheShowLang

Pour les exemples de programmes TSL :

```tslang
; Les commentaires utilisent des points-virgules
; Fonctions définies avec define
(define add (lambda (x y) (+ x y)))

; Variables
(define pi 3.14159)

; Flux de contrôle
(if (> x 0)
    (print "positif")
    (print "non-positif"))
```

---

## Tests

### Exécution des tests

```bash
# Exécuter tous les tests
make run_test

# Exécuter avec la couverture
make test_coverage

# Exécuter un test spécifique
stack test --ta "-m \"pattern\""
```

### Structure des tests

Les tests sont dans `test/Spec.hs` en utilisant le framework Hspec :

```haskell
import Test.Hspec

main :: IO ()
main = hspec $ do
    describe "Analyseur" $ do
        it "analyse les entiers" $ do
            parseSExpr "42" `shouldBe` Just (SInt 42)
        
        it "analyse les listes" $ do
            parseSExpr "(1 2 3)" `shouldBe` 
                Just (SList [SInt 1, SInt 2, SInt 3])
    
    describe "Évaluateur" $ do
        it "évalue l'addition" $ do
            let env = Map.empty
            evalAST (Call (AstSymbol "+") [AstInt 1, AstInt 2]) env
                `shouldReturn` Right (AstInt 3)
```

### Ajout de tests

1. **Tests unitaires**: Tester les fonctions individuelles de manière isolée
2. **Tests d'intégration**: Tester le pipeline de compilation complet
3. **Exemples de tests**: Exécuter tous les exemples de fichiers et vérifier la sortie
4. **Tests de propriétés**: Utiliser QuickCheck pour les tests basés sur les propriétés (futur)

### Fichiers de test

Exemples de fichiers de test dans `test/files_test/`:
- `basic_arithmetic.tsl`
- `control_flow.tsl`
- `functions.tsl`
- etc.

---

## Système de construction

### Cibles Makefile

```bash
# Construire l'exécutable
make build          # Équivalent à : stack build --copy-bins

# Nettoyer les artefacts de construction
make clean          # Supprimer .stack-work/
make fclean         # nettoyer + supprimer l'exécutable

# Tests
make run_test       # Exécuter la suite de tests
make test_coverage  # Générer un rapport de couverture

# Vérification du style
make style_check    # Exécuter le vérificateur de style TSL
```

### Configuration Stack

**package.yaml**: Configuration principale
- Dépendances
- Indicateurs de construction
- Exécutables et bibliothèques
- Suites de tests

**stack.yaml**: Configuration du résolveur Stack
- Version GHC
- Instantané du paquet
- Dépendances supplémentaires

### Dépendances

Bibliothèques principales (de `package.yaml`) :

```yaml
dependencies:
  - base >= 4.7 && < 5
  - megaparsec          # Analyse
  - containers          # Map, Set
  - haskeline           # REPL
  - process             # Commandes externes
  - mtl                 # Transformateurs de monades
  - bytestring          # Données binaires
  - filepath            # Manipulation des chemins
```

Dépendances de test :
```yaml
  - hspec               # Framework de test
```

---

## Débogage

### GHCi REPL

```bash
# Démarrer GHCi avec le projet chargé
stack ghci

# Charger un module spécifique
:load src/Parser.hs

# Vérification de type
:type parseSExpr
:info SExpr

# Recharger après les modifications
:reload
```

### Techniques de débogage

1. **Débogage de trace**:
   ```haskell
   import Debug.Trace
   
   maFonction x = trace ("x = " ++ show x) (x + 1)
   ```

2. **Impression de débogage dans IO**:
   ```haskell
   do
       putStrLn $ "Débogage : " ++ show valeur
       -- continuer
   ```

3. **Désassemblage de bytecode**:
   ```bash
   ./glados -d bytecode.bc  # Désassembler le bytecode
   ```

4. **Inspection de l'état de la VM**: Modifier `VM.hs` pour imprimer l'état après chaque instruction

---

## Considérations relatives aux performances

### Profilage

```bash
# Construire avec le profilage
stack build --profile

# Exécuter avec le profilage
stack exec -- glados +RTS -p

# Afficher le profil
cat glados.prof
```

### Conseils d'optimisation

1. **Utiliser des structures de données strictes** pour les grandes maps/listes
2. **Éviter la concaténation de chaînes répétée** - utiliser `Builder`
3. **Évaluation paresseuse vs stricte** - comprendre quand chacune est appropriée
4. **Récursion terminale** - s'assurer que les fonctions récursives sont terminales

---

## Feuille de route future

### Version 1.0
- [ ] Compléter le backend LLVM
- [ ] Inférence de type complète
- [ ] Bibliothèque standard
- [ ] Couverture de test complète (>80 %)

### Version 2.0
- [ ] Système de paquets/modules
- [ ] Collecte des ordures
- [ ] Compilateur d'optimisation
- [ ] Intégration IDE (LSP)

### Long terme
- [ ] Compilation JIT
- [ ] Génération de code natif
- [ ] Exécution simultanée
- [ ] Compilateur auto-hébergé

---

## Obtenir de l'aide

- **Problèmes**: Ouvrir un problème sur GitHub
- **Documentation**: Consulter le répertoire [docs/](.)
- **Exemples**: Voir le répertoire [examples/](../examples/)
- **Style de code**: [coding_style/TSL-style.md](../coding_style/TSL-style.md)

## Licence

BSD-3-Clause - Voir [LICENSE](../LICENSE)

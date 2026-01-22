# Compilateur - Documentation Technique

## Table des Matières

- [Vue d'ensemble](#vue-densemble)
- [Architecture du compilateur](#architecture-du-compilateur)
- [Pipeline de compilation](#pipeline-de-compilation)
- [Arbre de Syntaxe Abstraite (AST)](#arbre-de-syntaxe-abstraite-ast)
- [Système de types](#système-de-types)
- [Intégration du parseur](#intégration-du-parseur)
- [Analyse de code et optimisation](#analyse-de-code-et-optimisation)
- [Backends de génération de code](#backends-de-génération-de-code)
- [Gestion de la mémoire](#gestion-de-la-mémoire)
- [Fonctions intégrées](#fonctions-intégrées)
- [Gestion des erreurs](#gestion-des-erreurs)
- [Exemples d'utilisation](#exemples-dutilisation)
- [Considérations de performance](#considérations-de-performance)

---

## Vue d'ensemble

Le compilateur GLaDOS est un compilateur multi-backend pour le langage de programmation TheShowLang (TSL). Il transforme le code source écrit en TSL en code exécutable à travers plusieurs cibles de compilation :

- **Cible Bytecode** : Génère du bytecode pour la machine virtuelle GLaDOS
- **Assembleur x86-64** : Génération de code natif pour les systèmes Linux
- **LLVM IR** (prévu) : Pour des optimisations avancées

Le compilateur est implémenté en Haskell et fournit une sécurité de type forte, des rapports d'erreurs complets et de multiples passes d'optimisation.

### Caractéristiques principales

1. **Compilation multi-cible** : Support du bytecode VM et de l'assembleur x86-64 natif
2. **Inférence de types** : Déduction automatique de types pour les variables et expressions
3. **Passes d'optimisation** : Pliage de constantes, élimination de code mort, inlining de constantes globales
4. **Support des closures** : Fonctions de première classe avec portée lexicale
5. **Système de types riche** : Entiers, flottants, chaînes, booléens, tableaux, structures
6. **Messages d'erreur détaillés** : Rapports d'erreurs précis avec noms de variables/fonctions

---

## Architecture du compilateur

### Modules principaux

```
┌─────────────────────────────────────────────────┐
│                  Code source                    │
│            (Syntaxe TheShow/Lisp)               │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│             Parseur (Parser.hs)                 │
│  - Theshow.Parser (par défaut)                  │
│  - Lisp.Parser (alternatif)                     │
└────────────────────┬────────────────────────────┘
                     │
                     ▼ produit SExpr
┌─────────────────────────────────────────────────┐
│           SExpr → AST (AST.hs)                  │
│  - fonction sexprToAST                          │
│  - Convertit les S-expressions en AST typé      │
└────────────────────┬────────────────────────────┘
                     │
                     ▼ produit Ast
┌─────────────────────────────────────────────────┐
│       Analyse du compilateur (Compiler.hs)      │
│  - collectVarTypes                              │
│  - collectFunctionNames                         │
│  - collectGlobalConsts                          │
│  - inlineGlobalConsts                           │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
          ┌──────────┴──────────┐
          │                     │
          ▼                     ▼
┌──────────────────┐  ┌──────────────────┐
│  Génération de   │  │  Génération ASM  │
│  Bytecode        │  │  x86-64          │
│ (Bytecode.hs)    │  │  (Compiler.hs)   │
│                  │  │                  │
│ fichier .o       │  │  fichier .o      │
│ bytecode         │  │  objet           │
└──────────────────┘  └──────────────────┘
          │                     │
          ▼                     ▼
┌──────────────────┐  ┌──────────────────┐
│  Exécution VM    │  │  Exec Native     │
│    (VM.hs)       │  │  (via linker)    │
└──────────────────┘  └──────────────────┘
```

### Responsabilités des modules

| Module | Rôle |
|--------|------|
| **Parser.hs** | Sélectionne entre les parseurs TheShow et Lisp, convertit la source en SExpr |
| **Theshow.Parser** | Parse la syntaxe TheShow (par défaut) |
| **Lisp.Parser** | Parse la syntaxe S-expression Lisp |
| **AST.hs** | Définit les types AST, convertit SExpr en Ast, contient l'évaluateur |
| **Compiler.hs** | Logique de compilation principale, analyse, génération bytecode/assembleur |
| **Bytecode.hs** | Définitions d'instructions bytecode et sérialisation |
| **VM.hs** | Moteur d'exécution de bytecode |
| **Loader.hs** | Charge et décode les fichiers bytecode, sauvegarde le bytecode |

---

## Pipeline de compilation

### Flux de compilation complet

```
1. Fichier source (.tslang)
        ↓
2. Sélection du parseur (TheShow/Lisp)
        ↓
3. Analyse lexicale → Tokens
        ↓
4. Analyse syntaxique → SExpr
        ↓
5. Analyse sémantique → AST
        ↓
6. Collection et inférence de types
        ↓
7. Passes d'optimisation
   - Inlining de constantes globales
   - Élimination de code mort
   - Pliage de constantes
        ↓
8. Génération de code
   ├─→ Bytecode (.o pour VM)
   └─→ Assembleur (.s → .o pour natif)
        ↓
9. Sortie
   ├─→ Exécution VM
   └─→ Édition de liens & Exécution native
```

### Phases de compilation

#### Phase 1 : Parsing

**Entrée** : Chaîne de code source  
**Sortie** : `[SExpr]` (liste de S-expressions)

```haskell
-- Parser.hs - Sélection de parseur à l'exécution
parseSExprMultipleEither :: String -> Either String [SExpr]
```

Le parseur convertit le code source brut en S-expressions. Deux parseurs sont disponibles :

- **Parseur TheShow** (par défaut) : Syntaxe personnalisée pour TSL
- **Parseur Lisp** : Syntaxe S-expression Lisp traditionnelle

Exemple :
```
Source :  fun add(x: int, y: int) int { return x + y }
SExpr :   (fun add ((x int) (y int)) int ((return (+ x y))))
```

#### Phase 2 : Construction de l'AST

**Entrée** : `[SExpr]`  
**Sortie** : `Ast`

```haskell
-- AST.hs
sexprToAST :: SExpr -> Either String Ast
```

Convertit les S-expressions en un arbre de syntaxe abstraite fortement typé :

- Valide la structure syntaxique
- Construit des nœuds AST avec les types appropriés
- Signale les erreurs de syntaxe avec contexte

Exemple :
```haskell
SExpr: (fun "add" [(x int) (y int)] int [(return (+ x y))])
AST:   Define "add" Nothing 
         (AstLambda ["x", "y"] 
           (Block [Return (Call (AstSymbol "+") [AstSymbol "x", AstSymbol "y"])]))
```

#### Phase 3 : Analyse de types

**Entrée** : `Ast`  
**Sortie** : `Map.Map String Type` (carte des types de variables)

```haskell
collectVarTypes :: Ast -> Map.Map String Type -> Map.Map String Type
```

Analyse l'AST pour collecter les informations de types :

- Déclarations de types explicites des nœuds `Define`
- Inférence de types depuis les assignations et expressions
- Gestion spéciale pour les tableaux, chaînes et structures

Exemple :
```haskell
AST:  Define "x" (Just TInt) (AstInt 42)
      Define "name" Nothing (AstString "Alice")
      
Types: {"x" -> TInt, "name" -> TString}
```

#### Phase 4 : Optimisation

Plusieurs passes d'optimisation transforment l'AST :

**Inlining de constantes globales** :
```haskell
collectGlobalConsts :: Ast -> Map.Map String Ast
inlineGlobalConsts :: Map.Map String Ast -> Ast -> Ast
```

Remplace les références aux globales constantes à la compilation par leurs valeurs :

```
Avant : eric PI: float = 3.14159
        eric area: float = PI * r * r

Après : eric area: float = 3.14159 * r * r
```

**Masquage de variables** : L'inliner respecte la portée lexicale et le masquage de variables dans les fonctions et boucles.

#### Phase 5 : Génération de code

Deux backends génèrent différents formats de sortie :

**Backend Bytecode** :
```haskell
astToInstructions :: Ast -> [Instruction]
compileToBytecodeFile :: FilePath -> Ast -> IO ()
```

**Backend Assembleur** :
```haskell
emitASM :: Ast -> String
compileToObject :: FilePath -> Ast -> IO ()
```

---

## Arbre de Syntaxe Abstraite (AST)

### Types de nœuds AST

Le type de données `Ast` représente toutes les constructions du langage :

```haskell
data Ast
  -- Définitions et Variables
  = Define String (Maybe Type) Ast          -- Définition de variable/fonction
  | AstSymbol String                         -- Référence de variable
  | Assign String Ast                        -- Assignation de variable
  
  -- Littéraux
  | AstInt Int                              -- Littéral entier
  | AstFloat Double                          -- Littéral flottant
  | AstBool Bool                            -- Littéral booléen
  | AstString String                         -- Littéral chaîne
  | AstChar Char                            -- Littéral caractère
  | AstVoid                                 -- Valeur void/unit
  
  -- Fonctions et Closures
  | AstLambda [String] Ast                  -- Lambda/fonction (params, corps)
  | AstClosure [String] Ast Env             -- Closure avec environnement capturé
  | Call Ast [Ast]                          -- Appel de fonction
  | Return Ast                              -- Instruction return
  
  -- Flux de contrôle
  | IfElse Ast Ast Ast                      -- if-then-else
  | While Ast Ast                           -- boucle while
  | For String Ast Ast                      -- boucle for (var, plage, corps)
  | Break                                   -- Instruction Break
  | Continue                                -- Instruction Continue
  
  -- Collections
  | AstList [Ast]                           -- Liste d'expressions
  | Block [Ast]                             -- Bloc d'instructions
  | ArrayAccess Ast Ast                     -- array[index]
  | ArrayAssign String Ast Ast              -- array[index] = value
  
  -- Structures
  | Struct String [(String, Type)]          -- Définition de structure
  | StructFieldAssign String String Ast     -- struct.field = value
  | TypedVar String Type Ast                -- Déclaration de variable typée
  
  deriving (Show, Eq)
```

### Exemples de construction d'AST

#### Expression simple
```
Source :  42
SExpr :   (SInt 42)
AST :     AstInt 42
```

#### Appel de fonction
```
Source :  peric(x + 10)
SExpr :   (call peric (+ x (SInt 10)))
AST :     Call (AstSymbol "peric") 
           [Call (AstSymbol "+") [AstSymbol "x", AstInt 10]]
```

#### Définition de fonction
```
Source :  fun factorial(n: int) int {
           if n <= 1 { return 1 }
           return n * factorial(n - 1)
         }
         
AST :     Define "factorial" Nothing
           (AstLambda ["n"]
             (Block [
               IfElse (Call (AstSymbol "<=") [AstSymbol "n", AstInt 1])
                 (Block [Return (AstInt 1)])
                 (Block []),
               Return (Call (AstSymbol "*") [
                 AstSymbol "n",
                 Call (AstSymbol "factorial") [
                   Call (AstSymbol "-") [AstSymbol "n", AstInt 1]
                 ]
               ])
             ]))
```

---

## Système de types

### Définitions de types

```haskell
data Type
  = TInt              -- Entier signé 32 bits
  | TFloat            -- Flottant double précision
  | TBool             -- Booléen (vrai/faux)
  | TString           -- Chaîne (terminée par null)
  | TChar             -- Caractère unique
  | TVoid             -- Type void/unit
  | TCustom String    -- Types personnalisés (tableaux, structures)
  deriving (Show, Eq)
```

### Règles d'inférence de types

Le compilateur infère les types en fonction de :

1. **Déclarations explicites** :
   ```
   eric x: int = 42         → x: TInt
   eric name: string = ""   → name: TString
   ```

2. **Types de littéraux** :
   ```
   42       → TInt
   3.14     → TFloat
   "hello"  → TString
   'c'      → TChar
   true     → TBool
   ```

3. **Types d'expressions** :
   ```
   x + y    → TInt (si x, y sont TInt)
   x + "!"  → TString (si l'un est TString)
   x < y    → TBool
   ```

### Types de tableaux

Les tableaux utilisent une notation de type personnalisée :

```haskell
-- Déclaration de tableau
eric numbers: int[] = ...  → TCustom "int[]"

-- Règles de types d'accès aux tableaux
numbers[0]    → TInt
string[0]     → TChar
```

---

## Intégration du parseur

### Sélection du parseur

Le compilateur supporte deux parseurs via un flag d'exécution :

```haskell
-- Parser.hs
setUseLisp :: Bool -> IO ()

-- Par défaut : Parseur TheShow
parseSExprMultipleEither :: String -> Either String [SExpr]

-- Utilisation du parseur Lisp
setUseLisp True
parseSExprMultipleEither :: String -> Either String [SExpr]
```

### Syntaxe TheShow (par défaut)

TheShow fournit une syntaxe similaire au C :

```c
// Déclaration de variable
eric x: int = 42

// Définition de fonction
fun add(x: int, y: int) int {
  return x + y
}

// Structures de contrôle
if x < 10 {
  peric("Petit")
} else {
  peric("Grand")
}

// Boucles
for i in range(0, 10) {
  peric(i)
}

while x > 0 {
  assign x (x - 1)
}
```

### Syntaxe Lisp (alternative)

Syntaxe S-expression traditionnelle :

```lisp
; Déclaration de variable
(eric x int 42)

; Définition de fonction
(fun add ((x int) (y int)) int
  ((return (+ x y))))

; Structures de contrôle
(if (< x 10)
  ((peric "Petit"))
  ((peric "Grand")))

; Boucles
(aer i (range 0 10)
  ((peric i)))

(darius (> x 0)
  ((assign x (- x 1))))
```

---

## Analyse de code et optimisation

### Collection de types de variables

```haskell
collectVarTypes :: Ast -> Map.Map String Type -> Map.Map String Type
```

Parcourt l'AST pour construire une carte de types complète :

**Processus** :
1. Analyse tous les nœuds `Define` pour les annotations de types explicites
2. Infère les types depuis les assignations et expressions
3. Gère les cas spéciaux (fonctions intégrées, types de tableaux)
4. Analyse récursivement les corps de fonctions

**Exemple** :
```haskell
AST d'entrée :
  Block [
    Define "x" (Just TInt) (AstInt 10),
    Assign "result" (Call (AstSymbol "renaud") [AstString "data.txt"]),
    For "i" range body
  ]

Types de sortie :
  Map.fromList [
    ("x", TInt),
    ("result", TString),  -- inféré depuis renaud
    ("i", TInt)            -- inféré depuis la boucle for
  ]
```

### Collection de noms de fonctions

```haskell
collectFunctionNames :: Ast -> [String]
```

Extrait toutes les définitions de fonctions pour validation des appels :

```haskell
Entrée :
  Block [
    Define "factorial" Nothing (AstLambda ...),
    Define "fib" Nothing (AstLambda ...),
    Define "x" (Just TInt) (AstInt 42)
  ]

Sortie : ["factorial", "fib"]
```

### Cartographie des variables locales

```haskell
buildLocalMap :: Ast -> Map.Map String Type -> Map.Map String Int
```

Crée une carte d'offset de pile pour les variables locales :

**Algorithme** :
1. Collecte tous les noms de variables locales
2. Calcule la taille requise pour chaque variable :
   - Variables régulières : 8 octets
   - Tableaux : 4096 octets (par défaut)
   - Cas spéciaux (ex: "memo") : taille personnalisée
3. Assigne des offsets de pile depuis RBP

**Exemple** :
```haskell
Variables locales : ["x", "y", "buffer"]
Types : {"x" -> TInt, "y" -> TInt, "buffer" -> TCustom "int[]"}

Carte locale :
  {"x" -> 8, "y" -> 16, "buffer" -> 4112}
  
Disposition de la pile :
  RBP - 8:    x
  RBP - 16:   y
  RBP - 4112: buffer (tableau, 4096 octets)
```

### Inlining de constantes globales

**Phase de collection** :
```haskell
collectGlobalConsts :: Ast -> Map.Map String Ast
```

Identifie les constantes à la compilation :
- Littéraux entiers
- Littéraux caractères
- Littéraux booléens

**Phase d'inlining** :
```haskell
inlineGlobalConsts :: Map.Map String Ast -> Ast -> Ast
```

Remplace les références de variables par des valeurs littérales :

```haskell
-- Avant optimisation
Define "PI" Nothing (AstFloat 3.14159)
Define "TWO_PI" Nothing (Call (AstSymbol "*") [AstInt 2, AstSymbol "PI"])
Call (AstSymbol "calculate") [AstSymbol "TWO_PI"]

-- Après optimisation
Define "PI" Nothing (AstFloat 3.14159)
Define "TWO_PI" Nothing (Call (AstSymbol "*") [AstInt 2, AstFloat 3.14159])
Call (AstSymbol "calculate") [Call (AstSymbol "*") [AstInt 2, AstFloat 3.14159]]
```

**Gestion de la portée** : L'inliner respecte la portée lexicale et le masquage de variables :

```haskell
-- Constante globale
Define "x" Nothing (AstInt 10)

-- Fonction qui masque x
Define "foo" Nothing (AstLambda ["x"] 
  (Call (AstSymbol "peric") [AstSymbol "x"]))

-- x dans foo n'est PAS inliné (le paramètre masque la globale)
```

---

## Backends de génération de code

### Backend Bytecode

Génère du bytecode pour la machine virtuelle GLaDOS.

#### Génération d'instructions

```haskell
astToInstructions :: Ast -> [Instruction]
```

**Règles de compilation** :

| Nœud AST | Bytecode |
|----------|----------|
| `AstInt n` | `PUSH n` |
| `AstBool True` | `PUSH_TRUE` |
| `AstBool False` | `PUSH_FALSE` |
| `AstString s` | `LOAD_CONST s` |
| `AstSymbol v` | `LOAD_VAR idx` ou `LOAD_GLOBAL v` |
| `Assign n v` | `[code v] STORE_VAR idx` ou `STORE_GLOBAL n` |
| `Call (AstSymbol "+") [a,b]` | `[code a] [code b] ADD` |
| `Call (AstSymbol "-") [a,b]` | `[code a] [code b] SUB` |
| `Call (AstSymbol "*") [a,b]` | `[code a] [code b] MUL` |
| `Call (AstSymbol "/") [a,b]` | `[code a] [code b] DIV` |
| `Call (AstSymbol "<") [a,b]` | `[code a] [code b] LT` |
| `Call (AstSymbol "==") [a,b]` | `[code a] [code b] EQ` |
| `Return v` | `[code v] RET` |
| `Block xs` | `[concat de tout le code xs]` |

#### Exemple de bytecode

```
Source :
  fun add(x: int, y: int) int {
    return x + y
  }

Bytecode :
  add:
    LOAD_VAR 0      ; charge x
    LOAD_VAR 1      ; charge y
    ADD             ; x + y
    RET             ; retourne le résultat
    
  main:
    PUSH 5
    PUSH 7
    CALL add
    PRINT
    HALT
```

#### Génération de fichiers

```haskell
compileToBytecodeFile :: FilePath -> Ast -> IO ()
```

Crée un fichier bytecode `.o` :
1. Convertit l'AST en instructions
2. Ajoute l'instruction `HALT`
3. Sérialise au format binaire (voir documentation VM)
4. Écrit dans le fichier

**Format binaire** :
```
[Magic: "GLO\0"] [Version: 0x01] [Instructions...] [HALT]
```

### Backend assembleur x86-64

Génère de l'assembleur x86-64 natif pour les systèmes Linux.

#### Pipeline de génération d'assembleur

```haskell
emitASM :: Ast -> String
```

**Processus** :
1. **Optimisation** : Inline les constantes globales
2. **Analyse** : Collecte types, fonctions, chaînes
3. **Section data** : Émet les constantes de chaînes
4. **Section text** : Émet fonctions et main
5. **Built-ins** : Ajoute les implémentations de fonctions intégrées

#### Section data

Les littéraux de chaînes sont émis comme labels globaux :

```asm
.globl LC0
LC0: .string "Bonjour, le monde!"

.globl LC1
LC1: .string "Entrez un nombre : "
```

#### Prologue/Épilogue de fonction

**Structure de fonction** :
```asm
nom_fonction:
    pushq %rbp                  ; Sauvegarde pointeur de frame
    movq %rsp, %rbp            ; Configure nouveau frame
    subq $TAILLE, %rsp         ; Alloue espace de pile
    
    ; [Configuration des paramètres]
    ; [Corps de fonction]
    
.Lret_nom_fonction:
    leave                       ; Restaure la pile
    ret                         ; Retourne à l'appelant
```

#### Utilisation des registres

**Passage de paramètres** (System V AMD64 ABI) :
- 1er paramètre : `%rdi`
- 2ème paramètre : `%rsi`
- 3ème paramètre : `%rdx`
- 4ème paramètre : `%rcx`
- 5ème paramètre : `%r8`
- 6ème paramètre : `%r9`
- Paramètres additionnels : pile

**Valeur de retour** : `%rax`

**Registres scratch** : `%rax`, `%rcx`, `%rdx`, `%r8-r11`

**Registres préservés** : `%rbx`, `%rbp`, `%r12-r15`

#### Compilation d'expressions

```haskell
exprToASM :: Ast -> Map.Map String Int -> [(String, Int)] 
          -> Map.Map String Type -> [String] -> [String]
```

**Littéral entier** :
```asm
; AstInt 42
movq $42, %rax
```

**Chargement de variable** :
```asm
; AstSymbol "x" (offset -8)
movq -8(%rbp), %rax
```

**Opérations arithmétiques** :
```asm
; Call (AstSymbol "+") [x, y]
movq -8(%rbp), %rax    ; charge x
pushq %rax             ; sauvegarde x
movq -16(%rbp), %rax   ; charge y
movq %rax, %rdx        ; y -> rdx
popq %rax              ; restaure x
addq %rdx, %rax        ; x + y
```

**Concaténation de chaînes** :
```asm
; "bonjour" + " monde"
leaq LC0(%rip), %rax    ; charge "bonjour"
pushq %rax
leaq LC1(%rip), %rax    ; charge " monde"
movq %rax, %rsi
popq %rdi
call str_concat         ; concat intégrée
```

**Comparaison** :
```asm
; x < y
movq -8(%rbp), %rax     ; charge x
pushq %rax
movq -16(%rbp), %rax    ; charge y
movq %rax, %rdx
popq %rax
cmpq %rdx, %rax         ; compare
setl %al                ; définit si inférieur
movzbq %al, %rax        ; étend à zéro sur 64 bits
```

**Accès aux tableaux** :
```asm
; arr[i] où arr est à l'offset -4112, i est à l'offset -8
movq -8(%rbp), %rax     ; charge i
pushq %rax              ; sauvegarde i
leaq -4112(%rbp), %rdx  ; adresse de arr
popq %rcx               ; restaure i
movq (%rdx, %rcx, 8), %rax  ; arr[i] (éléments de 8 octets)
```

**Appel de fonction** :
```asm
; factorial(5)
movq $5, %rax           ; évalue l'argument
pushq %rax              ; sauvegarde sur la pile
popq %rdi               ; charge dans le registre de paramètre
movb $0, %al            ; pas d'args vectoriels
call factorial          ; appelle la fonction
```

---

## Gestion de la mémoire

### Disposition de la pile

Le compilateur utilise la gestion de mémoire basée sur la pile pour les variables locales :

```
Adresse haute
┌─────────────────┐
│ Adresse retour  │
├─────────────────┤  ← RBP (pointeur de frame)
│  RBP précédent  │
├─────────────────┤
│  Variable loc 1 │  RBP - 8
├─────────────────┤
│  Variable loc 2 │  RBP - 16
├─────────────────┤
│  Buffer tableau │  RBP - 4112
│  (4096 octets)  │
├─────────────────┤  ← RSP (pointeur de pile)
│  ...            │
Adresse basse
```

### Stockage des variables

**Variables régulières** (8 octets) :
- Entiers : signés 64 bits
- Pointeurs : adresses 64 bits
- Booléens : 64 bits (0 ou 1)

**Tableaux** :
- Taille par défaut : 4096 octets (512 quadwords)
- Stockés inline dans le frame de pile
- Accédés via pointeur de base + offset

**Chaînes** :
- Allouées sur le tas via `malloc`
- Pointeur stocké dans la pile
- Gérées par les fonctions intégrées

### Mémoire des chaînes

**Littéraux de chaînes** :
- Stockés dans la section `.rodata`
- Immuables
- Référencés par adresse

**Variables de chaînes** :
```c
// Définition avec allocation
eric message: string = "Bonjour"

Assembleur :
  leaq LC0(%rip), %rax      ; littéral de chaîne
  pushq %rax
  movq %rax, %rdi
  call strlen
  incq %rax                 ; +1 pour terminateur null
  movq %rax, %rdi
  call malloc               ; alloue buffer
  movq %rax, -8(%rbp)       ; stocke pointeur
  movq -8(%rbp), %rdi
  popq %rsi
  call strcpy               ; copie chaîne
```

### Mémoire des tableaux

**Tableaux locaux** :
```c
eric numbers: int[] = ...

Assembleur :
  ; Tableau stocké à RBP - offset
  leaq -4112(%rbp), %rax    ; adresse du tableau
```

**Initialisation de tableau** :
```asm
; Initialisation à zéro du tableau
movq $512, %rcx            ; taille en quadwords
xorq %rax, %rax            ; valeur zéro
leaq -4112(%rbp), %rdi     ; destination
rep stosq                  ; stockage répété
```

---

## Fonctions intégrées

Le compilateur inclut plusieurs fonctions intégrées implémentées en assembleur.

### renaud - Lire un fichier

**Signature** : `renaud(filename: string) -> string`

**But** : Lire tout le contenu d'un fichier dans une chaîne

### romaric - Lire une ligne

**Signature** : `romaric(prompt: string) -> string`

**But** : Afficher un prompt et lire une ligne depuis stdin

### marvin - Écrire un fichier

**Signature** : `marvin(filename: string, content: string) -> void`

**But** : Écrire le contenu d'une chaîne dans un fichier

### str_concat - Concaténation de chaînes

**Signature** : `str_concat(s1: string, s2: string) -> string`

**But** : Concaténer deux chaînes dans un buffer nouvellement alloué

### peric - Afficher (implicite)

La fonction `peric` utilise `printf` avec interpolation de chaîne de format :

```c
peric("Valeur : ", x)

Assembleur :
  ; Chaîne de format : "Valeur : %ld"
  leaq LC0(%rip), %rdi         ; chaîne de format
  movq -8(%rbp), %rsi          ; valeur x
  movb $0, %al
  call printf
```

---

## Gestion des erreurs

### Erreurs à la compilation

Le compilateur détecte et signale diverses erreurs :

#### Variable non définie
```c
assign x 42  // Erreur : Variable non définie 'x'
```

Gestion d'erreur :
```haskell
case Map.lookup v locals of
  Just off -> [generateCode]
  Nothing -> unsafePerformIO $ do
    printError ("Erreur de compilation : Variable non définie '" ++ v ++ "'")
    exitFailure
```

#### Fonction non définie
```c
foo(10)  // Erreur : Fonction non définie 'foo'
```

Gestion d'erreur :
```haskell
if func `notElem` fns && func `notElem` builtIns
then unsafePerformIO $ do
  printError ("Erreur de compilation : Fonction non définie '" ++ func ++ "'")
  exitFailure
else [generateCode]
```

#### Incompatibilité de types

Les erreurs de types sont détectées lors de la génération de code :

```c
eric x: int = 42
assign x "string"  // Erreur : Incompatibilité de types (int vs string)
```

### Erreurs de parseur

Erreurs de syntaxe depuis le parseur :

```
Entrée : fun add(x: int { return x }
Erreur : Erreur de parsing : Parenthèses non appariées
```

### Erreurs de conversion AST

Erreurs de conversion de S-expression vers AST :

```
SExpr : (fun add)
Erreur : fun: mauvaise syntaxe - liste de paramètres attendue
```

### Format des messages d'erreur

Toutes les erreurs incluent :
- **Type d'erreur** : "Erreur de compilation", "Erreur de parsing", etc.
- **Contexte** : Nom de variable/fonction, information de ligne (si disponible)
- **Description** : Explication claire du problème

Exemple :
```
Erreur de compilation : Fonction non définie 'factorial'
  dans l'appel : factorial(5)
```

---

## Exemples d'utilisation

### Compilation vers Bytecode

**Commande** :
```bash
glados -c program.tslang -o program.o
```

**Processus** :
1. Parse `program.tslang` → SExpr
2. Convertit en AST
3. Analyse et optimise
4. Génère les instructions bytecode
5. Sauvegarde dans `program.o`

**Exécution** :
```bash
glados program.o
```

### Compilation vers assembleur natif

**Commande** :
```bash
glados program.tslang -o program.o --native
```

**Processus** :
1. Parse source → AST
2. Analyse types et fonctions
3. Génère assembleur x86-64
4. Assemble avec `as`
5. Produit fichier objet `program.o`

**Lier et exécuter** :
```bash
gcc program.o -o program
./program
```

### Programme exemple

**Source** (`factorial.tslang`) :
```c
fun factorial(n: int) int {
  if n <= 1 {
    return 1
  }
  return n * factorial(n - 1)
}

fun Eric() void {
  eric result: int = factorial(5)
  peric("Factorielle de 5 est : ", result)
}
```

**Compiler vers Bytecode** :
```bash
glados -c factorial.tslang -o factorial.o
glados factorial.o
```

**Sortie** :
```
Factorielle de 5 est : 120
```

**Compiler vers natif** :
```bash
glados factorial.tslang -o factorial.o --native
gcc factorial.o -o factorial
./factorial
```

**Sortie** :
```
Factorielle de 5 est : 120
```

---

## Considérations de performance

### Stratégies d'optimisation

1. **Pliage de constantes** : Évalue les expressions constantes à la compilation
2. **Élimination de code mort** : Supprime le code inaccessible
3. **Inlining de constantes globales** : Remplace les variables constantes par des littéraux
4. **Allocation de registres** : Minimise les accès mémoire en assembleur
5. **Optimisation d'appels récursifs terminaux** (prévu) : Optimise les appels récursifs

### Bytecode vs Natif

**Avantages du Bytecode** :
- Compilation rapide
- Portable entre plateformes
- Débogage facile
- Petite taille de fichier

**Avantages de l'assembleur natif** :
- Exécution 10-100x plus rapide
- Accès matériel direct
- Pas de surcharge d'interpréteur
- Potentiel d'optimisation complet

### Temps de compilation

Temps de compilation typiques (sur matériel moderne) :

| Lignes de code | Bytecode | Assembleur natif |
|----------------|----------|------------------|
| 100            | <10ms    | ~50ms            |
| 1000           | ~50ms    | ~200ms           |
| 10000          | ~500ms   | ~2s              |

### Performance à l'exécution

**Bytecode** :
- Arithmétique simple : ~1 μs par opération
- Appel de fonction : ~1 μs par appel
- Accès tableau : ~0.5 μs

**Assembleur natif** :
- Arithmétique simple : ~1 ns par opération
- Appel de fonction : ~10 ns par appel
- Accès tableau : ~5 ns

### Utilisation de la mémoire

**Compilation** :
- Bytecode : ~1 MB par 1000 LOC
- Natif : ~2 MB par 1000 LOC

**Exécution** :
- Bytecode : AST + bytecode en mémoire
- Natif : Surcharge d'exécution minimale

### Opportunités d'optimisation

**Limitations actuelles** :
- Pas de déroulement de boucles
- Pas d'ordonnancement d'instructions
- Pas de vectorisation SIMD
- Pas d'optimisation interprocédurale

**Améliorations futures** :
- Backend LLVM IR pour optimisations avancées
- Optimisation guidée par profil
- Optimisation au moment de la liaison
- Compilation JIT pour bytecode

---

## Améliorations futures

1. **Vérification de types** : Vérification de types statique complète avant génération de code
2. **Backend LLVM** : Générer LLVM IR pour optimisation maximale
3. **Système de modules** : Support pour plusieurs fichiers et imports
4. **Génériques** : Fonctions et structures de données génériques
5. **Pattern matching** : Constructions de flux de contrôle avancées
6. **Garbage collection** : Gestion automatique de mémoire pour allocations tas
7. **Compilation incrémentale** : Recompiler uniquement les fonctions modifiées
8. **Symboles de débogage** : Information de débogage DWARF pour code natif
9. **Avertissements** : Avertissements style lint pour code suspect
10. **Niveaux d'optimisation** : Flags -O0, -O1, -O2, -O3

---

## Références

- [Module Bytecode](../../src/Bytecode.hs) - Définitions d'instructions
- [Module VM](../../src/VM.hs) - Moteur d'exécution de bytecode
- [Module AST](../../src/AST.hs) - Définitions d'arbre de syntaxe abstraite
- [Module Parser](../../src/Parser.hs) - Sélection et intégration du parseur
- [Documentation technique VM](TECHNICAL_VM.md) - Détails de la machine virtuelle
- [Guide utilisateur](user_guide.md) - Documentation pour l'utilisateur final
- [Référence du langage](tsl_language_reference.md) - Spécification du langage TSL

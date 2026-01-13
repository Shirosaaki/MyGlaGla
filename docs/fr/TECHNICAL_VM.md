# Machine Virtuelle - Documentation Technique

## Table des matières

- [Aperçu](#aperçu)
- [Architecture de la VM](#architecture-de-la-vm)
- [Format du bytecode](#format-du-bytecode)
- [Ensemble d'instructions](#ensemble-dinstructions)
- [Modèle d'exécution](#modèle-dexécution)
- [Gestion de la mémoire](#gestion-de-la-mémoire)
- [Pile d'appels et fonctions](#pile-dappels-et-fonctions)
- [Détails d'implémentation](#détails-dimplémentation)
- [Considérations de performance](#considérations-de-performance)

---

## Aperçu

La Machine Virtuelle (VM) de GLaDOS est un interpréteur basé sur une pile conçu pour exécuter du bytecode compilé à partir du langage TheShowLang (TSL). Elle fournit un environnement d'exécution efficace avec support pour :

- **Opérations arithmétiques et de comparaison basiques**
- **Contrôle de flux avec sauts conditionnels et inconditionnels**
- **Appels de fonction avec closures et environnements capturés**
- **Gestion des variables locales et globales**
- **Manipulation de chaînes et constantes**
- **Opérations de sortie (PRINT)**

La VM est implémentée en Haskell et est étroitement intégrée au compilateur backend du bytecode.

### Principes de conception clés

1. **Architecture basée sur pile** : Toutes les opérations utilisent une pile pour passer les opérandes
2. **Ensemble d'instructions simple** : Ensemble minimal et orthogonal d'instructions
3. **Support des closures** : Fonctions de première classe avec portée lexicale
4. **Sécurité de type** : Le système de type Haskell garantit la sécurité de la mémoire

---

## Architecture de la VM

### Composants principaux

#### 1. Type VMValue

Représente les valeurs d'exécution dans la VM :

```haskell
data VMValue
  = VMInt Int32              -- entiers signés 32 bits
  | VMBool Bool              -- valeurs booléennes (#t, #f)
  | VMString String          -- littéraux de chaîne
  | VMClosure Int32 Int32 [VMValue]  -- closures avec environnement capturé
  | VMVoid                   -- valeur unité/void
  deriving (Show, Eq)
```

#### 2. Structure CallFrame

Gère le contexte d'appel de fonction :

```haskell
data CallFrame = CallFrame
  { returnAddress :: Int
  , savedLocals   :: [VMValue]
  } deriving (Show)
```

Chaque cadre d'appel stocke :
- **returnAddress** : Compteur de programme pour reprendre après le retour de fonction
- **savedLocals** : État des variables locales avant l'appel

#### 3. Type VMState

État d'exécution complet :

```haskell
data VMState = VMState
  { stack     :: [VMValue]              -- pile des opérandes
  , pc        :: Int                    -- compteur de programme
  , callStack :: [CallFrame]            -- cadres d'appel pour les retours de fonction
  , globals   :: Map.Map String VMValue -- variables globales
  , locals    :: [VMValue]              -- variables locales (cadre courant)
  , program   :: [Instruction]          -- instructions du bytecode
  , halted    :: Bool                   -- drapeau d'arrêt d'exécution
  , outputs   :: [String]               -- sortie accumulée
  } deriving (Show)
```

---

## Format du bytecode

### Structure du format binaire

Les fichiers bytecode (extension `.o`) utilisent la structure suivante :

```
┌─────────────────────────────────────────┐
│ Nombre magique : "GLO\0" (4 octets)     │
├─────────────────────────────────────────┤
│ Version : 0x01 (1 octet)                │
├─────────────────────────────────────────┤
│ Instructions (longueur variable)        │
│   [Opcode] [Opérandes] [Opcode] ...     │
├─────────────────────────────────────────┤
│ Instruction HALT (0xFF) à la fin        │
└─────────────────────────────────────────┘
```

### Codage des instructions

Chaque instruction commence par un octet opcode suivi de zéro ou plusieurs opérandes :

- **Instructions sans opérande** : 1 octet (ex: ADD, POP)
- **Opérandes Int32** : 4 octets au format little-endian (ex: PUSH, JUMP)
- **Opérandes String** : Préfixe de longueur 4 octets + données de chaîne (ex: LOAD_GLOBAL)

### Chargement de fichiers ELF

Pour les fichiers ELF, la VM extrait la section `.text` :

1. Valide le nombre magique ELF (0x7F 0x45 0x4C 0x46)
2. Localise les en-têtes de section
3. Extrait la section `.text` contenant le bytecode
4. Décode les instructions de la section extraite

---

## Ensemble d'instructions

### Référence complète des instructions

| Opcode | Instruction       | Opérandes | Effet pile | Description |
|--------|-------------------|-----------|-----------|-------------|
| 0x01   | PUSH              | Int32     | → [n]        | Empile une constante entière |
| 0x02   | POP               | aucun     | [v] →        | Dépile le sommet de la pile |
| 0x03   | ADD               | aucun     | [b,a] → [a+b]| Ajoute deux entiers |
| 0x04   | SUB               | aucun     | [b,a] → [a-b]| Soustrait des entiers |
| 0x05   | MUL               | aucun     | [b,a] → [a*b]| Multiplie des entiers |
| 0x06   | DIV               | aucun     | [b,a] → [a/b]| Division entière (b≠0) |
| 0x07   | MOD               | aucun     | [b,a] → [a%b]| Opération modulo (b≠0) |
| 0x08   | LT                | aucun     | [b,a] → [a<b]| Comparaison inférieur à |
| 0x09   | EQ                | aucun     | [b,a] → [a==b]| Comparaison égalité |
| 0x0A   | JUMP              | Int32     | (pc)         | Saut inconditionnel à adresse |
| 0x0B   | JUMP_IF_FALSE     | Int32     | [v] →        | Saute si sommet est #f |
| 0x0C   | CALL              | Int32     | (pile)       | Appelle fonction à adresse |
| 0x0D   | RET               | aucun     | [v] → v      | Retourne de la fonction |
| 0x0E   | LOAD_VAR          | Int32     | → [v]        | Charge variable locale |
| 0x0F   | STORE_VAR         | Int32     | [v] →        | Stocke dans variable locale |
| 0x10   | LOAD_GLOBAL       | String    | → [v]        | Charge variable globale |
| 0x11   | STORE_GLOBAL      | String    | [v] →        | Stocke dans variable globale |
| 0x12   | MAKE_CLOSURE      | Int32 Int32 | → [closure] | Crée closure avec env capturé |
| 0x13   | PUSH_TRUE         | aucun     | → [#t]       | Empile booléen vrai |
| 0x14   | PUSH_FALSE        | aucun     | → [#f]       | Empile booléen faux |
| 0x15   | PRINT             | aucun     | [v] →        | Affiche valeur et stocke sortie |
| 0x16   | LOAD_CONST        | String    | → [s]        | Charge constante chaîne |
| 0xFF   | HALT              | aucun     | (arrête)     | Arrête l'exécution |

### Contraintes de type

La VM impose la correction de type sur les opérations :

- **Opérations arithmétiques (ADD, SUB, MUL, DIV, MOD)** : Les deux opérandes doivent être `VMInt`
- **Comparaisons (LT, EQ)** : Les opérandes doivent être de types compatibles
- **Sauts conditionnels (JUMP_IF_FALSE)** : L'opérande doit être `VMBool`
- **Erreurs de type** : Résultent en `Left String` avec description

---

## Modèle d'exécution

### Opération basée sur pile

La VM fonctionne sur une pile LIFO (Last In, First Out). La plupart des opérations dépilent les opérandes du sommet et empilent les résultats :

```
Exemple : Calculer (2 + 3) * 4

Initiale :      []
PUSH 2:         [2]
PUSH 3:         [2, 3]
ADD:            [5]
PUSH 4:         [5, 4]
MUL:            [20]
```

### Compteur de programme et séquençage

Les instructions s'exécutent séquentiellement sauf si une instruction de contrôle de flux est rencontrée :

- **Flux normal** : Le PC s'incrémente de la taille de l'instruction
- **JUMP addr** : Le PC est défini directement à `addr`
- **JUMP_IF_FALSE addr** : Branchement conditionnel basé sur le sommet de pile
- **CALL addr** : Saut avec cadre d'appel empilé
- **RET** : Dépile cadre d'appel et saute à l'adresse de retour

### Boucle d'exécution

```haskell
execBytecode :: VMState -> (Either String VMValue, [String])
execBytecode state
  | halted state = getResult state
  | pc out of bounds = erreur "PC hors limites"
  | otherwise = case step state (program !! pc) of
      Left err      → retourne erreur
      Right newState → execBytecode newState
```

L'exécution continue jusqu'à :
1. L'instruction `HALT` est exécutée
2. Une erreur se produit
3. Le compteur de programme sort des limites

### Fonction Step

La fonction `step` implémente chaque instruction :

```haskell
step :: VMState → Instruction → Either String VMState
```

Retourne :
- **Left msg** : Condition d'erreur
- **Right state** : État VM mis à jour prêt pour l'instruction suivante

---

## Gestion de la mémoire

### Pile

La pile des opérandes stocke des éléments `VMValue` :
- Grandit/rétrécit dynamiquement au fur et à mesure que les valeurs sont empilées/dépilées
- Le dépilement d'une pile vide sur POP/opérations arithmétiques retourne une erreur
- Pas de limite de taille fixe

### Variables locales

Les variables locales sont stockées dans une liste indexée par ID de variable :

```haskell
LOAD_VAR 0    -- Charge première variable locale
STORE_VAR 1   -- Stocke dans deuxième variable locale
```

L'accès est vérifié avec limite ; les indices invalides produisent des erreurs.

### Variables globales

Les variables globales utilisent une `Map.Map String VMValue` pour la recherche par nom :

```haskell
LOAD_GLOBAL "x"    -- Charge variable globale "x"
STORE_GLOBAL "y"   -- Stocke dans variable globale "y"
```

Les lectures de variables globales non définies produisent erreur "variable globale non définie".

### Pool de constantes

Les constantes chaîne utilisent l'instruction `LOAD_CONST` :

```haskell
LOAD_CONST "Bonjour le monde!"
PRINT
```

### Exemple de disposition mémoire

```
Cadre 1 (fonction externe)
├─ locals = [100, "bonjour"]
├─ callStack = []
└─ stack = [42]

Cadre 2 (après appel de fonction)
├─ locals = [10, 20, 30]      (locals du nouveau cadre)
├─ callStack = [CallFrame {returnAddress: 50, savedLocals: [100, "bonjour"]}]
└─ stack = [42, ...]
```

---

## Pile d'appels et fonctions

### Mécanisme d'appel de fonction

#### Instruction CALL

```haskell
CALL addr  -- Appelle fonction à adresse addr
```

Exécution :
1. Crée `CallFrame` avec le PC+1 courant (adresse de retour) et les locals courants
2. Empile le cadre sur `callStack`
3. Définit le PC à `addr`
4. Continue l'exécution

#### Instruction RET

```haskell
RET  -- Retourne de la fonction
```

Exécution :
1. Dépile le cadre d'appel supérieur
2. Restaure l'adresse de retour du cadre
3. Restaure les locals du cadre
4. Définit le PC à l'adresse de retour
5. Garde la valeur de retour sur la pile

### Support des closures

#### Instruction MAKE_CLOSURE

Crée une closure avec environnement capturé :

```haskell
MAKE_CLOSURE addr nparams
```

Crée `VMClosure addr nparams capturedEnv` où :
- **addr** : Adresse bytecode du code de fonction
- **nparams** : Nombre de paramètres
- **capturedEnv** : Variables locales courants (portée lexicale)

#### Appel de closure

Quand appeler une closure :
1. Les arguments sont pris de la pile
2. Nouvelles variables locales = arguments + environnement capturé
3. La fonction s'exécute avec les locals combinés
4. Le retour dépile le cadre et restaure les locals de l'appelant

### Exemple : Closure avec variables capturées

```
PUSH 100           -- valeur externe
STORE_VAR 0        -- locals = [100]
PUSH 5             -- nparams
PUSH 10            -- adresse de fonction
MAKE_CLOSURE       -- capture locals = [100]
                   -- stack = [VMClosure(10, 5, [VMInt 100])]

CALL addr          -- appelle closure
                   -- new locals = [args...] + [100]
                   -- peut accéder au 100 capturé
```

---

## Détails d'implémentation

### Gestion d'erreurs

La VM utilise `Either String` pour la propagation d'erreurs :

```haskell
step :: VMState → Instruction → Either String VMState
```

Cas d'erreur courants :
- **Dépilement de pile vide** : Pas assez d'opérandes
- **Erreur de type** : Mauvais types d'opérandes pour l'opération
- **Division par zéro** : DIV/MOD avec diviseur zéro
- **Hors limites** : Saut/accès à variable en dehors des limites
- **Variable non définie** : Variable globale n'existe pas

### Gestion de la sortie

L'instruction PRINT accumule la sortie :

```haskell
outputs :: [String]  -- chaînes de sortie accumulées
```

La sortie est conservée tout au long de l'exécution et retournée comme deuxième élément du tuple résultat :

```haskell
runVM :: [Instruction] → (Either String VMValue, [String])
```

### Décodage d'instructions

Décodage du bytecode binaire :

```haskell
decodeProgram :: ByteString → Either String [Instruction]
decodeProgram bs = go bs []
  where
    go b acc
      | null b = Right (reverse acc)
      | otherwise = case decodeOpcode (premier octet) of
          Just decoder → decoder reste
          Nothing → Left "Opcode inconnu"
```

Chaque décodeur d'instruction :
- Prend le `ByteString` restant
- Analyse les opérandes spécifiques à l'opcode
- Retourne `(Instruction, octets restants)` ou erreur

### Codage de chaîne

Les chaînes utilisent le format préfixé par longueur :

```
[Longueur: 4 octets LE] [données chaîne UTF-8]

Exemple: "Bonjour" → 07 00 00 00 42 6F 6E 6A 6F 75 72
         ^longueur  ^données chaîne
```

### Codage Int32

Tous les opérandes entiers utilisent le format 32 bits little-endian :

```
1234 → 0xD2 0x04 0x00 0x00  (en mémoire/fichier)
```

---

## Considérations de performance

### Opportunités d'optimisation

1. **Cache d'instructions** : Pré-parser les instructions pour éviter le décodage répété
2. **Optimisation du bytecode** :
   - Évaluation de constantes
   - Élimination de code mort
   - Insertion d'adresses de saut
3. **Optimisations de machine à pile** :
   - Allocation de registres pour les valeurs fréquemment utilisées
   - Réutilisation de pool de cadres de pile
4. **Compilation JIT** : Compiler les chemins de code hot en code natif

### Limitations actuelles

- **Pas d'optimisation d'appel terminal** : Les fonctions récursives peuvent déborder la pile d'appels
- **Recherche linéaire pour les instructions** : Pas de cache d'instructions
- **Copie de chaîne** : Toutes les opérations de chaîne impliquent des copies mémoire
- **Pas de garbage collection** : Les closures conservent l'environnement capturé

### Benchmarking

Métriques de performance typiques :
- Arithmétique simple : ~10-100 μs
- Surcharge d'appel de fonction : ~1 μs par cadre
- Opération PRINT : ~10 μs par appel

---

## Intégration avec le compilateur

### Flux de génération de bytecode

```
Source TSL
    ↓
Analyseur (syntaxe Theshow/Lisp)
    ↓
AST (Arbre de syntaxe abstraite)
    ↓
Compilateur (AST → Instructions)
    ↓
Bytecode.hs (sérialiser en binaire)
    ↓
fichier .o (bytecode)
    ↓
VM.hs (execBytecode)
    ↓
Résultat + Sortie
```

### Compilation en bytecode

Le compilateur traduit les nœuds AST en instructions :

```haskell
-- Exemple : (+ 2 3) compile en :
PUSH 2
PUSH 3
ADD
```

---

## Débogage et résolution de problèmes

### Messages d'erreur d'exécution

La VM fournit des messages d'erreur détaillés :

```
"Dépilement de pile vide sur POP"
"Erreur de type dans ADD"
"Division par zéro"
"Adresse de saut hors limites"
"Variable globale non définie : x"
```

### Désassemblage du bytecode

Le module Loader fournit le désassemblage :

```bash
glados -d programme.o
```

Produit le format bytecode lisible par l'homme.

### Test

Tests unitaires pour les opérations VM dans `test/Spec.hs` :
- Opérations arithmétiques
- Contrôle de flux
- Appels de fonction
- Gestion des variables
- Gestion des closures

---

## Extensions futures

1. **Annotations de type dans le bytecode** : Meilleurs messages d'erreur
2. **Garbage collection** : Pour les environnements de closure
3. **Système de modules** : Fichiers bytecode multiples
4. **Débogueur** : Exécution pas à pas, points d'arrêt
5. **Profilage mémoire** : Suivi des modèles d'allocation

---

## Références

- [Module Bytecode](../src/Bytecode.hs)
- [Module VM](../src/VM.hs)
- [Module Loader](../src/Loader.hs)
- [Application principale](../app/Main.hs)

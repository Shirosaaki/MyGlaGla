# VM et fichiers .o - Guide d'utilisation

## Vue d'ensemble

Votre projet GLaDOS peut maintenant compiler et exécuter des fichiers bytecode `.o` grâce à une machine virtuelle intégrée.

## Architecture

### Modules créés

1. **Bytecode.hs** - Définit le jeu d'instructions de la VM
2. **VM.hs** - Machine virtuelle pour exécuter le bytecode
3. **Loader.hs** - Chargement et sauvegarde des fichiers .o
4. **Main.hs** (modifié) - Support de l'exécution de fichiers .o

### Format des fichiers .o

Les fichiers `.o` sont des fichiers binaires avec le format suivant:

- **Magic number**: `GLO\0` (4 octets)
- **Version**: `0x01` (1 octet)
- **Instructions**: Séquence d'opcodes et leurs arguments

## Jeu d'instructions

La VM supporte les instructions suivantes:

| Opcode | Instruction   | Description                         |
| ------ | ------------- | ----------------------------------- |
| 0x01   | PUSH n        | Empile une valeur entière           |
| 0x02   | POP           | Dépile une valeur                   |
| 0x03   | ADD           | Addition des deux valeurs du sommet |
| 0x04   | SUB           | Soustraction                        |
| 0x05   | MUL           | Multiplication                      |
| 0x06   | DIV           | Division                            |
| 0x07   | MOD           | Modulo                              |
| 0x08   | LT            | Comparaison <                       |
| 0x09   | EQ            | Comparaison ==                      |
| 0x0A   | JUMP          | Saut inconditionnel                 |
| 0x0B   | JUMP_IF_FALSE | Saut conditionnel                   |
| 0x0C   | CALL          | Appel de fonction                   |
| 0x0D   | RET           | Retour de fonction                  |
| 0x0E   | LOAD_VAR      | Charger variable locale             |
| 0x0F   | STORE_VAR     | Stocker variable locale             |
| 0x10   | LOAD_GLOBAL   | Charger variable globale            |
| 0x11   | STORE_GLOBAL  | Stocker variable globale            |
| 0x12   | MAKE_CLOSURE  | Créer une closure                   |
| 0x13   | PUSH_TRUE     | Empile vrai                         |
| 0x14   | PUSH_FALSE    | Empile faux                         |
| 0xFF   | HALT          | Arrêter l'exécution                 |

## Utilisation

### Exécuter un fichier .o

```bash
stack exec glados-exe fichier.o
```

ou avec le binaire compilé:

```bash
./glados-exe fichier.o
```

### Désassembler un fichier .o

Pour voir le contenu d'un fichier .o en format lisible:

```bash
stack exec glados-exe -- -d fichier.o
```

### Mode interprète (original)

Sans argument, glados lit depuis stdin (mode original):

```bash
echo "(+ 2 3)" | stack exec glados-exe
```

## Exemples de fichiers .o

Des fichiers de test sont fournis:

- **test_add.o**: Addition simple (2 + 3) → 5
- **test_mul.o**: Multiplication (4 \* 5) → 20
- **test_lt.o**: Comparaison (3 < 5) → #t
- **test_complex.o**: Expression complexe ((2 + 3) \* 4) → 20

### Exécution des tests

```bash
# Tester l'addition
stack exec glados-exe test_add.o
# Sortie: 5

# Tester la multiplication
stack exec glados-exe test_mul.o
# Sortie: 20

# Tester la comparaison
stack exec glados-exe test_lt.o
# Sortie: #t

# Tester l'expression complexe
stack exec glados-exe test_complex.o
# Sortie: 20
```

## Créer vos propres fichiers .o

Utilisez le générateur de test pour créer de nouveaux fichiers .o:

```haskell
-- tools/generate_test_bytecode.hs
import Bytecode
import Loader
import qualified Bytecode as BC

myProgram :: [Instruction]
myProgram =
    [ PUSH 10
    , PUSH 5
    , SUB
    , HALT
    ]

main :: IO ()
main = saveBytecodeFile "my_program.o" myProgram
```

Puis exécutez:

```bash
stack runghc tools/generate_test_bytecode.hs
stack exec glados-exe my_program.o
```

## Détails techniques

### Structure de la VM

La VM utilise une architecture à pile (stack-based) avec:

- **Stack**: Pile d'exécution pour les valeurs
- **PC** (Program Counter): Pointeur d'instruction
- **Call Stack**: Pile d'appels pour les fonctions
- **Globals**: Variables globales
- **Locals**: Variables locales du frame actuel

### Types de valeurs

La VM supporte:

- `VMInt`: Entiers 32 bits
- `VMBool`: Booléens
- `VMClosure`: Closures (fonctions + environnement)
- `VMVoid`: Valeur vide

### Gestion d'erreurs

La VM détecte et signale:

- Division par zéro
- Stack underflow
- Sauts hors limites
- Erreurs de typage
- Variables non définies

## Prochaines étapes

Pour compléter la partie VM du projet, vous devrez:

1. **Créer un compilateur** (AST → Bytecode) dans un module `Compiler.hs`
2. **Ajouter le support des closures** et variables capturées
3. **Implémenter une bibliothèque standard** en bytecode
4. **Optimiser le bytecode** généré
5. **Documenter le processus de compilation** (requis pour la soutenance)

## Tests supplémentaires

Vous pouvez tester avec votre propre glados compilé en .o en créant un fichier bytecode qui reproduit le comportement attendu de votre langage.

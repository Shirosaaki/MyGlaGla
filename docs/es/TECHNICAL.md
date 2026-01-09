# Documentación técnica

## Tabla de contenido

- [Descripción de la arquitectura](#architecture-overview)
- [Estructura del proyecto](#project-structure)
- [Componentes principales](#core-components)
- [Configuración del desarrollo](#development-setup)
- [Directrices de contribución](#contributing-guidelines)
- [Estilo de código](#code-style)
- [Pruebas](#testing)
- [Sistema de construcción](#build-system)

---

## Descripción de la arquitectura

GLADOS es un compilador e intérprete para TheShowLang (TSL), un lenguaje de programación personalizado. El proyecto está escrito en Haskell y sigue un pipeline de compilación de múltiples etapas:

```
Source Code → Parser → AST → Compiler/Evaluator → Bytecode → VM
```

### Características principales

- **Soporte para doble analizador**: Sintaxis TheShow y Lisp
- **Sistema de tipos**: Inferencia de tipos básica con anotaciones de tipos opcionales
- **Modos de ejecución**:
  - Consola REPL interactiva
  - Compilación por lotes a LLVM IR
  - Compilación a bytecode y ejecución en VM
- **Características del lenguaje**: Variables, funciones, lambdas, flujos de control, arreglos, estructuras, punteros

---

## Estructura del proyecto

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

## Componentes principales

### 1. Analizador (`src/Parser.hs`, `src/Theshow/Parser.hs`, `src/Lisp/Parser.hs`)

**Objetivo**: Convertir el texto del código fuente en S-expresiones

**Funciones clave**:
- `parseSExpr :: String -> Maybe SExpr` - Analizar una sola expresión
- `parseSExprMultiple :: String -> Maybe [SExpr]` - Analizar múltiples expresiones
- `setUseLisp :: Bool -> IO ()` - Alternar entre los analizadores TheShow y Lisp

**Implementación**:
- Utiliza Megaparsec para el análisis
- Selección del analizador en tiempo de ejecución a través de `IORef`
- Ambos analizadores producen el mismo tipo de datos `SExpr`

**Ejemplo de flujo**:
```haskell
-- Syntaxe TheShow
"(define x 42)" → SList [SSymbol "define", SSymbol "x", SInt 42]

-- Syntaxe Lisp (avec l'indicateur -l)
"(define x 42)" → SList [SSymbol "define", SSymbol "x", SInt 42]
```

### 2. AST (`src/AST.hs`)

**Objetivo**: Definir y evaluar el árbol de sintaxis abstracta

**Tipos clave**:

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

**Funciones clave**:
- `sexprToAST :: SExpr -> Env -> Either String Ast` - Convertir S-expression a AST
- `evalAST :: Ast -> Env -> EvalResult` - Evaluar AST en el entorno dado

**Entorno (`Env`)**:
- Alias de tipo: `type Env = Map.Map String Ast`
- Almacena las vinculaciones de variables y las definiciones de funciones
- Transmitido recursivamente a través de la evaluación

### 3. Compilador (`src/Compiler.hs`)

**Objetivo**: Compilar AST a LLVM IR (trabajo en progreso)

**Funciones clave**:
- `compileModuleLLVM :: Ast -> String` - Generar LLVM IR
- `compileToLL :: a -> b -> IO ()` - Escribir LLVM IR en un archivo
- `compileToObject :: String -> String -> IO ()` - Compilar a archivo objeto

**Estado actual**: Implementación de stub, la compilación LLVM no está completamente implementada

**Análisis de tipos**:
- `collectVarTypes :: Ast -> Map.Map String Type -> Map.Map String Type`
- Realiza una inferencia de tipos simple
- Identifica los tipos de variables a partir de las asignaciones y definiciones

### 4. Bytecode (`src/Bytecode.hs`)

**Objetivo**: Definir el conjunto de instrucciones de bytecode

**Conjunto de instrucciones**:

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

**Serialización**:
- `serializeInstruction :: Instruction -> BS.ByteString`
- `deserializeInstruction :: BS.ByteString -> Maybe Instruction`
- Formato binario para archivos de bytecode

### 5. Máquina virtual (`src/VM.hs`)

**Objetivo**: Ejecutar las instrucciones de bytecode

**Estado de la VM**:

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

**Ejecutar**:
- `runVM :: [Instruction] -> VMState` - Inicializar y ejecutar la VM
- `execBytecode :: VMState -> VMState` - Ejecutar un solo paso
- Arquitectura basada en pila

### 6. Consola (`src/Console.hs`)

**Objetivo**: REPL interactivo para TheShowLang

**Funciones clave**:
- `runConsole :: IO ()` - Iniciar el modo interactivo
- `runBatch :: [SExpr] -> IO ()` - Ejecutar expresiones por lotes

**Características**:
- Utiliza Haskeline para la edición de líneas
- Entorno persistente entre expresiones
- Manejo y visualización de errores

---

## Configuración del desarrollo

### Requisitos previos

- **GHC**: Glasgow Haskell Compiler (>= 8.10)
- **Stack**: Herramienta de construcción Haskell
- **Make**: Automatización de la construcción

### Instalación

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

### Ejecución

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

## Directrices de contribución

### Para comenzar

1. **Hacer un fork del repositorio**
2. **Crear una rama de funcionalidad**: `git checkout -b feature/tu-funcionalidad`
3. **Leer la guía de estilo de código**: Ver [coding_style/TSL-style.md](../coding_style/TSL-style.md)
4. **Realizar tus modificaciones**
5. **Agregar pruebas** para las nuevas funcionalidades
6. **Ejecutar las pruebas**: `make run_test`
7. **Verificar el estilo**: `./tools/tsl_style_checker.sh`
8. **Hacer commit con mensajes claros**
9. **Hacer push y crear una solicitud de extracción**

### Áreas de contribución

#### Alta prioridad

- **Backend del compilador LLVM**: Completar la generación de LLVM IR en `Compiler.hs`
- **Inferencia de tipos**: Mejorar el sistema de tipos en el evaluador AST
- **Biblioteca estándar**: Agregar funciones integradas (matemáticas, manipulación de cadenas, E/S)
- **Mensajes de error**: Mejorar los informes de errores con números de línea y contexto
- **Optimizador de bytecode**: Implementar pases de optimización de bytecode

#### Prioridad media

- **Depurador**: Depurador interactivo para la VM de bytecode
- **Sistema de paquetes**: Mecanismo de importación/exportación de módulos
- **Gestión de memoria**: Recolector de basura para la VM
- **Compilación JIT**: Compilación en tiempo real para rutas de código caliente

#### Documentación

- **Documentación API**: Comentarios Haddock para todos los módulos
- **Tutorial de lenguaje**: Tutoriales de TSL amigables para principiantes
- **Ejemplos de programas**: Ejemplos de programas más complejos
- **Diagramas de arquitectura**: Representación visual del pipeline de compilación

### Agregar nuevas funcionalidades

#### Agregar un nuevo nodo AST

1. **Definir el nodo** en `src/AST.hs`:
   ```haskell
   data Ast = ...
            | VotreNouveauNœud String Ast
            | ...
   ```

2. **Agregar una lógica de análisis** en `src/Theshow/Parser.hs` y/o `src/Lisp/Parser.hs`

3. **Agregar una evaluación** en `src/AST.hs` en la función `evalAST`:
   ```haskell
   evalAST (VotreNouveauNœud nom expr) env = do
       -- Votre logique d'évaluation
       evalAST expr env
   ```

4. **Agregar una compilación de bytecode** (opcional) en `src/Bytecode.hs`

5. **Agregar pruebas** en `test/Spec.hs`

#### Adición de una nueva instrucción

1. **Definir la instrucción** en `src/Bytecode.hs`:
   ```haskell
   data Instruction = ...
                    | VOTRE_INSTRUCTION Int32
                    | ...
   ```

2. **Agregar una serialización**:
   ```haskell
   serializeInstruction VOTRE_INSTRUCTION val = ...
   deserializeInstruction ... = VOTRE_INSTRUCTION <$> ...
   ```

3. **Implementar la ejecución** en `src/VM.hs`:
   ```haskell
   step state@VMState{...} =
       case program !! pc of
           VOTRE_INSTRUCTION val -> ...
   ```

---

## Estilo de código

### Directrices de estilo Haskell

Sigue la [Guía de estilo TSL](../coding_style/TSL-style.md) para reglas detalladas. Puntos clave:

#### Formateo

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

#### Documentación

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

#### Estructura del módulo

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

Para los ejemplos de programas TSL:

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

## Pruebas

### Ejecución de pruebas

```bash
# Exécuter tous les tests
make run_test

# Exécuter avec la couverture
make test_coverage

# Exécuter un test spécifique
stack test --ta "-m \"pattern\""
```

### Estructura de las pruebas

Las pruebas están en `test/Spec.hs` utilizando el framework Hspec:

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

### Adición de pruebas

1. **Pruebas unitarias**: Probar funciones individuales de manera aislada
2. **Pruebas de integración**: Probar todo el pipeline de compilación
3. **Ejemplos de pruebas**: Ejecutar todos los ejemplos de archivos y verificar la salida
4. **Pruebas de propiedades**: Utilizar QuickCheck para pruebas basadas en propiedades (futuro)

### Archivos de prueba

Ejemplos de archivos de prueba en `test/files_test/`:
- `basic_arithmetic.tsl`
- `control_flow.tsl`
- `functions.tsl`
- etc.

---

## Sistema de construcción

### Objetivos de Makefile

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

**package.yaml**: Configuración principal
- Dependencias
- Indicadores de construcción
- Ejecutables y bibliotecas
- Suites de pruebas

**stack.yaml**: Configuración del resolutor Stack
- Versión GHC
- Instantánea del paquete
- Dependencias adicionales

### Dependencias

Bibliotecas principales (de `package.yaml`):

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

Dependencias de prueba:
```yaml
  - hspec               # Framework de test
```

---

## Depuración

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

### Técnicas de depuración

1. **Depuración por traza**:
   ```haskell
   import Debug.Trace
   
   maFonction x = trace ("x = " ++ show x) (x + 1)
   ```

2. **Impresión de depuración en IO**:
   ```haskell
   do
       putStrLn $ "Débogage : " ++ show valeur
       -- continuer
   ```

3. **Desensamblaje de bytecode**:
   ```bash
   ./glados -d bytecode.bc  # Désassembler le bytecode
   ```

4. **Inspección del estado de la VM**: Modificar `VM.hs` para imprimir el estado después de cada instrucción

---

## Consideraciones sobre el rendimiento

### Perfilado

```bash
# Construire avec le profilage
stack build --profile

# Exécuter avec le profilage
stack exec -- glados +RTS -p

# Afficher le profil
cat glados.prof
```

### Consejos de optimización

1. **Utilizar estructuras de datos estrictas** para grandes mapas/listas
2. **Evitar la concatenación de cadenas repetidas** - usar `Builder`
3. **Evaluación perezosa vs estricta** - entender cuándo es apropiada cada una
4. **Recursión terminal** - asegurarse de que las funciones recursivas sean terminales

---

## Hoja de ruta futura

### Versión 1.0
- [ ] Completar el backend LLVM
- [ ] Inferencia de tipos completa
- [ ] Biblioteca estándar
- [ ] Cobertura de pruebas completa (>80 %)

### Versión 2.0
- [ ] Sistema de paquetes/módulos
- [ ] Recolección de basura
- [ ] Compilador de optimización
- [ ] Integración IDE (LSP)

### Largo plazo
- [ ] Compilación JIT
- [ ] Generación de código nativo
- [ ] Ejecución simultánea
- [ ] Compilador auto-alojado

---

## Obtener ayuda

- **Problemas**: Abrir un problema en GitHub
- **Documentación**: Consultar el directorio [docs/](.)
- **Ejemplos**: Ver el directorio [examples/](../examples/)
- **Estilo de código**: [coding_style/TSL-style.md](../coding_style/TSL-style.md)

## Licencia

BSD-3-Clause - Ver [LICENSE](../LICENSE)

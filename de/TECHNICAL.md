# Technische Dokumentation

## Inhaltsverzeichnis

- [Architekturübersicht](#architekturübersicht)
- [Projektstruktur](#projektstruktur)
- [Kernkomponenten](#kernkomponenten)
- [Entwicklungsumgebung](#entwicklungsumgebung)
- [Beitragsrichtlinien](#beitragsrichtlinien)
- [Code-Stil](#code-stil)
- [Tests](#tests)
- [Build-System](#build-system)

---

## Architekturübersicht

GLADOS ist ein Compiler und Interpreter für TheShowLang (TSL), eine benutzerdefinierte Programmiersprache. Das Projekt ist in Haskell geschrieben und folgt einer mehrstufigen Kompilierungspipeline:

```
Source Code → Parser → AST → Compiler/Evaluator → Bytecode → VM
```

### Hauptmerkmale

- **Unterstützung für zwei Parser**: TheShow- und Lisp-Syntax
- **Typensystem**: Grundlegende Typinferenz mit optionalen Typannotationen
- **Ausführungsmodi**:
  - Interaktive REPL-Konsole
  - Batch-Kompilierung zu LLVM IR
  - Bytecode-Kompilierung und VM-Ausführung
- **Sprachmerkmale**: Variablen, Funktionen, Lambdas, Kontrollfluss, Arrays, Strukturen, Zeiger

---

## Projektstruktur

```
.
├── app/                    # Application entry point
│   └── Main.hs            # CLI interface and mode dispatcher
├── src/                   # Core library source code
│   ├── AST.hs            # Abstract Syntax Tree definitions
│   ├── Bytecode.hs       # Bytecode instruction set
│   ├── Compiler.hs       # LLVM IR compiler
│   ├── Console.hs        # Interactive REPL
│   ├── Loader.hs         # Bytecode loader/disassembler
│   ├── Parser.hs         # Parser dispatcher
│   ├── VM.hs             # Virtual Machine
│   ├── Lib.hs            # Library entry point
│   ├── Lisp/
│   │   └── Parser.hs     # Lisp syntax parser
│   └── Theshow/
│       └── Parser.hs     # TheShow syntax parser
├── test/                  # Test suite
│   ├── Spec.hs           # Test entry point
│   └── files_test/       # Test files
├── examples/              # Example TSL programs
├── docs/                  # Documentation
├── tools/                 # Development tools
├── package.yaml          # Stack package configuration
└── glados.cabal          # Generated cabal file
```

---

## Kernkomponenten

### 1. Parser (`src/Parser.hs`, `src/Theshow/Parser.hs`, `src/Lisp/Parser.hs`)

**Zweck**: Konvertiert Quellcode-Text in S-Ausdrücke

**Wichtige Funktionen**:
- `parseSExpr :: String -> Maybe SExpr` - Einzelnen Ausdruck parsen
- `parseSExprMultiple :: String -> Maybe [SExpr]` - Mehrere Ausdrücke parsen
- `setUseLisp :: Bool -> IO ()` - Zwischen TheShow- und Lisp-Parser wechseln

**Implementierung**:
- Verwendet Megaparsec zum Parsen
- Laufzeit-Parser-Auswahl über `IORef`
- Beide Parser erzeugen denselben `SExpr` Datentyp

**Beispielablauf**:
```haskell
-- TheShow syntax
"(define x 42)" → SList [SSymbol "define", SSymbol "x", SInt 42]

-- Lisp syntax (with -l flag)
"(define x 42)" → SList [SSymbol "define", SSymbol "x", SInt 42]
```

### 2. AST (`src/AST.hs`)

**Zweck**: Definieren und Auswerten des Abstrakten Syntaxbaums

**Wichtige Typen**:

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
         -- ... and more
```
```markdown
**Wichtige Funktionen**:
- `sexprToAST :: SExpr -> Env -> Either String Ast` - Konvertiert S-Ausdruck in AST
- `evalAST :: Ast -> Env -> EvalResult` - Bewertet AST in der gegebenen Umgebung

**Umgebung (`Env`)**:
- Typalias: `type Env = Map.Map String Ast`
- Speichert Variablenbindungen und Funktionsdefinitionen
- Wird rekursiv durch die Auswertung übergeben

### 3. Compiler (`src/Compiler.hs`)

**Zweck**: Kompiliert AST in LLVM IR (in Arbeit)

**Wichtige Funktionen**:
- `compileModuleLLVM :: Ast -> String` - Generiert LLVM IR
- `compileToLL :: a -> b -> IO ()` - Schreibt LLVM IR in eine Datei
- `compileToObject :: String -> String -> IO ()` - Kompiliert in eine Objektdatei

**Aktueller Status**: Stub-Implementierung, LLVM-Kompilierung nicht vollständig implementiert

**Typanalyse**:
- `collectVarTypes :: Ast -> Map.Map String Type -> Map.Map String Type`
- Führt einfache Typinferenz durch
- Identifiziert Variablentypen aus Zuweisungen und Definitionen

### 4. Bytecode (`src/Bytecode.hs`)

**Zweck**: Definiert den Bytecode-Befehlssatz

**Befehlssatz**:
``````haskell
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

**Serialisierung**:  
- `serializeInstruction :: Instruction -> BS.ByteString`  
- `deserializeInstruction :: BS.ByteString -> Maybe Instruction`  
- Binärformat für Bytecode-Dateien  

### 5. Virtuelle Maschine (`src/VM.hs`)  

**Zweck**: Ausführen von Bytecode-Anweisungen  

**VM-Zustand**:

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

**Ausführung**:
- `runVM :: [Instruction] -> VMState` - VM initialisieren und ausführen
- `execBytecode :: VMState -> VMState` - Einzelne Schritte ausführen
- Stack-basierte Architektur

### 6. Konsole (`src/Console.hs`)

**Zweck**: Interaktives REPL für TheShowLang

**Wichtige Funktionen**:
- `runConsole :: IO ()` - Interaktiven Modus starten
- `runBatch :: [SExpr] -> IO ()` - Ausdrücke im Batch ausführen

**Funktionen**:
- Verwendet Haskeline zur Zeilenbearbeitung
- Persistente Umgebung über Ausdrücke hinweg
- Fehlerbehandlung und -anzeige

---

## Entwicklungssetup

### Voraussetzungen

- **GHC**: Glasgow Haskell Compiler (>= 8.10)
- **Stack**: Haskell-Bautool
- **Make**: Automatisierung des Builds

### Installation

```bash
# Clone repository
git clone git@github.com:LaTableSurGit/GlaGla.git
cd GlaGla

# Setup Haskell stack
stack setup

# Build project
make build

# Or use stack directly
stack build
```

### Laufen

```bash
# Interactive REPL
./glados

# Execute file
./glados < examples/example1.tslang

# Compile to LLVM IR
./glados -S output.ll < input.tslang

# Execute bytecode
./glados -x bytecode.bc

# Use Lisp syntax
./glados -l < lisp_file.lisp
```

---

## Mitwirkungsrichtlinien

### Erste Schritte

1. **Forke das Repository**
2. **Erstelle einen Feature-Branch**: `git checkout -b feature/your-feature`
3. **Lies den Code-Stil-Leitfaden**: Siehe [coding_style/TSL-style.md](../coding_style/TSL-style.md)
4. **Nimm deine Änderungen vor**
5. **Füge Tests** für neue Funktionalitäten hinzu
6. **Führe Tests aus**: `make run_test`
7. **Überprüfe den Stil**: `./tools/tsl_style_checker.sh`
8. **Committe mit klaren Nachrichten**
9. **Push und erstelle einen Pull Request**

### Bereiche für Beiträge

#### Hohe Priorität

- **LLVM Compiler Backend**: Vervollständige die LLVM IR-Generierung in `Compiler.hs`
- **Typinferenz**: Verbessere das Typsystem im AST-Evaluator
- **Standardbibliothek**: Füge eingebaute Funktionen hinzu (Mathematik, Zeichenfolgenmanipulation, I/O)
- **Fehlermeldungen**: Bessere Fehlerberichterstattung mit Zeilennummern und Kontext
- **Bytecode-Optimierer**: Implementiere Bytecode-Optimierungspässe

#### Mittlere Priorität

- **Debugger**: Interaktiver Debugger für die Bytecode-VM
- **Paket-System**: Modul-Import/Export-Mechanismus
- **Speicherverwaltung**: Garbage Collection für die VM
- **JIT-Kompilierung**: Just-in-time-Kompilierung für heiße Code-Pfade

#### Dokumentation

- **API-Dokumentation**: Haddock-Kommentare für alle Module
- **Sprach-Tutorial**: Einsteigerfreundliche TSL-Tutorials
- **Beispielprogramme**: Komplexere Beispielprogramme
- **Architekturdiagramme**: Visuelle Darstellung der Kompilierungspipeline

### Hinzufügen neuer Funktionen

#### Hinzufügen eines neuen AST-Knotens

1. **Definiere den Knoten** in `src/AST.hs`:
   ```haskell
   data Ast = ...
            | YourNewNode String Ast
            | ...
   ```

2. **Fügen Sie Parsing-Logik** in `src/Theshow/Parser.hs` und/oder `src/Lisp/Parser.hs` hinzu

3. **Fügen Sie die Auswertung** in `src/AST.hs` in der Funktion `evalAST` hinzu:
   ```haskell
   evalAST (YourNewNode name expr) env = do
       -- Your evaluation logic
       evalAST expr env
   ```

4. **Fügen Sie die Bytecode-Kompilierung hinzu** (optional) in `src/Bytecode.hs`

5. **Fügen Sie Tests hinzu** in `test/Spec.hs`

#### Hinzufügen einer neuen Anweisung

1. **Definieren Sie die Anweisung** in `src/Bytecode.hs`:
   ```haskell
   data Instruction = ...
                    | YOUR_INSTRUCTION Int32
                    | ...
   ```

2. **Serialisierung hinzufügen**:
   ```haskell
   serializeInstruction YOUR_INSTRUCTION val = ...
   deserializeInstruction ... = YOUR_INSTRUCTION <$> ...
   ```

3. **Implementierung der Ausführung** in `src/VM.hs`:
   ```haskell
   step state@VMState{...} =
       case program !! pc of
           YOUR_INSTRUCTION val -> ...
   ```

---

## Code-Stil

### Haskell Stilrichtlinien

Befolgen Sie den [TSL Style Guide](../coding_style/TSL-style.md) für detaillierte Regeln. Wichtige Punkte:

#### Formatierung

```haskell
-- Function names: camelCase
evalExpression :: Ast -> Env -> EvalResult

-- Type names: PascalCase
data MyCustomType = Constructor1 | Constructor2

-- Constants: UPPER_CASE (if truly constant)
maxStackSize :: Int
maxStackSize = 1024

-- Indentation: 4 spaces
function :: Int -> String
function x =
    let result = x + 1
    in show result
```

#### Dokumentation

```haskell
-- | Brief description of function
--
-- Detailed explanation if needed
--
-- Example:
-- >>> myFunction 5
-- 10
myFunction :: Int -> Int
myFunction x = x * 2
```

#### Modulstruktur

```haskell
{-
-- EPITECH PROJECT, 2025
-- Module Name
-- File description:
-- Brief description
-}

module ModuleName (
    -- * Exported types
    MyType(..),
    
    -- * Exported functions
    myFunction,
    myOtherFunction
) where

import qualified Data.Map as Map
import Control.Monad (when)

-- Implementation
```

### TheShowLang Stil

Für TSL Beispielprogramme:

```tslang
; Comments use semicolons
; Functions defined with define
(define add (lambda (x y) (+ x y)))

; Variables
(define pi 3.14159)

; Control flow
(if (> x 0)
    (print "positive")
    (print "non-positive"))
```

---

## Testen

### Tests Ausführen

```bash
# Run all tests
make run_test

# Run with coverage
make test_coverage

# Run specific test
stack test --ta "-m \"pattern\""
```

### Teststruktur

Tests befinden sich in `test/Spec.hs` unter Verwendung des Hspec-Frameworks:

```haskell
import Test.Hspec

main :: IO ()
main = hspec $ do
    describe "Parser" $ do
        it "parses integers" $ do
            parseSExpr "42" `shouldBe` Just (SInt 42)
        
        it "parses lists" $ do
            parseSExpr "(1 2 3)" `shouldBe` 
                Just (SList [SInt 1, SInt 2, SInt 3])
    
    describe "Evaluator" $ do
        it "evaluates addition" $ do
            let env = Map.empty
            evalAST (Call (AstSymbol "+") [AstInt 1, AstInt 2]) env
                `shouldReturn` Right (AstInt 3)
```

### Tests hinzufügen

1. **Unit-Tests**: Testen Sie einzelne Funktionen isoliert
2. **Integrationstests**: Testen Sie die vollständige Kompilierungspipeline
3. **Beispieltests**: Führen Sie alle Beispieldateien aus und überprüfen Sie die Ausgabe
4. **Eigenschaftstests**: Verwenden Sie QuickCheck für tests basierend auf Eigenschaften (zukünftig)

### Testdateien

Beispiel-Testdateien in `test/files_test/`:
- `basic_arithmetic.tsl`
- `control_flow.tsl`
- `functions.tsl`
- usw.

---

## Build-System

### Makefile-Ziele

```bash
# Build executable
make build          # Equivalent to: stack build --copy-bins

# Clean build artifacts
make clean          # Remove .stack-work/
make fclean         # clean + remove executable

# Testing
make run_test       # Run test suite
make test_coverage  # Generate coverage report

# Style checking
make style_check    # Run TSL style checker
```

### Stack-Konfiguration

**package.yaml**: Hauptkonfiguration
- Abhängigkeiten
- Build-Flags
- Ausführbare Dateien und Bibliotheken
- Test-Suiten

**stack.yaml**: Konfiguration des Stack-Resolvers
- GHC-Version
- Paket-Snapshot
- Zusätzliche Abhängigkeiten

### Abhängigkeiten

Kernbibliotheken (aus `package.yaml`):

```yaml
dependencies:
  - base >= 4.7 && < 5
  - megaparsec          # Parsing
  - containers          # Map, Set
  - haskeline           # REPL
  - process             # External commands
  - mtl                 # Monad transformers
  - bytestring          # Binary data
  - filepath            # Path manipulation
```

Testabhängigkeiten:
```yaml
  - hspec               # Testing framework
```

---

## Debugging

### GHCi REPL

```bash
# Start GHCi with project loaded
stack ghci

# Load specific module
:load src/Parser.hs

# Type checking
:type parseSExpr
:info SExpr

# Reload after changes
:reload
```

### Debugging-Techniken

1. **Trace-Debugging**:
   ```haskell
   import Debug.Trace
   
   myFunction x = trace ("x = " ++ show x) (x + 1)
   ```

2. **Drucken von Debugging in IO**:
   ```haskell
   do
       putStrLn $ "Debug: " ++ show value
       -- continue
   ```

3. **Bytecode-Demontage**:
   ```bash
   ./glados -d bytecode.bc  # Disassemble bytecode
   ```

4. **VM-Zustandsinspektion**: Ändere `VM.hs`, um den Zustand nach jeder Anweisung auszugeben

---

## Leistungsüberlegungen

### Profiling

```bash
# Build with profiling
stack build --profile

# Run with profiling
stack exec -- glados +RTS -p

# View profile
cat glados.prof
```

### Optimierungstipps

1. **Verwenden Sie strenge Datenstrukturen** für große Karten/Listen
2. **Vermeiden Sie wiederholte Zeichenfolgenverkettung** - verwenden Sie `Builder`
3. **Lazy vs. strikte Auswertung** - verstehen, wann jede geeignet ist
4. **Endrekursion** - sicherstellen, dass rekursive Funktionen endrekursiv sind

---

## Zukünftiger Fahrplan

### Version 1.0
- [ ] LLVM-Backend abschließen
- [ ] Vollständige Typinferenz
- [ ] Standardbibliothek
- [ ] Umfassende Testabdeckung (>80%)

### Version 2.0
- [ ] Paket-/Modulsystem
- [ ] Garbage Collection
- [ ] Optimierender Compiler
- [ ] IDE-Integration (LSP)

### Langfristig
- [ ] JIT-Kompilierung
- [ ] Native Code-Generierung
- [ ] Nebenläufige Ausführung
- [ ] Selbst-Hosting-Compiler

---

## Hilfe erhalten

- **Probleme**: Öffnen Sie ein Issue auf GitHub
- **Dokumentation**: Überprüfen Sie das [docs/](.) Verzeichnis
- **Beispiele**: Sehen Sie sich das [examples/](../examples/) Verzeichnis an
- **Code-Stil**: [coding_style/TSL-style.md](../coding_style/TSL-style.md)

## Lizenz

BSD-3-Klausel - Siehe [LICENSE](../LICENSE)

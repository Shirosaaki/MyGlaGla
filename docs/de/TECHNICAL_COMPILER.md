# Compiler - Technische Dokumentation

## Inhaltsverzeichnis

- [Überblick](#überblick)
- [Compiler-Architektur](#compiler-architektur)
- [Kompilierungs-Pipeline](#kompilierungs-pipeline)
- [Abstrakter Syntaxbaum (AST)](#abstrakter-syntaxbaum-ast)
- [Typsystem](#typsystem)
- [Parser-Integration](#parser-integration)
- [Code-Analyse und Optimierung](#code-analyse-und-optimierung)
- [Code-Generierungs-Backends](#code-generierungs-backends)
- [Speicherverwaltung](#speicherverwaltung)
- [Eingebaute Funktionen](#eingebaute-funktionen)
- [Fehlerbehandlung](#fehlerbehandlung)
- [Verwendungsbeispiele](#verwendungsbeispiele)
- [Leistungsüberlegungen](#leistungsüberlegungen)

---

## Überblick

Der GLaDOS-Compiler ist ein Multi-Backend-Compiler für die Programmiersprache TheShowLang (TSL). Er transformiert in TSL geschriebenen Quellcode durch mehrere Kompilierungsziele in ausführbaren Code:

- **Bytecode-Ziel**: Generiert Bytecode für die GLaDOS Virtual Machine
- **x86-64 Assembly**: Native Code-Generierung für Linux-Systeme
- **LLVM IR** (geplant): Für fortgeschrittene Optimierungen

Der Compiler ist in Haskell implementiert und bietet starke Typsicherheit, umfassende Fehlerberichte und mehrere Optimierungsdurchläufe.

### Hauptmerkmale

1. **Multi-Ziel-Kompilierung**: Unterstützung für VM-Bytecode und native x86-64-Assembly
2. **Typ-Inferenz**: Automatische Typ-Ableitung für Variablen und Ausdrücke
3. **Optimierungsdurchläufe**: Konstantenfaltung, Dead-Code-Eliminierung, globales Konstanten-Inlining
4. **Closure-Unterstützung**: First-Class-Funktionen mit lexikalischer Scope
5. **Reiches Typsystem**: Integer, Floats, Strings, Booleans, Arrays, Structs
6. **Detaillierte Fehlermeldungen**: Präzise Fehlerberichte mit Variablen-/Funktionsnamen

---

## Compiler-Architektur

### Hauptmodule

```
┌─────────────────────────────────────────────────┐
│                 Quellcode                        │
│            (TheShow/Lisp Syntax)                 │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│              Parser (Parser.hs)                  │
│  - Theshow.Parser (Standard)                     │
│  - Lisp.Parser (Alternative)                     │
└────────────────────┬────────────────────────────┘
                     │
                     ▼ produziert SExpr
┌─────────────────────────────────────────────────┐
│           SExpr → AST (AST.hs)                   │
│  - sexprToAST Funktion                           │
│  - Konvertiert S-Expressions zu typisiertem AST  │
└────────────────────┬────────────────────────────┘
                     │
                     ▼ produziert Ast
┌─────────────────────────────────────────────────┐
│        Compiler-Analyse (Compiler.hs)            │
│  - collectVarTypes                               │
│  - collectFunctionNames                          │
│  - collectGlobalConsts                           │
│  - inlineGlobalConsts                            │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
          ┌──────────┴──────────┐
          │                     │
          ▼                     ▼
┌──────────────────┐  ┌──────────────────┐
│  Bytecode-Gen    │  │  x86-64 ASM Gen  │
│ (Bytecode.hs)    │  │  (Compiler.hs)   │
│                  │  │                  │
│ .o Bytecode-     │  │  .o Objekt-      │
│ Datei            │  │  Datei           │
└──────────────────┘  └──────────────────┘
          │                     │
          ▼                     ▼
┌──────────────────┐  ┌──────────────────┐
│  VM-Ausführung   │  │  Native Exec     │
│    (VM.hs)       │  │  (via Linker)    │
└──────────────────┘  └──────────────────┘
```

### Modulverantwortlichkeiten

| Modul | Zweck |
|-------|-------|
| **Parser.hs** | Wählt zwischen TheShow- und Lisp-Parsern, konvertiert Quelle zu SExpr |
| **Theshow.Parser** | Parst TheShow-Syntax (Standard) |
| **Lisp.Parser** | Parst Lisp-S-Expression-Syntax |
| **AST.hs** | Definiert AST-Typen, konvertiert SExpr zu Ast, enthält Evaluator |
| **Compiler.hs** | Hauptkompilierungslogik, Analyse, Bytecode/Assembly-Generierung |
| **Bytecode.hs** | Bytecode-Instruktionsdefinitionen und Serialisierung |
| **VM.hs** | Bytecode-Ausführungsmaschine |
| **Loader.hs** | Lädt und dekodiert Bytecode-Dateien, speichert Bytecode |

---

## Kompilierungs-Pipeline

### Vollständiger Kompilierungsfluss

```
1. Quelldatei (.tslang)
        ↓
2. Parser-Auswahl (TheShow/Lisp)
        ↓
3. Lexikalische Analyse → Tokens
        ↓
4. Syntaktische Analyse → SExpr
        ↓
5. Semantische Analyse → AST
        ↓
6. Typ-Sammlung & Inferenz
        ↓
7. Optimierungsdurchläufe
   - Globales Konstanten-Inlining
   - Dead-Code-Eliminierung
   - Konstantenfaltung
        ↓
8. Code-Generierung
   ├─→ Bytecode (.o für VM)
   └─→ Assembly (.s → .o für native)
        ↓
9. Ausgabe
   ├─→ VM-Ausführung
   └─→ Linking & Native Ausführung
```

### Kompilierungsphasen

#### Phase 1: Parsing

**Eingabe**: Quellcode-String  
**Ausgabe**: `[SExpr]` (S-Expression-Liste)

```haskell
-- Parser.hs - Laufzeit-Parser-Auswahl
parseSExprMultipleEither :: String -> Either String [SExpr]
```

Der Parser konvertiert rohen Quellcode in S-Expressions. Zwei Parser sind verfügbar:

- **TheShow Parser** (Standard): Benutzerdefinierte Syntax für TSL
- **Lisp Parser**: Traditionelle Lisp-S-Expression-Syntax

Beispiel:
```
Quelle:   fun add(x: int, y: int) int { return x + y }
SExpr:    (fun add ((x int) (y int)) int ((return (+ x y))))
```

#### Phase 2: AST-Konstruktion

**Eingabe**: `[SExpr]`  
**Ausgabe**: `Ast`

```haskell
-- AST.hs
sexprToAST :: SExpr -> Either String Ast
```

Konvertiert S-Expressions in einen stark typisierten abstrakten Syntaxbaum:

- Validiert Syntaxstruktur
- Konstruiert AST-Knoten mit geeigneten Typen
- Meldet Syntaxfehler mit Kontext

#### Phase 3: Typ-Analyse

**Eingabe**: `Ast`  
**Ausgabe**: `Map.Map String Type` (Variablen-Typ-Map)

```haskell
collectVarTypes :: Ast -> Map.Map String Type -> Map.Map String Type
```

Analysiert den AST, um Typ-Informationen zu sammeln:

- Explizite Typ-Deklarationen aus `Define`-Knoten
- Typ-Inferenz aus Zuweisungen und Ausdrücken
- Spezialbehandlung für Arrays, Strings und Structs

#### Phase 4: Optimierung

Mehrere Optimierungsdurchläufe transformieren den AST:

**Globales Konstanten-Inlining**:
```haskell
collectGlobalConsts :: Ast -> Map.Map String Ast
inlineGlobalConsts :: Map.Map String Ast -> Ast -> Ast
```

Ersetzt Referenzen zu Compile-Zeit-konstanten Globals durch ihre Werte:

```
Vorher: eric PI: float = 3.14159
        eric area: float = PI * r * r

Nachher: eric area: float = 3.14159 * r * r
```

#### Phase 5: Code-Generierung

Zwei Backends generieren unterschiedliche Ausgabeformate:

**Bytecode-Backend**:
```haskell
astToInstructions :: Ast -> [Instruction]
compileToBytecodeFile :: FilePath -> Ast -> IO ()
```

**Assembly-Backend**:
```haskell
emitASM :: Ast -> String
compileToObject :: FilePath -> Ast -> IO ()
```

---

## Abstrakter Syntaxbaum (AST)

### AST-Knotentypen

Der Datentyp `Ast` repräsentiert alle Sprachkonstrukte:

```haskell
data Ast
  -- Definitionen und Variablen
  = Define String (Maybe Type) Ast          -- Variablen-/Funktionsdefinition
  | AstSymbol String                         -- Variablenreferenz
  | Assign String Ast                        -- Variablenzuweisung
  
  -- Literale
  | AstInt Int                              -- Integer-Literal
  | AstFloat Double                          -- Float-Literal
  | AstBool Bool                            -- Boolean-Literal
  | AstString String                         -- String-Literal
  | AstChar Char                            -- Zeichen-Literal
  | AstVoid                                 -- Void/Unit-Wert
  
  -- Funktionen und Closures
  | AstLambda [String] Ast                  -- Lambda/Funktion (Parameter, Körper)
  | AstClosure [String] Ast Env             -- Closure mit erfasster Umgebung
  | Call Ast [Ast]                          -- Funktionsaufruf
  | Return Ast                              -- Return-Anweisung
  
  -- Kontrollfluss
  | IfElse Ast Ast Ast                      -- if-then-else
  | While Ast Ast                           -- while-Schleife
  | For String Ast Ast                      -- for-Schleife (var, Bereich, Körper)
  | Break                                   -- Break-Anweisung
  | Continue                                -- Continue-Anweisung
  
  -- Sammlungen
  | AstList [Ast]                           -- Liste von Ausdrücken
  | Block [Ast]                             -- Anweisungsblock
  | ArrayAccess Ast Ast                     -- array[index]
  | ArrayAssign String Ast Ast              -- array[index] = value
  
  -- Strukturen
  | Struct String [(String, Type)]          -- Struktur-Definition
  | StructFieldAssign String String Ast     -- struct.field = value
  | TypedVar String Type Ast                -- Typisierte Variablendeklaration
  
  deriving (Show, Eq)
```

---

## Typsystem

### Typ-Definitionen

```haskell
data Type
  = TInt              -- 32-Bit signierter Integer
  | TFloat            -- Double-Präzision Float
  | TBool             -- Boolean (true/false)
  | TString           -- String (null-terminiert)
  | TChar             -- Einzelnes Zeichen
  | TVoid             -- Void/Unit-Typ
  | TCustom String    -- Benutzerdefinierte Typen (Arrays, Structs)
  deriving (Show, Eq)
```

### Typ-Inferenz-Regeln

Der Compiler leitet Typen basierend auf ab:

1. **Explizite Deklarationen**:
   ```
   eric x: int = 42         → x: TInt
   eric name: string = ""   → name: TString
   ```

2. **Literal-Typen**:
   ```
   42       → TInt
   3.14     → TFloat
   "hello"  → TString
   'c'      → TChar
   true     → TBool
   ```

3. **Ausdruckstypen**:
   ```
   x + y    → TInt (wenn beide x, y TInt sind)
   x + "!"  → TString (wenn einer TString ist)
   x < y    → TBool
   ```

---

## Parser-Integration

### Parser-Auswahl

Der Compiler unterstützt zwei Parser über Runtime-Flag:

```haskell
-- Parser.hs
setUseLisp :: Bool -> IO ()

-- Standard: TheShow Parser
parseSExprMultipleEither :: String -> Either String [SExpr]

-- Verwendung des Lisp-Parsers
setUseLisp True
parseSExprMultipleEither :: String -> Either String [SExpr]
```

### TheShow-Syntax (Standard)

TheShow bietet C-ähnliche Syntax:

```c
// Variablendeklaration
eric x: int = 42

// Funktionsdefinition
fun add(x: int, y: int) int {
  return x + y
}

// Kontrollstrukturen
if x < 10 {
  peric("Klein")
} else {
  peric("Groß")
}

// Schleifen
for i in range(0, 10) {
  peric(i)
}

while x > 0 {
  assign x (x - 1)
}
```

### Lisp-Syntax (Alternative)

Traditionelle S-Expression-Syntax:

```lisp
; Variablendeklaration
(eric x int 42)

; Funktionsdefinition
(fun add ((x int) (y int)) int
  ((return (+ x y))))

; Kontrollstrukturen
(if (< x 10)
  ((peric "Klein"))
  ((peric "Groß")))

; Schleifen
(aer i (range 0 10)
  ((peric i)))

(darius (> x 0)
  ((assign x (- x 1))))
```

---

## Code-Analyse und Optimierung

### Variablen-Typ-Sammlung

```haskell
collectVarTypes :: Ast -> Map.Map String Type -> Map.Map String Type
```

Durchläuft den AST, um eine vollständige Typ-Map zu erstellen:

**Prozess**:
1. Scannt alle `Define`-Knoten nach expliziten Typ-Annotationen
2. Leitet Typen aus Zuweisungen und Ausdrücken ab
3. Behandelt Spezialfälle (eingebaute Funktionen, Array-Typen)
4. Analysiert rekursiv Funktionskörper

### Funktionsnamen-Sammlung

```haskell
collectFunctionNames :: Ast -> [String]
```

Extrahiert alle Funktionsdefinitionen zur Aufruf-Validierung.

### Lokale Variablen-Mapping

```haskell
buildLocalMap :: Ast -> Map.Map String Type -> Map.Map String Int
```

Erstellt Stack-Offset-Map für lokale Variablen:

**Algorithmus**:
1. Sammelt alle lokalen Variablennamen
2. Berechnet erforderliche Größe für jede Variable:
   - Reguläre Variablen: 8 Bytes
   - Arrays: 4096 Bytes (Standard)
   - Spezialfälle (z.B. "memo"): benutzerdefinierte Größe
3. Weist Stack-Offsets von RBP zu

---

## Code-Generierungs-Backends

### Bytecode-Backend

Generiert Bytecode für die GLaDOS Virtual Machine.

#### Instruktions-Generierung

```haskell
astToInstructions :: Ast -> [Instruction]
```

**Kompilierungsregeln**:

| AST-Knoten | Bytecode |
|------------|----------|
| `AstInt n` | `PUSH n` |
| `AstBool True` | `PUSH_TRUE` |
| `AstBool False` | `PUSH_FALSE` |
| `AstString s` | `LOAD_CONST s` |
| `Call (AstSymbol "+") [a,b]` | `[a code] [b code] ADD` |
| `Call (AstSymbol "-") [a,b]` | `[a code] [b code] SUB` |
| `Return v` | `[v code] RET` |

### x86-64 Assembly-Backend

Generiert native x86-64-Assembly für Linux-Systeme.

#### Assembly-Generierungs-Pipeline

```haskell
emitASM :: Ast -> String
```

**Prozess**:
1. **Optimierung**: Inliniert globale Konstanten
2. **Analyse**: Sammelt Typen, Funktionen, Strings
3. **Data-Sektion**: Emittiert String-Konstanten
4. **Text-Sektion**: Emittiert Funktionen und main
5. **Built-ins**: Hängt eingebaute Funktionsimplementierungen an

#### Register-Verwendung

**Parameter-Übergabe** (System V AMD64 ABI):
- 1. Parameter: `%rdi`
- 2. Parameter: `%rsi`
- 3. Parameter: `%rdx`
- 4. Parameter: `%rcx`
- 5. Parameter: `%r8`
- 6. Parameter: `%r9`

**Rückgabewert**: `%rax`

---

## Speicherverwaltung

### Stack-Layout

Der Compiler verwendet Stack-basierte Speicherverwaltung für lokale Variablen:

```
Hohe Adresse
┌─────────────────┐
│ Rücksprung-     │
│ Adresse         │
├─────────────────┤  ← RBP (Frame-Zeiger)
│  Vorheriges RBP │
├─────────────────┤
│  Lokale Var 1   │  RBP - 8
├─────────────────┤
│  Lokale Var 2   │  RBP - 16
├─────────────────┤
│  Array-Puffer   │  RBP - 4112
│  (4096 Bytes)   │
├─────────────────┤  ← RSP (Stack-Zeiger)
│  ...            │
Niedrige Adresse
```

### Variablen-Speicherung

**Reguläre Variablen** (8 Bytes):
- Integer: 64-Bit signiert
- Zeiger: 64-Bit-Adressen
- Booleans: 64-Bit (0 oder 1)

**Arrays**:
- Standardgröße: 4096 Bytes (512 Quadwords)
- Inline im Stack-Frame gespeichert
- Zugriff über Basis-Zeiger + Offset

**Strings**:
- Heap-allokiert über `malloc`
- Zeiger im Stack gespeichert
- Verwaltet durch eingebaute Funktionen

---

## Eingebaute Funktionen

Der Compiler enthält mehrere eingebaute Funktionen, die in Assembly implementiert sind.

### renaud - Datei lesen

**Signatur**: `renaud(filename: string) -> string`

**Zweck**: Gesamten Dateiinhalt in einen String lesen

### romaric - Zeile lesen

**Signatur**: `romaric(prompt: string) -> string`

**Zweck**: Prompt anzeigen und Zeile von stdin lesen

### marvin - Datei schreiben

**Signatur**: `marvin(filename: string, content: string) -> void`

**Zweck**: String-Inhalt in Datei schreiben

### str_concat - String-Konkatenation

**Signatur**: `str_concat(s1: string, s2: string) -> string`

**Zweck**: Zwei Strings in neu allokierten Puffer konkatenieren

### peric - Drucken (implizit)

Die Funktion `peric` verwendet `printf` mit Format-String-Interpolation.

---

## Fehlerbehandlung

### Compile-Zeit-Fehler

Der Compiler erkennt und meldet verschiedene Fehler:

#### Undefinierte Variable
```c
assign x 42  // Fehler: Undefinierte Variable 'x'
```

#### Undefinierte Funktion
```c
foo(10)  // Fehler: Undefinierte Funktion 'foo'
```

#### Typ-Inkompatibilität

Typ-Fehler werden während der Code-Generierung erkannt:

```c
eric x: int = 42
assign x "string"  // Fehler: Typ-Inkompatibilität (int vs string)
```

### Parser-Fehler

Syntax-Fehler vom Parser:

```
Eingabe: fun add(x: int { return x }
Fehler: Parse-Fehler: Unpassende Klammern
```

---

## Verwendungsbeispiele

### Kompilierung zu Bytecode

**Befehl**:
```bash
glados -c program.tslang -o program.o
```

**Ausführung**:
```bash
glados program.o
```

### Kompilierung zu nativer Assembly

**Befehl**:
```bash
glados program.tslang -o program.o --native
```

**Linken und Ausführen**:
```bash
gcc program.o -o program
./program
```

### Beispielprogramm

**Quelle** (`factorial.tslang`):
```c
fun factorial(n: int) int {
  if n <= 1 {
    return 1
  }
  return n * factorial(n - 1)
}

fun Eric() void {
  eric result: int = factorial(5)
  peric("Fakultät von 5 ist: ", result)
}
```

**Kompilieren zu Bytecode**:
```bash
glados -c factorial.tslang -o factorial.o
glados factorial.o
```

**Ausgabe**:
```
Fakultät von 5 ist: 120
```

---

## Leistungsüberlegungen

### Optimierungsstrategien

1. **Konstantenfaltung**: Wertet konstante Ausdrücke zur Compile-Zeit aus
2. **Dead-Code-Eliminierung**: Entfernt unerreichbaren Code
3. **Globales Konstanten-Inlining**: Ersetzt konstante Variablen durch Literale
4. **Register-Allokation**: Minimiert Speicherzugriffe in Assembly
5. **Tail-Call-Optimierung** (geplant): Optimiert rekursive Aufrufe

### Bytecode vs Native

**Bytecode-Vorteile**:
- Schnelle Kompilierung
- Plattformübergreifend portabel
- Einfaches Debugging
- Kleine Dateigröße

**Native Assembly-Vorteile**:
- 10-100x schnellere Ausführung
- Direkter Hardware-Zugriff
- Kein Interpreter-Overhead
- Volles Optimierungspotenzial

### Kompilierungszeit

Typische Kompilierungszeiten (auf moderner Hardware):

| Codezeilen | Bytecode | Native Assembly |
|------------|----------|-----------------|
| 100        | <10ms    | ~50ms           |
| 1000       | ~50ms    | ~200ms          |
| 10000      | ~500ms   | ~2s             |

### Laufzeit-Leistung

**Bytecode**:
- Einfache Arithmetik: ~1 μs pro Operation
- Funktionsaufruf: ~1 μs pro Aufruf
- Array-Zugriff: ~0.5 μs

**Native Assembly**:
- Einfache Arithmetik: ~1 ns pro Operation
- Funktionsaufruf: ~10 ns pro Aufruf
- Array-Zugriff: ~5 ns

---

## Zukünftige Erweiterungen

1. **Typ-Checking**: Vollständiges statisches Typ-Checking vor Code-Generierung
2. **LLVM-Backend**: LLVM IR für maximale Optimierung generieren
3. **Modulsystem**: Unterstützung für mehrere Dateien und Imports
4. **Generics**: Generische Funktionen und Datenstrukturen
5. **Pattern Matching**: Erweiterte Kontrollfluss-Konstrukte
6. **Garbage Collection**: Automatische Speicherverwaltung für Heap-Allokationen
7. **Inkrementelle Kompilierung**: Nur geänderte Funktionen neu kompilieren
8. **Debug-Symbole**: DWARF-Debug-Informationen für nativen Code
9. **Warnungen**: Lint-Style-Warnungen für verdächtigen Code
10. **Optimierungsstufen**: -O0, -O1, -O2, -O3 Flags

---

## Referenzen

- [Bytecode-Modul](../../src/Bytecode.hs) - Instruktionsdefinitionen
- [VM-Modul](../../src/VM.hs) - Bytecode-Ausführungsmaschine
- [AST-Modul](../../src/AST.hs) - Abstrakte Syntaxbaum-Definitionen
- [Parser-Modul](../../src/Parser.hs) - Parser-Auswahl und Integration
- [VM Technische Dokumentation](TECHNICAL_VM.md) - Virtual Machine Details
- [Benutzerhandbuch](user_guide.md) - Endbenutzer-Dokumentation
- [Sprachreferenz](tsl_language_reference.md) - TSL-Sprachspezifikation

# Virtuelle Maschine - Technische Dokumentation

## Inhaltsverzeichnis

- [Überblick](#überblick)
- [VM-Architektur](#vm-architektur)
- [Bytecode-Format](#bytecode-format)
- [Befehlssatz](#befehlssatz)
- [Ausführungsmodell](#ausführungsmodell)
- [Speicherverwaltung](#speicherverwaltung)
- [Aufrufliste und Funktionen](#aufrufliste-und-funktionen)
- [Implementierungsdetails](#implementierungsdetails)
- [Leistungsaspekte](#leistungsaspekte)

---

## Überblick

Die GLaDOS Virtual Machine (VM) ist ein stapelbasierter Interpreter, der für die Ausführung von kompiliertem Bytecode aus der Programmiersprache TheShowLang (TSL) entwickelt wurde. Sie bietet eine effiziente Ausführungsumgebung mit Unterstützung für:

- **Grundlegende arithmetische und Vergleichsoperationen**
- **Kontrollfluss mit bedingten und unbedingten Sprüngen**
- **Funktionsaufrufe mit Closures und erfasster Umgebung**
- **Verwaltung lokaler und globaler Variablen**
- **Zeichenketten- und Konstantenbehandlung**
- **Ausgabeoperationen (PRINT)**

Die VM ist in Haskell implementiert und ist eng in den Bytecode-Compiler-Backend integriert.

### Wichtige Designprinzipien

1. **Stapelbasierte Architektur**: Alle Operationen verwenden einen Stapel für die Operandenübergabe
2. **Einfacher Befehlssatz**: Minimaler, orthogonaler Satz von Befehlen
3. **Closure-Unterstützung**: Funktionen erster Klasse mit lexikalischem Geltungsbereich
4. **Typsicherheit**: Das Haskell-Typsystem gewährleistet Speichersicherheit

---

## VM-Architektur

### Kernkomponenten

#### 1. VMValue-Typ

Repräsentiert Laufzeitwerte in der VM:

```haskell
data VMValue
  = VMInt Int32              -- 32-Bit-Ganzzahlen mit Vorzeichen
  | VMBool Bool              -- Wahrheitswerte (#t, #f)
  | VMString String          -- Zeichenketten-Literale
  | VMClosure Int32 Int32 [VMValue]  -- Closures mit erfasster Umgebung
  | VMVoid                   -- Unit/Void-Wert
  deriving (Show, Eq)
```

#### 2. CallFrame-Struktur

Verwaltet den Kontext von Funktionsaufrufen:

```haskell
data CallFrame = CallFrame
  { returnAddress :: Int
  , savedLocals   :: [VMValue]
  } deriving (Show)
```

Jeder Aufrufrahmen speichert:
- **returnAddress**: Programmzähler zum Fortsetzen nach Funktionsrückkehr
- **savedLocals**: Zustand lokaler Variablen vor dem Aufruf

#### 3. VMState-Typ

Vollständiger Ausführungszustand:

```haskell
data VMState = VMState
  { stack     :: [VMValue]              -- Operandenstapel
  , pc        :: Int                    -- Programmzähler
  , callStack :: [CallFrame]            -- Aufrufliste für Funktionsrückkehrwerte
  , globals   :: Map.Map String VMValue -- Globale Variablen
  , locals    :: [VMValue]              -- Lokale Variablen (aktueller Rahmen)
  , program   :: [Instruction]          -- Bytecode-Befehle
  , halted    :: Bool                   -- Ausführungsstoppflag
  , outputs   :: [String]               -- Gesammelte Ausgabe
  } deriving (Show)
```

---

## Bytecode-Format

### Struktur des Binärformats

Bytecode-Dateien (Erweiterung `.o`) verwenden die folgende Struktur:

```
┌─────────────────────────────────────────┐
│ Magische Zahl: "GLO\0" (4 Bytes)        │
├─────────────────────────────────────────┤
│ Version: 0x01 (1 Byte)                  │
├─────────────────────────────────────────┤
│ Befehle (variable Länge)                │
│   [Opcode] [Operanden] [Opcode] ...     │
├─────────────────────────────────────────┤
│ HALT-Befehl (0xFF) am Ende              │
└─────────────────────────────────────────┘
```

### Befehlskodierung

Jeder Befehl beginnt mit einem Ein-Byte-Opcode, gefolgt von null oder mehreren Operanden:

- **Befehle ohne Operanden**: 1 Byte (z.B. ADD, POP)
- **Int32-Operanden**: 4 Bytes im Little-Endian-Format (z.B. PUSH, JUMP)
- **Zeichenketten-Operanden**: 4-Byte-Längenpräfix + Zeichenkettendata (z.B. LOAD_GLOBAL)

### ELF-Datei-Laden

Für ELF-Dateien extrahiert die VM die `.text`-Sektion:

1. Überprüft die ELF-Magische Zahl (0x7F 0x45 0x4C 0x46)
2. Sucht Sektionsköpfe
3. Extrahiert `.text`-Sektion mit Bytecode
4. Dekodiert Befehle aus der extrahierten Sektion

---

## Befehlssatz

### Vollständige Befehlsreferenz

| Opcode | Befehl            | Operanden | Stack-Effekt | Beschreibung |
|--------|-------------------|-----------|------------|-------------|
| 0x01   | PUSH              | Int32     | → [n]        | Ganzzahl-Konstante auf Stapel |
| 0x02   | POP               | keine     | [v] →        | Oberste Stapelelement entfernen |
| 0x03   | ADD               | keine     | [b,a] → [a+b]| Zwei Ganzzahlen addieren |
| 0x04   | SUB               | keine     | [b,a] → [a-b]| Ganzzahlen subtrahieren |
| 0x05   | MUL               | keine     | [b,a] → [a*b]| Ganzzahlen multiplizieren |
| 0x06   | DIV               | keine     | [b,a] → [a/b]| Ganzzahl-Division (b≠0) |
| 0x07   | MOD               | keine     | [b,a] → [a%b]| Modulo-Operation (b≠0) |
| 0x08   | LT                | keine     | [b,a] → [a<b]| Kleiner-als-Vergleich |
| 0x09   | EQ                | keine     | [b,a] → [a==b]| Gleichheits-Vergleich |
| 0x0A   | JUMP              | Int32     | (pc)         | Unbedingter Sprung zu Adresse |
| 0x0B   | JUMP_IF_FALSE     | Int32     | [v] →        | Sprung wenn Oberste = #f |
| 0x0C   | CALL              | Int32     | (Stapel)     | Funktion bei Adresse aufrufen |
| 0x0D   | RET               | keine     | [v] → v      | Aus Funktion zurückgeben |
| 0x0E   | LOAD_VAR          | Int32     | → [v]        | Lokale Variable laden |
| 0x0F   | STORE_VAR         | Int32     | [v] →        | In lokale Variable speichern |
| 0x10   | LOAD_GLOBAL       | String    | → [v]        | Globale Variable laden |
| 0x11   | STORE_GLOBAL      | String    | [v] →        | In globale Variable speichern |
| 0x12   | MAKE_CLOSURE      | Int32 Int32 | → [closure] | Closure mit erfasster Umgebung |
| 0x13   | PUSH_TRUE         | keine     | → [#t]       | Wahrheitswert wahr auf Stapel |
| 0x14   | PUSH_FALSE        | keine     | → [#f]       | Wahrheitswert falsch auf Stapel |
| 0x15   | PRINT             | keine     | [v] →        | Wert drucken und ausgeben |
| 0x16   | LOAD_CONST        | String    | → [s]        | Zeichenketten-Konstante laden |
| 0xFF   | HALT              | keine     | (stoppt)     | Ausführung beenden |

### Typeinschränkungen

Die VM erzwingt Typkorrektheit für Operationen:

- **Arithmetische Operationen (ADD, SUB, MUL, DIV, MOD)**: Beide Operanden müssen `VMInt` sein
- **Vergleiche (LT, EQ)**: Operanden müssen kompatible Typen sein
- **Bedingte Sprünge (JUMP_IF_FALSE)**: Operand muss `VMBool` sein
- **Typfehler** ergeben `Left String` mit Beschreibung

---

## Ausführungsmodell

### Stapelbasierte Operation

Die VM arbeitet mit einem LIFO-Stapel (Last In, First Out). Die meisten Operationen nehmen Operanden vom oberen Ende ab und drücken Ergebnisse zurück auf:

```
Beispiel: Berechnung (2 + 3) * 4

Initial:        []
PUSH 2:         [2]
PUSH 3:         [2, 3]
ADD:            [5]
PUSH 4:         [5, 4]
MUL:            [20]
```

### Programmzähler und Sequenzierung

Befehle werden nacheinander ausgeführt, es sei denn, ein Kontrollfluss-Befehl wird angetroffen:

- **Normaler Fluss**: PC inkrementiert um Befehlsgröße
- **JUMP addr**: PC direkt auf `addr` gesetzt
- **JUMP_IF_FALSE addr**: Bedingte Verzweigung basierend auf oberem Stapelelement
- **CALL addr**: Sprung mit gepushtem Aufruflisten-Rahmen
- **RET**: Aufruflisten-Rahmen poppen und zu Rücksprungadresse springen

### Ausführungsschleife

```haskell
execBytecode :: VMState -> (Either String VMValue, [String])
execBytecode state
  | halted state = getResult state
  | pc außerhalb = error "PC außerhalb Bereich"
  | otherwise = case step state (program !! pc) of
      Left err      → return error
      Right newState → execBytecode newState
```

Die Ausführung setzt sich fort bis:
1. `HALT`-Befehl ausgeführt wird
2. Ein Fehler auftritt
3. Programmzähler außerhalb Bereich geht

### Step-Funktion

Die `step`-Funktion implementiert jeden Befehl:

```haskell
step :: VMState → Instruction → Either String VMState
```

Rückgabe:
- **Left msg**: Fehlerzustand
- **Right state**: Aktualisierter VM-Zustand bereit für nächsten Befehl

---

## Speicherverwaltung

### Stapel

Der Operandenstapel speichert `VMValue`-Elemente:
- Wächst/schrumpft dynamisch während Werte gepusht/gepoppt werden
- Stack-Unterlauf bei POP/arithmetischen Operationen liefert Fehler
- Keine feste Größenbegrenzung

### Lokale Variablen

Lokale Variablen werden in einer nach Variablen-ID indizierten Liste gespeichert:

```haskell
LOAD_VAR 0    -- Erste lokale Variable laden
STORE_VAR 1   -- In zweite lokale Variable speichern
```

Zugriff wird mit Grenzenprüfung durchgeführt; ungültige Indizes produzierten Fehler.

### Globale Variablen

Globale Variablen verwenden `Map.Map String VMValue` für namensbasierte Suche:

```haskell
LOAD_GLOBAL "x"    -- Globale Variable "x" laden
STORE_GLOBAL "y"   -- In globale Variable "y" speichern
```

Undefinierte globale Lesevorgänge produzierten "Undefined global variable" Fehler.

### Konstanten-Pool

Zeichenketten-Konstanten verwenden `LOAD_CONST`-Befehl:

```haskell
LOAD_CONST "Hallo, Welt!"
PRINT
```

### Speicher-Layout-Beispiel

```
Rahmen 1 (äußere Funktion)
├─ locals = [100, "hallo"]
├─ callStack = []
└─ stack = [42]

Rahmen 2 (nach Funktionsaufruf)
├─ locals = [10, 20, 30]      (neue Rahmen-Locals)
├─ callStack = [CallFrame {returnAddress: 50, savedLocals: [100, "hallo"]}]
└─ stack = [42, ...]
```

---

## Aufrufliste und Funktionen

### Funktionsaufrufmechanismus

#### CALL-Befehl

```haskell
CALL addr  -- Funktion bei Adresse addr aufrufen
```

Ausführung:
1. Erstelle `CallFrame` mit aktuellem PC+1 (Rücksprungadresse) und aktuellen Locals
2. Pushes Rahmen auf `callStack`
3. Setze PC auf `addr`
4. Fortsetzen der Ausführung

#### RET-Befehl

```haskell
RET  -- Aus Funktion zurückgeben
```

Ausführung:
1. Ober-Aufruflisten-Rahmen poppen
2. Rücksprungadresse aus Rahmen wiederherstellen
3. Locals aus Rahmen wiederherstellen
4. PC auf Rücksprungadresse setzen
5. Rückgabewert auf Stapel behalten

### Closure-Unterstützung

#### MAKE_CLOSURE-Befehl

Erstellt Closure mit erfasster Umgebung:

```haskell
MAKE_CLOSURE addr nparams
```

Erstellt `VMClosure addr nparams capturedEnv` wobei:
- **addr**: Bytecode-Adresse des Funktionscodes
- **nparams**: Anzahl der Parameter
- **capturedEnv**: Aktuelle lokale Variablen (lexikalischer Geltungsbereich)

#### Closure-Aufruf

Beim Aufrufen einer Closure:
1. Argumente werden vom Stapel genommen
2. Neue lokale Variablen = Argumente + erfasste Umgebung
3. Funktion wird mit kombinierten Locals ausgeführt
4. Rückkehr poppt Rahmen und stellt Aufrufers Locals wieder her

### Beispiel: Closure mit erfassten Variablen

```
PUSH 100           -- äußerer Wert
STORE_VAR 0        -- locals = [100]
PUSH 5             -- nparams
PUSH 10            -- Funktionsadresse
MAKE_CLOSURE       -- erfasse locals = [100]
                   -- stack = [VMClosure(10, 5, [VMInt 100])]

CALL addr          -- Closure aufrufen
                   -- neue locals = [args...] + [100]
                   -- kann erfassten 100 zugreifen
```

---

## Implementierungsdetails

### Fehlerbehandlung

Die VM verwendet `Either String` für Fehlerausbreitung:

```haskell
step :: VMState → Instruction → Either String VMState
```

Häufige Fehlerfälle:
- **Stack-Unterlauf**: Nicht genug Operanden
- **Typfehler**: Falsche Operandentypen für Operation
- **Division durch Null**: DIV/MOD mit Null-Divisor
- **Außerhalb Bereich**: Sprung/Variablenzugriff außerhalb Grenzen
- **Undefinierte Variable**: Globale Variable existiert nicht

### Ausgabeverarbeitung

Der PRINT-Befehl akkumuliert Ausgabe:

```haskell
outputs :: [String]  -- gesammelte Ausgabezeichenketten
```

Ausgabe wird während Ausführung beibehalten und als zweites Element des Result-Tupels zurückgegeben:

```haskell
runVM :: [Instruction] → (Either String VMValue, [String])
```

### Befehlsdekodierung

Dekodierung binären Bytecodes:

```haskell
decodeProgram :: ByteString → Either String [Instruction]
decodeProgram bs = go bs []
  where
    go b acc
      | null b = Right (reverse acc)
      | otherwise = case decodeOpcode (erstes Byte) of
          Just decoder → decoder Rest
          Nothing → Left "Unbekannter Opcode"
```

Jeder Befehlsdekoder:
- Nimmt verbleibenden `ByteString`
- Analysiert Opcode-spezifische Operanden
- Rückgabe `(Instruction, verbleibende Bytes)` oder Fehler

### Zeichenketten-Kodierung

Zeichenketten verwenden längenpräfixiertes Format:

```
[Länge: 4 Bytes LE] [UTF-8 Zeichenkettendata]

Beispiel: "Hi" → 02 00 00 00 48 69
         ^Länge  ^"H"  ^"i"
```

### Int32-Kodierung

Alle Ganzzahl-Operanden verwenden 32-Bit Little-Endian:

```
1234 → 0xD2 0x04 0x00 0x00  (im Speicher/Datei)
```

---

## Leistungsaspekte

### Optimierungsmöglichkeiten

1. **Befehlscache**: Befehle vorab analysieren um wiederholte Dekodierung zu vermeiden
2. **Bytecode-Optimierung**:
   - Konstanten-Faltung
   - Tote Code-Beseitigung
   - Sprungziel-Inlining
3. **Stapelmaschinen-Optimierungen**:
   - Registerzuteilung für häufig verwendete Werte
   - Stapelrahmen-Pooling
4. **JIT-Kompilierung**: Compile Hot-Code-Pfade zu nativem Code

### Aktuelle Einschränkungen

- **Kein Tail-Call-Optimization**: Rekursive Funktionen können Aufrufliste überlaufen
- **Lineare Suche nach Befehlen**: Kein Befehlscache
- **Zeichenketten-Kopieren**: Alle Zeichenketten-Operationen beinhalten Speicherkopien
- **Kein Garbage Collection**: Closures behalten erfasste Umgebung

### Benchmarking

Typische Leistungsmetriken:
- Einfache Arithmetik: ~10-100 μs
- Funktionsaufruf-Overhead: ~1 μs pro Rahmen
- PRINT-Operation: ~10 μs pro Aufruf

---

## Integration mit Compiler

### Bytecode-Generierungsfluss

```
TSL-Quelle
    ↓
Parser (Theshow/Lisp-Syntax)
    ↓
AST (Abstrakte Syntax-Baum)
    ↓
Compiler (AST → Befehle)
    ↓
Bytecode.hs (in Binär serialisieren)
    ↓
.o-Datei (Bytecode)
    ↓
VM.hs (execBytecode)
    ↓
Ergebnis + Ausgabe
```

### Kompilierung zu Bytecode

Der Compiler übersetzt AST-Knoten zu Befehlen:

```haskell
-- Beispiel: (+ 2 3) kompiliert zu:
PUSH 2
PUSH 3
ADD
```

---

## Debugging und Troubleshooting

### Laufzeit-Fehlermeldungen

Die VM bietet detaillierte Fehlermeldungen:

```
"Stack-Unterlauf bei POP"
"Typfehler in ADD"
"Division durch Null"
"Sprungadresse außerhalb Bereich"
"Undefinierte globale Variable: x"
```

### Bytecode-Disassembly

Das Loader-Modul bietet Disassembly:

```bash
glados -d programm.o
```

Erzeugt von Menschen lesbar Bytecode-Format.

### Tests

Einheit-Tests für VM-Operationen in `test/Spec.hs`:
- Arithmetische Operationen
- Kontrollfluss
- Funktionsaufrufe
- Variablenverwaltung
- Closure-Behandlung

---

## Zukünftige Erweiterungen

1. **Typ-Anmerkungen in Bytecode**: Bessere Fehlermeldungen
2. **Garbage Collection**: Für Closure-Umgebungen
3. **Modulsystem**: Mehrere Bytecode-Dateien
4. **Debugger**: Schritt-Ausführung, Haltepunkte
5. **Speicher-Profiling**: Verfolgung von Allokationsmustern

---

## Referenzen

- [Bytecode-Modul](../src/Bytecode.hs)
- [VM-Modul](../src/VM.hs)
- [Loader-Modul](../src/Loader.hs)
- [Hauptanwendung](../app/Main.hs)

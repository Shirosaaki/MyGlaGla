# VM und .o-Dateien - Benutzerhandbuch

## Übersicht

Ihr GLaDOS-Projekt kann jetzt Bytecode-Dateien `.o` dank einer integrierten virtuellen Maschine kompilieren und ausführen.

## Architektur

### Erstellte Module

1. **Bytecode.hs** - Definiert den Befehlssatz der VM
2. **VM.hs** - Virtuelle Maschine zur Ausführung des Bytecodes
3. **Loader.hs** - Laden und Speichern von .o-Dateien
4. **Main.hs** (modifiziert) - Unterstützung für die Ausführung von .o-Dateien

### Format der .o-Dateien

Die `.o`-Dateien sind binäre Dateien mit folgendem Format:

- **Magic number**: `GLO\0` (4 Bytes)
- **Version**: `0x01` (1 Byte)
- **Befehle**: Sequenz von Opcodes und deren Argumenten

## Befehlssatz

Die VM unterstützt die folgenden Befehle:

| Opcode | Befehl        | Beschreibung                         |
| ------ | ------------- | ----------------------------------- |
| 0x01   | PUSH n        | Legt einen ganzzahligen Wert ab     |
| 0x02   | POP           | Nimmt einen Wert heraus              |
| 0x03   | ADD           | Addition der beiden Werte an der Spitze |
| 0x04   | SUB           | Subtraktion                         |
| 0x05   | MUL           | Multiplikation                      |
| 0x06   | DIV           | Division                            |
| 0x07   | MOD           | Modulo                              |
| 0x08   | LT            | Vergleich <                         |
| 0x09   | EQ            | Vergleich ==                        |
| 0x0A   | JUMP          | Unbedingter Sprung                 |
| 0x0B   | JUMP_IF_FALSE | Bedingter Sprung                   |
| 0x0C   | CALL          | Funktionsaufruf                    |
| 0x0D   | RET           | Funktionsrückgabe                  |
| 0x0E   | LOAD_VAR      | Lokale Variable laden               |
| 0x0F   | STORE_VAR     | Lokale Variable speichern           |
| 0x10   | LOAD_GLOBAL   | Globale Variable laden              |
| 0x11   | STORE_GLOBAL  | Globale Variable speichern          |
| 0x12   | MAKE_CLOSURE  | Eine Closure erstellen              |
| 0x13   | PUSH_TRUE     | Wahr ablegen                       |
| 0x14   | PUSH_FALSE    | Falsch ablegen                     |
| 0xFF   | HALT          | Ausführung stoppen                  |

## Verwendung

### Ausführen einer .o-Datei

```bash
stack exec glados-exe fichier.o
```
```markdown
oder mit der kompilierten Binärdatei:
``````bash
./glados-exe fichier.o
```

### Eine .o-Datei disassemblieren

Um den Inhalt einer .o-Datei in einem lesbaren Format anzuzeigen:

```bash
stack exec glados-exe -- -d fichier.o
```

### Modus Interpreter (Original)

Ohne Argument liest glados von stdin (Originalmodus):

```bash
echo "(+ 2 3)" | stack exec glados-exe
```

## Beispiele für .o-Dateien

Es werden Testdateien bereitgestellt:

- **test_add.o**: Einfache Addition (2 + 3) → 5
- **test_mul.o**: Multiplikation (4 \* 5) → 20
- **test_lt.o**: Vergleich (3 < 5) → #t
- **test_complex.o**: Komplexer Ausdruck ((2 + 3) \* 4) → 20

### Ausführung der Tests

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

## Erstellen Sie Ihre eigenen .o-Dateien

Verwenden Sie den Testgenerator, um neue .o-Dateien zu erstellen:

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

It seems that you haven't provided the Markdown chunk that needs to be translated. Please share the text you'd like me to translate into German, and I'll be happy to assist you!

```bash
stack runghc tools/generate_test_bytecode.hs
stack exec glados-exe my_program.o
```

## Technische Details

### Struktur der VM

Die VM verwendet eine stackbasierte Architektur mit:

- **Stack**: Ausführungsstapel für Werte
- **PC** (Program Counter): Befehlszeiger
- **Call Stack**: Aufrufstapel für Funktionen
- **Globals**: Globale Variablen
- **Locals**: Lokale Variablen des aktuellen Frames

### Werttypen

Die VM unterstützt:

- `VMInt`: 32-Bit-Ganzzahlen
- `VMBool`: Boolesche Werte
- `VMClosure`: Closures (Funktionen + Umgebung)
- `VMVoid`: Leerer Wert

### Fehlerbehandlung

Die VM erkennt und meldet:

- Division durch Null
- Stack-Underflow
- Sprünge außerhalb der Grenzen
- Typfehler
- Nicht definierte Variablen

## Nächste Schritte

Um den VM-Teil des Projekts abzuschließen, müssen Sie:

1. **Einen Compiler erstellen** (AST → Bytecode) in einem Modul `Compiler.hs`
2. **Unterstützung für Closures** und erfasste Variablen hinzufügen
3. **Eine Standardbibliothek** in Bytecode implementieren
4. **Den generierten Bytecode optimieren**
5. **Den Kompilierungsprozess dokumentieren** (erforderlich für die Verteidigung)

## Zusätzliche Tests

Sie können mit Ihrem eigenen glados, kompiliert in .o, testen, indem Sie eine Bytecode-Datei erstellen, die das erwartete Verhalten Ihrer Sprache reproduziert.

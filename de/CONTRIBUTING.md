# Beitrag zu GLADOS

Vielen Dank für Ihr Interesse, zu GLADOS beizutragen! Dieses Dokument bietet Richtlinien und Anweisungen für die Mitwirkung an dem Projekt.

## Inhaltsverzeichnis

- [Verhaltenskodex](#verhaltenskodex)
- [Erste Schritte](#erste-schritte)
- [Entwicklungsworkflow](#entwicklungsworkflow)
- [Kodierungsstandards](#kodierungsstandards)
- [Commit-Richtlinien](#commit-richtlinien)
- [Pull-Request-Prozess](#pull-request-prozess)
- [Fehlerberichterstattung](#fehlerberichterstattung)

---

## Verhaltenskodex

### Unsere Standards

- **Sei respektvoll**: Behandle alle mit Respekt und Freundlichkeit
- **Sei konstruktiv**: Gib hilfreiches Feedback und Vorschläge
- **Sei kooperativ**: Arbeite gemeinsam daran, das Projekt zu verbessern
- **Sei inklusiv**: Begrüße Mitwirkende aller Fähigkeitsstufen

### Unacceptable Behavior

- Belästigung, Diskriminierung oder beleidigende Kommentare
- Trolling, beleidigende oder abfällige Bemerkungen
- Veröffentlichung privater Informationen anderer
- Jegliches Verhalten, das in einem professionellen Umfeld unangemessen wäre

---

## Erste Schritte

### Voraussetzungen

1. **Installiere die erforderlichen Werkzeuge**:
   - Git
   - GHC (Glasgow Haskell Compiler) >= 8.10
   - Stack (Haskell-Bauwerkzeug)
   - Make

2. **Forke das Repository** auf GitHub

3. **Klonen Sie Ihren Fork**:   ```bash
   git clone git@github.com:YOUR_USERNAME/GlaGla.git
   cd GlaGla
   ```

4. **Fügen Sie ein Upstream-Remote hinzu**:
   ```bash
   git remote add upstream git@github.com:LaTableSurGit/GlaGla.git
   ```

5. **Abhängigkeiten installieren**:
   ```bash
   stack setup
   stack build
   ```

### Machen Sie sich vertraut

- Lesen Sie die [Technische Dokumentation](TECHNICAL.md)
- Durchstöbern Sie das [Benutzerhandbuch](user_guide.md)
- Überprüfen Sie die [bestehenden Probleme](https://github.com/LaTableSurGit/GlaGla/issues)
- Führen Sie die Beispielprogramme in `examples/` aus

---

## Entwicklungsworkflow

### 1. Erstellen Sie einen Branch

Erstellen Sie immer einen neuen Branch für Ihre Arbeit:

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

Branch-Namenskonventionen:
- `feature/` - Neue Funktionen
- `fix/` - Fehlerbehebungen
- `docs/` - Dokumentationsaktualisierungen
- `refactor/` - Code-Refactoring
- `test/` - Testergänzungen/-verbesserungen

### 2. Nehmen Sie Ihre Änderungen vor

- Schreiben Sie sauberen, lesbaren Code
- Befolgen Sie die [Kodierungsstandards](#coding-standards)
- Fügen Sie Kommentare für komplexe Logik hinzu
- Aktualisieren Sie die Dokumentation nach Bedarf

### 3. Testen Sie Ihre Änderungen

```bash
# Run tests
make run_test

# Run style checker
./tools/tsl_style_checker.sh

# Test manually
./glados < examples/example1.tslang
```

### 4. Übernehmen Sie Ihre Änderungen

Befolgen Sie die [Commit-Richtlinien](#commit-guidelines):

```bash
git add .
git commit -m "feat: add new feature description"
```

### 5. Halte Deinen Branch Aktuell

```bash
# Fetch upstream changes
git fetch upstream

# Rebase on upstream main
git rebase upstream/main

# Or merge if you prefer
git merge upstream/main
```

### 6. Push und PR erstellen

```bash
git push origin feature/your-feature-name
```

Dann erstelle einen Pull Request auf GitHub.

---

## Codierungsstandards

### Haskell Code-Stil

#### Namenskonventionen

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

#### Formatierung

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

#### Dokumentation

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

#### Beste Praktiken

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

### Modulstruktur

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

## Commit-Richtlinien

### Format der Commit-Nachricht

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Typ

- `feat`: Neue Funktion
- `fix`: Fehlerbehebung
- `docs`: Nur Dokumentation
- `style`: Formatierung, fehlende Semikolons usw.
- `refactor`: Code-Umstrukturierung
- `test`: Hinzufügen oder Aktualisieren von Tests
- `chore`: Wartungsaufgaben

### Beispiele

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

### Commit Best Practices

- **Halte Commits atomar**: Eine logische Änderung pro Commit
- **Schreibe klare Nachrichten**: Erkläre was und warum, nicht wie
- **Referenziere Issues**: Füge `#issue-number` in die Commit-Nachricht ein
- **Teste vor dem Commit**: Stelle sicher, dass der Code kompiliert und die Tests bestanden werden

---

## Pull Request Prozess

### Vor dem Einreichen

- [ ] Code kompiliert fehlerfrei
- [ ] Alle Tests bestehen (`make run_test`)
- [ ] Stilprüfer besteht (`./tools/tsl_style_checker.sh`)
- [ ] Dokumentation aktualisiert (falls zutreffend)
- [ ] Beispiele aktualisiert (falls neue Funktionen hinzugefügt werden)
- [ ] Commit-Nachrichten folgen den Richtlinien

### PR Vorlage

Beim Erstellen eines PR, füge hinzu:

```markdown
## Description
Brief description of changes

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

### Überprüfungsprozess

1. **Automatisierte Überprüfungen**: CI/CD führt Tests und Stilprüfungen durch
2. **Code-Überprüfung**: Maintainer überprüfen deinen Code
3. **Feedback**: Behebe alle angeforderten Änderungen
4. **Genehmigung**: Nach der Genehmigung wird dein PR zusammengeführt

### Feedback ansprechen

- Sei reaktionsschnell auf Kommentare
- Nimm angeforderte Änderungen in neuen Commits vor
- Fordere nach Änderungen erneut eine Überprüfung an
- Sei offen für Vorschläge und Diskussionen

---

## Fehlerberichterstattung

### Vor dem Erstellen eines Issues

1. **Suche nach bestehenden Issues**: Dein Issue könnte bereits existieren
2. **Überprüfe die Dokumentation**: Die Antwort könnte in den Unterlagen zu finden sein
3. **Reproduziere den Fehler**: Stelle sicher, dass er konsistent ist

### Fehlerbericht-Vorlage

```markdown
## Bug Description
Clear and concise description of the bug

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

### Feature-Anforderungs-Template

```markdown
## Feature Description
Clear description of the feature

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

## Bereiche, die Unterstützung benötigen

### Hohe Priorität

- **LLVM Backend**: Vervollständigung des Compiler-Backends
- **Typensystem**: Verbesserung der Typinferenz
- **Fehlermeldungen**: Bessere Fehlerberichterstattung
- **Standardbibliothek**: Hinzufügen von eingebauten Funktionen
- **Dokumentation**: API-Dokumente mit Haddock

### Gute erste Aufgaben

Suchen Sie nach Aufgaben, die mit `good-first-issue` gekennzeichnet sind:
- Verbesserungen der Dokumentation
- Beispielprogramme
- Testabdeckung
- Code-Kommentare
- Stilkorrekturen

### Fortgeschrittene Beiträge

Für erfahrene Mitwirkende:
- VM-Optimierung
- Speicherbereinigung
- JIT-Kompilierung
- Sprachserverprotokoll (LSP)
- Implementierung eines Debuggers

---

## Fragen?

- **GitHub Issues**: Für Fehler und Funktionen
- **GitHub Discussions**: Für Fragen und Ideen
- **Pull Requests**: Für Codebeiträge

## Anerkennung

Mitwirkende werden anerkannt in:
- CHANGELOG.md
- Projekt-README
- Versionshinweisen

Vielen Dank für Ihren Beitrag zu GLADOS! 🚀

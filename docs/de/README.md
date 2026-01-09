# GLADOS

## Beschreibung

Ein Compiler für seine eigene Programmiersprache. Wir werden sie TheShowLang (TSL) nennen. TSL ist eine einfache Sprache, die Variablenzuweisungen, arithmetische Operationen und grundlegende Kontrollstrukturen unterstützt.

Der gesamte Code ist in Haskell geschrieben.

## Installation

Um das Projekt zu installieren, stellen Sie sicher, dass Sie [Stack](https://docs.haskellstack.org/en/stable/README/) installiert haben. Klonen Sie dann das Repository und navigieren Sie zum Projektverzeichnis:

```bash
git clone git@github.com:LaTableSurGit/GlaGla.git
cd GlaGla
stack setup
```
## Projekt erstellen

Um das Projekt zu erstellen, führen Sie den folgenden Befehl im Projektverzeichnis aus:

```bash
make build
```

Um die Build-Artefakte zu bereinigen, verwenden Sie den folgenden Befehl:

```bash
make clean
```

Um alle Artefakte einschließlich Abhängigkeiten zu bereinigen, verwenden Sie den folgenden Befehl:

```bash
make fclean
```

## Ausführen des Compilators

Um den Compiler auszuführen, verwenden Sie den folgenden Befehl:
```bash
./glados < <path_to_input_file>
```
or```bash
./glados
```
um die interaktive Konsole zu betreten.

## Unit-Tests

Um die Unit-Tests auszuführen, verwenden Sie den folgenden Befehl:```bash
make run_test
```

Um die Unit-Tests mit einem Coverage-Bericht auszuführen, verwenden Sie den folgenden Befehl:
```bash
make test_coverage
```

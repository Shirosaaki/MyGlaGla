# Hallo Welt - Erste Schritte mit TSL

## Dein erstes Programm

Das einfachste TSL-Programm gibt "Hallo, Welt!" aus:

```tsl
Deschodt Eric() -> int
    peric("Salut, monde !")
    deschodt 0
```

Wenn Sie dieses Programm ausführen, gibt es Folgendes aus:
```
Salut, monde !
```

## Verständnis des Codes

### `Deschodt` - Funktionsdeklaration
- `Deschodt` ist das Schlüsselwort zur Definition einer Funktion
- Jedes TSL-Programm benötigt eine `Eric`-Funktion (den Einstiegspunkt)
- Man kann es sich wie `main()` in C oder Java vorstellen

### `Eric()` - Hauptfunktion
- `Eric` ist der spezielle Name für die Hauptfunktion
- Die Klammern `()` zeigen an, dass sie keine Parameter entgegennimmt
- Hier beginnt die Ausführung deines Programms

### `-> int` - Rückgabetyp
- Gibt an, dass die Funktion einen Integer zurückgibt
- `0` zeigt eine erfolgreiche Ausführung an (Standard in den meisten Systemen)
- Andere Rückgabetypen könnten `string`, `float`, `void` usw. sein

### `peric(...)` - Ausgabe drucken
- `peric` steht für "drucken" (auf Französisch: "écrire")
- Nimmt ein String-Argument entgegen
- Gibt in der Konsole aus und fügt eine neue Zeile hinzu
- Kann String-Interpolation mit `{variable}` verwenden

### `deschodt` - Rückgabebefehl
- `deschodt` bedeutet "zurückgeben" (auf Französisch: "descendre" → nach unten)
- Verlässt die Funktion und gibt einen Wert zurück
- `deschodt 0` gibt den Exit-Code 0 (Erfolg) zurück

## Ausführen deines Programms

### Kompilieren und Ausführen
```bash
./glados < hello.tsl
```

### Interaktive REPL
```bash
./glados
> :code
|Deschodt Eric() -> int
|    peric("Salut, monde !")
|    deschodt 0
|:end
Salut, monde !
```

## Variationen

### Mehrere Zeilen drucken
```tsl
Deschodt Eric() -> int
    peric("Line 1")
    peric("Line 2")
    peric("Line 3")
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
Line 1
Line 2
Line 3
```

### Verwendung von String-Interpolation
```tsl
Deschodt Eric() -> int
    eric name = "Alice" -> string
    peric("Hello, {name}!")
    deschodt 0
```

I'm sorry, but it seems that you haven't provided the Markdown chunk that you would like me to translate into German (DE). Please provide the text, and I'll be happy to assist you with the translation!
```
Hello, Alice!
```

### Verschiedene Rückgabecodes
```tsl
Deschodt Eric() -> int
    erif (someCondition):
        deschodt 1    desnote error exit
    deschelse:
        deschodt 0    desnote success exit
```

## Nächste Schritte

Jetzt, da du die grundlegende Struktur verstehst, erkunde:
1. **[Variablen](variable.md)** - Daten speichern und manipulieren
2. **[Bedingungen](condition.md)** - Entscheidungen in deinem Code treffen
3. **[Schleifen](loops.md)** - Aktionen wiederholen
4. **[Funktionen](functions.md)** - Wiederverwendbaren Code organisieren

Viel Spaß beim Programmieren!

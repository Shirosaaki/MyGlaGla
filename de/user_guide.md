# 📖 Benutzerhandbuch

Willkommen im GLADOS Benutzerhandbuch! Dieses Dokument bietet einen Überblick über die Funktionen und Möglichkeiten von GLADOS, einem leistungsstarken Kompilator für die TSL (TheShowLang). Egal, ob Sie ein Anfänger oder ein erfahrener Benutzer sind, dieses Handbuch hilft Ihnen, loszulegen und das Beste aus GLADOS herauszuholen.

## ✨ Funktionen

GLADOS bietet die folgenden Funktionen:
- **🟩 TSL Kompilator**: Kompilieren Sie TSL-Code, eine einfache Programmiersprache, die Variablenzuweisungen, arithmetische Operationen und grundlegende Kontrollstrukturen unterstützt.
- **▶️ Interaktives REPL**: Experimentieren Sie mit TSL-Code in einer interaktiven Read-Eval-Print Loop (REPL)-Umgebung.
- **⚠️ Fehlerbehandlung**: Erhalten Sie informative Fehlermeldungen, die Ihnen helfen, Ihren Code zu debuggen.

## 🚀 Erste Schritte

Um mit GLADOS zu beginnen, folgen Sie diesen Schritten:
1. **⬇️ Installation**: Stellen Sie sicher, dass Sie [Stack](https://docs.haskellstack.org/en/stable/README/) installiert haben. Klonen Sie das GLADOS-Repository und navigieren Sie zum Projektverzeichnis:
    ```bash
    git clone https://github.com/LaTableSurGit/GlaGla.git
    cd GlaGla
    stack setup
    ```
2. **⚒️ Projekt erstellen**: Erstellen Sie GLADOS mit dem folgenden Befehl:
    ```bash
    make
    ```
3. **▶️ Kompilator ausführen**: Sie können den Kompilator mit einer TSL-Datei als Eingabe ausführen:
    ```bash
    ./glados
    ```
    oder
    ```bash
    ./glados < path_to_your_file.tsl
    ```

## ✍️ Code schreiben

Das Projekt kann auf zwei Arten verwendet werden: über die interaktive Konsole oder durch Schreiben von TSL-Code in Dateien.
### 1. **Interaktive Konsole**
Starten Sie die interaktive Konsole, indem Sie `./glados` ohne Argumente ausführen. Sie können TSL-Code direkt in die Konsole eingeben, und dieser wird sofort ausgewertet.

Um mehrzeiligen Code zu schreiben, geben Sie `:code` ein, um in den Code-Modus zu wechseln, und `:end`, um den Code-Modus zu verlassen und den Code auszuwerten.

### 2. **TSL-Code-Dateien**
Sie können TSL-Code in Dateien mit der Endung `.tsl` schreiben und diese mit dem Kompilator ausführen.

Hier sind einige grundlegende Beispiele für TSL-Code, um Ihnen den Einstieg zu erleichtern:```tsl
Deschodt factoriel(n -> int) -> int
    erif (n <= 1):
        deschodt 1
    deschelse:
        deschodt n * factoriel(n - 1)

Deschodt Eric() -> int
    eric val = 5
    peric("factoriel({val}) = {factoriel(val)}")
    deschodt 0

desnote print factoriel(5) = 120
```

## 📚 Zusätzliche Ressourcen

## 🎨 Fehlerausgabe konfigurieren

GLADOS kann die Ausgabe von Fehlern anpassen (Präfix, Farbe, Fett/Unterstrichen) über eine YAML-Konfigurationsdatei.

### 1) Konfigurationsdatei erstellen

Erstellen Sie eine Datei `glados.config.yaml` im Projekt-Root.
Alternativ können Sie `GLADOS_CONFIG=/pfad/zur/config.yaml` verwenden, um auf eine andere Datei zu verweisen.

Beispiel:

```yaml
output_mode: console   # console | html

error:
    prefix: "*** ERROR: "
    color: "#FF8500"    # Name (red/green/...) oder Hex (#RRGGBB)
    bold: true
    underline: false

html:
    font_family: "DejaVu Sans Mono, monospace"
    font_size: "18px"
    path: "glados_error.html"
```

### 2) Konsolenmodus (empfohlen)

- `error.color` unterstützt **Hex**-Farben (`#RRGGBB`). GLADOS nutzt Truecolor-ANSI-Sequenzen, damit die Farbe korrekt ist, auch wenn das Terminal-Theme ANSI-Farben ummappt.

### 3) HTML-Modus

Wenn `output_mode: html`:

- GLADOS erzeugt/überschreibt `html.path` **einmal pro Ausführung** (alte Fehler werden nicht gesammelt).
- GLADOS versucht, die HTML-Datei automatisch im Standardbrowser zu öffnen (Linux: `xdg-open`).

Für detailliertere Informationen zur TSL-Syntax und den Funktionen, siehe bitte das [TSL Language Reference](./tsl_language_reference.md). Wenn Sie Fragen haben oder weitere Unterstützung benötigen, zögern Sie nicht, die GLADOS-Community zu kontaktieren oder das GitHub-Repository des Projekts auf Probleme und Diskussionen zu überprüfen.

## ✅ Fazit

Wir hoffen, dass Ihnen dieses Benutzerhandbuch den Einstieg in GLADOS erleichtert. Viel Spaß beim Programmieren mit LISP und TSL! 🎉

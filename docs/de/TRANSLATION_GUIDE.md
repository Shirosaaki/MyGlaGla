# Übersetzungsleitfaden

## Übersicht

Die GLADOS-Dokumentation unterstützt jetzt das automatische Umschalten der Sprache. Benutzer können die Sprache der Benutzeroberfläche über den Sprachwähler in der oberen rechten Ecke der Dokumentationsseite ändern.

## Aktuelle Funktionen

### Unterstützung der Benutzeroberflächensprache

Die Dokumentationsoberfläche unterstützt derzeit:
- 🇬🇧 **Englisch** (en)
- 🇫🇷 **Französisch** (fr)
- 🇪🇸 **Spanisch** (es)
- 🇩🇪 **Deutsch** (de)

Diese Übersetzungen betreffen:
- Beschriftungen der Schaltflächen für Barrierefreiheitseinstellungen
- Schriftgrößensteuerungen
- Textfarbsteuerungen
- Kontraststeuerungen
- Andere UI-Elemente

### So funktioniert es

1. **Sprachauswahl**: Verwenden Sie das Dropdown-Menü in der oberen rechten Ecke
2. **Persistenz**: Ihre Sprachpräferenz wird im Browser-Speicher gespeichert
3. **Automatische Anwendung**: Die Benutzeroberfläche wird sofort aktualisiert, wenn Sie die Sprache ändern

---

## Hinzufügen von Inhaltsübersetzungen

Um eine vollständige Dokumentation in mehreren Sprachen bereitzustellen, haben Sie mehrere Optionen:

### Option 1: Separate Sprachverzeichnisse (Empfohlen)

Erstellen Sie Unterverzeichnisse für jede Sprache:

```
docs/
├── en/               # English documentation
│   ├── README.md
│   ├── user_guide.md
│   └── TECHNICAL.md
├── fr/               # French documentation
│   ├── README.md
│   ├── user_guide.md
│   └── TECHNICAL.md
└── index.html
```

Dann ändern Sie `index.html`, um basierend auf der Sprache zu routen:

```javascript
window.$docsify = {
  // ... existing config
  basePath: '/' + getCurrentLanguage() + '/',
  fallbackLanguages: ['en']
}
```

### Option 2: Dateiendungen

Verwenden Sie Sprachendungen für übersetzte Dateien:

```
docs/
├── README.md         # English (default)
├── README.fr.md      # French
├── README.es.md      # Spanish
├── README.de.md      # German
├── user_guide.md
├── user_guide.fr.md
└── user_guide.es.md
```

### Option 3: Docsify i18n Plugin

Verwenden Sie das offizielle docsify-i18n-Plugin für erweiterte Übersetzungsunterstützung.

---

## Beiträge zu Übersetzungen

### UI-Übersetzungen

Um eine neue Sprache in die Benutzeroberfläche hinzuzufügen:

1. **Bearbeiten Sie `docs/index.html`**
2. **Fügen Sie das Übersetzungsobjekt hinzu**:

```javascript
const translations = {
  en: { /* existing */ },
  fr: { /* existing */ },
  // Add new language
  it: {
    settingsButton: '⚙️ Impostazioni di accessibilità',
    fontSize: 'Dimensione carattere',
    reset: 'Ripristina',
    textColor: 'Colore del testo',
    contrast: 'Contrasto',
    language: '🌐 Lingua'
  }
};
```

3. **Zum Sprachwähler hinzufügen**:

```javascript
var languages = [
  { code: 'en', name: 'English' },
  { code: 'fr', name: 'Français' },
  { code: 'it', name: 'Italiano' }  // Add here
];
```

### Inhalt Übersetzungen

Wir begrüßen Übersetzungen des Dokumentationsinhalts! Um beizutragen:

1. **Wählen Sie ein Dokument** zum Übersetzen (beginnen Sie mit README.md oder user_guide.md)
2. **Erstellen Sie eine Kopie** mit dem entsprechenden Sprachsuffix oder im Sprachverzeichnis
3. **Übersetzen Sie den Inhalt** und achten Sie dabei auf:
   - Originalformatierung
   - Codebeispiele (in der Regel in Englisch belassen)
   - Links und Struktur
4. **Reichen Sie einen Pull Request** mit Ihrer Übersetzung ein

### Übersetzungsrichtlinien

#### Was zu Übersetzen ist
- ✅ Überschriften und Titel
- ✅ Fließtext und Erklärungen
- ✅ Kommentare in Codebeispielen
- ✅ Bildunterschriften
- ✅ Fehlermeldungen und Warnungen

#### Was NICHT zu Übersetzen ist
- ❌ Codebezeichner (Variablen- und Funktionsnamen)
- ❌ Befehle in der Kommandozeile
- ❌ Dateipfade und URLs
- ❌ Technische Begriffe, wenn keine gute Übersetzung existiert
- ❌ Codeausgabe-Beispiele

#### Beispiel

**Deutsch (README.md)**:
```markdown
## Installation

To install GLADOS, run the following command:

```bash
make build
```

Dies wird den Haskell-Quellcode kompilieren.
```

**French (README.fr.md)**:
```markdown
## Installation

Pour installer GLADOS, exécutez la commande suivante :

```bash
make build
```

Das wird den Haskell-Quellcode kompilieren.
```

---

## Translation Status

### Interface (UI)
| Language | Status | Translator |
|----------|--------|------------|
| English  | ✅ Complete | - |
| French   | ✅ Complete | - |
| Spanish  | ✅ Complete | - |
| German   | ✅ Complete | - |

### Documentation Content
| Document | English | French | Spanish | German |
|----------|---------|--------|---------|--------|
| README.md | ✅ | ⏳ Needed | ⏳ Needed | ⏳ Needed |
| user_guide.md | ✅ | ⏳ Needed | ⏳ Needed | ⏳ Needed |
| TECHNICAL.md | ✅ | ⏳ Needed | ⏳ Needed | ⏳ Needed |
| CONTRIBUTING.md | ✅ | ⏳ Needed | ⏳ Needed | ⏳ Needed |
| tsl_language_reference.md | ✅ | ⏳ Needed | ⏳ Needed | ⏳ Needed |

**Legend**: ✅ Complete | 🚧 In Progress | ⏳ Needed

---

## Testing Translations

### Manual Testing

1. Open the documentation site
2. Select your language from the dropdown
3. Verify:
   - UI elements are correctly translated
   - Text makes sense in context
   - No missing translations
   - Proper grammar and spelling

### Automated Testing

Consider creating tests for:
- All translation keys are present in all languages
- No missing or extra keys
- Special characters are properly encoded

---

## Translation Tools

### Recommended Tools
- **DeepL**: High-quality machine translation for initial drafts
- **Google Translate**: Quick translations, but review carefully
- **Crowdin**: Collaborative translation platform
- **Weblate**: Open-source translation platform

### Quality Checklist
- [ ] All text is translated
- [ ] Technical terms are accurate
- [ ] Grammar is correct
- [ ] Tone is appropriate
- [ ] Code examples work
- [ ] Links are not broken
- [ ] Formatting is preserved

---

## Maintenance

### Keeping Translations Updated

When updating documentation:

1. **Update English version** first (source of truth)
2. **Mark other translations** as outdated
3. **Create issues** for translation updates
4. **Use version tags** to track which version was translated

### Translation Versioning

Consider adding a header to translated documents:

```markdown
> 📝 **Translation Info**  
> Original: English v1.2.0  
> Translated: 2026-01-09  
> Translator: @username  
> Status: ✅ Up to date
```

---

## Brauchen Sie Hilfe?

- **Fragen?** Öffnen Sie ein Issue mit dem `translation` Label
- **Möchten Sie beitragen?** Siehe [CONTRIBUTING.md](CONTRIBUTING.md)
- **Haben Sie einen Fehler gefunden?** Melden Sie ihn in den GitHub-Issues

Vielen Dank, dass Sie dazu beitragen, die GLADOS-Dokumentation für alle zugänglich zu machen! 🌍

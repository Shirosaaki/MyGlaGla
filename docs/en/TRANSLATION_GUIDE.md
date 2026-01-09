# Translation Guide

## Overview

The GLADOS documentation now supports automatic language switching. Users can change the interface language using the language selector in the top-right corner of the documentation page.

## Current Features

### Interface Language Support

The documentation interface currently supports:
- 🇬🇧 **English** (en)
- 🇫🇷 **Français** (fr)
- 🇪🇸 **Español** (es)
- 🇩🇪 **Deutsch** (de)

These translations affect:
- Accessibility settings button labels
- Font size controls
- Text color controls
- Contrast controls
- Other UI elements

### How It Works

1. **Language Selection**: Use the dropdown in the top-right corner
2. **Persistence**: Your language preference is saved in browser storage
3. **Automatic Application**: Interface updates immediately when you change language

---

## Adding Content Translations

To provide full documentation in multiple languages, you have several options:

### Option 1: Separate Language Directories (Recommended)

Create subdirectories for each language:

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

Then modify `index.html` to route based on language:

```javascript
window.$docsify = {
  // ... existing config
  basePath: '/' + getCurrentLanguage() + '/',
  fallbackLanguages: ['en']
}
```

### Option 2: File Suffixes

Use language suffixes for translated files:

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

Use the official docsify-i18n plugin for more advanced translation support.

---

## Contributing Translations

### UI Translations

To add a new language to the interface:

1. **Edit `docs/index.html`**
2. **Add to translations object**:

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

3. **Add to language selector**:

```javascript
var languages = [
  { code: 'en', name: 'English' },
  { code: 'fr', name: 'Français' },
  { code: 'it', name: 'Italiano' }  // Add here
];
```

### Content Translations

We welcome translations of the documentation content! To contribute:

1. **Choose a document** to translate (start with README.md or user_guide.md)
2. **Create a copy** with appropriate language suffix or in language directory
3. **Translate the content** while maintaining:
   - Original formatting
   - Code examples (usually kept in English)
   - Links and structure
4. **Submit a Pull Request** with your translation

### Translation Guidelines

#### What to Translate
- ✅ Headers and titles
- ✅ Body text and explanations
- ✅ Comments in code examples
- ✅ Image captions
- ✅ Error messages and warnings

#### What NOT to Translate
- ❌ Code identifiers (variable names, function names)
- ❌ Command-line commands
- ❌ File paths and URLs
- ❌ Technical terms when no good translation exists
- ❌ Code output examples

#### Example

**English (README.md)**:
```markdown
## Installation

To install GLADOS, run the following command:

```bash
make build
```

This will compile the Haskell source code.
```

**French (README.fr.md)**:
```markdown
## Installation

Pour installer GLADOS, exécutez la commande suivante :

```bash
make build
```

Cela compilera le code source Haskell.
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

## Need Help?

- **Questions?** Open an issue with the `translation` label
- **Want to contribute?** See [CONTRIBUTING.md](CONTRIBUTING.md)
- **Found an error?** Report it in GitHub issues

Thank you for helping make GLADOS documentation accessible to everyone! 🌍

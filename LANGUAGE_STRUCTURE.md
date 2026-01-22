# Language Directory Structure

## Overview

The documentation now uses a directory-based structure for multi-language support:

```
docs/
├── index.html          # Main entry point (unchanged)
├── _navbar.md          # Root navbar (fallback)
├── en/                 # English (complete)
│   ├── README.md
│   ├── user_guide.md
│   ├── TECHNICAL.md
│   ├── CONTRIBUTING.md
│   ├── TRANSLATION_GUIDE.md
│   ├── _navbar.md
│   └── TSL/
│       ├── hello_world.md
│       ├── variables.md
│       └── ...
├── fr/                 # French (starter files)
│   ├── README.md
│   ├── _navbar.md
│   └── TSL/
├── es/                 # Spanish (starter files)
│   ├── README.md
│   ├── _navbar.md
│   └── TSL/
└── de/                 # German (starter files)
    ├── README.md
    ├── _navbar.md
    └── TSL/
```

## How It Works

1. **Language Selection**: User selects language from dropdown
2. **Automatic Routing**: Page reloads with `basePath` set to `/{language}/`
3. **Fallback**: If translation doesn't exist, falls back to English (`en/`)

## Current Status

### ✅ English (en/)
- Complete documentation copied from root
- All files available
- Fully functional

### 🚧 French (fr/)
- README.md with basic translation
- Navigation menu (links to English content for now)
- Ready for full translation

### 🚧 Spanish (es/)
- README.md with basic translation
- Navigation menu (links to English content for now)
- Ready for full translation

### 🚧 German (de/)
- README.md with basic translation
- Navigation menu (links to English content for now)
- Ready for full translation

## Adding Translations

### For a new document:

1. **Copy the English file** to the target language directory:
   ```bash
   cp docs/en/user_guide.md docs/fr/guide_utilisateur.md
   ```

2. **Translate the content** while maintaining:
   - Markdown formatting
   - Code blocks (usually unchanged)
   - Link structure

3. **Update the navbar** in the language directory:
   ```markdown
   * [📖 Guide utilisateur](./guide_utilisateur.md)
   ```

### For TSL tutorials:

1. **Copy tutorial files**:
   ```bash
   cp docs/en/TSL/hello_world.md docs/fr/TSL/hello_world.md
   ```

2. **Translate** explanatory text

3. **Keep code examples** in original form (or add comments in target language)

## Testing

1. Start a local server:
   ```bash
   cd docs
   python3 -m http.server 3000
   ```

2. Open browser to `http://localhost:3000`

3. Select language from dropdown

4. Verify:
   - Page loads correctly
   - Navigation works
   - Falls back to English if translation missing

## Migration Notes

- Original documentation files remain in `docs/` root as backup
- English version in `docs/en/` is the source of truth
- Update English first, then translate to other languages
- Use relative links `../en/` for untranslated pages

## Benefits

✅ Clear organization by language  
✅ Easy to see translation progress  
✅ Independent navbar per language  
✅ Automatic fallback to English  
✅ Contributors can focus on one language  
✅ SEO-friendly language URLs

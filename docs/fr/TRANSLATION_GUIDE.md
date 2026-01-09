# Guide de traduction

## Aperçu

La documentation GLADOS prend désormais en charge la commutation automatique de langue. Les utilisateurs peuvent modifier la langue de l'interface à l'aide du sélecteur de langue situé dans le coin supérieur droit de la page de documentation.

## Fonctionnalités actuelles

### Prise en charge de la langue de l'interface

L'interface de documentation prend actuellement en charge :
- 🇬🇧 **Anglais** (en)
- 🇫🇷 **Français** (fr)
- 🇪🇸 **Español** (es)
- 🇩🇪 **Deutsch** (de)

Ces traductions affectent :
- Les étiquettes des boutons des paramètres d'accessibilité
- Les commandes de taille de police
- Les commandes de couleur de texte
- Les commandes de contraste
- Autres éléments de l'interface utilisateur

### Comment ça marche

1. **Sélection de la langue** : utilisez le menu déroulant dans le coin supérieur droit
2. **Persistance** : votre préférence de langue est enregistrée dans le stockage du navigateur
3. **Application automatique** : l'interface se met à jour immédiatement lorsque vous changez de langue

---

## Ajout de traductions de contenu

Pour fournir une documentation complète dans plusieurs langues, vous avez plusieurs options :

### Option 1 : Répertoires de langues distincts (recommandé)

Créez des sous-répertoires pour chaque langue :

```
docs/
├── en/               # Documentation en anglais
│   ├── README.md
│   ├── user_guide.md
│   └── TECHNICAL.md
├── fr/               # Documentation en français
│   ├── README.md
│   ├── user_guide.md
│   └── TECHNICAL.md
└── index.html
```

Modifiez ensuite `index.html` pour router en fonction de la langue :

```javascript
window.$docsify = {
  // ... existing config
  basePath: '/' + getCurrentLanguage() + '/',
  fallbackLanguages: ['en']
}
```

### Option 2 : Suffixes de fichiers

Utilisez des suffixes de langue pour les fichiers traduits :

```
docs/
├── README.md         # Anglais (par défaut)
├── README.fr.md      # Français
├── README.es.md      # Espagnol
├── README.de.md      # Allemand
├── user_guide.md
├── user_guide.fr.md
└── user_guide.es.md
```

### Option 3 : Plugin Docsify i18n

Utilisez le plugin officiel docsify-i18n pour une prise en charge plus avancée de la traduction.

---

## Contribution aux traductions

### Traductions de l'interface utilisateur

Pour ajouter une nouvelle langue à l'interface :

1. **Modifier `docs/index.html`**
2. **Ajouter à l'objet de traductions** :

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

3. **Ajouter au sélecteur de langue** :

```javascript
var languages = [
  { code: 'en', name: 'English' },
  { code: 'fr', name: 'Français' },
  { code: 'it', name: 'Italiano' }  // Add here
];
```

### Traductions de contenu

Nous acceptons volontiers les traductions du contenu de la documentation ! Pour contribuer :

1. **Choisissez un document** à traduire (commencez par README.md ou user_guide.md)
2. **Créez une copie** avec le suffixe de langue approprié ou dans le répertoire de langue
3. **Traduisez le contenu** tout en conservant :
   - Formatage d'origine
   - Exemples de code (généralement conservés en anglais)
   - Liens et structure
4. **Soumettez une demande d'extraction** avec votre traduction

### Consignes de traduction

#### Ce qu'il faut traduire
- ✅ En-têtes et titres
- ✅ Corps du texte et explications
- ✅ Commentaires dans les exemples de code
- ✅ Légendes d'images
- ✅ Messages d'erreur et avertissements

#### Ce qu'il ne faut PAS traduire
- ❌ Identificateurs de code (noms de variables, noms de fonctions)
- ❌ Commandes de ligne de commande
- ❌ Chemins de fichiers et URL
- ❌ Termes techniques lorsqu'il n'existe pas de bonne traduction
- ❌ Exemples de sortie de code

#### Exemple

**Anglais (README.md)** :
```markdown
## Installation

To install GLADOS, run the following command:

```bash
make build
```

This will compile the Haskell source code.
```

**Français (README.fr.md)** :
```markdown
## Installation

Pour installer GLADOS, exécutez la commande suivante :

```bash
make build
```

Cela compilera le code source Haskell.
```

---

## État de la traduction

### Interface (UI)
| Langue | État | Traducteur |
|----------|--------|------------|
| Anglais  | ✅ Terminé | - |
| Français   | ✅ Terminé | - |
| Espagnol  | ✅ Terminé | - |
| Allemand   | ✅ Terminé | - |

### Contenu de la documentation
| Document | Anglais | Français | Espagnol | Allemand |
|----------|---------|--------|---------|--------|
| README.md | ✅ | ⏳ Nécessaire | ⏳ Nécessaire | ⏳ Nécessaire |
| user_guide.md | ✅ | ⏳ Nécessaire | ⏳ Nécessaire | ⏳ Nécessaire |
| TECHNICAL.md | ✅ | ⏳ Nécessaire | ⏳ Nécessaire | ⏳ Nécessaire |
| CONTRIBUTING.md | ✅ | ⏳ Nécessaire | ⏳ Nécessaire | ⏳ Nécessaire |
| tsl_language_reference.md | ✅ | ⏳ Nécessaire | ⏳ Nécessaire | ⏳ Nécessaire |

**Légende** : ✅ Terminé | 🚧 En cours | ⏳ Nécessaire

---

## Test des traductions

### Tests manuels

1. Ouvrez le site de documentation
2. Sélectionnez votre langue dans le menu déroulant
3. Vérifiez :
   - Les éléments de l'interface utilisateur sont correctement traduits
   - Le texte a du sens dans le contexte
   - Aucune traduction manquante
   - Grammaire et orthographe correctes

### Tests automatisés

Envisagez de créer des tests pour :
- Toutes les clés de traduction sont présentes dans toutes les langues
- Aucune clé manquante ou supplémentaire
- Les caractères spéciaux sont correctement encodés

---

## Outils de traduction

### Outils recommandés
- **DeepL** : Traduction automatique de haute qualité pour les premières ébauches
- **Google Traduction** : Traductions rapides, mais à examiner attentivement
- **Crowdin** : Plateforme de traduction collaborative
- **Weblate** : Plateforme de traduction open source

### Liste de contrôle de la qualité
- [ ] Tout le texte est traduit
- [ ] Les termes techniques sont exacts
- [ ] La grammaire est correcte
- [ ] Le ton est approprié
- [ ] Les exemples de code fonctionnent
- [ ] Les liens ne sont pas rompus
- [ ] Le formatage est conservé

---

## Maintenance

### Maintien des traductions à jour

Lors de la mise à jour de la documentation :

1. **Mettez d'abord à jour la version anglaise** (source de vérité)
2. **Marquez les autres traductions** comme obsolètes
3. **Créez des problèmes** pour les mises à jour de traduction
4. **Utilisez des balises de version** pour suivre quelle version a été traduite

### Versionnage des traductions

Envisagez d'ajouter un en-tête aux documents traduits :

```markdown
> 📝 **Informations sur la traduction**
> Original : Anglais v1.2.0
> Traduit : 2026-01-09
> Traducteur : @username
> État : ✅ À jour
```

---

## Besoin d'aide ?

- **Des questions ?** Ouvrez un problème avec l'étiquette `translation`
- **Vous voulez contribuer ?** Consultez [CONTRIBUTING.md](CONTRIBUTING.md)
- **Vous avez trouvé une erreur ?** Signalez-la dans les problèmes GitHub

Merci d'aider à rendre la documentation GLADOS accessible à tous ! 🌍

# Guía de traducción

## Resumen

La documentación de GLADOS ahora admite el cambio automático de idioma. Los usuarios pueden modificar el idioma de la interfaz utilizando el selector de idioma ubicado en la esquina superior derecha de la página de documentación.

## Funcionalidades actuales

### Soporte de idioma de la interfaz

La interfaz de documentación actualmente admite:
- 🇬🇧 **Inglés** (en)
- 🇫🇷 **Francés** (fr)
- 🇪🇸 **Español** (es)
- 🇩🇪 **Alemán** (de)

Estas traducciones afectan:
- Las etiquetas de los botones de configuración de accesibilidad
- Los comandos de tamaño de fuente
- Los comandos de color de texto
- Los comandos de contraste
- Otros elementos de la interfaz de usuario

### Cómo funciona

1. **Selección del idioma**: utiliza el menú desplegable en la esquina superior derecha
2. **Persistencia**: tu preferencia de idioma se guarda en el almacenamiento del navegador
3. **Aplicación automática**: la interfaz se actualiza inmediatamente cuando cambias de idioma

---

## Adición de traducciones de contenido

Para proporcionar una documentación completa en varios idiomas, tienes varias opciones:

### Opción 1: Directorios de idiomas distintos (recomendado)

Crea subdirectorios para cada idioma:

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

Modifique luego `index.html` para enrutar según el idioma:

```javascript
window.$docsify = {
  // ... existing config
  basePath: '/' + getCurrentLanguage() + '/',
  fallbackLanguages: ['en']
}
```

### Opción 2: Sufijos de archivos

Utiliza sufijos de idioma para los archivos traducidos:

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

### Opción 3: Plugin Docsify i18n

Utiliza el plugin oficial docsify-i18n para un soporte más avanzado de la traducción.

---

## Contribución a las traducciones

### Traducciones de la interfaz de usuario

Para agregar un nuevo idioma a la interfaz:

1. **Modificar `docs/index.html`**
2. **Agregar al objeto de traducciones**:

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

3. **Agregar al selector de idioma** :

```javascript
var languages = [
  { code: 'en', name: 'English' },
  { code: 'fr', name: 'Français' },
  { code: 'it', name: 'Italiano' }  // Add here
];
```

### Traducciones de contenido

¡Aceptamos con gusto las traducciones del contenido de la documentación! Para contribuir:

1. **Elige un documento** para traducir (comienza por README.md o user_guide.md)
2. **Crea una copia** con el sufijo de idioma apropiado o en el directorio de idioma
3. **Traduce el contenido** manteniendo:
   - Formato original
   - Ejemplos de código (generalmente se mantienen en inglés)
   - Enlaces y estructura
4. **Envía una solicitud de extracción** con tu traducción

### Instrucciones de traducción

#### Lo que hay que traducir
- ✅ Encabezados y títulos
- ✅ Cuerpo del texto y explicaciones
- ✅ Comentarios en los ejemplos de código
- ✅ Leyendas de imágenes
- ✅ Mensajes de error y advertencias

#### Lo que NO hay que traducir
- ❌ Identificadores de código (nombres de variables, nombres de funciones)
- ❌ Comandos de línea de comandos
- ❌ Rutas de archivos y URL
- ❌ Términos técnicos cuando no existe una buena traducción
- ❌ Ejemplos de salida de código

#### Ejemplo

**Inglés (README.md)**:
```markdown
## Installation

To install GLADOS, run the following command:

```bash
make build
```

Esto compilará el código fuente de Haskell.
```

**Français (README.fr.md)** :
```markdown
## Installation

Pour installer GLADOS, exécutez la commande suivante :

```bash
make build
```

Esto compilará el código fuente de Haskell.
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

## ¿Necesitas ayuda?

- **¿Tienes preguntas?** Abre un problema con la etiqueta `translation`
- **¿Quieres contribuir?** Consulta [CONTRIBUTING.md](CONTRIBUTING.md)
- **¿Has encontrado un error?** Infórmalo en los problemas de GitHub

¡Gracias por ayudar a que la documentación de GLADOS sea accesible para todos! 🌍

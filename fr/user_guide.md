# 📖 Guide de l'utilisateur

Bienvenue dans le Guide de l'utilisateur de GLADOS ! Ce document fournit une vue d'ensemble des fonctionnalités de GLADOS, un compilateur puissant pour le TSL (TheShowLang). Que vous soyez débutant ou utilisateur expérimenté, ce guide vous aidera à démarrer et à tirer le meilleur parti de GLADOS.

## ✨ Fonctionnalités

GLADOS offre les fonctionnalités suivantes :
- **🟩 Compilateur TSL** : Compilez le code TSL, un langage de programmation simple qui prend en charge les affectations de variables, les opérations arithmétiques et les structures de contrôle de base.
- **▶️ REPL interactif** : Expérimentez avec le code TSL dans un environnement interactif Read-Eval-Print Loop (REPL).
- **⚠️ Gestion des erreurs** : Obtenez des messages d'erreur informatifs pour vous aider à déboguer votre code.

## 🚀 Démarrage

Pour commencer avec GLADOS, suivez ces étapes :
1. **⬇️ Installation** : Assurez-vous que [Stack](https://docs.haskellstack.org/en/stable/README/) est installé. Clonez le dépôt GLADOS et accédez au répertoire du projet :
    ```bash
    git clone https://github.com/LaTableSurGit/GlaGla.git
    cd GlaGla
    stack setup
    ```
2. **⚒️ Construction du projet** : Construisez GLADOS en utilisant la commande suivante :
    ```bash
    make
    ```
3. **▶️ Exécution du compilateur** : Vous pouvez exécuter le compilateur avec un fichier TSL en entrée :
    ```bash
    ./glados
    ```
    ou
    ```bash
    ./glados < path_to_your_file.tsl
    ```

## ✍️ Écriture de code

Le projet peut être utilisé de deux manières : via la console interactive ou en écrivant du code TSL dans des fichiers.
### 1. **Console interactive**
Lancez la console interactive en exécutant `./glados` sans aucun argument. Vous pouvez taper du code TSL directement dans la console, et il sera évalué immédiatement.

Pour écrire du code multiligne, tapez `:code` pour entrer en mode code, et `:end` pour quitter le mode code et évaluer le code.

### 2. **Fichiers de code TSL**
Vous pouvez écrire du code TSL dans des fichiers avec une extension `.tsl` et les exécuter en utilisant le compilateur.

Voici quelques exemples de base de code TSL pour vous aider à démarrer :
```tsl
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

## 📚 Ressources supplémentaires

## 🎨 Configuration de l’affichage des erreurs

GLADOS peut personnaliser l’affichage des erreurs (préfixe, couleur, gras/souligné) via un fichier de configuration YAML.

### 1) Créer un fichier de configuration

Créez un fichier nommé `glados.config.yaml` à la racine du projet.
Vous pouvez aussi utiliser `GLADOS_CONFIG=/chemin/vers/config.yaml` pour pointer vers un autre fichier.

Exemple :

```yaml
output_mode: console   # console | html

error:
    prefix: "*** ERROR: "
    color: "#FF8500"    # nom (red/green/...) ou hex (#RRGGBB)
    bold: true
    underline: false

html:
    font_family: "DejaVu Sans Mono, monospace"
    font_size: "18px"
    path: "glados_error.html"
```

### 2) Mode console (recommandé)

- `error.color` accepte des couleurs **hex** (`#RRGGBB`). GLADOS utilise des séquences ANSI truecolor afin que la couleur soit correcte même si le thème du terminal remappe les couleurs ANSI.

### 3) Mode HTML

Si `output_mode: html` :

- GLADOS génère/écrase `html.path` **une fois par exécution** (les anciennes erreurs ne s’accumulent pas).
- GLADOS essaie d’ouvrir automatiquement le fichier HTML dans le navigateur par défaut (Linux : `xdg-open`).

Pour des informations plus détaillées sur la syntaxe et les fonctionnalités du langage TSL, veuillez consulter la [Référence du langage TSL](./tsl_language_reference.md). Si vous avez des questions ou avez besoin d'aide supplémentaire, n'hésitez pas à contacter la communauté GLADOS ou à consulter le dépôt GitHub du projet pour les problèmes et les discussions.

## ✅ Conclusion

Nous espérons que ce Guide de l'utilisateur vous aidera à démarrer avec GLADOS. Amusez-vous à coder avec LISP et TSL ! 🎉

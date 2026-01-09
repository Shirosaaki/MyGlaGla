# GLADOS

## Description

Un compilateur de son propre langage de programmation. Nous l'appellerons TheShowLang (TSL). TSL est un langage simple qui supporte l'assignation de variables, les opérations arithmétiques et les structures de contrôle de base.

Tout le code est écrit en Haskell.

## Installation

Pour installer le projet, assurez-vous que [Stack](https://docs.haskellstack.org/en/stable/README/) est installé. Ensuite, clonez le référentiel et naviguez vers le répertoire du projet :

```bash
git clone git@github.com:LaTableSurGit/GlaGla.git
cd GlaGla
stack setup
```
## Construction du projet

Pour construire le projet, exécutez la commande suivante dans le répertoire du projet :

```bash
make build
```

Pour nettoyer les artefacts de construction, utilisez la commande suivante :

```bash
make clean
```

Pour nettoyer tous les artefacts y compris les dépendances, utilisez la commande suivante :

```bash
make fclean
```

## Exécution du Compilateur

Pour exécuter le compilateur, utilisez la commande suivante :
```bash
./glados < <chemin_vers_le_fichier_d_entree>
```
ou
```bash
./glados
```
pour entrer dans la console interactive.

## Tests unitaires

To run the unit tests, use the following command:
```bash
make run_test
```

To run the unit tests with coverage report, use the following command:
```bash
make test_coverage
```

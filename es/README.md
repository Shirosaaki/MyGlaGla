# GLADOS

## Descripción

Un compilador de su propio lenguaje de programación. Lo llamaremos TheShowLang (TSL). TSL es un lenguaje simple que soporta la asignación de variables, las operaciones aritméticas y las estructuras de control básicas.

Todo el código está escrito en Haskell.

## Instalación

Para instalar el proyecto, asegúrate de que [Stack](https://docs.haskellstack.org/en/stable/README/) esté instalado. Luego, clona el repositorio y navega hacia el directorio del proyecto :

```bash
git clone git@github.com:LaTableSurGit/GlaGla.git
cd GlaGla
stack setup
```
## Construcción del proyecto

Para construir el proyecto, ejecuta el siguiente comando en el directorio del proyecto:

```bash
make build
```

Para limpiar los artefactos de construcción, utiliza el siguiente comando:

```bash
make clean
```

Para limpiar todos los artefactos, incluidas las dependencias, utiliza el siguiente comando:

```bash
make fclean
```

## Ejecución del Compilador

Para ejecutar el compilador, utiliza el siguiente comando :
```bash
./glados < <chemin_vers_le_fichier_d_entree>
```
It seems that the Markdown chunk you provided is incomplete or contains only the word "ou." Please provide the full content you would like translated, and I'll be happy to assist you with the translation into Spanish (ES).```bash
./glados
```
```markdown
pour entrer dans la console interactive.

## Pruebas unitarias

Para ejecutar las pruebas unitarias, utiliza el siguiente comando:
``````bash
make run_test
```

Para ejecutar las pruebas unitarias con el informe de cobertura, utiliza el siguiente comando:
```bash
make test_coverage
```

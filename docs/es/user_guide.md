# 📖 Guía del usuario

¡Bienvenido a la Guía del usuario de GLADOS! Este documento proporciona una visión general de las características de GLADOS, un potente compilador para TSL (TheShowLang). Ya seas principiante o usuario experimentado, esta guía te ayudará a comenzar y a sacar el máximo provecho de GLADOS.

## ✨ Características

GLADOS ofrece las siguientes características:
- **🟩 Compilador TSL**: Compila el código TSL, un lenguaje de programación simple que admite asignaciones de variables, operaciones aritméticas y estructuras de control básicas.
- **▶️ REPL interactivo**: Experimenta con el código TSL en un entorno interactivo Read-Eval-Print Loop (REPL).
- **⚠️ Gestión de errores**: Obtén mensajes de error informativos que te ayudarán a depurar tu código.

## 🚀 Comenzando

Para empezar con GLADOS, sigue estos pasos:
1. **⬇️ Instalación**: Asegúrate de que [Stack](https://docs.haskellstack.org/en/stable/README/) esté instalado. Clona el repositorio de GLADOS y accede al directorio del proyecto:
    ```bash
    git clone https://github.com/LaTableSurGit/GlaGla.git
    cd GlaGla
    stack setup
    ```
2. **⚒️ Construcción del proyecto**: Construye GLADOS utilizando el siguiente comando:
    ```bash
    make
    ```
3. **▶️ Ejecución del compilador**: Puedes ejecutar el compilador con un archivo TSL como entrada:
    ```bash
    ./glados
    ```
    o
    ```bash
    ./glados < path_to_your_file.tsl
    ```

## ✍️ Escritura de código

El proyecto se puede utilizar de dos maneras: a través de la consola interactiva o escribiendo código TSL en archivos.
### 1. **Consola interactiva**
Inicia la consola interactiva ejecutando `./glados` sin ningún argumento. Puedes escribir código TSL directamente en la consola, y se evaluará de inmediato.

Para escribir código multilinea, escribe `:code` para entrar en modo código, y `:end` para salir del modo código y evaluar el código.

### 2. **Archivos de código TSL**
Puedes escribir código TSL en archivos con la extensión `.tsl` y ejecutarlos utilizando el compilador.

Aquí tienes algunos ejemplos básicos de código TSL para ayudarte a comenzar:```tsl
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

## 📚 Recursos adicionales

Para obtener información más detallada sobre la sintaxis y las características del lenguaje TSL, consulte la [Referencia del lenguaje TSL](./tsl_language_reference.md). Si tiene preguntas o necesita ayuda adicional, no dude en contactar a la comunidad GLADOS o consultar el repositorio de GitHub del proyecto para problemas y discusiones.

## ✅ Conclusión

Esperamos que esta Guía del usuario le ayude a comenzar con GLADOS. ¡Diviértase programando con LISP y TSL! 🎉

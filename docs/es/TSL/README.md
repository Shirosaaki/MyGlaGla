# Documentación TSL - Vista general de la guía completa

Este directorio contiene una documentación completa para el lenguaje de programación TSL (Temporal Stream Language). Todos los archivos están diseñados para principiantes que aprenden el lenguaje desde cero.

## 📚 Archivos de documentación

### Documentación básica (`docs/`)

| Archivo | Objetivo |
|------|---------|
| [LANGUAGE_GUIDE.md](LANGUAGE_GUIDE.md) | **Vista completa del lenguaje** - Todas las características, la sintaxis, ejemplos, uso de REPL, consejos, errores comunes |

### Serie de tutoriales (`docs/TSL/`)

| # | Tema | Archivo | Contenido |
|---|-------|------|---------|
| 1 | Hello World | [hello_world.md](TSL/hello_world.md) | Tu primer programa usando `Deschodt`, `Eric`, `peric`, `deschodt` |
| 2 | Variables | [variable.md](TSL/variable.md) | Declaración de variable, tipos, alcance, interpolación, conversión de tipo |
| 3 | Condiciones | [condition.md](TSL/condition.md) | Instrucciones If/else, operadores, lógica booleana, condiciones anidadas |
| 4 | Bucles | [loops.md](TSL/loops.md) | Bucles For-in (aer) y while (darius), break/continue, bucles anidados |
| 5 | Funciones | [functions.md](TSL/functions.md) | Definición de función, parámetros, tipos de retorno, recursión, ejemplos prácticos |
| 6 | Arreglos/Listas | [lists.md](TSL/lists.md) | Creación de arreglo, indexación, arreglos dispersos, iteración, ejemplos prácticos |
| 7 | Estructuras | [structs.md](TSL/structs.md) | Definición de estructura, campos, estructuras anidadas, arreglo de estructuras |
| 8 | Enumeraciones | [enums.md](TSL/enums.md) | Definición de enumeración, numeración automática, uso en funciones, ejemplos prácticos |
| 9 | Punteros | [pointers.md](TSL/pointers.md) | Declaración de puntero, desreferenciación, paso por referencia, aritmética de punteros |
| 10 | Entrada/Salida | [read-write.md](TSL/read-write.md) | Salida con `peric`, interpolación de cadenas, salida formateada, depuración |

## 🎯 Cobertura

### Funcionalidades del lenguaje documentadas

**Tipos de datos:**
- ✅ Enteros (`int`)
- ✅ Flotantes (`float`)
- ✅ Cadenas (`string`)
- ✅ Caracteres (`char`)
- ✅ Booleanos (`bool`)
- ✅ Vacío (`void`)
- ✅ Arreglos (`type[]`)
- ✅ Punteros (`type*`)
- ✅ Estructuras (`destruct`)
- ✅ Enumeraciones (`desnum`)

**Palabras clave y funciones:**
- ✅ `Deschodt` - Definición de función
- ✅ `Eric` - Función principal / Declaración de variable
- ✅ `peric` - Imprimir salida
- ✅ `deschodt` - Instrucción de retorno
- ✅ `erif` - Condicional If
- ✅ `deschelse` - Condicional Else
- ✅ `aer` - Bucle For-in
- ✅ `darius` - Bucle While
- ✅ `deschontinue` - Instrucción Continue
- ✅ `deschreak` - Instrucción Break
- ✅ `&` - Operador de dirección (punteros)
- ✅ `*` - Operador de desreferenciación (punteros)

**Operadores:**
- ✅ Aritméticos: `+`, `-`, `*`, `/`, `mod`, `div`
- ✅ Comparación: `==`, `!=`, `<`, `>`, `<=`, `>=`
- ✅ Lógicos: `&&`, `||`, `!`
- ✅ Anotaciones de tipo: `->`

## 📖 Ruta de aprendizaje

### Principiante (1-4)
Comienza aquí si eres nuevo en programación:
1. [Hello World](TSL/hello_world.md) - Escribe tu primer programa
2. [Variables](TSL/variable.md) - Almacena y utiliza datos
3. [Condiciones](TSL/condition.md) - Toma decisiones en el código
4. [Bucles](TSL/loops.md) - Repite acciones

### Intermedio (5-6)
Crea programas más complejos:
5. [Funciones](TSL/functions.md) - Organiza el código en elementos reutilizables
6. [Arreglos/Listas](TSL/lists.md) - Trabaja con colecciones de datos

### Avanzado (7-9)
Crea estructuras de datos sofisticadas:
7. [Estructuras](TSL/structs.md) - Agrupa datos relacionados
8. [Enumeraciones](TSL/enums.md) - Define conjuntos de valores fijos
9. [Punteros](TSL/pointers.md) - Trabaja con direcciones de memoria

### Práctica (10)
Domina la comunicación del programa:
10. [Entrada/Salida](TSL/read-write.md) - Muestra resultados y formatea la salida

## 🔑 Principales características de la documentación

### Para cada tema:
- ✅ **Conceptos básicos** - Explicaciones simples con la sintaxis
- ✅ **Ejemplos de código** - Ejemplos ejecutables con la salida
- ✅ **Aplicaciones prácticas** - Casos de uso reales
- ✅ **Errores comunes** - Patrones de error a evitar
- ✅ **Mejores prácticas** - Consejos para escribir buen código
- ✅ **Referencias cruzadas** - Enlaces a temas relacionados

### Estilo de documentación:
- 🎯 **Adaptado a principiantes** - No supone ningún conocimiento previo en programación
- 📝 **Ejemplo primero** - Muestra el código primero, explica después
- 🧪 **Ejemplos ejecutables** - Todo el código puede ser probado en el REPL
- 🔗 **Interconectado** - Referencias cruzadas entre conceptos relacionados
- 📊 **Tablas claras** - Tablas de referencia de sintaxis y operadores
- ⚠️ **Consejos sobre errores** - Errores comunes con sus correcciones

## 🚀 Uso de esta documentación

### Aprendizaje de TSL:
1. Comienza con **[Hello World](TSL/hello_world.md)**
2. Sigue la secuencia numerada según tu nivel de habilidad
3. Escribe ejemplos en el **REPL interactivo**
4. Experimenta y modifica los ejemplos
5. Consulta **[LANGUAGE_GUIDE](LANGUAGE_GUIDE.md)** para una referencia rápida

### Referencia rápida:
- ¿Necesitas ayuda con la sintaxis? → Consulta la sección de tutorial pertinente
- ¿Quieres ejemplos? → Revisa las secciones "Ejemplo práctico"
- ¿Te aparece un error? → Consulta la sección "Errores comunes"
- ¿Necesitas una visión completa? → Lee **[LANGUAGE_GUIDE](LANGUAGE_GUIDE.md)**

### Para los docentes:
- Utiliza los tutoriales como planes de clase
- Muestra ejemplos a los estudiantes
- Dirige a los aprendices hacia las secciones pertinentes
- Usa "Errores comunes" para la práctica de depuración

## 📊 Estadísticas de la documentación

| Métrica | Contar |
|--------|-------|
| Número total de archivos de documentación | 11 |
| Número total de líneas de documentación | ~4,500+ |
| Ejemplos de código | 150+ |
| Ejemplos prácticos | 40+ |
| Errores comunes listados | 60+ |
| Referencias cruzadas | 100+ |
| Tablas y material de referencia | 20+ |

## 🔄 REPL interactivo

Todos los ejemplos pueden ser probados en el REPL interactivo:

```bash
stack run
# or
./glados
```

**Características de REPL:**
- Ejecución inmediata en una sola línea: escribe y presiona Enter
- Bloques multilínea: utiliza los delimitadores `:code` ... `:end`
- Edición de línea: soporte completo del historial de edición
- Escribe cualquier expresión para evaluar

## 📝 Ejemplo de sesión

```
$ stack run
glados> eric x = 10 -> int
10
glados> peric("x = {x}")
x = 10
glados> :code
code> eric factorial(n -> int) -> int
code>     erif (n <= 1):
code>         deschodt 1
code>     deschelse:
code>         deschodt n * factorial(n - 1)
code> :end
<closure>
glados> peric("5! = {factorial(5)}")
5! = 120
```

## 🎓 Pasos siguientes

Después de haber completado la serie de tutoriales:

1. **Crear proyectos** - Crea tus propios programas utilizando los conceptos aprendidos
2. **Combinar conceptos** - Mezcla arreglos, estructuras, funciones para soluciones complejas
3. **Leer ejemplos** - Estudia los archivos `.tslang` en la carpeta `examples/`
4. **Experimentar** - Modifica los ejemplos para comprender mejor

## 📞 ¿Preguntas sobre la documentación?

Si los conceptos no están claros:
1. Consulta la **LANGUAGE_GUIDE** para más contexto
2. Revisa los **Errores comunes** para patrones de error
3. Consulta los **Ejemplos prácticos** para casos similares
4. Experimenta en el **REPL** para probar la comprensión

---

**Última actualización:** 2024  
**Versión:** 1.0 - Guía completa para principiantes  
**Estado:** ✅ Los 10 principales temas están documentados

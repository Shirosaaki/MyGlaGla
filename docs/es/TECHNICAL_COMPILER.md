# Compilador - Documentación Técnica

## Tabla de Contenidos

- [Descripción general](#descripción-general)
- [Arquitectura del compilador](#arquitectura-del-compilador)
- [Pipeline de compilación](#pipeline-de-compilación)
- [Árbol de Sintaxis Abstracta (AST)](#árbol-de-sintaxis-abstracta-ast)
- [Sistema de tipos](#sistema-de-tipos)
- [Integración del parser](#integración-del-parser)
- [Análisis de código y optimización](#análisis-de-código-y-optimización)
- [Backends de generación de código](#backends-de-generación-de-código)
- [Gestión de memoria](#gestión-de-memoria)
- [Funciones integradas](#funciones-integradas)
- [Manejo de errores](#manejo-de-errores)
- [Ejemplos de uso](#ejemplos-de-uso)
- [Consideraciones de rendimiento](#consideraciones-de-rendimiento)

---

## Descripción general

El compilador GLaDOS es un compilador multi-backend para el lenguaje de programación TheShowLang (TSL). Transforma código fuente escrito en TSL en código ejecutable a través de múltiples objetivos de compilación:

- **Objetivo Bytecode**: Genera bytecode para la Máquina Virtual GLaDOS
- **Ensamblador x86-64**: Generación de código nativo para sistemas Linux
- **LLVM IR** (planificado): Para optimizaciones avanzadas

El compilador está implementado en Haskell y proporciona seguridad de tipos fuerte, informes de errores completos y múltiples pases de optimización.

### Características principales

1. **Compilación multi-objetivo**: Soporte para bytecode VM y ensamblador x86-64 nativo
2. **Inferencia de tipos**: Deducción automática de tipos para variables y expresiones
3. **Pases de optimización**: Plegado de constantes, eliminación de código muerto, inlining de constantes globales
4. **Soporte de closures**: Funciones de primera clase con ámbito léxico
5. **Sistema de tipos rico**: Enteros, flotantes, cadenas, booleanos, arrays, structs
6. **Mensajes de error detallados**: Informes de errores precisos con nombres de variables/funciones

---

## Arquitectura del compilador

### Módulos principales

```
┌─────────────────────────────────────────────────┐
│                 Código fuente                    │
│            (Sintaxis TheShow/Lisp)               │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│              Parser (Parser.hs)                  │
│  - Theshow.Parser (predeterminado)               │
│  - Lisp.Parser (alternativo)                     │
└────────────────────┬────────────────────────────┘
                     │
                     ▼ produce SExpr
┌─────────────────────────────────────────────────┐
│           SExpr → AST (AST.hs)                   │
│  - función sexprToAST                            │
│  - Convierte S-expressions a AST tipado          │
└────────────────────┬────────────────────────────┘
                     │
                     ▼ produce Ast
┌─────────────────────────────────────────────────┐
│       Análisis del compilador (Compiler.hs)      │
│  - collectVarTypes                               │
│  - collectFunctionNames                          │
│  - collectGlobalConsts                           │
│  - inlineGlobalConsts                            │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
          ┌──────────┴──────────┐
          │                     │
          ▼                     ▼
┌──────────────────┐  ┌──────────────────┐
│  Generación de   │  │  Generación ASM  │
│  Bytecode        │  │  x86-64          │
│ (Bytecode.hs)    │  │  (Compiler.hs)   │
│                  │  │                  │
│ archivo .o       │  │  archivo .o      │
│ bytecode         │  │  objeto          │
└──────────────────┘  └──────────────────┘
          │                     │
          ▼                     ▼
┌──────────────────┐  ┌──────────────────┐
│  Ejecución VM    │  │  Ejecución Nativa│
│    (VM.hs)       │  │  (vía enlazador) │
└──────────────────┘  └──────────────────┘
```

### Responsabilidades de los módulos

| Módulo | Propósito |
|--------|-----------|
| **Parser.hs** | Selecciona entre parsers TheShow y Lisp, convierte fuente a SExpr |
| **Theshow.Parser** | Parsea sintaxis TheShow (predeterminado) |
| **Lisp.Parser** | Parsea sintaxis S-expression Lisp |
| **AST.hs** | Define tipos AST, convierte SExpr a Ast, contiene evaluador |
| **Compiler.hs** | Lógica de compilación principal, análisis, generación bytecode/ensamblador |
| **Bytecode.hs** | Definiciones de instrucciones bytecode y serialización |
| **VM.hs** | Motor de ejecución de bytecode |
| **Loader.hs** | Carga y decodifica archivos bytecode, guarda bytecode |

---

## Pipeline de compilación

### Flujo de compilación completo

```
1. Archivo fuente (.tslang)
        ↓
2. Selección del parser (TheShow/Lisp)
        ↓
3. Análisis léxico → Tokens
        ↓
4. Análisis sintáctico → SExpr
        ↓
5. Análisis semántico → AST
        ↓
6. Recolección e inferencia de tipos
        ↓
7. Pases de optimización
   - Inlining de constantes globales
   - Eliminación de código muerto
   - Plegado de constantes
        ↓
8. Generación de código
   ├─→ Bytecode (.o para VM)
   └─→ Ensamblador (.s → .o para nativo)
        ↓
9. Salida
   ├─→ Ejecución VM
   └─→ Enlazado y Ejecución nativa
```

### Fases de compilación

#### Fase 1: Parsing

**Entrada**: Cadena de código fuente  
**Salida**: `[SExpr]` (lista de S-expressions)

```haskell
-- Parser.hs - Selección de parser en tiempo de ejecución
parseSExprMultipleEither :: String -> Either String [SExpr]
```

El parser convierte código fuente sin procesar en S-expressions. Hay dos parsers disponibles:

- **Parser TheShow** (predeterminado): Sintaxis personalizada para TSL
- **Parser Lisp**: Sintaxis S-expression Lisp tradicional

Ejemplo:
```
Fuente:   fun add(x: int, y: int) int { return x + y }
SExpr:    (fun add ((x int) (y int)) int ((return (+ x y))))
```

#### Fase 2: Construcción del AST

**Entrada**: `[SExpr]`  
**Salida**: `Ast`

```haskell
-- AST.hs
sexprToAST :: SExpr -> Either String Ast
```

Convierte S-expressions en un árbol de sintaxis abstracta fuertemente tipado:

- Valida estructura sintáctica
- Construye nodos AST con tipos apropiados
- Informa errores de sintaxis con contexto

#### Fase 3: Análisis de tipos

**Entrada**: `Ast`  
**Salida**: `Map.Map String Type` (mapa de tipos de variables)

```haskell
collectVarTypes :: Ast -> Map.Map String Type -> Map.Map String Type
```

Analiza el AST para recolectar información de tipos:

- Declaraciones de tipos explícitas de nodos `Define`
- Inferencia de tipos desde asignaciones y expresiones
- Manejo especial para arrays, cadenas y structs

#### Fase 4: Optimización

Múltiples pases de optimización transforman el AST:

**Inlining de constantes globales**:
```haskell
collectGlobalConsts :: Ast -> Map.Map String Ast
inlineGlobalConsts :: Map.Map String Ast -> Ast -> Ast
```

Reemplaza referencias a globales constantes en tiempo de compilación con sus valores:

```
Antes: eric PI: float = 3.14159
       eric area: float = PI * r * r

Después: eric area: float = 3.14159 * r * r
```

#### Fase 5: Generación de código

Dos backends generan diferentes formatos de salida:

**Backend Bytecode**:
```haskell
astToInstructions :: Ast -> [Instruction]
compileToBytecodeFile :: FilePath -> Ast -> IO ()
```

**Backend Ensamblador**:
```haskell
emitASM :: Ast -> String
compileToObject :: FilePath -> Ast -> IO ()
```

---

## Árbol de Sintaxis Abstracta (AST)

### Tipos de nodos AST

El tipo de datos `Ast` representa todas las construcciones del lenguaje:

```haskell
data Ast
  -- Definiciones y Variables
  = Define String (Maybe Type) Ast          -- Definición de variable/función
  | AstSymbol String                         -- Referencia de variable
  | Assign String Ast                        -- Asignación de variable
  
  -- Literales
  | AstInt Int                              -- Literal entero
  | AstFloat Double                          -- Literal flotante
  | AstBool Bool                            -- Literal booleano
  | AstString String                         -- Literal cadena
  | AstChar Char                            -- Literal carácter
  | AstVoid                                 -- Valor void/unit
  
  -- Funciones y Closures
  | AstLambda [String] Ast                  -- Lambda/función (params, cuerpo)
  | AstClosure [String] Ast Env             -- Closure con entorno capturado
  | Call Ast [Ast]                          -- Llamada a función
  | Return Ast                              -- Instrucción return
  
  -- Flujo de control
  | IfElse Ast Ast Ast                      -- if-then-else
  | While Ast Ast                           -- bucle while
  | For String Ast Ast                      -- bucle for (var, rango, cuerpo)
  | Break                                   -- Instrucción Break
  | Continue                                -- Instrucción Continue
  
  -- Colecciones
  | AstList [Ast]                           -- Lista de expresiones
  | Block [Ast]                             -- Bloque de instrucciones
  | ArrayAccess Ast Ast                     -- array[index]
  | ArrayAssign String Ast Ast              -- array[index] = value
  
  -- Estructuras
  | Struct String [(String, Type)]          -- Definición de estructura
  | StructFieldAssign String String Ast     -- struct.field = value
  | TypedVar String Type Ast                -- Declaración de variable tipada
  
  deriving (Show, Eq)
```

---

## Sistema de tipos

### Definiciones de tipos

```haskell
data Type
  = TInt              -- Entero con signo de 32 bits
  | TFloat            -- Float de doble precisión
  | TBool             -- Booleano (verdadero/falso)
  | TString           -- Cadena (terminada en null)
  | TChar             -- Carácter único
  | TVoid             -- Tipo void/unit
  | TCustom String    -- Tipos personalizados (arrays, structs)
  deriving (Show, Eq)
```

### Reglas de inferencia de tipos

El compilador infiere tipos basándose en:

1. **Declaraciones explícitas**:
   ```
   eric x: int = 42         → x: TInt
   eric name: string = ""   → name: TString
   ```

2. **Tipos de literales**:
   ```
   42       → TInt
   3.14     → TFloat
   "hello"  → TString
   'c'      → TChar
   true     → TBool
   ```

3. **Tipos de expresiones**:
   ```
   x + y    → TInt (si ambos x, y son TInt)
   x + "!"  → TString (si alguno es TString)
   x < y    → TBool
   ```

---

## Integración del parser

### Selección del parser

El compilador soporta dos parsers mediante flag de ejecución:

```haskell
-- Parser.hs
setUseLisp :: Bool -> IO ()

-- Predeterminado: Parser TheShow
parseSExprMultipleEither :: String -> Either String [SExpr]

-- Usando Parser Lisp
setUseLisp True
parseSExprMultipleEither :: String -> Either String [SExpr]
```

### Sintaxis TheShow (predeterminada)

TheShow proporciona sintaxis similar a C:

```c
// Declaración de variable
eric x: int = 42

// Definición de función
fun add(x: int, y: int) int {
  return x + y
}

// Estructuras de control
if x < 10 {
  peric("Pequeño")
} else {
  peric("Grande")
}

// Bucles
for i in range(0, 10) {
  peric(i)
}

while x > 0 {
  assign x (x - 1)
}
```

### Sintaxis Lisp (alternativa)

Sintaxis S-expression tradicional:

```lisp
; Declaración de variable
(eric x int 42)

; Definición de función
(fun add ((x int) (y int)) int
  ((return (+ x y))))

; Estructuras de control
(if (< x 10)
  ((peric "Pequeño"))
  ((peric "Grande")))

; Bucles
(aer i (range 0 10)
  ((peric i)))

(darius (> x 0)
  ((assign x (- x 1))))
```

---

## Análisis de código y optimización

### Recolección de tipos de variables

```haskell
collectVarTypes :: Ast -> Map.Map String Type -> Map.Map String Type
```

Recorre el AST para construir un mapa de tipos completo:

**Proceso**:
1. Escanea todos los nodos `Define` para anotaciones de tipos explícitas
2. Infiere tipos desde asignaciones y expresiones
3. Maneja casos especiales (funciones integradas, tipos de arrays)
4. Analiza recursivamente cuerpos de funciones

### Recolección de nombres de funciones

```haskell
collectFunctionNames :: Ast -> [String]
```

Extrae todas las definiciones de funciones para validación de llamadas.

### Mapeo de variables locales

```haskell
buildLocalMap :: Ast -> Map.Map String Type -> Map.Map String Int
```

Crea mapa de offset de pila para variables locales:

**Algoritmo**:
1. Recolecta todos los nombres de variables locales
2. Calcula tamaño requerido para cada variable:
   - Variables regulares: 8 bytes
   - Arrays: 4096 bytes (predeterminado)
   - Casos especiales (ej: "memo"): tamaño personalizado
3. Asigna offsets de pila desde RBP

---

## Backends de generación de código

### Backend Bytecode

Genera bytecode para la Máquina Virtual GLaDOS.

#### Generación de instrucciones

```haskell
astToInstructions :: Ast -> [Instruction]
```

**Reglas de compilación**:

| Nodo AST | Bytecode |
|----------|----------|
| `AstInt n` | `PUSH n` |
| `AstBool True` | `PUSH_TRUE` |
| `AstBool False` | `PUSH_FALSE` |
| `AstString s` | `LOAD_CONST s` |
| `Call (AstSymbol "+") [a,b]` | `[código a] [código b] ADD` |
| `Call (AstSymbol "-") [a,b]` | `[código a] [código b] SUB` |
| `Return v` | `[código v] RET` |

### Backend ensamblador x86-64

Genera ensamblador x86-64 nativo para sistemas Linux.

#### Pipeline de generación de ensamblador

```haskell
emitASM :: Ast -> String
```

**Proceso**:
1. **Optimización**: Inlinea constantes globales
2. **Análisis**: Recolecta tipos, funciones, cadenas
3. **Sección data**: Emite constantes de cadenas
4. **Sección text**: Emite funciones y main
5. **Built-ins**: Añade implementaciones de funciones integradas

#### Uso de registros

**Paso de parámetros** (System V AMD64 ABI):
- 1er parámetro: `%rdi`
- 2do parámetro: `%rsi`
- 3er parámetro: `%rdx`
- 4to parámetro: `%rcx`
- 5to parámetro: `%r8`
- 6to parámetro: `%r9`

**Valor de retorno**: `%rax`

---

## Gestión de memoria

### Diseño de la pila

El compilador usa gestión de memoria basada en pila para variables locales:

```
Dirección alta
┌─────────────────┐
│ Dirección de    │
│ retorno         │
├─────────────────┤  ← RBP (puntero de frame)
│  RBP previo     │
├─────────────────┤
│  Variable loc 1 │  RBP - 8
├─────────────────┤
│  Variable loc 2 │  RBP - 16
├─────────────────┤
│  Buffer array   │  RBP - 4112
│  (4096 bytes)   │
├─────────────────┤  ← RSP (puntero de pila)
│  ...            │
Dirección baja
```

### Almacenamiento de variables

**Variables regulares** (8 bytes):
- Enteros: 64 bits con signo
- Punteros: direcciones de 64 bits
- Booleanos: 64 bits (0 o 1)

**Arrays**:
- Tamaño predeterminado: 4096 bytes (512 quadwords)
- Almacenados inline en frame de pila
- Acceso vía puntero base + offset

**Cadenas**:
- Asignadas en heap vía `malloc`
- Puntero almacenado en pila
- Gestionadas por funciones integradas

---

## Funciones integradas

El compilador incluye varias funciones integradas implementadas en ensamblador.

### renaud - Leer archivo

**Firma**: `renaud(filename: string) -> string`

**Propósito**: Leer contenido completo de archivo en una cadena

### romaric - Leer línea

**Firma**: `romaric(prompt: string) -> string`

**Propósito**: Mostrar prompt y leer línea desde stdin

### marvin - Escribir archivo

**Firma**: `marvin(filename: string, content: string) -> void`

**Propósito**: Escribir contenido de cadena a archivo

### str_concat - Concatenación de cadenas

**Firma**: `str_concat(s1: string, s2: string) -> string`

**Propósito**: Concatenar dos cadenas en buffer recién asignado

### peric - Imprimir (implícito)

La función `peric` usa `printf` con interpolación de cadena de formato.

---

## Manejo de errores

### Errores en tiempo de compilación

El compilador detecta y reporta varios errores:

#### Variable indefinida
```c
assign x 42  // Error: Variable indefinida 'x'
```

#### Función indefinida
```c
foo(10)  // Error: Función indefinida 'foo'
```

#### Incompatibilidad de tipos

Errores de tipos se detectan durante generación de código:

```c
eric x: int = 42
assign x "string"  // Error: Incompatibilidad de tipos (int vs string)
```

### Errores del parser

Errores de sintaxis desde el parser:

```
Entrada: fun add(x: int { return x }
Error: Error de parseo: Paréntesis no emparejados
```

---

## Ejemplos de uso

### Compilar a Bytecode

**Comando**:
```bash
glados -c program.tslang -o program.o
```

**Ejecutar**:
```bash
glados program.o
```

### Compilar a ensamblador nativo

**Comando**:
```bash
glados program.tslang -o program.o --native
```

**Enlazar y ejecutar**:
```bash
gcc program.o -o program
./program
```

### Programa de ejemplo

**Fuente** (`factorial.tslang`):
```c
fun factorial(n: int) int {
  if n <= 1 {
    return 1
  }
  return n * factorial(n - 1)
}

fun Eric() void {
  eric result: int = factorial(5)
  peric("Factorial de 5 es: ", result)
}
```

**Compilar a Bytecode**:
```bash
glados -c factorial.tslang -o factorial.o
glados factorial.o
```

**Salida**:
```
Factorial de 5 es: 120
```

---

## Consideraciones de rendimiento

### Estrategias de optimización

1. **Plegado de constantes**: Evalúa expresiones constantes en tiempo de compilación
2. **Eliminación de código muerto**: Elimina código inalcanzable
3. **Inlining de constantes globales**: Reemplaza variables constantes con literales
4. **Asignación de registros**: Minimiza accesos a memoria en ensamblador
5. **Optimización de llamadas recursivas de cola** (planificado): Optimiza llamadas recursivas

### Bytecode vs Nativo

**Ventajas del Bytecode**:
- Compilación rápida
- Portable entre plataformas
- Depuración fácil
- Tamaño de archivo pequeño

**Ventajas del ensamblador nativo**:
- Ejecución 10-100x más rápida
- Acceso directo al hardware
- Sin sobrecarga de intérprete
- Potencial completo de optimización

### Tiempo de compilación

Tiempos de compilación típicos (en hardware moderno):

| Líneas de código | Bytecode | Ensamblador nativo |
|------------------|----------|-------------------|
| 100              | <10ms    | ~50ms             |
| 1000             | ~50ms    | ~200ms            |
| 10000            | ~500ms   | ~2s               |

### Rendimiento en tiempo de ejecución

**Bytecode**:
- Aritmética simple: ~1 μs por operación
- Llamada de función: ~1 μs por llamada
- Acceso a array: ~0.5 μs

**Ensamblador nativo**:
- Aritmética simple: ~1 ns por operación
- Llamada de función: ~10 ns por llamada
- Acceso a array: ~5 ns

---

## Mejoras futuras

1. **Verificación de tipos**: Verificación de tipos estática completa antes de generación de código
2. **Backend LLVM**: Generar LLVM IR para optimización máxima
3. **Sistema de módulos**: Soporte para múltiples archivos e importaciones
4. **Genéricos**: Funciones y estructuras de datos genéricas
5. **Pattern matching**: Construcciones avanzadas de flujo de control
6. **Recolección de basura**: Gestión automática de memoria para asignaciones en heap
7. **Compilación incremental**: Solo recompilar funciones cambiadas
8. **Símbolos de depuración**: Información de depuración DWARF para código nativo
9. **Advertencias**: Advertencias estilo lint para código sospechoso
10. **Niveles de optimización**: Flags -O0, -O1, -O2, -O3

---

## Referencias

- [Módulo Bytecode](../../src/Bytecode.hs) - Definiciones de instrucciones
- [Módulo VM](../../src/VM.hs) - Motor de ejecución de bytecode
- [Módulo AST](../../src/AST.hs) - Definiciones de árbol de sintaxis abstracta
- [Módulo Parser](../../src/Parser.hs) - Selección e integración del parser
- [Documentación técnica VM](TECHNICAL_VM.md) - Detalles de la máquina virtual
- [Guía del usuario](user_guide.md) - Documentación para el usuario final
- [Referencia del lenguaje](tsl_language_reference.md) - Especificación del lenguaje TSL

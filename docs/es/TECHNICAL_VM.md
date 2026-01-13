# Máquina Virtual - Documentación Técnica

## Tabla de Contenidos

- [Descripción General](#descripción-general)
- [Arquitectura de la VM](#arquitectura-de-la-vm)
- [Formato del Bytecode](#formato-del-bytecode)
- [Conjunto de Instrucciones](#conjunto-de-instrucciones)
- [Modelo de Ejecución](#modelo-de-ejecución)
- [Gestión de Memoria](#gestión-de-memoria)
- [Pila de Llamadas y Funciones](#pila-de-llamadas-y-funciones)
- [Detalles de Implementación](#detalles-de-implementación)
- [Consideraciones de Rendimiento](#consideraciones-de-rendimiento)

---

## Descripción General

La Máquina Virtual (VM) de GLaDOS es un intérprete basado en pila diseñado para ejecutar bytecode compilado del lenguaje TheShowLang (TSL). Proporciona un entorno de ejecución eficiente con soporte para:

- **Operaciones aritméticas y de comparación básicas**
- **Control de flujo con saltos condicionales e incondicionales**
- **Llamadas a funciones con closures y entornos capturados**
- **Gestión de variables locales y globales**
- **Manejo de cadenas y constantes**
- **Operaciones de salida (PRINT)**

La VM está implementada en Haskell e está estrechamente integrada con el backend del compilador de bytecode.

### Principios de Diseño Clave

1. **Arquitectura Basada en Pila**: Todas las operaciones utilizan una pila para pasar operandos
2. **Conjunto de Instrucciones Simple**: Conjunto mínimo y ortogonal de instrucciones
3. **Soporte de Closures**: Funciones de primera clase con alcance léxico
4. **Seguridad de Tipos**: El sistema de tipos de Haskell garantiza seguridad de memoria

---

## Arquitectura de la VM

### Componentes Principales

#### 1. Tipo VMValue

Representa valores en tiempo de ejecución en la VM:

```haskell
data VMValue
  = VMInt Int32              -- enteros con signo de 32 bits
  | VMBool Bool              -- valores booleanos (#t, #f)
  | VMString String          -- literales de cadena
  | VMClosure Int32 Int32 [VMValue]  -- closures con entorno capturado
  | VMVoid                   -- valor unitario/void
  deriving (Show, Eq)
```

#### 2. Estructura CallFrame

Gestiona el contexto de la llamada a función:

```haskell
data CallFrame = CallFrame
  { returnAddress :: Int
  , savedLocals   :: [VMValue]
  } deriving (Show)
```

Cada marco de llamada almacena:
- **returnAddress**: Contador de programa para reanudar después del retorno de función
- **savedLocals**: Estado de variables locales antes de la llamada

#### 3. Tipo VMState

Estado de ejecución completo:

```haskell
data VMState = VMState
  { stack     :: [VMValue]              -- pila de operandos
  , pc        :: Int                    -- contador de programa
  , callStack :: [CallFrame]            -- marcos de llamada para retornos de función
  , globals   :: Map.Map String VMValue -- variables globales
  , locals    :: [VMValue]              -- variables locales (marco actual)
  , program   :: [Instruction]          -- instrucciones de bytecode
  , halted    :: Bool                   -- bandera de detención de ejecución
  , outputs   :: [String]               -- salida acumulada
  } deriving (Show)
```

---

## Formato del Bytecode

### Estructura del Formato Binario

Los archivos de bytecode (extensión `.o`) utilizan la siguiente estructura:

```
┌─────────────────────────────────────────┐
│ Número Mágico: "GLO\0" (4 bytes)        │
├─────────────────────────────────────────┤
│ Versión: 0x01 (1 byte)                  │
├─────────────────────────────────────────┤
│ Instrucciones (longitud variable)       │
│   [Opcode] [Operandos] [Opcode] ...     │
├─────────────────────────────────────────┤
│ Instrucción HALT (0xFF) al final        │
└─────────────────────────────────────────┘
```

### Codificación de Instrucciones

Cada instrucción comienza con un opcode de un byte seguido de cero o más operandos:

- **Instrucciones sin operandos**: 1 byte (p.ej. ADD, POP)
- **Operandos Int32**: 4 bytes en formato little-endian (p.ej. PUSH, JUMP)
- **Operandos de cadena**: Prefijo de longitud de 4 bytes + datos de cadena (p.ej. LOAD_GLOBAL)

### Carga de Archivos ELF

Para archivos ELF, la VM extrae la sección `.text`:

1. Valida el número mágico ELF (0x7F 0x45 0x4C 0x46)
2. Localiza encabezados de sección
3. Extrae la sección `.text` que contiene el bytecode
4. Decodifica instrucciones de la sección extraída

---

## Conjunto de Instrucciones

### Referencia Completa de Instrucciones

| Opcode | Instrucción       | Operandos | Efecto Pila | Descripción |
|--------|-------------------|-----------|------------|-------------|
| 0x01   | PUSH              | Int32     | → [n]        | Empuja constante entera |
| 0x02   | POP               | ninguno   | [v] →        | Extrae elemento superior |
| 0x03   | ADD               | ninguno   | [b,a] → [a+b]| Suma dos enteros |
| 0x04   | SUB               | ninguno   | [b,a] → [a-b]| Resta enteros |
| 0x05   | MUL               | ninguno   | [b,a] → [a*b]| Multiplica enteros |
| 0x06   | DIV               | ninguno   | [b,a] → [a/b]| División de enteros (b≠0) |
| 0x07   | MOD               | ninguno   | [b,a] → [a%b]| Operación módulo (b≠0) |
| 0x08   | LT                | ninguno   | [b,a] → [a<b]| Comparación menor que |
| 0x09   | EQ                | ninguno   | [b,a] → [a==b]| Comparación igualdad |
| 0x0A   | JUMP              | Int32     | (pc)         | Salto incondicional a dirección |
| 0x0B   | JUMP_IF_FALSE     | Int32     | [v] →        | Salta si superior es #f |
| 0x0C   | CALL              | Int32     | (pila)       | Llama función en dirección |
| 0x0D   | RET               | ninguno   | [v] → v      | Retorna de función |
| 0x0E   | LOAD_VAR          | Int32     | → [v]        | Carga variable local |
| 0x0F   | STORE_VAR         | Int32     | [v] →        | Almacena en variable local |
| 0x10   | LOAD_GLOBAL       | String    | → [v]        | Carga variable global |
| 0x11   | STORE_GLOBAL      | String    | [v] →        | Almacena en variable global |
| 0x12   | MAKE_CLOSURE      | Int32 Int32 | → [closure] | Crea closure con entorno capturado |
| 0x13   | PUSH_TRUE         | ninguno   | → [#t]       | Empuja booleano verdadero |
| 0x14   | PUSH_FALSE        | ninguno   | → [#f]       | Empuja booleano falso |
| 0x15   | PRINT             | ninguno   | [v] →        | Imprime valor y almacena salida |
| 0x16   | LOAD_CONST        | String    | → [s]        | Carga constante de cadena |
| 0xFF   | HALT              | ninguno   | (detiene)    | Detiene ejecución |

### Restricciones de Tipo

La VM impone la corrección de tipos en las operaciones:

- **Operaciones aritméticas (ADD, SUB, MUL, DIV, MOD)**: Ambos operandos deben ser `VMInt`
- **Comparaciones (LT, EQ)**: Los operandos deben ser de tipos compatibles
- **Saltos condicionales (JUMP_IF_FALSE)**: El operando debe ser `VMBool`
- **Errores de tipo**: Resultan en `Left String` con descripción

---

## Modelo de Ejecución

### Operación Basada en Pila

La VM opera en una pila LIFO (Last In, First Out). La mayoría de operaciones extraen operandos de la cima e emplazan resultados de vuelta:

```
Ejemplo: Calcular (2 + 3) * 4

Inicial:        []
PUSH 2:         [2]
PUSH 3:         [2, 3]
ADD:            [5]
PUSH 4:         [5, 4]
MUL:            [20]
```

### Contador de Programa y Secuenciación

Las instrucciones se ejecutan secuencialmente a menos que se encuentre una instrucción de control de flujo:

- **Flujo normal**: El CP se incrementa por el tamaño de la instrucción
- **JUMP addr**: El CP se establece directamente a `addr`
- **JUMP_IF_FALSE addr**: Rama condicional basada en elemento superior
- **CALL addr**: Salto con marco de llamada empujado
- **RET**: Extrae marco de llamada y salta a dirección de retorno

### Bucle de Ejecución

```haskell
execBytecode :: VMState -> (Either String VMValue, [String])
execBytecode state
  | halted state = getResult state
  | pc fuera de limites = error "PC fuera de limites"
  | otherwise = case step state (program !! pc) of
      Left err      → return error
      Right newState → execBytecode newState
```

La ejecución continúa hasta que:
1. Se ejecuta la instrucción `HALT`
2. Ocurre un error
3. El contador de programa sale de limites

### Función Step

La función `step` implementa cada instrucción:

```haskell
step :: VMState → Instruction → Either String VMState
```

Retorna:
- **Left msg**: Condición de error
- **Right state**: Estado VM actualizado listo para siguiente instrucción

---

## Gestión de Memoria

### Pila

La pila de operandos almacena elementos `VMValue`:
- Crece/se encoge dinámicamente a medida que se emplazan/extraen valores
- Extracción en pila vacía en POP/operaciones aritméticas retorna error
- Sin límite de tamaño fijo

### Variables Locales

Las variables locales se almacenan en una lista indexada por ID de variable:

```haskell
LOAD_VAR 0    -- Carga primera variable local
STORE_VAR 1   -- Almacena en segunda variable local
```

El acceso es verificado por limites; índices inválidos producen errores.

### Variables Globales

Las variables globales utilizan `Map.Map String VMValue` para búsqueda por nombre:

```haskell
LOAD_GLOBAL "x"    -- Carga variable global "x"
STORE_GLOBAL "y"   -- Almacena en variable global "y"
```

Lecturas de variables globales indefinidas producen error "variable global indefinida".

### Pool de Constantes

Las constantes de cadena utilizan la instrucción `LOAD_CONST`:

```haskell
LOAD_CONST "¡Hola, Mundo!"
PRINT
```

### Ejemplo de Distribución de Memoria

```
Marco 1 (función externa)
├─ locals = [100, "hola"]
├─ callStack = []
└─ stack = [42]

Marco 2 (después de llamada de función)
├─ locals = [10, 20, 30]      (locals del nuevo marco)
├─ callStack = [CallFrame {returnAddress: 50, savedLocals: [100, "hola"]}]
└─ stack = [42, ...]
```

---

## Pila de Llamadas y Funciones

### Mecanismo de Llamada a Función

#### Instrucción CALL

```haskell
CALL addr  -- Llama función en dirección addr
```

Ejecución:
1. Crea `CallFrame` con CP+1 actual (dirección de retorno) y locals actuales
2. Emplaza marco en `callStack`
3. Establece CP a `addr`
4. Continúa ejecución

#### Instrucción RET

```haskell
RET  -- Retorna de función
```

Ejecución:
1. Extrae marco de llamada superior
2. Restaura dirección de retorno del marco
3. Restaura locals del marco
4. Establece CP a dirección de retorno
5. Mantiene valor de retorno en pila

### Soporte de Closures

#### Instrucción MAKE_CLOSURE

Crea closure con entorno capturado:

```haskell
MAKE_CLOSURE addr nparams
```

Crea `VMClosure addr nparams capturedEnv` donde:
- **addr**: Dirección de bytecode del código de función
- **nparams**: Número de parámetros
- **capturedEnv**: Variables locales actuales (alcance léxico)

#### Llamada de Closure

Al llamar una closure:
1. Los argumentos se toman de la pila
2. Nuevas variables locales = argumentos + entorno capturado
3. La función se ejecuta con locals combinados
4. El retorno extrae el marco y restaura los locals del llamador

### Ejemplo: Closure con Variables Capturadas

```
PUSH 100           -- valor externo
STORE_VAR 0        -- locals = [100]
PUSH 5             -- nparams
PUSH 10            -- dirección de función
MAKE_CLOSURE       -- captura locals = [100]
                   -- stack = [VMClosure(10, 5, [VMInt 100])]

CALL addr          -- llama closure
                   -- new locals = [args...] + [100]
                   -- puede acceder al 100 capturado
```

---

## Detalles de Implementación

### Manejo de Errores

La VM utiliza `Either String` para propagación de errores:

```haskell
step :: VMState → Instruction → Either String VMState
```

Casos de error comunes:
- **Extracción en pila vacía**: No hay suficientes operandos
- **Error de tipo**: Tipos de operandos incorrectos para operación
- **División por cero**: DIV/MOD con divisor cero
- **Fuera de limites**: Salto/acceso variable fuera de limites
- **Variable indefinida**: Variable global no existe

### Procesamiento de Salida

La instrucción PRINT acumula salida:

```haskell
outputs :: [String]  -- cadenas de salida acumuladas
```

La salida se preserva durante la ejecución y se retorna como segundo elemento del tupla resultado:

```haskell
runVM :: [Instruction] → (Either String VMValue, [String])
```

### Decodificación de Instrucciones

Decodificación de bytecode binario:

```haskell
decodeProgram :: ByteString → Either String [Instruction]
decodeProgram bs = go bs []
  where
    go b acc
      | null b = Right (reverse acc)
      | otherwise = case decodeOpcode (primer byte) of
          Just decoder → decoder resto
          Nothing → Left "Opcode desconocido"
```

Cada decodificador de instrucción:
- Toma el `ByteString` restante
- Analiza operandos específicos del opcode
- Retorna `(Instruction, bytes restantes)` o error

### Codificación de Cadena

Las cadenas utilizan formato prefijado por longitud:

```
[Longitud: 4 bytes LE] [datos de cadena UTF-8]

Ejemplo: "Hola" → 04 00 00 00 48 6F 6C 61
         ^Longitud  ^datos de cadena
```

### Codificación Int32

Todos los operandos enteros utilizan formato 32 bits little-endian:

```
1234 → 0xD2 0x04 0x00 0x00  (en memoria/archivo)
```

---

## Consideraciones de Rendimiento

### Oportunidades de Optimización

1. **Caché de Instrucciones**: Pre-analizar instrucciones para evitar decodificación repetida
2. **Optimización de Bytecode**:
   - Plegamiento de constantes
   - Eliminación de código muerto
   - Inlining de destino de salto
3. **Optimizaciones de Máquina de Pila**:
   - Asignación de registros para valores frecuentemente utilizados
   - Agrupamiento de marcos de pila
4. **Compilación JIT**: Compilar rutas de código hot a código nativo

### Limitaciones Actuales

- **Sin Optimización de Llamada Terminal**: Funciones recursivas pueden desbordar la pila de llamadas
- **Búsqueda Lineal de Instrucciones**: Sin caché de instrucciones
- **Copia de Cadena**: Todas las operaciones de cadena implican copias de memoria
- **Sin Garbage Collection**: Los closures retienen el entorno capturado

### Benchmarking

Métricas de rendimiento típicas:
- Aritmética simple: ~10-100 μs
- Overhead de llamada de función: ~1 μs por marco
- Operación PRINT: ~10 μs por llamada

---

## Integración con el Compilador

### Flujo de Generación de Bytecode

```
Fuente TSL
    ↓
Analizador (sintaxis Theshow/Lisp)
    ↓
AST (Árbol de Sintaxis Abstracta)
    ↓
Compilador (AST → Instrucciones)
    ↓
Bytecode.hs (serializar a binario)
    ↓
archivo .o (bytecode)
    ↓
VM.hs (execBytecode)
    ↓
Resultado + Salida
```

### Compilación a Bytecode

El compilador traduce nodos AST a instrucciones:

```haskell
-- Ejemplo: (+ 2 3) compila a:
PUSH 2
PUSH 3
ADD
```

---

## Depuración y Solución de Problemas

### Mensajes de Error en Tiempo de Ejecución

La VM proporciona mensajes de error detallados:

```
"Extracción en pila vacía en POP"
"Error de tipo en ADD"
"División por cero"
"Dirección de salto fuera de limites"
"Variable global indefinida: x"
```

### Desensamblado de Bytecode

El módulo Loader proporciona desensamblado:

```bash
glados -d programa.o
```

Produce formato de bytecode legible por humanos.

### Pruebas

Pruebas unitarias para operaciones VM en `test/Spec.hs`:
- Operaciones aritméticas
- Control de flujo
- Llamadas a función
- Gestión de variables
- Manejo de closures

---

## Extensiones Futuras

1. **Anotaciones de Tipo en Bytecode**: Mejores mensajes de error
2. **Garbage Collection**: Para entornos de closure
3. **Sistema de Módulos**: Múltiples archivos de bytecode
4. **Depurador**: Ejecución paso a paso, puntos de interrupción
5. **Perfilado de Memoria**: Seguimiento de patrones de asignación

---

## Referencias

- [Módulo Bytecode](../src/Bytecode.hs)
- [Módulo VM](../src/VM.hs)
- [Módulo Loader](../src/Loader.hs)
- [Aplicación Principal](../app/Main.hs)

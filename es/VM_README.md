# VM y archivos .o - Guía de uso

## Vista general

Su proyecto GLaDOS ahora puede compilar y ejecutar archivos bytecode `.o` gracias a una máquina virtual integrada.

## Arquitectura

### Módulos creados

1. **Bytecode.hs** - Define el conjunto de instrucciones de la VM
2. **VM.hs** - Máquina virtual para ejecutar el bytecode
3. **Loader.hs** - Carga y guarda los archivos .o
4. **Main.hs** (modificado) - Soporte de la ejecución de archivos .o

### Formato de los archivos .o

Los archivos `.o` son archivos binarios con el formato siguiente:

- **Magic number**: `GLO\0` (4 octetos)
- **Version**: `0x01` (1 octeto)
- **Instrucciones**: Secuencia de opcodes y sus argumentos

## Juego de instrucciones

La VM soporta las instrucciones siguientes:

| Opcode | Instruction   | Description                         |
| ------ | ------------- | ----------------------------------- |
| 0x01   | PUSH n        | Apila un valor entero               |
| 0x02   | POP           | Desapila un valor                   |
| 0x03   | ADD           | Adición de los dos valores de la cima |
| 0x04   | SUB           | Sustracción                         |
| 0x05   | MUL           | Multiplicación                      |
| 0x06   | DIV           | División                            |
| 0x07   | MOD           | Modulo                              |
| 0x08   | LT            | Comparación <                       |
| 0x09   | EQ            | Comparación ==                      |
| 0x0A   | JUMP          | Salto incondicional                 |
| 0x0B   | JUMP_IF_FALSE | Salto condicional                   |
| 0x0C   | CALL          | Llamada de función                  |
| 0x0D   | RET           | Retorno de función                  |
| 0x0E   | LOAD_VAR      | Cargar variable local               |
| 0x0F   | STORE_VAR     | Almacenar variable local            |
| 0x10   | LOAD_GLOBAL   | Cargar variable global              |
| 0x11   | STORE_GLOBAL  | Almacenar variable global           |
| 0x12   | MAKE_CLOSURE  | Crear una closure                   |
| 0x13   | PUSH_TRUE     | Apila verdadero                     |
| 0x14   | PUSH_FALSE    | Apila falso                         |
| 0xFF   | HALT          | Detener la ejecución                |

## Utilización

### Ejecutar un archivo .o

```bash
stack exec glados-exe fichier.o
```

o con el binario compilado:

```bash
./glados-exe fichier.o
```

### Desensamblar un archivo .o

Para ver el contenido de un archivo .o en formato legible:

```bash
stack exec glados-exe -- -d fichier.o
```

### Modo intérprete (original)

Sin argumento, glados lee desde stdin (modo original):

```bash
echo "(+ 2 3)" | stack exec glados-exe
```

## Ejemplos de archivos .o

Se proporcionan archivos de prueba:

- **test_add.o**: Adición simple (2 + 3) → 5
- **test_mul.o**: Multiplicación (4 \* 5) → 20
- **test_lt.o**: Comparación (3 < 5) → #t
- **test_complex.o**: Expresión compleja ((2 + 3) \* 4) → 20

### Ejecución de las pruebas

```bash
# Tester l'addition
stack exec glados-exe test_add.o
# Sortie: 5

# Tester la multiplication
stack exec glados-exe test_mul.o
# Sortie: 20

# Tester la comparaison
stack exec glados-exe test_lt.o
# Sortie: #t

# Tester l'expression complexe
stack exec glados-exe test_complex.o
# Sortie: 20
```

## Crear sus propios archivos .o

Utilice el generador de prueba para crear nuevos archivos .o:

```haskell
-- tools/generate_test_bytecode.hs
import Bytecode
import Loader
import qualified Bytecode as BC

myProgram :: [Instruction]
myProgram =
    [ PUSH 10
    , PUSH 5
    , SUB
    , HALT
    ]

main :: IO ()
main = saveBytecodeFile "my_program.o" myProgram
```

Luego ejecute:

```bash
stack runghc tools/generate_test_bytecode.hs
stack exec glados-exe my_program.o
```

## Detalles técnicos

### Estructura de la VM

La VM utiliza una arquitectura de pila (stack-based) con:

- **Stack**: Pila de ejecución para los valores
- **PC** (Program Counter): Puntero de instrucción
- **Call Stack**: Pila de llamadas para las funciones
- **Globals**: Variables globales
- **Locals**: Variables locales del frame actual

### Tipos de valores

La VM soporta:

- `VMInt`: Enteros de 32 bits
- `VMBool`: Booleanos
- `VMClosure`: Closures (funciones + entorno)
- `VMVoid`: Valor vacío

### Gestión de errores

La VM detecta y señala:

- División por cero
- Stack underflow
- Saltos fuera de límites
- Errores de tipado
- Variables no definidas

## Próximos pasos

Para completar la parte VM del proyecto, usted deberá:

1. **Crear un compilador** (AST → Bytecode) en un módulo `Compiler.hs`
2. **Añadir el soporte de las closures** y variables capturadas
3. **Implementar una biblioteca estándar** en bytecode
4. **Optimizar el bytecode** generado
5. **Documentar el proceso de compilación** (requisito para la defensa)

## Pruebas adicionales

Puede probar con su propio glados compilado en .o creando un archivo bytecode que reproduzca el comportamiento esperado de su lenguaje.

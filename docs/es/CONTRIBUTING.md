# Contribuir a GLADOS

¡Gracias por tu interés en contribuir a GLADOS! Este documento proporciona directrices e instrucciones para contribuir al proyecto.

## Tabla de contenido

- [Código de conducta](#código-de-conducta)
- [Primeros pasos](#primeros-pasos)
- [Flujo de trabajo de desarrollo](#flujo-de-trabajo-de-desarrollo)
- [Normas de codificación](#normas-de-codificación)
- [Directrices de commit](#directrices-de-commit)
- [Proceso de solicitud de extracción](#proceso-de-solicitud-de-extracción)
- [Reportar problemas](#reportar-problemas)

---

## Código de conducta

### Nuestras normas

- **Sé respetuoso**: Trata a todos con respeto y amabilidad
- **Sé constructivo**: Proporciona comentarios y sugerencias útiles
- **Sé colaborativo**: Trabaja en conjunto para mejorar el proyecto
- **Sé inclusivo**: Da la bienvenida a los colaboradores de todos los niveles

### Comportamiento inaceptable

- Acoso, discriminación o comentarios ofensivos
- Trolling, insultos o comentarios despectivos
- Publicación de información privada de otros
- Cualquier comportamiento inapropiado en un entorno profesional

---

## Primeros pasos

### Requisitos previos

1. **Instalar las herramientas requeridas**:
   - Git
   - GHC (Glasgow Haskell Compiler) >= 8.10
   - Stack (herramienta de construcción Haskell)
   - Make

2. **Haz un fork del repositorio** en GitHub

3. **Clona tu fork**:   ```bash
   git clone git@github.com:YOUR_USERNAME/GlaGla.git
   cd GlaGla
   ```

4. **Añadir un remote upstream** :
   ```bash
   git remote add upstream git@github.com:LaTableSurGit/GlaGla.git
   ```

5. **Instalar las dependencias** :
   ```bash
   stack setup
   stack build
   ```

### Familiarizarse

- Leer la [Documentación técnica](TECHNICAL.md)
- Recorrer la [Guía del usuario](user_guide.md)
- Verificar los [problemas existentes](https://github.com/LaTableSurGit/GlaGla/issues)
- Ejecutar los programas de ejemplo en `examples/`

---

## Flujo de trabajo de desarrollo

### 1. Crear una rama

Siempre crea una nueva rama para tu trabajo :

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

Conventions de nommage des branches :
- `feature/` - Nuevas funcionalidades
- `fix/` - Correcciones de errores
- `docs/` - Actualizaciones de la documentación
- `refactor/` - Refactorización del código
- `test/` - Adiciones/mejoras de pruebas

### 2. Realiza tus modificaciones

- Escribir un código limpio y legible
- Seguir las [normas de codificación](#normas-de-codificación)
- Agregar comentarios para la lógica compleja
- Actualizar la documentación si es necesario

### 3. Prueba tus modificaciones

```bash
# Run tests
make run_test

# Run style checker
./tools/tsl_style_checker.sh

# Test manually
./glados < examples/example1.tslang
```

### 4. Comprometerse con sus modificaciones

Siga las [directrices de commit](#directrices-de-commit):

```bash
git add .
git commit -m "feat: add new feature description"
```

### 5. Mantener su rama actualizada

```bash
# Fetch upstream changes
git fetch upstream

# Rebase on upstream main
git rebase upstream/main

# Or merge if you prefer
git merge upstream/main
```

### 6. Empujar y crear una PR

```bash
git push origin feature/your-feature-name
```

Ensuite, créez une Pull Request sur GitHub.

---

## Normas de codificación

### Estilo de código Haskell

#### Convenciones de nomenclatura

```haskell
-- Functions and variables: camelCase
parseExpression :: String -> Maybe Ast
currentValue :: Int

-- Types and constructors: PascalCase
data ExpressionType = IntType | BoolType
newtype Environment = Environment (Map String Value)

-- Constants: camelCase or UPPER_CASE for truly constant values
maxIterations :: Int
maxIterations = 1000
```

#### Formateo

```haskell
-- 4 spaces for indentation (no tabs)
myFunction :: Int -> String -> IO ()
myFunction count message = do
    putStrLn message
    if count > 0
        then do
            myFunction (count - 1) message
        else
            return ()

-- Line length: try to keep under 80 characters
-- Break long function signatures
longFunctionName 
    :: VeryLongTypeName 
    -> AnotherLongType 
    -> Maybe Result

-- Align list elements
myList = 
    [ element1
    , element2
    , element3
    ]

-- Use qualified imports for common modules
import qualified Data.Map as Map
import qualified Data.Set as Set
```

#### Documentación

```haskell
-- | Brief one-line description
--
-- Longer description with more details.
-- Can span multiple lines.
--
-- Arguments:
-- * First argument description
-- * Second argument description
--
-- Example:
-- >>> calculateSum [1, 2, 3]
-- 6
calculateSum :: [Int] -> Int
calculateSum = sum
```

#### Buenas prácticas

```haskell
-- Use explicit type signatures
goodFunction :: Int -> String
goodFunction x = show x

-- Avoid partial functions when possible
safeDivide :: Int -> Int -> Maybe Int
safeDivide _ 0 = Nothing
safeDivide x y = Just (x `div` y)

-- Use pattern matching
processResult :: Either String Int -> String
processResult (Left err) = "Error: " ++ err
processResult (Right val) = "Success: " ++ show val

-- Use let/where for readability
complexCalculation :: Int -> Int
complexCalculation x = result
  where
    intermediate = x * 2
    result = intermediate + 10

-- Prefer pure functions
-- Good: pure function
double :: Int -> Int
double x = x * 2

-- Avoid when possible: impure function with side effects
badPrintDouble :: Int -> IO Int
badPrintDouble x = do
    let result = x * 2
    print result  -- Side effect
    return result
```

### Estructura del módulo

```haskell
{-
-- EPITECH PROJECT, 2025
-- Module Name
-- File description:
-- Description of what this module does
-}

-- Module declaration with exports
module ModuleName (
    -- * Types
    MyType(..),
    OtherType,
    
    -- * Functions
    mainFunction,
    helperFunction
) where

-- Imports grouped and sorted
import Control.Monad (when, unless)
import Data.Maybe (fromMaybe)
import qualified Data.Map as Map

-- Type definitions
data MyType = Constructor1 | Constructor2

-- Function implementations
mainFunction :: Int -> String
mainFunction = undefined
```

---

## Directrices de commit

### Formato del mensaje de commit

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Tipo

- `feat` : Nueva funcionalidad
- `fix` : Corrección de errores
- `docs` : Solo documentación
- `style` : Formato, puntos y comas faltantes, etc.
- `refactor` : Reestructuración del código
- `test` : Adición o actualización de pruebas
- `chore` : Tareas de mantenimiento

### Ejemplos

```bash
# Simple feature
git commit -m "feat(parser): add support for hexadecimal literals"

# Bug fix with body
git commit -m "fix(vm): correct stack overflow in recursive calls

The call stack wasn't being properly managed when handling
deeply nested function calls. Added proper bounds checking."

# Breaking change
git commit -m "feat(ast)!: change function definition syntax

BREAKING CHANGE: Function definitions now require explicit
return type annotations."
```

### Mejores prácticas de commit

- **Mantener los commits atómicos**: Un cambio lógico por commit
- **Escribir mensajes claros**: Explicar qué y por qué, no cómo
- **Referenciar los problemas**: Incluir `#issue-number` en el mensaje de commit
- **Probar antes de commitear**: Asegurarse de que el código compile y que las pruebas pasen

---

## Proceso de solicitud de extracción

### Antes de enviar

- [ ] El código compila sin errores
- [ ] Todas las pruebas pasan (`make run_test`)
- [ ] El verificador de estilo pasa (`./tools/tsl_style_checker.sh`)
- [ ] Documentación actualizada (si aplica)
- [ ] Ejemplos actualizados (si se añaden nuevas funcionalidades)
- [ ] Los mensajes de commit siguen las directrices

### Plantilla de PR

Al crear una PR, incluir:

```markdown
## Description
Brève description des changements

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Changes Made
- List specific changes
- Be detailed but concise

## Testing
- Describe how you tested
- Include test cases added

## Screenshots (if applicable)
Add screenshots for UI changes

## Related Issues
Fixes #123
Relates to #456

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] Tests pass
- [ ] No new warnings
```

### Proceso de revisión

1. **Verificaciones automáticas**: CI/CD ejecuta pruebas y verificaciones de estilo
2. **Revisión de código**: Los mantenedores revisan tu código
3. **Comentarios**: Responder a todos los cambios solicitados
4. **Aprobación**: Una vez aprobada, tu PR será fusionada

### Responder a los comentarios

- Ser receptivo a los comentarios
- Realizar los cambios solicitados en nuevos commits
- Volver a solicitar una revisión después de los cambios
- Estar abierto a sugerencias y a la discusión

---

## Reporte de problemas

### Antes de crear un problema

1. **Buscar problemas existentes**: Tu problema puede que ya exista
2. **Verificar la documentación**: La respuesta podría estar en la documentación
3. **Reproducir el error**: Asegurarse de que sea consistente

### Plantilla de reporte de errores

```markdown
## Bug Description
Description claire et concise du bug

## To Reproduce
Steps to reproduce:
1. Run command '...'
2. Input '...'
3. See error

## Expected Behavior
What you expected to happen

## Actual Behavior
What actually happened

## Environment
- OS: [e.g., Ubuntu 22.04]
- GHC version: [e.g., 9.0.2]
- Stack version: [e.g., 2.7.5]
- GLADOS version: [e.g., 0.4.1.0]

## Additional Context
- Error messages
- Stack traces
- Screenshots
- Related issues
```

### Modelo de solicitud de funcionalidad

```markdown
## Feature Description
Description claire de la fonctionnalité

## Motivation
Why is this feature needed?
What problem does it solve?

## Proposed Solution
How should this feature work?

## Alternatives Considered
Other approaches you've thought about

## Additional Context
Any other relevant information
```

---

## Áreas que requieren contribución

### Alta prioridad

- **Backend LLVM** : Completar el backend del compilador
- **Sistema de tipos** : Mejorar la inferencia de tipos
- **Mensajes de error** : Mejor reporte de errores
- **Biblioteca estándar** : Añadir funciones integradas
- **Documentación** : Documentación API con Haddock

### Buenas primeras contribuciones

Buscar problemas etiquetados como `good-first-issue` :
- Mejoras en la documentación
- Programas de ejemplo
- Cobertura de pruebas
- Comentarios de código
- Correcciones de estilo

### Contribuciones avanzadas

Para los colaboradores experimentados :
- Optimización de la VM
- Recolección de basura
- Compilación JIT
- Protocolo de servidor de lenguaje (LSP)
- Implementación del depurador

---

## ¿Tienes preguntas?

- **Problemas en GitHub** : Para errores y funcionalidades
- **Discusiones en GitHub** : Para preguntas e ideas
- **Solicitudes de extracción** : Para contribuciones de código

## Reconocimiento

Los colaboradores serán reconocidos en :
- CHANGELOG.md
- README del proyecto
- Notas de versión

¡Gracias por contribuir a GLADOS! 🚀

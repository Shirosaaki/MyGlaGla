# Enumeraciones - Conjuntos de valores fijos

Las enumeraciones permiten definir un conjunto fijo de valores nombrados. Son útiles para representar un conjunto limitado de opciones.

## Definición de enumeración básica

```tsl
desnum Color
    RED
    GREEN
    BLUE

Deschodt Eric() -> int
    eric myColor -> int
    myColor = RED
    
    erif (myColor == RED):
        peric("Color is RED")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into Spanish (ES).
```
Color is RED
```

**Sintaxis:**
- `desnum EnumName` inicia una definición de enumeración
- Cada valor en una nueva línea
- Los valores de enumeración se numeran automáticamente (0, 1, 2, ...)
- Utiliza los valores de enumeración directamente como variables

## Valores de enumeración y Numeración automática

Cuando defines un enum, cada valor recibe un entero automático:

```tsl
desnum Day
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY

Deschodt Eric() -> int
    eric today -> int
    today = MONDAY      desnote Value is 0
    
    eric weekend -> int
    weekend = SATURDAY  desnote Value is 5
    
    peric("Monday: {today}")
    peric("Saturday: {weekend}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into Spanish (ES).
```
Monday: 0
Saturday: 5
```

La primera valor de enumeración siempre es 0, y cada valor siguiente aumenta en 1.

## Usando Enumeraciones en Condiciones

```tsl
desnum Status
    WAITING
    RUNNING
    COMPLETED
    FAILED

Deschodt getStatusMessage(status -> int) -> string
    erif (status == WAITING):
        deschodt "Waiting to start"
    deschelse:
        erif (status == RUNNING):
            deschodt "Currently running"
        deschelse:
            erif (status == COMPLETED):
                deschodt "Finished successfully"
            deschelse:
                erif (status == FAILED):
                    deschodt "Failed"
                deschelse:
                    deschodt "Unknown status"

Deschodt Eric() -> int
    eric taskStatus = RUNNING -> int
    peric("Status: {getStatusMessage(taskStatus)}")
    deschodt 0
```

Sure, please provide the Markdown chunk you would like me to translate into Spanish (ES).
```
Status: Currently running
```

## Enumeración en la estructura

```tsl
desnum Priority
    LOW
    MEDIUM
    HIGH
    URGENT

destruct Task
    name -> string
    priority -> int

Deschodt Eric() -> int
    eric task -> Task
    task.name = "Fix bug"
    task.priority = HIGH
    
    erif (task.priority == URGENT):
        peric("This task is URGENT!")
    deschelse:
        erif (task.priority == HIGH):
            peric("High priority task: {task.name}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into Spanish (ES).
```
High priority task: Fix bug
```

## Múltiples Enumeraciones

Puedes definir múltiples enums en tu programa:

```tsl
desnum Color
    RED
    GREEN
    BLUE

desnum Size
    SMALL
    MEDIUM
    LARGE

destruct Product
    color -> int
    size -> int

Deschodt Eric() -> int
    eric shirt -> Product
    shirt.color = BLUE
    shirt.size = LARGE
    
    peric("Color: {shirt.color}")
    peric("Size: {shirt.size}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into Spanish (ES).
```
Color: 2
Size: 2
```

## Enumeración con comparaciones

```tsl
desnum Difficulty
    EASY
    MEDIUM
    HARD
    NIGHTMARE

Deschodt getDifficultySuggestion(level -> int) -> string
    erif (level <= EASY):
        deschodt "Great for beginners"
    deschelse:
        erif (level <= MEDIUM):
            deschodt "Challenge yourself!"
        deschelse:
            erif (level <= HARD):
                deschodt "You're brave"
            deschelse:
                deschodt "Only experts dare enter"

Deschodt Eric() -> int
    eric difficulty = NIGHTMARE -> int
    peric("{getDifficultySuggestion(difficulty)}")
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into Spanish (ES).
```
Only experts dare enter
```

## Uso de Énumeraciones en Bucles

```tsl
desnum TrafficLight
    RED
    YELLOW
    GREEN

Deschodt getWaitTime(light -> int) -> int
    erif (light == RED):
        deschodt 30
    deschelse:
        erif (light == YELLOW):
            deschodt 5
        deschelse:
            deschodt 0

Deschodt Eric() -> int
    eric lights -> int[]
    lights[0] = RED
    lights[1] = YELLOW
    lights[2] = GREEN
    lights[3] = RED
    
    aer i in range(0, 4):
        eric wait = getWaitTime(lights[i]) -> int
        peric("Light {i}: Wait {wait} seconds")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you'd like me to translate into Spanish (ES).
```
Light 0: Wait 30 seconds
Light 1: Wait 5 seconds
Light 2: Wait 0 seconds
Light 3: Wait 30 seconds
```

## Ejemplo práctico: Estados del juego

```tsl
desnum GameState
    MENU
    PLAYING
    PAUSED
    GAME_OVER

Deschodt getGameMessage(state -> int) -> string
    erif (state == MENU):
        deschodt "Press START to play"
    deschelse:
        erif (state == PLAYING):
            deschodt "Game is running"
        deschelse:
            erif (state == PAUSED):
                deschodt "Game paused - press RESUME"
            deschelse:
                deschodt "Game Over - press RESTART"

Deschodt Eric() -> int
    eric currentState = PLAYING -> int
    peric("{getGameMessage(currentState)}")
    
    currentState = PAUSED
    peric("{getGameMessage(currentState)}")
    
    currentState = GAME_OVER
    peric("{getGameMessage(currentState)}")
    
    deschodt 0
```

Lo siento, pero no veo el contenido en Markdown que necesitas traducir. Por favor, proporciona el texto y estaré encantado de ayudarte con la traducción al español.
```
Game is running
Game paused - press RESUME
Game Over - press RESTART
```

## Ejemplo práctico: Roles del usuario

```tsl
desnum Role
    GUEST
    USER
    MODERATOR
    ADMIN

Deschodt hasPermission(role -> int, action -> string) -> bool
    erif (role == ADMIN):
        deschodt #t
    deschelse:
        erif (role == MODERATOR):
            deschodt #t
        deschelse:
            erif (role == USER):
                desnote Users can read but not delete
                deschodt #f
            deschelse:
                desnote Guests are read-only
                deschodt #f

Deschodt Eric() -> int
    eric userRole = USER -> int
    
    erif (hasPermission(userRole, "delete")):
        peric("You can delete content")
    deschelse:
        peric("You cannot delete content")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you'd like me to translate into Spanish (ES).
```
You cannot delete content
```

## Ejemplo práctico: Condiciones meteorológicas

```tsl
desnum WeatherType
    SUNNY
    CLOUDY
    RAINY
    SNOWY
    STORMY

Deschodt getWeatherRecommendation(weather -> int) -> string
    erif (weather == SUNNY):
        deschodt "Perfect day! Go outside!"
    deschelse:
        erif (weather == CLOUDY):
            deschodt "Mild weather, bring a light jacket"
        deschelse:
            erif (weather == RAINY):
                deschodt "Bring an umbrella"
            deschelse:
                erif (weather == SNOWY):
                    deschodt "Bundle up! Wear winter clothes"
                deschelse:
                    deschodt "Stay indoors, storm approaching"

Deschodt Eric() -> int
    eric currentWeather = RAINY -> int
    peric("{getWeatherRecommendation(currentWeather)}")
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into Spanish (ES).
```
Bring an umbrella
```

## Enum en Tableros

```tsl
desnum Season
    SPRING
    SUMMER
    FALL
    WINTER

Deschodt Eric() -> int
    eric seasons -> int[]
    
    seasons[0] = SPRING
    seasons[1] = SUMMER
    seasons[2] = FALL
    seasons[3] = WINTER
    
    eric seasonNames -> string[]
    seasonNames[0] = "Spring"
    seasonNames[1] = "Summer"
    seasonNames[2] = "Fall"
    seasonNames[3] = "Winter"
    
    aer i in range(0, 4):
        peric("Season {seasons[i]}: {seasonNames[i]}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into Spanish (ES).
```
Season 0: Spring
Season 1: Summer
Season 2: Fall
Season 3: Winter
```

## Errores comunes

### Usar un valor de enumeración no definido
```tsl
desnum Color
    RED
    GREEN
    BLUE

eric myColor = PURPLE -> int  desnote ERROR - PURPLE not defined
eric myColor = RED -> int     desnote CORRECT
```

### Los valores de enumeración deben usarse de manera consistente
```tsl
desnum Animal
    DOG
    CAT
    BIRD

desnum Color
    RED
    GREEN
    BLUE

eric pet = DOG -> int      desnote CORRECT
eric pet = RED -> int      desnote WRONG - RED is a Color, not an Animal
```

Énumérations son solo enteros, pero están destinados a agrupaciones lógicas. Usa el enum correcto para el contexto adecuado.

### Olvidando la palabra clave desnum
```tsl
Color
    RED          desnote ERROR - missing desnum keyword
    GREEN
    BLUE

desnum Color     desnote CORRECT
    RED
    GREEN
    BLUE
```

### Confusión en la Numeración de Enum
```tsl
desnum Priority
    LOW      desnote This is 0
    MEDIUM   desnote This is 1
    HIGH     desnote This is 2

desnote If you compare with wrong numbers:
eric p = 3 -> int  desnote Out of range
eric p = LOW -> int  desnote Correct - value 0
```

## Mejores prácticas

1. **Usa Nombres Descriptivos**: Haz que los nombres de los enums indiquen claramente su propósito
2. **Agrupación Lógica**: Agrupa los valores de enums relacionados
3. **Convención UPPERCASE**: Por tradición, los valores de enums están en UPPERCASE
4. **No Omitas Valores**: Mantén los valores de enums consecutivos (0, 1, 2, ...)
5. **Documenta el Significado**: Agrega comentarios si los valores de enums no son autoexplicativos
6. **Usa en Funciones**: Pasa enums a las funciones para procesarlos
7. **Combina con Estructuras**: Usa enums en structs para seguridad de tipos

## Pasos Siguientes

- Usa enums con **[Funciones](functions.md)** para procesar diferentes casos
- Almacena enums en **[Estructuras](structs.md)** para datos estructurados
- Combina enums con **[Bucles](loops.md)** para iterar sobre los valores de enums

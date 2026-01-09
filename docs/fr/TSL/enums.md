# Énumérations - Ensembles de valeurs fixes

Les énumérations permettent de définir un ensemble fixe de valeurs nommées. Ils sont utiles pour représenter un ensemble limité d'options.

## Définition d'énumération de base

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

Output:
```
Color is RED
```

**Syntax:**
- `desnum EnumName` commence une énumération definition
- Chaque valeur sur une nouvelle ligne
- Les valeurs d'énumération sont automatiquement numérotées (0, 1, 2, ...)
- Utilisez les valeurs d'énumération directement comme des variables

## Valeurs d'énumération and Numérotation automatique

Quand vous définissez an enum, chaque valeur obtient un entier automatique:

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

Output:
```
Monday: 0
Saturday: 5
```

La première valeur d'énumération est toujours 0, and chaque valeur suivante augmente de 1.

## Using Énumérations in Conditions

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

Output:
```
Status: Currently running
```

## Énumération dans la structure

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

Output:
```
High priority task: Fix bug
```

## Multiple Énumérations

Vous pouvez définir multiple enums in your program:

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

Output:
```
Color: 2
Size: 2
```

## Énumération avec comparaisons

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

Output:
```
Only experts dare enter
```

## Using Énumérations in Boucles

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

Output:
```
Light 0: Wait 30 seconds
Light 1: Wait 5 seconds
Light 2: Wait 0 seconds
Light 3: Wait 30 seconds
```

## Exemple pratique: États du jeu

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

Output:
```
Game is running
Game paused - press RESUME
Game Over - press RESTART
```

## Exemple pratique: Rôles de l'utilisateur

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

Output:
```
You cannot delete content
```

## Exemple pratique: Conditions météorologiques

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

Output:
```
Bring an umbrella
```

## Enum in Tableaux

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

Output:
```
Season 0: Spring
Season 1: Summer
Season 2: Fall
Season 3: Winter
```

## Erreurs courantes

### Utiliser la valeur d'énumération non définie
```tsl
desnum Color
    RED
    GREEN
    BLUE

eric myColor = PURPLE -> int  desnote ERROR - PURPLE not defined
eric myColor = RED -> int     desnote CORRECT
```

### Valeurs d'énumération Must Be Used Consistently
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

Énumérations are just integers, but they're meant for logical grouping. Use the right enum for the right context.

### Forgetting desnum Keyword
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

### Enum Numbering Confusion
```tsl
desnum Priority
    LOW      desnote This is 0
    MEDIUM   desnote This is 1
    HIGH     desnote This is 2

desnote If you compare with wrong numbers:
eric p = 3 -> int  desnote Out of range
eric p = LOW -> int  desnote Correct - value 0
```

## Meilleures pratiques

1. **Use Descriptive Names**: Make enum names clearly indicate their purpose
2. **Logical Grouping**: Group related enum values together
3. **UPPERCASE Convention**: By tradition, enum values are UPPERCASE
4. **Don't Skip Values**: Keep enum values consecutive (0, 1, 2, ...)
5. **Document Meaning**: Add comments if enum values aren't self-explanatory
6. **Use in Fonctions**: Pass enums aux fonctions to process them
7. **Combine with Structures**: Use enums in structs for type safety

## Étapes suivantes

- Use enums with **[Fonctions](functions.md)** to process different cases
- Store enums in **[Structures](structs.md)** for structured data
- Combine enums with **[Boucles](loops.md)** to iterate over enum values

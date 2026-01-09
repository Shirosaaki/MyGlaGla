# Enums - Feste Werte-Sets

Enums ermöglichen es Ihnen, eine feste Menge benannter Werte zu definieren. Sie sind nützlich, um eine begrenzte Anzahl von Optionen darzustellen.

## Grundlegende Enum-Definition

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

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
Color is RED
```

**Syntax:**
- `desnum EnumName` beginnt eine Enum-Definition
- Jeder Wert in einer neuen Zeile
- Enum-Werte werden automatisch nummeriert (0, 1, 2, ...)
- Verwende Enum-Werte direkt wie Variablen

## Enum-Werte und automatische Nummerierung

Wenn du ein Enum definierst, erhält jeder Wert eine automatische Ganzzahl:

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

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
Monday: 0
Saturday: 5
```

Der erste Enum-Wert ist immer 0, und jeder nachfolgende Wert erhöht sich um 1.

## Verwendung von Enums in Bedingungen

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

Sure, please provide the Markdown chunk you would like me to translate into German (DE).
```
Status: Currently running
```

## Enum in Struct

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

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
High priority task: Fix bug
```

## Mehrere Enums

Sie können mehrere Enums in Ihrem Programm definieren:

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

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
Color: 2
Size: 2
```

## Enum mit Vergleichen

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

Sure! Please provide the Markdown chunk you'd like me to translate into German (DE).
```
Only experts dare enter
```

## Verwendung von Enums in Schleifen

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

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
Light 0: Wait 30 seconds
Light 1: Wait 5 seconds
Light 2: Wait 0 seconds
Light 3: Wait 30 seconds
```

## Praktisches Beispiel: Spielzustände

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

I'm sorry, but it seems you haven't provided the Markdown chunk that you would like me to translate. Please share the text, and I'll be happy to assist you with the translation!
```
Game is running
Game paused - press RESUME
Game Over - press RESTART
```

## Praktisches Beispiel: Benutzerrollen

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

Sure! Please provide the Markdown chunk you'd like me to translate into German (DE).
```
You cannot delete content
```

## Praktisches Beispiel: Wetterbedingungen

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

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
Bring an umbrella
```

## Enum in Arrays

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

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
Season 0: Spring
Season 1: Summer
Season 2: Fall
Season 3: Winter
```

## Häufige Fehler

### Verwendung eines undefinierten Enum-Werts
```tsl
desnum Color
    RED
    GREEN
    BLUE

eric myColor = PURPLE -> int  desnote ERROR - PURPLE not defined
eric myColor = RED -> int     desnote CORRECT
```

### Enum-Werte müssen konsistent verwendet werden
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

Enums sind einfach Ganzzahlen, aber sie sind für logische Gruppierungen gedacht. Verwenden Sie das richtige Enum für den richtigen Kontext.

### Vergessen des desnum-Schlüsselworts
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

### Verwirrung bei der Enum-Nummerierung
```tsl
desnum Priority
    LOW      desnote This is 0
    MEDIUM   desnote This is 1
    HIGH     desnote This is 2

desnote If you compare with wrong numbers:
eric p = 3 -> int  desnote Out of range
eric p = LOW -> int  desnote Correct - value 0
```

## Best Practices

1. **Verwenden Sie beschreibende Namen**: Lassen Sie die Enum-Namen klar ihren Zweck anzeigen
2. **Logische Gruppierung**: Gruppieren Sie verwandte Enum-Werte zusammen
3. **UPPERCASE-Konvention**: Traditionell sind Enum-Werte in UPPERCASE
4. **Werte nicht überspringen**: Halten Sie die Enum-Werte aufeinanderfolgend (0, 1, 2, ...)
5. **Bedeutung dokumentieren**: Fügen Sie Kommentare hinzu, wenn Enum-Werte nicht selbsterklärend sind
6. **In Funktionen verwenden**: Übergeben Sie Enums an Funktionen zur Verarbeitung
7. **Mit Structs kombinieren**: Verwenden Sie Enums in Structs für Typensicherheit

## Next Steps

- Verwenden Sie Enums mit **[Funktionen](functions.md)**, um verschiedene Fälle zu verarbeiten
- Speichern Sie Enums in **[Structs](structs.md)** für strukturierte Daten
- Kombinieren Sie Enums mit **[Schleifen](loops.md)**, um über Enum-Werte zu iterieren

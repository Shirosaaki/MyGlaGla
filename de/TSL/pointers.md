# Zeiger - Verweise auf Werte

Zeiger speichern Speicheradressen anderer Variablen. Sie ermöglichen es Ihnen, indirekt mit Werten zu arbeiten und Daten in Funktionen zu ändern.

## Verständnis von Zeigern

Ein Zeiger ist eine Variable, die die Speicheradresse einer anderen Variable enthält:

```
Regular variable:    int x = 5        (stores the value 5)
Pointer variable:    int* ptr = &x    (stores the address of x)
```

Der `&`-Operator erhält die Adresse einer Variablen.  
Der `*`-Operator greift auf den Wert an einer Adresse zu.  

## Zeigerdeklaration und -initialisierung

```tsl
Deschodt Eric() -> int
    eric x = 10 -> int
    eric ptr = &x -> int*
    
    peric("Value of x: {x}")
    peric("Address of x: {ptr}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
Value of x: 10
Address of x: 94593175618496
```

**Syntax:**
- `eric ptr -> int*` deklariert einen Zeiger auf einen int (Typ mit `*`)
- `&variable` erhält die Adresse einer Variablen
- Zuweisung: `ptr = &x`

## Dereferenzierung von Zeigern

Dereferenziere einen Zeiger mit `*`, um auf den Wert zuzugreifen, auf den er zeigt:

```tsl
Deschodt Eric() -> int
    eric x = 10 -> int
    eric ptr = &x -> int*
    
    eric value = *ptr -> int
    peric("x = {x}")
    peric("*ptr = {value}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
x = 10
*ptr = 10
```

Wenn Sie einen Zeiger dereferenzieren, erhalten Sie den Wert an dieser Adresse.

## Über Zeiger Modifizieren

Sie können einen Wert über einen Zeiger ändern:

```tsl
Deschodt Eric() -> int
    eric x = 10 -> int
    eric ptr = &x -> int*
    
    peric("Before: x = {x}")
    
    *ptr = 20
    peric("After: x = {x}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
Before: x = 10
After: x = 20
```

Ändern von `*ptr` ändert die ursprüngliche Variable `x`.

## Zeigertypen

Verschiedene Arten von Zeigern:

```tsl
Deschodt Eric() -> int
    eric intVal = 42 -> int
    eric floatVal = 3.14 -> float
    eric strVal = "hello" -> string
    eric boolVal = #t -> bool
    
    eric intPtr = &intVal -> int*
    eric floatPtr = &floatVal -> float*
    eric strPtr = &strVal -> string*
    eric boolPtr = &boolVal -> bool*
    
    peric("int* points to: {*intPtr}")
    peric("float* points to: {*floatPtr}")
    
    deschodt 0
```

## Funktionsparameter mit Zeigern

Übergeben Sie Zeiger an Funktionen, um Werte innerhalb der Funktion zu ändern:

```tsl
Deschodt increment(ptr -> int*) -> void
    *ptr = *ptr + 1

Deschodt Eric() -> int
    eric x = 5 -> int
    peric("Before: {x}")
    
    increment(&x)
    peric("After: {x}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you'd like me to translate into German (DE).
```
Before: 5
After: 6
```

Die Funktion ändert die ursprüngliche Variable über ihren Zeigerparameter.

## Werte mit Zeigern tauschen

```tsl
Deschodt swap(a -> int*, b -> int*) -> void
    eric temp = *a -> int
    *a = *b
    *b = temp

Deschodt Eric() -> int
    eric x = 10 -> int
    eric y = 20 -> int
    
    peric("Before: x = {x}, y = {y}")
    swap(&x, &y)
    peric("After: x = {x}, y = {y}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you'd like me to translate into German (DE).
```
Before: x = 10, y = 20
After: x = 20, y = 10
```

## Vergleichen von Zeigern

```tsl
Deschodt Eric() -> int
    eric x = 10 -> int
    eric y = 20 -> int
    
    eric ptr1 = &x -> int*
    eric ptr2 = &x -> int*
    eric ptr3 = &y -> int*
    
    erif (ptr1 == ptr2):
        peric("ptr1 and ptr2 point to same location")
    
    erif (ptr1 != ptr3):
        peric("ptr1 and ptr3 point to different locations")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
ptr1 and ptr2 point to same location
ptr1 and ptr3 point to different locations
```

## Zeigerarithmetik (Konzeptionell)

```tsl
Deschodt Eric() -> int
    eric arr -> int[]
    arr[0] = 10
    arr[1] = 20
    arr[2] = 30
    
    eric ptr = &arr[0] -> int*
    peric("Points to: {*ptr}")
    
    deschodt 0
```

## Array-Parameter mit Zeigern

```tsl
Deschodt doubleArray(arr -> int*, size -> int) -> void
    aer i in range(0, size):
        desnote Access element through pointer arithmetic (conceptual)
        desnote For now, use the array directly

Deschodt Eric() -> int
    eric values -> int[]
    values[0] = 1
    values[1] = 2
    values[2] = 3
    
    eric ptr = &values[0] -> int*
    peric("First element: {*ptr}")
    
    deschodt 0
```

## Rückgabe von Zeigern aus Funktionen

```tsl
Deschodt getMax(a -> int*, b -> int*) -> int*
    erif (*a > *b):
        deschodt a
    deschelse:
        deschodt b

Deschodt Eric() -> int
    eric x = 10 -> int
    eric y = 25 -> int
    
    eric maxPtr = getMax(&x, &y) -> int*
    peric("Maximum: {*maxPtr}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
Maximum: 25
```

## Strukturfelder mit Zeigern

```tsl
destruct LinkedNode
    value -> int
    next -> LinkedNode*

Deschodt Eric() -> int
    eric node -> LinkedNode
    node.value = 10
    desnote node.next = null (not yet implemented)
    
    peric("Node value: {node.value}")
    deschodt 0
```

## Pass by Value vs. Pass by Pointer

**Pass by Value** - Funktion erhält eine KOPIE:

```tsl
Deschodt incrementValue(x -> int) -> void
    x = x + 1

Deschodt Eric() -> int
    eric num = 5 -> int
    incrementValue(num)
    peric("{num}")  desnote Still 5 - copy was modified
    deschodt 0
```

I'm sorry, but it seems that you haven't provided the Markdown chunk that you would like me to translate. Please provide the text, and I'll be happy to assist you with the translation into German (DE) while following your specified guidelines.
```
5
```

**Übergabe durch Zeiger** - Funktion erhält die ADRESSE:

```tsl
Deschodt incrementPointer(ptr -> int*) -> void
    *ptr = *ptr + 1

Deschodt Eric() -> int
    eric num = 5 -> int
    incrementPointer(&num)
    peric("{num}")  desnote Now 6 - original was modified
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
6
```

Verwenden Sie Zeiger, wenn Sie die ursprüngliche Variable ändern müssen.

## Praktisches Beispiel: Strukturwerte aktualisieren

```tsl
destruct BankAccount
    balance -> float
    transactions -> int

Deschodt deposit(account -> BankAccount*, amount -> float) -> void
    (*account).balance = (*account).balance + amount
    (*account).transactions = (*account).transactions + 1

Deschodt Eric() -> int
    eric myAccount -> BankAccount
    myAccount.balance = 1000.0
    myAccount.transactions = 0
    
    peric("Initial balance: {myAccount.balance}")
    deposit(&myAccount, 500.0)
    peric("After deposit: {myAccount.balance}")
    peric("Transactions: {myAccount.transactions}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
Initial balance: 1000.0
After deposit: 1500.0
Transactions: 1
```

## Praktisches Beispiel: Bubble Sort mit Zeigern

```tsl
Deschodt swap(a -> int*, b -> int*) -> void
    eric temp = *a -> int
    *a = *b
    *b = temp

Deschodt Eric() -> int
    eric arr -> int[]
    arr[0] = 64
    arr[1] = 34
    arr[2] = 25
    arr[3] = 12
    arr[4] = 22
    
    desnote Simple sorting loop
    aer i in range(0, 5):
        aer j in range(0, 4):
            erif (arr[j] > arr[j + 1]):
                swap(&arr[j], &arr[j + 1])
    
    aer i in range(0, 5):
        peric("{arr[i]}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
12
22
25
34
64
```

## Häufige Fehler

### Dereferenzierung ohne Initialisierung
```tsl
eric ptr -> int*
desnote ptr is uninitialized
eric value = *ptr -> int  desnote ERROR - accessing garbage memory
```

Immerse Zeiger immer:
```tsl
eric x = 10 -> int
eric ptr = &x -> int*  desnote CORRECT - now safe to dereference
```

### Typkonflikt
```tsl
eric x = 10 -> int
eric strPtr = &x -> string*  desnote ERROR - type mismatch
eric intPtr = &x -> int*     desnote CORRECT
```

### Vergessen, die Referenz aufzulösen
```tsl
eric x = 10 -> int
eric ptr = &x -> int*

eric value = ptr -> int  desnote ERROR - assigns address, not value
eric value = *ptr -> int desnote CORRECT - dereferences to get value
```

### Modifizieren ohne Dereferenzierung
```tsl
eric x = 10 -> int
eric ptr = &x -> int*

ptr = 20         desnote ERROR - changes the pointer, not x
*ptr = 20        desnote CORRECT - changes the value x points to
```

## Best Practices

1. **Zeiger initialisieren**: Immer auf eine gültige Variable zeigen
2. **Vor Dereferenzierung überprüfen**: Überprüfen, ob der Zeiger gültig ist
3. **Bedeutungsvolle Namen verwenden**: Verwende `ptr`-Suffix: `xPtr`, `nodePtr`
4. **Eigentum dokumentieren**: Klarstellen, wer den Speicher besitzt
5. **Null-Zeiger**: Zeiger vorsichtig verwenden, wenn sie null sein könnten
6. **Hängende Zeiger vermeiden**: Nicht auf Variablen zeigen, die aus dem Gültigkeitsbereich fallen
7. **Nur bei Bedarf verwenden**: Zeiger nur verwenden, wenn nötig (Originale modifizieren)

## Next Steps

- Verwende Zeiger mit **[Structs](structs.md)** für komplexe Datenstrukturen
- Kombiniere Zeiger mit **[Functions](functions.md)** zur Datenmodifikation
- Wende Zeiger in **[Arrays](lists.md)** für effiziente Verarbeitung an

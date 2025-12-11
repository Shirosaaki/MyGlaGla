# Pointers - References to Values

Pointers store memory addresses of other variables. They let you work with values indirectly and modify data in functions.

## Understanding Pointers

A pointer is a variable that holds the memory address of another variable:

```
Regular variable:    int x = 5        (stores the value 5)
Pointer variable:    int* ptr = &x    (stores the address of x)
```

The `&` operator gets the address of a variable.
The `*` operator accesses the value at an address.

## Pointer Declaration and Initialization

```tsl
Deschodt Eric() -> int
    eric x = 10 -> int
    eric ptr = &x -> int*
    
    peric("Value of x: {x}")
    peric("Address of x: {ptr}")
    
    deschodt 0
```

Output:
```
Value of x: 10
Address of x: 94593175618496
```

**Syntax:**
- `eric ptr -> int*` declares a pointer to an int (type with `*`)
- `&variable` gets the address of a variable
- Assign: `ptr = &x`

## Dereferencing Pointers

Dereference a pointer with `*` to access the value it points to:

```tsl
Deschodt Eric() -> int
    eric x = 10 -> int
    eric ptr = &x -> int*
    
    eric value = *ptr -> int
    peric("x = {x}")
    peric("*ptr = {value}")
    
    deschodt 0
```

Output:
```
x = 10
*ptr = 10
```

When you dereference a pointer, you get the value at that address.

## Modifying Through Pointers

You can modify a value through a pointer:

```tsl
Deschodt Eric() -> int
    eric x = 10 -> int
    eric ptr = &x -> int*
    
    peric("Before: x = {x}")
    
    *ptr = 20
    peric("After: x = {x}")
    
    deschodt 0
```

Output:
```
Before: x = 10
After: x = 20
```

Changing `*ptr` changes the original variable `x`.

## Pointer Types

Different types of pointers:

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

## Function Parameters with Pointers

Pass pointers to functions to modify values inside the function:

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

Output:
```
Before: 5
After: 6
```

The function modifies the original variable through its pointer parameter.

## Swapping Values with Pointers

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

Output:
```
Before: x = 10, y = 20
After: x = 20, y = 10
```

## Comparing Pointers

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

Output:
```
ptr1 and ptr2 point to same location
ptr1 and ptr3 point to different locations
```

## Pointer Arithmetic (Conceptual)

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

## Array Parameters with Pointers

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

## Returning Pointers from Functions

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

Output:
```
Maximum: 25
```

## Struct Fields with Pointers

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

**Pass by Value** - Function gets a COPY:

```tsl
Deschodt incrementValue(x -> int) -> void
    x = x + 1

Deschodt Eric() -> int
    eric num = 5 -> int
    incrementValue(num)
    peric("{num}")  desnote Still 5 - copy was modified
    deschodt 0
```

Output:
```
5
```

**Pass by Pointer** - Function gets the ADDRESS:

```tsl
Deschodt incrementPointer(ptr -> int*) -> void
    *ptr = *ptr + 1

Deschodt Eric() -> int
    eric num = 5 -> int
    incrementPointer(&num)
    peric("{num}")  desnote Now 6 - original was modified
    deschodt 0
```

Output:
```
6
```

Use pointers when you need to modify the original variable.

## Practical Example: Update Struct Values

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

Output:
```
Initial balance: 1000.0
After deposit: 1500.0
Transactions: 1
```

## Practical Example: Bubble Sort with Pointers

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

Output:
```
12
22
25
34
64
```

## Common Mistakes

### Dereferencing Without Initialization
```tsl
eric ptr -> int*
desnote ptr is uninitialized
eric value = *ptr -> int  desnote ERROR - accessing garbage memory
```

Always initialize pointers:
```tsl
eric x = 10 -> int
eric ptr = &x -> int*  desnote CORRECT - now safe to dereference
```

### Type Mismatch
```tsl
eric x = 10 -> int
eric strPtr = &x -> string*  desnote ERROR - type mismatch
eric intPtr = &x -> int*     desnote CORRECT
```

### Forgetting to Dereference
```tsl
eric x = 10 -> int
eric ptr = &x -> int*

eric value = ptr -> int  desnote ERROR - assigns address, not value
eric value = *ptr -> int desnote CORRECT - dereferences to get value
```

### Modifying Without Dereference
```tsl
eric x = 10 -> int
eric ptr = &x -> int*

ptr = 20         desnote ERROR - changes the pointer, not x
*ptr = 20        desnote CORRECT - changes the value x points to
```

## Best Practices

1. **Initialize Pointers**: Always point to a valid variable
2. **Check Before Dereferencing**: Verify pointer is valid
3. **Use Meaningful Names**: Use `ptr` suffix: `xPtr`, `nodePtr`
4. **Document Ownership**: Clarify who owns the memory
5. **Null Pointers**: Use pointers carefully when they might be null
6. **Avoid Dangling Pointers**: Don't point to variables that go out of scope
7. **Use When Needed**: Only use pointers when necessary (modifying originals)

## Next Steps

- Use pointers with **[Structs](structs.md)** for complex data structures
- Combine pointers with **[Functions](functions.md)** for data modification
- Apply pointers in **[Arrays](lists.md)** for efficient processing

# Complexities

## Time Complexity – Big O

### References

- [Time Complexity of Algorithms](https://www.studytonight.com/data-structures/time-complexity-of-algorithms)
- [Why is Time Complexity Essential and What is Time Complexity?](https://www.mygreatlearning.com/blog/why-is-time-complexity-essential/)
- [How To Calculate Time Complexity With Big O Notation](https://medium.com/dataseries/how-to-calculate-time-complexity-with-big-o-notation-9afe33aa4c46)
- [Calculating Time Complexity | New Examples | GeeksforGeeks](https://www.youtube.com/watch?v=KXAbAa1mieU)

### Definition

**Time complexity signifies the total time needed for an algorithm to accomplish it's task.** It is most commonly expressed in Big O Notation. Time complexity is calculated by counting the number of elementary steps, performed by an algorithm to finish execution.

Big O Notation is used as it represents the upper bound of 

### Types of Big O Time Complexities

1. `O(1)` – the best complexity: one action, independent of input

```swift
/**
- Constant complexity O(1)
- Algorithm not dependent from the input size (n)
- Runtime is always the same
*/

func square(_ input: Int) -> Int {
  return input * input
}
```

2. `O(n)` – steps count is equal to input size

```swift
/**
- Linear complexity O(n)
- Running time increase linearly with the input size (n)
*/

func repeatNTimes(_ n: Int) { 
	for (i = 0; i < n; i++) { // n times the process will repeat
		statement; // constant, not included (c)
	} 	
}
```

3. `O(log n)` – each step the input size is reduced

```swift
/**
- Logarithmic complexity O(log n)
- Input size is reduced at each step (aka working with splits of input)
*/

/// This algorithm worth commenting:
/// - this is the benary search algorithm
/// - it iterates over the input to find given element

func binarySearch(_ inputArray: [Int], element: Int) -> Int? {
  
  // `begin` is the start of the array, the first value
  // `end` is the last index
  // these are needed to access the values
  // their values will be later compared with the `element`
  
  var begin = 0
  var end = inputArray.count
  
  // we iterate until we reach the end
  
  while begin < end {
    
    /**
    Each time we calculate the mid index
    taking in account if the beginning
    has shifted forward (closer to the end)
    */
    
    let mid = begin + (end - begin) / 2
            
    if inputArray[mid] == element {
    	return mid
    } else if inputArray[mid] < element {
    	begin = mid
    } else  {
    	end = mid
    }
  }
  return nil
}
```

4. `O(n * log(n))` – before reduce input size, some linear action is performed (sort algorithms; recursive)

```swift
func mergeSort<T: Comparable>(_ inputArray: inout [T], startIndex: Int, endIndex: Int) {
	
  // `midIndex` is needed to divide the input into two halves
  	
  let midIndex = (startIndex + endIndex) / 2
  
  // The input population is divided into halves here
  
  mergeSort(&inputArray, startIndex: startIndex, endIndex: middleIndex)
  mergeSort(&inputArray, startIndex: middleIndex + 1, endIndex: endIndex)
  
  // After two population subgroups were sorted, they are merged
  
  merge(array: &inputArray, startIndex: startIndex, middleIndex: middleIndex, endIndex: endIndex)

}
```

4. `O(n!), O(n^n), O(n^c)` – worst	

```c
/**
- Quadratic complexity O(n^2) = O(n) * O(n)
- Running time directly proportional to N^2
*/

for (i = 0; i < N; i++) { // O(n)
	for (j = 0; j < N; j++) { // O(n)
    statement; 
  }
}

/// NB: - There is a polynominal complexity O(nˆm) where 'm' is the number of nested loops
```

### Calculating Time Complexity

Time complexity in general is calculated to get how algorithm will deal with the large sized input and to examine the worst-case scenario.

Big O Notation is the most common metric here. As per Big O all constant factors are removed from the calculation, running time can be estimated by **N** (that approaches infinity).

Consider the algorithm:

```swift
func add(lhs: Int, rhs: Int) {
	let total = lhs + rhs
  return total
}
```

To calculate the time complexity of the algorithm we first need to break this function down into separate operations:

1. Look up `lhs`
2. Look up `rhs`
3. Assign to the `total`
4. Return the `total`

Next, we should calculate the time complexity of each of them (all are `O(1)` as do not depend on the input size and happen once).

Then we should add the complexities together: `O(1 + 1 + 1 + 1) = O(4) = 4 x O(1)`.

At last we strip out this expression to leave only the highest-order term here - `O(1)`.

**Recap:**

- `break down to elemen tary actions`

- `calculate time complexity for each`

- `add up`

- `extract the highest and drop constant multipliers`

Some Examples:

```swift
for(i = 1; i < n; i++) { // here comes n
  x = y+z // constant time C
}

// Complexity = C*n = O(n)
```



```swift
for(i = 1; i < n; i++) { // n times
  for(j = 1; i < n; i++) { // n times
  	x = y+z // constant time C
  }
}

// Complexity = C * n * n = C * (n^2) = O(n^2)
```



```swift
if (condition) {
  /* for loop O(n) */
} else {
  /* nested for loop O(n^2) */
}

// Complexity = O(n^2 )
```

## Space Complexity

### References

- [Space Complexity of Algorithms](https://www.studytonight.com/data-structures/space-complexity-of-algorithms)

### Definition

Space complexity is the total amount of space, that an algorithm requires to store it's data (variables and constants). To calculate it properly we need to sum up all the variables, created in the algorithm. 

### Data Types Sizes in Swift

Here's the representation of all default data types in Swift sorted asc by bytes needed:

- `Int8`, `UInt8`, `Bool` – 1 byte
- `Int32`, `UInt32`, `Float` – 4 bytes
- `Int64`, `UInt64`, `Double` – 8 bytes
- `Character` - 16 bytes (Unicode, `String` is a collection of characters)

### Cases

Case #1:

```swift
func add(lhs: Int, rhs: Int) -> Int {
	let total = lhs + rhs // 3 * 64 bytes
  return total as! Int8 // 8 bytes
}

// total = 3*64 + 8
```

Case #2:


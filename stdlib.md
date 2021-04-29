# 1. STDLIB

## 1.1. Table of Contents
- [1. STDLIB](#1-stdlib)
  - [1.1. Table of Contents](#11-table-of-contents)
  - [1.2. Foreword](#12-foreword)
  - [1.3. Spin-Offs](#13-spin-offs)
    - [1.3.1. Big Endian vs. Little Endian](#131-big-endian-vs-little-endian)
    - [1.3.2. `@frozen`](#132-frozen)
    - [1.3.3. `@_transparent`](#133-_transparent)
    - [1.3.4. `@inline`](#134-inline)
    - [1.3.5. `@autoclosure`](#135-autoclosure)
    - [1.3.6. Binary Overflow](#136-binary-overflow)
    - [1.3.7. Binary Signed Representation: Sign and Magnitude](#137-binary-signed-representation-sign-and-magnitude)
    - [1.3.8. Binary Signed Representation: Two's Complement](#138-binary-signed-representation-twos-complement)
    - [1.3.9. Words](#139-words)
  - [1.4. Numbers and Basic Values](#14-numbers-and-basic-values)
    - [1.4.1. Logical Values / Bool](#141-logical-values--bool)
    - [1.4.2. Number Values / Int](#142-number-values--int)
      - [1.4.2.1. Introduction](#1421-introduction)
      - [1.4.2.2. Int Sizes](#1422-int-sizes)
      - [1.4.2.3. Initialization](#1423-initialization)
      - [1.4.2.4. Performing Calculations](#1424-performing-calculations)
      - [1.4.2.5. Performing Calculations with Assignment](#1425-performing-calculations-with-assignment)
      - [1.4.2.6. Performing Masked Arithmetic](#1426-performing-masked-arithmetic)
      - [1.4.2.7. Bitwise Operations](#1427-bitwise-operations)
      - [1.4.2.8. Bit Shift Operations](#1428-bit-shift-operations)
      - [1.4.2.9. Some Useful Calculation Methods](#1429-some-useful-calculation-methods)
      - [1.4.2.10. Operations with Binary Representation](#14210-operations-with-binary-representation)
    - [1.4.3. Number Values / Double](#143-number-values--double)
    - [1.4.4. Number Values / Float](#144-number-values--float)
    - [1.4.5. Errors / Error](#145-errors--error)
    - [1.4.6. Errors / Result](#146-errors--result)
    - [1.4.7. Optionals / Optional](#147-optionals--optional)
      - [1.4.7.1. Introduction](#1471-introduction)
      - [1.4.7.2. Optional Techniques: `if let` / `guard let` / `switch`](#1472-optional-techniques-if-let--guard-let--switch)
      - [1.4.7.3. Optional Techniques: `while let`](#1473-optional-techniques-while-let)
      - [1.4.7.4. Optional Techniques: `for case let i?`](#1474-optional-techniques-for-case-leti)
      - [1.4.7.5. Optional Techniques: `if var`](#1475-optional-techniques-if-var)
      - [1.4.7.6. Double-wrapped Optionals](#1476-double-wrapped-optionals)
      - [1.4.7.7. Optional Chaining](#1477-optional-chaining)
      - [1.4.7.8. The nil-coalescing operator](#1478-the-nil-coalescing-operator)
      - [1.4.7.9. Optional `flatMap`](#1479-optional-flatmap)
      - [1.4.7.10. Optional `compactMap`](#14710-optional-compactmap)
      - [1.4.7.11. Equating Optionals](#14711-equating-optionals)
      - [1.4.7.12. Nillifying Dictionaries](#14712-nillifying-dictionaries)
      - [1.4.7.13. Compating Optionals](#14713-compating-optionals)
    - [1.4.8. Basic Arithmetic Protocols](#148-basic-arithmetic-protocols)
  - [1.5. Strings And Text](#15-strings-and-text)
    - [1.5.1. Strings and Characters / String](#151-strings-and-characters--string)
    - [1.5.2. Strings and Characters / Character](#152-strings-and-characters--character)
    - [1.5.3. Encoding And Storage / Unicode](#153-encoding-and-storage--unicode)
    - [1.5.4. Compile-TimeStrings / Static String](#154-compile-timestrings--static-string)
  - [1.6. Collections](#16-collections)


## 1.2. Foreword

Exploring [stdlib](https://github.com/apple/swift/tree/main/stdlib) here.

## 1.3. Spin-Offs

### 1.3.1. Big Endian vs. Little Endian

This is just the order by which the bits are organised. Little endian is the way arabic writing goes – from right to left. Big endian is quite the opposite.

`**let** x49 = Int16(bitPattern: 0b01110101)` – 16-bit Integer mkay.

`String(x49.littleEndian, radix: 2)` – prints `1110101` (leading bits are removed)

`String(x49.bigEndian, radix: 2)` – prints `111010100000000`

The **order of bytes is changing** but the **bit order stays the same**: say you have `3,168,415,017` as 32-bit unsigned number. Here is the Little Endian binary representation of it:

```
10111100 11011010 00101101 00101001
```

While the Big Endian representation would flip the bytes:

```
00101001 00101101 11011010 10111100
```

### 1.3.2. `@frozen`

Reference - Proposal [SE-2060](https://github.com/apple/swift-evolution/blob/master/proposals/0260-library-evolution.md).

When a library author is certain that there will never be a need to add fields to a struct in future, they may mary that struct as `@frozen`. Marking a structs as frozen only guarantees that stored instance properties won't change. This allows a compiler to perform certain optimizations.

### 1.3.3. `@_transparent`

References:

- [Swift Forums](https://forums.swift.org/t/whats-transparent-for/38154/3)
- [swift](https://github.com/apple/swift)/[docs](https://github.com/apple/swift/tree/main/docs)/[TransparentAttr.md](https://github.com/apple/swift/blob/main/docs/TransparentAttr.md)

This marks the operation in `stdlib` as primitive e.g. evaluating an expression, assigning a variable, indexing into an array, calling a method, returning from a method, etc. And there's some other stuff but I shan't serearch more at least for now as this is `not intended for ordinary language users`.

### 1.3.4. `@inline`

Inlining is the direct replacing of the function call with the function implementation inside the code. This happens at compile time and provide a great performance boost. It can be used in two ways:

- `@inline(__always)` – inline method always, if possible;
- `@inline(__never)` – never inline the method.

### 1.3.5. `@autoclosure`

This attributes allows the compiler to treat an argument as a closure, so you don't need to perform trailing closure syntax. Consider the code.

```swift
func printTest1(_ res: () -> Void) {
    print("Before")
    res()
    print("after")
}

printTest1 { print("hello") }

func printTest2(_ res: @autoclosure () -> Void) {
    print("Before")
    res()
    print("after")
}

printTest2(print("hello")) // can now be passed as an argument
```

### 1.3.6. Binary Overflow

Numbers in Binary systems can be represented from `-2^(n-1)` to `2^(n-1)-1`. Consider the following:

- `Int8().min = -128 = -10000000 = -2^(8-1)`
- `Int8().max = 127 = -10000000 = -2^(8-1)-1`

Overflow happens when some `2n bit` group is appended to existing `2n bit` group and the latter cannot fit the first, e.g. the answer is to large, to fit the receiver.

### 1.3.7. Binary Signed Representation: Sign and Magnitude

MSB is a sign: `1` is negative, `0` is positive. This method has a few downsides:

- there are two zeros: `0000` and `1000`
- a number and it's negative do not add up to zero: `1111` + `0111` != `0` (= 6)
- what add up to `0` are not negatives of each other: `0011` + `1101` = `0000` (sic)

Conclusion – this is a clumsy way to manipulate integers, fairly not obvious, though may confuse when doing some complex calculations.

### 1.3.8. Binary Signed Representation: Two's Complement

Reference: [University of Michigan Lecture on CS, fall 2014](https://www.eecs.umich.edu/courses/eecs452/Lec/L03SlidesF14.pdf)

MSB is a **negative value**, not the sign – this is a core distinguishing point:

`1011` = `1x(-2^3) + 0x(2^2) + 1x(2^1) + 1x(2^0)` = `-8 + 0 + 2 + 1 = -5`

Some traits of 2's complement:

- positive values have `0` in it's MSB; negative values have `1`
- there is a single zero: `0000` (`1000` is `-8`)
- max value of an N-bit 2's complement number: `(2^(n-1))-1`
- min value of an N-bit 2's complement number: `-2^(n-1)`

Negation of 2's complements is simple – inverting all bits and adding one:

- 4-bit example: `0101 = 5 -> 1010 + 1 = 1011 = -8 + 0 + 3 + 0 = -5`
- 6-bit example: `001110 = 14 -> 110001 + 1 = 110010 = -2^5 + 2^4 + 2 = -14`
- 8-bit example: `01010110 = 86 -> 10101001 + 1 = 10101010 = -86`
- 4-bit out of range example: `1000 = -8 -> 0111 + 1 = 1000`

How does negation work:

- N- bit 2's complement number is: `bn-1 bn-2 ... b1 b0`
- And it has a value: v = `(-bn-1 x 2^(n-1) + bn-1 x 2^(n-1) ... b1 x 2^1 + b0 x 2^0)`
- And the conversion yields the pattern: `(1-bn-1)(1-bn-2)...(1-b1)(1-b0)`
- The new number has a value: `-(1-bn-1)2^n-1 ... +(1-b0)2^0`

Simply said, we just need to **invert all bits** and then **add `1` to the LSB**.

As seen – two's complement is convinient. Also it is the most commonly encountered scheme defining negative numbers:

- there is one more negative value that a positive value (see `Int Sizes`)
- Bits are lost on overflow: modulo arithmetic (?)

Converting an N-bit 2's complement number to N+P bits is easy:

- 1001 = `-7 -> 11001 = -7 -> 111001 = -7 -> 1111001 = -7`

All needed is just to duplicate the MSB P times and we get the value same as before.

### 1.3.9. Words

In computer architecture word is the smallest addressible unit of data, that can be any number of bits in length.

## 1.4. Numbers and Basic Values

### 1.4.1. Logical Values / Bool

This is a value type whose object value is either `true` or `false`. Integers and strings cannot be used where the Boolean is required – `let boolean: Bool = "YES"` or `let boolean: Bool = 0` will result in compilation error.

```swift
@frozen struct Bool
```

By default `Bool` is initialized as `false`. 

```swift
let someBool = Bool()
someBool // prints 'false'
```

The type  has over 7 initializers that allow to create an instance of this via string literal, RNG, boolean literal and a number. `Bool` can be hashed and compared via `&&` and `||` operators, as well as negated (aka toggled) via `!` operator (`toggle()` method). This type engages `NSNumber` initializers to perform initialization via numbers (probably).

```swift
/// Init via NSNumber #1
/// this is `probably` the initializer of NSNumber:
///
///     public init(truncating number: __shared NSNumber) {
///         self = number.boolValue
///     }
/// NB - `boolValue` is the Boolean representation of `NSNumber`object value
/// 0 value means `false` and everything else means `true`
var nsNumberInitializedTrueBool = Bool.init(truncating: NSNumber(1)) // true
var nsNumberInitializedFalseBool = Bool.init(truncating: NSNumber(0)) // false
var nsNumberInitializedBool = Bool.init(truncating: NSNumber(value: UInt64.max)) // true

/// Init via NSNumber #2
/// this is `probably` the initializer of NSNumber:
///
///     public init?(exactly number: __shared NSNumber) {
///       if number === kCFBooleanTrue as NSNumber || NSNumber(value: 1) == number {
///           self = true
///       } else if number === kCFBooleanFalse as NSNumber || NSNumber(value: 0) == number {
///           self = false
///       } else {
///           return nil
///       }
///     }
var yetAnotherNSNumberBool = Bool.init(exactly: NSNumber(43)) // nil
```

C `bool` and Objective-C `BOOL` are bridged into Swift as `Bool`.

Bool experiments can be found here:

[TCS](https://github.com/daksyonov/TCS)/[Assets](https://github.com/daksyonov/TCS/tree/main/Assets)/[Playgrounds](https://github.com/daksyonov/TCS/tree/main/Assets/Playgrounds)/[stdlib](https://github.com/daksyonov/TCS/tree/main/Assets/Playgrounds/stdlib)/[Bool.playground](https://github.com/daksyonov/TCS/tree/main/Assets/Playgrounds/stdlib/Bool.playground)/[Contents.swift](https://github.com/daksyonov/TCS/blob/main/Assets/Playgrounds/stdlib/Bool.playground/Contents.swift)

### 1.4.2. Number Values / Int

#### 1.4.2.1. Introduction

This is a signed integer value type. Signed here means that `Int` can be negative, so it have a 'sign'.

```swift
@frozen public struct Int: FixedWidthInteger, SignedInteger

/// Technically speaking, the `Int` is only a literal that helps to create the new
/// instance with the same memory representation as the given value
///	
///	public typealias IntegerLiteralType = Int
```

On 32-bit platforms `Int` is the same as `Int32`, on 64-bit platforms `Int` is the same as `Int64`. Each type of `Int` has it's own capacity (fixed size). That means each integer instance has it's own predetermined bit width, resulting in min and max values.

#### 1.4.2.2. Int Sizes

```swift
-----------------------------------------
Signed Integers Min / Max Values
-----------------------------------------
Int8:  from -128 to 127
Int16: from -32768 to 32767
Int32: from -2147483648 to 2147483647
Int64: from -9223372036854775808 to 9223372036854775807
-----------------------------------------

*****************************************

-----------------------------------------
Unsigned Integers Min / Max Values
-----------------------------------------
UInt8:  from 0 to 255
UInt16: from 0 to 65535
UInt32: from 0 to 4294967295
UInt64: from 0 to 18446744073709551615
-----------------------------------------

*****************************************
```

It is clearly seen that `UInt` max values are two times higher than `Int`. That's because unsigned integers does not store negative values, so they have extra capacity. Ranges of both types of integers are the same, but `unsigned` covers more non-negative values.
The range is simple math. Consider on any arch the integer that can store 8 bytes, that will be `2ˆ8-1` or `1111 1111` or `255` in max (256 values from 0 to 255 in total). When the negative range is included, the value is halved:

- `UInt8().max = 2ˆ8-1 = 255`, where 8 is the number of available bits;
- `Int8().max = 2ˆ(8-1)-1 = 127`, where 7 is the number of available bits;

Note – the first bit of the signed integer is the 'sign' bit.

#### 1.4.2.3. Initialization

`Int` can be initialized in various ways, for example it can be formed from the bit-width of the given value. In this case the bit width is truncated if it is equal or greater then the expected type. Also it can calculate the closest value that will fit the width of the receiver. Consider the code below.

```swift
/// If the given value is greater then the maximum value of this type, the result will be the type's maximum value
///
/// 	let threeThousand = Int8.init(clamping: 3000) gives 127
/// 	let minusOne = UInt8.init(clamping: -500) gives 0

/// Truncating Initializer gets the least significant bits if the bit width of input is equal or greater than this type's bit width
let four: Int16 = -500
let five = Int8(truncatingIfNeeded: four) // 12

/// `let five` will be equals to 12 as only 8 bits can be stored in `Int8`
/// and the less significant bits of `four` are `1100` that are `(2^3) + (2^2) = 12`
```

But usually `Int` is initialised from some numeric value.

To structure we can say that `Int` can be initialised from:

- converting other integers: exactly, from a closest match, truncating bit pattern, from a bit patern
- converting floating-point values: given value, `Double`, `Float`, `CGFloat`, `Float16`, `Float80`
- converting floating-point values with no loss of precision: `Double`, `Float`, `Float16`, `Float80` (nil if not representable aka if there is non-zero after the floating point)
- converting strings: ASCII representation (format sensitive – only "123" counts) or ASCII representation passed as radix (or base) (format sensitive as well)
- creating a random integer: `Range`, `ClosedRange`, `ClosedRange` + `RNG`

#### 1.4.2.4. Performing Calculations

Integers can be summed up, subtracted from and multiplied by each other – that's quite expectable by their nature. This is achieved via addition / subtraction / multilication operators (`+` / `-` / `*`) These operators have some constraints:

- type sensitive – arguments (`lhs` & `rhs`) should be of the same type
- operation result should be representable in the arguments' type (overflow prone)

These constraints came from `AdditiveArithmetic`, `Numeric` protocols and 'bit'-nature of integers:

- `AdditiveArithmetic` and `Numeric` protocols impose type sensitivity
- operation result should not be overflown

Division `/` and remainder `%` operations came to integers from `BinaryIntger` protocol:

- for `/` operation any remainder is discarded
- only remainder is returned, e.g. `22 % 4 = 2`

Some constraints here too – arguments should be of the same type.

#### 1.4.2.5. Performing Calculations with Assignment

Calculations with assignment allows to store the result in he `lhs` variable (`(lhs: inout Int, rhs: Int)`). Operations available: addition, subtraction, multiplication, division and remainder-division.
Same constrains apply – overflow-prone & type sensitive.

The main advantage of this operations is that they act as a shorthand and frees you up from writing long constructions with another instance declaration. The drawback is that the varianble on which the operation should be applied has to be variable and maybe sometimes in cases when the code is already messed up it can add up to disorderliness.

#### 1.4.2.6. Performing Masked Arithmetic

Integers are overflow-prone which means if some integer cannot fit the receiver's binary group, this will result in compiler error (if `-0unchecked` is unmarked). Swift gets us covered with some stuff like:

- overflow operators: `&+`, `&-`, `&*`
- overflow assignment operators: `&+=`, `&-=`, `&*=`

These ones work similarly to their non-masked neighbours – they'll silently discard any overflowing bits and wrap the result as a partial value.

Here's what happens, for one, with `UInt8`:

```swift
///           ___ ___ ___ ___ ___ ___ ___ ___
///          | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
///           ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯
var unsignedOverflow = UInt8.max

///	          ___ ___ ___ ___ ___ ___ ___ ___ 
///          | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 
///           ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ 
///						        									   +
///                                       ___
///													        	   | 1 |
///                                       ¯¯¯
///  results in:
///  
///	  ___	 |  ___ ___ ___ ___ ___ ___ ___ ___  
///  | 1 | | | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 
///   ¯¯¯  |  ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯  
/// 
///  This is quite natural – if we add additional binary to the last
///  order, it will be forced to round up by math rules until the last order
///  satisfies the rule. Therefore this calculation results in additional bit
///  that is overflowing. As the UInt8 can hold only 8 bits, all eight zeros
///  are stored in the variable after the calculation.
///  
///  Thereby, the result will be 0.

var overflownRes = unsignedOverflow &+ 1
```

The same same thing, but flip-flopped happens with subtraction. Again, let's tear down `UInt8`:

```swift
///           ___ ___ ___ ___ ___ ___ ___ ___
///          | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
///           ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯
var unsignedOverflow = UInt8.min

///	          ___ ___ ___ ___ ___ ___ ___ ___ 
///          | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 
///           ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ 
///						        									   -
///                                       ___
///														           | 1 |
///                                       ¯¯¯
///  results in:
///  
///    X----- <-- <-- <-- <-- <-- <-- <-- <--
///	  ___	 |  ___ ___ ___ ___ ___ ___ ___ ___  
///  | 0 | | | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 
///   ¯¯¯  |  ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯ ¯¯¯  
/// 
///  Here if we subtract 1 from the 0, we need to 'borrow' the 1 from
///  the next higher order digit.
///  As all bits in this group are 0, abstract 'ninth' bit is needed to borrow the 1
///  So all the bits will turn 1, ninth bit will be 0, but this is an overflowing
///  bit, sot it will not be included in the group
///  
///  Thereby, the result will be 255 aka (2^8)-1.

var overflownRes = unsignedOverflow &- 1
```

Well, another example just to hone things up:

```swift
  ┌───────────────────┐
  │+1 from order shift│
  └───────┬─┬─┬─┬─┬───┘
          │ │ │ │ │
          ▼ ▼ ▼ ▼ ▼
  254     1 1 1 1 1 1 1 0
          │ │ │ │ │ │ │ │
  &+      │ │ │ │ │ │ │ │
          │ ▼ ▼ ▼ ▼ ▼ ▼ ▼
  123     ▼ 1 1 1 1 0 1 1
          ───────────────
  = 121 : 0 1 1 1 1 0 0 1
```

Rule of thumb here:

**For both signed and unsigned integers, overflow in positive direction wraps around from the max value back to the minimum and overflow in negative direction wraps around from the minimum value to the maximum.**

#### 1.4.2.7. Bitwise Operations

As integers are `bitty` by nature, bitwise operations apply to them. General truth table applies too. stdlib provides bitwise `AND` / `OR` / `XOR` / `NOT` operators and let's just quickly recap what they do:

- `AND` (`&`) – if both bit values are set to `1` the result is `1`, otherwise it is `0`
- `OR` (`|`) – if one or both bit values are set to `1` the result is `1`, otherwise it is `0`
- `XOR` (`^`) – if one or the other bit value (*but not the both*) is set to `1`, the result is `1`
- `NOT` (`~`) – values are flipped, so if the bit value was set to `1` if will turn `0` and v/v

These operators have their corresponding shorthand assignmnent neighbours.

#### 1.4.2.8. Bit Shift Operations

Okay, so here we have right shift `>>`, letft shift `<<` and their masking and assignment interpretations. The strange thing that these operators have at least two implementations at a higher level, each one generic. One implementations accepts `<RHS>` genric parameter, and the second accepts `<Other>` generic parameter. Strange as it may sound, but even diff-checking the whole doc page did not lit any more differences, except parameters name. Also in [swift](https://github.com/apple/swift/commits/main)/[stdlib](https://github.com/apple/swift/commits/main/stdlib)/[public](https://github.com/apple/swift/commits/main/stdlib/public)/[core](https://github.com/apple/swift/commits/main/stdlib/public/core)/[Integers.swift](https://github.com/apple/swift/blob/main/stdlib/public/core/Integers.swift) I did not founf the implementation of `<Other>` method, thus let's say that it is just a convenience measure and maybe in future that `<Other>` method will deprecate.

`<<` shifts bits of the receiver to left by the specified number of positions:

```swift
var x: UInt8 = 30 // 0b00011110
let y = x << 2 // 0b01111000 [aka 120 in decimals]

/// Overshift simulation
x >>= 2
x <<= 11 // 0b00000000

/// Using neative value for shift is the same as performing right shift
var a: UInt8 = 30 // 0b00011110
a <<= -3 // 0b00000011
```

`>>` shifts the bits of the receiver to the right by the specified number of positions.

```swift
var x: UInt8 = 30 // 0b00011110
let y = x >> 2 // 0b00000111 [aka 7 in decimals]

/// Overshift applies

/// Using neative value for shift is the same as performing left shift

/// `>>` on negative values fill in the higher bits with 1 and that 1s do not count
```

Spin-off: here I just play around with some integers

```swift
let someNegativeInt: Int8 = -100 // -0b1100100

-100 	=  -1100100 	= 0+0+2^2+0+0+2^5+2^6
-56 	=  -111000 		= 0+0+0+2^3+2^4+2^5
-5 		=  -101 			= 2^0+0+2^2
-11 	=  -1011			= 2^0+2^1+0+2^3
-99 	=  -1100011		= 2^0+2^1+0+0+0+2^5+2^6
```

These operators perform smart shifts aka:

- negative value for left shift's `rhs` performs right shift with the abs value of `rhs`
- if `rhs` value is greater than the `lhs` bit width that results in an overshift – the result will be 0

Their assignment neighbours do the same, but store the result in the lhs variable.

`&<<` and `&>>` are masking shift operators that are used to perform bit shifts within the range of the receiver. 

```swift
let x: UInt8 = 30                 // 0b00011110
let y = x &<< 2

// y == 120                       // 0b01111000
```

That means (in terms of the case above) when the first `1` will fly out of bounds, it will appear in the beginning of the bit width.

#### 1.4.2.9. Some Useful Calculation Methods

Integers can be nagated by `negate()` method that, surprisingly negates the value of an integer. This operation is overflow-prone, e.g. negating `Int8.min` (-128) will result in an overflow error as 128 is not representable in signed 8-bit group. This is not a bitwise negation, thus **this is not something like:**

```swift
for bit in integer.bits {
  bit ~= bit
}
```

This is an arithmetic negation: simply multiplying by 1 and then checking if the result suits the receiver.

Whenever you want to calculate the qoutent and remainder of the integer, it is useful to use the corresponding function that will return the tuple, containing `q` and `r` respectively.

```swift
/// Quotient and Remainder
let x5 = 1000
var (quotient, remainder) = x5.quotientAndRemainder(dividingBy: 21)
/// output: (47, 13)
```

Back to the school class, pals – now there's a time to find if the value is the multiple of some other value. The receiver is the multiple of the given value in case when there is a third value, by which the given value can be multiplied. `Int8.init(15).isMultiple(of: 5) // returns true` because 5*3 is 15. Zero is the multiple of everything.

Edge cases:

- x is multiple of 0 only if x = 0
- `Int8.min.isMultiple(of: -1)` is `true` even though the quotient is not representable in `Int8`.

There are also overflow addition / subtraction / multiplication and division operators that return a tuple contain a Boolean indicating whether an overflow occured and a entire sum or the actual sum if the overflow occured.

```swift
/// Two max Int8 values (127 each, 8-bit group)
let x6 = Int8.max
let x7 = Int8.max

/// Prints `1 1 1 1 1 1 1`
String(Int8.max, radix: 2)

/// Here we get `-2` in decimal system
let x8 = x6 &+ x7

/// Prints `-1 0` (not in 2's comlement)
String(x8, radix: 2)

    1   1   1   1   1   1   1
+   1   1   1   1   1   1   1
-----------------------------
1   1   1   1   1   1   1   0 // overflow here

(-128 + 64 + 32 + 16 + 8 + 4 + 2) = -2
```

#### 1.4.2.10. Operations with Binary Representation

You can get the `bitWidth` of Int instance (`static` and non-`static` `var`) – useful to check what platform (64-32) you're using. Trailing and leading zeros bit count can be checked by `var leadingZeroBitCount: Int { get }` & `var trailingZeroBitCount: Int { get }`.

You can gen the `words` og the integer.

### 1.4.3. Number Values / Double

This is a double-precision floating point value, that can be initialized via:

- converting integers
- converting strings
- converting floating-point values (`Double` and `Float`), creating reounded closest possible representation or approximating the given value
- converting with no-loss of precision (nil-prone)
- creating random value from range or closed range or with rng

As `Int` `Double` comes with all standard arithmetic operations, but also it can calculate the `squareRoot()`.

Doubles can be rounded, compared and comes with more mathematical operations, than Int. You can check magnitude, significand and the exponent. As well as the other operations.

### 1.4.4. Number Values / Float

Same as double but with single precision.

Double vs single precision – double precision is the precision that requires twice more bits then the single precision.

### 1.4.5. Errors / Error

This is a protocol (type) of an error value that can be thrown. Enums are good for errors:

```swift
enum IntError: Error {
  case notANumber(String)
  case overflown(partialResult: String)
}

do { 
	let parsedInt = try Int(validating: "@100")
} catch IntError.notANumber(let invalid) {
  print("error parsing, see character: \(invalid)")
} catch IntError.overflown {
  print("Integer overflow")
}
```

Structs are also good for error-handling if you want to, for one, present the same data types with each error

```swift
struct CoreDataError: Error {
    
    enum ErrorType {
        case noSuchObject
        case noSuchValue
    }
    
    let closelyMatchedObject: NSManagedObject?
    let closelyMatchedValue: KeyPath<NSManagedObject, String>?
  	let errorType: ErrorType?
}

func findObjectAndValue(_ object: String, value: KeyPath) {
    // ...
    throw CoreDataError(
        closelyMatchedObject: object,
        closelyMatchedValue: nil,
      	errorType: .noSuchObject
    )
  	// ...
}
```

Error by default have domain and code that can allow one to distinguish between them. Domain is more high-level concept than code.

As I see from the [source code](https://github.com/apple/swift/blob/main/stdlib/public/core/ErrorType.swift) – Error is a wrapper on NSError.

### 1.4.6. Errors / Result

This type represent either success or a failure including the associated value in each case. This is a slightly wider concept than errors, and technically `Result` does not represent the malfunctioning of some algorithm, rather that it ended in a negative way.

```swift
/// Results and error enum
let results: Result<Bool, Error> = []

enum CurrentInfoError: Error {
  case noTrainerContract
}

/// Method that can throw
func hasTrainerContract() throws -> Bool {
  guard let currentInfo = super.currentInfo else { return }
  
  if currentInfo.hasTrainerContract {
    return true
  } else {
    throw CurrentInfoError.noTrainerContract
  }
}

/// Sampling method
/// Here the things are the following:
/// 	- for 1k times the method tries to check if the user has trainer contract
///		- the result of the operation is appended to the `results` array and it can be either:
/// 		- Result(true, .success)
/// 		- Result(false, .failure)
func sample() {
  for _ in 0..<1000 {
    let sampledReslt = Result { try hasTrainerContract() }
    results.append(sampleResult)
  }
}
```

`Result` can be used in a broader functionality, for one to store the results of `.success` along with the `.failure`. For example `let results: Result<Bool, Error> = []` represents the array of sampled results (LMAO) of the method execution. By iterating over this array we can calculate some statiscital data, perhaps, to get some insights on how this method generally works and decide whether it needs a thorough overhaul.

This type is very handy with some async API, specially when we are waiting some result of asynchronous callback.

```swift

/// This enum defines an error case when there is an empty schedule in the gym
enum FitnessAPIError: Error {
  case emptySchedule
}

/// Sample class to make request to fitness API and try to get the timetable
final class FitnessAPIClient {
  
  class func getClubSchedule(_ completion: @escaping (Result<Data, FitnessAPIError>) -> Void) {
		Moya.rx.request(/* passing the request here */) { response in
      guard let response = response else { return }
                                                     
			let result = Result<Data, FitnessAPIError>
			
			/// Here the result is initiated
			switch response.code {
        case 200:
        	result = .success(response)
        default:
        	result = .failure(.emptySchedule)
      }
    }
  }
}

/// Some scope...

/// Here we try to get some timetable from the API and store the result in Result LMAO
FitnessAPIClient.getClubSchedule { result in 
	switch result {
    case .success(let response):
    	debugPrint(response)
    // or some other custom logic here
    case .failure(let error):
    	print("Error on requesting schedule: \(error, error.localizedDescription)")
  }
}

/// ...Scope ends
```

### 1.4.7. Optionals / Optional

#### 1.4.7.1. Introduction

Optional is a `generic enumeration` that represents either a wrapped value or `nil`.

```swift
@frozen enum Optional<Wrapped>

/// Example optional types:
Int?
Optional<Int>
```

Optional is an enum that contains two cases:

- .none - `nil`
- .some - there is a wrapped value

#### 1.4.7.2. Optional Techniques: `if let` / `guard let` / `switch`

`if let` / `guard let` / `switch` are used to bind the wrapped value to new variable if the value is not `nil`.

```swift
var x: Int? = 3

/// Prints `3`
switch x {
	case .some(let value): // Equivalent to case let value?
    print(value)
	case .none:
    print("it is nil")
}

/// NB - `case nil` is also suitable
switch x {
	case 3:
    print(3)
	case nil:
    print("it is nil")
}
```

#### 1.4.7.3. Optional Techniques: `while let`

This is a loop that terminates when a condition returns `nil`.

```swift
let massiv = [1, 2, 3]
var iterator = massiv.makeIterator()

/// As long as the iterator is not nil, the number is printed
/// If the iterator is nil, the loop is exited
while let i = iterator.next() {
  print(i)
}
```

#### 1.4.7.4. Optional Techniques: `for case let i?`

This is advanced one, but the essence is same as `flatMap()` – this one takes in account only non-nil elements of the sequence. Consider we have an array of optional `Int`s that we formed from an array of strings via `map()` and `Int.init(string)` passed to a transformation closure:

```Swift
let stringNumbers = ["one", "2", "3"]
let optionalInts = stringNumbers.map({ Int($0) })
```

As seen from the above code, `"one"` would produce `nil` as  `Int.init?(_ description: String)` is the failable initializer, though it can return `nil` if it is passed with something it does not expect to handle, e.g. non-integer unicode characters. Say, we wanna iterate over the sequence of `optionalInts`, ignoring any `nil` value there. And here's the interesting way to do this:

```swift
/// Shorthand varint
for case let i? in optionalInts {
    print(i) // prints "2, 3"
}

/// Long variant with case and associated value
for case .some(let i) in optionalInts {
    print(i) // prints "2, 3"
}
```

#### 1.4.7.5. Optional Techniques: `if var`

Instead of using if let, one can use if var to mutate the unwrapped value inside the clause:

```swift
let number = "1"

if var num = number {
  num += 1
  print(num)
}
```

#### 1.4.7.6. Double-wrapped Optionals

Consider that we need to make an array of optional integers based on the array of strings. Here we will use the failable initializer of `Int`:

```swift
let massivOfStrings = ["one", "2", "3"]
let massivOfOptionalInts = massivOfStrings.map{ Int.init($0) } // [nil, Optional(2), Optional(3)]
var massivIterator = massivOfOptionalints.makeIterator()
```

If we try to iterate over this sequence, all three elements, including `nil` will be printed out:

```swift
while let next = iterator.next() {
    print(next, terminator: "")

// prints: nil, Optional(2), Optional(3)
```

That's because the iterator's `next` functions returns optional value, but what's coming to it when the iterator reaches the end is not nil. Technically it's `.some(nil)`. Therefore `nil` will be printed.
NB - `iterator.next()` will return `Optional<Optional<Int>>` or `Int??`

Another case just to hone things up:

```swift
/// Chaining multi-layer optionals
let s1: String?? = nil

/// Here the constant will coalesce with `inner` as it is nil, so the inner coalescence will trigger
(s1 ?? "inner") ?? "outer"

/// Here we put something in the variable and this something holds nil
/// Therefore technically the variable isn't itself nil, it's the wrapped optinal value that is nil
let s2: String?? = .some(nil)

/// So here if we unwrap the optional, inner coalescence does not fire up
/// But when the oprional inside the const is unwrapped, nil is presented to the audience
/// Thereby the `outer` coalescence will set in
(s2 ?? "inner") ?? "outer"
```

#### 1.4.7.7. Optional Chaining

To safely access the property of an optional value, postfix optional chaining operator is used `?`. 

```swift
x?.magnitude // prints `3`
```

The question mark here is the clear sign of that the `magnitude` might not be called. The result, returned via the chained method would also be an optional.

Optional chaining is a flattenning operation which means it comfort the type for us:

```swift
let clubAuthTypeId = currentInfo?.clubAuthType?.last?.clubAuthTypeId // Optional(1)
```

Here what we might get could be `Int????` but that could be troublesome to get through the multi-unwrapping. Swift destroys this discomfort by giving us single optional type. 

#### 1.4.7.8. The nil-coalescing operator

To supply the `default` value aka the value `in-case-the-optional-is-nil` the nil-coalescing operator is used:

```swift
let y = (x ?? 0) + 34 // will be 37 if x has some value and 34 if not
```

Multiple `??` operators can be chained:

```swift
var x: Int? = 3
var y: Int? = 5
var z: Int? = 7

/**
- if x = nil, y != nil, z = nil, the result will be 10
- if x = nil, y = nil, z != nil, the result will be 12
- if x = nil, y = nil, z = nil, the result will be 5
*/
var a = (x ?? y ?? z ?? 0) + 5
```

If you're certain that the value is not `nil` at the point of accessing the variable, you can use forced unwrap operator `!`. If there is nil at the moment of accessing the var, runtime error (aka crash) is triggered.

Optionals can be transformed (`map` / `flatMap`), compared and hashed.

Another way to check the value on nil is to use `~=` operator ` x ~= nil // returns true`.

Concerning ViewControllers, especially when constructing the UI programmatically the common pattern is (1) to declare optional properties and (2) to initialize them in `viewDidLoad()`. In this case technically speaking, they will not be optional after ViewController is set up, but syntactically we will need to unwrap them each time we address them. That will spread the boilerplate code.

```swift
class ProfileViewController: UIViewController {
    private var headerView: HeaderView?
    private var logOutButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        let headerView = HeaderView()
        view.addSubview(headerView)
        self.headerView = headerView

        let logOutButton = UIButton()
        view.addSubview(logOutButton)
        self.logOutButton = logOutButton
        
        // More view configuration
        ...
    }
}

extension ProfileViewController {
    func userDidUpdate(_ user: User) {
        guard let headerView = headerView else {
            // This should never happen, but we still have
            // to maintain this code path.
            return
        }

        headerView.imageView.image = user.image
        headerView.label.text = user.name
    }
}
```

Declaring the `headerView` and the `logoutButton` as `lazy` solves that problem.

```swift
class ProfileViewController: UIViewController {
    private lazy var headerView = HeaderView()
    private lazy var logOutButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(headerView)
        view.addSubview(logOutButton)
        
        // More view configuration
        ...
    }

    func userDidUpdate(_ user: User) {
        headerView.imageView.image = user.image
        headerView.label.text = user.name
    }
}
```

#### 1.4.7.9. Optional `flatMap`

`flatMap` is very similair to `if let` construct as it checks whether the velue to be transformed is an optional or not. Optional chaining is very similar to `flatMap` as it too checks whether ther is something wrapped inside the optional prior to performing some transformation.

#### 1.4.7.10. Optional `compactMap`

This is a fancy way to filter-out nils, somewhat similar to `for case let i? in someSequence.map({ /..transform../ }) { /..do something../ }`

#### 1.4.7.11. Equating Optionals

All optionals can be equated but only if a wrapped type conforms to `Equatable`. If you try to compare optional and non-optional strings, compiler will silently promote non-optional value to optional to make the comparison possible. This implicit conversion goes througout the Swift. For one, take subscripting collections: this takes and returns the optional, no matter what we tried to pass in.

#### 1.4.7.12. Nillifying Dictionaries

`var dictWithNils: [String: Int?] = ["one": 1, "two": 2, "three": nil]` - this dictionary has three keys, and one's value is set to `nil`. Suppose we want to set the second key to `nil`:

- this won't do that: `dictWithNils["two"] = ni`
- this will do: `dictWithNils["two"]? = nil`

#### 1.4.7.13. Compating Optionals

It was someday, but removed in Swift 3.0. Many unexpected results were in place:

- `nil < .some(_) = true`
- `nil < 0 = true`

### 1.4.8. Basic Arithmetic Protocols





## 1.5. Strings And Text

### 1.5.1. Strings and Characters / String

### 1.5.2. Strings and Characters / Character

### 1.5.3. Encoding And Storage / Unicode

### 1.5.4. Compile-TimeStrings / Static String

## 1.6. Collections


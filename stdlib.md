# STDLIB

## Foreword

Exploring [stdlib](https://github.com/apple/swift/tree/main/stdlib) here.

## Spin-Offs

### `@frozen`

Reference - Proposal [SE-2060](https://github.com/apple/swift-evolution/blob/master/proposals/0260-library-evolution.md).

When a library author is certain that there will never be a need to add fields to a struct in future, they may mary that struct as `@frozen`. Marking a structs as frozen only guarantees that stored instance properties won't change. This allows a compiler to perform certain optimizations.

### `@_transparent`

References:

- [Swift Forums](https://forums.swift.org/t/whats-transparent-for/38154/3)
- [swift](https://github.com/apple/swift)/[docs](https://github.com/apple/swift/tree/main/docs)/[TransparentAttr.md](https://github.com/apple/swift/blob/main/docs/TransparentAttr.md)

This marks the operation in `stdlib` as primitive e.g. evaluating an expression, assigning a variable, indexing into an array, calling a method, returning from a method, etc. And there's some other stuff but I shan't serearch more at least for now as this is `not intended for ordinary language users`.

### `@inline`

Inlining is the direct replacing of the function call with the function implementation inside the code. This happens at compile time and provide a great performance boost. It can be used in two ways:

- `@inline(__always)` – inline method always, if possible;
- `@inline(__never)` – never inline the method.

### `@autoclosure`

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

### Binary Overflow

Numbers in Binary systems can be represented from `-2^(n-1)` to `2^(n-1)-1`. Consider the following:

- `Int8().min = -128 = -10000000 = -2^(8-1)`
- `Int8().max = 127 = -10000000 = -2^(8-1)-1`

Overflow happens when some `2n bit` group is appended to existing `2n bit` group and the latter cannot fit the first, e.g. the answer is to large, to fit the receiver.

## Numbers and Basic Values

### Logical Values / Bool

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

### Number Values / Int

#### Introduction

This is a signed integer value type. Signed here means that `Int` can be negative, so it have a 'sign'.

```swift
@frozen public struct Int: FixedWidthInteger, SignedInteger

/// Technically speaking, the `Int` is only a literal that helps to create the new
/// instance with the same memory representation as the given value
///	
///	public typealias IntegerLiteralType = Int
```

On 32-bit platforms `Int` is the same as `Int32`, on 64-bit platforms `Int` is the same as `Int64`. Each type of `Int` has it's own capacity (fixed size). That means each integer instance has it's own predetermined bit width, resulting in min and max values.

#### Int Sizes

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

#### Initialization

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

#### Performing Calculations

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

#### Performing Calculations with Assignment

Calculations with assignment allows to store the result in he `lhs` variable (`(lhs: inout Int, rhs: Int)`). Operations available: addition, subtraction, multiplication, division and remainder-division.
Same constrains apply – overflow-prone & type sensitive.

The main advantage of this operations is that they act as a shorthand and frees you up from writing long constructions with another instance declaration. The drawback is that the varianble on which the operation should be applied has to be variable and maybe sometimes in cases when the code is already messed up it can add up to disorderliness.

#### Performing Masked Arithmetic

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
         ────────────────
  = 121 : 0 1 1 1 1 0 0 1
```

Rule of thumb here:

**For both signed and unsigned integers, overflow in positive direction wraps around from the max value back to the minimum and overflow in negative direction wraps around from the minimum value to the maximum.**

#### Bitwise Operations

As integers are `bitty` by nature, bitwise operations apply to them. General truth table applies too. stdlib provides bitwise `AND` / `OR` / `XOR` / `NOT` operators and let's just quickly recap what they do:

- `AND` (`&`) – if both bit values are set to `1` the result is `1`, otherwise it is `0`
- `OR` (`|`) – if one or both bit values are set to `1` the result is `1`, otherwise it is `0`
- `XOR` (`^`) – if one or the other bit value (*but not the both*) is set to `1`, the result is `1`
- `NOT` (`~`) – values are flipped, so if the bit value was set to `1` if will turn `0` and v/v

These operators have their corresponding shorthand assignmnent neighbours.

#### Bit Shift Operations

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

Calculating right to left will give `2^0+0+2^2+2^3+2^4+0+0+0 = 29`

These operators perform smart shifts aka:

- negative value for left shift's `rhs` performs right shift with the abs value of `rhs`
- if `rhs` value is greater than the `lhs` bit width that results in an overshift – the result will be 0

Their assignment neighbour does the same, but stores the result in the lhs variable.

`&<<` and `&>>` are masking shift operators that are used to perform bit shifts within the range of the receiver. 

```swift
let x: UInt8 = 30                 // 0b00011110
let y = x &<< 2

// y == 120                       // 0b01111000
```

That means (in terms of the case above) when the first `1` will fly out of bounds, it will appear in the beginning of the bit width.

#### Some Useful Calculation Methods

Integers can be nagated by `negate()` method that, surprisingly negates the value of an integer. This operation is overflow-prone, e.g. negating `Int8.min` (-128) will result in an overflow error as 128 is not representable in signed 8-bit group. This is not a bitwise negation, thus this is not something like:

```swift
for bit in integer.bits {
  bit ~= bit
}
```

This is an arithmetic negation, by simply multiplying by 1 and then checking if the result suits the receiver.

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



### Number Values / Double

### Number Values / Float

### Ranges / Range

### Ranges / ClosedRange

### Errors / Error

### Errors / Result

### Optionals / Optional

## Strings And Text

### Strings and Characters / String

### Strings and Characters / Character

### Encoding And Storage / Unicode

### Compile-TimeStrings / Static String

## Collections


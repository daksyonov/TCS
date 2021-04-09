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

## Numbers and Basic Values

### Logical Values / Bool

This is a value type whose value are either `true` or `false`. Integers and strings cannot be used where the Boolean is required – `let boolean: Bool = "YES"` or `let boolean: Bool = 0` will result in compilation error.

```swift
@frozen public struct Bool: Sendable
```

Be default `Bool` is initialized as `false`. 

```swift
let someBool = Bool()
someBool // prints 'false'
```

`Bool` has over 7 initializers that allow to create an instance of this type via string literal, RNG, literal and even string. `Bool` can be hashed and compared via `&&` and `||` operators, as well as negated (aka toggled) via `!` operator (`toggle()` method). This type `probably`can engage `NSNumber` initializers to perform initialization via numbers.

```swift
/// Init via NSNumber
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


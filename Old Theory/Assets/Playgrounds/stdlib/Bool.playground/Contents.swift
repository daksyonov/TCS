import Foundation

// MARK: - Initializers

/// Init with pre-defined value
let bool = Bool.init(true)

/// Init w/o pre-defined value – always `false`
let anotherBool = Bool.init()

/// Init with random value
let randomBool = Bool.random()

/// Init with random value via pre-defined RNG
var rng = SystemRandomNumberGenerator()
let anotherRandomBool = Bool.random(using: &rng)

/// Init via literal
/// This initializer is used by the compiler when you use a Boolean literal
/// In this case both assignments to the `hereWeGoBoolAgain` call this Boolean literal initializer behind the scenes

/**
 Not encouraged to use
 */
var yetAnotherBool = Bool.init(booleanLiteral: true)

/**
 Preferred literal way of initialization
 */
var hereWeGoBoolAgain = false
hereWeGoBoolAgain = true

/// Init from string
/// If the string passed to init is not `true` of `false`, `nil` will be returned
let boolFromString = Bool.init("true")
let nilBoolFromString = Bool.init("ahaha")

/// Init via NSNumber
/// this is `probably` the initializer of NSNumber:
///
///     public init(truncating number: __shared NSNumber) {
///         self = number.boolValue
///     }
/// NB - `boolValue` is the Boolean representation of `NSNumber`object value
/// 0 value means `false` and everything else means `true`
var nsNumberInitializedTrueBool = Bool.init(truncating: NSNumber(1))
var nsNumberInitializedFalseBool = Bool.init(truncating: NSNumber(0))
var nsNumberInitializedBool = Bool.init(truncating: NSNumber(value: UInt64.max))

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
var yetAnotherNSNumberBool = Bool.init(exactly: NSNumber(43))

// MARK: - Bool and Strings

/// Prints the desctiption of the value
anotherBool.description

// MARK: - Bool and Equations

/// Nothing special here, just determining if the booleans are equal
bool == anotherBool

// MARK: Bool and Hashes

/// Boolean value can be hashed
var hasher = Hasher()

bool.hash(into: &hasher)
hasher.finalize()

// MARK: - Operators

/// Logical NOT
!bool

/// Logical AND
/// Combines two booleans and returns true if both of them are true
/// This operator first evaluates `lhs` and `rhs` is evaluated only if `rhs` return true
var logicalAndTest = bool == true && !bool == false

/// Logical OR
/// This operator first evaluates `lhs` and `rhs` is evaluated only if `rhs` return false
/// Here lhs is `false`. sp `rhs` is evaluated
var logicalOrTest = bool == false || !bool == false

// MARK: - Toggling Values

/// This was true and `toggle()` simplt toggles from true to false
yetAnotherBool.toggle()


import Foundation

// MARK: - Integers Capacity

/// Signed
var int8 	= Int8()
var int16 	= Int16()
var int32 	= Int32()
var int64 	= Int64()

/// Unsigned
var uInt8 	= UInt8()
var uInt16 	= UInt16()
var uInt32 	= UInt32()
var uInt64 	= UInt64()

print("-----------------------------------------")
print("Signed Integers Min / Max Values")
print("-----------------------------------------")
print("Int8:  from \(Int8.min) to \(Int8.max)")
print("Int16: from \(Int16.min) to \(Int16.max)")
print("Int32: from \(Int32.min) to \(Int32.max)")
print("Int64: from \(Int64.min) to \(Int64.max)")
print("-----------------------------------------")

print("\n*****************************************\n")

print("-----------------------------------------")
print("Unsigned Integers Min / Max Values")
print("-----------------------------------------")
print("UInt8:  from \(UInt8.min) to \(UInt8.max)")
print("UInt16: from \(UInt16.min) to \(UInt16.max)")
print("UInt32: from \(UInt32.min) to \(UInt32.max)")
print("UInt64: from \(UInt64.min) to \(UInt64.max)")
print("-----------------------------------------")

print("\n*****************************************\n")

func byteArray<T>(from value: T) -> [UInt8] where T: FixedWidthInteger {
	withUnsafeBytes(of: value.bigEndian, Array.init)
}

print("-----------------------------------------")
print("Signed Integers Min / Max Values Bytes")
print("\nUInt8 array = n * 8 bytes, so")
print("min value = (2^(n*8))-1, where")
print("\t - 2 is the highest binary;")
print("\t - n is the count of bytes;")
print("\t - 1 is the last bit of a 'sign'.")
print("\nAs seen in the bytes arrays, the first")
print("negative number is exactly 128, that is")
print("equal to 2^(8-1).")
print("-----------------------------------------")
print("Int8:   from \(byteArray(from: Int8.min)) to \(byteArray(from: Int8.max))")
print("Int16:  from \(byteArray(from: Int16.min)) to \(byteArray(from: Int16.max))")
print("Int32:  from \(byteArray(from: Int32.min)) to \(byteArray(from: Int32.max))")
print("Int64:  from \(byteArray(from: Int64.min)) to \(byteArray(from: Int64.max))")
print("-----------------------------------------")

print("\n*****************************************\n")

print("-----------------------------------------")
print("Unsigned Integers Min / Max Values Bytes")
print("\nUInt8 array = n * 8 bytes, so")
print("max value = 2^((n*8)-1), where")
print("\t - 2 is the highest binary;")
print("\t - n is the count of bytes;")
print("\t - 1 is the last bit of a 'sign'.")
print("\nAs seen in the bytes arrays, the first")
print("positive number is exactly 255, that is")
print("equal to 2^(8-1).")
print("-----------------------------------------")
print("UInt8:  from \(byteArray(from: UInt8.min)) to \(byteArray(from: UInt8.max))")
print("UInt16:  from \(byteArray(from: UInt16.min)) to \(byteArray(from: UInt16.max))")
print("UInt32:  from \(byteArray(from: UInt32.min)) to \(byteArray(from: UInt32.max))")
print("UInt64:  from \(byteArray(from: UInt64.min)) to \(byteArray(from: UInt64.max))")
print("-----------------------------------------")

print("\n*****************************************\n")

// MARK: - Initializing Integers

/// Converting from another integer when sure that source is within target's bounds
/// The code below will compile successfully
let one = Int8.init(5)

/// If something that not conforms to BinatyInteger protocol passed to the initializer, it will return `nil`
let two = Int8.init("two")

/// The code below will not compile because the max of Int8 is 127 = (2^7) - 1
///
/// 	let fiveThousand = Int8.init(one * 1000)

/// Clamping Init creates a new instance with the representable value, closest to the given integer
let three = Int8.init(clamping: 3)

/// If the given value is not greater then the maximum value of this type, the result will be the type's maximum value
///
/// 	let threeThousand = Int8.init(clamping: 3000) gives 127
/// 	let minusOne = UInt8.init(clamping: -500) gives 0

/// Truncating Initializer gets the least significant bits if the bit width of input is equal or greater than this type's bit width
let four: Int16 = -500
let five = Int8(truncatingIfNeeded: four) // 12

four.bitWidth
five.bitWidth
String(four, radix: 2)
let fourLsb = four & 0xFF

let fourLsbBits = String(fourLsb, radix: 2)
let fiveBits = String(five, radix: 2)

/// `let five` will be equals to 12 as only 8 bits can be stored in `Int8`
/// and the less significant bits of `four` are `1100` that are `(2^3) + (2^2) = 12`

/// Initialization via bit pattern
///
/// 	String(bitPatternInitializedInt, radix: 2) ~> 100111
/// This type of initializer also accespts UInt8 (this is a classic representation of a byte)
///
/// 	String(anotherBitPatternInitializedInt, radix: 2) ~> 111000 = 8 + 16 + 32 = 56
let bitPatternInitializedInt = Int8.init(bitPattern: 0b100111)
let anotherBitPatternInitializedInt = Int8.init(bitPattern: UInt8(56))

/// Initialisation via NSNumber (exactly)
/// If there's an overflow, `nil` is returned
let nsNumberInt = Int8.init(exactly: NSNumber(127)) // ok
let anotherNsNumberInt = Int8.init(exactly: NSNumber(128)) // nil

/// Initialisation via NSNumber (truncating)
/// Again
let truncatingNsNumberInt = Int8.init(truncating: NSNumber(168468427))
let anotherTruncatingNsNumberInt = Int8.init(truncating: NSNumber(128))

let exactlyFloatingInt = Int8.init(exactly: 2.24)

/// Initialisation from strings
let stringInitedInt = Int8.init("13")
let anotherStringInitedInt = Int8.init(String(Character("1")))

/// Initialising from a random Integer
let randomIntFromClosedRange = Int.random(in: 2...5)
let randomIntFromRange = Int.random(in: 5..<7)

var rng = SystemRandomNumberGenerator()
let randomintFromRangeAndRNG = Int8.random(in: -10...125, using: &rng)

// MARK: - Performing Calculations

/// Sum
let sum = one + (two ?? 2)
let anotherSum = 21.5 + 23.44

/// Sum should be representable in the argument's type
///
/// 	let erroneousSum = Int8(21) + 120 // results in an overflow
///
/// And arguments should be of the same type
///
///		let anotherErroneousSym = Int16(2) + UInt8(2)
/// 	results in:
///		error: binary operator '+' cannot be applied to operands
///		of type 'Int16' and 'UInt8

/// Division
let res = 2223452345 % 5234523452345

var multiplicant = Int8(5)
multiplicant *= Int8(3)

// MARK: - Overflow Calculation

var unsignedOverflow = UInt8.max - 1
String(unsignedOverflow, radix: 2)
var overflownRes = unsignedOverflow &+ 123
String(overflownRes, radix: 2)

/// >> on negative values
var x: Int8 = -30
String(x, radix: 2)
let r = x >> 2
String(r, radix: 2)

let negativeInt: Int8 = -100
let anotherNegativeInt: Int8 = -56
var anotherNegativeInt2: Int8 = -5
let anotherNegativeInt3: Int8 = -11
let anotherNegativeInt4: Int8 = -99

print("\(negativeInt) = ", String(negativeInt, radix: 2))
print("\(anotherNegativeInt) = ", String(anotherNegativeInt, radix: 2))
print("\(anotherNegativeInt2) = ", String(anotherNegativeInt2, radix: 2))
print("\(anotherNegativeInt3) = ", String(anotherNegativeInt3, radix: 2))
print("\(anotherNegativeInt4) = ", String(anotherNegativeInt4, radix: 2))

anotherNegativeInt2 >>= 2
String(anotherNegativeInt2, radix: 2)

/// Masking shifts
let someInt: UInt8 = 30
String(someInt, radix: 2)
let maskedShiftWithoutOvershift = someInt &<< 2
String(maskedShiftWithoutOvershift, radix: 2)
let maskedShiftWithOvershift = someInt &<< 8
String(maskedShiftWithOvershift, radix: 2)

/// Negating
var x1 = Int8.min
String(x1, radix: 2)

var x2 = -128
String(x2, radix: 2)
x2.negate()
String(x2, radix: 2)

var x3 = 6
x3.negate()
String(x3, radix: 2)

var x4 = -487
String(x4, radix: 2)
x4.negate()
String(x4, radix: 2)

/// Quotient and Remainder
let x5 = 1000
var (quotient, remainder) = x5.quotientAndRemainder(dividingBy: 21)
print((quotient, remainder))


Int8.init(15).isMultiple(of: 5)

Int8.min.isMultiple(of: -1)

/// Two max Int8 values (127 each, 8-bit group)
let x6 = Int8.max
let x7 = Int8.max

/// Prints `1 1 1 1 1 1 1`
String(Int8.max, radix: 2)

/// Here we get `-2` in decimal system
let x8 = x6 &+ x7

/// Prints `-1 0`
String(x8, radix: 2)
x6.addingReportingOverflow(x7).partialValue
String(Int8.max, radix: 2)
String(x6.addingReportingOverflow(x7).partialValue, radix: 2)

Int.init(bitPattern: 0b11100100)

/// Operations of full width
let x9 = Int8(1)
let x10 = x9.multipliedFullWidth(by: 3)
String(x10.low , radix: 2)

Int8(1).bitWidth
Int8.bitWidth
Int.bitWidth


Double.radix
let sign = FloatingPointSign.plus
let exp = -2
let significand = 1.5
let y = pow(Decimal((sign == .minus ? -1 : 1) * Int(significand) * Double.radix), -2)

var double = Double(1.22)
double.addProduct(3, 3.3)


/// Endianness
let x49 = Int16(bitPattern: 0b01110101)
String(x49.littleEndian, radix: 2)
String(x49.bigEndian, radix: 2)

"Hello World!".data(using: .utf8)

for number in stride(from: 0, to: 100, by: 2) {
    print(number)
}

func fourLetters(names: String) -> Int {
	let allowedChars = "ABCDEFGHJKLMNOPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
	
	var res = 0
	var counter = 0
	
	for letter in names {
		if allowedChars.contains(letter) {
			counter += 1
		} else if counter == 4 && letter == " " {
			counter == 0
			res += 1
		} else if letter == names.last && counter == 4 {
			counter == 0
			res += 1
		}
	}
	
	return res
}

let names = "Tror Gvigris Deriana Nori"

fourLetters(names: names)


let firstName: String? = nil
let lastName: String? = nil
var fullName: String? { get { return "\(firstName ?? "John") \(lastName ?? "Doe")" } }
fullName

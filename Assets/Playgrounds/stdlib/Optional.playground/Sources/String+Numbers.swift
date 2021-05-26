/*
 
 Erica Sadun, http://ericasadun.com
 
 */

import Foundation

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif

// --------------------------------------------------
// MARK: Numbers
//
// Note: although it is possible to use built-in Int
//       initializers, e.g. Int(self, radix: 16),
//       these are less flexible as they do not support
//       common prefixes. If you choose to replace
//       the unix calls with Int(_, radix:), return
//       `Int?` and allow the client to coalesce
//
// --------------------------------------------------
// Supports Swift prefixes (0b, 0o, 0x) and Unix (0, 0x / 0X)
public extension String {
	/// Trims prefix from string
	func trim(prefix: String) -> String {
		return hasPrefix(prefix) ? String(dropFirst(prefix.count)) : self
	}

	/// Standard binary prefix
	var binaryPrefix: String { return "0b" }
	
	/// Standard octal prefix
	var octalPrefix: String { return "0o" }
	
	/// Standard hex prefix
	var hexPrefix: String { return "0x" }
	
	/// Converts string to Int value
	var integerValue: Int { return strtol(self, nil, 10) }
	
	/// Converts string to UInt value
	var uintegerValue: UInt { return strtoul(self, nil, 10) }
	
	/// Converts string to Bool value
	var booleanValue: Bool { return integerValue != 0 }
	
	/// Converts string to binary value, ignoring any 0b prefix
	var binaryValue: Int? {
		return Int(trim(prefix: binaryPrefix), radix: 2)
	}
	
	/// Converts string to octal value, ignoring any 0o prefix, supporting 0 prefix
	var octalValue: Int? {
		return Int(trim(prefix: octalPrefix), radix: 8)
	}
	
	/// Converts string to hex value. This supports 0x, 0X prefix if present
	var hexValue: Int? {
		return Int(trim(prefix: hexPrefix).trim(prefix: "0X"), radix: 16)
	}
	
	/// Converts string to its unsigned binary value, ignoring any 0b prefix
	var uBinaryValue: UInt? {
		return UInt(trim(prefix: binaryPrefix), radix: 2)
	}
	
	/// Converts string to its unsigned octal value, ignoring any 0o prefix
	var uOctalValue: UInt? {
		return UInt(trim(prefix: octalPrefix), radix: 8)
	}
	
	/// Converts string to unsigned hex value. This supports 0x prefix if present
	var uHexValue: UInt? {
		return UInt(trim(prefix: hexPrefix).trim(prefix: "0X"), radix: 16)
	}
	
	/// Left pads string to at least `minWidth` characters wide
	func leftPad(_ character: Character, toWidth minWidth: Int) -> String {
		guard minWidth > count else { return self }
		return String(repeating: String(character), count: minWidth - count) + self
	}
}

public extension Int {
	
	/// Convert to binary string, no prefix
	var binaryString: String { return String(self, radix:2) }
	
	/// Convert to octal string, no prefix
	var octalString: String { return String(self, radix:8) }
	
	/// Returns Int's representation as hex string using 0-padding
	/// to represent the smallest standard memory footprint that can
	/// store the value.
	var hexString : String {
		let unpaddedHex = String(self, radix:16, uppercase: true)
		let stringCharCount = unpaddedHex.count
		let desiredPadding = 1 << Swift.max(fls(Int32(stringCharCount - 1)), 1) // Thanks, Greg Titus
		return unpaddedHex.leftPad("0", toWidth: Int(desiredPadding))
	}
}

//
//  NSHashTableWeakTests.swift
//  WeakifiedContainersTests
//
//  Created by Аксёнов Дмитрий Александрович on 30.03.2022.
//

import XCTest


/// Testing `NSHashTable` weak options
final class WeakTableTests: XCTestCase {

	/// https://www.swiftbysundell.com/articles/avoiding-force-unwrapping-in-swift-unit-tests/
	/// https://stackoverflow.com/questions/24127587/how-do-i-declare-an-array-of-weak-references-in-swift
	/// 	@propertyWrapper
	/// 		viewController test
	/// 		NSPointerArray
	///

	// MARK: SUT

	var sut: NSHashTable<Foo>!

	// MARK: Properties

	var foo: Foo?

	// MARK: SUT Lifecycle

	override func setUp() {
		super.setUp()

		sut = NSHashTable<Foo>.weakObjects()
		foo = Foo(1)

	}

	override func tearDown() {
		sut = nil
		foo = nil

		super.tearDown()
	}

	// MARK: Tests

	func testWeakifiedTable() {

		// Arrange

		// Act

		sut.add(foo)

		foo = nil

		// Assert

		XCTAssertEqual(sut.allObjects.count, 0)
	}

	func testWeakifiedTableWithArray() {

		// Arrange

		var fooArray: [Foo]? = [Foo(1), Foo(2)]

		// Act

		for element in fooArray! {
			sut.add(element)
		}

		fooArray = nil

		// Assert
		
		XCTAssertEqual(sut.allObjects.count, 0)
	}
}

// MARK: - Convenience

extension WeakTableTests {

	func makeObjectArray() -> [Foo]? {
		(0..<10).map (Foo.init)
	}
}

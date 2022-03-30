//
//  NSHashTableWeakTests.swift
//  WeakifiedContainersTests
//
//  Created by Аксёнов Дмитрий Александрович on 30.03.2022.
//

import XCTest

@testable import WeakifiedContainers

class WeakTableTests: XCTestCase {

	// MARK: - SUT

	var sut: NSHashTable<Foo>!

	// MARK: - SUT Lifecycle

	override func setUpWithError() throws {
		do {
			try super.setUpWithError()
			sut = NSHashTable<Foo>.weakObjects()
		} catch let error as NSError {
			print(error.userInfo)
			XCTFail("Failed to setup SUT")
		}
	}

	override func tearDownWithError() throws {
		do {
			sut = nil
			try super.tearDownWithError()
		} catch let error as NSError {
			print(error.userInfo)
			XCTFail("Failed to setup SUT")
		}
	}

	// MARK: - Tests

	func testWeakifiedTable() {

		// Arrange

		var foo: Foo? = Foo(1)

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

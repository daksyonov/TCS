//
//  FunctionalWeakifiedTests.swift
//  WeakifiedContainersTests
//
//  Created by Аксёнов Дмитрий Александрович on 30.03.2022.
//

import XCTest


/// Testing functional approach to weakified containing
class FunctionalWeakifiedTests: XCTestCase {

	// MARK: SUT

	var sut: [() -> Foo?]!

	// MARK: Properties

	var foo: Foo?

	// MARK: SUT Lifecycle

	override func setUp() {
		super.setUp()

		sut = [() -> Foo?]()
		foo = Foo(1)
	}

	override func tearDown() {
		sut = nil
		foo = nil

		super.tearDown()
	}

	// MARK: Tests

	func testExample() {

		// Arrange

		// Act

		sut.append({ [weak foo] in foo })

		foo = nil

		// Assert

		XCTAssertNil(sut.first!())
	}
}

//
//  WeakClassTests.swift
//  WeakifiedContainersTests
//
//  Created by Dmitry Aksyonov on 27.03.2022.
//

import XCTest

final class WeakClassTests: XCTestCase {

	// MARK: SUT

	var sut: WeakifiedClass<Foo>!

	// MARK: Tests

	func testObjectsAreNilAfterLocalScope() {

		// Arrange

		var weakPointersArray = [WeakifiedClass<Foo>]()

		// Act

		for i in 0...10 {
			let foo = Foo(i)
			let container = WeakifiedClass<Foo>(withRefType: foo)
			weakPointersArray.append(container)
		}

		// Assert

		weakPointersArray.forEach {
			XCTAssertNil($0.object)
		}
	}

	func testWeakRefIsNilAfterStrongRemoval() {

		// Arrange

		let wrapper = WeakifiedClass<Foo>.init(withRefType: Foo(0))

		var objectRef = wrapper.object

		weak var objectWeakRef = objectRef

		// Act

		objectRef = nil

		// Assert

		XCTAssertNil(objectWeakRef)
	}
}

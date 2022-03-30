//
//  WeakClassTests.swift
//  WeakifiedContainersTests
//
//  Created by Dmitry Aksyonov on 27.03.2022.
//

import XCTest

@testable import WeakifiedContainers

class WeakClassTests: XCTestCase {

	func testObjectsAreNilAfterLocalScope() throws {

		// Arrange

		var weakPointersArray = [WeakifiedClass<Foo>]()

		// Act

		for _ in 0...10 {
			let foo = Foo()
			let container = WeakifiedClass<Foo>(withRefType: foo)
			weakPointersArray.append(container)
		}

		// Assert

		weakPointersArray.forEach {
			XCTAssertNil($0.object)
		}
	}
}

extension WeakClassTests {

	class Foo { }

	struct Boo { }
}


//
//  WeakPointerArrayTest.swift
//  WeakifiedContainersTests
//
//  Created by Dmitry Aksyonov on 31.03.2022.
//

import XCTest

final class WeakPointerArrayTest: XCTestCase {

	// MARK: SUT

	var sut: WeakPointerArray<UIView>!

	// MARK: Properties

	var views: [UIView?]?

	// MARK: SUT Life Cycle

	override func setUp() {
		views = [UIView(), UIView(), UIView()]

		super.setUp()
	}

	override func tearDown() {
		sut = nil
		views?.removeAll()

		super.tearDown()
	}

	// MARK: Tests

	func testPointersArray() {

		// Arrange

		// Act

		sut = WeakPointerArray<UIView>.init(
			elements: views![0]!, views![1]!, views![2]!
		)

		views = nil

		// Assert

		sut.forEach({
			XCTAssertNil($0)
		})
	}
}

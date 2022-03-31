//
//  PropertyWrapperWeakContainerTests.swift
//  WeakifiedContainersTests
//
//  Created by Dmitry Aksyonov on 30.03.2022.
//

import XCTest

final class PropertyWrapperWeakContainerTests: XCTestCase {

	// MARK: SUT

	@WeakElements var sut = [UIView?]()

	// MARK: SUT Lifecycle

	override func setUp() {
		super.setUp()
		sut.removeAll()
	}

	// MARK: Tests

	func testPropertyWrapperWeakifiesElements() {

		// Arrange

		var viewRef: UIView? = UIView()

		// Act

		sut.append(viewRef)

		viewRef = nil

		// Assert

		sut.forEach {
			XCTAssertNil($0)
		}
	}
}

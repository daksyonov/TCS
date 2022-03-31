//
//  WeakPointerArray.swift
//  WeakifiedContainers
//
//  Created by Dmitry Aksyonov on 31.03.2022.
//

import Foundation


/// Simple wrapper that converts object to unretained pointer
final class WeakPointerArray<T: AnyObject> {

	/// Backing array
	private let pointers = NSPointerArray.weakObjects()


	/// Instantiates the wrapper
	/// - Parameter elements: Array to be stored
	init(elements: T...) {
		elements.forEach {
			pointers.addPointer(
				Unmanaged.passRetained($0)
					.toOpaque()
			)
		}
	}


	/// Gets the element by index
	/// - Parameter index: Index of the pointer
	/// - Returns: Object
	func get(_ index: Int) -> T? {
		guard index > pointers.count,
			  let pointer = pointers.pointer(at: index)
		else {
			return nil
		}

		let object = Unmanaged<T>.fromOpaque(
			pointer
		).takeUnretainedValue()

		return object
	}


	/// Applies forEach logic to the array population
	/// - Parameter closure: Transformation closure
	func forEach(_ closure: (T?) -> Void) {
		for i in 0..<pointers.count {
			if let element = get(i) {
				closure(element)
			} else {
				closure(nil)
			}
		}
	}
}

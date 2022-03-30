//
//  WeakifiedTable.swift
//  WeakifiedContainers
//
//  Created by Аксёнов Дмитрий Александрович on 30.03.2022.
//

import Foundation

/// Stores weak references in a hash-table fashioned manner
class WeakifiedTable<T: AnyObject> {

	// MARK: Propterties

	/// Holds wrapped objects
	private var container: NSHashTable<T>

	// MARK: Initializaiton

	/// Instantiates the watpper
	/// - Parameter objects: Ref type object array
	init(objects: [T] = []) {
		container = NSHashTable<T>.init(
			options: .weakMemory,
			capacity: objects.count
		)
	}

	// MARK: Methods

	/// Retrieve all objects as weak refs
	/// - Returns: Weak objects array
	func allObjects() -> [T] {
		container.allObjects
	}

	/// Adds objects to container
	/// - Parameter objects: Object array to be weakified
	func add(objects: [T]) {
		objects.forEach {
			container.add($0)
		}
	}
}

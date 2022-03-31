//
//  PropertyWrapperWeakContainer.swift
//  WeakifiedContainers
//
//  Created by Dmitry Aksyonov on 30.03.2022.
//

import Foundation


/// Container for weak object
struct WeakObject<Object: AnyObject> {

	weak var object: Object?
}

@propertyWrapper
/// Wraps the values into the array of weak elements
struct WeakElements<Collect, Element>
where

/// This conformance needed for init(s:) for Collection
/// Conforming to Array seems redundant as we have backing array inside and this wrapper is meant to be used as array
/// Thus some more abstract type is selected for conformance
Collect: RangeReplaceableCollection,

/// As weaks are optionals we need to excplicitly state that Element should be optional
Collect.Element == Optional<Element>,

/// Ofc, in context of weak refs we're talking on reftypes, nothing new here
Element : AnyObject
{

	// MARK: Properties

	/// Array backing the wrapped value. Holds values, wrapped in WeakObject struct
	private var weakObjects = [WeakObject<Element>]()

	var wrappedValue: Collect {

		/// Returns plain objects from backing struct container
		get { Collect(weakObjects.map { $0.object } ) }

		/// just save the values
		set (newValues) { save(collection: newValues) }
	}

	// MARK: Initialization

	/// Instantiates the wrapper
	init(wrappedValue value: Collect) {
		save(collection: value)
	}

	// MARK: Methods

	/// Saves the collection to feature "back-end"
	/// - Parameter collection: Array of reftypes
	private mutating func save(collection: Collect) {
		weakObjects = collection.map { WeakObject(object: $0) }
	}
}

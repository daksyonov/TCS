//
//  NSHashTableExample.swift
//  WeakifiedContainers
//
//  Created by Аксёнов Дмитрий Александрович on 30.03.2022.
//

final class Foo {

	// Just some vars to occupy memory

	var a = "a"
	var integer = 123456789
	var bool = true

	// Memory address

	var memaddr: String = ""

	var arrayOfThings: Any
	var number: Int


	init(_ numValue: Int) {

		arrayOfThings = [a, integer, bool]
		number = numValue

		memaddr = Unmanaged<Foo>.passUnretained(
			self
		)
		.toOpaque()
		.debugDescription
	}

	deinit {
		print("<\(self): \(memaddr)>: I'm dead.")
	}
}

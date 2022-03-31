//
//  WeakifiedClass.swift
//  WeakifiedContainers
//
//  Created by Dmitry Aksyonov on 27.03.2022.
//

final class WeakifiedClass<T: AnyObject> {

	weak var object: T?

	init(withRefType obj: T?) {
		self.object = obj
	}
}

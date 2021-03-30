//
//  ViewController.swift
//  ConcurrentImageDownload
//
//  Created by Dmitry Aksyonov on 28.03.2021.
//

import UIKit

class ImageListViewController: UITableViewController {
	
	// MARK: - Properties
	
	var imageUrlStrings: [String] =
		[
			"https://images.unsplash.com/photo-1533910534207-90f31029a78e?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=934&q=80",
			"https://images.unsplash.com/photo-1481349518771-20055b2a7b24?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=2009&q=80",
			"https://images.unsplash.com/photo-1529245856630-f4853233d2ea?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=2100&q=80",
			"https://images.unsplash.com/photo-1524678606370-a47ad25cb82a?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=2100&q=80",
			"https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=1868&q=80",
			"https://images.unsplash.com/photo-1524678714210-9917a6c619c2?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=2098&q=80",
			"https://images.unsplash.com/photo-1541100242370-4d536228f2a7?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=1867&q=80",
			"https://images.unsplash.com/photo-1487837647815-bbc1f30cd0d2?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1867&q=80",
			"https://images.unsplash.com/photo-1485256807238-97782da2fa07?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=2102&q=80",
			"https://images.unsplash.com/photo-1506808547685-e2ba962ded60?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=975&q=80"
		]
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
}

// MARK: - Table View

extension ImageListViewController {
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		imageUrlStrings.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(
			withIdentifier: "imageCell",
			for: indexPath
		) as? ImageTableViewCell {
			cell.imageURL = URL(string: imageUrlStrings[indexPath.row])!
			return cell
		} else {
			return UITableViewCell()
		}
	}
}

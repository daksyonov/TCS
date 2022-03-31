//
//  ImageCollectionViewController.swift
//  ConcurrentImageDownload
//
//  Created by Dmitry Aksyonov on 29.03.2021.
//

import UIKit

private let reuseIdentifier = "Cell"

class ImageCollectionViewController: UICollectionViewController {
	
	// MARK: - Properties
	
	let imageGroup = DispatchGroup()
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
	
	var imageData = [Data]()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	// MARK: UICollectionViewDataSource
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return imageUrlStrings.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
		
		
		
		for item in 0...3 {
			DispatchQueue.global(qos: .userInitiated).async(group: imageGroup) {
				if let url = URL(string: self.imageUrlStrings[item]) {
					cell.imageURL = url
					print("done first iteration task \(item)")
				}
			}
		}

		for item in 4...imageUrlStrings.endIndex-1 {
			DispatchQueue.global(qos: .userInitiated).async(group: imageGroup) {
				if let url = URL(string: self.imageUrlStrings[item]) {
					cell.imageURL = url
					print("done second iteration task \(item)")
				}
			}
		}

		imageGroup.notify(queue: .main) {
			for imageData in self.imageData {
				cell.contentView.largeContentImage = UIImage(data: imageData)
			}

			self.view.layoutIfNeeded()
		}
		
		return cell
	}
}

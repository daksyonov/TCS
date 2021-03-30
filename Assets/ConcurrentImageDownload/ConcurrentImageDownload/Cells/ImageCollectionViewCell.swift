//
//  ImageCollectionViewCell.swift
//  ConcurrentImageDownload
//
//  Created by Dmitry Aksyonov on 29.03.2021.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet private weak var cellImageView: UIImageView!
	@IBOutlet private weak var proggressSpinner: UIActivityIndicatorView!
	
	override class func awakeFromNib() {
		super.awakeFromNib()
	}
	
	var imageURL: URL? {
		didSet {
			DispatchQueue.main.async { self.cellImageView.image = nil }
			updateCellUI()
		}
	}
	
	private func updateCellUI() {
		if let url = imageURL {
			DispatchQueue.main.async { self.proggressSpinner.startAnimating() }
			
			DispatchQueue.global(qos: .userInitiated).async {
				let urlData = try? Data(contentsOf: url)
				
				DispatchQueue.main.sync {
					if url == self.imageURL, let imageData = urlData {
						self.cellImageView?.image = UIImage(data: imageData)
					}
					self.proggressSpinner.stopAnimating()
				}
			}
		}
	}
}

//
//  ImageTableViewCell.swift
//  ConcurrentImageDownload
//
//  Created by Dmitry Aksyonov on 28.03.2021.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

	@IBOutlet private weak var cellImageView: UIImageView!
	@IBOutlet private weak var proggressSpinner: UIActivityIndicatorView!
	
	var imageURL: URL? {
		didSet {
			cellImageView.image = nil
			updateCellUI()
		}
	}
	
	private func updateCellUI() {
		if let url = imageURL {
			proggressSpinner.startAnimating()
			
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

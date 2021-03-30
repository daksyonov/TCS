import UIKit
import PlaygroundSupport

// MARK: - Initial Setup

PlaygroundPage.current.needsIndefiniteExecution = true

var view = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 500))
var imageView = UIImageView(frame: view.bounds)
imageView.backgroundColor = .cyan
imageView.contentMode = .scaleAspectFit
view.addSubview(imageView)

PlaygroundPage.current.liveView = view

let imageUrl = URL(
	string: "https://images.unsplash.com/photo-1481349518771-20055b2a7b24?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=2009&q=80"
)!

// MARK: - Classic Download

func fetchImage() {
	
	/**
	Download task is scheduled on the global concurrent queue
	and will run async.
	*/
	
	
	DispatchQueue.global(qos: .utility).async {
		
		/**
		Nothing special here:
		just trying to download the contents of the URL,
		cast it to Data type and then decode this
		to UIImage that will be set as imageView's image
		on the main thread.
		*/
		
		if let data = try? Data(contentsOf: imageUrl) {
			DispatchQueue.main.async {
				imageView.image = UIImage(data: data)
			}
		}
	}
}

// MARK: - URLSession Download

func fetchImageViaURLSession() {
	
	/**
	Same thing but achieved via URLSesision dataTask that is asynchronous by default
	one of closure's parameters is the desired image data
	*/
	
	URLSession.shared.dataTask(with: imageUrl) { data, response, error in
		if let imageData = data {
			DispatchQueue.main.async {
				imageView.image = UIImage(data: imageData)
			}
		}
	}.resume()
}

// MARK: - Download via DispatchWorkItem

func fetchImageViaDispatchWorkItem() {
	var data: Data?
	let workItem = DispatchWorkItem { data = try? Data(contentsOf: imageUrl) }
	
	DispatchQueue.global(qos: .utility).async(execute: workItem)
	
	/**
	'notify' schedules a specific work after the work item block
	has finished it's job.
	No need of 'DispatchQueue.main.async { ... }' here, just specify the type of queue
	that will perform the work after notification is sent
	*/
	
	workItem.notify(
		queue: .main,
		execute: { if let imageData = data {
			imageView.image = UIImage(data: imageData)
		}}
	)
}

// MARK: - Wrapping Up

func loadImageFromURLAsync(
	imageURL: URL,
	executionQueue: DispatchQueue,
	completionQueue: DispatchQueue,
	completion: @escaping (UIImage?, Error?) -> ()
)
{
	executionQueue.async {
		do {
			let data = try Data(contentsOf: imageURL)
			completionQueue.async { completion(UIImage(data: data), nil) }
		} catch let error as NSError {
			completionQueue.async { completion(nil, error) }
		}
	}
}

loadImageFromURLAsync(
	imageURL: imageUrl,
	executionQueue: .global(qos: .utility),
	completionQueue: .main
) { result, _ in
	guard let image = result else { return }
	imageView.image = image
}

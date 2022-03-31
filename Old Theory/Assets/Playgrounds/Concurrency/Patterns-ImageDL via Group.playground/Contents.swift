import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// MARK: - Properties

var view = EightImages(frame: CGRect(x: 0, y: 0, width: 200, height: 500))
view.backgroundColor = UIColor.red

let imageURLs = [
	"http://www.planetware.com/photos-large/F/france-paris-eiffel-tower.jpg",
	"https://nshipster.com/assets/swift-documentation-method-declaration-f71f126f04b44df90e59fe61fd46842999817db5edaf3d8c07c2d4cba3a2c4314fed743a27ad42670b7db557134d49118a04dd2a63a2f208f64f11092d927e07.png",
	"http://bestkora.com/IosDeveloper/wp-content/uploads/2016/12/Screen-Shot-2017-01-17-at-9.33.52-PM.png",
	"https://www.utoronto.ca/sites/default/files/GettyImages-171795023.jpg"
]
var images = [UIImage] ()

PlaygroundPage.current.liveView = view

// MARK: - Methods

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


/**
Downloads images asynchronously in group
- Important: Images won't show until all of them have been d/l
- Attention: Errors are not handled properly
*/
func asyncGroup() {
	print("------- Forming async tasks group -------")
	
	let asyncGroup = DispatchGroup()
	
	// passing all images to group via for loop
	
	for i in 0...3 {
		asyncGroup.enter()
		
		loadImageFromURLAsync(
			imageURL: URL(string: imageURLs[i])!,
			executionQueue: .global(qos: .userInitiated),
			completionQueue: .main,
			completion: { result, error in
				guard let image = result else { return }
				images.append(image)
				asyncGroup.leave()
			}
		)
	}
	
	asyncGroup.notify(queue: .main) {
		for i in 0...3 {
			view.ivs[i].image = images[i]
		}
	}
}

/**
Classic way via URLSession
- Important: images update in realtime one-by-one
- Attention: Errors are not handled properly
*/
func asyncViaURLSession() {
	print("---- Classic way via URLSession ----")
	
	for i in 4...7 {
		let url = URL(string: imageURLs[i - 4])
		let request = URLRequest(url: url!)
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			DispatchQueue.main.async {
				print("---- finished with image \(i) ----")
				view.ivs[i].image = UIImage(data: data!)
			}
		}.resume()
	}
}

func mixedDownloadViaGroup() {
	print("---- Forming mixed sync-async tasks group ----")
	
	let asyncGroup = DispatchGroup()
	
	// passing all images to group via for loop
	
	for i in 0...1 {
		asyncGroup.enter()
		
		loadImageFromURLAsync(
			imageURL: URL(string: imageURLs[i])!,
			executionQueue: .global(qos: .userInitiated),
			completionQueue: .main,
			completion: { result, error in
				guard let image = result else { return }
				images.append(image)
				print("----- finished \(i) with priority \(qos_class_self().rawValue) -----")
				asyncGroup.leave()
			}
		)
	}
	
	/**
	It is not critical wether sync or async tasks are appended to group.
	It will do it's job as well and fire the 'notification closure' as soon as all the work is done
	*/
	for i in 2...3 {
		DispatchQueue.global(qos: .userInitiated).async(group: asyncGroup) {
			if let url = URL(string: imageURLs[i]), let data = try? Data(contentsOf: url) {
				images.append(UIImage(data: data)!)
				print("----- finished \(i) with priority \(qos_class_self().rawValue) -----")
			}
		}
	}
	
	asyncGroup.notify(queue: .main) {
		for i in 0...3 {
			view.ivs[i].image = images[i]
		}
	}
}

mixedDownloadViaGroup()
asyncViaURLSession()

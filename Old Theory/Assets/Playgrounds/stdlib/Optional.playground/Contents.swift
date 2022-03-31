import Foundation
import UIKit
import PlaygroundSupport

var urlString = String.init("api.cold.com")

func returnNonOptionalString(string: String) -> URLRequest? {
	URL(string: string).map({ URLRequest(url: $0) })
}

returnNonOptionalString(string: urlString)

let optionalInt: Int? = 4
optionalInt?.magnitude

class MassivClas {
	var massiv: [String]? = ["1", "2", "3"]
}

var masiv: MassivClas? = MassivClas()

if var masivs = masiv {
	masivs = MassivClas()
	masivs.massiv = ["sgfsdfg"]
}



/// Chaining multi-layer optionals
let s1: String?? = nil

/// Here the constant will coalesce with `inner` as it is nil, so the inner coalescence will trigger
(s1 ?? "inner") ?? "outer"

/// Here we put something in the variable and this something holds nil
/// Therefore technically the variable isn't itself nil, it's the wrapped optinal value that is nil
let s2: String?? = .some(nil)

/// So here if we unwrap the optional, inner coalescence does not fire up
/// But when the oprional inside the const is unwrapped, nil is presented to the audience
/// Thereby the `outer` coalescence will set in
(s2 ?? "inner") ?? "outer"


///Mapping optionals
let chars: [Character] = ["a", "b", "c"]
let firstChar = chars.first.map({ String($0) })

let arrayOfIntegers: [Int] = [0, 1, 2]
let firstInt = arrayOfIntegers.first.map({ Int($0) })
let flatFirstInt = arrayOfIntegers.first.flatMap({ Int($0) })
print(firstInt, flatFirstInt)

/// Flatmapping everything
let urlString1 = "https://www.objc.io/logo.png"
let view = URL(string: urlString1)
	.flatMap({ try? Data(contentsOf: $0) })
	.flatMap({ UIImage(data: $0) })
	.map({ UIImageView(image: $0) })


PlaygroundPage.current.liveView = view
PlaygroundPage.current.needsIndefiniteExecution = true

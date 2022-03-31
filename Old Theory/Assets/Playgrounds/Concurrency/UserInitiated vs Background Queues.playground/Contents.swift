import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

func ordinaryPriorityTask(_ symbol: String) {
	for i in 1...10 {
		print("\(symbol) – \(i) priority = \(qos_class_self().rawValue)")
	}
}

/**
As serial queue #2 is less prioritized – it's work will be performed at last
Even despite that in imperative way it is called earlier
*/

let serialPriorityQueue1 = DispatchQueue(label: "priority1", qos: .userInitiated)
let serialPriorityQueue2 = DispatchQueue(label: "priority2", qos: .background)

serialPriorityQueue2.async { ordinaryPriorityTask("🥶") }
serialPriorityQueue1.async { ordinaryPriorityTask("🥵") }

/**
OUTPUT:
🥵 – 1 priority = 25
🥵 – 2 priority = 25
🥵 – 3 priority = 25
🥵 – 4 priority = 25
🥵 – 5 priority = 25
🥵 – 6 priority = 25
🥵 – 7 priority = 25
🥵 – 8 priority = 25
🥵 – 9 priority = 25
🥵 – 10 priority = 25
🥶 – 1 priority = 9
🥶 – 2 priority = 9
🥶 – 3 priority = 9
🥶 – 4 priority = 9
🥶 – 5 priority = 9
🥶 – 6 priority = 9
🥶 – 7 priority = 9
🥶 – 8 priority = 9
🥶 – 9 priority = 9
🥶 – 10 priority = 9
*/

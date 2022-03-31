import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

func ordinaryPriorityTask(_ symbol: String) {
	for i in 1...10 {
		print("\(symbol) – \(i) priority = \(qos_class_self().rawValue)")
	}
}

let concurrentPriorityQueue1 = DispatchQueue(label: "priority1", qos: .userInitiated, attributes: .concurrent)
let concurrentPriorityQueue2 = DispatchQueue(label: "priority1", qos: .background, attributes: .concurrent)

concurrentPriorityQueue2.async { ordinaryPriorityTask("🥵") }
concurrentPriorityQueue1.async { ordinaryPriorityTask("🥶") }
   
/**
OUTPUT VARIANT:
🥶 – 1 priority = 25
🥶 – 2 priority = 25
🥶 – 3 priority = 25
🥶 – 4 priority = 25
🥶 – 5 priority = 25
🥶 – 6 priority = 25
🥶 – 7 priority = 25
🥶 – 8 priority = 25
🥶 – 9 priority = 25
🥶 – 10 priority = 25
🥵 – 1 priority = 9
🥵 – 2 priority = 9
🥵 – 3 priority = 9
🥵 – 4 priority = 9
🥵 – 5 priority = 9
🥵 – 6 priority = 9
🥵 – 7 priority = 9
🥵 – 8 priority = 9
🥵 – 9 priority = 9
🥵 – 10 priority = 9
*/

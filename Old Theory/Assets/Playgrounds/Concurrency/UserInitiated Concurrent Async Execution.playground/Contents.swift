import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

func ordinaryPriorityTask(_ symbol: String) {
	for i in 1...10 {
		print("\(symbol) – \(i) priority = \(qos_class_self().rawValue)")
	}
}

/**
Here the execution will go by zig-zag if you will as each time the task is sent to the execution
the system can return to another task
*/

let concurrentPriorityQueue = DispatchQueue(label: "priority1", qos: .userInitiated, attributes: .concurrent)

concurrentPriorityQueue.async { ordinaryPriorityTask("🥵") }
concurrentPriorityQueue.async { ordinaryPriorityTask("🥶") }

/**
OUTPUT VARIANT:
🥶 – 1 priority = 25
🥵 – 1 priority = 25
🥶 – 2 priority = 25
🥵 – 2 priority = 25
🥶 – 3 priority = 25
🥵 – 3 priority = 25
🥶 – 4 priority = 25
🥵 – 4 priority = 25
🥶 – 5 priority = 25
🥵 – 5 priority = 25
🥶 – 6 priority = 25
🥵 – 6 priority = 25
🥶 – 7 priority = 25
🥵 – 7 priority = 25
🥶 – 8 priority = 25
🥵 – 8 priority = 25
🥶 – 9 priority = 25
🥵 – 9 priority = 25
🥶 – 10 priority = 25
🥵 – 10 priority = 25
*/

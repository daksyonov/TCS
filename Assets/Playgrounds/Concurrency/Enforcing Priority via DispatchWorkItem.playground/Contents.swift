import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

func ordinaryPriorityTask(_ symbol: String) {
	for i in 1...10 {
		print("\(symbol) – \(i) priority = \(qos_class_self().rawValue)")
	}
}

func highPriorityTask(_ symbol: String) {
	for i in 1...10 {
		print("\(symbol) – \(i) HIGH priority = \(qos_class_self().rawValue)")
	}
}

let concurrentPriorityQueue1 = DispatchQueue(label: "priority1", qos: .userInitiated, attributes: .concurrent)
let concurrentPriorityQueue2 = DispatchQueue(label: "priority1", qos: .background, attributes: .concurrent)

let highPriorityItem = DispatchWorkItem(
	qos: .userInteractive,
	flags: [.enforceQoS],
	block: {
		highPriorityTask("🌸")
	}
)

concurrentPriorityQueue2.async { ordinaryPriorityTask("🥵") }
concurrentPriorityQueue1.async { ordinaryPriorityTask("🥶") }

concurrentPriorityQueue2.async(execute: highPriorityItem)
concurrentPriorityQueue1.async(execute: highPriorityItem)

/**
OUTPUT VARIANT:
🌸 – 1 HIGH priority = 33
🥶 – 1 priority = 25
🌸 – 1 HIGH priority = 33
🌸 – 2 HIGH priority = 33
🌸 – 2 HIGH priority = 33
🌸 – 3 HIGH priority = 33
🥶 – 2 priority = 25
🌸 – 4 HIGH priority = 33
🌸 – 5 HIGH priority = 33
🌸 – 3 HIGH priority = 33
🥶 – 3 priority = 25
🌸 – 4 HIGH priority = 33
🌸 – 6 HIGH priority = 33
🌸 – 5 HIGH priority = 33
🥶 – 4 priority = 25
🌸 – 6 HIGH priority = 33
🌸 – 7 HIGH priority = 33
🥶 – 5 priority = 25
🌸 – 7 HIGH priority = 33
🥶 – 6 priority = 25
🌸 – 8 HIGH priority = 33
🥶 – 7 priority = 25
🌸 – 8 HIGH priority = 33
🌸 – 9 HIGH priority = 33
🥶 – 8 priority = 25
🌸 – 9 HIGH priority = 33
🌸 – 10 HIGH priority = 33
🥶 – 9 priority = 25
🌸 – 10 HIGH priority = 33
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

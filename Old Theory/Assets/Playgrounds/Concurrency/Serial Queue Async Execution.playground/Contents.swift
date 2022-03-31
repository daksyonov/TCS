import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

func ordinaryPriorityTask(_ symbol: String) {
	for i in 1...10 {
		print("\(symbol) – \(i) priority = \(qos_class_self().rawValue)")
	}
}

/**
As this is a serial queue even sending tasks asynchronnously
won't take any effect – tasks come and go strictly by FIFO
*/

let privatePriorityQueue = DispatchQueue(label: "priority", qos: .userInitiated)

print(privatePriorityQueue.self)
privatePriorityQueue.async { ordinaryPriorityTask("🥵") }
privatePriorityQueue.async { ordinaryPriorityTask("🥶") }

/**
OUTPUT:
<OS_dispatch_queue_serial: priority>
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
*/

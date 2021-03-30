import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// MARK: - Properties

// Global Main Serial Queue

let mainQueue = DispatchQueue.main

// Global Concurrent Queues

let userInteractiveQueue = DispatchQueue.global(qos: .userInteractive)
let userQueue = DispatchQueue.global(qos: .userInitiated)
let utilityQueue = DispatchQueue.global(qos: .utility)
let backgroundQueue = DispatchQueue.global(qos: .background)

// Global Concurrent Default Queue

let defaultQueue = DispatchQueue.global(qos: .default)

// MARK: - Methods

func ordinaryPriorityTask(_ symbol: String) {
	for i in 1...10 {
		print("\(symbol) – \(i) priority = \(qos_class_self().rawValue)")
	}
}

/*

func highPriorityTask(_ symbol: String) {
	print("\(symbol); HIGH приоритет = \(qos_class_self().rawValue)")
}

*/

print("--------------------------------------------")
print("sync tasks exec")
print("user queue (qos: .userInitiated)")
print("--------------------------------------------")

/**
Here (sync case) tasks execution will go strictly one after another.
First all 10 "🥵" emojis will be printed and then "🥶" will drop in.
Priority will be equivalent.
*/

userQueue.sync { ordinaryPriorityTask("🥵") }
ordinaryPriorityTask("🥶")

sleep(2)

print("--------------------------------------------")
print("async tasks exec")
print("user queue (qos: .userInitiated)")
print("--------------------------------------------")

/**
Here (async case) after asynchronously sending first 10 "🥵" on thread
the control immediately returns to the playground code
invoking the "🥶".
The fisrt task here will be more prioritized and will finish earlier.
*/

userQueue.async { ordinaryPriorityTask("🥵") }
ordinaryPriorityTask("🥶")

sleep(2)

/**
OUTPUT:
--------------------------------------------
sync tasks exec
user queue (qos: .userInitiated)
--------------------------------------------
🥵 – 1 priority = 33
🥵 – 2 priority = 33
🥵 – 3 priority = 33
🥵 – 4 priority = 33
🥵 – 5 priority = 33
🥵 – 6 priority = 33
🥵 – 7 priority = 33
🥵 – 8 priority = 33
🥵 – 9 priority = 33
🥵 – 10 priority = 33
🥶 – 1 priority = 33
🥶 – 2 priority = 33
🥶 – 3 priority = 33
🥶 – 4 priority = 33
🥶 – 5 priority = 33
🥶 – 6 priority = 33
🥶 – 7 priority = 33
🥶 – 8 priority = 33
🥶 – 9 priority = 33
🥶 – 10 priority = 33
--------------------------------------------
async tasks exec
user queue (qos: .userInitiated)
--------------------------------------------
🥵 – 1 priority = 25
🥵 – 2 priority = 25
🥶 – 1 priority = 33
🥵 – 3 priority = 25
🥶 – 2 priority = 33
🥵 – 4 priority = 25
🥶 – 3 priority = 33
🥵 – 5 priority = 25
🥶 – 4 priority = 33
🥵 – 6 priority = 25
🥶 – 5 priority = 33
🥵 – 7 priority = 25
🥶 – 6 priority = 33
🥵 – 8 priority = 25
🥵 – 9 priority = 25
🥶 – 7 priority = 33
🥵 – 10 priority = 25
🥶 – 8 priority = 33
🥶 – 9 priority = 33
🥶 – 10 priority = 33
*/

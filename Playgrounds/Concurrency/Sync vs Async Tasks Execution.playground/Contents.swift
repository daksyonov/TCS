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
		print("\(symbol) – \(i) приоритет = \(qos_class_self().rawValue)")
	}
}

func highPriorityTask(_ symbol: String) {
	print("\(symbol); HIGH приоритет = \(qos_class_self().rawValue)")
}

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
The second task here will be more prioritized and will finish earlier.
*/

userQueue.async { ordinaryPriorityTask("🥵") }
ordinaryPriorityTask("🥶")

sleep(2)

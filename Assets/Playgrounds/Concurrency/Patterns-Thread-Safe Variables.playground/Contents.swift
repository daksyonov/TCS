import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

var view = QueuesView (frame: CGRect(x: 0, y: 0, width: 600, height: 500))
view.numberLines = 10
view.backgroundColor = UIColor.lightGray

view.labels_[0].text  =  "     СИНХРОННОСТЬ  global (qos: .userInitiated) к playground"
view.labels_[1].text  =  "     АСИНХРОННОСТЬ  global (qos: .userInitiated) к playground"
view.labels_[2].text  =  "     СИНХРОННОСТЬ   .serial  к playground"
view.labels_[3].text  =  "     АСИНХРОННОСТЬ  .serial  к playground"
view.labels_[4].text  =  "     .serial Q1 - .userInitiated "
view.labels_[5].text  =  "     .serial     Q1 - .userInitiated Q2 - .background"
view.labels_[6].text  =  "     .concurrent Q - .userInitiated"
view.labels_[7].text  =  "     .concurrent Q1 - .userInitiated  Q2 - .background"
view.labels_[8].text  =  "     .concurrent Q1 - .userInitiated Q2 - .background asyncAfter (0.0)"
view.labels_[9].text  =  "     .concurrent Q1 - .userInitiated Q2 - .background asyncAfter (0.1)"

PlaygroundPage.current.liveView = view

// MARK: - Использование Global Queues

// Глобальная последовательная (serial) main queue

let main = DispatchQueue.main

// Глобальная concurrent.userInitiated dispatch queue

let userQueue = DispatchQueue.global(qos: .userInitiated)

// Глобальная concurrent .utility dispatch queue

let utilityQueue = DispatchQueue.global(qos: .utility)

// Глобальная concurrent .default dispatch queue

let background = DispatchQueue.global()

// Некоторые задания

// MARK: - Properties

var safeString = ThreadSafeString("")
var usualString = ""

// MARK: - Methods

func task(_ symbol: String) {
    for i in 1...10 {
        safeString.addString(string: symbol)
        usualString = usualString + symbol
        
        print("\(symbol) \(i) приоритет = \(qos_class_self().rawValue)")
    }
}

func taskHIGH(_ symbol: String) {
    safeString.addString(string: symbol)
    usualString = usualString + symbol
    
    print("\(symbol) HIGH приоритет = \(qos_class_self().rawValue)")
}

func clearStrings() {
    safeString = ThreadSafeString("")
    usualString = ""
}

// MARK: - Experiments

/**
 #1
 Sync scheduling on concurrent queue
 Control is no returned immediately, so threads do not face race-condition when accessing the strings
 The output will be something like this:
 - thread-safe string:        😀😀😀😀😀😀😀😀😀😀😈😈😈😈😈😈😈😈😈😈
 - non-thread-safe string: 😀😀😀😀😀😀😀😀😀😀😈😈😈😈😈😈😈😈😈😈
 */
print("\n **** SYNC task execution **** ")
print(" **** Global concurrent queue, userInitiated **** ")

let duration0 = duration {
    userQueue.sync { task("😀") }
    task("😈")
}

sleep(1)

view.labels[0].text = safeString.text + String(Float(duration0))

print("\nthread-safe string:     \(safeString.text)")
print("non-thread-safe string: \(usualString)")

/**
 #2
 Async scheduling on concurrent queue
 Strings are cleared beforehand
 Thread safe string is filled asynchronously with emojis and will look like:
 😀😈😈😀😈😈😀😈😀😈😀😈😀😈😀😈😀😈😀😀
 Thread `unsafe` string won't match thread-safe neighbour:
 😈😀😈😈😀😈😀😈😀😈😈😈😀😈😈😀😀😀😀
 */
print("\n **** ASYNC task execution **** ")
print(" **** Global concurrent queue, userInitiated **** ")

clearStrings()

let duration1 = duration {
    userQueue.async { task("😀") }
    task("😈")
}

sleep(1)

view.labels[1].text = safeString.text + String(Float(duration1))
print("\nthread-safe string:     \(safeString.text)")
print("non-thread-safe string: \(usualString)")

/**
 #3
 Sync scheduling on serial queue
 Strings are cleared beforehand
 Output:
 - thread-safe string:        😀😀😀😀😀😀😀😀😀😀😈😈😈😈😈😈😈😈😈😈
 - non-thread-safe string: 😀😀😀😀😀😀😀😀😀😀😈😈😈😈😈😈😈😈😈😈
 */
print("\n **** SYNC task execution **** ")
print(" **** Private serial queue **** ")

let privateSeralQueue = DispatchQueue(label: "com.dimka.serial")

clearStrings()

let duration2 = duration {
    privateSeralQueue.sync { task("😀") }
    task("😈")
}

sleep(1)

view.labels[2].text = safeString.text + String(Float(duration2))
print("\nthread-safe string:     \(safeString.text)")
print("non-thread-safe string: \(usualString)")

/**
 #4
 Aync scheduling on serial queue
 Strings are cleared beforehand
 Output:
 - thread-safe string:        😀😈😈😀😈😀😈😀😈😀😈😀😈😀😈😀😈😀😈😀
 - non-thread-safe string: 😀😈😀😈😀😈😀😈😀😈😀😈😀😈😀😈😀😈😀
 */
print("\n **** ASYNC task execution **** ")
print(" **** Private serial queue **** ")

clearStrings()

let duration3 = duration {
    privateSeralQueue.async { task("😀") }
    task("😈")
}

sleep(1)

view.labels[3].text = safeString.text + String(Float(duration3))
print("\nthread-safe string:     \(safeString.text)")
print("non-thread-safe string: \(usualString)")

/**
 #5
 Aync scheduling on serial priority queue queue
 Strings are cleared beforehand
 Output:
 - thread-safe string:        😀😀😀😀😀😀😀😀😀😀😈😈😈😈😈😈😈😈😈😈
 - non-thread-safe string: 😀😀😀😀😀😀😀😀😀😀😈😈😈😈😈😈😈😈😈😈
 */
print("\n **** ASYNC task execution **** ")
print(" **** Private serial queue **** ")

clearStrings()

let privatePrioritySeralQueue = DispatchQueue(label: "com.dimka.serial", qos: .userInitiated)

let duration4 = duration {
    privatePrioritySeralQueue.async { task("😀") }
    privatePrioritySeralQueue.async { task("😈") }
}

sleep(1)

view.labels[4].text = safeString.text + String(Float(duration4))
print("\nthread-safe string:     \(safeString.text)")
print("non-thread-safe string: \(usualString)")

/**
 #6
 Aync scheduling on serial priority queue
 Strings are cleared beforehand
 Output:
 - thread-safe string:        😀😈😀😀😀😈😀😀😀😀😈😀😀😈😈😈😈😈😈😈
 - non-thread-safe string: 😀😀😈😀😀😀😀😈😀😀😀😈😈😈😈😈😈😈😈
 */
print("\n **** ASYNC task execution **** ")
print(" **** Private serial queue bg queue vs priority queue **** ")

clearStrings()

let backgroundPrivateSerialQueue = DispatchQueue.global(qos: .background)

let duration5 = duration {
    privatePrioritySeralQueue.async { task("😀") }
    backgroundPrivateSerialQueue.async { task("😈") }
}

sleep(1)

view.labels[5].text = safeString.text + String(Float(duration5))
print("\nthread-safe string:     \(safeString.text)")
print("non-thread-safe string: \(usualString)")

/**
 #7
 Aync scheduling on concurrent priority private queue
 Strings are cleared beforehand
 Output:
 - thread-safe string:        😀😈😀😀😀😈😀😀😀😀😈😀😀😈😈😈😈😈😈😈
 - non-thread-safe string: 😀😀😈😀😀😀😀😈😀😀😀😈😈😈😈😈😈😈😈
 */
print("\n **** ASYNC task execution **** ")
print(" **** Private serial queue bg queue vs priority queue **** ")

clearStrings()

let privateConcurrentPriorityQueue = DispatchQueue(
    label: "privatePriorConc",
    qos: .userInitiated,
    attributes: .concurrent
)

let duration6 = duration {
    privateConcurrentPriorityQueue.async { task("😀") }
    privateConcurrentPriorityQueue.async { task("😈") }
}

sleep(1)

view.labels[6].text = safeString.text + String(Float(duration6))
print("\nthread-safe string:     \(safeString.text)")
print("non-thread-safe string: \(usualString)")

/**
 #8
 Aync scheduling on concurrent private queues with different priorities
 Strings are cleared beforehand
 Output:
 - thread-safe string:        😀😈🌺🌺😀😀😈😀😀😀😀😈😀😀😀😈😈😈😈😈😈😈
 - non-thread-safe string: 😀🌺🌺😀😈😀😀😀😀😈😀😀😀😈😈😈😈😈😈😈😈
 */
print("\n **** ASYNC task execution **** ")
print(" **** Private serial queue bg queue vs priority queue **** ")

clearStrings()

let highPriorityItem = DispatchWorkItem (qos: .userInteractive, flags:[.enforceQoS]) {
    taskHIGH("🌺")
}

let backgroundConcurrentPriorityQueue = DispatchQueue(
    label: "privatePriorConc",
    qos: .background,
    attributes: .concurrent
)

let duration7 = duration {
    privateConcurrentPriorityQueue.async { task("😀") }
    backgroundConcurrentPriorityQueue.async { task("😈") }
    
    privateConcurrentPriorityQueue.async(execute: highPriorityItem)
    backgroundConcurrentPriorityQueue.async(execute: highPriorityItem)
}

sleep(1)

view.labels[7].text = safeString.text + String(Float(duration7))
print("\nthread-safe string:     \(safeString.text)")
print("non-thread-safe string: \(usualString)")

/**
 #9
 Aync scheduling on concurrent private queues with different priorities
 Strings are cleared beforehand
 Output:
 - thread-safe string:        😀😈🌺🌺😀😀😈😀😀😀😀😈😀😀😀😈😈😈😈😈😈😈
 - non-thread-safe string: 😀🌺🌺😀😈😀😀😀😀😈😀😀😀😈😈😈😈😈😈😈😈
 */
print("\n **** ASYNC task execution **** ")
print(" **** Private serial queue bg queue vs priority queue **** ")

clearStrings()

let duration8 = duration {
    backgroundConcurrentPriorityQueue.asyncAfter(
        deadline: .now() + 0.0, execute: {
            task("😈")
        })
    
    privateConcurrentPriorityQueue.async { task("😀") }
    
    backgroundConcurrentPriorityQueue.async(execute: highPriorityItem)
    privateConcurrentPriorityQueue.async(execute: highPriorityItem)
}

sleep(1)

view.labels[8].text = safeString.text + String(Float(duration8))
print("\nthread-safe string:     \(safeString.text)")
print("non-thread-safe string: \(usualString)")


/**
 #9
 Aync scheduling on concurrent private queues with different priorities
 Strings are cleared beforehand
 Output:
 - thread-safe string:        😀😈🌺🌺😀😀😈😀😀😀😀😈😀😀😀😈😈😈😈😈😈😈
 - non-thread-safe string: 😀🌺🌺😀😈😀😀😀😀😈😀😀😀😈😈😈😈😈😈😈😈
 */
print("\n **** ASYNC task execution **** ")
print(" **** Private serial queue bg queue vs priority queue **** ")

clearStrings()

let duration9 = duration {
    backgroundConcurrentPriorityQueue.asyncAfter(
        deadline: .now() + 0.0, execute: {
            task("😈")
        })
    
    privateConcurrentPriorityQueue.async { task("😀") }
    
    backgroundConcurrentPriorityQueue.async(execute: highPriorityItem)
    privateConcurrentPriorityQueue.async(execute: highPriorityItem)
}

sleep(1)

view.labels[9].text = safeString.text + String(Float(duration9))
print("\nthread-safe string:     \(safeString.text)")
print("non-thread-safe string: \(usualString)")

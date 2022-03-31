import UIKit
import PlaygroundSupport

// MARK: - Playground Live View

PlaygroundPage.current.needsIndefiniteExecution = true

var view = QueuesView (frame: CGRect(x: 0, y: 0, width: 600, height: 500))
view.numberLines = 10
view.backgroundColor = UIColor.lightGray

view.labels_[0].text  =  "   Sync   |  Global              |  QoS: .userInitiated"
view.labels_[1].text  =  "   Async  |  Global              |  QoS: .userInitiated"
view.labels_[2].text  =  "   Sync   |  Private             |  QoS: not specified"
view.labels_[3].text  =  "   Async  |  Private             |  QoS: not specified"
view.labels_[4].text  =  "   Async  |  Private Serial      |  QoS: not specified"
view.labels_[5].text  =  "   Async  |  Private Serial      |  QoS: bg vs userInitiated"
view.labels_[6].text  =  "   Async  |  Private Concurrent  |  QoS: bg vs userInitiated"
view.labels_[7].text  =  "     .concurrent Q1 - .userInitiated  Q2 - .background"
view.labels_[8].text  =  "     .concurrent Q1 - .userInitiated Q2 - .background asyncAfter (0.0)"
view.labels_[9].text  =  "     .concurrent Q1 - .userInitiated Q2 - .background asyncAfter (0.1)"

PlaygroundPage.setLiveView(PlaygroundPage.current)(view)

// MARK: - Strings

var threadSafeString = ThreadSafeString("")
var nonThreadSafeString = ""

// MARK: - Queues

let serialGlobalUserInitiatedQueue = DispatchQueue.global(qos: .userInitiated)
let serialPrivateQueue = DispatchQueue(label: "com.dimka.serial")
let serialPrivateUserInitiatedQueue = DispatchQueue(
	label: "com.dimka.initiated",
	qos: .userInitiated
)
let serialPrivateBackgroundQueue = DispatchQueue(label: "com.dimka.bgqueue", qos: .background)
let concurrentPrivateUserInitiatedQueue = DispatchQueue(
	label: "com.dimka.concurrent",
	qos: .userInitiated,
	attributes: .concurrent
)
let backgroundConcurrentPriorityQueue = DispatchQueue(
	label: "com.dimka.bgConcurrent",
	qos: .background,
	attributes: .concurrent
)

// MARK: - Methods

func ordinaryPriorityTask(_ symbol: String) {
	for i in 1...10 {
		threadSafeString.addString(string: symbol)
		nonThreadSafeString = nonThreadSafeString + symbol
		
		print("\(symbol) \(i) приоритет = \(qos_class_self().rawValue)")
	}
}

func highPriorityTask(_ symbol: String) {
	threadSafeString.addString(string: symbol)
	nonThreadSafeString = nonThreadSafeString + symbol
	
	print("\(symbol) HIGH приоритет = \(qos_class_self().rawValue)")
}

func flushStringsContent() {
	threadSafeString = ThreadSafeString("")
	nonThreadSafeString = ""
}

// MARK: - Some Kick-Off Info

/**
NB:
Sync task execution returns control to queue only after the task has been executed, thereby locking the queue.
Async task execution returns control immediately after scheduling the task.

`duration` is the variable that is designated to calculate the time spent for each experiment, as well as executing the tasks
*/

// MARK: - Experiments

/**
#1
Sync scheduling on serial global userInitiated priority queue.

Output:
- thread-safe string:        😀😀😀😀😀😀😀😀😀😀😈😈😈😈😈😈😈😈😈😈
- non-thread-safe string: 😀😀😀😀😀😀😀😀😀😀😈😈😈😈😈😈😈😈😈😈

Clarification:
As shown above - first "😀" are added to both strings in a sync manner and then the control returns to the Playground Queue
and it fills the strings with "😈". Therefore strings are filled with symbols in a consistent and consecutive manner.
*/

print("--------------------------------------------------")
print("\tExperiment 1: SYNC task execution")
print("\tserial global userInitiated priority queue")
print("--------------------------------------------------")

let duration0 = duration {
	serialGlobalUserInitiatedQueue.sync { ordinaryPriorityTask("😀") }
	ordinaryPriorityTask("😈")
}

sleep(1)

view.labels[0].text = threadSafeString.text + String(Float(duration0))

print("--------------------------------------------------")
print("\tExperiment 1 Results")
print("\t- thread-safe string:     \(threadSafeString.text)")
print("\t- non-thread-safe string: \(nonThreadSafeString)")
print("--------------------------------------------------")

/**
#2
Async scheduling on serial global userInitiated priority queue.

Strings are cleared beforehand.

The output will be something like this:
- thread-safe string:        😀😈😀😈😀😈😀😈😀😈😈😀😀😈😀😈😀😈😀😈
- non-thread-safe string: 😀😈😀😈😈😈😈😀😀😈😀😈😀😈😀😈😈😀

Clarification:
Bearing in mind the nature of async task scheduling, it's notable that strings are filled with  "😀" and "😈" are in some random order.
Also the strings are not equal.
Thread-safe string is filled firstly with "😀" which means more high priority of the user initiated queue.
*/

print("--------------------------------------------------")
print("\tExperiment 2: ASYNC task execution")
print("\tserial global userInitiated priority queue")
print("--------------------------------------------------")

flushStringsContent()

let duration1 = duration {
	serialGlobalUserInitiatedQueue.async { ordinaryPriorityTask("😀") }
	ordinaryPriorityTask("😈")
}

sleep(1)

view.labels[1].text = threadSafeString.text + String(Float(duration1))

print("--------------------------------------------------")
print("\tExperiment 2 Results")
print("\t- thread-safe string:     \(threadSafeString.text)")
print("\t- non-thread-safe string: \(nonThreadSafeString)")
print("--------------------------------------------------")

/**
#3
Sync scheduling on private serial queue.

Strings are cleared beforehand.

Output:
- thread-safe string:        😀😀😀😀😀😀😀😀😀😀😈😈😈😈😈😈😈😈😈😈
- non-thread-safe string: 😀😀😀😀😀😀😀😀😀😀😈😈😈😈😈😈😈😈😈😈

Clarfication:
Nothing new here – sync task scheduling, control is returned only after the task is finished executing.
Therefore both strings will fill with  "😀" and "😈" in consistent and consecutive manner.
Strings here will be identical as sync task execution (in this very case) does not impose thread-unsafety, so to say.
*/

print("--------------------------------------------------")
print("\tExperiment 3: SYNC task execution")
print("\tserial private queue")
print("--------------------------------------------------")

flushStringsContent()

let duration2 = duration {
	serialPrivateQueue.sync { ordinaryPriorityTask("😀") }
	ordinaryPriorityTask("😈")
}

sleep(1)

view.labels[2].text = threadSafeString.text + String(Float(duration2))

print("--------------------------------------------------")
print("\tExperiment 3 Results")
print("\t- thread-safe string:     \(threadSafeString.text)")
print("\t- non-thread-safe string: \(nonThreadSafeString)")
print("--------------------------------------------------")

/**
#4
Aync scheduling on private serial queue.
Strings are cleared beforehand.

Output:
- thread-safe string:        😀😈😈😀😀😈😀😈😀😈😀😈😀😈😀😈😀😈😀😈
- non-thread-safe string: 😀😀😀😈😀😈😈😀😈😀😈😀😈😀😈😀😈

Clarification:
Nothing new here – sync scheduling, so some mess with the emojis and the order of filling.
The interesting thing here is that non-thread-safe string contains less emojis (18; and can be less, even 16!) than thread-safe (20).
Both of the tasks did not succeed to put all 10 emojis in non-thread safe string.

# TBD: For now let's say that some async concurrency issues provoke this behavior.
*/

print("--------------------------------------------------")
print("\tExperiment 4: ASYNC task execution")
print("\tserial private queue")
print("--------------------------------------------------")

flushStringsContent()

let duration3 = duration {
	serialPrivateQueue.async { ordinaryPriorityTask("😀") }
	ordinaryPriorityTask("😈")
}

sleep(1)

view.labels[3].text = threadSafeString.text + String(Float(duration3))

print("--------------------------------------------------")
print("\tExperiment 4 Results")
print("\t- thread-safe string:     \(threadSafeString.text)")
print("\t- non-thread-safe string: \(nonThreadSafeString)")
print("--------------------------------------------------")

/**
#5
Aync scheduling on private serial user initiated priority queue.

Strings are cleared beforehand.

Output:
- thread-safe string:        😀😀😀😀😀😀😀😀😀😀😈😈😈😈😈😈😈😈😈😈
- non-thread-safe string: 😀😀😀😀😀😀😀😀😀😀😈😈😈😈😈😈😈😈😈😈

Clarification:
Async task sxcheduling, but strings are equal. This shows the serial nature of the queue – tasks are executed 1 by 1,
not concurrently.

- Important: note that despite this experiment queue is the same as the queue from experiment #2 (except this queue is private)
the behaviour is totally different in async scheduling, for refeference see output from ex #2:
- thread-safe string:        😀😈😀😈😀😈😀😈😀😈😈😀😀😈😀😈😀😈😀😈
- non-thread-safe string: 😀😈😀😈😈😈😈😀😀😈😀😈😀😈😀😈😈😀
*/

print("--------------------------------------------------")
print("\tExperiment 5: ASYNC task execution")
print("\tserial private userInitiated queue")
print("--------------------------------------------------")

flushStringsContent()

let duration4 = duration {
	serialPrivateUserInitiatedQueue.async { ordinaryPriorityTask("😀") }
	serialPrivateUserInitiatedQueue.async { ordinaryPriorityTask("😈") }
}

sleep(1)

view.labels[4].text = threadSafeString.text + String(Float(duration4))

print("--------------------------------------------------")
print("\tExperiment 5 Results")
print("\t- thread-safe string:     \(threadSafeString.text)")
print("\t- non-thread-safe string: \(nonThreadSafeString)")
print("--------------------------------------------------")

/**
#6
Aync scheduling on private serial background queue vs private serial userInitiated queue.

Strings are cleared beforehand.

Output:
- thread-safe string:        😀😈😈😈😀😈😈😈😈😀😈😈😈😀😀😀😀😀😀😀
- non-thread-safe string: 😈😀😈😈😈😈😈😈😈😈😀😀😀😀😀😀😀😀

Clarification:
As the user initiated queue has the most priority from the two – it's task will be finished first, despite it was send to execution last.
Moreover the non-thread-safe string is not fully filled with  emojis.
*/

print("--------------------------------------------------")
print("\tExperiment 6: ASYNC task execution")
print("\tserial private userInitiated queue")
print("\tvs")
print("\tserial private background queue")
print("--------------------------------------------------")

flushStringsContent()

let duration5 = duration {
	serialPrivateBackgroundQueue.async { ordinaryPriorityTask("😀") }
	serialPrivateUserInitiatedQueue.async { ordinaryPriorityTask("😈") }
}

sleep(1)

view.labels[5].text = threadSafeString.text + String(Float(duration5))

print("--------------------------------------------------")
print("\tExperiment 6 Results")
print("\t- thread-safe string:     \(threadSafeString.text)")
print("\t- non-thread-safe string: \(nonThreadSafeString)")
print("--------------------------------------------------")

/**
#7
Aync scheduling on concurrent private userInitiated queue.

Strings are cleared beforehand.

Output:
- thread-safe string:        😀😈😀😈😈😀😈😀😈😀😈😀😈😀😈😀😈😀😈😀
- non-thread-safe string: 😀😈😀😀😈😀😈😀😈😀😈😀😈😀😈😀😈😀

Clarification:
As seen from the output, the tasks went almost in zig-zag way gradually filling the strings. This was achieved due to async nature
and the sole queue.

Moreover, non-thread-safe string again failed to fill in.
*/

print("--------------------------------------------------")
print("\tExperiment 7: ASYNC task execution")
print("\tconcurrent private userInitiated queue")
print("--------------------------------------------------")

flushStringsContent()

let duration6 = duration {
	concurrentPrivateUserInitiatedQueue.async { ordinaryPriorityTask("😀") }
	concurrentPrivateUserInitiatedQueue.async { ordinaryPriorityTask("😈") }
}

sleep(1)

view.labels[6].text = threadSafeString.text + String(Float(duration6))

print("--------------------------------------------------")
print("\tExperiment 7 Results")
print("\t- thread-safe string:     \(threadSafeString.text)")
print("\t- non-thread-safe string: \(nonThreadSafeString)")
print("--------------------------------------------------")

/**
#8
Aync scheduling on concurrent private queues with different priorities.

Strings are cleared beforehand.

Output:
- thread-safe string:        😀😈🌺🌺😀😀😈😀😀😀😀😈😀😀😀😈😈😈😈😈😈😈
- non-thread-safe string: 😀🌺🌺😀😈😀😀😀😀😈😀😀😀😈😈😈😈😈😈😈😈
*/
print("--------------------------------------------------")
print("\tExperiment 8: ASYNC task execution")
print("\tconcurrent private background queue")
print("--------------------------------------------------")

flushStringsContent()

let highPriorityItem = DispatchWorkItem (qos: .userInteractive, flags:[.enforceQoS]) {
	highPriorityTask("🌺")
}

let duration7 = duration {
	concurrentPrivateUserInitiatedQueue.async { ordinaryPriorityTask("😀") }
	backgroundConcurrentPriorityQueue.async { ordinaryPriorityTask("😈") }
	
	concurrentPrivateUserInitiatedQueue.async(execute: highPriorityItem)
	backgroundConcurrentPriorityQueue.async(execute: highPriorityItem)
}

sleep(1)

view.labels[7].text = threadSafeString.text + String(Float(duration7))
print("\nthread-safe string:     \(threadSafeString.text)")
print("non-thread-safe string: \(nonThreadSafeString)")

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

flushStringsContent()

let duration8 = duration {
	backgroundConcurrentPriorityQueue.asyncAfter(
		deadline: .now() + 0.0, execute: {
			ordinaryPriorityTask("😈")
		})
	
	concurrentPrivateUserInitiatedQueue.async { ordinaryPriorityTask("😀") }
	
	backgroundConcurrentPriorityQueue.async(execute: highPriorityItem)
	concurrentPrivateUserInitiatedQueue.async(execute: highPriorityItem)
}

sleep(1)

view.labels[8].text = threadSafeString.text + String(Float(duration8))
print("\nthread-safe string:     \(threadSafeString.text)")
print("non-thread-safe string: \(nonThreadSafeString)")


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

flushStringsContent()

let duration9 = duration {
	backgroundConcurrentPriorityQueue.asyncAfter(
		deadline: .now() + 0.0, execute: {
			ordinaryPriorityTask("😈")
		})
	
	concurrentPrivateUserInitiatedQueue.async { ordinaryPriorityTask("😀") }
	
	backgroundConcurrentPriorityQueue.async(execute: highPriorityItem)
	concurrentPrivateUserInitiatedQueue.async(execute: highPriorityItem)
}

sleep(1)

view.labels[9].text = threadSafeString.text + String(Float(duration9))
print("\nthread-safe string:     \(threadSafeString.text)")
print("non-thread-safe string: \(nonThreadSafeString)")

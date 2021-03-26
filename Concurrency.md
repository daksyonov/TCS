## What is GCD and How It Works?

### References

- [Многопоточность (concurrency) в Swift 3. GCD и Dispatch Queues](https://habr.com/post/320152/)
- https://habr.com/post/335756/
- http://greenteapress.com/semaphores/LittleBookOfSemaphores.pdf
- https://stepik.org/course/3278/
- https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/Introduction/Introduction.html#//apple_ref/doc/uid/10000057i-CH1-SW1

### Prologue

By default the app works on the main thread that manages the UI. If some heavy operation like downloading file or scanning a large database is added - UI can freeze.

Definitions:

- queue - queue (🤣) that is used by `closures`(FIFO pattern)
- task  - single piece of work aka `closure`
- thread - sequence of instructions, executed on runtime

Single core CPUs can handle one task at a time on a single thread. Thus 'concurrency' in this case is achieved by rapidly switching between the tasks. Multicore CPUs can delegate each of it's cores to work with some threads (one per core). Both of these technologies use term 'concurrency'.

The main drawback of concurrency is the risk of thread safety. This means that, say, different tasks would want to gain access to same resource (amend one variable simultaneously) or try to gain access to resources, already blocked by other tasks. Such risks can damage the resources or lead to other unpredictable behaviours.

Apple provides the developers with several instruments:

- `Thread` - low level tool for objc method to run @ their own threads of execution 
- `GCD` - languange, runtime and other features to provide concurrency management
- `Operation` - abstract class that represents a single task

*NB
Abstract class is a class that cannot be instantiated, but can be inherited from. It can contain abstract methods and properties. Abstract class `Animal`, can be developed to `class Cat: Animal` or `class Dog: Animal`.*

### Serial & Concurrent Queues

**Serial Queues** - iOS drags out the top task of the stack, w8s until it finihes execution and then drags out next task.
**Concurrent Queues** - iOS drags out top task of the stack, starts it's execution on some thread and if there's a 'free power' left iOS drags out next task and executes it on some other thread while the first (in this case) task is still running. Concurrent queues can save time on tasks execution therefore.

### Synchronous & Asynchronous Task Execution

Sync task execution returns control to queue only after the task has been executed, thereby locking the queue. In contrast async task execution returns control immediately after sending the task on some other queue, thereby not locking the queue.

Consider the code:

```swift
/**
Consider a case when the app needs to download really large amount of data from the Internet and 
notify the developer that download has started (through the console log).
*/

// Huge and clumsy method to download tons of images

func downloadFromImgur() {
  ImgurHelper.getAllImages(count: 1000) { images in                                         
    if images.count == count {
    	CoreDataHelper.container.persistentStorage.images.append(images)
     	print("Download finished, \(count) images saved to persistent store!")
    }
  }
}

// Just a method to show that images are downloading (console output)

func showConsoleMessage() {
  print("The images are downloading!")
}

// MARK: - Sync task execution

DispatchQueue.global(qos: .background).sync { 
	downloadFromImgur()
}

showConsoleMessage()

/**
Here the output will be:
- Download finished, 1000 images saved to persistent store!
- The images are downloading!

This is achieved because of synchronous task execution. 
The console will not print the second phrase until all 1000 images finish 
downloading and are written to the app's store.
*/

// MARK: - Async task execution

DispatchQueue.global(qos: .background).async { 
	downloadFromImgur()
}

showConsoleMessage()

/**
Here the output will be:
- The images are downloading!
- Download finished, 1000 images saved to persistent store!

This is achieved because of asynchronous task execution.
The app does not wait until the 'downloadFromImgur()' finishes 
and returns control immediately.
*/
```

The main trick to be performed by developer is to wisely select the queue to receive tasks and to select appropriate task addition method. Everything else is handled by iOS.

### Use Case: Data Download

Consider the code

```swift
let imageURL: URL = URL(string: "https://imgur.com/i/8HjTE34Rs")!
let queue = DispatchQueue.global(qos: .utility)

// task sent to global queue asynchronously not to lock main queue

queue.async {
	if let data = try? Data(contentsOf: imageURL) {
    
    // when the image data is downloaded we asynchronously return to main queue to set the UIImage
    
    DispatchQueue.main.async { 
    	self.imageView.image = UIImage(data: data)
    }
  }
}
```

### iOS Queue Types

**Serial Global Main Queue** handles all UI operations (`let main = DispatchQueue.main`). This queue has the highest priority amongst others.

**4+ Concurrent Global Background Queues** with differentiating QoS (quality of service) and priority:

1. `.userInteractive` - for tasks that interact with the user, like finger-drawing (user drags the finger / iOS calculates the curve that will be rendered). Though real implementation can show some delay, **main queue** is still listening to user's touches and reacts.
2. `.userInitiated` - for tasks that are initiated by user and request feedback, but not in terms of interactive event; usually can take up to some seconds.
3. `.utility` - for tasks that demand some time to execute, like data downloading or database cleaning / scanning etc; usually the user does not ask these tasks to be executed.
4. `.background` - for tasks not connected to UI at all or not demanding to quick execution time like backups or web sync; these tasks can take hours to complete.
5. `.default` - used when there's no info on QoS.

*NB*
*Needless to say that above listed queues (main + friends) are **system**, thus are actively used by iOS when the app is on run. Therefore user's tasks are not the sole customers of these queues.*

### Main Queue

The sole SERIAL global queue is **main queue**. It is discouraged to perform non-UI high-consuming tasks on this queue not to freeze the UI for the time of task execution and preserve the responsiveness of the UI.

UI-related tasks can be performed only on main queue. This is enforced not only because one usually wants the UI tasks to run fluently but as well because the UI should be protected from spontaneous and desynced operation. Other words - UI's reaction on user's events should be performed strictly in serial and arranged manner. If UI-related tasks would run on concurrent queue, drawing on screen would complete with different speed and that would lead to unpredictable behaviour.
That being said, main queue is a point of ui synchronization so to say.

### Common Concurrency Problems

There are three main problems:

1. Race condition
2. Priority Inversion
3. Deadlock

Race condition case:

```swift
import Dispatch

// Initializing serial queue

var serialQueue = DispatchQueue(label: "", qos: .userInitiated)
var value = "😇"

// Dummy method will change value

func changeValue(variant: Int) {
    
    // sleep operator increases execution time (made intentionally)
    
    sleep(1)
    
    value = value + "🐔"
    print("\(value) - \(variant)")
}

// Trying to change the value async

serialQueue.async { // NB - changing it to 'sync' resolves the race condition
    changeValue(variant: 1)
}

// Here the value did not made it to change in time we access it

value // 😇

// Here's the point where the race condition is revealed
// The 😇 changed to 🦊 before the 🐔 was added
// That clearly represents race conidition

value = "🦊" // 🦊

serialQueue.sync {
    changeValue(variant: 2)
}

// the first opetation (variant 1) will take place presumably somewhere here

value

/**
 the final output will be as follows:
 🦊🐔 - 1
 🦊🐔🐔 - 2
 see? no 😇 here
 */
```


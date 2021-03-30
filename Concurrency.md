# What is GCD and How It Works?

## References

- [Многопоточность (concurrency) в Swift 3. GCD и Dispatch Queues](https://habr.com/post/320152/)
- [Understanding how DispatchQueue.sync can cause deadlocks](https://www.donnywals.com/understanding-how-dispatchqueue-sync-can-cause-deadlocks/ )
- [apple](https://github.com/apple)/[darwin-libpthread](https://github.com/apple/darwin-libpthread)/[include](https://github.com/apple/darwin-libpthread/tree/main/include)/[sys](https://github.com/apple/darwin-libpthread/tree/main/include/sys)/[qos.h](https://github.com/apple/darwin-libpthread/blob/main/include/sys/qos.h)
- https://habr.com/post/335756/
- http://greenteapress.com/semaphores/LittleBookOfSemaphores.pdf
- https://stepik.org/course/3278/
- https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/Introduction/Introduction.html#//apple_ref/doc/uid/10000057i-CH1-SW1

## Definitions

- queue – queue (🤣) that is used by `closures`(FIFO pattern)
- task  – single piece of work aka `closure`
- thread – sequence of instructions, executed on runtime
- resource – almost anything: database / file / time to run the code / CPU core / variable etc

## Prologue

By default the app works on the main thread that manages the UI. If some heavy operation like downloading file or scanning a large database is added - UI can freeze.

Single core CPUs can handle one task at a time on a single thread. Thus 'concurrency' in this case is achieved by rapidly switching between the tasks. Multicore CPUs can delegate each of it's cores to work with some threads (one per core). Both of these technologies use term 'concurrency'.

The main drawback of concurrency is the risk of thread safety. This means that, say, different tasks would want to gain access to same resource (amend one variable simultaneously) or try to gain access to resources, already blocked by other tasks. Such risks can damage the resources or lead to other unpredictable behaviours.

Apple provides the developers with several instruments:

- `Thread` - low level tool for objc method to run @ their own threads of execution 
- `GCD` - languange, runtime and other features to provide concurrency management
- `Operation` - abstract class that represents a single task

*NB
Abstract class is a class that cannot be instantiated, but can be inherited from. It can contain abstract methods and properties. Abstract class `Animal`, can be developed to `class Cat: Animal` or `class Dog: Animal`.*

## Queues

### Serial & Concurrent Queues

**Serial Queues** - iOS drags out the first task, w8s until it finihes execution and then drags out next task.
**Concurrent Queues** - iOS drags out the first task, starts it's execution on some thread and if there's a 'free room' left, iOS drags out next task and executes it on some other thread while the first (in this case) task is still running. Concurrent queues can save time on tasks execution therefore.

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

DispatchQueue.global(qos: .utility).sync { 
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

DispatchQueue.global(qos: .utility).async { 
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

*NB*
*Some say that due to it's blocking nature `sync` calls are encouraged only when the developer is >9000% sure it won't break something.*

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

**Serial Global Main Queue** handles all UI operations (`let main = DispatchQueue.main`). This queue has the highest priority amongst others and the sole serial queue, provided by system.

**4+ Concurrent Global Background Queues** with differentiating QoS (quality of service) and priority:

1. `.userInteractive` - for tasks that interact directly with the user. Though real implementation can show some delay, **main queue** is still listening to user's touches and reacts. Specifying this QoS is a request to run with nearly all available system CPU and I/O bandwith, though it is not energy-efficient for large tasks. Should be limited thus to view drawing, animations, main run loop events.
2. `.userInitiated` - second-highest priority task; not energy-efficient for large undertakings too; usage should be limited to opetiations of short enough duration that the user is unlikely to switch from the task until it's finished. Consider gathering complex data structure from persistent stores to present on the new screen after gathering.
3. `.utility` - for tasks that demand some time to execute, like data downloading or database cleaning / scanning etc; usually the user does not ask these tasks to be executed. This QoS is energy and thermally-efficient and though the progress of this work may be not seen, the effect of such work is user-visible.
4. `.background` - for tasks not connected to UI at all or not demanding to quick execution time like backups or web sync; these tasks can take hours to complete. Also such tasks was not be initiated by user and the user may be unaware of it. This is the most energy and thermally-efficient type of work
5. `.default` - used when there's no info on QoS. This QoS is relatively higher than utility and background QoSs. This should be used only when propagating and restoring QoS class, provided by the system.



6. `.unspecified` - indicates that thread was configured with legacy API that does not support QoS class system.

*NB*
*Needless to say that above listed queues (main + friends) are **system**, thus are actively used by iOS when the app is on run. Therefore user's tasks are not the sole customers of these queues.*

### Main Queue

The sole SERIAL global queue is **main queue**. It is discouraged to perform non-UI high consuming tasks on this queue not to freeze the UI for the time of task execution and thereby preserving UI responsiveness.

UI-related tasks can be performed only on main queue. This is enforced not only because one usually wants the UI tasks to run fluently but as well because the UI should be protected from spontaneous and desynced operations. Other words - UI's reaction on user's events should be performed strictly in serial and arranged (consistent, if you will) manner. If UI-related tasks would run on concurrent queue, drawing on screen would complete with different speed and that would lead to unpredictable behaviour and misleading visual mess.
That being said, main queue is a point of UI synchronization so to say.

### Private Queues

Created on user demand and represent resource-freed (in comparison with system queues) opertaion queues. If no arguments are specified (except the queue label `let myPrivateQueue = DispatchQueue(label: "com.dimka.mySerialQueue")`) upon initialisation – the queue is created as serial by default.

## Common Concurrency Problems

### Introduction

There are three main problems:

1. Race condition
2. Priority Inversion
3. Deadlock

### Race Condition

This is a situation when app's the control flow irrationally accesses the shared resource from multiple threads and performs operations (on this resource) that are inconsistent with the desired logic and leads to unexpected outcomes. Generally this is the design error.

Case 1

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

Case 2 (schematic)

| Thread 1 | Thread 2 | R / W  | Some Integer | Comment                                                      |
| :------: | :------: | :----: | :----------: | :----------------------------------------------------------- |
|   Read   |          |  `<-`  |      0       | Int is `0`, app is reading it from some thread               |
|          |   Read   |  `<-`  |      0       | Int is `0`, app is reading it from some other thread         |
|   += 1   |          | `idle` |      0       | Value is being incremented in-ram by some thread             |
|          |   += 1   | `idle` |      0       | Value is being incremented in-ram by some  other thread      |
|  Write   |          |  `->`  |      1       | Some thread writes the value – now it is `1`                 |
|          |  Write   |  `->`  |      1       | Some other thread (over)writes the value – now it is `1` as well |

Code blocks that produce race condition are called critical zones.

### Priority Inversion

This is the state when the high-prioritized task cannot start execution (aka resources usage) due to less prioritized task had already locked the resources. Thereore high-priority task has to wait until the resources are unlocked.

Case 1: Limited priority inversion

Limitation - consider that in terms of case there is only one resource (consider it a variable); there is only two tasks, running each on its own thread.

```
                                                                                                   
                                     Task B                                                         
             Priority                tries to                 Task A                                
           ^            Task B       gain                     finished        Now Task B            
           |            comes in     access to                and unlocked    gains control         
 High      |                         resources                resource                              
 (Task B)  |                  |----------|                         |-----------|-------->            
           |                  |          |                         |           |                    
           |                  |          |    Task A has           |           |                    
           |                  |          |    already locked       |           |                    
           |                  |          |    the Resource and     |           |                    
           |                  |          |    goes until it's      |           |                    
           |                  |          |    fininshed            |           |                    
           |  Task A          |          |                         |           |                    
           |  locked          |          |   (Priority inversion   |           |                    
 Low       |  resources       |          |   zone here)            |           |                    
 (Task A)  |---------|--------|          |-------------------------|           |                    
           |         |        |          |                         |           |                    
           |         |        |          |                         |           |                    
           |         |        |          |                         |           |                    
           +---------|--------|----------|-------------------------|-----------|------->            
                    T1       T2         T3                        T4          T5                          
```

If task B of high priority sets in **after** the low-priority task A has locked the resource. B has to wait until A frees up the resource, despite B has the highest priority among the two. Saying naturally, their priorities are inverted (see T3-T4). 

Case 2: Unlimited Priority Inversion

Same limitations apply, though additional mid-priority task C added + it is unknown whether there are more tasks.

```
            Priority                                                                               
          ^                                                                                        
          |                                                                                        
 High     |           B appears      B waits                          B locks                      
 (Task B) |                  |----------|                         |------|------------->            
          |                  |          |     Unlimited           |      |                         
          |                  |          |     Priority Inversion  |      |                         
          |                  |          |     Zone                |      |                         
 Mid      |                  |          |                         |      |    • More tasks?                     
 (Task C) |                  |          |        C appears        |      |    • What if after C comes D?                     
          |                  |          |       |---------|       |      |    • B would still wait                     
          |                  |          |     L |         |U      |      |    • What if after D some recurrent task                     
          |                  |          |       |         |       |      |      comes?                     
 Low      |      A locks     |          |       |         |  A unlocks   |    • B could wait forever                     
 (Task A) |---------|--------|          |-------| A waits |-------|      |                         
          |         |        |          |       |         |       |      |                         
          |         |        |          |       |         |       |      |                         
          |         |        |          |       |         |       |      |                         
          +---------|--------|----------|-------|---------|-------|------|------------>            
                   T1       T2         T3      T4        T5      T6     T7                         
```

Here is the same thing, but at T4 comes in task C, which priority is higher that A but lower than B. A/B priorities are already inverted, so B waits for A. But C is higher in priority than A, so the system can decide to put A on hold, force it to wait, unlock the resource for C and let it do it's job.

Enforsing QoS can mitigate priority inversion. For one, creating a task as a `DispatchWorkItem` with flag `[.enforceQoS]` and setting QoS explicitly:

```swift
let highPriorityItem = DispatchWorkItem(
	qos: .userInteractive, // here QoS os explicitly stated
	flags: [.enforceQoS], // here the flag set to enforce QoS regardless of queue-set QoS
	block: {
		highPriorityTask("🌸")
	})
```

can mitigate the risk of priority inversion. If this flag is not set – the item will execute with the priority, inherited from the queue on which it was sent.

### Deadlock

*NB*
*The app usually crashes with `EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)` when the deadlock occurs.*

In short the deadlock is the state when the app is waiting for some resource to be freed when its impossible for this resource to become available.

Deadlock Case (Abstracted)

Consider this is a restaurant where the waiter **synchronously** waits until the chef will serve the soup. but the client did not specified what kind of soup she wants, so the chef cannot serve the soup and **synchronously** asks the waiter to determine the soup type. Now they're **deadlocked** 💀. This means that the client will never receive the soup as the waiter won't move until the chef serves the soup and the chef, in turn will never serve soup until he knows what concrete type of soup to cook.

```swift
import Dispatch

let waiter = DispatchQueue(label: "waiter")
let chef = DispatchQueue(label: "chef")

// synchronously order the soup

waiter.sync {
  print("Waiter: hi chef, please make me 1 soup.")

  // synchronously prepare the soup
  
  chef.sync {
	print("Chef: sure thing! Please ask the customer what soup they wanted.")

		// synchronously ask for clarification
    
    waiter.sync { // waiter is already waiting for chef to finish the operation, so deadlock here
      print("Waiter: Sure thing!")

      print("Waiter: Hello customer. What soup did you want again?")
    }
  }
}

// making any of these three steps async solves the problem
```

## Common iOS Concurrency Patterns

### Image Downloading

[See this playground](https://github.com/daksyonov/TCS/tree/main/Assets/Playgrounds/Concurrency/Patterns-Image%20DL.playground)

### Image Downloading via Dispatch Group

[See this playground](https://github.com/daksyonov/TCS/tree/main/Assets/Playgrounds/Concurrency/Patterns-ImageDL%20via%20Group.playground)

### TableView / CollectionView Image Downloading

[See this project](https://github.com/daksyonov/TCS/tree/main/Assets/ConcurrentImageDownload)

### Thread-Safe Variables & Isolation Queues

*NB*
*All constants `let ` in Swift are thread-sade by default. We *can say that due to facts that constants are:*

- *atomic - set in a single step from the perspective of other threads (regardless of what other threads are executing) ~> it can be safely accessed from other threads*
- *immutable - once initialized, they can't be changed (of course with caveats)*

*Variables, being mutable and and non-atomic (thus not thread-safe) can be exposed to various problems like race condition.*

*The ideal variant of thread safety therefore would be:*

- *reads occure synchronously and on multiple threads*
- *writes occur asynchronously and each separati write is the sole task, the variable is exposed to at a given time*
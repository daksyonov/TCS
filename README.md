# TCS iOS Interview Preparation

## Foreword

Here I write on some theoretic concepts I was asked during interviews.

## ARC

### References:

- https://docs.swift.org/swift-book/LanguageGuide/AutomaticReferenceCounting.html
- https://github.com/apple/swift/blob/d1c87f3c936c41418ee93320e42d523b3f51b6df/stdlib/public/SwiftShims/RefCount.h
- https://docs.huihoo.com/apple/wwdc/2012/session_406__adopting_automatic_reference_counting.pdf
- https://stackoverflow.com/a/42847825/11841185

### What is ARC (+ Definitions)

- **ARC (Automatic Reference Counting)** is the automatic memory management of objects that imposes conventions of managing and transferring ownership.
- **Ownership** is the responsibility of some code to eventually deallocate the object it handles.
- **Reference** is a name by which an object can be pointed to. References in Swift can be `strong`, ` weak` and `unowned`. `Strong` and `weak` are the two levels of strength. `Unowned` is the flavor of `weak`.
- **Reference counter** - the value that increments as new references to an object are created. 

*NB 
Dynamically allocated objects are represented with [`HeapObject`](https://github.com/apple/swift/blob/4fd0671e542299d7805e41cf9426640ab3b399af/stdlib/public/SwiftShims/HeapObject.h) struct, that contains (but not limited to) reference counters. Conceptually an object has three refcounters - `strong`, `weak` and `unowned`.
ARC is not a new runtime memory model / garbage collector / automation for `malloc`.*

### How ARC Works

Each time an instance of an an object is created, ARC allocates a memory fragment to store any information related to that instance. When the object is no longer needed, ARC frees up allocated memory by deallocating the object.
To determine exactly how long to retain the object ARC tracks how many constants and variables are referencing it. Thus ARC will not release the object until there is at least one `strong` reference to it.

### Strong, Weak and Unowned References

#### Strong

Strong reference keeps an object from being deallocated by increasing it's retain count by 1. A declaration of a property is a strong reference by default. Strong references are ok to use with linear relationship (e.g. `ancestor -> child` relationships).

```swift
class Kraken { 
	let tentacle = Tentacle() // strong reference to a child
 }
class Tentacle { 
	let sucker = Sucker() // strong reference to a child
 }
class Sucker { }
```

Strong references can cause **retain cycles** - for instaince when two objects refer each other, or when an object is strongly captured within a closure.

```swift
// MARK: - Mutual Reference

class A { var b: B? = nil }
class B { var a: A? = nil }

let a = A()
let b = B()

/**
Here objects create a retain cycle:
- 'b' property of 'a' references strongly to 'b' object;
- 'a' property of 'b' references strongly to 'a' object;
- these objects cannot be deallocated because they `strongly` pointing to each other.
*/

	a.b = b
	b.a = a

// MARK: - Closure Capturing

class FatBoy {
  private var closure = { }
  private func fart() {
    print("ppppppwwarrrrppppp")
  }
  
  init() {
    self.closure = { // placing [weak self] here would do the deal
    	self.fart() // reference cycle point is here
    }
  }
}
```

#### Weak
Weak references do not protect an object from being deallocated by the ARC. `Weak` does not increase retain count. `Weak` zero-out the pointer to the object. Accessing a weak reference will either return a valid object or `nil`.

```swift
class Kraken {
  
  // this won't compile as weak references should be mutable as they turn to nil at some point
  
  weak let tentacle = Tentacle()
}

class WeakKraken {
  
  // this will compile
  
  weak var tentacle: Tentacle? 
}

// MARK: - Closure Capturing

class FatBoy {
  var closure = { }
  func fart() {
    print("ppppppwwarrrrppppp")
  }
  init() {
    self.closure = { [weak self] in // no retain cycle here
    	self?.fart()
    }
  }
}
```

`weak` are good to use when the object is captured by the closure.

#### Unowned
Unowned reference is less overhead-prone flavour of weak references. Whereas weak performs lots of overhead stuff like runtime maintaining a *scratchpad* of all references marked *'weak'* and dealing with optionals, unowned does not do so, hence cutting the perfomance impact.
**Therefore the `unowned` is a preferred way of referencing but only when is is 100% clear that it's safe to do so.** 

##### Unowned is non-ARC 'weak' aka Obj-C 'assign' or '__unsafe_unretained'
In good ol' times of ObjC, even before the ARC was introduced, there was a property memory management policy called `assign` - that was a default pre-ARC memory policy applied to properties upon declaration. `assign` will not be nilified as soon as the object it holds is deallocated, hence resulting in dangling pointers. 
`assign` is also called `__unsafe_unretained` as the reference of this policy will <u>still point at the original memory address</u> (`__unsafe`), where the object it held used to be, <u>while not increasing the reference count</u> (e.g. not retaining the object; `unretained`).

## What is a Side Table?

They are separate chunks of memory that store object's reference counters and flags(?). Initially objects do not have side tables. They're generated when an object is pointed at by a `weak` pointer, as well as when `strong` or `unowned` counter for an object overflows (exceeeds 32 bits or 4294967300 references).

Instead of directly pointing on an object, `weak` points to a side table, that in its turn points to an object. This allows to safely `nil` the weak reference, since it does not directly points to the object. In contrast `strong` and `unowned` point directly on the object.

```c++
// MARK: - How SideTable is Implemented in Swift Runtime Lib (.cpp)

class HeapObjectSideTableEntry {
  std::atomic<HeapObject*> object;
  SideRableRefCounts refCounts;
}
```

An object with a side table never loses it, thus gaining a side table is a one-way operation.

**NB:** - all refCounters start with 1 extra count.
**NB2:** - refcounts can be also inlinable.

## Object Lifecycle Under ARC
Object's life in Swift is represented by a finite state machine of 5 states: `LIVE ~> DEINITING ~> DEINITED ~> FREED ~> DEAD`

- `LIVE` Object is initialized and being passed "strongly".

- `DENINITNG` Strong RC  = 0, unowned RC > 0, weak RC > 0.

- `DEINITED` Strong RC  = 0, unowned RC = 0, weak RC > 0.

- `FREED` All RCs = 0, side table is freed.

- `DEAD` Object is no more occupying memory.

### Shortcuts

`LIVE ~> DEINITING ~> DEAD` - no weak or unowned refs @ `DEINITING`.
`LIVE ~> DEINITING ~> DEINITED ~> DEAD` - no weak @ `DEINITING`

### Invariants

- When `strong` = 0, object is deinited. `Unowned` references raise assertion failures, `weak` references return `nil`
- `unowned` adds +1 to `strong`, which is decremented after object's `deinit` completes
- `weak` adds +1 to `unowned`, which is decremented after object is freed

## Spin-Off: What is Memory

Memory, at a hardware level, is just a list of bytes. Beyond hardware memory is organized in two levels:
- **Stack** - an array of data where new elements come and go by LIFO principle. Used for static memory allocation (SMA). Variables, allocated on the stack are stored directly in RAM, therefore can be accessed fast. **SMA** allocates fixed amount of memory @ compile time.
  *When a function or a method calls another function or a method, which, in turn, calls another etc. the execution of these functions or methods is suspended untill the very last function is finished executing. This ensures that the most recently allocated block of memory is sure to be the first candidate to leave the party.* Stack is easy to track due to it's nature. It is good to use it when the required amount of memory is predetermined prior to compiling (and is not too big: >1 Mb). In Swift stack stores value types.
- **Heap** - pool of data, allocated @ runtime (dynamic memory allocation or **DMA**), thus hindering memory access performance. In contrast, it's size is limited only by the physical memory (RAM) size. Elements of the heap have no dependencies between each other and can be allocated and deallocated randomly at any time. Heap is harder to track due to dynamic pool-like nature. In Swift heap stores reference types. Every object on the heap has it's own lifetime.

**NB** - in a multi-threaded case each thread will use it's own stack, but they'll share the same heap. Therefore stack is thread-wide, so to say, and heap is application-wide. Stack size for the main thread on iPhone cannot exceed 1MB, nor can be shrunk. Minimum allowed stack size for secondary threads is 16 Kb and it's size should be a multiple of 4 Kb.

### For Escaping Closure

An important note to keep in mind is that in cases where a value stored on a stack is captured by a closure, that value will be copied to the heap so to be available by the time the closure is executed.

## What is @autoreleasepool?
### References
* https://swiftrocks.com/autoreleasepool-in-2019-swift.html

### Intorduction
Autorelese pool stores objects that are sent a release message when the pool block comes to an end.

```objc
@autoreleasepool {
    // Code benefitting from a local autorelease pool.
}
```

**NB -** `autorelease()` releases (by default) these objects at the end of the run loop of the thread being executed. That's because threads are surrrounded by `@autreleasepool`. In pre-ARC era `retain()` and `release()` had to be used to control memory of the program.

```objc
int main(int argc, char * argv[]) {
  @autoreleasepool {
    return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
  }
}
```

### Usage In Swift
Handy when dealing with classes, bridged with ObjC (like `Data`). Their methods can still call `autorelease` meaning that the object will free the memory from itself only at the thread's runloop end. Consider the code below:

```swift
func run() {
    guard let file = Bundle.main.path(forResource: "bigImage", ofType: "png") else {
        return
    }
    for i in 0..<1000000 {
        let url = URL(fileURLWithPath: file)
        let imageData = try! Data(contentsOf: url)
    }
}
```

This will cause a huge mempry spike as Data invokes legacy init that calls `autorelease`. The code below will do the thing.

```swift
autoreleasepool {
    let url = URL(fileURLWithPath: file)
    let imageData = try! Data(contentsOf: url)
}
```

`autoreleasepool` in Swift comes handy with Cocoa (Touch) classes (`UIKit` and Friends).

## What is GCD and How It Works?

### References

- https://habr.com/post/320152/
- https://habr.com/post/335756/
- http://greenteapress.com/semaphores/LittleBookOfSemaphores.pdf
- https://stepik.org/course/3278/
- https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/Introduction/Introduction.html#//apple_ref/doc/uid/10000057i-CH1-SW1

### Prologue

By default the app works on the main thread that manages the UI. If some heavy operation like downloading file or scanning a large database is added - UI can freeze.

Single core CPU can handle one task at a time on a thread. Thus 'concurrency' in this case is achieved by rapidly switching between the tasks. Multicore CPU can delegate it's entire core to each thread to perform some tasks. Both of these technologies use term 'concurrency'.

Main drawback of concurrency is risk of thread safety. This means that, say, different tasks would want to gain access to same resource (amend one variable simultaneously) or try to gain access to resources, already blocked by other tasks. Such risks can damage the resources.

Apple provides the developers with several instruments:

- `Thread` - low level tool for objc method to run @ their own threads of execution 
- `GCD` - languange, runtime and other features to provide concurrency management
- `Operation` - abstract class that represents a task

*NB
Abstract class is a class that cannot be instantiated, but can be inherited from. It can contain abstract methods and properties. Abstract class `Animal`, can be developed to `class Cat: Animal` or `class Dog: Animal`.*

### Serial & Concurrent Queues

- Queue - this is a queue (🤣) that is used by `closures`(FIFO pattern)
- Task  - a single piece of work aka `closure`

**Serial Queues** - iOS drags out the top task of the stack, w8s until it finihes execution and then drags out next task.
**Concurrent Queues** - iOS drags out top task of the stack, starts it's execution on some thread and if there's a 'free power' left iOS drags out next task and executes it on some other thread while the first (in this case) task is still running. Concurrent queues can save time on tasks execution thus.

### Synchronous & Asynchronous Task Execution

Sync task execution returns control to queue only after the task has been executed, thereby locking the queue. In contrast async task execution returns control immediately after sending the task on some other queue, thereby not locking the queue.

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



## What are Binary Trees and How They Work?

## What are Trees and How They Work?

## Could a UIView Have an Origin of Zero (0, 0)?

## What are Property Wrappers?

## What is the Difference Between [string], [weak] and [unowned] Reference?

* https://www.vadimbulavin.com/swift-memory-management-arc-strong-weak-and-unowned/
* https://www.mikeash.com/pyblog/friday-qa-2017-09-22-swift-4-weak-references.html
* https://medium.com/flawless-app-stories/you-dont-always-need-weak-self-a778bec505ef

## What are Closures and How They Work?

## What is the Factory Design Pattern?

* https://refactoring.guru/ru/design-patterns/catalog

## What is the Abstract Factory Design Pattern?

* https://refactoring.guru/ru/design-patterns/catalog

## What is the Facade Design Pattern?

* https://refactoring.guru/ru/design-patterns/catalog

## What is the Decorator Design Pattern?

* https://refactoring.guru/ru/design-patterns/catalog

## What is a Method Dispatch?

* https://www.rightpoint.com/rplabs/switch-method-dispatch-table

## What are the Opaque Types?

## What are Metatypes?

* https://swiftrocks.com/whats-type-and-self-swift-metatypes.html

## How CoreData Handles Multithreaded Access to the Same Data?

## What are SOLID?

* https://www.youtube.com/watch?v=v-2yFMzxqwU

## What is COW?

* https://medium.com/@nitingeorge_39047/copy-on-write-in-swift-b44949436e4f

## How Multithreading in Swift Works?

* https://habr.com/post/320152/
* https://habr.com/ru/post/335756/
* http://greenteapress.com/semaphores/LittleBookOfSemaphores.pdf
* https://stepik.org/course/3278/promo
* https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/Introduction/Introduction.html#//apple_ref/doc/uid/10000057i-CH1-SW1

## What is a Run Loop and How Many of Them Are Present in App's Lifecycle?

## What are The Main Architectural Patterns?

* https://www.youtube.com/watch?v=_kPz7MrejPA

## What are Unit Tests?

## What are UI Tests?

## What is Mutating Testing?

* https://soundcloud.com/podlodka/podlodka-4-mutatsionnoe-testirovanie

## What Are Integrations Tests?

* https://blog.cleancoder.com/uncle-bob/2017/05/05/TestDefinitions.html

## UI Section (get through)

* https://www.youtube.com/watch?v=TQRJXLXhG2o&feature=youtu.be

* https://www.amazon.com/iOS-Core-Animation-Advanced-Techniques-ebook/dp/B00EHJCORC

* https://www.objc.io/issues/3-views/moving-pixels-onto-the-screen/

* https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/using_resp onders_and_the_responder_chain_to_handle_events

* https://www.calayer.com/ https://www.youtube.com/watch?v=Qusz9R39ndw

## Calculate Time Complexity of Insertion Algorithm (Big "O")

## What Algorithms of Sorting There Are?

## How Dictionaries and Sets Work?

## How Sets and Dics Search for Data within Themselves?

## Given the Hash - What Will Dictionary Do with It?

## How the Collision Can be Handled Given Two Equal Hashes in Two Objects?

## How to Authorize in Yandex Music Given the Yandex.Mail Account?

## What Happens if Trigger the Following Code in Serial Queue?

``` swift
DispatchQueue.main.sync {
	/// some code    
	DispatchQueue.main.sync {  
		/// SOME OTHER CODE THAT TRIGGERS DEADLOCK
	}
	/// some other code
}
```

## What Happens if Trigger the Following Code in Serial Queue?

```swift
DispatchQueue.main.async {
	/// some code    
	DispatchQueue.main.sync {  
		/// SOME OTHER CODE THAT TRIGGERS DEADLOCK
	}
	/// some other code
}
```

## What is Stack vs Heap and how swift types are got into this



## Stack vs queue



## Where to store app’s secret keys and passwords etc



## What is GoF?

## What's the Difference Between Public / Private / Fileprivate in Swift?

## What is MVC

## What is MVP

## What is MVVM

## What is VIPER

## What is RIB

## OOP

**Object Oriented Programming** is a paradigm - a way of thinking about how code can be structured and interrelated. Paradigm - roughly a set of conventions that allows the programmer to transmute the technical specification to code. OOP perfeclty fits human perception of life - we live in the world of objects and we understand well what is is. So when the task is assigned to a OOP programmer - she decomposes it to a set of objects and their methods.

The OOP paradigm is based on '4 pillars of OOP' that are discussed below.

### Encapsulation

Encapsulation is the process of enclosing variables and functions in some context (class), within which they are united by the same common feature - they all belong to this context (class). An object of the `Car` class will contain the methods that are necessary for the car to move, start, and so on. Among the properties of the `Car` are tank capacity, tire pressure, kilometers traveled and other metrics. Consider the snippet below. The class encompasses only related functional and properties, excluding anything that goes out of car's scope.

```swift
class Car {
  
  // MARK: - Private
  
  private var odometer: ODO?
  private var fuelTank: FuelTank?
  private var tyres: [Tyre]?
	private var engine: Engine?
  
	private func checkPressure(tyres: [Tyre]) -> Bool { 
  	let res = tyres.forEach({ $0.pressure >= 1.5 })
    return res.reduce(false, &&)
  }
	private func checkFueltank(tank: FuelTank) -> Bool { 
  	return tank.fuelVolume > 0 : true : false
  }
  
  // MARK: - Public
  
  public var door: Door?
  public var odoDigitBar: ODO.tripA?
  public var fuelCap: FuelTank.cap = {
    let cap = self.fuelTank.cap
    return cap
  }()
  
  public func lock() { }
  public func unlock() { }
	public func startEngine() { }
  public func drive() { }
}
```

**NB -** that's good to think of encapsulating methods and properties as a [MECE](https://www.preplounge.com/en/bootcamp.php/case-cracking-toolbox/structure-your-thoughts/mece-principle) exercise.

### Abstraction

Abstraction in general terms is a technique of hiding unnecessary implementation details from the user. The user is exposed only to relevant information via `public` properties or methods. For instance, when our `Car()` starts up, it fires up the `startEngine()` public method. 

```swift
public func startEngine() {
  if self.checkPressure(tyres: self.tyres) && self.checkFueltank(tank: self.fuelTank) {
    self.engine.start()
  }
}
```

As you can see from the snippet - the code from the `startEngine()` fires up the private methods to check whether the car has some bad tyre or the fuel is empty. The user just hits the `startEngine()`, but the program makes some logic abstarcted out in private part.

### Inheritance

The process of a sub class heiring the properties and methods from a super class. This allows to eliminate redundant code. Consider all cars should have at least methods and properties as in our `Car` implementation. If the developer had always to re-write this code - his program would soon become overwhelmed by boilerplate. When it comes to inheritance all your `Lexus: Car` and `Porsche: Car` will share the same `fuelTank` property and `startEngine()` method, because `Car` as their superclass implements them in line with other methods and properties.

### Polymorphism

It is the ability of the methods to be redefined by the same name but with different signature. Swift distinguishes between the following polymorphism types:

- Compile time polymorphism: method overloading - changing method's parameters and their types and quantity
- Run time polymorphism - method overriding - though the signature remains untouched, the behavuour of the method is based on wht object called it

## VC Lifecycle

## App's Lifecycle

## Responder Chain

## SSOT 

https://habr.com/ru/post/524508/

## Atomic vs Non-Atomic

## What Happens if You Assign Superclass Object to Subclass Object? (Inheritance)

```swift
class Animal {  }
class Cat: Animal {  }

let animal = Animal()
let cat = Cat()

cat = Animal() // this is ok, as cat inherits from animal thus having all fields and methods
animal = Cat() // animal may not containt data that cat has, so a compiler error is raised
```

## Memory Leaks in Closures

## What is a Witness Table?



What is KVO
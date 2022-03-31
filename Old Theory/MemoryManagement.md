# Memory Management

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
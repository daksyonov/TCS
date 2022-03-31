# TCS iOS Interview Preparation

## Foreword

Here I write on some theoretic concepts I was asked during interviews.





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

Value types vs Reference Types

Optionals Under the Hood

ARC vs MRC

Structures in Swift

Classes in Swift

Closures

Swift Standard Library (with [GitHub](https://github.com/apple/swift/tree/main/stdlib)!!!)
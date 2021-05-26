# Singleton

Singleton is the creational pattern that guarantees that only one instance of a class will be instantiated (for the lifetime of the routine or the application).

These are singletons:

```swift
let session = URLSession.shared
let defaults = UserDefaults.standard
```

**Advantages:**

- using only one instance
- convenience aka global access
- no need to instantiate same object throughout the app

**Disadvantages:**

- no transparency (easy to lose track of what objects modify and access singleton throughout app's lifecycle)
- not obvious for developer who is not familiar with the codebase
- project can drown in singletons
- hard to test due to persistent state (test should be totally independent)
- resetting singleton state can result in a complex code
- global mutable shared state – many objects modify a singleton from any part of the app
- harder to manage and control async behaviours
- easy to abuse due to advantages
- implicit dependency – a class is dependent on a singleton without clearly expressing this
- any side effects of interacting the singleton can affect other app's 'parties'



> A singleton that manages user-specific state is a code smell.



**Possible substitutions to reach transparency:**

- DI:
  - StoryBoard segues (`prepareForSegue()`) – passing data back and forth
  - `UINavigationcontroller` – passing data view `push` and `pop`

**Wikipedia vs Apple:**

- as per wiki singleton is a *pattern that restricts the instantiation of a class to one*
- as per apple docs singleton provides *globally accessible shared intstance of a class* (no mentioning of single instance)

References:

- [Avoiding Singleton Abuse (objcio)](https://www.objc.io/issues/13-architecture/singletons/)
- [Singleton (wiki)](https://ru.wikipedia.org/wiki/Одиночка_(шаблон_проектирования))
- [Swift Singletons: A Design Pattern to Avoid (With Examples)](https://matteomanferdini.com/swift-singleton/)
- [Managing a Shared Resource Using a Singleton (apple docs)](https://developer.apple.com/documentation/swift/cocoa_design_patterns/managing_a_shared_resource_using_a_singleton)

# Dependency Injection

This is a pattern when a class instance gets some object it depends on passed by another class instance.

**Advantages:**

- no globally accessed mutable state
- clearer to track when and where the shared resource was propagated and altered
- more to other coders unfamiliar with the codebase
- in advanced archs DI is handled by *coordinators* which are great central points

**Disadvantages:**

- hard to refactor existing code to DI if it is not well prepared
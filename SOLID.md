# Single Responsibility Principle (SRP)

Reference: [Single Responsibility Principle in Swift](https://medium.com/movile-tech/single-responsibility-principle-in-swift-61ee11ee81b5)

> *A class should have a unique reason to be changed, or in other words, the class should have a single responsibility.*

Responsibility – a role of a class that it executes and a reson of changing. 
If a class has more than one reason to change, it has more than one responsibility e.g. it has more than one role. So the SRP is broken here.

# Open Closed Principle (OCP)

Reference: [Open-Closed Principle in Swift](https://medium.com/movile-tech/open-closed-principle-in-swift-6d666270953d)

> *Software Entities (class, modules, functions, etc) should be open for extension but closed for modification.*

## Case #1 – Classes and Protocols

```swift
// SCENARIO: ALL WENT OK, BUT FOR WHATEVER REASON WE NEED TO INTRODUCE NEW PERSON TYPE)))

// This class simply defines a person with a name and age

// What if it's changed? Will the OCP be broken. Definitely.

class Person {
    private let name: String
    private let age: Int

    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

// A house that stores some residents ([Person])

// Alternatively we can introduce changes here.
// There will be a need to re-write and re-test the code of House class
// Therefore OCP would be broken as the class will need to be modified

class House {
    private var residents: [Person]

    init(residents: [Person]) {
        self.residents = residents
    }

    func add(_ resident: Person) {
        residents.append(resident)
    }
}
```

Why modifying classes is bad? Because, simply said, it could be avoided if the code were written in another way. So we would have had a little bit more code at start. To elaborate a bit – if we change the `House` class, we break the OCP, if we modify `Person` class, we break OCP as well. It would be good to consider the earlier stage of code design, where the things were projecting.

```swift
// Declaring protocol that will handle all 'residents'

protocol Resident {
  var firstName: String { get }
  var lastName: String { get }
  var daysOfResidence: Int { get }
}

// Person class now conforms to Resident protocol

class Person: Resident {
  var firstName: String
  var lastName: String
  var daysOfResidence: Int
  
  init(firstName: String, lastName: String, days: Int) {
    self.firstName = firstName
    self.lastName = lastName
    self.days = days
  }
}

// House class now conforms to Resident protocol

class House {
  private var residents: [Resident]
  
  init(residents: [Resident]) {
    self.residents = residents
  }
  
  func add(_ resident: Resident) {
    self.residents.append(resident)
  }
}

/**
We can now add as many resident types as we want
nothing will force us to change House implementation,
as all residents will conform to the same protocol
*/
```

## Case #2 – Enums

Consider a case where a router will fire up deeplink method to travel the user to some screen

```Swift
// defining the protocol that will implement the method of deep-link execution

protocol DeepLink {
  func execute()
}

// defining some deeplinks

class HomeDeepLink: DeepLink {
  func execute() {
    // travel to home screen
  }
}
  
class ProfileDeepLink: DeepLink {
  func execute() {
    // travel to profile screen
  }
}

// and a router to fire things up
// it don't need to be changed or something


class router {
  func execute(_ deepLink: DeepLink) {
    deepLink.execute()
  }
}
```




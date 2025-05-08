# Object-Oriented Programming Concepts in PetCareApp

This document explains the basic Object-Oriented Programming (OOP) concepts demonstrated in the PetCareApp in a beginner-friendly way.

## 1. Classes and Objects

**Classes** are like blueprints that describe what an object will look like and how it will behave.
**Objects** are actual instances created from these blueprints.

In our app:
- `Pet` is a class that defines what properties and behaviors a pet should have
- When you create a specific pet like `myDog`, that's an object

```swift
// Creating an object from the Dog class
let myDog = Dog(name: "Buddy", age: 3, breed: "Golden Retriever")
```

## 2. Inheritance

**Inheritance** allows a new class to take on the properties and methods of an existing class, then add or modify them.

In our app:
- `Dog`, `Cat`, and `Bird` all inherit from the `Pet` class
- They get all the basic pet properties and behaviors
- Each adds its own unique properties and behaviors

```swift
// Pet is the parent (superclass)
class Pet {
    var name: String
    var age: Int
    // ...
}

// Dog is the child (subclass) that inherits from Pet
class Dog: Pet {
    var breed: String
    // ...
}
```

## 3. Polymorphism

**Polymorphism** means "many forms" - it allows objects of different classes to be treated as objects of a common superclass, with each responding appropriately to common methods.

In our app:
- All pets have a `makeSound()` method
- Each pet type implements it differently (dogs bark, cats meow, birds chirp)
- We can call `makeSound()` on any pet without knowing its specific type

```swift
// Each subclass implements makeSound() differently
let myPets: [Pet] = [myDog, myCat, myBird]

// Polymorphism in action - each pet makes its own sound
for pet in myPets {
    pet.makeSound() // Dog barks, Cat meows, Bird chirps
}
```

## 4. Encapsulation

**Encapsulation** means bundling data (properties) and methods that work on that data within a single unit (the class), and restricting access to some of the object's components.

In our app:
- The `PetCare` class keeps its `pets` array private
- It provides specific methods to interact with the pets

```swift
class PetCare {
    // Private property - hidden from outside
    private var pets: [Pet] = []
    
    // Public methods - the interface for working with pets
    func addPet(_ pet: Pet) {
        // ...
    }
}
```

## 5. Abstraction

**Abstraction** means hiding complex implementation details and showing only the necessary features of an object.

In our app:
- Users don't need to know how `feed()` works internally
- They just need to know that calling `feed()` will feed the pet

```swift
// Users just call this method
pet.feed()

// They don't need to know the implementation details
func feed() {
    print("\(name) is eating...")
    mood = .happy
}
```

## 6. Composition

**Composition** is building complex objects by combining simpler ones.

In our app:
- The `PetCare` class contains (is composed of) multiple `Pet` objects
- This "has-a" relationship is different from inheritance's "is-a" relationship

```swift
class PetCare {
    private var pets: [Pet] = [] // PetCare has pets
}
```

## Learning Exercises

1. **Add a new pet type**: Create a `Fish` class that inherits from `Pet`
2. **Add a new property**: Add a `weight` property to the `Pet` class
3. **Add a new behavior**: Add a `groom()` method to the `Pet` class
4. **Modify existing behavior**: Change how the `play()` method works
5. **Use composition**: Create a `PetToy` class and give pets toys

## Key Takeaways

- **Classes** define the structure and behavior of objects
- **Inheritance** allows classes to inherit properties and methods from other classes
- **Polymorphism** lets different objects respond to the same method in their own way
- **Encapsulation** bundles data and methods together and controls access
- **Abstraction** hides complex details behind simple interfaces
- **Composition** builds complex objects by combining simpler ones

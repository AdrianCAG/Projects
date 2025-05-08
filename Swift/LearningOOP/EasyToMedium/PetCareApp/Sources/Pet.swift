// Pet.swift - Defines the Pet class and related subclasses

import Foundation

// Simple enum for pet mood - demonstrates basic enumeration
enum Mood: String {
    case happy = "Happy"
    case neutral = "Neutral"
    case sad = "Sad"
}

// Base Pet class - demonstrates basic class structure
class Pet {
    // Properties - demonstrates encapsulation
    var name: String
    var age: Int
    var mood: Mood
    
    // Initializer (constructor)
    init(name: String, age: Int) {
        self.name = name
        self.age = age
        self.mood = .neutral
    }
    
    // Methods
    func feed() {
        print("\(name) is eating...")
        mood = .happy
    }
    
    func play() {
        print("\(name) is playing...")
        mood = .happy
    }
    
    func sleep() {
        print("\(name) is sleeping...")
        mood = .neutral
    }
    
    // Method to be overridden - demonstrates polymorphism
    func makeSound() {
        print("\(name) makes a generic sound")
    }
    
    // Display pet info
    func displayInfo() {
        print("Name: \(name)")
        print("Age: \(age)")
        print("Mood: \(mood.rawValue)")
    }
}

// Dog class - demonstrates inheritance
class Dog: Pet {
    var breed: String
    
    // Constructor with super call - demonstrates constructor inheritance
    init(name: String, age: Int, breed: String) {
        self.breed = breed
        super.init(name: name, age: age)
    }
    
    // Override method - demonstrates polymorphism
    override func makeSound() {
        print("\(name) barks: Woof! Woof!")
    }
    
    // New method specific to Dog - demonstrates extending functionality
    func fetch() {
        print("\(name) fetches the ball!")
        mood = .happy
    }
    
    // Override displayInfo to add breed - demonstrates method overriding
    override func displayInfo() {
        super.displayInfo()
        print("Breed: \(breed)")
    }
}

// Cat class - demonstrates another subclass
class Cat: Pet {
    var color: String
    
    init(name: String, age: Int, color: String) {
        self.color = color
        super.init(name: name, age: age)
    }
    
    override func makeSound() {
        print("\(name) meows: Meow!")
    }
    
    func purr() {
        print("\(name) is purring...")
        mood = .happy
    }
    
    override func displayInfo() {
        super.displayInfo()
        print("Color: \(color)")
    }
}

// Bird class - demonstrates another subclass
class Bird: Pet {
    var canFly: Bool
    
    init(name: String, age: Int, canFly: Bool) {
        self.canFly = canFly
        super.init(name: name, age: age)
    }
    
    override func makeSound() {
        print("\(name) chirps: Tweet! Tweet!")
    }
    
    func fly() {
        if canFly {
            print("\(name) is flying around!")
            mood = .happy
        } else {
            print("\(name) can't fly.")
        }
    }
    
    override func displayInfo() {
        super.displayInfo()
        print("Can fly: \(canFly ? "Yes" : "No")")
    }
}

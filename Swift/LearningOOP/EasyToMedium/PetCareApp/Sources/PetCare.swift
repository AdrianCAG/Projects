// PetCare.swift - Manages pet care activities

import Foundation

// PetCare class - demonstrates composition
class PetCare {
    // Array to store pets - demonstrates collection usage
    private var pets: [Pet] = []
    
    // Add a pet to the collection
    func addPet(_ pet: Pet) {
        pets.append(pet)
        print("\(pet.name) has been added to your pet collection!")
    }
    
    // Remove a pet from the collection
    func removePet(at index: Int) {
        guard index >= 0 && index < pets.count else {
            print("Invalid pet index!")
            return
        }
        
        let petName = pets[index].name
        pets.remove(at: index)
        print("\(petName) has been removed from your pet collection.")
    }
    
    // Display all pets
    func displayAllPets() {
        if pets.isEmpty {
            print("You don't have any pets yet.")
            return
        }
        
        print("\n===== Your Pets =====")
        for (index, pet) in pets.enumerated() {
            print("\n--- Pet #\(index + 1) ---")
            pet.displayInfo()
        }
    }
    
    // Feed all pets
    func feedAllPets() {
        if pets.isEmpty {
            print("You don't have any pets to feed.")
            return
        }
        
        print("\n===== Feeding Time =====")
        for pet in pets {
            pet.feed()
        }
    }
    
    // Play with a specific pet
    func playWithPet(at index: Int) {
        guard index >= 0 && index < pets.count else {
            print("Invalid pet index!")
            return
        }
        
        let pet = pets[index]
        pet.play()
        
        // Demonstrate polymorphism with special actions
        if let dog = pet as? Dog {
            dog.fetch()
        } else if let cat = pet as? Cat {
            cat.purr()
        } else if let bird = pet as? Bird {
            bird.fly()
        }
    }
    
    // Make all pets sound - demonstrates polymorphism
    func hearPetSounds() {
        if pets.isEmpty {
            print("You don't have any pets to make sounds.")
            return
        }
        
        print("\n===== Pet Sounds =====")
        for pet in pets {
            pet.makeSound()
        }
    }
    
    // Main application loop
    func run() {
        print("Welcome to Pet Care App!")
        
        var running = true
        while running {
            displayMenu()
            
            if let choice = readLine(), let option = Int(choice) {
                switch option {
                case 1:
                    addNewPet()
                case 2:
                    displayAllPets()
                case 3:
                    interactWithPet()
                case 4:
                    feedAllPets()
                case 5:
                    hearPetSounds()
                case 6:
                    removePetMenu()
                case 7:
                    running = false
                    print("Thank you for using Pet Care App. Goodbye!")
                default:
                    print("Invalid option. Please try again.")
                }
            } else {
                print("Invalid input. Please enter a number.")
            }
        }
    }
    
    // Helper method to display menu
    private func displayMenu() {
        print("\n===== Pet Care Menu =====")
        print("1. Add a new pet")
        print("2. View all pets")
        print("3. Play with a pet")
        print("4. Feed all pets")
        print("5. Hear pet sounds")
        print("6. Remove a pet")
        print("7. Exit")
        print("Enter your choice (1-7): ", terminator: "")
    }
    
    // Helper method to add a new pet
    private func addNewPet() {
        print("\n===== Add a New Pet =====")
        print("What type of pet would you like to add?")
        print("1. Dog")
        print("2. Cat")
        print("3. Bird")
        print("Enter your choice (1-3): ", terminator: "")
        
        guard let typeChoice = readLine(), let petType = Int(typeChoice), (1...3).contains(petType) else {
            print("Invalid pet type. Returning to main menu.")
            return
        }
        
        print("Enter pet name: ", terminator: "")
        guard let name = readLine(), !name.isEmpty else {
            print("Name cannot be empty. Returning to main menu.")
            return
        }
        
        print("Enter pet age: ", terminator: "")
        guard let ageStr = readLine(), let age = Int(ageStr), age > 0 else {
            print("Invalid age. Returning to main menu.")
            return
        }
        
        var pet: Pet
        
        switch petType {
        case 1: // Dog
            print("Enter dog breed: ", terminator: "")
            let breed = readLine() ?? "Mixed"
            pet = Dog(name: name, age: age, breed: breed)
            
        case 2: // Cat
            print("Enter cat color: ", terminator: "")
            let color = readLine() ?? "Unknown"
            pet = Cat(name: name, age: age, color: color)
            
        case 3: // Bird
            print("Can this bird fly? (y/n): ", terminator: "")
            let canFly = readLine()?.lowercased() == "y"
            pet = Bird(name: name, age: age, canFly: canFly)
            
        default:
            print("Invalid choice. Creating a generic pet.")
            pet = Pet(name: name, age: age)
        }
        
        addPet(pet)
    }
    
    // Helper method to interact with a pet
    private func interactWithPet() {
        if pets.isEmpty {
            print("You don't have any pets to play with.")
            return
        }
        
        displayAllPets()
        
        print("\nEnter the pet number to play with: ", terminator: "")
        if let indexStr = readLine(), let index = Int(indexStr), (1...pets.count).contains(index) {
            playWithPet(at: index - 1)
        } else {
            print("Invalid pet number.")
        }
    }
    
    // Helper method to remove a pet
    private func removePetMenu() {
        if pets.isEmpty {
            print("You don't have any pets to remove.")
            return
        }
        
        displayAllPets()
        
        print("\nEnter the pet number to remove: ", terminator: "")
        if let indexStr = readLine(), let index = Int(indexStr), (1...pets.count).contains(index) {
            removePet(at: index - 1)
        } else {
            print("Invalid pet number.")
        }
    }
}

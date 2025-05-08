// GameCharacterFactoryPatternApp - Demonstrates the Factory Method Pattern
// A medium-high complexity implementation for game character creation

import Foundation

print("===== Game Character Factory Pattern Demo =====\n")

// Create a new game system
let gameSystem = GameSystem(difficulty: .medium, gameMode: .story)

// Demonstrate the Factory Method Pattern by creating different character types
print("Creating characters using the Factory Method Pattern...\n")

// Create a warrior character using the WarriorFactory
print("\n=== Creating a Warrior ===\n")
if let warrior = gameSystem.createCharacter(name: "Aragorn", type: "warrior") {
    print(warrior.displayInfo())
    print("\nWarrior special actions:")
    print("- Attack: \(warrior.attack())")
    print("- Defend: \(warrior.defend())")
    print("- Special: \(warrior.specialAction())")
    
    // Set as player character
    gameSystem.setPlayerCharacter(character: warrior)
}

// Create a mage character using the MageFactory
print("\n=== Creating a Mage ===\n")
if let mage = gameSystem.createCharacter(name: "Gandalf", type: "mage") {
    print(mage.displayInfo())
    print("\nMage special actions:")
    print("- Attack: \(mage.attack())")
    print("- Defend: \(mage.defend())")
    print("- Special: \(mage.specialAction())")
    
    // Add to party
    gameSystem.addNPCToParty(name: "Gandalf", type: "mage")
}

// Create an archer character using the ArcherFactory
print("\n=== Creating an Archer ===\n")
if let archer = gameSystem.createCharacter(name: "Legolas", type: "archer") {
    print(archer.displayInfo())
    print("\nArcher special actions:")
    print("- Attack: \(archer.attack())")
    print("- Defend: \(archer.defend())")
    print("- Special: \(archer.specialAction())")
    
    // Add to party
    gameSystem.addNPCToParty(name: "Legolas", type: "archer")
}

// Create a paladin character using the PaladinFactory
print("\n=== Creating a Paladin ===\n")
if let paladin = gameSystem.createCharacter(name: "Uther", type: "paladin") {
    print(paladin.displayInfo())
    print("\nPaladin special actions:")
    print("- Attack: \(paladin.attack())")
    print("- Defend: \(paladin.defend())")
    print("- Special: \(paladin.specialAction())")
    
    // Add to party
    gameSystem.addNPCToParty(name: "Uther", type: "paladin")
}

// Display party information
print("\n=== Party Information ===\n")
if let partyInfo = gameSystem.getPartyInfo() {
    print(partyInfo)
}

// Display available regions
print("\n=== Available Regions ===\n")
print(gameSystem.displayAvailableRegions())

// Display available quests
print("\n=== Available Quests ===\n")
print(gameSystem.displayAvailableQuests())

// Try to enter a region
print("\n=== Entering a Region ===\n")
print(gameSystem.enterRegion(index: 0))

// Try to accept a quest
print("\n=== Accepting a Quest ===\n")
print(gameSystem.acceptQuest(index: 0))

print("\n===== End of Factory Method Pattern Demo =====\n")
print("This application demonstrates how the Factory Method Pattern allows for flexible character creation")
print("while encapsulating the specific implementation details of each character type.")

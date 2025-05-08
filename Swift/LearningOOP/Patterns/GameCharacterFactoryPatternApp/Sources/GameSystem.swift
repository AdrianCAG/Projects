// GameSystem.swift - Game management system

import Foundation

// Game difficulty levels
enum GameDifficulty {
    case easy
    case medium
    case hard
    case nightmare
    
    var enemyLevelModifier: Int {
        switch self {
        case .easy: return 0
        case .medium: return 2
        case .hard: return 5
        case .nightmare: return 10
        }
    }
    
    var enemyCountModifier: Int {
        switch self {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        case .nightmare: return 4
        }
    }
}

// Game modes
enum GameMode {
    case story
    case survival
    case arena
    case exploration
}

// Game region
struct GameRegion {
    let name: String
    let description: String
    let minimumLevel: Int
    let enemies: [String]
    let boss: String?
    
    func displayInfo() -> String {
        var info = """
        Region: \(name)
        \(description)
        Minimum Level: \(minimumLevel)
        
        Common Enemies:
        """
        
        for enemy in enemies {
            info += "\n  - \(enemy)"
        }
        
        if let boss = boss {
            info += "\n\nRegion Boss: \(boss)"
        }
        
        return info
    }
}

// Game quest
struct Quest {
    let title: String
    let description: String
    let requiredLevel: Int
    let reward: String
    let targetRegion: String
    let isCompleted: Bool = false
    
    func displayInfo() -> String {
        return """
        Quest: \(title)
        \(description)
        Required Level: \(requiredLevel)
        Target Region: \(targetRegion)
        Reward: \(reward)
        Status: \(isCompleted ? "Completed" : "In Progress")
        """
    }
}

// Party system
class Party {
    let name: String
    var members: [Character]
    let maxSize: Int
    
    init(name: String, leader: Character, maxSize: Int = 4) {
        self.name = name
        self.members = [leader]
        self.maxSize = maxSize
    }
    
    func addMember(character: Character) -> Bool {
        guard members.count < maxSize else {
            print("Party is already full!")
            return false
        }
        
        members.append(character)
        print("\(character.name) has joined the party!")
        return true
    }
    
    func removeMember(name: String) -> Character? {
        guard let index = members.firstIndex(where: { $0.name == name }) else {
            print("Character \(name) is not in the party!")
            return nil
        }
        
        let character = members.remove(at: index)
        print("\(character.name) has left the party!")
        return character
    }
    
    func displayPartyInfo() -> String {
        var info = "Party: \(name) (\(members.count)/\(maxSize) members)\n"
        info += "Members:\n"
        
        for (index, character) in members.enumerated() {
            info += "  \(index + 1). \(character.name) (Level \(character.level))\n"
        }
        
        return info
    }
    
    func calculatePartyPower() -> Int {
        return members.reduce(0) { total, character in
            let equipmentPower = character.equipment.reduce(0) { sum, item in sum + item.power }
            return total + character.level * 10 + equipmentPower
        }
    }
}

// Game system
class GameSystem {
    private var playerCharacter: Character?
    private var party: Party?
    private var difficulty: GameDifficulty
    private var gameMode: GameMode
    private var availableRegions: [GameRegion]
    private var availableQuests: [Quest]
    private var characterFactories: [String: CharacterFactory]
    
    init(difficulty: GameDifficulty = .medium, gameMode: GameMode = .story) {
        self.difficulty = difficulty
        self.gameMode = gameMode
        
        // Initialize available character factories
        self.characterFactories = [
            "warrior": WarriorFactory(),
            "mage": MageFactory(),
            "archer": ArcherFactory(),
            "paladin": PaladinFactory(),
            "rogue": RogueFactory()
        ]
        
        // Initialize game regions
        self.availableRegions = [
            GameRegion(
                name: "Forest of Shadows",
                description: "A dark forest filled with ancient trees and mysterious creatures.",
                minimumLevel: 1,
                enemies: ["Wolf", "Bandit", "Giant Spider"],
                boss: "Ancient Treant"
            ),
            GameRegion(
                name: "Misty Mountains",
                description: "Tall peaks shrouded in mist where flying creatures and mountain dwellers reside.",
                minimumLevel: 5,
                enemies: ["Mountain Troll", "Harpy", "Rock Elemental"],
                boss: "Cloud Giant"
            ),
            GameRegion(
                name: "Sunken Temple",
                description: "An ancient temple that has partially sunk into a swamp, now home to all manner of undead.",
                minimumLevel: 10,
                enemies: ["Skeleton Warrior", "Zombie", "Wraith"],
                boss: "Lich King"
            ),
            GameRegion(
                name: "Dragon's Lair",
                description: "A volcanic region where dragons and their servants make their home.",
                minimumLevel: 15,
                enemies: ["Kobold", "Fire Elemental", "Dragon Whelp"],
                boss: "Ancient Red Dragon"
            )
        ]
        
        // Initialize quests
        self.availableQuests = [
            Quest(
                title: "Clear the Forest Path",
                description: "Travelers have been attacked on the forest path. Clear out the bandits responsible.",
                requiredLevel: 1,
                reward: "100 Gold, Leather Boots",
                targetRegion: "Forest of Shadows"
            ),
            Quest(
                title: "Mountain Rescue",
                description: "A group of miners has gone missing in the Misty Mountains. Find them and bring them home.",
                requiredLevel: 5,
                reward: "300 Gold, Health Potion x3",
                targetRegion: "Misty Mountains"
            ),
            Quest(
                title: "Artifact Recovery",
                description: "An ancient artifact of great power lies within the Sunken Temple. Retrieve it before it falls into the wrong hands.",
                requiredLevel: 10,
                reward: "500 Gold, Rare Weapon",
                targetRegion: "Sunken Temple"
            ),
            Quest(
                title: "Slay the Dragon",
                description: "The Ancient Red Dragon has been terrorizing nearby settlements. Put an end to its reign of terror.",
                requiredLevel: 15,
                reward: "1000 Gold, Legendary Item",
                targetRegion: "Dragon's Lair"
            )
        ]
    }
    
    // Create a new character using the Factory Method pattern
    func createCharacter(name: String, type: String) -> Character? {
        guard let factory = characterFactories[type.lowercased()] else {
            print("Invalid character type: \(type)")
            print("Available types: \(characterFactories.keys.joined(separator: ", "))")
            return nil
        }
        
        let character = factory.prepareCharacter(name: name)
        return character
    }
    
    // Set the player's character
    func setPlayerCharacter(character: Character) {
        self.playerCharacter = character
        print("\(character.name) is now your main character!")
        
        // Create a party with the player character as leader
        self.party = Party(name: "\(character.name)'s Party", leader: character)
    }
    
    // Add an NPC to the player's party
    func addNPCToParty(name: String, type: String) -> Bool {
        guard let party = party else {
            print("You need to create a player character first!")
            return false
        }
        
        guard let npc = createCharacter(name: name, type: type) else {
            return false
        }
        
        return party.addMember(character: npc)
    }
    
    // Display available regions
    func displayAvailableRegions() -> String {
        var info = "Available Regions:\n"
        
        for (index, region) in availableRegions.enumerated() {
            info += "\n\(index + 1). \(region.name) (Min Level: \(region.minimumLevel))"
        }
        
        return info
    }
    
    // Display available quests
    func displayAvailableQuests() -> String {
        var info = "Available Quests:\n"
        
        for (index, quest) in availableQuests.enumerated() {
            info += "\n\(index + 1). \(quest.title) (Level \(quest.requiredLevel)+)"
        }
        
        return info
    }
    
    // Get detailed information about a region
    func getRegionInfo(index: Int) -> String? {
        guard index >= 0 && index < availableRegions.count else {
            return nil
        }
        
        return availableRegions[index].displayInfo()
    }
    
    // Get detailed information about a quest
    func getQuestInfo(index: Int) -> String? {
        guard index >= 0 && index < availableQuests.count else {
            return nil
        }
        
        return availableQuests[index].displayInfo()
    }
    
    // Get player character info
    func getPlayerInfo() -> String? {
        guard let character = playerCharacter else {
            return nil
        }
        
        return character.displayInfo()
    }
    
    // Get party info
    func getPartyInfo() -> String? {
        guard let party = party else {
            return nil
        }
        
        return party.displayPartyInfo()
    }
    
    // Change game difficulty
    func setDifficulty(difficulty: GameDifficulty) {
        self.difficulty = difficulty
        print("Game difficulty set to: \(difficulty)")
    }
    
    // Change game mode
    func setGameMode(mode: GameMode) {
        self.gameMode = mode
        print("Game mode set to: \(mode)")
    }
    
    // Simulate entering a region
    func enterRegion(index: Int) -> String {
        guard let character = playerCharacter else {
            return "You need to create a character first!"
        }
        
        guard index >= 0 && index < availableRegions.count else {
            return "Invalid region index!"
        }
        
        let region = availableRegions[index]
        
        if character.level < region.minimumLevel {
            return "Your character is too weak to enter \(region.name)! Required level: \(region.minimumLevel)"
        }
        
        return "Entering \(region.name)...\n\nYou venture into \(region.description)"
    }
    
    // Simulate accepting a quest
    func acceptQuest(index: Int) -> String {
        guard let character = playerCharacter else {
            return "You need to create a character first!"
        }
        
        guard index >= 0 && index < availableQuests.count else {
            return "Invalid quest index!"
        }
        
        let quest = availableQuests[index]
        
        if character.level < quest.requiredLevel {
            return "Your character is too inexperienced to take on this quest! Required level: \(quest.requiredLevel)"
        }
        
        return "Quest accepted: \(quest.title)\n\n\(quest.description)"
    }
}

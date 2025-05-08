// CharacterFactory.swift - Creator classes for the Factory Method pattern

import Foundation

// Creator protocol - Defines the factory method
protocol CharacterFactory {
    // Factory Method
    func createCharacter(name: String) -> Character
    
    // Template method that uses the factory method
    func prepareCharacter(name: String) -> Character
}

// Default implementation for the template method
extension CharacterFactory {
    func prepareCharacter(name: String) -> Character {
        // Create the character using the factory method
        let character = createCharacter(name: name)
        
        // Additional setup that's common for all characters
        print("Preparing character: \(name)")
        print("Character created successfully!")
        
        return character
    }
}

// Concrete Creator for Warriors
class WarriorFactory: CharacterFactory {
    func createCharacter(name: String) -> Character {
        // Create warrior-specific equipment
        let sword = Weapon(name: "Steel Broadsword", power: 15, attackSpeed: 1.2, range: 2)
        let shield = Armor(name: "Iron Shield", power: 5, defense: 12, weight: 8)
        let plateArmor = Armor(name: "Plate Armor", power: 8, defense: 20, weight: 15)
        let strengthAmulet = Accessory(name: "Amulet of Strength", power: 5, bonusType: "Strength", bonusValue: 3)
        
        // Create warrior-specific abilities
        let cleave = AttackAbility(name: "Cleave", cooldown: 8, damage: 25, range: 3)
        let shieldBash = AttackAbility(name: "Shield Bash", cooldown: 5, damage: 10, range: 1)
        let bulwark = DefenseAbility(name: "Bulwark", cooldown: 15, protection: 30, duration: 6)
        
        // Create warrior-specific attributes
        let attributes = Attributes(strength: 16, intelligence: 8, dexterity: 12, 
                                   constitution: 15, charisma: 10, wisdom: 9)
        
        // Create and return the warrior
        return Warrior(
            name: name,
            health: 150,
            mana: 50,
            attributes: attributes,
            equipment: [sword, shield, plateArmor, strengthAmulet],
            abilities: [cleave, shieldBash, bulwark]
        )
    }
}

// Concrete Creator for Mages
class MageFactory: CharacterFactory {
    func createCharacter(name: String) -> Character {
        // Create mage-specific equipment
        let staff = Weapon(name: "Arcane Staff", power: 12, attackSpeed: 1.5, range: 8)
        let robes = Armor(name: "Enchanted Robes", power: 3, defense: 8, weight: 4)
        let wizardHat = Armor(name: "Wizard's Hat", power: 2, defense: 3, weight: 1)
        let intelligenceAmulet = Accessory(name: "Amulet of Intelligence", power: 5, bonusType: "Intelligence", bonusValue: 3)
        
        // Create mage-specific abilities
        let fireball = AttackAbility(name: "Fireball", cooldown: 6, damage: 35, range: 10)
        let frostNova = AttackAbility(name: "Frost Nova", cooldown: 10, damage: 20, range: 5)
        let arcaneBarrier = DefenseAbility(name: "Arcane Barrier", cooldown: 12, protection: 25, duration: 8)
        let teleport = UtilityAbility(name: "Teleport", cooldown: 20, effect: "Mobility", effectStrength: 10)
        
        // Create mage-specific attributes
        let attributes = Attributes(strength: 6, intelligence: 18, dexterity: 10, 
                                   constitution: 8, charisma: 12, wisdom: 16)
        
        // Create and return the mage
        return Mage(
            name: name,
            health: 80,
            mana: 150,
            attributes: attributes,
            equipment: [staff, robes, wizardHat, intelligenceAmulet],
            abilities: [fireball, frostNova, arcaneBarrier, teleport]
        )
    }
}

// Concrete Creator for Archers
class ArcherFactory: CharacterFactory {
    func createCharacter(name: String) -> Character {
        // Create archer-specific equipment
        let bow = Weapon(name: "Longbow", power: 14, attackSpeed: 1.8, range: 15)
        let quiver = Accessory(name: "Quiver of Precision", power: 3, bonusType: "Accuracy", bonusValue: 5)
        let leatherArmor = Armor(name: "Leather Armor", power: 4, defense: 10, weight: 6)
        let dexterityGloves = Accessory(name: "Gloves of Dexterity", power: 4, bonusType: "Dexterity", bonusValue: 3)
        
        // Create archer-specific abilities
        let preciseShot = AttackAbility(name: "Precise Shot", cooldown: 5, damage: 30, range: 18)
        let multiShot = AttackAbility(name: "Multi Shot", cooldown: 12, damage: 45, range: 12)
        let evasion = DefenseAbility(name: "Evasion", cooldown: 15, protection: 20, duration: 5)
        let eagleEye = UtilityAbility(name: "Eagle Eye", cooldown: 25, effect: "Critical Chance", effectStrength: 15)
        
        // Create archer-specific attributes
        let attributes = Attributes(strength: 12, intelligence: 10, dexterity: 18, 
                                   constitution: 10, charisma: 12, wisdom: 8)
        
        // Create and return the archer
        return Archer(
            name: name,
            health: 100,
            mana: 80,
            attributes: attributes,
            equipment: [bow, quiver, leatherArmor, dexterityGloves],
            abilities: [preciseShot, multiShot, evasion, eagleEye]
        )
    }
}

// Concrete Creator for Paladins
class PaladinFactory: CharacterFactory {
    func createCharacter(name: String) -> Character {
        // Create paladin-specific equipment
        let hammer = Weapon(name: "Divine Warhammer", power: 14, attackSpeed: 1.3, range: 2)
        let holyShield = Armor(name: "Holy Shield", power: 6, defense: 15, weight: 10)
        let plateArmor = Armor(name: "Blessed Plate", power: 10, defense: 18, weight: 14)
        let holySymbol = Accessory(name: "Holy Symbol", power: 8, bonusType: "Divine Power", bonusValue: 5)
        
        // Create paladin-specific abilities
        let holyStrike = AttackAbility(name: "Holy Strike", cooldown: 6, damage: 22, range: 2)
        let divineProtection = DefenseAbility(name: "Divine Protection", cooldown: 20, protection: 35, duration: 8)
        let layOnHands = UtilityAbility(name: "Lay on Hands", cooldown: 30, effect: "Healing", effectStrength: 40)
        let smite = AttackAbility(name: "Smite", cooldown: 15, damage: 35, range: 3)
        
        // Create paladin-specific attributes
        let attributes = Attributes(strength: 14, intelligence: 10, dexterity: 8, 
                                   constitution: 14, charisma: 12, wisdom: 14)
        
        // Create and return the paladin
        return Paladin(
            name: name,
            health: 130,
            mana: 100,
            attributes: attributes,
            equipment: [hammer, holyShield, plateArmor, holySymbol],
            abilities: [holyStrike, divineProtection, layOnHands, smite]
        )
    }
}

// Concrete Creator for Rogues
class RogueFactory: CharacterFactory {
    func createCharacter(name: String) -> Character {
        // Create rogue-specific equipment
        let daggers = Weapon(name: "Dual Daggers", power: 12, attackSpeed: 2.2, range: 1)
        let shadowCloak = Armor(name: "Shadow Cloak", power: 5, defense: 8, weight: 3)
        let leatherArmor = Armor(name: "Studded Leather", power: 3, defense: 9, weight: 5)
        let lockpicks = Accessory(name: "Master Lockpicks", power: 2, bonusType: "Stealth", bonusValue: 5)
        
        // Create rogue-specific abilities
        let backstab = AttackAbility(name: "Backstab", cooldown: 8, damage: 40, range: 1)
        let poisonBlade = AttackAbility(name: "Poison Blade", cooldown: 12, damage: 25, range: 1)
        let vanish = DefenseAbility(name: "Vanish", cooldown: 18, protection: 15, duration: 4)
        let pickpocket = UtilityAbility(name: "Pickpocket", cooldown: 15, effect: "Theft", effectStrength: 8)
        
        // Create rogue-specific attributes
        let attributes = Attributes(strength: 10, intelligence: 12, dexterity: 18, 
                                   constitution: 9, charisma: 14, wisdom: 8)
        
        // Create and return the rogue
        return Rogue(
            name: name,
            health: 90,
            mana: 70,
            attributes: attributes,
            equipment: [daggers, shadowCloak, leatherArmor, lockpicks],
            abilities: [backstab, poisonBlade, vanish, pickpocket]
        )
    }
}

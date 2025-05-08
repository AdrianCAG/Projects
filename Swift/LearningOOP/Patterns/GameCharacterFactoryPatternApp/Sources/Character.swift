// Character.swift - Abstract product class

import Foundation

// Equipment protocol and implementations
protocol Equipment {
    var name: String { get }
    var power: Int { get }
    var description: String { get }
}

struct Weapon: Equipment {
    let name: String
    let power: Int
    let attackSpeed: Double
    let range: Int
    
    var description: String {
        return "\(name) (Power: \(power), Speed: \(attackSpeed), Range: \(range))"
    }
}

struct Armor: Equipment {
    let name: String
    let power: Int
    let defense: Int
    let weight: Int
    
    var description: String {
        return "\(name) (Power: \(power), Defense: \(defense), Weight: \(weight))"
    }
}

struct Accessory: Equipment {
    let name: String
    let power: Int
    let bonusType: String
    let bonusValue: Int
    
    var description: String {
        return "\(name) (Power: \(power), \(bonusType): +\(bonusValue))"
    }
}

// Ability protocol and implementations
protocol Ability {
    var name: String { get }
    var cooldown: Int { get }
    var description: String { get }
    func use() -> String
}

struct AttackAbility: Ability {
    let name: String
    let cooldown: Int
    let damage: Int
    let range: Int
    
    var description: String {
        return "\(name) - Deals \(damage) damage at \(range) range (Cooldown: \(cooldown)s)"
    }
    
    func use() -> String {
        return "Used \(name) to attack for \(damage) damage!"
    }
}

struct DefenseAbility: Ability {
    let name: String
    let cooldown: Int
    let protection: Int
    let duration: Int
    
    var description: String {
        return "\(name) - Provides \(protection) protection for \(duration)s (Cooldown: \(cooldown)s)"
    }
    
    func use() -> String {
        return "Used \(name) for \(protection) protection for \(duration) seconds!"
    }
}

struct UtilityAbility: Ability {
    let name: String
    let cooldown: Int
    let effect: String
    let effectStrength: Int
    
    var description: String {
        return "\(name) - \(effect) with strength \(effectStrength) (Cooldown: \(cooldown)s)"
    }
    
    func use() -> String {
        return "Used \(name) for \(effect) effect with \(effectStrength) strength!"
    }
}

// Attribute system
struct Attributes {
    var strength: Int
    var intelligence: Int
    var dexterity: Int
    var constitution: Int
    var charisma: Int
    var wisdom: Int
    
    init(strength: Int = 10, intelligence: Int = 10, dexterity: Int = 10, 
         constitution: Int = 10, charisma: Int = 10, wisdom: Int = 10) {
        self.strength = strength
        self.intelligence = intelligence
        self.dexterity = dexterity
        self.constitution = constitution
        self.charisma = charisma
        self.wisdom = wisdom
    }
    
    func display() -> String {
        return """
        Attributes:
          Strength: \(strength)
          Intelligence: \(intelligence)
          Dexterity: \(dexterity)
          Constitution: \(constitution)
          Charisma: \(charisma)
          Wisdom: \(wisdom)
        """
    }
}

// Character protocol - Abstract Product
protocol Character {
    var name: String { get }
    var level: Int { get set }
    var health: Int { get set }
    var mana: Int { get set }
    var attributes: Attributes { get }
    var equipment: [Equipment] { get }
    var abilities: [Ability] { get }
    
    func attack() -> String
    func defend() -> String
    func specialAction() -> String
    func displayInfo() -> String
    func levelUp()
}

// Base implementation with common functionality
class BaseCharacter: Character {
    let name: String
    var level: Int
    var health: Int
    var mana: Int
    var attributes: Attributes
    var equipment: [Equipment]
    var abilities: [Ability]
    
    init(name: String, level: Int = 1, health: Int, mana: Int, 
         attributes: Attributes, equipment: [Equipment], abilities: [Ability]) {
        self.name = name
        self.level = level
        self.health = health
        self.mana = mana
        self.attributes = attributes
        self.equipment = equipment
        self.abilities = abilities
    }
    
    func attack() -> String {
        return "\(name) performs a basic attack!"
    }
    
    func defend() -> String {
        return "\(name) takes a defensive stance!"
    }
    
    func specialAction() -> String {
        return "\(name) performs a special action!"
    }
    
    func levelUp() {
        level += 1
        health += 10
        mana += 5
        print("\(name) has reached level \(level)!")
    }
    
    func displayInfo() -> String {
        var info = """
        Character: \(name) (Level \(level))
        Health: \(health) | Mana: \(mana)
        \(attributes.display())
        
        Equipment:
        """
        
        for (index, item) in equipment.enumerated() {
            info += "\n  \(index + 1). \(item.description)"
        }
        
        info += "\n\nAbilities:"
        
        for (index, ability) in abilities.enumerated() {
            info += "\n  \(index + 1). \(ability.description)"
        }
        
        return info
    }
}

// Concrete Product implementations
class Warrior: BaseCharacter {
    override func attack() -> String {
        return "\(name) swings a mighty weapon with strength!"
    }
    
    override func defend() -> String {
        return "\(name) raises a shield, boosting defense!"
    }
    
    override func specialAction() -> String {
        return "\(name) enters a battle rage, increasing damage output!"
    }
    
    override func levelUp() {
        super.levelUp()
        attributes.strength += 3
        attributes.constitution += 2
        health += 15 // Warriors gain extra health per level
    }
}

class Mage: BaseCharacter {
    override func attack() -> String {
        return "\(name) casts a magical bolt with intelligence!"
    }
    
    override func defend() -> String {
        return "\(name) creates a magical barrier!"
    }
    
    override func specialAction() -> String {
        return "\(name) channels arcane energy, increasing spell power!"
    }
    
    override func levelUp() {
        super.levelUp()
        attributes.intelligence += 3
        attributes.wisdom += 2
        mana += 15 // Mages gain extra mana per level
    }
}

class Archer: BaseCharacter {
    override func attack() -> String {
        return "\(name) fires a precise arrow with dexterity!"
    }
    
    override func defend() -> String {
        return "\(name) nimbly dodges incoming attacks!"
    }
    
    override func specialAction() -> String {
        return "\(name) takes careful aim, increasing critical hit chance!"
    }
    
    override func levelUp() {
        super.levelUp()
        attributes.dexterity += 3
        attributes.charisma += 2
        health += 8 // Archers gain moderate health per level
        mana += 8 // Archers gain moderate mana per level
    }
}

class Paladin: BaseCharacter {
    override func attack() -> String {
        return "\(name) strikes with righteous fury!"
    }
    
    override func defend() -> String {
        return "\(name) calls upon divine protection!"
    }
    
    override func specialAction() -> String {
        return "\(name) channels holy light, healing allies and damaging enemies!"
    }
    
    override func levelUp() {
        super.levelUp()
        attributes.strength += 2
        attributes.wisdom += 2
        attributes.constitution += 1
        health += 12
        mana += 8
    }
}

class Rogue: BaseCharacter {
    override func attack() -> String {
        return "\(name) strikes from the shadows with deadly precision!"
    }
    
    override func defend() -> String {
        return "\(name) vanishes in a cloud of smoke!"
    }
    
    override func specialAction() -> String {
        return "\(name) finds an enemy's weak spot, preparing for a critical strike!"
    }
    
    override func levelUp() {
        super.levelUp()
        attributes.dexterity += 3
        attributes.intelligence += 1
        attributes.charisma += 1
        health += 7
        mana += 5
    }
}

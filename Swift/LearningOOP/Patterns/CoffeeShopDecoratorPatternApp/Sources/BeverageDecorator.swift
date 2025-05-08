// BeverageDecorator.swift - Decorator abstract class and concrete decorators

import Foundation

// BeverageDecorator is the base decorator class that wraps a beverage
class BeverageDecorator: Beverage {
    // The wrapped beverage
    let beverage: Beverage
    
    // Forward all properties to the wrapped beverage
    var description: String {
        return beverage.description
    }
    
    var size: Size {
        return beverage.size
    }
    
    var temperature: Temperature {
        return beverage.temperature
    }
    
    var basePrice: Double {
        return beverage.basePrice
    }
    
    var calories: Int {
        return beverage.calories
    }
    
    var ingredients: [String] {
        return beverage.ingredients
    }
    
    // Initialize with a beverage to decorate
    required init(beverage: Beverage) {
        self.beverage = beverage
    }
    
    // Forward the cost calculation to the wrapped beverage
    func cost() -> Double {
        return beverage.cost()
    }
    
    // Forward the details to the wrapped beverage
    func getDetails() -> String {
        return beverage.getDetails()
    }
    
    // Forward the ingredient check to the wrapped beverage
    func containsIngredient(_ ingredient: String) -> Bool {
        return beverage.containsIngredient(ingredient)
    }
    
    // Create a copy with a different size
    func withSize(_ newSize: Size) -> Beverage {
        // Create a new instance of the same decorator with the beverage size changed
        let newBeverage = beverage.withSize(newSize)
        return type(of: self).init(beverage: newBeverage)
    }
    
    // Create a copy with a different temperature
    func withTemperature(_ newTemperature: Temperature) -> Beverage {
        // Create a new instance of the same decorator with the beverage temperature changed
        let newBeverage = beverage.withTemperature(newTemperature)
        return type(of: self).init(beverage: newBeverage)
    }
}

// MilkDecorator adds milk to a beverage
class MilkDecorator: BeverageDecorator {
    private let milkType: String
    private let additionalPrice: Double
    private let additionalCalories: Int
    
    override var description: String {
        return "\(beverage.description) with \(milkType) Milk"
    }
    
    override var ingredients: [String] {
        return beverage.ingredients + ["\(milkType) Milk"]
    }
    
    required init(beverage: Beverage) {
        self.milkType = "Whole"
        self.additionalPrice = 0.60
        self.additionalCalories = 50
        super.init(beverage: beverage)
    }
    
    init(beverage: Beverage, milkType: String = "Whole") {
        self.milkType = milkType
        
        // Different milk types have different prices and calories
        switch milkType.lowercased() {
        case "almond":
            self.additionalPrice = 0.75
            self.additionalCalories = 30
        case "oat":
            self.additionalPrice = 0.80
            self.additionalCalories = 40
        case "soy":
            self.additionalPrice = 0.70
            self.additionalCalories = 35
        case "skim":
            self.additionalPrice = 0.50
            self.additionalCalories = 20
        default: // Whole milk
            self.additionalPrice = 0.60
            self.additionalCalories = 50
        }
        
        super.init(beverage: beverage)
    }
    
    override func cost() -> Double {
        return super.cost() + additionalPrice
    }
    
    override var calories: Int {
        return super.calories + additionalCalories
    }
}

// WhippedCreamDecorator adds whipped cream to a beverage
class WhippedCreamDecorator: BeverageDecorator {
    override var description: String {
        return "\(beverage.description) with Whipped Cream"
    }
    
    override var ingredients: [String] {
        return beverage.ingredients + ["Whipped Cream"]
    }
    
    required init(beverage: Beverage) {
        super.init(beverage: beverage)
    }
    
    override func cost() -> Double {
        return super.cost() + 0.75
    }
    
    override var calories: Int {
        return super.calories + 120
    }
}

// FlavorSyrupDecorator adds flavor syrup to a beverage
class FlavorSyrupDecorator: BeverageDecorator {
    private let flavor: String
    private let pumps: Int
    
    override var description: String {
        if pumps > 1 {
            return "\(beverage.description) with \(pumps) Pumps of \(flavor) Syrup"
        } else {
            return "\(beverage.description) with \(flavor) Syrup"
        }
    }
    
    override var ingredients: [String] {
        return beverage.ingredients + ["\(flavor) Syrup"]
    }
    
    required init(beverage: Beverage) {
        self.flavor = "Vanilla"
        self.pumps = 1
        super.init(beverage: beverage)
    }
    
    init(beverage: Beverage, flavor: String, pumps: Int = 1) {
        self.flavor = flavor
        self.pumps = max(1, min(pumps, 5)) // Limit pumps between 1 and 5
        super.init(beverage: beverage)
    }
    
    override func cost() -> Double {
        return super.cost() + (Double(pumps) * 0.50)
    }
    
    override var calories: Int {
        return super.calories + (pumps * 30)
    }
}

// CaramelDrizzleDecorator adds caramel drizzle to a beverage
class CaramelDrizzleDecorator: BeverageDecorator {
    private let extraDrizzle: Bool
    
    override var description: String {
        if extraDrizzle {
            return "\(beverage.description) with Extra Caramel Drizzle"
        } else {
            return "\(beverage.description) with Caramel Drizzle"
        }
    }
    
    override var ingredients: [String] {
        return beverage.ingredients + ["Caramel Sauce"]
    }
    
    required init(beverage: Beverage) {
        self.extraDrizzle = false
        super.init(beverage: beverage)
    }
    
    init(beverage: Beverage, extraDrizzle: Bool = false) {
        self.extraDrizzle = extraDrizzle
        super.init(beverage: beverage)
    }
    
    override func cost() -> Double {
        return super.cost() + (extraDrizzle ? 1.00 : 0.60)
    }
    
    override var calories: Int {
        return super.calories + (extraDrizzle ? 90 : 45)
    }
}

// ChocolateDrizzleDecorator adds chocolate drizzle to a beverage
class ChocolateDrizzleDecorator: BeverageDecorator {
    private let extraDrizzle: Bool
    
    override var description: String {
        if extraDrizzle {
            return "\(beverage.description) with Extra Chocolate Drizzle"
        } else {
            return "\(beverage.description) with Chocolate Drizzle"
        }
    }
    
    override var ingredients: [String] {
        return beverage.ingredients + ["Chocolate Sauce"]
    }
    
    required init(beverage: Beverage) {
        self.extraDrizzle = false
        super.init(beverage: beverage)
    }
    
    init(beverage: Beverage, extraDrizzle: Bool = false) {
        self.extraDrizzle = extraDrizzle
        super.init(beverage: beverage)
    }
    
    override func cost() -> Double {
        return super.cost() + (extraDrizzle ? 1.00 : 0.60)
    }
    
    override var calories: Int {
        return super.calories + (extraDrizzle ? 100 : 50)
    }
}

// CinnamonDecorator adds cinnamon to a beverage
class CinnamonDecorator: BeverageDecorator {
    override var description: String {
        return "\(beverage.description) with Cinnamon"
    }
    
    override var ingredients: [String] {
        return beverage.ingredients + ["Cinnamon"]
    }
    
    required init(beverage: Beverage) {
        super.init(beverage: beverage)
    }
    
    override func cost() -> Double {
        return super.cost() + 0.25
    }
    
    override var calories: Int {
        return super.calories + 5
    }
}

// SugarDecorator adds sugar to a beverage
class SugarDecorator: BeverageDecorator {
    private let packets: Int
    
    override var description: String {
        if packets > 1 {
            return "\(beverage.description) with \(packets) Sugar Packets"
        } else {
            return "\(beverage.description) with Sugar"
        }
    }
    
    override var ingredients: [String] {
        return beverage.ingredients + ["Sugar"]
    }
    
    required init(beverage: Beverage) {
        self.packets = 1
        super.init(beverage: beverage)
    }
    
    init(beverage: Beverage, packets: Int = 1) {
        self.packets = max(1, min(packets, 5)) // Limit packets between 1 and 5
        super.init(beverage: beverage)
    }
    
    override func cost() -> Double {
        return super.cost() + (Double(packets) * 0.10)
    }
    
    override var calories: Int {
        return super.calories + (packets * 15)
    }
}

// ShotDecorator adds an extra shot of espresso to a beverage
class ShotDecorator: BeverageDecorator {
    private let shots: Int
    
    override var description: String {
        if shots > 1 {
            return "\(beverage.description) with \(shots) Extra Shots"
        } else {
            return "\(beverage.description) with an Extra Shot"
        }
    }
    
    override var ingredients: [String] {
        // Don't add "Espresso Beans" again if it's already in the ingredients
        if beverage.containsIngredient("Espresso Beans") {
            return beverage.ingredients
        } else {
            return beverage.ingredients + ["Espresso Beans"]
        }
    }
    
    required init(beverage: Beverage) {
        self.shots = 1
        super.init(beverage: beverage)
    }
    
    init(beverage: Beverage, shots: Int = 1) {
        self.shots = max(1, min(shots, 4)) // Limit shots between 1 and 4
        super.init(beverage: beverage)
    }
    
    override func cost() -> Double {
        return super.cost() + (Double(shots) * 0.80)
    }
    
    override var calories: Int {
        return super.calories + (shots * 5)
    }
}

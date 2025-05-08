// ConcreteBeverages.swift - Concrete Component implementations

import Foundation

// Base class for concrete beverages to reduce code duplication
class BaseBeverage: Beverage {
    let description: String
    let size: Size
    let temperature: Temperature
    let basePrice: Double
    let calories: Int
    let ingredients: [String]
    
    init(description: String, size: Size, temperature: Temperature, basePrice: Double, calories: Int, ingredients: [String]) {
        self.description = description
        self.size = size
        self.temperature = temperature
        self.basePrice = basePrice
        self.calories = calories
        self.ingredients = ingredients
    }
    
    // Create a copy with a different size
    func withSize(_ newSize: Size) -> Beverage {
        return BaseBeverage(
            description: description,
            size: newSize,
            temperature: temperature,
            basePrice: basePrice,
            calories: calories,
            ingredients: ingredients
        )
    }
    
    // Create a copy with a different temperature
    func withTemperature(_ newTemperature: Temperature) -> Beverage {
        return BaseBeverage(
            description: description,
            size: size,
            temperature: newTemperature,
            basePrice: basePrice,
            calories: calories,
            ingredients: ingredients
        )
    }
}

// Espresso is a concrete component
class Espresso: BaseBeverage {
    init(size: Size = .small, temperature: Temperature = .hot) {
        super.init(
            description: "Espresso",
            size: size,
            temperature: temperature,
            basePrice: 1.99,
            calories: 5,
            ingredients: ["Espresso Beans", "Water"]
        )
    }
    
    override func withSize(_ newSize: Size) -> Beverage {
        return Espresso(size: newSize, temperature: temperature)
    }
    
    override func withTemperature(_ newTemperature: Temperature) -> Beverage {
        return Espresso(size: size, temperature: newTemperature)
    }
}

// Americano is a concrete component
class Americano: BaseBeverage {
    init(size: Size = .medium, temperature: Temperature = .hot) {
        super.init(
            description: "Americano",
            size: size,
            temperature: temperature,
            basePrice: 2.49,
            calories: 10,
            ingredients: ["Espresso Beans", "Water"]
        )
    }
    
    override func withSize(_ newSize: Size) -> Beverage {
        return Americano(size: newSize, temperature: temperature)
    }
    
    override func withTemperature(_ newTemperature: Temperature) -> Beverage {
        return Americano(size: size, temperature: newTemperature)
    }
}

// Latte is a concrete component
class Latte: BaseBeverage {
    init(size: Size = .medium, temperature: Temperature = .hot) {
        super.init(
            description: "Latte",
            size: size,
            temperature: temperature,
            basePrice: 3.49,
            calories: 120,
            ingredients: ["Espresso Beans", "Steamed Milk", "Milk Foam"]
        )
    }
    
    override func withSize(_ newSize: Size) -> Beverage {
        return Latte(size: newSize, temperature: temperature)
    }
    
    override func withTemperature(_ newTemperature: Temperature) -> Beverage {
        return Latte(size: size, temperature: newTemperature)
    }
}

// Cappuccino is a concrete component
class Cappuccino: BaseBeverage {
    init(size: Size = .medium, temperature: Temperature = .hot) {
        super.init(
            description: "Cappuccino",
            size: size,
            temperature: temperature,
            basePrice: 3.29,
            calories: 110,
            ingredients: ["Espresso Beans", "Steamed Milk", "Milk Foam"]
        )
    }
    
    override func withSize(_ newSize: Size) -> Beverage {
        return Cappuccino(size: newSize, temperature: temperature)
    }
    
    override func withTemperature(_ newTemperature: Temperature) -> Beverage {
        return Cappuccino(size: size, temperature: newTemperature)
    }
}

// Mocha is a concrete component
class Mocha: BaseBeverage {
    init(size: Size = .medium, temperature: Temperature = .hot) {
        super.init(
            description: "Mocha",
            size: size,
            temperature: temperature,
            basePrice: 3.99,
            calories: 250,
            ingredients: ["Espresso Beans", "Steamed Milk", "Chocolate Syrup", "Milk Foam"]
        )
    }
    
    override func withSize(_ newSize: Size) -> Beverage {
        return Mocha(size: newSize, temperature: temperature)
    }
    
    override func withTemperature(_ newTemperature: Temperature) -> Beverage {
        return Mocha(size: size, temperature: newTemperature)
    }
}

// Tea is a concrete component
class Tea: BaseBeverage {
    private let teaType: String
    
    init(teaType: String = "Black", size: Size = .medium, temperature: Temperature = .hot) {
        self.teaType = teaType
        
        let calories: Int
        let basePrice: Double
        
        switch teaType.lowercased() {
        case "green":
            calories = 0
            basePrice = 2.29
        case "herbal":
            calories = 0
            basePrice = 2.49
        case "chai":
            calories = 30
            basePrice = 2.99
        default: // Black tea
            calories = 0
            basePrice = 2.19
        }
        
        super.init(
            description: "\(teaType) Tea",
            size: size,
            temperature: temperature,
            basePrice: basePrice,
            calories: calories,
            ingredients: ["\(teaType) Tea Leaves", "Water"]
        )
    }
    
    override func withSize(_ newSize: Size) -> Beverage {
        return Tea(teaType: teaType, size: newSize, temperature: temperature)
    }
    
    override func withTemperature(_ newTemperature: Temperature) -> Beverage {
        return Tea(teaType: teaType, size: size, temperature: newTemperature)
    }
}

// HotChocolate is a concrete component
class HotChocolate: BaseBeverage {
    init(size: Size = .medium, temperature: Temperature = .hot) {
        super.init(
            description: "Hot Chocolate",
            size: size,
            temperature: temperature,
            basePrice: 3.29,
            calories: 320,
            ingredients: ["Chocolate", "Steamed Milk", "Sugar"]
        )
    }
    
    override func withSize(_ newSize: Size) -> Beverage {
        return HotChocolate(size: newSize, temperature: temperature)
    }
    
    override func withTemperature(_ newTemperature: Temperature) -> Beverage {
        return HotChocolate(size: size, temperature: newTemperature)
    }
}

// Beverage.swift - Component interface for the Decorator Pattern

import Foundation

// Size options for beverages
enum Size: String, CaseIterable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    
    var priceMultiplier: Double {
        switch self {
        case .small: return 1.0
        case .medium: return 1.3
        case .large: return 1.6
        }
    }
}

// Temperature options for beverages
enum Temperature: String, CaseIterable {
    case hot = "Hot"
    case iced = "Iced"
    case frozen = "Frozen"
    
    var additionalCost: Double {
        switch self {
        case .hot: return 0.0
        case .iced: return 0.5
        case .frozen: return 1.0
        }
    }
}

// Beverage is the Component interface that defines the core functionality
protocol Beverage {
    // Basic properties all beverages must have
    var description: String { get }
    var size: Size { get }
    var temperature: Temperature { get }
    var basePrice: Double { get }
    var calories: Int { get }
    var ingredients: [String] { get }
    
    // Calculate the final price including size and temperature adjustments
    func cost() -> Double
    
    // Display detailed information about the beverage
    func getDetails() -> String
    
    // Check if the beverage contains a specific ingredient
    func containsIngredient(_ ingredient: String) -> Bool
    
    // Create a copy of the beverage with a different size
    func withSize(_ newSize: Size) -> Beverage
    
    // Create a copy of the beverage with a different temperature
    func withTemperature(_ newTemperature: Temperature) -> Beverage
}

// Extension to provide default implementations for some methods
extension Beverage {
    // Default implementation for cost calculation
    func cost() -> Double {
        return (basePrice * size.priceMultiplier) + temperature.additionalCost
    }
    
    // Default implementation for detailed information
    func getDetails() -> String {
        let formattedPrice = String(format: "%.2f", cost())
        
        return """
        \(description)
        Size: \(size.rawValue)
        Temperature: \(temperature.rawValue)
        Price: $\(formattedPrice)
        Calories: \(calories)
        Ingredients: \(ingredients.joined(separator: ", "))
        """
    }
    
    // Default implementation for ingredient check
    func containsIngredient(_ ingredient: String) -> Bool {
        return ingredients.contains { $0.lowercased() == ingredient.lowercased() }
    }
}

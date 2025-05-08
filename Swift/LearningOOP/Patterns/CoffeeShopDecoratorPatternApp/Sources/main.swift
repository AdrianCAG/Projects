// main.swift - Entry point for the CoffeeShopDecoratorPatternApp

import Foundation

// Create and start the command-line interface
let cli = CommandLineInterface()
cli.start()

// The following code demonstrates the Decorator Pattern programmatically
// It's not executed in the interactive mode, but shows how the pattern works

func demonstrateDecoratorPattern() {
    print("\n=== DECORATOR PATTERN DEMONSTRATION ===\n")
    
    // Create a base beverage
    let espresso = Espresso()
    print("Base Beverage: \(espresso.description)")
    print("Cost: $\(String(format: "%.2f", espresso.cost()))")
    print("Calories: \(espresso.calories)")
    print("Ingredients: \(espresso.ingredients.joined(separator: ", "))")
    
    // Decorate with milk
    let espressoWithMilk = MilkDecorator(beverage: espresso)
    print("\nAfter adding milk:")
    print("Description: \(espressoWithMilk.description)")
    print("Cost: $\(String(format: "%.2f", espressoWithMilk.cost()))")
    print("Calories: \(espressoWithMilk.calories)")
    print("Ingredients: \(espressoWithMilk.ingredients.joined(separator: ", "))")
    
    // Decorate with whipped cream
    let espressoWithMilkAndWhip = WhippedCreamDecorator(beverage: espressoWithMilk)
    print("\nAfter adding whipped cream:")
    print("Description: \(espressoWithMilkAndWhip.description)")
    print("Cost: $\(String(format: "%.2f", espressoWithMilkAndWhip.cost()))")
    print("Calories: \(espressoWithMilkAndWhip.calories)")
    print("Ingredients: \(espressoWithMilkAndWhip.ingredients.joined(separator: ", "))")
    
    // Decorate with caramel drizzle
    let espressoWithMilkWhipAndCaramel = CaramelDrizzleDecorator(beverage: espressoWithMilkAndWhip)
    print("\nAfter adding caramel drizzle:")
    print("Description: \(espressoWithMilkWhipAndCaramel.description)")
    print("Cost: $\(String(format: "%.2f", espressoWithMilkWhipAndCaramel.cost()))")
    print("Calories: \(espressoWithMilkWhipAndCaramel.calories)")
    print("Ingredients: \(espressoWithMilkWhipAndCaramel.ingredients.joined(separator: ", "))")
    
    // Create a different base beverage
    let mocha = Mocha(size: .large, temperature: .iced)
    print("\nDifferent Base Beverage: \(mocha.description)")
    print("Size: \(mocha.size.rawValue), Temperature: \(mocha.temperature.rawValue)")
    print("Cost: $\(String(format: "%.2f", mocha.cost()))")
    print("Calories: \(mocha.calories)")
    
    // Decorate with multiple decorators at once
    let customMocha = ShotDecorator(
        beverage: WhippedCreamDecorator(
            beverage: FlavorSyrupDecorator(
                beverage: mocha,
                flavor: "Vanilla",
                pumps: 2
            )
        ),
        shots: 2
    )
    
    print("\nComplex Decorated Beverage:")
    print("Description: \(customMocha.description)")
    print("Cost: $\(String(format: "%.2f", customMocha.cost()))")
    print("Calories: \(customMocha.calories)")
    print("Ingredients: \(customMocha.ingredients.joined(separator: ", "))")
    
    print("\n=== END OF DEMONSTRATION ===")
}

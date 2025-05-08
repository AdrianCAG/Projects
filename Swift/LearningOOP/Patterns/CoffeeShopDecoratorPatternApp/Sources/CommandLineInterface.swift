// CommandLineInterface.swift - Command-line interface for the Coffee Shop

import Foundation

// CommandLineInterface handles user interaction through the command line
class CommandLineInterface {
    private let coffeeShop = CoffeeShop()
    private var currentOrder: Order?
    
    // Start the command-line interface
    func start() {
        printWelcomeMessage()
        
        var running = true
        while running {
            printMainMenu()
            
            if let choice = readLine() {
                switch choice.lowercased() {
                case "1":
                    viewMenu()
                case "2":
                    startNewOrder()
                case "3":
                    if let order = currentOrder {
                        print(order.generateReceipt())
                    } else {
                        print("⚠️ No active order. Please start a new order first.")
                    }
                case "4":
                    running = false
                    print("Thank you for visiting our Coffee Shop! Goodbye!")
                default:
                    print("⚠️ Invalid choice. Please try again.")
                }
            }
        }
    }
    
    // Print welcome message
    private func printWelcomeMessage() {
        print("""
        ╔════════════════════════════════════════════════════════════════╗
        ║                                                                ║
        ║                 Welcome to the Coffee Shop                     ║
        ║                                                                ║
        ║  This application demonstrates the Decorator Design Pattern    ║
        ║  by implementing a coffee shop ordering system where           ║
        ║  beverages can be customized with various add-ons.            ║
        ║                                                                ║
        ╚════════════════════════════════════════════════════════════════╝
        """)
        
        print("""
        The Decorator Pattern allows behavior to be added to individual objects
        dynamically without affecting the behavior of other objects from the same class.
        
        In this application:
        • Beverage is the Component interface
        • Concrete beverages (Espresso, Latte, etc.) are Concrete Components
        • BeverageDecorator is the Decorator abstract class
        • Various add-ons (Milk, WhippedCream, etc.) are Concrete Decorators
        
        Let's see the pattern in action!
        """)
    }
    
    // Print main menu
    private func printMainMenu() {
        print("""
        
        ===== MAIN MENU =====
        1. View Menu
        2. Start New Order
        3. View Current Order
        4. Exit
        
        Please enter your choice (1-4):
        """)
    }
    
    // View the coffee shop menu
    private func viewMenu() {
        print(coffeeShop.getMenuAsString())
    }
    
    // Start a new order
    private func startNewOrder() {
        print("\nPlease enter your name:")
        guard let name = readLine(), !name.isEmpty else {
            print("⚠️ Name cannot be empty. Order cancelled.")
            return
        }
        
        currentOrder = coffeeShop.createOrder(customerName: name)
        print("Order #\(currentOrder!.orderNumber) created for \(name).")
        
        orderBeverages()
    }
    
    // Order beverages
    private func orderBeverages() {
        var ordering = true
        
        while ordering {
            print("""
            
            ===== ORDER MENU =====
            1. Add a Base Beverage
            2. Add a Specialty Drink
            3. Create a Custom Beverage
            4. Remove a Beverage
            5. Finish Order
            
            Please enter your choice (1-5):
            """)
            
            guard let choice = readLine() else { continue }
            
            switch choice {
            case "1":
                addBaseBeverage()
            case "2":
                addSpecialtyDrink()
            case "3":
                createCustomBeverage()
            case "4":
                removeBeverage()
            case "5":
                ordering = false
                print("\nOrder completed! Here's your receipt:")
                print(currentOrder!.generateReceipt())
            default:
                print("⚠️ Invalid choice. Please try again.")
            }
        }
    }
    
    // Add a base beverage to the order
    private func addBaseBeverage() {
        let baseBeverages = [
            "1": ("Espresso", "espresso"),
            "2": ("Americano", "americano"),
            "3": ("Latte", "latte"),
            "4": ("Cappuccino", "cappuccino"),
            "5": ("Mocha", "mocha"),
            "6": ("Black Tea", "black_tea"),
            "7": ("Green Tea", "green_tea"),
            "8": ("Chai Tea", "chai_tea"),
            "9": ("Herbal Tea", "herbal_tea"),
            "10": ("Hot Chocolate", "hot_chocolate")
        ]
        
        print("\n===== BASE BEVERAGES =====")
        for (key, (name, _)) in baseBeverages {
            print("\(key). \(name)")
        }
        
        print("\nPlease select a beverage (1-10):")
        guard let choice = readLine(), let (name, key) = baseBeverages[choice] else {
            print("⚠️ Invalid choice. Returning to order menu.")
            return
        }
        
        // Get size
        let size = selectSize()
        
        // Get temperature
        let temperature = selectTemperature()
        
        // Create the beverage
        guard var beverage = coffeeShop.getBeverage(name: key) else {
            print("⚠️ Error creating beverage. Returning to order menu.")
            return
        }
        
        // Apply size and temperature
        beverage = beverage.withSize(size)
        beverage = beverage.withTemperature(temperature)
        
        // Get quantity
        let quantity = getQuantity()
        
        // Add to order
        currentOrder?.addBeverage(beverage, quantity: quantity)
        
        print("✅ Added \(quantity) \(name) (\(size.rawValue), \(temperature.rawValue)) to your order.")
    }
    
    // Add a specialty drink to the order
    private func addSpecialtyDrink() {
        let specialtyDrinks = [
            "1": ("Caramel Macchiato", "caramel_macchiato"),
            "2": ("Mocha with Whipped Cream", "mocha_with_whip"),
            "3": ("Chai Latte", "chai_latte"),
            "4": ("Double Shot Americano", "double_shot_americano")
        ]
        
        print("\n===== SPECIALTY DRINKS =====")
        for (key, (name, _)) in specialtyDrinks {
            print("\(key). \(name)")
        }
        
        print("\nPlease select a specialty drink (1-4):")
        guard let choice = readLine(), let (name, key) = specialtyDrinks[choice] else {
            print("⚠️ Invalid choice. Returning to order menu.")
            return
        }
        
        // Get size
        let size = selectSize()
        
        // Get temperature
        let temperature = selectTemperature()
        
        // Create the beverage
        guard var beverage = coffeeShop.getBeverage(name: key) else {
            print("⚠️ Error creating beverage. Returning to order menu.")
            return
        }
        
        // Apply size and temperature
        beverage = beverage.withSize(size)
        beverage = beverage.withTemperature(temperature)
        
        // Get quantity
        let quantity = getQuantity()
        
        // Add to order
        currentOrder?.addBeverage(beverage, quantity: quantity)
        
        print("✅ Added \(quantity) \(name) (\(size.rawValue), \(temperature.rawValue)) to your order.")
    }
    
    // Create a custom beverage
    private func createCustomBeverage() {
        // Select base beverage
        let baseBeverages = [
            "1": ("Espresso", "espresso"),
            "2": ("Americano", "americano"),
            "3": ("Latte", "latte"),
            "4": ("Cappuccino", "cappuccino"),
            "5": ("Mocha", "mocha"),
            "6": ("Black Tea", "black_tea"),
            "7": ("Green Tea", "green_tea"),
            "8": ("Chai Tea", "chai_tea"),
            "9": ("Herbal Tea", "herbal_tea"),
            "10": ("Hot Chocolate", "hot_chocolate")
        ]
        
        print("\n===== CREATE CUSTOM BEVERAGE =====")
        print("First, select a base beverage:")
        
        for (key, (name, _)) in baseBeverages {
            print("\(key). \(name)")
        }
        
        print("\nPlease select a base beverage (1-10):")
        guard let choice = readLine(), let (name, key) = baseBeverages[choice] else {
            print("⚠️ Invalid choice. Returning to order menu.")
            return
        }
        
        // Get size
        let size = selectSize()
        
        // Get temperature
        let temperature = selectTemperature()
        
        // Customization options
        var milkType: String? = nil
        var whippedCream = false
        var flavorSyrup: (flavor: String, pumps: Int)? = nil
        var caramelDrizzle = false
        var extraCaramel = false
        var chocolateDrizzle = false
        var extraChocolate = false
        var cinnamon = false
        var sugar = 0
        var extraShots = 0
        
        // Add milk
        print("\nWould you like to add milk? (y/n):")
        if readLine()?.lowercased() == "y" {
            print("\nSelect milk type:")
            print("1. Whole Milk (+$0.60)")
            print("2. Skim Milk (+$0.50)")
            print("3. Almond Milk (+$0.75)")
            print("4. Oat Milk (+$0.80)")
            print("5. Soy Milk (+$0.70)")
            
            if let milkChoice = readLine() {
                switch milkChoice {
                case "1": milkType = "Whole"
                case "2": milkType = "Skim"
                case "3": milkType = "Almond"
                case "4": milkType = "Oat"
                case "5": milkType = "Soy"
                default: print("⚠️ Invalid choice. No milk added.")
                }
            }
        }
        
        // Add whipped cream
        print("\nWould you like to add whipped cream? (+$0.75) (y/n):")
        whippedCream = readLine()?.lowercased() == "y"
        
        // Add flavor syrup
        print("\nWould you like to add flavor syrup? (y/n):")
        if readLine()?.lowercased() == "y" {
            print("\nSelect flavor:")
            print("1. Vanilla")
            print("2. Caramel")
            print("3. Hazelnut")
            print("4. Chocolate")
            print("5. Peppermint")
            
            var flavor = ""
            if let flavorChoice = readLine() {
                switch flavorChoice {
                case "1": flavor = "Vanilla"
                case "2": flavor = "Caramel"
                case "3": flavor = "Hazelnut"
                case "4": flavor = "Chocolate"
                case "5": flavor = "Peppermint"
                default:
                    print("⚠️ Invalid choice. No syrup added.")
                    flavor = ""
                }
            }
            
            if !flavor.isEmpty {
                print("\nHow many pumps? (1-5) (+$0.50 per pump):")
                if let pumpsStr = readLine(), let pumps = Int(pumpsStr), pumps > 0 && pumps <= 5 {
                    flavorSyrup = (flavor: flavor, pumps: pumps)
                } else {
                    print("⚠️ Invalid choice. Using 1 pump.")
                    flavorSyrup = (flavor: flavor, pumps: 1)
                }
            }
        }
        
        // Add caramel drizzle
        print("\nWould you like to add caramel drizzle? (+$0.60) (y/n):")
        caramelDrizzle = readLine()?.lowercased() == "y"
        
        if caramelDrizzle {
            print("Would you like extra caramel drizzle? (+$0.40 more) (y/n):")
            extraCaramel = readLine()?.lowercased() == "y"
        }
        
        // Add chocolate drizzle
        print("\nWould you like to add chocolate drizzle? (+$0.60) (y/n):")
        chocolateDrizzle = readLine()?.lowercased() == "y"
        
        if chocolateDrizzle {
            print("Would you like extra chocolate drizzle? (+$0.40 more) (y/n):")
            extraChocolate = readLine()?.lowercased() == "y"
        }
        
        // Add cinnamon
        print("\nWould you like to add cinnamon? (+$0.25) (y/n):")
        cinnamon = readLine()?.lowercased() == "y"
        
        // Add sugar
        print("\nHow many packets of sugar would you like to add? (0-5) (+$0.10 per packet):")
        if let sugarStr = readLine(), let sugarPackets = Int(sugarStr), sugarPackets >= 0 && sugarPackets <= 5 {
            sugar = sugarPackets
        }
        
        // Add extra shots
        print("\nHow many extra shots of espresso would you like to add? (0-4) (+$0.80 per shot):")
        if let shotsStr = readLine(), let shots = Int(shotsStr), shots >= 0 && shots <= 4 {
            extraShots = shots
        }
        
        // Create the custom beverage
        guard let beverage = coffeeShop.createCustomBeverage(
            baseBeverageName: key,
            size: size,
            temperature: temperature,
            milkType: milkType,
            whippedCream: whippedCream,
            flavorSyrup: flavorSyrup,
            caramelDrizzle: caramelDrizzle,
            extraCaramel: extraCaramel,
            chocolateDrizzle: chocolateDrizzle,
            extraChocolate: extraChocolate,
            cinnamon: cinnamon,
            sugar: sugar,
            extraShots: extraShots
        ) else {
            print("⚠️ Error creating custom beverage. Returning to order menu.")
            return
        }
        
        // Get quantity
        let quantity = getQuantity()
        
        // Add to order
        currentOrder?.addBeverage(beverage, quantity: quantity)
        
        print("✅ Added \(quantity) custom \(name) to your order.")
        print("Description: \(beverage.description)")
        print("Price: $\(String(format: "%.2f", beverage.cost())) each")
    }
    
    // Remove a beverage from the order
    private func removeBeverage() {
        guard let order = currentOrder, !order.items.isEmpty else {
            print("⚠️ No items in the current order.")
            return
        }
        
        print("\n===== CURRENT ORDER ITEMS =====")
        for (index, item) in order.items.enumerated() {
            print("\(index + 1). \(item.beverage.description) (Qty: \(item.quantity)) - $\(String(format: "%.2f", item.subtotal))")
        }
        
        print("\nEnter the number of the item to remove:")
        if let choice = readLine(), let index = Int(choice), index > 0 && index <= order.items.count {
            let item = order.items[index - 1]
            order.removeBeverage(at: index - 1)
            print("✅ Removed \(item.beverage.description) from your order.")
        } else {
            print("⚠️ Invalid choice. No items removed.")
        }
    }
    
    // Helper method to select size
    private func selectSize() -> Size {
        print("\nSelect size:")
        print("1. Small")
        print("2. Medium (+30%)")
        print("3. Large (+60%)")
        
        if let sizeChoice = readLine() {
            switch sizeChoice {
            case "1": return .small
            case "3": return .large
            default: return .medium
            }
        }
        
        return .medium
    }
    
    // Helper method to select temperature
    private func selectTemperature() -> Temperature {
        print("\nSelect temperature:")
        print("1. Hot")
        print("2. Iced (+$0.50)")
        print("3. Frozen (+$1.00)")
        
        if let tempChoice = readLine() {
            switch tempChoice {
            case "2": return .iced
            case "3": return .frozen
            default: return .hot
            }
        }
        
        return .hot
    }
    
    // Helper method to get quantity
    private func getQuantity() -> Int {
        print("\nHow many would you like? (1-10):")
        if let quantityStr = readLine(), let quantity = Int(quantityStr), quantity > 0 && quantity <= 10 {
            return quantity
        }
        
        print("⚠️ Invalid quantity. Using 1.")
        return 1
    }
}

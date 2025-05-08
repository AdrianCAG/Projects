// CoffeeShop.swift - Coffee shop implementation to demonstrate the Decorator Pattern

import Foundation

// Order item represents a beverage in an order with a quantity
struct OrderItem {
    let beverage: Beverage
    let quantity: Int
    
    var subtotal: Double {
        return beverage.cost() * Double(quantity)
    }
}

// Order represents a customer's order with multiple beverages
class Order {
    private(set) var items: [OrderItem] = []
    private(set) var customerName: String
    private(set) var orderNumber: Int
    private(set) var orderDate: Date
    
    init(customerName: String, orderNumber: Int) {
        self.customerName = customerName
        self.orderNumber = orderNumber
        self.orderDate = Date()
    }
    
    // Add a beverage to the order
    func addBeverage(_ beverage: Beverage, quantity: Int = 1) {
        items.append(OrderItem(beverage: beverage, quantity: quantity))
    }
    
    // Remove a beverage from the order
    func removeBeverage(at index: Int) {
        guard index >= 0 && index < items.count else { return }
        items.remove(at: index)
    }
    
    // Calculate the total cost of the order
    func totalCost() -> Double {
        return items.reduce(0) { $0 + $1.subtotal }
    }
    
    // Calculate the total calories of the order
    func totalCalories() -> Int {
        return items.reduce(0) { $0 + ($1.beverage.calories * $1.quantity) }
    }
    
    // Generate a receipt for the order
    func generateReceipt() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        var receipt = """
        ===================================
                COFFEE SHOP RECEIPT
        ===================================
        Order #: \(orderNumber)
        Date: \(dateFormatter.string(from: orderDate))
        Customer: \(customerName)
        -----------------------------------
        
        """
        
        for (index, item) in items.enumerated() {
            let beverage = item.beverage
            let itemTotal = String(format: "%.2f", item.subtotal)
            
            receipt += """
            \(index + 1). \(beverage.description)
               Size: \(beverage.size.rawValue)
               Temperature: \(beverage.temperature.rawValue)
               Quantity: \(item.quantity)
               Price: $\(String(format: "%.2f", beverage.cost())) each
               Subtotal: $\(itemTotal)
            
            """
        }
        
        let total = String(format: "%.2f", totalCost())
        let tax = String(format: "%.2f", totalCost() * 0.08) // 8% tax
        let grandTotal = String(format: "%.2f", totalCost() * 1.08)
        
        receipt += """
        -----------------------------------
        Subtotal: $\(total)
        Tax (8%): $\(tax)
        Total: $\(grandTotal)
        
        Total Calories: \(totalCalories())
        
        ===================================
        Thank you for your order!
        Please come again!
        ===================================
        """
        
        return receipt
    }
}

// CoffeeShop manages the coffee shop operations
class CoffeeShop {
    private var orderCounter: Int = 1000
    private var orders: [Order] = []
    private var menu: [String: Beverage] = [:]
    
    init() {
        setupMenu()
    }
    
    // Setup the base menu
    private func setupMenu() {
        // Add base beverages to the menu
        menu["espresso"] = Espresso()
        menu["americano"] = Americano()
        menu["latte"] = Latte()
        menu["cappuccino"] = Cappuccino()
        menu["mocha"] = Mocha()
        menu["black_tea"] = Tea(teaType: "Black")
        menu["green_tea"] = Tea(teaType: "Green")
        menu["chai_tea"] = Tea(teaType: "Chai")
        menu["herbal_tea"] = Tea(teaType: "Herbal")
        menu["hot_chocolate"] = HotChocolate()
        
        // Add some pre-configured specialty drinks
        
        // Caramel Macchiato
        let baseLatte = Latte()
        let vanillaLatte = FlavorSyrupDecorator(beverage: baseLatte, flavor: "Vanilla", pumps: 2)
        let caramelMacchiato = CaramelDrizzleDecorator(beverage: vanillaLatte, extraDrizzle: true)
        menu["caramel_macchiato"] = caramelMacchiato
        
        // Mocha with Whipped Cream
        let baseMocha = Mocha()
        let mochaWithWhip = WhippedCreamDecorator(beverage: baseMocha)
        menu["mocha_with_whip"] = mochaWithWhip
        
        // Chai Tea Latte
        let baseTea = Tea(teaType: "Chai")
        let milkTea = MilkDecorator(beverage: baseTea)
        let chaiLatte = CinnamonDecorator(beverage: milkTea)
        menu["chai_latte"] = chaiLatte
        
        // Double Shot Americano
        let baseAmericano = Americano()
        let doubleShot = ShotDecorator(beverage: baseAmericano)
        menu["double_shot_americano"] = doubleShot
    }
    
    // Create a new order
    func createOrder(customerName: String) -> Order {
        let order = Order(customerName: customerName, orderNumber: orderCounter)
        orderCounter += 1
        orders.append(order)
        return order
    }
    
    // Get a beverage from the menu
    func getBeverage(name: String) -> Beverage? {
        return menu[name.lowercased()]
    }
    
    // Get the menu as a formatted string
    func getMenuAsString() -> String {
        var menuString = """
        ===================================
                COFFEE SHOP MENU
        ===================================
        
        BASE BEVERAGES:
        """
        
        // Add base beverages
        let baseBeverages = [
            "Espresso", "Americano", "Latte", "Cappuccino", "Mocha",
            "Black Tea", "Green Tea", "Chai Tea", "Herbal Tea", "Hot Chocolate"
        ]
        
        for (index, name) in baseBeverages.enumerated() {
            let key = name.lowercased().replacingOccurrences(of: " ", with: "_")
            if let beverage = menu[key] {
                let price = String(format: "%.2f", beverage.cost())
                menuString += "\n\(index + 1). \(name) - $\(price)"
            }
        }
        
        // Add specialty drinks
        menuString += "\n\nSPECIALTY DRINKS:"
        
        let specialtyDrinks = [
            "Caramel Macchiato": "caramel_macchiato",
            "Mocha with Whipped Cream": "mocha_with_whip",
            "Chai Latte": "chai_latte",
            "Double Shot Americano": "double_shot_americano"
        ]
        
        for (index, (name, key)) in specialtyDrinks.enumerated() {
            if let beverage = menu[key] {
                let price = String(format: "%.2f", beverage.cost())
                menuString += "\n\(index + 1). \(name) - $\(price)"
            }
        }
        
        // Add customization options
        menuString += """
        
        
        CUSTOMIZATION OPTIONS:
        
        Sizes:
        - Small (base price)
        - Medium (+30%)
        - Large (+60%)
        
        Temperatures:
        - Hot (base price)
        - Iced (+$0.50)
        - Frozen (+$1.00)
        
        Add-ons:
        - Milk: Whole (+$0.60), Skim (+$0.50), Almond (+$0.75), Oat (+$0.80), Soy (+$0.70)
        - Whipped Cream (+$0.75)
        - Flavor Syrups: Vanilla, Caramel, Hazelnut, etc. (+$0.50 per pump)
        - Caramel Drizzle (+$0.60, Extra: +$1.00)
        - Chocolate Drizzle (+$0.60, Extra: +$1.00)
        - Cinnamon (+$0.25)
        - Sugar (+$0.10 per packet)
        - Extra Shot of Espresso (+$0.80 per shot)
        
        ===================================
        """
        
        return menuString
    }
    
    // Create a customized beverage based on user selections
    func createCustomBeverage(
        baseBeverageName: String,
        size: Size = .medium,
        temperature: Temperature = .hot,
        milkType: String? = nil,
        whippedCream: Bool = false,
        flavorSyrup: (flavor: String, pumps: Int)? = nil,
        caramelDrizzle: Bool = false,
        extraCaramel: Bool = false,
        chocolateDrizzle: Bool = false,
        extraChocolate: Bool = false,
        cinnamon: Bool = false,
        sugar: Int = 0,
        extraShots: Int = 0
    ) -> Beverage? {
        // Get the base beverage
        guard var beverage = getBeverage(name: baseBeverageName) else {
            return nil
        }
        
        // Apply size and temperature
        beverage = beverage.withSize(size)
        beverage = beverage.withTemperature(temperature)
        
        // Apply decorators based on customizations
        if let milkType = milkType {
            beverage = MilkDecorator(beverage: beverage, milkType: milkType)
        }
        
        if whippedCream {
            beverage = WhippedCreamDecorator(beverage: beverage)
        }
        
        if let syrup = flavorSyrup {
            beverage = FlavorSyrupDecorator(beverage: beverage, flavor: syrup.flavor, pumps: syrup.pumps)
        }
        
        if caramelDrizzle {
            beverage = CaramelDrizzleDecorator(beverage: beverage, extraDrizzle: extraCaramel)
        }
        
        if chocolateDrizzle {
            beverage = ChocolateDrizzleDecorator(beverage: beverage, extraDrizzle: extraChocolate)
        }
        
        if cinnamon {
            beverage = CinnamonDecorator(beverage: beverage)
        }
        
        if sugar > 0 {
            beverage = SugarDecorator(beverage: beverage, packets: sugar)
        }
        
        if extraShots > 0 {
            beverage = ShotDecorator(beverage: beverage, shots: extraShots)
        }
        
        return beverage
    }
}

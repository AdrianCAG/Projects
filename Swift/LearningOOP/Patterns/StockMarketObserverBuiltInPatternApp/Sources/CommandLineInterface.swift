// CommandLineInterface.swift
// Handles user interactions with the stock market application

import Foundation

/// CommandLineInterface handles user input and output for the stock market application
class CommandLineInterface {
    /// The stock market singleton instance
    private let stockMarket = StockMarket.shared
    
    /// List of created observers info
    private var createdObserversInfo: [(type: String, name: String, id: UUID)] = []
    
    /// Strong references to actual observer objects to prevent deallocation
    private var observers: [Any] = []
    
    /// Initialize a new command line interface
    init() {
        print("Stock Market Observer Pattern Application (Built-in)")
        print("--------------------------------------------------")
    }
    
    /// Start the command line interface
    func start() {
        // Create some predefined observers
        createDefaultObservers()
        
        var isRunning = true
        
        while isRunning {
            displayMenu()
            
            if let choice = readLine(), let option = Int(choice) {
                switch option {
                case 1:
                    displayAllStocks()
                case 2:
                    registerNewObserver()
                case 3:
                    unregisterObserver()
                case 4:
                    updateStockPrice()
                case 5:
                    addNewStock()
                case 6:
                    simulateMarketChanges()
                case 7:
                    displayObservers()
                case 8:
                    isRunning = false
                    print("Exiting application. Goodbye!")
                default:
                    print("Invalid option. Please try again.")
                }
            } else {
                print("Please enter a valid number.")
            }
            
            // Add a pause to allow reading output
            if isRunning {
                print("\nPress Enter to continue...")
                _ = readLine()
            }
        }
    }
    
    /// Display the main menu
    private func displayMenu() {
        print("\n===== Stock Market Menu =====")
        print("1. Display All Stocks")
        print("2. Register New Observer")
        print("3. Unregister Observer")
        print("4. Update Stock Price")
        print("5. Add New Stock")
        print("6. Simulate Market Changes")
        print("7. Display Registered Observers")
        print("8. Exit")
        print("============================")
        print("Enter your choice: ", terminator: "")
    }
    
    /// Create default observers for demonstration
    private func createDefaultObservers() {
        // Create observers
        let investor1 = StockInvestor(name: "Alice", interestedStocks: ["AAPL", "MSFT", "GOOGL"])
        let investor2 = StockInvestor(name: "Bob", interestedStocks: ["AMZN", "TSLA", "AAPL"])
        let analyst1 = StockAnalyst(name: "Charlie", firm: "InvestCo")
        
        // Add to our local list (no explicit registration needed with NotificationCenter)
        createdObserversInfo.append((type: "Investor", name: investor1.name, id: investor1.id))
        createdObserversInfo.append((type: "Investor", name: investor2.name, id: investor2.id))
        createdObserversInfo.append((type: "Analyst", name: analyst1.name, id: analyst1.id))
        
        // Keep strong references to prevent deallocation
        observers.append(investor1)
        observers.append(investor2)
        observers.append(analyst1)
        
        print("Default observers created.")
    }
    
    /// Display all stocks in the market
    private func displayAllStocks() {
        print("\n===== Current Stock Prices =====")
        let stocks = stockMarket.getAllStocks()
        
        for (_, stock) in stocks.sorted(by: { $0.key < $1.key }) {
            print("\(stock.symbol): $\(String(format: "%.2f", stock.price)) (\(stock.changeDescription))")
        }
    }
    
    /// Register a new observer
    private func registerNewObserver() {
        print("\n===== Register New Observer =====")
        print("Select observer type:")
        print("1. Investor")
        print("2. Analyst")
        print("Enter choice: ", terminator: "")
        
        guard let choice = readLine(), let option = Int(choice), option == 1 || option == 2 else {
            print("Invalid option. Registration cancelled.")
            return
        }
        
        print("Enter name: ", terminator: "")
        guard let name = readLine(), !name.isEmpty else {
            print("Invalid name. Registration cancelled.")
            return
        }
        
        var id: UUID
        
        if option == 1 {
            // Create an investor
            print("Enter interested stocks (comma-separated, e.g., AAPL,MSFT): ", terminator: "")
            guard let stockInput = readLine() else {
                print("Invalid input. Registration cancelled.")
                return
            }
            
            let interestedStocks = stockInput.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
            let investor = StockInvestor(name: name, interestedStocks: interestedStocks)
            id = investor.id
            createdObserversInfo.append((type: "Investor", name: name, id: id))
            observers.append(investor)
            
        } else {
            // Create an analyst
            print("Enter firm name: ", terminator: "")
            guard let firm = readLine(), !firm.isEmpty else {
                print("Invalid firm name. Registration cancelled.")
                return
            }
            
            let analyst = StockAnalyst(name: name, firm: firm)
            id = analyst.id
            createdObserversInfo.append((type: "Analyst", name: name, id: id))
            observers.append(analyst)
        }
        
        print("Observer registered successfully.")
    }
    
    /// Unregister an observer
    /// Note: This is more conceptual since NotificationCenter observers need
    /// to be unregistered from within their own objects (which happens in deinit)
    private func unregisterObserver() {
        print("\n===== Unregister Observer =====")
        
        if createdObserversInfo.isEmpty {
            print("No observers to unregister.")
            return
        }
        
        print("Select observer to unregister:")
        for (index, observer) in createdObserversInfo.enumerated() {
            print("\(index + 1). \(observer.type): \(observer.name)")
        }
        
        print("Enter choice (or 0 to cancel): ", terminator: "")
        guard let choice = readLine(), let option = Int(choice), option > 0, option <= createdObserversInfo.count else {
            print("Invalid option or cancelled.")
            return
        }
        
        // Remove from our tracking list and the strong reference
        createdObserversInfo.remove(at: option - 1)
        observers.remove(at: option - 1)
        
        print("Observer unregistered successfully.")
        print("Note: In a real application, the observer object would need to be deallocated to fully unregister from NotificationCenter.")
    }
    
    /// Update the price of a stock
    private func updateStockPrice() {
        print("\n===== Update Stock Price =====")
        print("Enter stock symbol: ", terminator: "")
        guard let symbol = readLine()?.uppercased(), !symbol.isEmpty else {
            print("Invalid symbol.")
            return
        }
        
        guard stockMarket.getStock(symbol: symbol) != nil else {
            print("Stock not found.")
            return
        }
        
        print("Enter new price: ", terminator: "")
        guard let priceInput = readLine(), let price = Double(priceInput), price > 0 else {
            print("Invalid price.")
            return
        }
        
        stockMarket.updateStockPrice(symbol: symbol, price: price)
    }
    
    /// Add a new stock to the market
    private func addNewStock() {
        print("\n===== Add New Stock =====")
        print("Enter stock symbol: ", terminator: "")
        guard let symbol = readLine()?.uppercased(), !symbol.isEmpty else {
            print("Invalid symbol.")
            return
        }
        
        if stockMarket.getStock(symbol: symbol) != nil {
            print("Stock already exists.")
            return
        }
        
        print("Enter initial price: ", terminator: "")
        guard let priceInput = readLine(), let price = Double(priceInput), price > 0 else {
            print("Invalid price.")
            return
        }
        
        stockMarket.addStock(symbol: symbol, initialPrice: price)
    }
    
    /// Simulate random market changes
    private func simulateMarketChanges() {
        print("\n===== Simulating Market Changes =====")
        stockMarket.simulateMarketChanges()
    }
    
    /// Display all created observers
    private func displayObservers() {
        print("\n===== Registered Observers =====")
        
        if createdObserversInfo.isEmpty {
            print("No observers registered.")
            return
        }
        
        for observer in createdObserversInfo {
            print("\(observer.type): \(observer.name) (ID: \(observer.id))")
        }
    }
}

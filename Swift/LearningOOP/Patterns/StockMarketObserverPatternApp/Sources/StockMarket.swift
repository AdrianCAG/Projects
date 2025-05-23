// StockMarket.swift
// A concrete implementation of the Subject protocol

import Foundation

/// Represents a stock and its current price
struct Stock {
    let symbol: String
    var price: Double
    var previousPrice: Double
    
    /// Calculate the percent change from the previous price
    var percentChange: Double {
        guard previousPrice > 0 else { return 0 }
        return ((price - previousPrice) / previousPrice) * 100
    }
    
    /// Returns a string with the percent change formatted
    var changeDescription: String {
        let prefix = percentChange >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.2f", percentChange))%"
    }
    
    /// Initialize a new stock
    /// - Parameters:
    ///   - symbol: The stock symbol (e.g., AAPL, MSFT)
    ///   - price: The initial price
    init(symbol: String, price: Double) {
        self.symbol = symbol
        self.price = price
        self.previousPrice = price
    }
    
    /// Update the stock price
    /// - Parameter newPrice: The new price
    mutating func updatePrice(newPrice: Double) {
        previousPrice = price
        price = newPrice
    }
}

/// StockMarket class maintains a collection of stocks and notifies observers of price changes
class StockMarket: Subject {
    /// Singleton instance of the stock market
    static let shared = StockMarket()
    
    /// Collection of stocks
    private var stocks: [String: Stock] = [:]
    
    /// Collection of registered observers
    private var observers: [UUID: Observer] = [:]
    
    /// Initialize with some default stocks
    private init() {
        stocks["AAPL"] = Stock(symbol: "AAPL", price: 150.0)
        stocks["MSFT"] = Stock(symbol: "MSFT", price: 250.0)
        stocks["GOOGL"] = Stock(symbol: "GOOGL", price: 2800.0)
        stocks["AMZN"] = Stock(symbol: "AMZN", price: 3300.0)
        stocks["TSLA"] = Stock(symbol: "TSLA", price: 800.0)
    }
    
    /// Register an observer to receive updates
    /// - Parameter observer: The observer to register
    func register(observer: Observer) {
        observers[observer.id] = observer
        print("Observer with ID \(observer.id) has been registered")
    }
    
    /// Unregister an observer to stop receiving updates
    /// - Parameter observer: The observer to unregister
    func unregister(observer: Observer) {
        observers.removeValue(forKey: observer.id)
        print("Observer with ID \(observer.id) has been unregistered")
    }
    
    /// Notify all registered observers of a change
    func notifyObservers() {
        for (_, observer) in observers {
            observer.update(data: stocks)
        }
    }
    
    /// Get all stocks
    /// - Returns: Dictionary of all stocks
    func getAllStocks() -> [String: Stock] {
        return stocks
    }
    
    /// Get a specific stock by symbol
    /// - Parameter symbol: The stock symbol
    /// - Returns: The stock if found, nil otherwise
    func getStock(symbol: String) -> Stock? {
        return stocks[symbol]
    }
    
    /// Update the price of a stock
    /// - Parameters:
    ///   - symbol: The stock symbol
    ///   - price: The new price
    func updateStockPrice(symbol: String, price: Double) {
        guard var stock = stocks[symbol] else {
            print("Stock with symbol \(symbol) not found")
            return
        }
        
        stock.updatePrice(newPrice: price)
        stocks[symbol] = stock
        print("Updated \(symbol) price to $\(String(format: "%.2f", price)) (\(stock.changeDescription))")
        
        // Notify observers about the change
        notifyObservers()
    }
    
    /// Add a new stock to the market
    /// - Parameters:
    ///   - symbol: The stock symbol
    ///   - initialPrice: The initial price
    func addStock(symbol: String, initialPrice: Double) {
        guard stocks[symbol] == nil else {
            print("Stock with symbol \(symbol) already exists")
            return
        }
        
        stocks[symbol] = Stock(symbol: symbol, price: initialPrice)
        print("Added new stock: \(symbol) at $\(String(format: "%.2f", initialPrice))")
        
        // Notify observers about the change
        notifyObservers()
    }
    
    /// Remove a stock from the market
    /// - Parameter symbol: The stock symbol
    func removeStock(symbol: String) {
        guard stocks[symbol] != nil else {
            print("Stock with symbol \(symbol) not found")
            return
        }
        
        stocks.removeValue(forKey: symbol)
        print("Removed stock: \(symbol)")
        
        // Notify observers about the change
        notifyObservers()
    }
    
    /// Simulate random market changes
    func simulateMarketChanges() {
        for symbol in stocks.keys {
            guard var stock = stocks[symbol] else { continue }
            
            // Generate random price change between -5% and +5%
            let randomChangePercent = Double.random(in: -5.0...5.0)
            let changeAmount = stock.price * (randomChangePercent / 100.0)
            let newPrice = max(stock.price + changeAmount, 0.01) // Ensure price doesn't go below $0.01
            
            stock.updatePrice(newPrice: newPrice)
            stocks[symbol] = stock
        }
        
        print("Market changes simulated")
        notifyObservers()
    }
}

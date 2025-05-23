// StockInvestor.swift
// A concrete implementation of the Observer protocol

import Foundation

/// An investor who observes stock prices and makes investment decisions
class StockInvestor: Observer {
    /// Unique identifier for the observer
    let id = UUID()
    
    /// The name of the investor
    let name: String
    
    /// The stocks the investor is interested in
    private let interestedStocks: [String]
    
    /// Portfolio of stocks and quantities owned
    private var portfolio: [String: Int] = [:]
    
    /// Available cash for investments
    private var cash: Double
    
    /// Initialize a new investor
    /// - Parameters:
    ///   - name: The investor's name
    ///   - interestedStocks: Array of stock symbols the investor is interested in
    ///   - initialCash: Initial cash available (default: $10,000)
    init(name: String, interestedStocks: [String], initialCash: Double = 10000.0) {
        self.name = name
        self.interestedStocks = interestedStocks
        self.cash = initialCash
        
        // Start with some initial investments
        for symbol in interestedStocks {
            portfolio[symbol] = Int.random(in: 0...10)
        }
    }
    
    /// Update method called when the subject (stock market) changes
    /// - Parameter data: Dictionary of stock symbols and their current data
    func update(data: Any?) {
        guard let stocks = data as? [String: Stock] else { return }
        
        print("\n\(name) received stock market update:")
        
        // Filter for only the stocks this investor is interested in
        for symbol in interestedStocks {
            guard let stock = stocks[symbol] else { continue }
            
            let sharesOwned = portfolio[symbol] ?? 0
            let portfolioValue = Double(sharesOwned) * stock.price
            
            print("  - \(symbol): $\(String(format: "%.2f", stock.price)) (\(stock.changeDescription)) | Owned: \(sharesOwned) shares ($\(String(format: "%.2f", portfolioValue)))")
            
            // Make a simple investment decision based on price change
            makeInvestmentDecision(for: stock)
        }
        
        printPortfolioSummary(using: stocks)
    }
    
    /// Make an investment decision based on stock price changes
    /// - Parameter stock: The stock to evaluate
    private func makeInvestmentDecision(for stock: Stock) {
        // This is a very simplified algorithm:
        // - Buy if price dropped more than 2%
        // - Sell if price increased more than 2%
        
        let sharesOwned = portfolio[stock.symbol] ?? 0
        
        if stock.percentChange <= -2.0 && cash >= stock.price {
            // Buy opportunity - price dropped significantly
            let sharesToBuy = min(Int(cash / stock.price), 5) // Buy up to 5 shares
            if sharesToBuy > 0 {
                portfolio[stock.symbol] = (portfolio[stock.symbol] ?? 0) + sharesToBuy
                cash -= Double(sharesToBuy) * stock.price
                print("  > \(name) BUYS \(sharesToBuy) shares of \(stock.symbol) at $\(String(format: "%.2f", stock.price))")
            }
        } else if stock.percentChange >= 2.0 && sharesOwned > 0 {
            // Sell opportunity - price increased significantly
            let sharesToSell = min(sharesOwned, Int.random(in: 1...3)) // Sell 1-3 shares if available
            if sharesToSell > 0 {
                portfolio[stock.symbol] = sharesOwned - sharesToSell
                cash += Double(sharesToSell) * stock.price
                print("  > \(name) SELLS \(sharesToSell) shares of \(stock.symbol) at $\(String(format: "%.2f", stock.price))")
            }
        }
    }
    
    /// Print a summary of the investor's portfolio
    /// - Parameter stocks: Current stock data
    private func printPortfolioSummary(using stocks: [String: Stock]) {
        var totalValue = cash
        
        for (symbol, quantity) in portfolio {
            guard let stock = stocks[symbol] else { continue }
            totalValue += Double(quantity) * stock.price
        }
        
        print("  Portfolio Summary for \(name):")
        print("  - Cash: $\(String(format: "%.2f", cash))")
        print("  - Total Portfolio Value: $\(String(format: "%.2f", totalValue))")
    }
}

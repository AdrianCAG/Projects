// StockAnalyst.swift
// Observer implementation using NotificationCenter

import Foundation

/// Represents a recommendation for a stock
enum Recommendation: String {
    case strongBuy = "Strong Buy"
    case buy = "Buy"
    case hold = "Hold"
    case sell = "Sell"
    case strongSell = "Strong Sell"
}

/// A stock analyst who provides market analysis and recommendations
class StockAnalyst {
    /// Unique identifier for the observer
    let id = UUID()
    
    /// The name of the analyst
    let name: String
    
    /// The firm the analyst works for
    let firm: String
    
    /// Historical recommendations for stocks
    private var recommendations: [String: Recommendation] = [:]
    
    /// Initialize a new analyst
    /// - Parameters:
    ///   - name: The analyst's name
    ///   - firm: The analyst's firm
    init(name: String, firm: String) {
        self.name = name
        self.firm = firm
        
        // Register for stock market notifications
        registerForNotifications()
    }
    
    deinit {
        // Clean up by removing notification observers
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Register for relevant notifications
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStockPriceChanged),
            name: .stockPriceChanged,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMarketSimulated),
            name: .marketSimulated,
            object: nil
        )
    }
    
    /// Handle stock price change notifications
    @objc private func handleStockPriceChanged(_ notification: Notification) {
        processMarketUpdate(notification)
    }
    
    /// Handle market simulation notifications
    @objc private func handleMarketSimulated(_ notification: Notification) {
        processMarketUpdate(notification)
    }
    
    /// Process market update from notification
    private func processMarketUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let stocks = userInfo["stocks"] as? [String: Stock] else {
            return
        }
        
        print("\n\(name) from \(firm) Market Analysis:")
        analyzeMarket(stocks: stocks)
    }
    
    /// Analyze the market and provide recommendations
    /// - Parameter stocks: Current stock data
    private func analyzeMarket(stocks: [String: Stock]) {
        // Calculate overall market trend
        let marketPerformers = categorizeStocks(stocks)
        
        // Print market summary
        printMarketSummary(marketPerformers)
        
        // Generate and print recommendations for selected stocks
        generateRecommendations(stocks)
    }
    
    /// Categorize stocks based on their performance
    /// - Parameter stocks: Current stock data
    /// - Returns: Dictionary with categories and the stocks in each category
    private func categorizeStocks(_ stocks: [String: Stock]) -> [String: [Stock]] {
        var result: [String: [Stock]] = [
            "Strong Performers": [],
            "Moderate Performers": [],
            "Underperformers": []
        ]
        
        for (_, stock) in stocks {
            if stock.percentChange >= 2.0 {
                result["Strong Performers"]?.append(stock)
            } else if stock.percentChange <= -2.0 {
                result["Underperformers"]?.append(stock)
            } else {
                result["Moderate Performers"]?.append(stock)
            }
        }
        
        return result
    }
    
    /// Print a summary of the market
    /// - Parameter marketPerformers: Categorized stocks
    private func printMarketSummary(_ marketPerformers: [String: [Stock]]) {
        print("  Market Summary:")
        
        for (category, stocks) in marketPerformers {
            if !stocks.isEmpty {
                let symbols = stocks.map { $0.symbol }.joined(separator: ", ")
                print("  - \(category): \(symbols)")
            }
        }
    }
    
    /// Generate recommendations for stocks
    /// - Parameter stocks: Current stock data
    private func generateRecommendations(_ stocks: [String: Stock]) {
        print("\n  Stock Recommendations:")
        
        // Select a few stocks to provide recommendations for
        let selectedStocks = selectStocksForRecommendation(stocks)
        
        for stock in selectedStocks {
            let recommendation = analyzeStock(stock)
            recommendations[stock.symbol] = recommendation
            
            print("  - \(stock.symbol) (\(String(format: "%.2f", stock.price))): \(recommendation.rawValue)")
            printAnalysisRationale(stock, recommendation: recommendation)
        }
    }
    
    /// Select a subset of stocks to provide recommendations for
    /// - Parameter stocks: All available stocks
    /// - Returns: Array of selected stocks
    private func selectStocksForRecommendation(_ stocks: [String: Stock]) -> [Stock] {
        // For this example, we'll just select all stocks
        // In a real application, an analyst might focus on specific sectors
        return Array(stocks.values)
    }
    
    /// Analyze an individual stock and provide a recommendation
    /// - Parameter stock: The stock to analyze
    /// - Returns: A recommendation
    private func analyzeStock(_ stock: Stock) -> Recommendation {
        // This is a simplified algorithm based solely on recent price movement
        // A real analyst would consider many more factors
        
        if stock.percentChange >= 4.0 {
            return .sell        // Sell on significant increase (take profit)
        } else if stock.percentChange >= 2.0 {
            return .hold        // Hold if moderately up
        } else if stock.percentChange >= 0 {
            return .buy         // Buy on slight increase (upward momentum)
        } else if stock.percentChange >= -2.0 {
            return .buy         // Buy on slight dip (good entry)
        } else if stock.percentChange >= -4.0 {
            return .strongBuy   // Strong buy on moderate dip
        } else {
            return .hold        // Hold on significant drop (wait for stabilization)
        }
    }
    
    /// Print the rationale for an analysis
    /// - Parameters:
    ///   - stock: The stock being analyzed
    ///   - recommendation: The recommendation
    private func printAnalysisRationale(_ stock: Stock, recommendation: Recommendation) {
        var rationale = ""
        
        switch recommendation {
        case .strongBuy:
            rationale = "Stock is significantly undervalued after recent drop"
        case .buy:
            rationale = "Good entry point with positive risk/reward ratio"
        case .hold:
            rationale = "Current price fairly reflects value, maintain position"
        case .sell:
            rationale = "Consider taking profits at current elevated levels"
        case .strongSell:
            rationale = "Overvalued with potential downside risk"
        }
        
        print("    Rationale: \(rationale)")
    }
}

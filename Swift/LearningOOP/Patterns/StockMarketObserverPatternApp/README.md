# Stock Market Observer Pattern App

A Swift console application that demonstrates the Observer design pattern through a real-time stock market monitoring system.

## Overview

This application simulates a stock market where multiple investors and analysts (observers) can monitor stock prices in real-time. When stock prices change, all registered observers are automatically notified and can react accordingly. This demonstrates the core concept of the Observer pattern: a one-to-many dependency between objects where multiple observers are notified when the subject's state changes.

## Design Pattern: Observer

The Observer pattern is a behavioral design pattern that defines a one-to-many dependency between objects. When one object (the subject) changes state, all its dependents (observers) are notified and updated automatically.

### Key Components in This Implementation

1. **Subject Interface**: Defines methods for attaching, detaching, and notifying observers
   - `register(observer:)`: Adds an observer to the notification list
   - `unregister(observer:)`: Removes an observer from the notification list
   - `notifyObservers()`: Triggers notifications to all registered observers

2. **Concrete Subject**: Implements the Subject interface and maintains state that observers are interested in
   - `StockMarket`: Maintains a collection of stocks and notifies observers when prices change

3. **Observer Interface**: Defines the update method that concrete observers must implement
   - `update(data:)`: Called when the subject's state changes

4. **Concrete Observers**: Implement the Observer interface to receive and process updates
   - `StockInvestor`: Represents an investor who makes buying/selling decisions based on price changes
   - `StockAnalyst`: Represents an analyst who provides market analysis and recommendations

## Project Structure

```
StockMarketObserverPatternApp/
├── Sources/
│   ├── Observer.swift             # Observer interface
│   ├── Subject.swift              # Subject interface
│   ├── StockMarket.swift          # Concrete subject implementation
│   ├── StockInvestor.swift        # Concrete observer implementation
│   ├── StockAnalyst.swift         # Another concrete observer implementation
│   ├── CommandLineInterface.swift # User interface
│   └── main.swift                 # Application entry point
└── Package.swift                  # Swift package definition
```

## Features

- Monitor real-time stock price changes
- Register and unregister different types of observers
- Simulate market changes that trigger notifications
- Add new stocks to the market
- Update prices of existing stocks
- View different observer reactions to the same market changes
- Make automated investment decisions based on price movements
- Generate stock market analysis and recommendations

## How the Observer Pattern is Applied

In this application:

1. The `Subject` protocol defines the interface for objects that can be observed, with methods to register, unregister, and notify observers.

2. The `StockMarket` class implements the Subject interface and maintains the state (stock prices) that observers are interested in.

3. The `Observer` protocol defines the update method that all observers must implement to receive notifications.

4. Concrete observers (`StockInvestor` and `StockAnalyst`) implement the Observer interface and define how they respond to stock market changes.

When a stock price changes:
- The `StockMarket` calls `notifyObservers()`, which iterates through all registered observers
- Each observer's `update(data:)` method is called with the current stock data
- Observers process this data according to their specific logic
- Investors might buy or sell stocks based on price movements
- Analysts might update their recommendations based on market trends

## Benefits of the Observer Pattern

1. **Loose Coupling**: Subjects and observers are loosely coupled, allowing them to vary independently
2. **Support for Broadcast Communication**: One update in the subject can trigger multiple responses from different observers
3. **Open/Closed Principle**: New observer types can be added without modifying the subject
4. **Established Relationship**: Clear one-to-many relationship between subject and observers
5. **Real-time Updates**: Changes are propagated immediately to all interested parties

## Running the Application

To run the application:

```bash
cd /path/to/StockMarketObserverPatternApp
swift build
swift run
```

## Usage Example

The application allows you to:

1. View current stock prices
2. Register new observers (investors or analysts)
3. Unregister existing observers
4. Update individual stock prices
5. Add new stocks to the market
6. Simulate random market changes
7. See how different observers react to the same market events

## Implementation Details

- The application uses Swift's protocol-oriented approach to implement the Observer pattern
- Each observer has a unique identifier to ensure proper registration/unregistration
- The StockMarket is implemented as a singleton to ensure a single source of truth
- Observers maintain their own state and logic for responding to updates
- The command-line interface provides a user-friendly way to demonstrate the pattern

## Comparison to Other Patterns

| Aspect | Observer | Publisher/Subscriber | Model-View-Controller |
|--------|----------|----------------------|----------------------|
| Coupling | Observers know about the subject | Publishers and subscribers don't know about each other | Controller mediates between Model and View |
| Communication | Direct method calls | Often through an intermediary | Controller updates View when Model changes |
| Notification Specificity | All observers notified of all changes | Can filter notifications by topic/channel | Views updated with specific Model changes |
| Implementation Complexity | Relatively simple | More complex with intermediary | More structured but complex |
| Use Case | Direct object relationships | Loosely coupled systems | User interfaces |

The Observer pattern is particularly well-suited for this stock market application because:
- There's a clear one-to-many relationship between the market and its observers
- Different types of observers need different reactions to the same events
- Observers need to be dynamically added and removed at runtime
- Real-time updates are essential for accurate market representation

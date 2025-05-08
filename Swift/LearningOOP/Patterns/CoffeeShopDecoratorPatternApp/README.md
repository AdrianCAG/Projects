# Coffee Shop Decorator Pattern App

A Swift console application that demonstrates the Decorator design pattern in the context of a coffee shop.

## Overview

This application simulates a coffee shop ordering system where customers can order various beverages and add customizations (decorators) to them. The Decorator pattern allows for dynamic addition of responsibilities to objects without modifying their structure.

## Design Pattern: Decorator

The Decorator pattern is a structural design pattern that allows behavior to be added to individual objects, either statically or dynamically, without affecting the behavior of other objects from the same class.

### Key Components in This Implementation

1. **Component (Beverage)**: The abstract base class that defines the interface for objects that can have responsibilities added to them.
2. **Concrete Components**: Specific beverage types (Espresso, Americano, Latte, etc.) that implement the Beverage interface.
3. **Decorator (BeverageDecorator)**: Abstract class that maintains a reference to a Component object and conforms to its interface.
4. **Concrete Decorators**: Specific add-ons (Milk, Whipped Cream, Caramel, etc.) that extend the functionality of beverages.

## Project Structure

```
CoffeeShopDecoratorPatternApp/
├── Sources/
│   ├── Beverage.swift             # Component interface
│   ├── ConcreteBeverages.swift    # Concrete Component implementations
│   ├── BeverageDecorator.swift    # Decorator abstract class
│   ├── CoffeeShop.swift           # Main business logic
│   ├── CommandLineInterface.swift # User interface
│   └── main.swift                 # Application entry point
└── Package.swift                  # Swift package definition
```

## Features

- Order various coffee types (Espresso, Americano, Latte, Cappuccino, Mocha)
- Customize beverages with add-ons (Milk, Whipped Cream, Chocolate, Caramel, Vanilla)
- View detailed cost breakdown of orders
- Manage a shopping cart with multiple beverages
- Checkout and view receipt

## How the Decorator Pattern is Applied

In this application:

1. `Beverage` is the component interface with properties like `name`, `description`, and methods like `cost()`.
2. Concrete beverages (Espresso, Latte, etc.) implement the base functionality.
3. `BeverageDecorator` is the abstract decorator that wraps a beverage.
4. Concrete decorators (Milk, WhippedCream, etc.) add functionality by:
   - Extending the description (e.g., "Espresso + Milk")
   - Adding to the cost (e.g., base cost + milk cost)

This allows for flexible combinations of beverages and add-ons without creating an explosion of subclasses.

## Benefits of the Decorator Pattern

1. **Open/Closed Principle**: The code is open for extension but closed for modification.
2. **Single Responsibility Principle**: Each class has a single responsibility.
3. **Flexibility**: New beverage types or add-ons can be added without changing existing code.
4. **Composability**: Decorators can be combined in various ways to create complex objects.

## Running the Application

To run the application:

```bash
cd /path/to/CoffeeShopDecoratorPatternApp
swift build
swift run
```

## Usage Example

The application allows you to:

1. Select a base beverage (e.g., Espresso)
2. Add customizations (e.g., Milk, Whipped Cream)
3. Add the customized beverage to your cart
4. Continue shopping or checkout
5. View the final receipt with cost breakdown

## Implementation Details

- The application uses Swift's object-oriented features to implement the Decorator pattern.
- The console interface provides a user-friendly way to interact with the application.
- Prices and descriptions are dynamically calculated based on the selected options.

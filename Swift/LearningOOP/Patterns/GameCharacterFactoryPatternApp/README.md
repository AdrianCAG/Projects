# Game Character Factory Pattern App

This Swift command-line application demonstrates the Factory Method design pattern with a medium-high complexity implementation focused on game character creation.

## What is the Factory Method Pattern?

The Factory Method Pattern is a creational design pattern that provides an interface for creating objects in a superclass, but allows subclasses to alter the type of objects that will be created. It defines an interface for creating an object, but lets subclasses decide which class to instantiate.

## Application Overview

This application simulates a game character creation system where different types of characters (Warriors, Mages, Archers) can be created with various equipment, abilities, and attributes. The Factory Method Pattern is used to create these characters with their specific traits and capabilities.

## Key Components

1. `Character` - Abstract product class
2. `CharacterFactory` - Creator interface with factory method
3. Concrete Creators - Specific factories for different character types
4. Concrete Products - Specific character implementations
5. Equipment and Ability systems - Additional components for character customization

## How to Run

```bash
cd GameCharacterFactoryPatternApp
swift run
```

## Learning Objectives

This application demonstrates:
- Factory Method Pattern implementation
- Object-oriented programming principles
- Inheritance and polymorphism
- Encapsulation and abstraction
- Composition for complex object creation

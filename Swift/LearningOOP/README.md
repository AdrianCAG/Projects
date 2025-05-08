# Swift OOP Learning Examples

This repository contains a collection of Swift applications designed to help you learn Object-Oriented Programming (OOP) concepts and design patterns at different complexity levels.

## Folder Structure

The repository is organized into the following directories:

### 1. EasyToMedium
Beginner-friendly applications that introduce fundamental OOP concepts:

- **PetCareApp**: A simple pet management system demonstrating basic inheritance, polymorphism, and encapsulation
- **TaskManagerApp**: A task management application showing how to use classes, inheritance, and polymorphism
- **LibraryApp**: A library management system similar in complexity to TaskManagerApp but in a different context

### 2. MediumToAdvanced
More complex applications that build on basic concepts and introduce intermediate to advanced patterns:

- **WeatherDashboard**: A console-based weather application that demonstrates the Observer and Repository patterns. It integrates with the OpenWeatherMap API to provide current weather data and forecasts for any city, manages user preferences, and tracks search history. Built with Alamofire for networking, SwiftyJSON for parsing, and Rainbow for colorful console output.

- **WeatherbitApp**: A console-based weather application similar to WeatherDashboard but integrating with the Weatherbit.io API. It demonstrates the Repository Pattern with WeatherRepositoryProtocol and WeatherbitRepository, and the Observer Pattern with WeatherService as the subject and WeatherObserver protocol for observers. Features include current weather data, 5-day forecasts, city search functionality, user preferences management, and recent searches tracking. Built with Alamofire for network requests, SwiftyJSON for parsing, and Rainbow for colorful console output.

### 3. AdvancedToProfessional
Advanced applications demonstrating professional-level Swift programming:

- **CloudSyncPlatform**: A sophisticated cloud synchronization and storage system that demonstrates multiple design patterns (MVVM, Repository, Factory Method, Strategy, Observer, Dependency Injection, Decorator, Adapter, Singleton, Command) and advanced Swift concepts. Features include secure file storage with encryption, conflict resolution, delta synchronization, and reactive programming with RxSwift.

### 4. Patterns
Applications specifically focused on demonstrating design patterns:

- **SingletonWeatherApp**: A weather tracking system that demonstrates the Singleton pattern for centralized data management
- **SmartHomeFacadePatternApp**: A smart home automation system demonstrating the Facade pattern to provide a simplified interface to complex subsystems
- **GameCharacterFactoryPatternApp**: A game character creation system demonstrating the Factory Method pattern
- **MediaLibraryAdapterPatternApp**: A media library system demonstrating the Adapter pattern to unify different media sources
- **CoffeeShopDecoratorPatternApp**: Demonstrates the Decorator pattern for adding features to objects dynamically
- **FileSystemCompositePatternApp**: Demonstrates the Composite pattern for tree-like object structures
- **SecureAPIProxyPatternApp**: Demonstrates the Proxy pattern for controlled access to resources
- **MVCPatternApp**: Demonstrates the Model-View-Controller architectural pattern

### 5. Build Tools
Tools for managing the Swift projects:

- **shared-build**: A shared build directory for all Swift Package Manager projects to reduce disk space usage and improve build times by reusing dependencies across projects.

- **build-project.sh**: A utility script that builds and runs Swift projects using the shared build directory. It handles the configuration of build paths, manages dependencies, and provides a consistent interface for building and running any project in the repository. Usage:
  ```bash
  ./build-project.sh <project-directory> [build|run|clean]
  ```
  - `build`: Compiles the project without running it
  - `run`: Builds and runs the project
  - `clean`: Cleans just the specified project's build artifacts

- **cleanup-build-dirs.sh**: A comprehensive cleanup script that removes all build artifacts to free up disk space and reset the build environment. It cleans both:
  - The central shared-build directory containing cached dependencies and build artifacts
  - All individual project .build directories
  
  This is useful when you want to perform a completely fresh build or when troubleshooting build issues. Usage:
  ```bash
  ./cleanup-build-dirs.sh
  ```

## Running the Applications

Each application can be run using the shared build script:

```bash
./build-project.sh <project-directory> run
```

Example:
```bash
./build-project.sh Patterns/GameCharacterFactoryPatternApp run
```

## Learning Path

For beginners, we recommend this learning path:

1. Start with **EasyToMedium/PetCareApp** - It has the simplest structure and clearly demonstrates basic OOP concepts
2. Move on to **EasyToMedium/TaskManagerApp** or **EasyToMedium/LibraryApp** - These add more complexity while reinforcing the same concepts
3. Study the design patterns in the **Patterns** directory - These demonstrate standard solutions to common software design problems

Each pattern application demonstrates a specific design pattern in a practical context, helping you understand when and how to apply these patterns in your own projects.

- **Classes and Objects**
- **Inheritance**
- **Polymorphism**
- **Encapsulation**
- **Abstraction**
- **Composition**
- **Design Patterns** (Singleton)

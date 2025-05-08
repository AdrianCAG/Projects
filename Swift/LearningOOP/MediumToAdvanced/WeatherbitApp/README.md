# WeatherbitApp

A medium to advanced complexity Swift console application that demonstrates the Repository and Observer design patterns while integrating with the Weatherbit.io API.

## Features

- View current weather for any city
- See 5-day forecasts
- Search for cities
- Manage preferences like default city
- Track recent searches

## Design Patterns

### Repository Pattern
The application implements the Repository pattern through:
- `WeatherRepositoryProtocol`: Defines the contract for weather data access
- `WeatherbitRepository`: Concrete implementation that fetches data from the Weatherbit.io API

### Observer Pattern
The application implements the Observer pattern through:
- `WeatherObserver` protocol: Defines methods for observers to receive updates
- `WeatherService`: Acts as the subject, notifying observers of weather updates
- `ConsoleUI`: Implements the observer interface to update the UI when weather data changes

## Project Structure

```
WeatherbitApp/
├── Sources/
│   └── WeatherbitApp/
│       ├── Models/
│       │   └── Weather.swift
│       ├── Repositories/
│       │   └── WeatherRepository.swift
│       ├── Services/
│       │   └── WeatherService.swift
│       ├── UI/
│       │   └── ConsoleUI.swift
│       ├── Utils/
│       │   └── ConfigManager.swift
│       └── main.swift
└── Package.swift
```

## Dependencies

- [Alamofire](https://github.com/Alamofire/Alamofire): For network requests
- [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON): For JSON parsing
- [Rainbow](https://github.com/onevcat/Rainbow): For colorful console output

## Setup

1. Clone the repository
2. Add your Weatherbit API key in `ConfigManager.swift`
3. Run the following commands:

```bash
cd WeatherbitApp
swift build
swift run
```

## API Key

You'll need to sign up for a free API key at [Weatherbit.io](https://www.weatherbit.io/account/create) and replace the placeholder in `ConfigManager.swift` with your actual API key.

## Usage

Follow the on-screen prompts to navigate through the application. You can:
- View current weather for any city
- Check 5-day forecasts
- Search for cities
- Set your default city
- View your recent searches

## Note

This application uses synchronous network calls (without async/await) as requested, utilizing Alamofire's completion handler-based API.

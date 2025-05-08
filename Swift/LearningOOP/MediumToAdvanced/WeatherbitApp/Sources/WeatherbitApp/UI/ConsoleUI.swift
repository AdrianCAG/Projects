import Foundation
import Rainbow

class ConsoleUI: WeatherObserver {
    private let weatherService: WeatherService
    private var isRunning = false
    
    init(weatherService: WeatherService) {
        self.weatherService = weatherService
        weatherService.addObserver(self)
    }
    
    func start() {
        isRunning = true
        displayWelcomeMessage()
        showMainMenu()
    }
    
    // MARK: - WeatherObserver Protocol
    
    func weatherDidUpdate(weather: Weather) {
        displayWeather(weather)
        showMainMenu()
    }
    
    func forecastDidUpdate(forecasts: [Forecast]) {
        displayForecast(forecasts)
        showMainMenu()
    }
    
    func didFailWithError(error: Error) {
        print("Error: \(error.localizedDescription)".red)
        showMainMenu()
    }
    
    // MARK: - UI Display Methods
    
    private func displayWelcomeMessage() {
        print("\n" + "🌤️  WEATHERBIT DASHBOARD 🌤️".blue.bold)
        print("Your comprehensive weather information center\n".blue)
    }
    
    private func showMainMenu() {
        guard isRunning else { return }
        
        // Check if API key is set
        if !ConfigManager.shared.isApiKeySet {
            print("\n" + "⚠️  API KEY REQUIRED".red.bold)
            print("You need to set your Weatherbit API key before using the app.".yellow)
            setApiKey()
            return
        }
        
        print("\n" + "MAIN MENU".green.bold)
        print("1. View current weather for a city")
        print("2. View 5-day forecast for a city")
        print("3. Search for a city")
        print("4. View recent searches")
        print("5. Set default city (current: \(weatherService.defaultCity))")
        print("6. Set API key")
        print("7. Exit")
        print("\nEnter your choice (1-7): ".green, terminator: "")
        
        guard let input = readLine(), let choice = Int(input) else {
            print("Invalid input. Please try again.".red)
            showMainMenu()
            return
        }
        
        handleMenuChoice(choice)
    }
    
    private func handleMenuChoice(_ choice: Int) {
        switch choice {
        case 1:
            promptForCity { [weak self] city in
                self?.weatherService.fetchCurrentWeather(for: city)
            }
        case 2:
            promptForCity { [weak self] city in
                self?.weatherService.fetchForecast(for: city)
            }
        case 3:
            searchCity()
        case 4:
            displayRecentSearches()
        case 5:
            setDefaultCity()
        case 6:
            setApiKey()
        case 7:
            exit()
        default:
            print("Invalid choice. Please try again.".red)
            showMainMenu()
        }
    }
    
    private func setApiKey() {
        print("\n" + "SET WEATHERBIT API KEY".blue.bold)
        print("You can get a free API key by signing up at https://www.weatherbit.io/account/create".yellow)
        
        let currentKey = ConfigManager.shared.apiKey
        if !currentKey.isEmpty {
            print("Current API key: \(currentKey.prefix(4))****\(currentKey.suffix(4))".cyan)
        }
        
        print("\nEnter your Weatherbit API key (or press Enter to keep current key): ".green, terminator: "")
        
        if let input = readLine(), !input.isEmpty {
            ConfigManager.shared.apiKey = input
            print("API key saved successfully!".green)
        } else if currentKey.isEmpty {
            print("API key cannot be empty. Please enter a valid API key.".red)
            setApiKey()
            return
        }
        
        showMainMenu()
    }
    
    private func promptForCity(completion: @escaping (String) -> Void) {
        print("\nEnter city name (or press Enter for default city \(weatherService.defaultCity)): ".green, terminator: "")
        
        let input = readLine() ?? ""
        let city = input.isEmpty ? weatherService.defaultCity : input
        
        print("Fetching weather data for \(city)...".yellow)
        completion(city)
    }
    
    private func searchCity() {
        print("\nEnter search term: ".green, terminator: "")
        guard let query = readLine(), !query.isEmpty else {
            print("Search term cannot be empty.".red)
            showMainMenu()
            return
        }
        
        print("Searching for cities matching '\(query)'...".yellow)
        
        weatherService.searchCity(query: query) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let cities):
                if cities.isEmpty {
                    print("No cities found matching '\(query)'.".red)
                } else {
                    print("\nCities matching '\(query)':".green)
                    for (index, city) in cities.enumerated() {
                        print("\(index + 1). \(city)")
                    }
                    
                    print("\nSelect a city (1-\(cities.count)) or press Enter to go back: ".green, terminator: "")
                    if let input = readLine(), let choice = Int(input), choice >= 1, choice <= cities.count {
                        let selectedCity = cities[choice - 1]
                        print("Selected: \(selectedCity)".yellow)
                        print("1. View current weather")
                        print("2. View forecast")
                        print("Enter choice (1-2): ".green, terminator: "")
                        
                        if let actionInput = readLine(), let action = Int(actionInput) {
                            if action == 1 {
                                self.weatherService.fetchCurrentWeather(for: selectedCity)
                            } else if action == 2 {
                                self.weatherService.fetchForecast(for: selectedCity)
                            } else {
                                self.showMainMenu()
                            }
                        } else {
                            self.showMainMenu()
                        }
                    } else {
                        self.showMainMenu()
                    }
                }
            case .failure(let error):
                print("Error searching for cities: \(error.localizedDescription)".red)
                self.showMainMenu()
            }
        }
    }
    
    private func displayRecentSearches() {
        let recentSearches = weatherService.getRecentSearches()
        
        if recentSearches.isEmpty {
            print("\nNo recent searches.".yellow)
            showMainMenu()
            return
        }
        
        print("\nRecent searches:".green)
        for (index, city) in recentSearches.enumerated() {
            print("\(index + 1). \(city)")
        }
        
        print("\nSelect a city to view current weather (1-\(recentSearches.count)) or press Enter to go back: ".green, terminator: "")
        if let input = readLine(), let choice = Int(input), choice >= 1, choice <= recentSearches.count {
            let selectedCity = recentSearches[choice - 1]
            print("Selected: \(selectedCity)".yellow)
            print("1. View current weather")
            print("2. View forecast")
            print("Enter choice (1-2): ".green, terminator: "")
            
            if let actionInput = readLine(), let action = Int(actionInput) {
                if action == 1 {
                    weatherService.fetchCurrentWeather(for: selectedCity)
                } else if action == 2 {
                    weatherService.fetchForecast(for: selectedCity)
                } else {
                    showMainMenu()
                }
            } else {
                showMainMenu()
            }
        } else {
            showMainMenu()
        }
    }
    
    private func setDefaultCity() {
        print("\nEnter new default city: ".green, terminator: "")
        guard let city = readLine(), !city.isEmpty else {
            print("City name cannot be empty.".red)
            showMainMenu()
            return
        }
        
        weatherService.setDefaultCity(city)
        print("Default city set to \(city).".green)
        showMainMenu()
    }
    
    private func displayWeather(_ weather: Weather) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        print("\n" + "CURRENT WEATHER FOR \(weather.cityName.uppercased())".blue.bold)
        print("Updated: \(dateFormatter.string(from: weather.timestamp))".lightBlue)
        print("Temperature: \(String(format: "%.1f°C", weather.temperature))".yellow)
        print("Feels Like: \(String(format: "%.1f°C", weather.feelsLike))".yellow)
        print("Condition: \(weather.description)".cyan)
        print("Humidity: \(weather.humidity)%".cyan)
        print("Wind: \(String(format: "%.1f m/s", weather.windSpeed)) from \(weather.windDirection)".cyan)
        print("Pressure: \(String(format: "%.1f hPa", weather.pressure))".cyan)
        print("UV Index: \(String(format: "%.1f", weather.uvIndex))".cyan)
        print("Cloud Coverage: \(weather.cloudCoverage)%".cyan)
    }
    
    private func displayForecast(_ forecasts: [Forecast]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, MMM d"
        
        print("\n" + "5-DAY FORECAST".blue.bold)
        
        for forecast in forecasts {
            let dateString = dateFormatter.string(from: forecast.date)
            print("\n\(dateString):".green.bold)
            print("  High: \(String(format: "%.1f°C", forecast.maxTemp))".yellow)
            print("  Low: \(String(format: "%.1f°C", forecast.minTemp))".lightBlue)
            print("  Condition: \(forecast.description)".cyan)
            print("  Precipitation: \(String(format: "%.1f mm", forecast.precipitation))".cyan)
            print("  Humidity: \(forecast.humidity)%".cyan)
            print("  Wind: \(String(format: "%.1f m/s", forecast.windSpeed))".cyan)
        }
    }
    
    private func exit() {
        print("\nThank you for using Weatherbit Dashboard!".blue.bold)
        print("Goodbye! 👋\n".blue)
        isRunning = false
    }
}

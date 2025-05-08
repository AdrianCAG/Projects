import Foundation

// Initialize the application
print("Initializing Weatherbit Dashboard...")

// Create repository that will use the API key from ConfigManager
let repository = WeatherbitRepository(apiKey: ConfigManager.shared.apiKey)

// Create weather service with repository
let defaultCity = ConfigManager.shared.defaultCity
let weatherService = WeatherService(repository: repository, defaultCity: defaultCity)

// Create and start the UI
let consoleUI = ConsoleUI(weatherService: weatherService)
consoleUI.start()

// Keep the application running
RunLoop.main.run()

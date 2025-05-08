// WeatherDataManager.swift - Implements the Singleton Pattern for weather data management

import Foundation

// Weather data structure
struct WeatherData {
    let temperature: Double
    let humidity: Double
    let windSpeed: Double
    let condition: WeatherCondition
    let location: String
    let timestamp: Date
    
    // Computed property for temperature in Fahrenheit
    var temperatureF: Double {
        return (temperature * 9/5) + 32
    }
}

// Weather condition enum
enum WeatherCondition: String {
    case sunny = "Sunny"
    case cloudy = "Cloudy"
    case rainy = "Rainy"
    case snowy = "Snowy"
    case stormy = "Stormy"
}

// Singleton class for managing weather data
class WeatherDataManager {
    // MARK: - Singleton Pattern Implementation
    
    // The shared instance - this is the core of the Singleton Pattern
    static let shared = WeatherDataManager()
    
    // Private initializer prevents external instantiation - crucial for Singleton Pattern
    private init() {
        print("WeatherDataManager singleton initialized")
        loadSavedLocations()
    }
    
    // MARK: - Properties
    
    // In-memory cache of weather data
    private var weatherCache: [String: WeatherData] = [:]
    
    // Last update timestamps for each location
    private var lastUpdates: [String: Date] = [:]
    
    // Saved favorite locations
    private(set) var savedLocations: [String] = []
    
    // Update frequency in seconds
    var updateFrequency: TimeInterval = 3600 // Default: 1 hour
    
    // MARK: - Weather Data Methods
    
    // Get weather data for a location
    func getWeatherData(for location: String) -> WeatherData? {
        // Check if we need to update the data
        if shouldUpdateData(for: location) {
            updateWeatherData(for: location)
        }
        return weatherCache[location]
    }
    
    // Update weather data for a location
    func updateWeatherData(for location: String) {
        // In a real app, this would call an API
        // For this demo, we'll generate random weather data
        let newData = generateRandomWeatherData(for: location)
        weatherCache[location] = newData
        lastUpdates[location] = Date()
        
        // Notify observers that data has changed
        NotificationCenter.default.post(
            name: .weatherDataUpdated,
            object: self,
            userInfo: ["location": location]
        )
    }
    
    // Check if we should update data for a location
    private func shouldUpdateData(for location: String) -> Bool {
        guard let lastUpdate = lastUpdates[location] else {
            return true // No previous update, so we should update
        }
        
        let timeSinceLastUpdate = Date().timeIntervalSince(lastUpdate)
        return timeSinceLastUpdate > updateFrequency
    }
    
    // Generate random weather data (simulates API call)
    private func generateRandomWeatherData(for location: String) -> WeatherData {
        let temperature = Double.random(in: -10...35)
        let humidity = Double.random(in: 0...100)
        let windSpeed = Double.random(in: 0...50)
        
        let conditions: [WeatherCondition] = [.sunny, .cloudy, .rainy, .snowy, .stormy]
        let condition = conditions.randomElement() ?? .sunny
        
        return WeatherData(
            temperature: temperature,
            humidity: humidity,
            windSpeed: windSpeed,
            condition: condition,
            location: location,
            timestamp: Date()
        )
    }
    
    // MARK: - Location Management
    
    // Add a location to saved locations
    func addLocation(_ location: String) {
        guard !savedLocations.contains(location) else { return }
        
        savedLocations.append(location)
        saveLocations()
        
        // Get initial weather data
        updateWeatherData(for: location)
    }
    
    // Remove a location from saved locations
    func removeLocation(_ location: String) {
        guard let index = savedLocations.firstIndex(of: location) else { return }
        
        savedLocations.remove(at: index)
        weatherCache.removeValue(forKey: location)
        lastUpdates.removeValue(forKey: location)
        saveLocations()
    }
    
    // Save locations to persistent storage
    private func saveLocations() {
        // In a real app, this would save to UserDefaults or a database
        // For this demo, we'll just print the saved locations
        print("Saved locations: \(savedLocations)")
    }
    
    // Load saved locations from persistent storage
    private func loadSavedLocations() {
        // In a real app, this would load from UserDefaults or a database
        // For this demo, we'll just add some default locations
        savedLocations = ["New York", "London", "Tokyo", "Sydney"]
    }
    
    // MARK: - Batch Operations
    
    // Update all saved locations
    func updateAllLocations() {
        for location in savedLocations {
            updateWeatherData(for: location)
        }
    }
    
    // Clear all cached data
    func clearCache() {
        weatherCache.removeAll()
        lastUpdates.removeAll()
        print("Weather cache cleared")
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let weatherDataUpdated = Notification.Name("weatherDataUpdated")
}

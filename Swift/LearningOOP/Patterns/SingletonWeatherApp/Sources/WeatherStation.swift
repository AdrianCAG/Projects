// WeatherStation.swift - Represents a weather monitoring station

import Foundation

// Observer protocol for weather updates
protocol WeatherObserver: AnyObject {
    func weatherDidUpdate(data: WeatherData, for location: String)
}

// Weather station class that uses the WeatherDataManager singleton
class WeatherStation {
    // Properties
    private let stationId: String
    private let location: String
    private var observers: [WeatherObserver] = []
    private var timer: Timer?
    
    // Reference to the singleton WeatherDataManager
    private let dataManager = WeatherDataManager.shared
    
    // Initializer
    init(stationId: String, location: String) {
        self.stationId = stationId
        self.location = location
        
        // Register for notifications from the WeatherDataManager
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWeatherUpdate),
            name: .weatherDataUpdated,
            object: nil
        )
        
        // Add this location to the WeatherDataManager
        dataManager.addLocation(location)
    }
    
    deinit {
        // Unregister from notifications
        NotificationCenter.default.removeObserver(self)
        stopMonitoring()
    }
    
    // Start monitoring weather at regular intervals
    func startMonitoring(interval: TimeInterval) {
        stopMonitoring()
        
        // Create a timer to update weather data
        timer = Timer.scheduledTimer(
            timeInterval: interval,
            target: self,
            selector: #selector(updateWeather),
            userInfo: nil,
            repeats: true
        )
        
        // Get initial weather data
        updateWeather()
    }
    
    // Stop monitoring weather
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    // Update weather data
    @objc private func updateWeather() {
        dataManager.updateWeatherData(for: location)
    }
    
    // Handle weather update notifications
    @objc private func handleWeatherUpdate(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let updatedLocation = userInfo["location"] as? String,
              updatedLocation == location,
              let weatherData = dataManager.getWeatherData(for: location) else {
            return
        }
        
        // Notify all observers
        notifyObservers(with: weatherData)
    }
    
    // Get current weather data
    func getCurrentWeather() -> WeatherData? {
        return dataManager.getWeatherData(for: location)
    }
    
    // MARK: - Observer Pattern Methods
    
    // Add an observer
    func addObserver(_ observer: WeatherObserver) {
        observers.append(observer)
    }
    
    // Remove an observer
    func removeObserver(_ observer: WeatherObserver) {
        observers.removeAll { $0 === observer }
    }
    
    // Notify all observers of weather update
    private func notifyObservers(with data: WeatherData) {
        for observer in observers {
            observer.weatherDidUpdate(data: data, for: location)
        }
    }
    
    // MARK: - Utility Methods
    
    // Get station information
    func getStationInfo() -> [String: Any] {
        return [
            "stationId": stationId,
            "location": location,
            "isMonitoring": timer != nil,
            "observerCount": observers.count
        ]
    }
}

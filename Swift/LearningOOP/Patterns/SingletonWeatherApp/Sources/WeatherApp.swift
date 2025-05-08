// WeatherApp.swift - Main interface for the weather application

import Foundation

// Weather display formatter
class WeatherFormatter {
    // Format temperature
    static func formatTemperature(_ temp: Double, inFahrenheit: Bool = false) -> String {
        let value = inFahrenheit ? temp : (temp * 9/5) + 32
        let unit = inFahrenheit ? "°F" : "°C"
        return String(format: "%.1f%@", value, unit)
    }
    
    // Format humidity
    static func formatHumidity(_ humidity: Double) -> String {
        return String(format: "%.1f%%", humidity)
    }
    
    // Format wind speed
    static func formatWindSpeed(_ speed: Double) -> String {
        return String(format: "%.1f km/h", speed)
    }
    
    // Format timestamp
    static func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Main app class that uses the WeatherStation and WeatherDataManager
class WeatherApp: WeatherObserver {
    // Properties
    private var stations: [WeatherStation] = []
    private var useMetric = true
    
    // Reference to the singleton WeatherDataManager
    private let dataManager = WeatherDataManager.shared
    
    // Initializer
    init() {
        print("Weather App initialized")
    }
    
    // Run the application
    func run() {
        print("Welcome to the Singleton Weather App!")
        
        var running = true
        while running {
            displayMenu()
            
            if let choice = readLine(), let option = Int(choice) {
                switch option {
                case 1:
                    viewAllLocations()
                case 2:
                    addNewStation()
                case 3:
                    removeStation()
                case 4:
                    startMonitoring()
                case 5:
                    stopMonitoring()
                case 6:
                    toggleUnits()
                case 7:
                    updateAllWeatherData()
                case 8:
                    running = false
                    print("Thank you for using the Singleton Weather App. Goodbye!")
                default:
                    print("Invalid option. Please try again.")
                }
            } else {
                print("Invalid input. Please enter a number.")
            }
        }
    }
    
    // Display main menu
    private func displayMenu() {
        print("\n===== Singleton Weather App Menu =====")
        print("1. View all locations")
        print("2. Add new weather station")
        print("3. Remove weather station")
        print("4. Start monitoring location")
        print("5. Stop monitoring location")
        print("6. Toggle temperature units (\(useMetric ? "Celsius" : "Fahrenheit"))")
        print("7. Update all weather data")
        print("8. Exit")
        print("Enter your choice (1-8): ", terminator: "")
    }
    
    // View all locations and their weather data
    private func viewAllLocations() {
        let locations = dataManager.savedLocations
        
        if locations.isEmpty {
            print("No locations saved.")
            return
        }
        
        print("\n===== Weather Data =====")
        for location in locations {
            if let weatherData = dataManager.getWeatherData(for: location) {
                displayWeatherData(weatherData)
            } else {
                print("\n--- \(location) ---")
                print("No weather data available.")
            }
        }
    }
    
    // Add a new weather station
    private func addNewStation() {
        print("\n===== Add New Weather Station =====")
        
        print("Enter location name: ", terminator: "")
        guard let location = readLine(), !location.isEmpty else {
            print("Location cannot be empty.")
            return
        }
        
        // Check if location already exists
        if dataManager.savedLocations.contains(location) {
            print("This location is already being monitored.")
            return
        }
        
        print("Enter station ID: ", terminator: "")
        let stationId = readLine() ?? UUID().uuidString
        
        // Create a new weather station
        let station = WeatherStation(stationId: stationId, location: location)
        station.addObserver(self)
        stations.append(station)
        
        print("Weather station added for \(location).")
    }
    
    // Remove a weather station
    private func removeStation() {
        if stations.isEmpty {
            print("No weather stations to remove.")
            return
        }
        
        displayStations()
        
        print("Enter the station number to remove: ", terminator: "")
        if let indexStr = readLine(), let index = Int(indexStr), (1...stations.count).contains(index) {
            let station = stations[index - 1]
            let location = station.getStationInfo()["location"] as! String
            
            // Stop monitoring and remove the station
            station.stopMonitoring()
            stations.remove(at: index - 1)
            dataManager.removeLocation(location)
            
            print("Weather station for \(location) removed.")
        } else {
            print("Invalid station number.")
        }
    }
    
    // Start monitoring a location
    private func startMonitoring() {
        if stations.isEmpty {
            print("No weather stations available.")
            return
        }
        
        displayStations()
        
        print("Enter the station number to start monitoring: ", terminator: "")
        if let indexStr = readLine(), let index = Int(indexStr), (1...stations.count).contains(index) {
            print("Enter update interval in seconds (default 60): ", terminator: "")
            let intervalStr = readLine() ?? "60"
            let interval = Double(intervalStr) ?? 60
            
            stations[index - 1].startMonitoring(interval: interval)
            let location = stations[index - 1].getStationInfo()["location"] as! String
            print("Started monitoring \(location) every \(Int(interval)) seconds.")
        } else {
            print("Invalid station number.")
        }
    }
    
    // Stop monitoring a location
    private func stopMonitoring() {
        if stations.isEmpty {
            print("No weather stations available.")
            return
        }
        
        displayStations()
        
        print("Enter the station number to stop monitoring: ", terminator: "")
        if let indexStr = readLine(), let index = Int(indexStr), (1...stations.count).contains(index) {
            stations[index - 1].stopMonitoring()
            let location = stations[index - 1].getStationInfo()["location"] as! String
            print("Stopped monitoring \(location).")
        } else {
            print("Invalid station number.")
        }
    }
    
    // Toggle between Celsius and Fahrenheit
    private func toggleUnits() {
        useMetric = !useMetric
        print("Temperature units set to \(useMetric ? "Celsius" : "Fahrenheit").")
    }
    
    // Update all weather data
    private func updateAllWeatherData() {
        dataManager.updateAllLocations()
        print("Weather data updated for all locations.")
    }
    
    // Display all weather stations
    private func displayStations() {
        print("\n===== Weather Stations =====")
        for (index, station) in stations.enumerated() {
            let info = station.getStationInfo()
            let location = info["location"] as! String
            let isMonitoring = info["isMonitoring"] as! Bool
            
            print("\(index + 1). \(location) (\(isMonitoring ? "Monitoring" : "Not monitoring"))")
        }
    }
    
    // Display weather data
    private func displayWeatherData(_ data: WeatherData) {
        print("\n--- \(data.location) ---")
        print("Condition: \(data.condition.rawValue)")
        print("Temperature: \(WeatherFormatter.formatTemperature(data.temperature, inFahrenheit: !useMetric))")
        print("Humidity: \(WeatherFormatter.formatHumidity(data.humidity))")
        print("Wind Speed: \(WeatherFormatter.formatWindSpeed(data.windSpeed))")
        print("Last Updated: \(WeatherFormatter.formatTimestamp(data.timestamp))")
    }
    
    // MARK: - WeatherObserver Protocol
    
    func weatherDidUpdate(data: WeatherData, for location: String) {
        print("\nWeather update received for \(location):")
        displayWeatherData(data)
    }
}

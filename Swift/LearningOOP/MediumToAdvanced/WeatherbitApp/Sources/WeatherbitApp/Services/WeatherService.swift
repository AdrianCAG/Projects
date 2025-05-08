import Foundation

// Observer pattern implementation
protocol WeatherObserver: AnyObject {
    func weatherDidUpdate(weather: Weather)
    func forecastDidUpdate(forecasts: [Forecast])
    func didFailWithError(error: Error)
}

class WeatherService {
    private let repository: WeatherRepositoryProtocol
    private var observers: [WeatherObserver] = []
    
    // User preferences
    private(set) var defaultCity: String
    private(set) var recentSearches: [String] = []
    private let maxRecentSearches = 5
    
    init(repository: WeatherRepositoryProtocol, defaultCity: String = "Los Angeles") {
        self.repository = repository
        self.defaultCity = defaultCity
    }
    
    // Observer pattern methods
    func addObserver(_ observer: WeatherObserver) {
        observers.append(observer)
    }
    
    func removeObserver(_ observer: WeatherObserver) {
        observers.removeAll { $0 === observer }
    }
    
    private func notifyObserversOfWeatherUpdate(_ weather: Weather) {
        observers.forEach { $0.weatherDidUpdate(weather: weather) }
    }
    
    private func notifyObserversOfForecastUpdate(_ forecasts: [Forecast]) {
        observers.forEach { $0.forecastDidUpdate(forecasts: forecasts) }
    }
    
    private func notifyObserversOfError(_ error: Error) {
        observers.forEach { $0.didFailWithError(error: error) }
    }
    
    // Weather data methods
    func fetchCurrentWeather(for city: String) {
        repository.getCurrentWeather(for: city) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let weather):
                self.addToRecentSearches(city)
                self.notifyObserversOfWeatherUpdate(weather)
            case .failure(let error):
                self.notifyObserversOfError(error)
            }
        }
    }
    
    func fetchForecast(for city: String, days: Int = 5) {
        repository.getForecast(for: city, days: days) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let forecasts):
                self.addToRecentSearches(city)
                self.notifyObserversOfForecastUpdate(forecasts)
            case .failure(let error):
                self.notifyObserversOfError(error)
            }
        }
    }
    
    func searchCity(query: String, completion: @escaping (Result<[String], Error>) -> Void) {
        repository.searchCity(query: query, completion: completion)
    }
    
    // User preferences methods
    func setDefaultCity(_ city: String) {
        defaultCity = city
        addToRecentSearches(city)
    }
    
    private func addToRecentSearches(_ city: String) {
        // Remove if already exists to avoid duplicates
        recentSearches.removeAll { $0.lowercased() == city.lowercased() }
        
        // Add to the beginning of the array
        recentSearches.insert(city, at: 0)
        
        // Trim if exceeds maximum
        if recentSearches.count > maxRecentSearches {
            recentSearches = Array(recentSearches.prefix(maxRecentSearches))
        }
    }
    
    func getRecentSearches() -> [String] {
        return recentSearches
    }
}

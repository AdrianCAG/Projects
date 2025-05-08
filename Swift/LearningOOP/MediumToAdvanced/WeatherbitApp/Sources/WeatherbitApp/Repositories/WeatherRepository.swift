import Foundation
import Alamofire
import SwiftyJSON

protocol WeatherRepositoryProtocol {
    func getCurrentWeather(for city: String, completion: @escaping (Result<Weather, Error>) -> Void)
    func getForecast(for city: String, days: Int, completion: @escaping (Result<[Forecast], Error>) -> Void)
    func searchCity(query: String, completion: @escaping (Result<[String], Error>) -> Void)
}

enum WeatherbitError: Error {
    case invalidResponse
    case apiError(String)
    case networkError(Error)
}

class WeatherbitRepository: WeatherRepositoryProtocol {
    private let baseURL = "https://api.weatherbit.io/v2.0"
    
    // We'll no longer store the API key as a property
    // Instead, we'll get it dynamically from ConfigManager
    init(apiKey: String) {
        // We still accept an apiKey parameter for backward compatibility
        // but we don't store it
    }
    
    func getCurrentWeather(for city: String, completion: @escaping (Result<Weather, Error>) -> Void) {
        let url = "\(baseURL)/current"
        let parameters: [String: Any] = [
            "city": city,
            "key": ConfigManager.shared.apiKey
        ]
        
        AF.request(url, parameters: parameters).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let json = try JSON(data: data)
                    
                    if let errorMessage = json["error"].string {
                        completion(.failure(WeatherbitError.apiError(errorMessage)))
                        return
                    }
                    
                    guard let weatherData = json["data"].array?.first else {
                        completion(.failure(WeatherbitError.invalidResponse))
                        return
                    }
                    
                    let weather = Weather(cityName: city, json: weatherData)
                    completion(.success(weather))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(WeatherbitError.networkError(error)))
            }
        }
    }
    
    func getForecast(for city: String, days: Int = 5, completion: @escaping (Result<[Forecast], Error>) -> Void) {
        let url = "\(baseURL)/forecast/daily"
        let parameters: [String: Any] = [
            "city": city,
            "key": ConfigManager.shared.apiKey,
            "days": days
        ]
        
        AF.request(url, parameters: parameters).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let json = try JSON(data: data)
                    
                    if let errorMessage = json["error"].string {
                        completion(.failure(WeatherbitError.apiError(errorMessage)))
                        return
                    }
                    
                    guard let forecastData = json["data"].array else {
                        completion(.failure(WeatherbitError.invalidResponse))
                        return
                    }
                    
                    let forecasts = forecastData.map { Forecast(json: $0) }
                    completion(.success(forecasts))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(WeatherbitError.networkError(error)))
            }
        }
    }
    
    func searchCity(query: String, completion: @escaping (Result<[String], Error>) -> Void) {
        // Note: Weatherbit doesn't have a dedicated city search API
        // This is a simplified implementation that would need to be replaced
        // with a proper geocoding service in a real application
        
        // For demonstration purposes, we'll return some mock results
        let mockCities = [
            "\(query) City",
            "\(query) Town",
            "\(query) Village"
        ]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(mockCities))
        }
    }
}

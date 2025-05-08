import Foundation
import SwiftyJSON

struct Weather {
    let cityName: String
    let temperature: Double
    let description: String
    let humidity: Int
    let windSpeed: Double
    let windDirection: String
    let pressure: Double
    let uvIndex: Double
    let feelsLike: Double
    let cloudCoverage: Int
    let timestamp: Date
    
    init(cityName: String, json: JSON) {
        self.cityName = cityName
        self.temperature = json["temp"].doubleValue
        self.description = json["weather"]["description"].stringValue
        self.humidity = json["rh"].intValue
        self.windSpeed = json["wind_spd"].doubleValue
        self.windDirection = json["wind_cdir_full"].stringValue
        self.pressure = json["pres"].doubleValue
        self.uvIndex = json["uv"].doubleValue
        self.feelsLike = json["app_temp"].doubleValue
        self.cloudCoverage = json["clouds"].intValue
        
        // Parse timestamp
        if let timestamp = Double(json["ts"].stringValue) {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        } else {
            self.timestamp = Date()
        }
    }
}

struct Forecast {
    let date: Date
    let maxTemp: Double
    let minTemp: Double
    let description: String
    let precipitation: Double
    let humidity: Int
    let windSpeed: Double
    
    init(json: JSON) {
        // Parse date
        let dateString = json["valid_date"].stringValue
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.date = dateFormatter.date(from: dateString) ?? Date()
        
        self.maxTemp = json["max_temp"].doubleValue
        self.minTemp = json["min_temp"].doubleValue
        self.description = json["weather"]["description"].stringValue
        self.precipitation = json["precip"].doubleValue
        self.humidity = json["rh"].intValue
        self.windSpeed = json["wind_spd"].doubleValue
    }
}

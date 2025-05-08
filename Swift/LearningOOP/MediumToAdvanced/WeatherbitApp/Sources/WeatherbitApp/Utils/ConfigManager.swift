import Foundation

struct ConfigManager {
    static var shared = ConfigManager()
    
    private init() {}
    
    // User preferences
    private let userDefaultsPrefix = "com.weatherbitapp."
    
    var apiKey: String {
        get {
            return UserDefaults.standard.string(forKey: userDefaultsPrefix + "apiKey") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: userDefaultsPrefix + "apiKey")
        }
    }
    
    var isApiKeySet: Bool {
        return !apiKey.isEmpty
    }
    
    var defaultCity: String {
        get {
            return UserDefaults.standard.string(forKey: userDefaultsPrefix + "defaultCity") ?? "Los Angeles"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: userDefaultsPrefix + "defaultCity")
        }
    }
    
    var recentSearches: [String] {
        get {
            return UserDefaults.standard.stringArray(forKey: userDefaultsPrefix + "recentSearches") ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: userDefaultsPrefix + "recentSearches")
        }
    }
}

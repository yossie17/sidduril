import Foundation
import CoreLocation
import Combine

@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published private(set) var sunrise: Date?
    @Published private(set) var sunset: Date?
    @Published private(set) var locationError: String?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyReduced
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        // Check authorization status
        let status = locationManager.authorizationStatus
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        } else if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        } else {
            // Use default location (Jerusalem) if permission denied
            useDefaultLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        calculateSunriseSunset(for: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // If location fails, use default location instead of showing error
        useDefaultLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    private func useDefaultLocation() {
        // Default to Jerusalem coordinates
        let defaultLocation = CLLocation(latitude: 31.7683, longitude: 35.2137)
        calculateSunriseSunset(for: defaultLocation)
    }
    
    private func calculateSunriseSunset(for location: CLLocation) {
        Task { @MainActor in
            await fetchSunriseSunset(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    private func fetchSunriseSunset(latitude: Double, longitude: Double) async {
        let urlString = "https://api.sunrise-sunset.org/json?lat=\(latitude)&lng=\(longitude)&formatted=0"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status: \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let apiResponse = try decoder.decode(SunriseSunsetResponse.self, from: data)
            
            print("API Status: \(apiResponse.status)")
            
            if apiResponse.status == "OK" {
                sunrise = apiResponse.results.sunrise
                sunset = apiResponse.results.sunset
                print("Sunrise: \(apiResponse.results.sunrise)")
                print("Sunset: \(apiResponse.results.sunset)")
            }
        } catch {
            print("Error fetching sunrise/sunset: \(error)")
            print("Error details: \(error.localizedDescription)")
        }
    }
}

// API Response models
struct SunriseSunsetResponse: Codable {
    let results: SunriseSunsetResults
    let status: String
}

struct SunriseSunsetResults: Codable {
    let sunrise: Date
    let sunset: Date
    let solarNoon: Date?
    let dayLength: Int?
    
    enum CodingKeys: String, CodingKey {
        case sunrise
        case sunset
        case solarNoon = "solar_noon"
        case dayLength = "day_length"
    }
}
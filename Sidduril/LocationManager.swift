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
        let solar = Solar(coordinate: location.coordinate)
        sunrise = solar?.sunrise
        sunset = solar?.sunset
    }
}

// Solar calculation helper
struct Solar {
    private let calendar: Calendar
    private let coordinate: CLLocationCoordinate2D
    
    init?(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.calendar = Calendar.current
    }
    
    var sunrise: Date? {
        return calculateSunriseSunset(zenith: 90.8333, isRise: true)
    }
    
    var sunset: Date? {
        return calculateSunriseSunset(zenith: 90.8333, isRise: false)
    }
    
    private func calculateSunriseSunset(zenith: Double, isRise: Bool) -> Date? {
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        guard let today = calendar.date(from: components) else { return nil }
        
        // Get day of year
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: now) ?? 1
        
        // Convert latitude and longitude to radians
        let lat = coordinate.latitude * .pi / 180.0
        let lng = coordinate.longitude * .pi / 180.0
        
        // Calculate solar mean anomaly
        let meanAnomaly = (0.9856 * Double(dayOfYear) - 3.289) * .pi / 180.0
        
        // Calculate solar true longitude
        var trueLong = meanAnomaly + (1.916 * sin(meanAnomaly)) + (0.020 * sin(2 * meanAnomaly)) + 282.634
        
        // Normalize to 0-360 degrees
        while trueLong > 360.0 { trueLong -= 360.0 }
        while trueLong < 0.0 { trueLong += 360.0 }
        
        // Convert to radians
        trueLong = trueLong * .pi / 180.0
        
        // Calculate right ascension
        var rightAsc = atan(0.91764 * tan(trueLong))
        
        // Normalize to 0-360 degrees
        while rightAsc > .pi * 2 { rightAsc -= .pi * 2 }
        while rightAsc < 0.0 { rightAsc += .pi * 2 }
        
        // Convert to same quadrant as true longitude
        let lQuadrant = floor(trueLong / (.pi / 2)) * (.pi / 2)
        let raQuadrant = floor(rightAsc / (.pi / 2)) * (.pi / 2)
        rightAsc += (lQuadrant - raQuadrant)
        
        // Convert to hours
        rightAsc = rightAsc * 180.0 / .pi / 15.0
        
        // Calculate sin of solar declination
        let sinDec = 0.39782 * sin(trueLong)
        let cosDec = cos(asin(sinDec))
        
        // Calculate cosine of solar hour angle
        let cosH = (cos(zenith * .pi / 180.0) - sinDec * sin(lat)) / (cosDec * cos(lat))
        
        if cosH > 1 || cosH < -1 {
            return nil // Sun never rises/sets on this location on this day
        }
        
        // Calculate solar hour angle
        var H = isRise ? 360.0 - acos(cosH) * 180.0 / .pi : acos(cosH) * 180.0 / .pi
        H = H / 15.0 // Convert to hours
        
        // Calculate local mean time
        let T = H + rightAsc - (0.06571 * Double(dayOfYear)) - 6.622
        
        // Adjust for time zone and daylight savings
        let UT = T - lng / 15.0
        var localT = UT + Double(TimeZone.current.secondsFromGMT()) / 3600.0
        
        // Normalize hours to 0-24
        while localT > 24.0 { localT -= 24.0 }
        while localT < 0.0 { localT += 24.0 }
        
        // Convert to date
        let hours = floor(localT)
        let minutes = (localT - hours) * 60.0
        
        var dateComponents = components
        dateComponents.hour = Int(hours)
        dateComponents.minute = Int(minutes)
        
        return calendar.date(from: dateComponents)
    }
}
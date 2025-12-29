import Foundation
import CoreLocation

struct MockLocations {
    static let locations: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // San Francisco
        CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), // New York
        CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), // Los Angeles
        CLLocationCoordinate2D(latitude: 41.8781, longitude: -87.6298), // Chicago
        CLLocationCoordinate2D(latitude: 29.7604, longitude: -95.3698), // Houston
        CLLocationCoordinate2D(latitude: 33.4484, longitude: -112.0740), // Phoenix
        CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652), // Philadelphia
        CLLocationCoordinate2D(latitude: 32.7767, longitude: -96.7970), // Dallas
        CLLocationCoordinate2D(latitude: 25.7617, longitude: -80.1918), // Miami
        CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321), // Seattle
        CLLocationCoordinate2D(latitude: 39.7392, longitude: -104.9903), // Denver
        CLLocationCoordinate2D(latitude: 36.1699, longitude: -115.1398), // Las Vegas
        CLLocationCoordinate2D(latitude: 45.5152, longitude: -122.6784), // Portland
        CLLocationCoordinate2D(latitude: 30.2672, longitude: -97.7431), // Austin
        CLLocationCoordinate2D(latitude: 35.2271, longitude: -80.8431), // Charlotte
        CLLocationCoordinate2D(latitude: 38.9072, longitude: -77.0369), // Washington DC
        CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589), // Boston
        CLLocationCoordinate2D(latitude: 33.7490, longitude: -84.3880), // Atlanta
        CLLocationCoordinate2D(latitude: 44.9778, longitude: -93.2650), // Minneapolis
        CLLocationCoordinate2D(latitude: 37.3382, longitude: -121.8863) // San Jose
    ]
    
    static func randomLocation() -> CLLocationCoordinate2D {
        locations.randomElement() ?? locations[0]
    }
}


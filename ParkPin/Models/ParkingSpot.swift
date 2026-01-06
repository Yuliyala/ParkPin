import Foundation
import CoreLocation

struct ParkingSpot: Codable, Identifiable {
    let id: UUID
    var location: CLLocationCoordinate2D
    var address: String
    var floor: String?
    var zone: String?
    var row: String?
    var photo: Data?
    var notes: String?
    var date: Date
    
    init(
        id: UUID = UUID(),
        location: CLLocationCoordinate2D,
        address: String,
        floor: String? = nil,
        zone: String? = nil,
        row: String? = nil,
        photo: Data? = nil,
        notes: String? = nil,
        date: Date = Date()
    ) {
        self.id = id
        self.location = location
        self.address = address
        self.floor = floor
        self.zone = zone
        self.row = row
        self.photo = photo
        self.notes = notes
        self.date = date
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case latitude
        case longitude
        case address
        case floor
        case zone
        case row
        case photo
        case notes
        case date
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        address = try container.decode(String.self, forKey: .address)
        floor = try container.decodeIfPresent(String.self, forKey: .floor)
        zone = try container.decodeIfPresent(String.self, forKey: .zone)
        row = try container.decodeIfPresent(String.self, forKey: .row)
        photo = try container.decodeIfPresent(Data.self, forKey: .photo)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        date = try container.decode(Date.self, forKey: .date)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(location.latitude, forKey: .latitude)
        try container.encode(location.longitude, forKey: .longitude)
        try container.encode(address, forKey: .address)
        try container.encodeIfPresent(floor, forKey: .floor)
        try container.encodeIfPresent(zone, forKey: .zone)
        try container.encodeIfPresent(row, forKey: .row)
        try container.encodeIfPresent(photo, forKey: .photo)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encode(date, forKey: .date)
    }
}



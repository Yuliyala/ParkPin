import Foundation

struct Note: Codable, Identifiable, Hashable {
    let id: UUID
    var text: String
    var photos: [Data]
    var date: Date
    var parkingSpotId: UUID?
    
    init(
        id: UUID = UUID(),
        text: String,
        photos: [Data] = [],
        date: Date = Date(),
        parkingSpotId: UUID? = nil
    ) {
        self.id = id
        self.text = text
        self.photos = photos
        self.date = date
        self.parkingSpotId = parkingSpotId
    }
}



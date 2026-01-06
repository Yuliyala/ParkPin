import Foundation

struct ParkingTimer: Codable, Identifiable {
    let id: UUID
    var endDate: Date
    var notes: String?
    var isActive: Bool
    
    init(
        id: UUID = UUID(),
        endDate: Date,
        notes: String? = nil,
        isActive: Bool = true
    ) {
        self.id = id
        self.endDate = endDate
        self.notes = notes
        self.isActive = isActive
    }
    
    var timeRemaining: TimeInterval {
        max(0, endDate.timeIntervalSinceNow)
    }
    
    var isExpired: Bool {
        endDate < Date()
    }
}



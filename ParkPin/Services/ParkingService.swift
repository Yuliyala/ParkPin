import Foundation
import Combine

class ParkingService: ObservableObject {
    static let shared = ParkingService()
    
    private let currentParkingKey = "currentParking"
    private let parkingHistoryKey = "parkingHistory"
    private let maxHistoryCount = 10
    
    private init() {}
    
    func saveCurrentParking(_ parking: ParkingSpot) {
        if let encoded = try? JSONEncoder().encode(parking) {
            UserDefaults.standard.set(encoded, forKey: currentParkingKey)
        }
        addToHistory(parking)
    }
    
    func getCurrentParking() -> ParkingSpot? {
        guard let data = UserDefaults.standard.data(forKey: currentParkingKey),
              let parking = try? JSONDecoder().decode(ParkingSpot.self, from: data) else {
            return nil
        }
        return parking
    }
    
    func deleteCurrentParking() {
        UserDefaults.standard.removeObject(forKey: currentParkingKey)
    }
    
    func getParkingHistory() -> [ParkingSpot] {
        guard let data = UserDefaults.standard.data(forKey: parkingHistoryKey),
              let history = try? JSONDecoder().decode([ParkingSpot].self, from: data) else {
            return []
        }
        return Array(history.prefix(maxHistoryCount))
    }
    
    func deleteParkingFromHistory(_ parking: ParkingSpot) {
        var history = getParkingHistory()
        history.removeAll { $0.id == parking.id }
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: parkingHistoryKey)
        }
    }
    
    private func addToHistory(_ parking: ParkingSpot) {
        var history = getParkingHistory()
        history.insert(parking, at: 0)
        if history.count > maxHistoryCount {
            history = Array(history.prefix(maxHistoryCount))
        }
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: parkingHistoryKey)
        }
    }
    
    func clearAllData() {
        UserDefaults.standard.removeObject(forKey: currentParkingKey)
        UserDefaults.standard.removeObject(forKey: parkingHistoryKey)
    }
}


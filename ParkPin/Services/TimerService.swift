import Foundation

class TimerService {
    static let shared = TimerService()
    
    private let timerKey = "parkingTimer"
    
    private init() {}
    
    func saveTimer(_ timer: ParkingTimer) {
        if let encoded = try? JSONEncoder().encode(timer) {
            UserDefaults.standard.set(encoded, forKey: timerKey)
        }
    }
    
    func getTimer() -> ParkingTimer? {
        guard let data = UserDefaults.standard.data(forKey: timerKey),
              let timer = try? JSONDecoder().decode(ParkingTimer.self, from: data) else {
            return nil
        }
        return timer
    }
    
    func deleteTimer() {
        UserDefaults.standard.removeObject(forKey: timerKey)
    }
    
    func clearAllData() {
        UserDefaults.standard.removeObject(forKey: timerKey)
    }
}



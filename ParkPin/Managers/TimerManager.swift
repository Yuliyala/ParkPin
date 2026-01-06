import Foundation
import Combine
import UserNotifications
import AudioToolbox
import UIKit

class TimerManager: ObservableObject {
    static let shared = TimerManager()
    
    @Published var currentTimer: ParkingTimer?
    @Published var timeRemaining: TimeInterval = 0
    @Published var isExpired: Bool = false
    
    private var timer: Timer?
    private let timerService = TimerService.shared
    private var hasPlayedAlert = false
    
    private init() {
        loadTimer()
    }
    
    func loadTimer() {
        currentTimer = timerService.getTimer()
        if let timer = currentTimer {
            if timer.isExpired {
                deleteTimer()
            } else if timer.isActive {
                startTimer()
            }
        }
    }
    
    func startTimer(with timer: ParkingTimer) {
        currentTimer = timer
        timerService.saveTimer(timer)
        hasPlayedAlert = false
        startTimer()
        scheduleNotification(for: timer.endDate)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        if var current = currentTimer {
            current.isActive = false
            currentTimer = current
            timerService.saveTimer(current)
        }
    }
    
    func deleteTimer() {
        stopTimer()
        timerService.deleteTimer()
        currentTimer = nil
        hasPlayedAlert = false
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
        updateTimer()
    }
    
    private func updateTimer() {
        guard let timer = currentTimer, timer.isActive else {
            timer?.invalidate()
            self.timer = nil
            return
        }
        
        timeRemaining = timer.timeRemaining
        isExpired = timer.isExpired
        
        if isExpired {
            handleTimerExpired()
        }
    }
    
    private func handleTimerExpired() {
        guard !hasPlayedAlert else { return }
        
        hasPlayedAlert = true
        timer?.invalidate()
        timer = nil
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.warning)
        
        AudioServicesPlaySystemSound(1005)
    }
    
    private func scheduleNotification(for date: Date) {
        let timeInterval = date.timeIntervalSinceNow
        
        guard timeInterval > 0 else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Parking Timer"
        content.body = "Your parking time is up!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "parkingTimer",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}


import Foundation
import UserNotifications
import UIKit

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "notificationsEnabled")
            if isEnabled {
                requestAuthorization()
            }
        }
    }
    
    private init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                        DispatchQueue.main.async {
                            if granted {
                                self?.isEnabled = true
                            } else {
                                self?.isEnabled = false
                                self?.showSettingsAlert()
                            }
                        }
                    }
                case .denied:
                    self?.isEnabled = false
                    self?.showSettingsAlert()
                case .authorized, .provisional, .ephemeral:
                    self?.isEnabled = true
                @unknown default:
                    self?.isEnabled = false
                }
            }
        }
    }
    
    private func showSettingsAlert() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        let alert = UIAlertController(
            title: "Notifications Disabled",
            message: "Please enable notifications in Settings to receive parking timer alerts.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        rootViewController.present(alert, animated: true)
    }
}



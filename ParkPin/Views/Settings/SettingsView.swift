import SwiftUI

struct SettingsView: View {
    @ObservedObject private var notificationManager = NotificationManager.shared
    @State private var showingClearAlert = false
    @State private var selectedWebViewURL: URL?
    @State private var showingWebView = false
    @Binding var showTabBar: Bool
    
    init(showTabBar: Binding<Bool> = .constant(true)) {
        self._showTabBar = showTabBar
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("mainBg")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Image("settingsIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 224, height: 132)
                        .padding(.top, 20)

                    ZStack {
                        RoundedRectangle(cornerRadius: 29)
                            .fill(Color(hex: "6A6361"))
                            .frame(height: 249)
                            .overlay(
                                RoundedRectangle(cornerRadius: 29)
                                    .stroke(Color(hex: "5B5B5A"), lineWidth: 3)
                            )
                        
                        VStack(spacing: 4) {
                            HStack {
                                Text("Notification")
                                    .font(.custom("Montserrat-ExtraBold", size: 20))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: {
                                    if notificationManager.isEnabled {
                                        notificationManager.isEnabled = false
                                    } else {
                                        notificationManager.requestAuthorization()
                                    }
                                }) {
                                    Image(notificationManager.isEnabled ? "switchOn" : "switch")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 76, height: 49)
                                }
                            }
                            .frame(height: 73)
                            .padding(.horizontal, 20)
                            .background(Color(hex: "83817F"))
                            .cornerRadius(21)
                            .overlay(
                                RoundedRectangle(cornerRadius: 21)
                                    .stroke(Color(hex: "5B5B5A"), lineWidth: 3)
                            )
                            
                            HStack {
                                Text("History")
                                    .font(.custom("Montserrat-ExtraBold", size: 20))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: {
                                    showingClearAlert = true
                                }) {
                                    Text("Clear")
                                        .font(.custom("Montserrat-ExtraBold", size: 20))
                                        .foregroundColor(.white)
                                        .frame(width: 76, height: 49)
                                        .background(Color.red)
                                        .cornerRadius(25)
                                }
                            }
                            .frame(height: 73)
                            .padding(.horizontal, 20)
                            .background(Color(hex: "83817F"))
                            .cornerRadius(21)
                            .overlay(
                                RoundedRectangle(cornerRadius: 21)
                                    .stroke(Color(hex: "5B5B5A"), lineWidth: 3)
                            )
                            
                            HStack {
                                Text("About the app")
                                    .font(.custom("Montserrat-ExtraBold", size: 20))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: {
                                    selectedWebViewURL = URL(string: "https://google.com")
                                    showingWebView = true
                                }) {
                                    Image("navigate")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 55, height: 44)
                                }
                            }
                            .frame(height: 73)
                            .padding(.horizontal, 20)
                            .background(Color(hex: "83817F"))
                            .cornerRadius(21)
                            .overlay(
                                RoundedRectangle(cornerRadius: 21)
                                    .stroke(Color(hex: "5B5B5A"), lineWidth: 3)
                            )
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 20)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .overlay {
                if showingClearAlert {
                    clearAlertOverlay
                }
            }
            .navigationDestination(isPresented: $showingWebView) {
                if let url = selectedWebViewURL {
                    WebViewScreen(url: url, showTabBar: $showTabBar)
                }
            }
        }
    }
    
    private var clearAlertOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    showingClearAlert = false
                }
            
            VStack(spacing: 20) {
                Text("Clear")
                    .font(.custom("FontdinerSwanky", size: 35))
                    .foregroundColor(.white)
                
                Text("Do you really want to delete all data?")
                    .font(.custom("Montserrat-ExtraBold", size: 20))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                HStack(spacing: 20) {
                    Button(action: {
                        showingClearAlert = false
                    }) {
                        Text("Cancel")
                            .font(.custom("Montserrat-ExtraBold", size: 20))
                            .foregroundColor(.white)
                            .frame(width: 120, height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        clearAllData()
                        showingClearAlert = false
                    }) {
                        Text("Clear")
                            .font(.custom("Montserrat-ExtraBold", size: 20))
                            .foregroundColor(.white)
                            .frame(width: 120, height: 50)
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(20)
            .background(Color(hex: "6A6361"))
            .cornerRadius(29)
            .overlay(
                RoundedRectangle(cornerRadius: 29)
                    .stroke(Color(hex: "5B5B5A"), lineWidth: 3)
            )
            .padding(.horizontal, 32)
        }
    }
    
    private func clearAllData() {
        ParkingService.shared.clearAllData()
        TimerService.shared.clearAllData()
        NotesService.shared.clearAllData()
        TimerManager.shared.deleteTimer()
    }
}



import SwiftUI

struct TimerView: View {
    @StateObject private var timerManager = TimerManager.shared
    @State private var navigateToEdit = false
    @State private var showDeleteAlert = false
    @Binding var showTabBar: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("mainBg")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Image("parkingTimer")
                        .resizable()
                        .frame(width: 208, height: 123)
                        .padding(.top, 20)
                    
                    if let timer = timerManager.currentTimer, timer.isActive {
                        if timerManager.isExpired {
                            Spacer()
                            
                            timeExpiredView
                            
                            Spacer()
                        } else {
                            Spacer()
                            
                            activeTimerCard(timer: timer)
                                .padding(.horizontal, 32)
                                .offset(y: -72)
                            
                            Spacer()
                        }
                    } else {
                        Spacer()
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay {
                    if timerManager.currentTimer == nil {
                        VStack {
                            Spacer()
                            
                            NavigationLink(destination: AddTimerView(showTabBar: $showTabBar) { timer in
                                timerManager.startTimer(with: timer)
                            }) {
                                emptyStateView
                            }
                            .buttonStyle(.plain)
                            .offset(y: -20)
                            
                            Spacer()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                timerManager.loadTimer()
            }
            .navigationDestination(isPresented: $navigateToEdit) {
                if let timer = timerManager.currentTimer {
                    AddTimerView(existingTimer: timer, showTabBar: $showTabBar) { updatedTimer in
                        timerManager.startTimer(with: updatedTimer)
                        navigateToEdit = false
                    }
                }
            }
            .overlay {
                if showDeleteAlert {
                    deleteAlertOverlay
                }
            }
        }
    }
    
    private func activeTimerCard(timer: ParkingTimer) -> some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 29)
                .fill(Color(hex: "6A6361"))
                .frame(height: 326)
                .overlay(
                    RoundedRectangle(cornerRadius: 29)
                        .stroke(Color(hex: "383333"), lineWidth: 3)
                )
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            navigateToEdit = true
                        }) {
                            Image("edit")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 48, height: 46)
                        }
                        
                        Button(action: {
                            showDeleteAlert = true
                        }) {
                            Image("remove")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 48, height: 46)
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.trailing, 16)
    
                HStack(spacing: 0) {
                    countdownBox(value: daysRemaining, label: "days")
                    countdownBox(value: hoursRemaining, label: "hours")
                    countdownBox(value: minutesRemaining, label: "minutes")
                }
                .padding(.horizontal, 4)
                .padding(.top, 20)
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 21)
                        .fill(Color(hex: "83817F"))
                        .frame(height: 73)
                        .overlay(
                            RoundedRectangle(cornerRadius: 21)
                                .stroke(Color(hex: "5B5B5A"), lineWidth: 3)
                        )
              
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes")
                            .font(.custom("Montserrat-ExtraBold", size: 20))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.leading, 20)
                            .padding(.top, 8)
                        
                        if let notes = timer.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.custom("Montserrat-ExtraBold", size: 20))
                                .foregroundColor(.white)
                                .padding(.leading, 20)
                                .padding(.bottom, 8)
                        } else {
                            Text("Refill if needed")
                                .font(.custom("Montserrat-ExtraBold", size: 20))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.leading, 20)
                                .padding(.bottom, 8)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
    }
    
    private func countdownBox(value: Int, label: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 23)
                    .fill(Color(hex: "6A6361"))
                    .frame(width: 98, height: 98)
                    .overlay(
                        RoundedRectangle(cornerRadius: 23)
                            .stroke(Color(hex: "383333"), lineWidth: 2.2)
                    )
                
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "83817F"))
                        .frame(width: 85, height: 85)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "5B5B5A"), lineWidth: 1.5)
                        )
                    
                    Text("\(value)")
                        .font(.custom("Montserrat-ExtraBold", size: 50))
                        .foregroundColor(.white)
                }
            }
            
            Text(label)
                .font(.custom("Montserrat-ExtraBold", size: 16))
                .foregroundColor(.white)
        }
    }
    
    private var daysRemaining: Int {
        guard let timer = timerManager.currentTimer, timer.isActive else { return 0 }
        return Int(timerManager.timeRemaining) / 86400
    }
    
    private var hoursRemaining: Int {
        guard let timer = timerManager.currentTimer, timer.isActive else { return 0 }
        return (Int(timerManager.timeRemaining) % 86400) / 3600
    }
    
    private var minutesRemaining: Int {
        guard let timer = timerManager.currentTimer, timer.isActive else { return 0 }
        return (Int(timerManager.timeRemaining) % 3600) / 60
    }
    
    private var emptyStateView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 29)
                .fill(Color(hex: "6A6361"))
                .frame(height: 244)
                .overlay(
                    RoundedRectangle(cornerRadius: 29)
                        .stroke(Color(hex: "5B5B5A"), lineWidth: 3)
                )
            
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    Text("No active timers")
                        .font(.custom("Montserrat-ExtraBold", size: 25))
                        .foregroundColor(.white)
                        .lineSpacing(0)
                        .kerning(-0.41)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Set a timer for your parking session to avoid fines")
                        .font(.custom("Montserrat-ExtraBold", size: 20))
                        .foregroundColor(.white.opacity(0.5))
                        .lineSpacing(0)
                        .kerning(-0.41)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 32)
                .padding(.horizontal, 20)
                
                Spacer()
                
                Image("addIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 84)
                    .padding(.bottom, 20)
            }
            .frame(height: 244)
        }
        .padding(.horizontal, 32)
    }
    
    private var timeExpiredView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 29)
                .fill(Color(hex: "6A6361"))
                .frame(height: 326)
                .overlay(
                    RoundedRectangle(cornerRadius: 29)
                        .stroke(Color(hex: "383333"), lineWidth: 3)
                )
            
            VStack(spacing: 12) {
                Image("timesUp")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 143, height: 192)
                
                Text("Time's up!")
                    .font(.custom("FontdinerSwanky", size: 35))
                    .foregroundColor(.white)
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        timerManager.deleteTimer()
                    }) {
                        Image("delete")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 55, height: 55)
                    }
                    .padding(.top, 16)
                    .padding(.trailing, 16)
                }
                
                Spacer()
            }
        }
        .frame(height: 326)
        .padding(.horizontal, 32)
        .offset(y: -32)
    }
    
    private var deleteAlertOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Delete")
                    .font(.custom("FontdinerSwanky", size: 35))
                    .foregroundColor(.white)
                
                Text("Do you want to delete this timer?")
                    .font(.custom("Montserrat-ExtraBold", size: 20))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                HStack(spacing: 20) {
                    Button(action: {
                        showDeleteAlert = false
                    }) {
                        Text("Cancel")
                            .font(.custom("Montserrat-ExtraBold", size: 20))
                            .foregroundColor(.white)
                            .frame(width: 140, height: 56)
                            .background(Color.blue)
                            .cornerRadius(28)
                    }
                    
                    Button(action: {
                        timerManager.deleteTimer()
                        showDeleteAlert = false
                    }) {
                        Text("Clear")
                            .font(.custom("Montserrat-ExtraBold", size: 20))
                            .foregroundColor(.white)
                            .frame(width: 140, height: 56)
                            .background(Color.red)
                            .cornerRadius(28)
                    }
                }
            }
            .padding(40)
            .background(Color(hex: "6A6361"))
            .cornerRadius(29)
            .padding(.horizontal, 40)
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

import SwiftUI

struct AddTimerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedDate = Date()
    @State private var selectedTime = Date().addingTimeInterval(3600)
    @State private var notes: String = ""
    @State private var showingDatePicker = false
    @State private var showingTimePicker = false
    @State private var hasSelectedDate = false
    @State private var hasSelectedTime = false
    
    let existingTimer: ParkingTimer?
    let onSave: (ParkingTimer) -> Void
    @Binding var showTabBar: Bool
    
    init(existingTimer: ParkingTimer? = nil, showTabBar: Binding<Bool>, onSave: @escaping (ParkingTimer) -> Void) {
        self.existingTimer = existingTimer
        self._showTabBar = showTabBar
        self.onSave = onSave
        
        if let timer = existingTimer {
            _selectedDate = State(initialValue: timer.endDate)
            _selectedTime = State(initialValue: timer.endDate)
            _notes = State(initialValue: timer.notes ?? "")
            _hasSelectedDate = State(initialValue: true)
            _hasSelectedTime = State(initialValue: true)
        }
    }
    
    var body: some View {
        ZStack {
            Image("mainBg")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image("back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 101, height: 81)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        saveTimer()
                    }) {
                        Image(isFormValid ? "doneOn" : "done")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 88, height: 85)
                    }
                    .disabled(!isFormValid)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 29)
                                .fill(Color(hex: "6A6361"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 29)
                                        .stroke(Color(hex: "383333"), lineWidth: 3)
                                )
                            
                            VStack(spacing: 0) {
                                Text("Paid Until")
                                    .font(.custom("Montserrat-ExtraBold", size: 20))
                                    .foregroundColor(.white)
                                    .padding(.top, 8)
                                    .padding(.bottom, 8)
                                
                                VStack(spacing: 4) {
                                    TimerFieldButton(
                                        placeholder: "Date",
                                        value: hasSelectedDate ? formatDate(selectedDate) : "",
                                        icon: "calendar",
                                        action: {
                                            showingDatePicker = true
                                        }
                                    )
                                    
                                    TimerFieldButton(
                                        placeholder: "Time",
                                        value: hasSelectedTime ? formatTime(selectedTime) : "",
                                        icon: "clock",
                                        action: {
                                            showingTimePicker = true
                                        }
                                    )
                                    
                                    TimerTextField(placeholder: "Notes", text: $notes)
                                }
                                .padding(.horizontal, 8)
                                .padding(.bottom, 8)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            showTabBar = false
        }
        .onDisappear {
            showTabBar = true
        }
        .overlay {
            datePickerOverlay
            timePickerOverlay
        }
        .hideKeyboardOnTap()
    }
    
    private var isFormValid: Bool {
        guard hasSelectedDate && hasSelectedTime && !notes.isEmpty else {
            return false
        }
        let endDate = combineDateAndTime(date: selectedDate, time: selectedTime)
        return endDate > Date()
    }
    
    private func saveTimer() {
        let endDate = combineDateAndTime(date: selectedDate, time: selectedTime)
        
        let timer = ParkingTimer(
            endDate: endDate,
            notes: notes.isEmpty ? nil : notes
        )
        
        onSave(timer)
        dismiss()
    }
    
    private func combineDateAndTime(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        
        return calendar.date(from: combined) ?? Date()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    @ViewBuilder
    private var datePickerOverlay: some View {
        if showingDatePicker {
            ZStack {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hasSelectedDate = true
                        showingDatePicker = false
                    }
                
                VStack {
                    Spacer()
                    
                    DatePickerView(
                        selectedDate: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    @ViewBuilder
    private var timePickerOverlay: some View {
        if showingTimePicker {
            ZStack {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showingTimePicker = false
                        hasSelectedTime = true
                    }
                
                VStack {
                    Spacer()
                    
                    DatePickerView(
                        selectedDate: $selectedTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct TimerFieldButton: View {
    let placeholder: String
    let value: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 21)
                    .fill(Color(hex: "83817F"))
                    .frame(height: 73)
                    .overlay(
                        RoundedRectangle(cornerRadius: 21)
                            .stroke(Color(hex: "5B5B5A"), lineWidth: 3)
                    )
                
                HStack {
                    Text(value.isEmpty ? placeholder : value)
                        .font(.custom("Montserrat-ExtraBold", size: 20))
                        .foregroundColor(value.isEmpty ? .white.opacity(0.5) : .white)
                        .padding(.leading, 20)
                    
                    Spacer()
                    
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .padding(.trailing, 15)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct TimerTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .trailing) {
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.5)))
                .font(.custom("Montserrat-ExtraBold", size: 20))
                .foregroundColor(.white)
                .frame(height: 73)
                .padding(.leading, 16)
                .padding(.trailing, text.isEmpty ? 16 : 48)
                .background(Color(hex: "83817F"))
                .cornerRadius(21)
                .overlay(
                    RoundedRectangle(cornerRadius: 21)
                        .stroke(Color(hex: "5B5B5A"), lineWidth: 3)
                )
                .submitLabel(.done)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image("delete")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 31)
                }
                .padding(.trailing, 16)
            }
        }
    }
}

struct DatePickerView: View {
    @Binding var selectedDate: Date
    let displayedComponents: DatePickerComponents
    
    private var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        var startComponents = DateComponents()
        startComponents.year = 1900
        startComponents.month = 1
        startComponents.day = 1
        let startDate = calendar.date(from: startComponents) ?? Date()
        
        var endComponents = DateComponents()
        endComponents.year = 2100
        endComponents.month = 12
        endComponents.day = 31
        let endDate = calendar.date(from: endComponents) ?? Date()
        
        return startDate...endDate
    }
    
    var body: some View {
        if displayedComponents.contains(.date) && !displayedComponents.contains(.hourAndMinute) {
            DatePicker("", selection: $selectedDate, in: dateRange, displayedComponents: displayedComponents)
                .datePickerStyle(.graphical)
                .labelsHidden()
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .onTapGesture(count: 99) {}
        } else {
            DatePicker("", selection: $selectedDate, in: dateRange, displayedComponents: displayedComponents)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding()
                .background(Color.white)
                .cornerRadius(12)
        }
    }
}

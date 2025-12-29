import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var parkingService = ParkingService.shared
    @State private var history: [ParkingSpot] = []
    @State private var parkingToEdit: ParkingSpot?
    @State private var parkingToDelete: ParkingSpot?
    @State private var showDeleteAlert = false
    @State private var navigateToEdit = false
    @Binding var showTabBar: Bool
    @Binding var selectedTab: Int
    
    init(showTabBar: Binding<Bool> = .constant(true), selectedTab: Binding<Int> = .constant(0)) {
        self._showTabBar = showTabBar
        self._selectedTab = selectedTab
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
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                if history.isEmpty {
                    Spacer()
                    
                    emptyStateView
                        .offset(y: -50)
                    
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            ForEach(history) { parking in
                                NavigationLink(destination: ParkingDetailView(
                                    parking: parking,
                                    onEdit: {
                                        parkingToEdit = parking
                                        navigateToEdit = true
                                    },
                                    onDelete: {
                                        parkingToDelete = parking
                                        showDeleteAlert = true
                                    },
                                    showTabBar: $showTabBar,
                                    selectedTab: $selectedTab
                                )
                                .navigationBarHidden(true)) {
                                    HistoryCard(parking: parking)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadHistory()
            showTabBar = false
        }
        .onDisappear {
            showTabBar = true
        }
        .overlay(deleteAlertOverlay)
    }
    
    @ViewBuilder
    private var deleteAlertOverlay: some View {
        if showDeleteAlert {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    showDeleteAlert = false
                }
            
            VStack {
                Spacer()
                
                DeleteAlertView(
                    title: "Delete",
                    message: "Do you want to delete this entry?",
                    onDelete: {
                        if let parking = parkingToDelete {
                            parkingService.deleteParkingFromHistory(parking)
                            loadHistory()
                            showDeleteAlert = false
                            parkingToDelete = nil
                        }
                    },
                    onDismiss: {
                        showDeleteAlert = false
                        parkingToDelete = nil
                    }
                )
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
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
                    Text("No previous parking records")
                        .font(.custom("Montserrat-ExtraBold", size: 25))
                        .foregroundColor(.white)
                        .lineSpacing(0)
                        .kerning(-0.41)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Track your past parking locations easily")
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
            }
            .frame(height: 244)
        }
        .padding(.horizontal, 32)
    }
    
    private func loadHistory() {
        history = parkingService.getParkingHistory()
    }
}

struct HistoryCard: View {
    let parking: ParkingSpot
    
    var body: some View {
        HStack(spacing: 16) {
            if let photo = parking.photo, let uiImage = UIImage(data: photo) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 104, height: 104)
                    .clipShape(RoundedRectangle(cornerRadius: 21))
            } else {
                Image("photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 21))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image("calendar")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 29, height: 28)
                    
                    Text(formatDate(parking.date))
                        .font(.custom("Montserrat-ExtraBold", size: 16))
                        .foregroundColor(.white)
                }
                
                HStack(spacing: 8) {
                    Image("clock")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 29, height: 28)
                    
                    Text(formatTime(parking.date))
                        .font(.custom("Montserrat-ExtraBold", size: 16))
                        .foregroundColor(.white)
                }
                
                HStack(spacing: 8) {
                    Image("location")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 29, height: 28)
                    
                    Text(parking.address)
                        .font(.custom("Montserrat-ExtraBold", size: 16))
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
        }
        .padding(8)
        .background(Color(hex: "6A6361"))
        .cornerRadius(29)
        .overlay(
            RoundedRectangle(cornerRadius: 29)
                .stroke(Color(hex: "5B5B5A"), lineWidth: 3)
        )
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
}


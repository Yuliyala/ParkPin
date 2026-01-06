import SwiftUI
import MapKit

struct ParkingView: View {
    @Binding var showTabBar: Bool
    @ObservedObject private var parkingService = ParkingService.shared
    @State private var currentParking: ParkingSpot?
    @State private var showDeleteAlert = false
    @State private var navigateToAdd = false
    @State private var parkingToEdit: ParkingSpot?
    
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
                    Image("parkingHeader")
                        .resizable()
                        .frame(width: 208, height: 123)
                        .padding(.top, 20)
                    
                    if let parking = currentParking {
                        ParkingDetailView(
                            parking: parking,
                            onEdit: {
                                parkingToEdit = parking
                                navigateToAdd = true
                            },
                            onDelete: {
                                showDeleteAlert = true
                            }
                        )
                    } else {
                        Spacer()
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay {
                    if currentParking == nil {
                        VStack {
                            Spacer()
                            
                            NavigationLink(destination: AddParkingView(showTabBar: $showTabBar) { parking in
                                parkingService.saveCurrentParking(parking)
                                currentParking = parking
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
                loadParking()
                showTabBar = true
            }
            .navigationDestination(isPresented: $navigateToAdd) {
                AddParkingView(existingParking: parkingToEdit, showTabBar: $showTabBar) { parking in
                    parkingService.saveCurrentParking(parking)
                    currentParking = parking
                    navigateToAdd = false
                    parkingToEdit = nil
                }
                .navigationBarHidden(true)
            }
            .overlay(deleteAlertOverlay)
        }
        .hideKeyboardOnTap()
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
                    Text("No parking spots saved yet")
                        .font(.custom("Montserrat-ExtraBold", size: 25))
                        .foregroundColor(.white)
                        .lineSpacing(0)
                        .kerning(-0.41)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Never forget where you parked again")
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
                        parkingService.deleteCurrentParking()
                        currentParking = nil
                        showDeleteAlert = false
                    },
                    onDismiss: {
                        showDeleteAlert = false
                    }
                )
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func loadParking() {
        currentParking = parkingService.getCurrentParking()
    }
}

struct ParkingCard: View {
    let parking: ParkingSpot
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                if let photo = parking.photo, let uiImage = UIImage(data: photo) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                } else {
                    Color.gray
                        .frame(height: 200)
                }
                
                HStack(spacing: 12) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.red)
                            .clipShape(Circle())
                    }
                }
                .padding(12)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "calendar")
                    Text(formatDate(parking.date))
                }
                .font(.system(size: 14))
                .foregroundColor(.white)
                
                HStack {
                    Image(systemName: "clock")
                    Text(formatTime(parking.date))
                }
                .font(.system(size: 14))
                .foregroundColor(.white)
                
                HStack {
                    Image(systemName: "mappin.circle")
                    Text(parking.address)
                }
                .font(.system(size: 14))
                .foregroundColor(.white)
                
                if let notes = parking.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Text(notes)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Map(coordinateRegion: Binding(
                    get: {
                        MKCoordinateRegion(
                            center: parking.location,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                    },
                    set: { _ in }
                ), annotationItems: [parking]) { spot in
                    MapMarker(coordinate: spot.location, tint: .blue)
                }
                .frame(height: 150)
                .cornerRadius(12)
            }
            .padding(16)
        }
        .background(Color(hex: "5B5B5A"))
        .cornerRadius(16)
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

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

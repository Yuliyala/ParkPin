import SwiftUI
import MapKit

struct MapAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct ParkingDetailView: View {
    @Environment(\.dismiss) var dismiss
    let parking: ParkingSpot
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?
    @State private var region: MKCoordinateRegion
    @State private var annotation: MapAnnotation
    @Binding var showTabBar: Bool
    var selectedTabBinding: Binding<Int>?
    
    init(parking: ParkingSpot, onEdit: (() -> Void)? = nil, onDelete: (() -> Void)? = nil, showTabBar: Binding<Bool> = .constant(true), selectedTab: Binding<Int>? = nil) {
        self.parking = parking
        self.onEdit = onEdit
        self.onDelete = onDelete
        self._showTabBar = showTabBar
        self.selectedTabBinding = selectedTab
        let location = MockLocations.randomLocation()
        _region = State(initialValue: MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
        _annotation = State(initialValue: MapAnnotation(coordinate: location))
    }
    
    var body: some View {
        ZStack {
            Image("mainBg")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if selectedTabBinding != nil {
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
                        
                        if onEdit != nil || onDelete != nil {
                            HStack(spacing: 0) {
                                if let onEdit = onEdit {
                                    Button(action: onEdit) {
                                        Image("edit")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 66, height: 63)
                                    }
                                }
                                
                                if let onDelete = onDelete {
                                    Button(action: onDelete) {
                                        Image("remove")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 66, height: 63)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 20)
                }
                
                ScrollView(showsIndicators: false) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 29)
                            .fill(Color(hex: "6A6361"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 29)
                                    .stroke(Color(hex: "5B5B5A"), lineWidth: 3)
                            )
                        
                        VStack(spacing: 0) {
                            ZStack(alignment: .topTrailing) {
                                if let photo = parking.photo, let uiImage = UIImage(data: photo) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: UIScreen.main.bounds.width - 80, height: 304)
                                        .clipped()
                                        .cornerRadius(21)
                                } else {
                                    Image("photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: UIScreen.main.bounds.width - 80, height: 304)
                                        .clipped()
                                        .cornerRadius(21)
                                }
                                
                                if onEdit != nil || onDelete != nil {
                                    HStack(spacing: 0) {
                                        if let onEdit = onEdit {
                                            Button(action: onEdit) {
                                                Image("edit")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 66, height: 63)
                                            }
                                        }
                                        
                                        if let onDelete = onDelete {
                                            Button(action: onDelete) {
                                                Image("remove")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 66, height: 63)
                                            }
                                        }
                                    }
                                    .padding(.top, 4)
                                    .padding(.trailing, 4)
                                }
                            }
                            .padding(.top, 8)
                            .padding(.horizontal, 8)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 8) {
                                    Image("calendar")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 37, height: 36)
                                    
                                    Text(formatDate(parking.date))
                                        .font(.custom("Montserrat-ExtraBold", size: 20))
                                        .foregroundColor(.white)
                                }
                                
                                HStack(spacing: 8) {
                                    Image("clock")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 37, height: 36)
                                    
                                    Text(formatTime(parking.date))
                                        .font(.custom("Montserrat-ExtraBold", size: 20))
                                        .foregroundColor(.white)
                                }
                                
                                HStack(spacing: 8) {
                                    Image("location")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 37, height: 36)
                                    
                                    Text(parking.address)
                                        .font(.custom("Montserrat-ExtraBold", size: 20))
                                        .foregroundColor(.white)
                                }
                                
                                if let notes = parking.notes, !notes.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Notes")
                                            .font(.custom("Montserrat-ExtraBold", size: 16))
                                            .foregroundColor(.white.opacity(0.5))
                                        
                                        Text(notes)
                                            .font(.custom("Montserrat-ExtraBold", size: 20))
                                            .foregroundColor(.white)
                                    }
                                    .padding(.top, 4)
                                }
                                
                                Map(coordinateRegion: $region, annotationItems: [annotation]) { item in
                                    MapMarker(coordinate: item.coordinate, tint: .blue)
                                }
                                .preferredColorScheme(.dark)
                                .frame(height: 200)
                                .cornerRadius(21)
                                .padding(.top, 16)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 8)
                            .padding(.top, 20)
                            .padding(.bottom, 32)
                        }
                        .padding(.horizontal, 8)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            showTabBar = false
        }
        .onDisappear {
            showTabBar = true
            if let selectedTabBinding = selectedTabBinding {
                DispatchQueue.main.async {
                    selectedTabBinding.wrappedValue = 0
                }
            }
        }
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

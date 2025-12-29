import SwiftUI
import MapKit
import PhotosUI

struct AddParkingView: View {
    @Binding var showTabBar: Bool
    @Environment(\.dismiss) var dismiss
    
    @State private var address: String = ""
    @State private var floorZone: String = ""
    @State private var notes: String = ""
    @State private var selectedPhoto: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    @State private var isLoading = false
    
    let onSave: (ParkingSpot) -> Void
    var existingParking: ParkingSpot?
    
    init(existingParking: ParkingSpot? = nil, showTabBar: Binding<Bool> = .constant(true), onSave: @escaping (ParkingSpot) -> Void) {
        self.existingParking = existingParking
        self._showTabBar = showTabBar
        self.onSave = onSave
        _address = State(initialValue: existingParking?.address ?? "")
        _floorZone = State(initialValue: existingParking?.floor ?? "")
        _notes = State(initialValue: existingParking?.notes ?? "")
        if let photoData = existingParking?.photo {
            _selectedPhoto = State(initialValue: UIImage(data: photoData))
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
                        saveParking()
                    }) {
                        Image(isFormValid ? "doneOn" : "done")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 88, height: 85)
                    }
                    .disabled(!isFormValid || isLoading)
                }
                .padding(.horizontal, 24)
                .padding(.top, 30)
                
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
                                if let photo = selectedPhoto {
                                    Image(uiImage: photo)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 189, height: 189)
                                        .clipShape(RoundedRectangle(cornerRadius: 21))
                                        .onTapGesture {
                                            showingImagePicker = true
                                        }
                                        .padding(.top, 20)
                                } else {
                                    Button(action: {
                                        showingImagePicker = true
                                    }) {
                                        Image("photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 189, height: 189)
                                    }
                                    .padding(.top, 20)
                                }
                                
                                VStack(spacing: 4) {
                                    ParkingTextField(placeholder: "Location", text: $address, onDelete: {
                                        address = ""
                                    })
                                    .onSubmit {
                                        hideKeyboard()
                                    }
                                    
                                    ParkingTextField(placeholder: "Floor / Zone", text: $floorZone, onDelete: {
                                        floorZone = ""
                                    })
                                    .onSubmit {
                                        hideKeyboard()
                                    }
                                    
                                    ParkingTextField(placeholder: "Notes", text: $notes, onDelete: {
                                        notes = ""
                                    })
                                    .onSubmit {
                                        hideKeyboard()
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.top, 8)
                                .padding(.bottom, 8)
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 20)
                    }
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            showTabBar = false
        }
        .onDisappear {
            showTabBar = true
        }
        .confirmationDialog("Select Photo", isPresented: $showingImagePicker) {
            Button("Camera") {
                showingCamera = true
            }
            Button("Photo Library") {
                showingPhotoLibrary = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showingCamera) {
            ParkingImagePicker(image: $selectedPhoto, sourceType: .camera)
        }
        .sheet(isPresented: $showingPhotoLibrary) {
            ParkingImagePicker(image: $selectedPhoto, sourceType: .photoLibrary)
        }
        .hideKeyboardOnTap()
    }
    
    private var isFormValid: Bool {
        let hasAddress = !address.isEmpty
        let hasFloorZone = !floorZone.isEmpty
        let hasNotes = !notes.isEmpty
        let hasPhoto = selectedPhoto != nil
        
        return hasAddress && hasFloorZone && hasNotes && hasPhoto
    }
    
    private func saveParking() {
        isLoading = true
        
        let photoData = selectedPhoto?.jpegData(compressionQuality: 0.7)
        
        let coord = existingParking?.location ?? MockLocations.randomLocation()
        
        let parking = ParkingSpot(
            id: existingParking?.id ?? UUID(),
            location: coord,
            address: address,
            floor: floorZone.isEmpty ? nil : floorZone,
            zone: nil,
            row: nil,
            photo: photoData,
            notes: notes.isEmpty ? nil : notes,
            date: existingParking?.date ?? Date()
        )
        
        onSave(parking)
        dismiss()
    }
}

struct ParkingTextField: View {
    let placeholder: String
    @Binding var text: String
    var onDelete: () -> Void = {}
    
    var body: some View {
        ZStack(alignment: .trailing) {
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.5)))
                .font(.custom("Montserrat-ExtraBold", size: 20))
                .foregroundColor(.white)
                .frame(height: 73)
                .padding(.leading, 16)
                .padding(.trailing, text.isEmpty ? 16 : 53)
                .background(Color(hex: "83817F"))
                .cornerRadius(21)
                .overlay(
                    RoundedRectangle(cornerRadius: 21)
                        .stroke(Color(hex: "5B5B5A"), lineWidth: 3)
                )
                .submitLabel(.done)
            
            if !text.isEmpty {
                Button(action: onDelete) {
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

struct ParkingImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ParkingImagePicker
        
        init(_ parent: ParkingImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }
    }
}

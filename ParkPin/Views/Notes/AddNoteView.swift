import SwiftUI
import PhotosUI

struct AddNoteView: View {
    @Environment(\.dismiss) var dismiss
    @State private var noteText: String = ""
    @State private var selectedPhotos: [UIImage] = []
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @Binding var showTabBar: Bool
    
    let existingNote: Note?
    let onSave: () -> Void
    
    init(existingNote: Note? = nil, showTabBar: Binding<Bool> = .constant(false), onSave: @escaping () -> Void) {
        self.existingNote = existingNote
        _showTabBar = showTabBar
        self.onSave = onSave
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
                        saveNote()
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
                
                ZStack {
                    RoundedRectangle(cornerRadius: 21)
                        .fill(Color(hex: "6A6361"))
                        .frame(height: 220)
                        .overlay(
                            RoundedRectangle(cornerRadius: 21)
                                .stroke(Color(hex: "383333"), lineWidth: 3)
                        )
                    
                    VStack(spacing: 0) {
                        VStack(spacing: 4) {
                            ZStack(alignment: .trailing) {
                                TextField("", text: $noteText, prompt: Text("Notes").foregroundColor(.white.opacity(0.5)))
                                    .font(.custom("Montserrat-ExtraBold", size: 20))
                                    .foregroundColor(.white)
                                    .frame(height: 73)
                                    .padding(.leading, 20)
                                    .padding(.trailing, noteText.isEmpty ? 20 : 53)
                                    .background(Color(hex: "83817F"))
                                    .cornerRadius(21)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 21)
                                            .stroke(Color(hex: "5B5B5A"), lineWidth: 3)
                                    )
                                    .submitLabel(.done)
                                
                                if !noteText.isEmpty {
                                    Button(action: {
                                        noteText = ""
                                    }) {
                                        Image("delete")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 32, height: 31)
                                    }
                                    .padding(.trailing, 16)
                                }
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 4) {
                                    if selectedPhotos.isEmpty {
                                        Menu {
                                            Button(action: {
                                                showingCamera = true
                                            }) {
                                                Label("Take Photo", systemImage: "camera")
                                            }
                                            
                                            Button(action: {
                                                showingImagePicker = true
                                            }) {
                                                Label("Choose Photo", systemImage: "photo.on.rectangle")
                                            }
                                        } label: {
                                            Image("photo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 122, height: 122)
                                        }
                                    } else {
                                        ForEach(selectedPhotos.indices, id: \.self) { index in
                                            Image(uiImage: selectedPhotos[index])
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 122, height: 122)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                    }
                                    
                                    Menu {
                                        Button(action: {
                                            showingCamera = true
                                        }) {
                                            Label("Take Photo", systemImage: "camera")
                                        }
                                        
                                        Button(action: {
                                            showingImagePicker = true
                                        }) {
                                            Label("Choose Photo", systemImage: "photo.on.rectangle")
                                        }
                                    } label: {
                                        Image("addIcon")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 60, height: 60)
                                    }
                                    .padding(.leading, selectedPhotos.isEmpty ? 4 : 0)
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8)
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            showTabBar = false
            if let note = existingNote {
                noteText = note.text
                selectedPhotos = note.photos.compactMap { UIImage(data: $0) }
            }
        }
        .onDisappear {
            showTabBar = true
        }
        .sheet(isPresented: $showingImagePicker) {
            PhotoLibraryPicker(selectedImages: $selectedPhotos)
        }
        .sheet(isPresented: $showingCamera) {
            CameraPickerView(selectedImage: Binding(
                get: { selectedPhotos.first },
                set: { if let image = $0 { selectedPhotos.append(image) } }
            ))
        }
        .hideKeyboardOnTap()
    }
    
    private var isFormValid: Bool {
        !noteText.isEmpty || !selectedPhotos.isEmpty
    }
    
    private func saveNote() {
        let photoData = selectedPhotos.compactMap { $0.jpegData(compressionQuality: 0.8) }
        
        if let existing = existingNote {
            let updatedNote = Note(
                id: existing.id,
                text: noteText,
                photos: photoData,
                date: existing.date,
                parkingSpotId: existing.parkingSpotId
            )
            NotesService.shared.updateNote(updatedNote)
        } else {
            let note = Note(text: noteText, photos: photoData)
            NotesService.shared.addNote(note)
        }
        
        onSave()
        dismiss()
    }
}

struct PhotoLibraryPicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 10
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoLibraryPicker
        
        init(_ parent: PhotoLibraryPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.selectedImages.append(image)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView
        
        init(_ parent: CameraPickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

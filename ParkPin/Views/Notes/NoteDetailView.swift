import SwiftUI

struct NoteDetailView: View {
    @Environment(\.dismiss) var dismiss
    let note: Note
    @State private var showDeleteAlert = false
    
    var body: some View {
        ZStack {
            Image("mainBg")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Text("Notes & Photos")
                        .font(.custom("Montserrat-ExtraBold", size: 25))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                    }) {
                        Image("copy")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 60)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 55)
                
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 29)
                        .fill(Color(hex: "6A6361"))
                        .frame(height: 290)
                        .overlay(
                            RoundedRectangle(cornerRadius: 29)
                                .stroke(Color(hex: "383333"), lineWidth: 3)
                        )
                    
                    VStack(spacing: 0) {
    
                        HStack(spacing: 0) {
                            Spacer()
                            
                            Button(action: {
                            }) {
                                Image("edit")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 61, height: 58)
                            }
                            
                            Button(action: {
                                showDeleteAlert = true
                            }) {
                                Image("remove")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 61, height: 58)
                            }
                        }
                        .padding(.top, 4)
                        .padding(.trailing, 4)
                        
                        if !note.photos.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(note.photos.indices, id: \.self) { index in
                                        if let image = UIImage(data: note.photos[index]) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 149, height: 149)
                                                .clipShape(RoundedRectangle(cornerRadius: 21))
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.top, 8)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.custom("Montserrat-ExtraBold", size: 20))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text(note.text)
                                .font(.custom("Montserrat-ExtraBold", size: 20))
                                .foregroundColor(.white)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .overlay {
            if showDeleteAlert {
                deleteAlertOverlay
            }
        }
    }
    
    private var deleteAlertOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    showDeleteAlert = false
                }
            
            VStack(spacing: 20) {
                Text("Delete")
                    .font(.custom("FontdinerSwanky", size: 35))
                    .foregroundColor(.white)
                
                Text("Do you want to delete this note?")
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
                            .frame(width: 120, height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        NotesService.shared.deleteNote(note)
                        showDeleteAlert = false
                        dismiss()
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
                    .stroke(Color(hex: "5B5B5B5A"), lineWidth: 3)
            )
            .padding(.horizontal, 32)
        }
    }
}


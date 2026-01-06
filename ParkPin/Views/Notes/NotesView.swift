import SwiftUI

struct NotesView: View {
    @ObservedObject private var notesService = NotesService.shared
    @State private var notes: [Note]
    @State private var showingAddNote = false
    @State private var showingEditNote = false
    @State private var showingNoteDetail = false
    @State private var showingHistory = false
    @State private var selectedNoteForDetail: Note?
    @State private var selectedNoteForEdit: Note?
    @State private var selectedNoteForDelete: Note?
    @State private var showDeleteAlert = false
    @Binding var showTabBar: Bool
    @Binding var selectedTab: Int
    
    init(showTabBar: Binding<Bool> = .constant(true), selectedTab: Binding<Int> = .constant(0)) {
        _showTabBar = showTabBar
        _selectedTab = selectedTab
        _notes = State(initialValue: NotesService.shared.getNotes())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("mainBg")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Image("notes")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 224, height: 132)
                        
                        Spacer()
                        
                        Button(action: {
                            showingHistory = true
                        }) {
                            Image("history")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 87, height: 78)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    if notes.isEmpty {
                        Spacer()
                        
                        NavigationLink(destination: AddNoteView(showTabBar: $showTabBar) {
                            loadNotes()
                            showingAddNote = false
                        }) {
                            emptyStateView
                        }
                        .buttonStyle(.plain)
                        .offset(y: -82)
                        
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(notes) { note in
                                    NoteCard(
                                        note: note,
                                        onTap: {
                                            selectedNoteForDetail = note
                                            showingNoteDetail = true
                                        },
                                        onEdit: {
                                            selectedNoteForEdit = note
                                            showingEditNote = true
                                        },
                                        onDelete: {
                                            selectedNoteForDelete = note
                                            showDeleteAlert = true
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationBarHidden(true)
            .onAppear {
                loadNotes()
                showTabBar = true
            }
            .navigationDestination(isPresented: $showingAddNote) {
                AddNoteView(showTabBar: $showTabBar) {
                    loadNotes()
                    showingAddNote = false
                }
                .navigationBarHidden(true)
            }
            .navigationDestination(isPresented: $showingNoteDetail) {
                if let note = selectedNoteForDetail {
                    NoteDetailView(note: note)
                        .navigationBarHidden(true)
                        .onDisappear {
                            selectedNoteForDetail = nil
                        }
                }
            }
            .navigationDestination(isPresented: $showingEditNote) {
                if let note = selectedNoteForEdit {
                    AddNoteView(existingNote: note, showTabBar: $showTabBar) {
                        loadNotes()
                        showingEditNote = false
                        selectedNoteForEdit = nil
                    }
                    .navigationBarHidden(true)
                }
            }
            .navigationDestination(isPresented: $showingHistory) {
                HistoryView(showTabBar: $showTabBar, selectedTab: $selectedTab)
                    .navigationBarHidden(true)
            }
            .overlay {
                if showDeleteAlert {
                    deleteAlertOverlay
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 29)
                .fill(Color(hex: "6A6361"))
                .frame(height: 266)
                .overlay(
                    RoundedRectangle(cornerRadius: 29)
                        .stroke(Color(hex: "5B5B5A"), lineWidth: 3)
                )
            
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text("No notes or photos yet")
                        .font(.custom("Montserrat-ExtraBold", size: 25))
                        .foregroundColor(.white)
                        .lineSpacing(0)
                        .kerning(-0.41)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Add details like landmarks or special instructions for your parking spot")
                        .font(.custom("Montserrat-ExtraBold", size: 16))
                        .foregroundColor(.white.opacity(0.5))
                        .lineSpacing(0)
                        .kerning(-0.41)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 40)
                .padding(.horizontal, 20)
                
                Spacer()
                
                Image("addIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 84)
                    .padding(.bottom, 20)
            }
            .frame(height: 266)
        }
        .padding(.horizontal, 32)
    }
    
    private func loadNotes() {
        notes = notesService.getNotes()
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
                        if let note = selectedNoteForDelete {
                            notesService.deleteNote(note)
                            loadNotes()
                            showDeleteAlert = false
                            selectedNoteForDelete = nil
                        }
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
}

struct NoteCard: View {
    let note: Note
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 29)
                .fill(Color(hex: "6A6361"))
                .frame(height: 290)
                .overlay(
                    RoundedRectangle(cornerRadius: 29)
                        .stroke(Color(hex: "5B5B5A"), lineWidth: 3)
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    onTap()
                }
            
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Spacer()
                    
                    Button(action: {
                        onEdit()
                    }) {
                        Image("edit")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 46)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        onDelete()
                    }) {
                        Image("remove")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 46)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 16)
                .padding(.trailing, 16)
                
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
                    .padding(.top, 12)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Notes")
                        .font(.custom("Montserrat-ExtraBold", size: 16))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text(note.text)
                        .font(.custom("Montserrat-ExtraBold", size: 20))
                        .foregroundColor(.white)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, note.photos.isEmpty ? 12 : 12)
                
                Spacer()
            }
        }
    }
}


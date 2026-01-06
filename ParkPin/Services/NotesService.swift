import Foundation
import Combine

class NotesService: ObservableObject {
    static let shared = NotesService()
    
    private let notesKey = "parkingNotes"
    private let maxNotesCount = 10
    
    private init() {}
    
    func saveNotes(_ notes: [Note]) {
        let limitedNotes = Array(notes.prefix(maxNotesCount))
        if let encoded = try? JSONEncoder().encode(limitedNotes) {
            UserDefaults.standard.set(encoded, forKey: notesKey)
        }
    }
    
    func getNotes() -> [Note] {
        guard let data = UserDefaults.standard.data(forKey: notesKey),
              let notes = try? JSONDecoder().decode([Note].self, from: data) else {
            return []
        }
        return notes
    }
    
    func addNote(_ note: Note) {
        var notes = getNotes()
        notes.insert(note, at: 0)
        if notes.count > maxNotesCount {
            notes = Array(notes.prefix(maxNotesCount))
        }
        saveNotes(notes)
    }
    
    func updateNote(_ note: Note) {
        var notes = getNotes()
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            saveNotes(notes)
        }
    }
    
    func deleteNote(_ note: Note) {
        var notes = getNotes()
        notes.removeAll { $0.id == note.id }
        saveNotes(notes)
    }
    
    func clearAllData() {
        UserDefaults.standard.removeObject(forKey: notesKey)
    }
}


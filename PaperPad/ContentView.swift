
import SwiftUI
import WidgetKit

struct PaperNote: Identifiable, Codable {
    var id = UUID()
    var text: String
    var isCompleted = false
}

struct PaperPage: Identifiable, Codable {
    var id = UUID()
    var notes: [PaperNote] = []
}

struct ContentView: View {
    @State private var noteText = ""
    @State private var pages: [PaperPage] = [PaperPage()]
    @State private var currentPageIndex = 0
    @State private var recentlyDeletedNote: PaperNote? = nil
    @State private var deletedNotePageIndex: Int? = nil
    @State private var deletedNoteIndex: Int? = nil
    @State private var undoToken = UUID()
    @State private var editingNoteID: UUID? = nil
    @State private var editingText = ""



    private let notesPerPage = 8
    private let storageKey = "PaperPad.savedNotes"
    private let appGroupID =
        "group.com.koshymammoottillmathew.PaperPad"

    private let paperColor = Color(
        red: 1.0,
        green: 0.97,
        blue: 0.78
    )

    private let inkColor = Color(
        red: 0.24,
        green: 0.22,
        blue: 0.16
    )

    var body: some View {
        ZStack {
            paperColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                Rectangle()
                    .fill(inkColor.opacity(0.16))
                    .frame(height: 1)
                    .padding(.top, 18)

                inputArea
                    .padding(.top, 18)

                Divider()
                    .overlay(inkColor.opacity(0.15))
                    .padding(.vertical, 12)

                notesArea

                Spacer(minLength: 12)

                pageNavigation
                
                if recentlyDeletedNote != nil {
                    HStack {
                        Text("Note deleted")
                            .font(.system(size: 14))

                        Spacer()

                        Button("Undo", action: undoDelete)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(inkColor)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.top, 10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 12)
        }
        
        .foregroundStyle(inkColor)
        .onAppear(perform: loadPages)
        .sheet(
            isPresented: Binding(
                get: { editingNoteID != nil },
                set: { if !$0 { editingNoteID = nil } }
            )
        ) {
            editNoteSheet
        }

    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 5) {
                Text("PaperPad")
                    .font(.system(
                        size: 30,
                        weight: .bold,
                        design: .rounded
                    ))

                Text("A little space for your thoughts.")
                    .font(.system(size: 12))
                    .foregroundStyle(inkColor.opacity(0.65))
            }

            Spacer()

            Image(systemName: "note.text")
                .font(.system(size: 23, weight: .medium))
                .frame(width: 48, height: 48)
                .background(.white.opacity(0.38))
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }

    private var inputArea: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "pencil.line")

                Text("ADD A THOUGHT")
                    .font(.caption.weight(.bold))
                    .tracking(1.5)
            }
            .foregroundStyle(inkColor.opacity(0.65))

            TextField(
                "What would you like to remember?",
                text: $noteText,
                axis: .vertical
            )
            .font(.system(size: 16))
            .lineLimit(1...4)
            .padding(14)
            .background(.white.opacity(0.42))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(inkColor.opacity(0.08), lineWidth: 1)
            }

            Button(action: addNote) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Add note")
                }
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(inkColor)
                .foregroundStyle(paperColor)
                .clipShape(RoundedRectangle(cornerRadius: 13))
            }
            .buttonStyle(.plain)
            .disabled(
                noteText.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty
            )
            .opacity(
                noteText.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty ? 0.5 : 1
            )
        }
    }
    
    
    private var editNoteSheet: some View {
        NavigationStack {
            Form {
                Section("Edit your note") {
                    TextField(
                        "Note text",
                        text: $editingText,
                        axis: .vertical
                    )
                    .lineLimit(3...8)
                }
            }
            .navigationTitle("Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        editingNoteID = nil
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveEditedNote)
                        .disabled(
                            editingText.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ).isEmpty
                        )
                }
            }
        }
    }


    private var notesArea: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("YOUR NOTES")
                    .font(.caption.weight(.bold))
                    .tracking(1.5)

                Spacer()

                Text("\(pages[currentPageIndex].notes.count) notes")
                    .font(.caption)
                    .foregroundStyle(inkColor.opacity(0.6))
            }

            if pages[currentPageIndex].notes.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "leaf")
                        .font(.system(size: 28))

                    Text("A fresh page")
                        .font(.system(size: 18, weight: .semibold))

                    Text("Your next thought belongs here.")
                        .font(.system(size: 13))
                        .foregroundStyle(inkColor.opacity(0.65))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(20)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(pages[currentPageIndex].notes) { note in
                            Button {
                                toggleNote(note)
                            } label: {
                                HStack(
                                    alignment: .top,
                                    spacing: 12
                                ) {
                                    Image(
                                        systemName: note.isCompleted
                                            ? "checkmark.circle.fill"
                                            : "circle"
                                    )
                                    .font(.system(size: 19))
                                    .foregroundStyle(
                                        note.isCompleted
                                            ? inkColor.opacity(0.5)
                                            : inkColor.opacity(0.6)
                                    )
                                    .padding(.top, 2)

                                    Text(note.text)
                                        .font(.system(size: 16))
                                        .strikethrough(
                                            note.isCompleted,
                                            color: inkColor.opacity(0.65)
                                        )
                                        .foregroundStyle(
                                            inkColor.opacity(
                                                note.isCompleted ? 0.5 : 1
                                            )
                                        )
                                        .frame(
                                            maxWidth: .infinity,
                                            alignment: .leading
                                        )
                                        .fixedSize(
                                            horizontal: false,
                                            vertical: true
                                        )
                                    
                                    Button {
                                        editingNoteID = note.id
                                        editingText = note.text
                                    } label: {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(inkColor.opacity(0.65))
                                            .padding(6)
                                            .background(.white.opacity(0.35))
                                            .clipShape(RoundedRectangle(cornerRadius: 7))
                                    }
                                    .buttonStyle(.plain)

                                }
                                .padding(.vertical, 15)
                                .padding(.horizontal, 12)
                                .frame(maxWidth: .infinity)
                                .background {
                                    ZStack(alignment: .bottom) {
                                        Color.white.opacity(
                                            note.isCompleted ? 0.12 : 0.25
                                        )

                                        Rectangle()
                                            .fill(inkColor.opacity(0.08))
                                            .frame(height: 1)
                                    }
                                }
                                .contentShape(Rectangle())
                            }
                            
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    deleteNote(note)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .fill(inkColor.opacity(0.10))
                                    .frame(height: 1)
                            }

                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var pageNavigation: some View {
        HStack {
            Button {
                if currentPageIndex > 0 {
                    currentPageIndex -= 1
                }
            } label: {
                Label("Previous", systemImage: "chevron.left")
                    .font(.system(size: 13, weight: .medium))
            }
            .disabled(currentPageIndex == 0)

            Spacer()

            Text("PAGE \(currentPageIndex + 1) OF \(pages.count)")
                .font(.system(size: 11, weight: .bold))
                .tracking(1)
                .foregroundStyle(inkColor.opacity(0.65))

            Spacer()

            Button {
                if currentPageIndex < pages.count - 1 {
                    currentPageIndex += 1
                }
            } label: {
                HStack(spacing: 5) {
                    Text("Next")
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: 13, weight: .medium))
            }
            .disabled(currentPageIndex >= pages.count - 1)
        }
        .buttonStyle(.plain)
        .padding(.top, 12)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(inkColor.opacity(0.15))
                .frame(height: 1)
        }
    }

    private func loadPages() {
        guard let sharedDefaults = UserDefaults(
            suiteName: appGroupID
        ) else {
            return
        }

        // Load from shared storage first.
        if let sharedData = sharedDefaults.data(forKey: storageKey) {
            decodePages(from: sharedData)
            return
        }

        // Migrate data saved by the earlier version of PaperPad.
        if let oldData = UserDefaults.standard.data(forKey: storageKey) {
            sharedDefaults.set(oldData, forKey: storageKey)
            decodePages(from: oldData)
        }
    }

    private func decodePages(from data: Data) {
        let decoder = JSONDecoder()

        if let savedPages = try? decoder.decode(
            [PaperPage].self,
            from: data
        ) {
            pages = savedPages.isEmpty ? [PaperPage()] : savedPages
            currentPageIndex = pages.count - 1
            return
        }

        if let savedNotes = try? decoder.decode(
            [PaperNote].self,
            from: data
        ) {
            pages = []

            for note in savedNotes {
                if pages.isEmpty ||
                    pages[pages.count - 1].notes.count >= notesPerPage {
                    pages.append(PaperPage())
                }

                pages[pages.count - 1].notes.append(note)
            }

            if pages.isEmpty {
                pages = [PaperPage()]
            }

            currentPageIndex = pages.count - 1
            savePages()
        }
    }

    private func savePages() {
        guard let data = try? JSONEncoder().encode(pages) else {
            return
        }

        UserDefaults(suiteName: appGroupID)?.set(
            data,
            forKey: storageKey
        )
        WidgetCenter.shared.reloadTimelines(ofKind: "PaperPadWidget")
    }

    private func addNote() {
        let cleanedText = noteText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanedText.isEmpty else {
            return
        }

        currentPageIndex = pages.count - 1

        if pages[currentPageIndex].notes.count >= notesPerPage {
            pages.append(PaperPage())
            currentPageIndex = pages.count - 1
        }

        pages[currentPageIndex].notes.append(
            PaperNote(text: cleanedText)
        )

        savePages()
        noteText = ""
    }

    
    private func toggleNote(_ selectedNote: PaperNote) {
        guard let index = pages[currentPageIndex].notes.firstIndex(
            where: { $0.id == selectedNote.id }
        ) else { return }

        withAnimation(.easeInOut(duration: 0.2)) {
            pages[currentPageIndex].notes[index].isCompleted.toggle()
        }

        savePages()
    }
    
    
    private func saveEditedNote() {
        guard let noteID = editingNoteID else { return }

        let cleanedText = editingText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanedText.isEmpty else { return }

        for pageIndex in pages.indices {
            if let noteIndex = pages[pageIndex].notes.firstIndex(
                where: { $0.id == noteID }
            ) {
                pages[pageIndex].notes[noteIndex].text = cleanedText
                savePages()
                editingNoteID = nil
                editingText = ""
                return
            }
        }

        editingNoteID = nil
        editingText = ""
    }

    
    private func deleteNote(_ selectedNote: PaperNote) {
        guard let noteIndex = pages[currentPageIndex].notes.firstIndex(
            where: { $0.id == selectedNote.id }
        ) else { return }

        recentlyDeletedNote = pages[currentPageIndex].notes[noteIndex]
        deletedNotePageIndex = currentPageIndex
        deletedNoteIndex = noteIndex

        let currentToken = UUID()
        undoToken = currentToken

        withAnimation(.easeInOut(duration: 0.2)) {
            pages[currentPageIndex].notes.remove(at: noteIndex)
            recentlyDeletedNote = pages[currentPageIndex].notes.isEmpty
                ? recentlyDeletedNote
                : recentlyDeletedNote
        }

        savePages()

        Task {
            try? await Task.sleep(for: .seconds(5))

            guard undoToken == currentToken else { return }

            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.2)) {
                    recentlyDeletedNote = nil
                    deletedNotePageIndex = nil
                    deletedNoteIndex = nil
                }
            }
        }
    }

    
    
    private func undoDelete() {
        guard
            let note = recentlyDeletedNote,
            let pageIndex = deletedNotePageIndex,
            let noteIndex = deletedNoteIndex
        else { return }

        // Make sure the original page still exists.
        guard pages.indices.contains(pageIndex) else { return }

        // Restore the note at its original position.
        let safeIndex = min(noteIndex, pages[pageIndex].notes.count)
        pages[pageIndex].notes.insert(note, at: safeIndex)

        // Return to the page containing the restored note.
        currentPageIndex = pageIndex

        // Clear the saved deletion.
        recentlyDeletedNote = nil
        deletedNotePageIndex = nil
        deletedNoteIndex = nil
        undoToken = UUID()
        savePages()
    }


}

#Preview {
    ContentView()
}


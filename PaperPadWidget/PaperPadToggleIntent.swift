
import AppIntents
import WidgetKit
import Foundation

struct PaperPadToggleIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle PaperPad Note"
    static var description = IntentDescription(
        "Mark a PaperPad note as complete or incomplete."
    )

    @Parameter(title: "Note ID")
    var noteID: String

    init() {
        self.noteID = ""
    }

    init(noteID: String) {
        self.noteID = noteID
    }

    func perform() async throws -> some IntentResult {
        let appGroupID = "group.com.koshymammoottillmathew.PaperPad"
        let storageKey = "PaperPad.savedNotes"

        guard
            let defaults = UserDefaults(suiteName: appGroupID),
            let data = defaults.data(forKey: storageKey)
        else {
            return .result()
        }

        let decoder = JSONDecoder()

        guard var pages = try? decoder.decode(
            [TogglePage].self,
            from: data
        ) else {
            return .result()
        }

        for pageIndex in pages.indices {
            if let noteIndex = pages[pageIndex].notes.firstIndex(
                where: { $0.id.uuidString == noteID }
            ) {
                pages[pageIndex].notes[noteIndex].isCompleted.toggle()

                let encoder = JSONEncoder()
                if let updatedData = try? encoder.encode(pages) {
                    defaults.set(updatedData, forKey: storageKey)
                }

                WidgetCenter.shared.reloadTimelines(
                    ofKind: "PaperPadWidget"
                )

                break
            }
        }

        return .result()
    }
}

private struct TogglePage: Codable {
    var id: UUID
    var notes: [ToggleNote]
}

private struct ToggleNote: Codable {
    var id: UUID
    var text: String
    var isCompleted: Bool
}

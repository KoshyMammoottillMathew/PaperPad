import WidgetKit
import SwiftUI
import AppIntents

private let appGroupID = "group.com.koshymammoottillmathew.PaperPad"
private let storageKey = "PaperPad.savedNotes"

struct PaperPadWidgetEntry: TimelineEntry {
    let date: Date
    let notes: [WidgetNote]
    let family: WidgetFamily
}

struct WidgetNote: Identifiable {
    let id: UUID
    let text: String
    let isCompleted: Bool
}

struct PaperPadWidgetProvider: TimelineProvider {

    func placeholder(in context: Context) -> PaperPadWidgetEntry {
        PaperPadWidgetEntry(
            date: Date(),
            notes: [
                WidgetNote(
                    id: UUID(),
                    text: "Welcome to PaperPad",
                    isCompleted: false
                ),
                WidgetNote(
                    id: UUID(),
                    text: "Your notes appear here",
                    isCompleted: false
                )
            ],
            family: context.family
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (PaperPadWidgetEntry) -> Void
    ) {
        completion(makeEntry(for: context.family))
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<PaperPadWidgetEntry>) -> Void
    ) {
        let entry = makeEntry(for: context.family)

        let nextUpdate = Calendar.current.date(
            byAdding: .minute,
            value: 15,
            to: Date()
        ) ?? Date().addingTimeInterval(900)

        completion(
            Timeline(
                entries: [entry],
                policy: .after(nextUpdate)
            )
        )
    }

    private func makeEntry(
        for family: WidgetFamily
    ) -> PaperPadWidgetEntry {
        let defaults = UserDefaults(suiteName: appGroupID)
        var notes: [WidgetNote] = []

        if let data = defaults?.data(forKey: storageKey),
           let pages = try? JSONDecoder().decode(
               [WidgetPage].self,
               from: data
           ) {
            notes = pages.flatMap { $0.notes }.map {
                WidgetNote(
                    id: $0.id,
                    text: $0.text,
                    isCompleted: $0.isCompleted
                )
            }
        }

        let noteLimit = family == .systemLarge ? 12 : 4

        return PaperPadWidgetEntry(
            date: Date(),
            notes: Array(notes.prefix(noteLimit)),
            family: family
        )
    }
}

private struct WidgetPage: Decodable {
    let notes: [WidgetNoteData]
}

private struct WidgetNoteData: Decodable {
    let id: UUID
    let text: String
    let isCompleted: Bool
}

struct PaperPadWidgetEntryView: View {
    var entry: PaperPadWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "note.text")
                    .font(.headline)

                Text("PaperPad")
                    .font(
                        .system(
                            size: 17,
                            weight: .bold,
                            design: .rounded
                        )
                    )

                Spacer(minLength: 0)
            }
            .foregroundStyle(.black)

            Rectangle()
                .fill(Color.black.opacity(0.15))
                .frame(height: 1)

            if entry.notes.isEmpty {
                Spacer(minLength: 4)

                Image(systemName: "pencil.line")
                    .font(.title2)
                    .foregroundStyle(.black.opacity(0.45))
                    .frame(maxWidth: .infinity)

                Text("Your next idea starts here.")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(.black.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                Spacer(minLength: 4)
            } else {
                ForEach(entry.notes) { note in
                    Button(
                        intent: PaperPadToggleIntent(
                            noteID: note.id.uuidString
                        )
                    ) {
                        HStack(alignment: .top, spacing: 7) {
                            Image(
                                systemName: note.isCompleted
                                    ? "checkmark.circle.fill"
                                    : "circle"
                            )
                            .font(.system(size: 12))
                            .foregroundStyle(
                                note.isCompleted
                                    ? .gray
                                    : .black.opacity(0.75)
                            )
                            .padding(.top, 2)

                            Text(note.text)
                                .font(
                                    .system(
                                        size: 12,
                                        design: .rounded
                                    )
                                )
                                .foregroundStyle(
                                    note.isCompleted
                                        ? .black.opacity(0.45)
                                        : .black.opacity(0.9)
                                )
                                .strikethrough(note.isCompleted)
                                .lineLimit(2)
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: 0)
            }
        }
        .padding(12)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .background(
            Color(red: 1.0, green: 0.96, blue: 0.72)
        )
    }
}

struct PaperPadWidget: Widget {
    let kind = "PaperPadWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: PaperPadWidgetProvider()
        ) { entry in
            PaperPadWidgetEntryView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge
        ])
        .configurationDisplayName("PaperPad Notes")
        .description("View your saved PaperPad notes.")
    }
}

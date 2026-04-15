import SwiftUI
import WidgetKit

struct NextStepEntry: TimelineEntry {
    let date: Date
    let snapshot: ExternalSurfaceSnapshot?
}

struct NextStepProvider: TimelineProvider {
    private let reader = ExtensionExternalSurfaceSnapshotReader()

    func placeholder(in context: Context) -> NextStepEntry {
        NextStepEntry(
            date: .now,
            snapshot: ExternalSurfaceSnapshot(
                generatedAt: "2026-01-01T00:00:00Z",
                nextAction: ExternalSurfaceNextAction(
                    goalID: "goal-placeholder",
                    stepID: "step-placeholder",
                    display: ExternalSurfaceDisplayMetadata(
                        templateKey: "next_tiny_step",
                        goalMode: .project,
                        stepState: .planned,
                        urgency: .normal,
                        timing: .deadline
                    )
                )
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (NextStepEntry) -> Void) {
        let snapshot = reader.loadSnapshot()
        completion(NextStepEntry(date: .now, snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NextStepEntry>) -> Void) {
        let snapshot = reader.loadSnapshot()
        let entry = NextStepEntry(date: .now, snapshot: snapshot)
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now.addingTimeInterval(900)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct NextStepWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "AmbitionsNextStepWidget", provider: NextStepProvider()) { entry in
            NextStepWidgetView(entry: entry)
        }
        .configurationDisplayName("Next Step")
        .description("Shows your current next-step context from the shared snapshot export.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

private struct NextStepWidgetView: View {
    let entry: NextStepEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ambitions")
                .font(.caption)
                .foregroundStyle(.secondary)

            if let next = entry.snapshot?.nextAction {
                Text("Next step ready")
                    .font(.headline)
                Text(urgencyLabel(next.display.urgency))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Goal \(next.goalID.prefix(8))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            } else {
                Text("No next step")
                    .font(.headline)
                Text("Open Ambitions to refresh your plan.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding()
        .widgetURL(widgetURL())
    }

    private func urgencyLabel(_ urgency: ExternalSurfaceUrgency) -> String {
        switch urgency {
        case .overdue:
            return "Needs attention"
        case .soon:
            return "Coming up soon"
        case .normal:
            return "In progress"
        case .anytime:
            return "Flexible timing"
        }
    }

    private func widgetURL() -> URL? {
        guard let goalID = entry.snapshot?.nextAction?.goalID else {
            return URL(string: "ambitions://tab/today")
        }
        return URL(string: "ambitions://goal/\(goalID)")
    }
}

private struct ExtensionExternalSurfaceSnapshotReader {
    func loadSnapshot() -> ExternalSurfaceSnapshot? {
        let fileURL = SharedExternalSnapshotStore.snapshotFileURL()
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(ExternalSurfaceSnapshot.self, from: data)
    }
}

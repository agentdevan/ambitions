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
                ),
                nowState: ExternalSurfaceNowState(
                    todayPosture: .active,
                    pressureLevel: .steady,
                    bestNextStep: ExternalSurfaceActionReference(goalID: "goal-placeholder", stepID: "step-placeholder"),
                    activeFocus: nil,
                    openCaptureUrgency: .none,
                    blockerSummary: ExternalSurfaceBlockerSummary(waitingCount: 0, blockedCount: 0),
                    supportedCommands: [
                        ExternalSurfaceCommandDescriptor(kind: .openToday, requiresGoalID: false, requiresStepID: false),
                    ]
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
        let glance = ExternalSurfaceGlanceState(snapshot: entry.snapshot)

        VStack(alignment: .leading, spacing: 8) {
            Text("Ambitions")
                .font(.caption)
                .foregroundStyle(.secondary)

            if glance.primaryReference != nil {
                Text(title(for: glance))
                    .font(.headline)
                Text(detail(for: glance))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(pressureLabel(glance.pressureLevel))
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
        .widgetURL(glance.primaryURL)
    }

    private func title(for glance: ExternalSurfaceGlanceState) -> String {
        if let ritualCue = glance.ritualCue {
            return ritualTitle(for: ritualCue.kind)
        }
        switch glance.todayPosture {
        case .empty:
            return "No next step"
        case .active:
            return "Next step ready"
        case .waiting:
            return "Waiting on a blocker"
        case .recovery:
            return "Recovery step ready"
        }
    }

    private func detail(for glance: ExternalSurfaceGlanceState) -> String {
        if let ritualCue = glance.ritualCue {
            switch ritualCue.kind {
            case .morningSetup:
                return "One next move is ready."
            case .middayReset:
                return ritualCue.progressState == .needsReset ? "A smaller reset is ready." : "The next move still fits."
            case .eveningClose:
                return "Close the loop in Today."
            case .weeklyReset:
                return "Review the week in Today."
            }
        }
        switch glance.todayPosture {
        case .waiting:
            return "Open Ambitions for the safest next move."
        case .empty:
            return "Open Ambitions to refresh your plan."
        case .active, .recovery:
            return urgencyLabel(glance.urgency)
        }
    }

    private func ritualTitle(for kind: ExternalSurfaceRitualKind) -> String {
        switch kind {
        case .morningSetup:
            return "Morning setup"
        case .middayReset:
            return "Midday reset"
        case .eveningClose:
            return "Evening close"
        case .weeklyReset:
            return "Weekly reset"
        }
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

    private func pressureLabel(_ pressure: ExternalSurfacePressureLevel) -> String {
        switch pressure {
        case .open:
            return "Open"
        case .steady:
            return "Steady"
        case .elevated:
            return "Elevated pressure"
        case .overloaded:
            return "Needs triage"
        }
    }
}

private struct ExtensionExternalSurfaceSnapshotReader {
    func loadSnapshot() -> ExternalSurfaceSnapshot? {
        let fileURL = SharedExternalSnapshotStore.snapshotFileURL()
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(ExternalSurfaceSnapshot.self, from: data)
    }
}

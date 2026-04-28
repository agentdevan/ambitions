import SwiftUI
import WidgetKit

struct NextStepEntry: TimelineEntry {
    let date: Date
    let snapshot: ExternalSurfaceSnapshot?
    let family: WidgetFamily
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
                        ExternalSurfaceCommandDescriptor(kind: .openMemoryLens, requiresGoalID: false, requiresStepID: false),
                    ]
                ),
                ambientState: ExternalSurfaceAmbientState(
                    today: ExternalSurfaceVariantState(
                        kind: .today,
                        title: "Today has a next move",
                        detail: "Your next move still looks doable.",
                        privacySummary: "Glance-safe next move only",
                        action: ExternalSurfaceVariantAction(title: "Open Today", surface: .tab, tab: "today"),
                        reference: ExternalSurfaceActionReference(goalID: "goal-placeholder", stepID: "step-placeholder"),
                        prominence: .standard
                    ),
                    focus: ExternalSurfaceVariantState(
                        kind: .focus,
                        title: "Focus time ready",
                        detail: "A small focus step is available.",
                        privacySummary: "Details stay inside Ambitions",
                        action: ExternalSurfaceVariantAction(title: "Open Focus", surface: .tab, tab: "today"),
                        reference: ExternalSurfaceActionReference(goalID: "goal-placeholder", stepID: "step-placeholder"),
                        prominence: .elevated
                    ),
                    goal: ExternalSurfaceVariantState(
                        kind: .goal,
                        title: "1 active goal",
                        detail: "Progress comes from your local plan.",
                        privacySummary: "Goal names stay private here",
                        action: ExternalSurfaceVariantAction(title: "Open Goals", surface: .tab, tab: "goals"),
                        reference: ExternalSurfaceActionReference(goalID: "goal-placeholder", stepID: "step-placeholder"),
                        prominence: .standard
                    ),
                    plan: ExternalSurfaceVariantState(
                        kind: .plan,
                        title: "Week looks doable",
                        detail: "Open Plan to adjust the week from your latest local state.",
                        privacySummary: "Plan detail opens in app",
                        action: ExternalSurfaceVariantAction(title: "Open Plan", surface: .tab, tab: "plan"),
                        reference: ExternalSurfaceActionReference(goalID: "goal-placeholder", stepID: "step-placeholder"),
                        prominence: .standard
                    )
                ),
                continuity: .localFirst(generatedAt: "2026-01-01T00:00:00Z")
            ),
            family: context.family
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (NextStepEntry) -> Void) {
        let snapshot = reader.loadSnapshot()
        completion(NextStepEntry(date: .now, snapshot: snapshot, family: context.family))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NextStepEntry>) -> Void) {
        let snapshot = reader.loadSnapshot()
        let entry = NextStepEntry(date: .now, snapshot: snapshot, family: context.family)
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
        .description("Shows a glance-safe Ambitions surface from your latest local state.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryInline, .accessoryCircular, .accessoryRectangular])
    }
}

private struct NextStepWidgetView: View {
    let entry: NextStepEntry

    var body: some View {
        let glance = ExternalSurfaceGlanceState(snapshot: entry.snapshot)
        let variants = variants(for: glance)

        Group {
            switch entry.family {
            case .accessoryInline:
                Text("\(title(for: glance)) · \(glance.continuity.lease.freshnessLabel)")
            case .accessoryCircular:
                circularView(glance: glance)
            case .accessoryRectangular:
                rectangularLockView(glance: glance)
            case .systemMedium:
                mediumView(glance: glance, variants: variants)
            case .systemLarge:
                largeView(glance: glance, variants: variants)
            default:
                smallView(glance: glance)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(glance.primaryURL)
    }

    private func smallView(glance: ExternalSurfaceGlanceState) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            surfaceHeader(icon: "scope", label: "Ambitions")
            Spacer(minLength: 0)
            Text(title(for: glance))
                .font(.headline.weight(.semibold))
                .lineLimit(3)
            Text(detail(for: glance))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)
            trustLine(glance: glance)
        }
        .padding()
        .background(widgetGradient(glance: glance))
    }

    private func mediumView(glance: ExternalSurfaceGlanceState, variants: [ExternalSurfaceVariantState]) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                surfaceHeader(icon: "scope", label: "Ambitions")
                Text(title(for: glance))
                    .font(.headline.weight(.semibold))
                    .lineLimit(2)
                Text(detail(for: glance))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                trustLine(glance: glance)
            }
            Spacer(minLength: 0)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(variants.prefix(2), id: \.kind.rawValue) { variant in
                    variantRow(variant)
                }
            }
            .frame(maxWidth: 150, alignment: .leading)
        }
        .padding()
        .background(widgetGradient(glance: glance))
    }

    private func largeView(glance: ExternalSurfaceGlanceState, variants: [ExternalSurfaceVariantState]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            surfaceHeader(icon: "sparkles", label: "Ambitions")
            Text(title(for: glance))
                .font(.title3.weight(.semibold))
                .lineLimit(2)
            Text(detail(for: glance))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            VStack(spacing: 8) {
                ForEach(variants, id: \.kind.rawValue) { variant in
                    variantRow(variant)
                }
            }
            Spacer(minLength: 0)
            trustLine(glance: glance)
        }
        .padding()
        .background(widgetGradient(glance: glance))
    }

    private func rectangularLockView(glance: ExternalSurfaceGlanceState) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title(for: glance))
                .font(.headline)
                .lineLimit(1)
            Text(lockDetail(for: glance))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
    }

    private func circularView(glance: ExternalSurfaceGlanceState) -> some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Image(systemName: icon(for: glance))
                    .font(.headline)
                Text(shortPressure(glance.pressureLevel))
                    .font(.caption2.weight(.semibold))
            }
        }
    }

    private func surfaceHeader(icon: String, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(label)
            Spacer(minLength: 0)
        }
        .font(.caption2.weight(.semibold))
        .foregroundStyle(.secondary)
    }

    private func variantRow(_ variant: ExternalSurfaceVariantState) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon(for: variant.kind))
                .font(.caption.weight(.semibold))
                .frame(width: 18, height: 18)
                .background(.quaternary, in: Circle())
            VStack(alignment: .leading, spacing: 1) {
                Text(variant.title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                Text(variant.privacySummary)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }

    private func trustLine(glance: ExternalSurfaceGlanceState) -> some View {
        Text("\(glance.continuity.syncHealth.label) · \(glance.continuity.lease.freshnessLabel)")
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .lineLimit(1)
    }

    private func widgetGradient(glance: ExternalSurfaceGlanceState) -> LinearGradient {
        let warm = Color(red: 0.96, green: 0.72, blue: 0.42).opacity(glance.pressureLevel == .overloaded ? 0.30 : 0.18)
        return LinearGradient(
            colors: [Color(red: 0.08, green: 0.10, blue: 0.12), Color(red: 0.13, green: 0.16, blue: 0.18), warm],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func variants(for glance: ExternalSurfaceGlanceState) -> [ExternalSurfaceVariantState] {
        guard let ambientState = glance.ambientState else { return [] }
        return [ambientState.today, ambientState.focus, ambientState.goal, ambientState.plan]
            .sorted { lhs, rhs in
                prominenceRank(lhs.prominence) > prominenceRank(rhs.prominence)
            }
    }

    private func prominenceRank(_ prominence: ExternalSurfaceVariantProminence) -> Int {
        switch prominence {
        case .quiet:
            return 0
        case .standard:
            return 1
        case .elevated:
            return 2
        }
    }

    private func title(for glance: ExternalSurfaceGlanceState) -> String {
        if let today = glance.ambientState?.today {
            return today.title
        }
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
        if let today = glance.ambientState?.today {
            return today.detail
        }
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
            return "Open Ambitions for the next useful move."
        case .empty:
            return "Open Ambitions to refresh your plan."
        case .active, .recovery:
            return urgencyLabel(glance.urgency)
        }
    }

    private func lockDetail(for glance: ExternalSurfaceGlanceState) -> String {
        switch glance.continuity.lease.status {
        case .current:
            return detail(for: glance)
        case .stale:
            return "This may be older. Open Ambitions to confirm."
        case .unavailable:
            return "Open Ambitions to refresh local state."
        }
    }

    private func icon(for kind: ExternalSurfaceVariantKind) -> String {
        switch kind {
        case .today:
            return "sun.max"
        case .focus:
            return "scope"
        case .goal:
            return "target"
        case .plan:
            return "calendar"
        }
    }

    private func icon(for glance: ExternalSurfaceGlanceState) -> String {
        switch glance.todayPosture {
        case .empty:
            return "sparkle.magnifyingglass"
        case .active:
            return "scope"
        case .waiting:
            return "exclamationmark.arrow.triangle.2.circlepath"
        case .recovery:
            return "leaf"
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
            return "Getting tight"
        case .overloaded:
            return "Too much planned"
        }
    }

    private func shortPressure(_ pressure: ExternalSurfacePressureLevel) -> String {
        switch pressure {
        case .open:
            return "Open"
        case .steady:
            return "Now"
        case .elevated:
            return "Tight"
        case .overloaded:
            return "Too much"
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

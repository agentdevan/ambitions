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
                        title: "Today has a next step",
                        detail: "Your recommended step still looks doable.",
                        privacySummary: "Glance-safe recommended step only",
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
                        detail: "Open Time to adjust the week from your latest local state.",
                        privacySummary: "Time detail opens in app",
                        action: ExternalSurfaceVariantAction(title: "Open Time", surface: .tab, tab: "time"),
                        reference: ExternalSurfaceActionReference(goalID: "goal-placeholder", stepID: "step-placeholder"),
                        prominence: .standard
                    ),
                    currentStep: ExternalSurfaceVariantState(
                        kind: .currentStep,
                        title: "Recommended step ready",
                        detail: "A small focus step is available.",
                        privacySummary: "Step details stay inside Ambitions",
                        action: ExternalSurfaceVariantAction(title: "Open step", surface: .tab, tab: "today"),
                        reference: ExternalSurfaceActionReference(goalID: "goal-placeholder", stepID: "step-placeholder"),
                        prominence: .elevated
                    ),
                    todayPressure: ExternalSurfaceVariantState(
                        kind: .todayPressure,
                        title: "Today is steady",
                        detail: "The current plan still looks believable.",
                        privacySummary: "Pressure uses local counts only",
                        action: ExternalSurfaceVariantAction(title: "Open Today", surface: .tab, tab: "today"),
                        reference: ExternalSurfaceActionReference(goalID: "goal-placeholder", stepID: "step-placeholder"),
                        prominence: .standard
                    ),
                    protectedTime: ExternalSurfaceVariantState(
                        kind: .protectedTime,
                        title: "Protected time is calm",
                        detail: "Open Time before adding more to the day.",
                        privacySummary: "Protected-time details open in app",
                        action: ExternalSurfaceVariantAction(title: "Open Time", surface: .tab, tab: "time"),
                        reference: ExternalSurfaceActionReference(goalID: "goal-placeholder", stepID: "step-placeholder"),
                        prominence: .standard
                    ),
                    captureEntry: ExternalSurfaceVariantState(
                        kind: .captureEntry,
                        title: "Capture is clear",
                        detail: "Add a thought without exposing it here.",
                        privacySummary: "Capture text never appears here",
                        action: ExternalSurfaceVariantAction(title: "Open Capture", surface: .tab, tab: "capture"),
                        reference: ExternalSurfaceActionReference(goalID: "goal-placeholder", stepID: "step-placeholder"),
                        prominence: .standard
                    ),
                    recovery: ExternalSurfaceVariantState(
                        kind: .recovery,
                        title: "Recovery stays available",
                        detail: "Close or adjust from the last honest point.",
                        privacySummary: "Recovery context opens in Today",
                        action: ExternalSurfaceVariantAction(title: "Open Today", surface: .tab, tab: "today"),
                        reference: ExternalSurfaceActionReference(goalID: "goal-placeholder", stepID: "step-placeholder"),
                        prominence: .quiet
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
        let projection = ExternalWidgetProjection(snapshot: entry.snapshot)

        Group {
            switch entry.family {
            case .accessoryInline:
                Text("\(projection.title) · \(projection.trustSummary)")
            case .accessoryCircular:
                circularView(projection: projection)
            case .accessoryRectangular:
                rectangularLockView(projection: projection)
            case .systemMedium:
                mediumView(projection: projection)
            case .systemLarge:
                largeView(projection: projection)
            default:
                smallView(projection: projection)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(projection.primaryURL)
        .accessibilityLabel(projection.accessibilityLabel)
    }

    private func smallView(projection: ExternalWidgetProjection) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            surfaceHeader(icon: "scope", label: "Ambitions")
            Spacer(minLength: 0)
            Text(projection.title)
                .font(.headline.weight(.semibold))
                .lineLimit(3)
            Text(projection.detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)
            trustLine(projection: projection)
        }
        .padding()
        .background(widgetGradient(projection: projection))
    }

    private func mediumView(projection: ExternalWidgetProjection) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                surfaceHeader(icon: "scope", label: "Ambitions")
                Text(projection.title)
                    .font(.headline.weight(.semibold))
                    .lineLimit(2)
                Text(projection.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                trustLine(projection: projection)
            }
            Spacer(minLength: 0)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(projection.variants.prefix(2), id: \.kind.rawValue) { variant in
                    variantRow(variant)
                }
            }
            .frame(maxWidth: 150, alignment: .leading)
        }
        .padding()
        .background(widgetGradient(projection: projection))
    }

    private func largeView(projection: ExternalWidgetProjection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            surfaceHeader(icon: "sparkles", label: "Ambitions")
            Text(projection.title)
                .font(.title3.weight(.semibold))
                .lineLimit(2)
            Text(projection.detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            VStack(spacing: 8) {
                ForEach(projection.variants, id: \.kind.rawValue) { variant in
                    variantRow(variant)
                }
            }
            Spacer(minLength: 0)
            trustLine(projection: projection)
        }
        .padding()
        .background(widgetGradient(projection: projection))
    }

    private func rectangularLockView(projection: ExternalWidgetProjection) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(projection.title)
                .font(.headline)
                .lineLimit(1)
            Text(projection.lockDetail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
    }

    private func circularView(projection: ExternalWidgetProjection) -> some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Image(systemName: icon(for: projection.pressureLevel))
                    .font(.headline)
                Text(shortPressure(projection.pressureLevel))
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

    private func variantRow(_ variant: ExternalWidgetProjection.VariantRow) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon(for: variant.kind))
                .font(.caption.weight(.semibold))
                .frame(width: 18, height: 18)
                .background(.quaternary, in: Circle())
            VStack(alignment: .leading, spacing: 1) {
                Text(variant.title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                Text(variant.detail)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(variant.privacySummary)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
    }

    private func trustLine(projection: ExternalWidgetProjection) -> some View {
        Text(projection.trustSummary)
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .lineLimit(1)
    }

    private func widgetGradient(projection: ExternalWidgetProjection) -> LinearGradient {
        let warm = Color(red: 0.96, green: 0.72, blue: 0.42).opacity(projection.pressureLevel == .overloaded ? 0.30 : 0.18)
        return LinearGradient(
            colors: [Color(red: 0.08, green: 0.10, blue: 0.12), Color(red: 0.13, green: 0.16, blue: 0.18), warm],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
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
        case .currentStep:
            return "checkmark.seal"
        case .todayPressure:
            return "gauge.with.dots.needle.67percent"
        case .protectedTime:
            return "lock.shield"
        case .captureEntry:
            return "square.and.pencil"
        case .recovery:
            return "arrow.counterclockwise.heart"
        }
    }

    private func icon(for pressure: ExternalSurfacePressureLevel) -> String {
        switch pressure {
        case .open:
            return "sparkle.magnifyingglass"
        case .steady:
            return "scope"
        case .elevated:
            return "exclamationmark.arrow.triangle.2.circlepath"
        case .overloaded:
            return "leaf"
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

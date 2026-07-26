import SwiftUI

enum TodayVitalityHistoryFilter: String, CaseIterable, Identifiable {
    case all
    case today
    case lastSevenDays
    case currentGoal
    case currentStep

    var id: String { rawValue }

    var visibleTitle: String {
        switch self {
        case .all: "All"
        case .today: "Today"
        case .lastSevenDays: "Last 7 Days"
        case .currentGoal: "Current Goal"
        case .currentStep: "Current Step"
        }
    }
}

struct TodayVitalityGoalDetailView: View {
    let content: TodayFlagshipCalibrationContent
    let onDismiss: () -> Void

    var body: some View {
        TodayVitalitySupportingContainer(title: "Goal", onDismiss: onDismiss) {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 9) {
                    Text("Pursuit")
                        .font(TodayVitalityTypographyRole.metadata.font.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(content.supporting.goal.title)
                        .font(TodayVitalityTypographyRole.objectIdentity.font)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier("r13-goal-detail-identity")
                }

                TodayVitalitySupportingSection(
                    title: "Why it matters",
                    body: content.supporting.goal.whyItMatters,
                    identifier: "r13-goal-detail-why"
                )
                TodayVitalitySupportingSection(
                    title: "Right now",
                    body: content.supporting.goal.currentPosture,
                    identifier: "r13-goal-detail-posture"
                )

                Label {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Next Step")
                            .font(TodayVitalityTypographyRole.metadata.font.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(content.primaryStep.title)
                            .font(TodayVitalityTypographyRole.relationship.font)
                    }
                } icon: {
                    Image(systemName: "arrow.forward.circle")
                        .foregroundStyle(.tint)
                }
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("r13-goal-detail-next-step")
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("r13-goal-detail")
        }
    }
}

struct TodayVitalityConsequenceDetailsView: View {
    let content: TodayFlagshipCalibrationContent
    let onDismiss: () -> Void

    var body: some View {
        TodayVitalitySupportingContainer(title: "Details", onDismiss: onDismiss) {
            VStack(alignment: .leading, spacing: 22) {
                Text(content.primaryStep.title)
                    .font(TodayVitalityTypographyRole.objectIdentity.font)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                TodayVitalitySupportingSection(
                    title: "What changes",
                    body: content.primaryStep.stillCountsProposal.exactConsequence,
                    identifier: "r13-consequence-details-impact"
                )
                TodayVitalitySupportingSection(
                    title: "Also updates",
                    body: content.primaryStep.stillCountsProposal.affectedLineage,
                    identifier: "r13-consequence-details-pursuit"
                )
                TodayVitalitySupportingSection(
                    title: "On this device",
                    body: content.interfaceCopy.historyTrustCue,
                    identifier: "r13-consequence-details-history"
                )
                TodayVitalitySupportingSection(
                    title: "Protected boundary",
                    body: content.primaryStep.materialConsequence,
                    identifier: "r13-consequence-details-protected"
                )
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("r13-consequence-details")
        }
    }
}

struct TodayVitalityHistoryEntryView: View {
    let content: TodayFlagshipCalibrationContent
    let onDismiss: () -> Void

    @State private var path: [TodayVitalityHistoryFilterRoute]
    @State private var filter: TodayVitalityHistoryFilter = .all

    init(
        content: TodayFlagshipCalibrationContent,
        initiallyShowsFilters: Bool = false,
        onDismiss: @escaping () -> Void
    ) {
        self.content = content
        self.onDismiss = onDismiss
        _path = State(initialValue: initiallyShowsFilters ? [.filters] : [])
    }

    var body: some View {
        NavigationStack(path: $path) {
            TodayVitalitySupportingScroll {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Local history")
                            .font(TodayVitalityTypographyRole.metadata.font.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(content.supporting.history.recordedTruth)
                            .font(TodayVitalityTypographyRole.objectIdentity.font)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityAddTraits(.isHeader)
                            .accessibilityIdentifier("r13-history-entry-truth")
                    }

                    Label(historyTimestamp, systemImage: "clock")
                        .font(TodayVitalityTypographyRole.relationship.font.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("r13-history-entry-time")

                    TodayVitalitySupportingSection(
                        title: "Step",
                        body: content.primaryStep.title,
                        identifier: "r13-history-entry-step"
                    )
                    TodayVitalitySupportingSection(
                        title: "Pursuit",
                        body: content.supporting.goal.title,
                        identifier: "r13-history-entry-goal"
                    )

                    Label("Recorded on this device", systemImage: "lock")
                        .font(TodayVitalityTypographyRole.relationship.font)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("r13-history-entry-local")
                }
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("r13-history-entry")
            }
            .navigationTitle("History")
            .todayFlagshipInlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done", action: onDismiss)
                        .accessibilityIdentifier("r13-supporting-done")
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Filter") {
                        path.append(.filters)
                    }
                    .accessibilityIdentifier("r13-history-filter-open")
                }
            }
            .navigationDestination(for: TodayVitalityHistoryFilterRoute.self) { _ in
                TodayVitalityHistoryFiltersView(content: content, selection: $filter)
            }
        }
    }

    private var historyTimestamp: String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: content.supporting.history.recordedAtISO8601) else {
            return content.supporting.history.recordedAtISO8601
        }
        return date.formatted(date: .abbreviated, time: .shortened)
    }
}

struct TodayVitalityHistoryFiltersView: View {
    let content: TodayFlagshipCalibrationContent
    @Binding var selection: TodayVitalityHistoryFilter

    var body: some View {
        List(TodayVitalityHistoryFilter.allCases) { filter in
            Button {
                selection = filter
            } label: {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(filter.visibleTitle)
                        if let context = context(for: filter) {
                            Text(context)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    if selection == filter {
                        Image(systemName: "checkmark")
                            .accessibilityHidden(true)
                    }
                }
                .frame(minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityValue(selection == filter ? "Selected" : "")
            .accessibilityIdentifier("r13-history-filter-\(filter.rawValue)")
        }
        .navigationTitle("Filters")
        .todayFlagshipInlineNavigationTitle()
        .accessibilityIdentifier("r13-history-filters")
    }

    private func context(for filter: TodayVitalityHistoryFilter) -> String? {
        switch filter {
        case .currentGoal: content.supporting.goal.title
        case .currentStep: content.primaryStep.title
        default: nil
        }
    }
}

public struct TodayFlagshipTimeTransferEvaluationView: View {
    public let content: TodayFlagshipCalibrationContent
    public let onCancel: () -> Void

    public init(
        content: TodayFlagshipCalibrationContent,
        onCancel: @escaping () -> Void
    ) {
        self.content = content
        self.onCancel = onCancel
    }

    public var body: some View {
        NavigationStack {
            TodayVitalitySupportingScroll {
                VStack(alignment: .leading, spacing: 24) {
                    Text(content.supporting.timeTransfer.title)
                        .font(TodayVitalityTypographyRole.objectIdentity.font)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)

                    Text(content.supporting.timeTransfer.body)
                        .font(TodayVitalityTypographyRole.stateTruth.font)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(
                        "\(content.supporting.timeTransfer.sourceOwner) → "
                            + content.supporting.timeTransfer.destinationOwner
                    )
                    .font(TodayVitalityTypographyRole.relationship.font.weight(.semibold))
                    .foregroundStyle(.tint)
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("r13-time-transfer-ownership")

                    Label("Today remains unchanged", systemImage: "lock")
                        .font(TodayVitalityTypographyRole.relationship.font)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("r13-time-transfer-evaluation")
            }
            .navigationTitle("Time")
            .todayFlagshipInlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Not now", action: onCancel)
                        .accessibilityIdentifier("r13-time-transfer-cancel")
                }
            }
        }
    }
}

private enum TodayVitalityHistoryFilterRoute: Hashable {
    case filters
}

private struct TodayVitalitySupportingContainer<Content: View>: View {
    let title: String
    let onDismiss: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        NavigationStack {
            TodayVitalitySupportingScroll {
                content
            }
            .navigationTitle(title)
            .todayFlagshipInlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: onDismiss)
                        .accessibilityIdentifier("r13-supporting-done")
                }
            }
        }
    }
}

private struct TodayVitalitySupportingScroll<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView {
            content
                .frame(maxWidth: 560, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
        }
        .background(
            Color(white: colorScheme == .dark ? 0.035 : 0.965)
                .ignoresSafeArea()
        )
    }
}

private struct TodayVitalitySupportingSection: View {
    let title: String
    let text: String
    let identifier: String

    init(title: String, body: String, identifier: String) {
        self.title = title
        text = body
        self.identifier = identifier
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(TodayVitalityTypographyRole.metadata.font.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(text)
                .font(TodayVitalityTypographyRole.relationship.font)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(identifier)
    }
}

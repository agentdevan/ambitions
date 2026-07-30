import SwiftUI

public struct TimeNativeCalibrationView: View {
    private let fixture: TimeNativeCalibrationFixture
    @Binding private var state: TimeNativeCalibrationJourneyState

    public init(
        fixture: TimeNativeCalibrationFixture,
        state: Binding<TimeNativeCalibrationJourneyState>
    ) {
        self.fixture = fixture
        _state = state
    }

    public var body: some View {
        NavigationStack(path: navigationPath) {
            TimeNativeCalibrationWeekRoot(
                fixture: fixture,
                state: $state
            )
            .navigationDestination(for: TimeNativeCalibrationRoute.self) { route in
                destination(for: route)
            }
        }
        .sheet(item: presentedObject) { object in
            TimeNativeCalibrationObjectDetail(
                object: object,
                onDismiss: { _ = state.dismissObjectDetail() }
            )
            .timeNativeCalibrationSheetPresentation()
        }
        .background(TimeNativeCalibrationPalette.background)
    }

    private var navigationPath: Binding<[TimeNativeCalibrationRoute]> {
        Binding(
            get: { state.navigationPath },
            set: { state.restoreNavigationPath($0) }
        )
    }

    private var presentedObject: Binding<TimeNativeCalibrationObject?> {
        Binding(
            get: {
                state.presentedObjectID.flatMap { fixture.object(id: $0) }
            },
            set: { newValue in
                if newValue == nil, state.presentedObjectID != nil {
                    _ = state.dismissObjectDetail()
                }
            }
        )
    }

    @ViewBuilder
    private func destination(for route: TimeNativeCalibrationRoute) -> some View {
        switch route {
        case let .focusedDay(dayID):
            TimeNativeCalibrationFocusedDay(
                fixture: fixture,
                dayID: dayID,
                focusAnchor: state.focusAnchor,
                onOpenObject: { _ = state.presentObject(id: $0) },
                onOpenReview: { _ = state.openConflictReview(proposalID: $0) }
            )
        case let .conflictReview(proposalID):
            TimeNativeCalibrationConflictReview(
                fixture: fixture,
                proposalID: proposalID,
                onCancel: { _ = state.cancelConflictReview() },
                onKeepCurrent: { _ = state.keepCurrent() }
            )
        }
    }
}

private struct TimeNativeCalibrationWeekRoot: View {
    let fixture: TimeNativeCalibrationFixture
    @Binding var state: TimeNativeCalibrationJourneyState

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @AccessibilityFocusState private var focusedDayID: TimeNativeCalibrationDayID?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                TimeNativeCalibrationWeekHeader(
                    fixture: fixture,
                    selectedDayID: state.selectedDayID,
                    focusedDayID: $focusedDayID,
                    onSelectDay: { _ = state.selectDay($0) }
                )

                if dynamicTypeSize.isAccessibilitySize {
                    TimeNativeCalibrationChronologicalEquivalent(
                        fixture: fixture,
                        onOpenObject: { _ = state.presentObject(id: $0) },
                        onOpenReview: { _ = state.openConflictReview(proposalID: $0) }
                    )
                } else {
                    selectedDayPassage
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .scrollIndicators(.hidden)
        .background(TimeNativeCalibrationPalette.background.ignoresSafeArea())
        .foregroundStyle(Color.white)
        .timeNativeCalibrationHideRootNavigationBar()
        .accessibilityIdentifier("tnc-d07-week-root")
        .onChange(of: state.focusAnchor, initial: true) { _, anchor in
            if case let .day(dayID) = anchor {
                focusedDayID = dayID
            }
        }
    }

    private var selectedDayPassage: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                if let day = fixture.day(state.selectedDayID) {
                    Text("\(day.longName), July \(day.dayNumber)")
                        .font(.title2.weight(.bold))
                        .accessibilityIdentifier("tnc-d07-selected-day-heading")
                }
                Spacer()
                if state.selectedDayID == .wednesday {
                    Button("Focus day") {
                        _ = state.openFocusedDay()
                    }
                    .buttonStyle(.bordered)
                    .accessibilityInputLabels(["Focus Wednesday", "Open Wednesday"])
                    .accessibilityIdentifier("tnc-d07-focus-day")
                }
            }

            if state.selectedDayID == .wednesday {
                TimeNativeCalibrationAdjacentDayContext {
                    _ = state.selectDay(.thursday)
                }
            }

            if fixture.objects(on: state.selectedDayID).isEmpty {
                Text("No fixture objects on this day.")
                    .font(.body)
                    .foregroundStyle(TimeNativeCalibrationPalette.secondary)
                    .padding(.vertical, 48)
            } else {
                TimeNativeCalibrationMeasuredTimeline(
                    fixture: fixture,
                    dayID: state.selectedDayID,
                    focused: false,
                    focusAnchor: state.focusAnchor,
                    onOpenObject: { _ = state.presentObject(id: $0) },
                    onOpenReview: { _ = state.openConflictReview(proposalID: $0) }
                )
            }
        }
    }
}

private struct TimeNativeCalibrationWeekHeader: View {
    let fixture: TimeNativeCalibrationFixture
    let selectedDayID: TimeNativeCalibrationDayID
    let focusedDayID: AccessibilityFocusState<TimeNativeCalibrationDayID?>.Binding
    let onSelectDay: (TimeNativeCalibrationDayID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Time", systemImage: "crown")
                .font(.headline.weight(.semibold))
                .foregroundStyle(TimeNativeCalibrationPalette.secondary)
                .accessibilityIdentifier("tnc-d07-time-crown")

            VStack(alignment: .leading, spacing: 2) {
                Text(fixture.weekLabel)
                    .font(.largeTitle.weight(.bold))
                Text(fixture.rangeLabel)
                    .font(.title3.monospacedDigit())
                    .foregroundStyle(TimeNativeCalibrationPalette.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("This week, July 27 through August 2")
            .accessibilityIdentifier("tnc-d07-week-range")

            ScrollView(.horizontal) {
                HStack(spacing: 6) {
                    ForEach(fixture.days) { day in
                        Button {
                            onSelectDay(day.id)
                        } label: {
                            VStack(spacing: 3) {
                                Text(day.shortName)
                                    .font(.caption)
                                Text("\(day.dayNumber)")
                                    .font(.body.monospacedDigit().weight(.semibold))
                            }
                            .frame(minWidth: 44, minHeight: 48)
                            .foregroundStyle(day.id == selectedDayID ? Color.white : TimeNativeCalibrationPalette.secondary)
                            .background(
                                day.id == selectedDayID
                                    ? TimeNativeCalibrationPalette.accent
                                    : TimeNativeCalibrationPalette.plane,
                                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                            )
                            .overlay {
                                if day.id == .wednesday {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color.white.opacity(0.72), lineWidth: 1)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(day.longName), July \(day.dayNumber)")
                        .accessibilityValue(day.id == selectedDayID ? "Selected" : "")
                        .accessibilityInputLabels([day.longName, "\(day.shortName) \(day.dayNumber)"])
                        .accessibilityFocused(focusedDayID, equals: day.id)
                        .accessibilityIdentifier("tnc-d07-day-\(day.id.rawValue)")
                    }
                }
            }
            .scrollIndicators(.hidden)
            .accessibilityIdentifier("tnc-d07-week-orientation")
        }
    }
}

private struct TimeNativeCalibrationAdjacentDayContext: View {
    let onOpenThursday: () -> Void

    var body: some View {
        Button(action: onOpenThursday) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Next · Thursday 30")
                        .font(.subheadline.weight(.semibold))
                    Text("Prenatal 9:00 · Nursery proposal 10:30")
                        .font(.caption)
                        .foregroundStyle(TimeNativeCalibrationPalette.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(TimeNativeCalibrationPalette.accent)
            }
            .padding(.vertical, 9)
            .overlay(alignment: .top) {
                Rectangle().fill(TimeNativeCalibrationPalette.rule).frame(height: 1)
            }
            .overlay(alignment: .bottom) {
                Rectangle().fill(TimeNativeCalibrationPalette.rule).frame(height: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            "Thursday context, Prenatal appointment at 9 AM, external observation; "
                + "Paint the nursery wall at 10:30 AM, proposed and not scheduled"
        )
        .accessibilityHint("Selects Thursday within this week")
        .accessibilityInputLabels(["Thursday context", "Thursday"])
        .accessibilityIdentifier("tnc-d07-adjacent-thursday")
    }
}

private struct TimeNativeCalibrationFocusedDay: View {
    let fixture: TimeNativeCalibrationFixture
    let dayID: TimeNativeCalibrationDayID
    let focusAnchor: TimeNativeCalibrationFocusAnchor
    let onOpenObject: (String) -> Void
    let onOpenReview: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Accepted chronology remains authoritative. Proposed time stays open until review.")
                    .font(.subheadline)
                    .foregroundStyle(TimeNativeCalibrationPalette.secondary)
                    .accessibilityIdentifier("tnc-d07-focused-authority")

                TimeNativeCalibrationMeasuredTimeline(
                    fixture: fixture,
                    dayID: dayID,
                    focused: true,
                    focusAnchor: focusAnchor,
                    onOpenObject: onOpenObject,
                    onOpenReview: onOpenReview
                )
            }
            .padding(16)
        }
        .background(TimeNativeCalibrationPalette.background.ignoresSafeArea())
        .foregroundStyle(Color.white)
        .navigationTitle("Wednesday · Jul 29")
        .timeNativeCalibrationNavigationTitleDisplayMode()
        .accessibilityIdentifier("tnc-d07-focused-wednesday")
    }
}

private struct TimeNativeCalibrationObjectDetail: View {
    let object: TimeNativeCalibrationObject
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    TimeNativeCalibrationTruthLabel(truth: object.truth)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(object.title)
                            .font(.title2.weight(.bold))
                        Text(object.timeLabel)
                            .font(.body.monospacedDigit())
                            .foregroundStyle(TimeNativeCalibrationPalette.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("tnc-d07-detail-identity")

                    if let source = object.source {
                        detailRow(title: "Source", value: source)
                    }
                    if let goalTitle = object.goalTitle {
                        detailRow(title: "Goal", value: goalTitle)
                    }
                    if let meaning = object.meaning {
                        detailRow(title: "Meaning", value: meaning)
                    }

                    Text("Fixture inspection only. No edit, mutation, Receipt, or external write is available.")
                        .font(.footnote)
                        .foregroundStyle(TimeNativeCalibrationPalette.secondary)
                        .accessibilityIdentifier("tnc-d07-detail-ceiling")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
            }
            .background(TimeNativeCalibrationPalette.background.ignoresSafeArea())
            .foregroundStyle(Color.white)
            .navigationTitle("Time object")
            .timeNativeCalibrationNavigationTitleDisplayMode()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: onDismiss)
                        .accessibilityIdentifier("tnc-d07-detail-done")
                }
            }
        }
        .accessibilityAddTraits(.isModal)
        .accessibilityAction(.escape, onDismiss)
        .accessibilityIdentifier("tnc-d07-object-detail")
    }

    private func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(TimeNativeCalibrationPalette.secondary)
            Text(value)
                .font(.body)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct TimeNativeCalibrationConflictReview: View {
    let fixture: TimeNativeCalibrationFixture
    let proposalID: String
    let onCancel: () -> Void
    let onKeepCurrent: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Current truth stays in place")
                    .font(.title2.weight(.bold))
                    .accessibilityIdentifier("tnc-d07-review-heading")

                if let familyTime {
                    truthSection(
                        eyebrow: "CURRENT · ACCEPTED",
                        object: familyTime,
                        dominant: true
                    )
                    .accessibilityIdentifier("tnc-d07-review-current")
                }

                if let proposal {
                    truthSection(
                        eyebrow: "PROPOSED · NOT SCHEDULED",
                        object: proposal,
                        dominant: false
                    )
                    .accessibilityIdentifier("tnc-d07-review-proposed")
                }

                VStack(alignment: .leading, spacing: 7) {
                    Label("Consequence", systemImage: "exclamationmark.triangle")
                        .font(.headline)
                    Text("The proposed launch review would consume protected Family time from 5:45 to 6:15 PM.")
                        .font(.body)
                }
                .padding(16)
                .background(TimeNativeCalibrationPalette.protected, in: RoundedRectangle(cornerRadius: 14))
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("tnc-d07-review-consequence")

                VStack(spacing: 10) {
                    Button("Keep current", action: onKeepCurrent)
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                        .accessibilityHint("Returns with Family time unchanged")
                        .accessibilityIdentifier("tnc-d07-review-keep-current")
                    Button("Cancel", action: onCancel)
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                        .accessibilityHint("Dismisses this proposal without changing accepted time")
                        .accessibilityIdentifier("tnc-d07-review-cancel")
                }
                .controlSize(.large)
            }
            .padding(16)
        }
        .background(TimeNativeCalibrationPalette.background.ignoresSafeArea())
        .foregroundStyle(Color.white)
        .navigationTitle("Review proposed time")
        .timeNativeCalibrationNavigationTitleDisplayMode()
    }

    private var proposal: TimeNativeCalibrationObject? {
        fixture.object(id: proposalID)
    }

    private var familyTime: TimeNativeCalibrationObject? {
        fixture.object(id: "placement.family-time.wed-1730")
    }

    private func truthSection(
        eyebrow: String,
        object: TimeNativeCalibrationObject,
        dominant: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(eyebrow)
                .font(.caption.weight(.bold))
                .foregroundStyle(
                    dominant ? Color.white : TimeNativeCalibrationPalette.proposal
                )
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(object.title)
                        .font(.headline)
                    Text(object.timeLabel)
                        .font(.body.monospacedDigit())
                    Text(object.truth.stateLabel)
                        .font(.subheadline)
                        .foregroundStyle(TimeNativeCalibrationPalette.secondary)
                    if let meaning = object.meaning {
                        Text(meaning)
                            .font(.subheadline.weight(.semibold))
                    }
                }
                Spacer()
                Image(systemName: dominant ? "lock.fill" : "circle.dashed")
                    .foregroundStyle(
                        dominant ? Color.white : TimeNativeCalibrationPalette.proposal
                    )
            }
        }
        .padding(16)
        .background(
            dominant
                ? TimeNativeCalibrationPalette.protected
                : TimeNativeCalibrationPalette.plane,
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    dominant ? Color.white.opacity(0.8) : TimeNativeCalibrationPalette.proposal,
                    style: StrokeStyle(
                        lineWidth: dominant ? 2 : 1.5,
                        dash: dominant ? [] : [7, 5]
                    )
                )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(object.accessibilityLabel)
    }
}

private struct TimeNativeCalibrationChronologicalEquivalent: View {
    let fixture: TimeNativeCalibrationFixture
    let onOpenObject: (String) -> Void
    let onOpenReview: (String) -> Void

    private let orderedDays: [TimeNativeCalibrationDayID] = [.wednesday, .thursday]

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 20) {
            Text("Chronological Week")
                .font(.title2.weight(.bold))
                .accessibilityIdentifier("tnc-d07-accessibility-heading")

            ForEach(orderedDays, id: \.self) { dayID in
                if let day = fixture.day(dayID) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(day.longName), July \(day.dayNumber)")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                        ForEach(semanticRows(for: dayID)) { row in
                            semanticRow(row)
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("tnc-d07-chronological-equivalent")
    }

    @ViewBuilder
    private func semanticRow(_ row: TimeNativeCalibrationSemanticRow) -> some View {
        if let object = row.object {
            Button {
                if object.conflictParticipantIDs.isEmpty {
                    onOpenObject(object.id)
                } else {
                    onOpenReview(object.id)
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: row.symbolName)
                        .frame(width: 24)
                        .foregroundStyle(row.tint)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(object.timeLabel)
                            .font(.subheadline.monospacedDigit().weight(.semibold))
                        Text(object.title)
                            .font(.body.weight(.semibold))
                        Text(object.truth.stateLabel)
                            .font(.subheadline)
                            .foregroundStyle(TimeNativeCalibrationPalette.secondary)
                        if let meaning = object.meaning {
                            Text(meaning)
                                .font(.subheadline)
                                .foregroundStyle(TimeNativeCalibrationPalette.secondary)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(object.accessibilityLabel)
            .accessibilityInputLabels([object.title])
            .accessibilityIdentifier("tnc-d07-list-\(object.id)")
        } else {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "location.fill")
                    .frame(width: 24)
                    .foregroundStyle(TimeNativeCalibrationPalette.now)
                VStack(alignment: .leading, spacing: 4) {
                    Text("3:12 PM")
                        .font(.subheadline.monospacedDigit().weight(.semibold))
                    Text("Now")
                        .font(.body.weight(.semibold))
                }
            }
            .padding(.vertical, 8)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Now, Wednesday at 3:12 PM")
            .accessibilityIdentifier("tnc-d07-list-now")
        }
    }

    private func semanticRows(
        for dayID: TimeNativeCalibrationDayID
    ) -> [TimeNativeCalibrationSemanticRow] {
        var rows = fixture.objects(on: dayID).map(TimeNativeCalibrationSemanticRow.init)
        if dayID == .wednesday {
            rows.append(.init(nowMinute: fixture.nowMinute))
        }
        return rows.sorted { $0.minute < $1.minute }
    }
}

private struct TimeNativeCalibrationSemanticRow: Identifiable {
    let id: String
    let minute: Int
    let object: TimeNativeCalibrationObject?

    init(object: TimeNativeCalibrationObject) {
        id = object.id
        minute = object.startMinute
        self.object = object
    }

    init(nowMinute: Int) {
        id = "now"
        minute = nowMinute
        object = nil
    }

    var symbolName: String {
        switch object?.truth {
        case .acceptedFixed:
            "pin.fill"
        case .acceptedProtected:
            "lock.fill"
        case .externalObservation:
            "arrow.down.left.circle"
        case .proposedPlacement:
            "circle.dashed"
        case .openCapacity:
            "arrow.right"
        case nil:
            "location.fill"
        }
    }

    var tint: Color {
        switch object?.truth {
        case .externalObservation:
            .cyan.opacity(0.9)
        case .proposedPlacement:
            TimeNativeCalibrationPalette.proposal
        case .openCapacity:
            TimeNativeCalibrationPalette.secondary
        default:
            .white
        }
    }
}

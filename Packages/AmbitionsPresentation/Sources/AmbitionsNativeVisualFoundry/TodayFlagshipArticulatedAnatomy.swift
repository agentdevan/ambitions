import SwiftUI

enum TodayFlagshipReliefRole {
    case primary
    case current
    case proposed
    case settled
    case interrupted
}

struct TodayFlagshipObjectField<Content: View>: View {
    let role: TodayFlagshipReliefRole
    let palette: TodayFlagshipPalette
    let content: Content

    init(
        role: TodayFlagshipReliefRole,
        palette: TodayFlagshipPalette,
        @ViewBuilder content: () -> Content
    ) {
        self.role = role
        self.palette = palette
        self.content = content()
    }

    var body: some View {
        content
            .padding(.leading, 42)
            .padding(.trailing, 18)
            .padding(.vertical, 17)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                fieldShape
                    .fill(fieldFill)
                    .shadow(
                        color: role == .primary ? palette.reliefShadow : .clear,
                        radius: 8,
                        y: 4
                    )
            }
            .overlay(alignment: .leading) {
                TodayOpenContinuitySpine(
                    kind: role.nodeKind,
                    palette: palette.openContinuity,
                    extendsBefore: false,
                    extendsAfter: true
                )
                    .padding(.leading, 7)
                    .padding(.vertical, 8)
                    .frame(maxHeight: .infinity)
                    .accessibilityHidden(true)
            }
    }

    private var fieldShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: 20,
            bottomLeadingRadius: 4,
            bottomTrailingRadius: 20,
            topTrailingRadius: 4,
            style: .continuous
        )
    }

    private var fieldFill: Color {
        switch role {
        case .primary:
            palette.primaryObjectPlane
        case .current:
            palette.currentTruthPlane
        case .proposed:
            palette.proposedTruthPlane
        case .settled:
            palette.settledTruthPlane
        case .interrupted:
            palette.interruptedTruthPlane
        }
    }
}

struct TodayFlagshipLandmarkLabel: View {
    let title: String
    let symbol: String
    let tint: Color

    var body: some View {
        Label(title, systemImage: symbol)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(tint)
            .accessibilityAddTraits(.isHeader)
    }
}

struct TodayFlagshipRelationshipRow: View {
    let symbol: String
    let title: String
    let value: String
    let palette: TodayFlagshipPalette
    var emphasized = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(emphasized ? palette.articulationAccent : palette.tertiaryInk)
                .frame(width: 18)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(palette.tertiaryInk)

                Text(value)
                    .font(.subheadline.weight(emphasized ? .semibold : .regular))
                    .foregroundStyle(palette.primaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct TodayFlagshipStateField: View {
    let label: String
    let symbol: String
    let truth: String
    let role: TodayFlagshipReliefRole
    let palette: TodayFlagshipPalette

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: symbol)
                .font(.headline)
                .foregroundStyle(accent)

            Text(truth)
                .font(.body.weight(role == .proposed || role == .settled ? .semibold : .regular))
                .foregroundStyle(palette.primaryInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.leading, 40)
        .padding(.trailing, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            UnevenRoundedRectangle(
                topLeadingRadius: 12,
                bottomLeadingRadius: 4,
                bottomTrailingRadius: 12,
                topTrailingRadius: 4,
                style: .continuous
            )
                .fill(fill)
        }
        .overlay(alignment: .leading) {
            TodayOpenContinuitySpine(
                kind: role.nodeKind,
                palette: palette.openContinuity,
                extendsBefore: false,
                extendsAfter: false
            )
                .padding(.leading, 6)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
    }

    private var fill: Color {
        switch role {
        case .primary:
            palette.primaryObjectPlane
        case .current:
            palette.currentTruthPlane
        case .proposed:
            palette.proposedTruthPlane
        case .settled:
            palette.settledTruthPlane
        case .interrupted:
            palette.interruptedTruthPlane
        }
    }

    private var accent: Color {
        switch role {
        case .primary, .proposed:
            palette.articulationAccent
        case .current:
            palette.secondaryInk
        case .settled:
            palette.settledAccent
        case .interrupted:
            palette.interruptionAccent
        }
    }
}

struct TodayFlagshipTimelineRow: View {
    let item: TodayFlagshipTimelineObject
    let palette: TodayFlagshipPalette
    var showsContinuation = true

    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            Text(item.timeLabel)
                .font(.caption.monospacedDigit().weight(.semibold))
                .foregroundStyle(palette.tertiaryInk)
                .frame(width: 62, alignment: .trailing)
                .padding(.top, 3)

            TodayOpenContinuitySpine(
                kind: timelineNodeKind,
                palette: palette.openContinuity,
                extendsBefore: false,
                extendsAfter: showsContinuation
            )
            .frame(width: 18)
            .frame(minHeight: 68)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
                Text(item.objectTitle)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(palette.primaryInk)
                    .fixedSize(horizontal: false, vertical: true)

                Text(item.relationship)
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)

                Label(item.acceptedState, systemImage: stateSymbol)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(stateColor)
            }
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(item.objectTitle), \(item.timeLabel), \(item.relationship), \(item.acceptedState)"
        )
        .accessibilityIdentifier("tfcs-timeline-row-\(item.canonicalObjectID)")
    }

    private var stateColor: Color {
        item.isProtected ? palette.settledAccent : palette.tertiaryInk
    }

    private var stateSymbol: String {
        if item.isProtected {
            return "shield"
        }
        if item.isFixed {
            return "pin"
        }
        return "circle"
    }

    private var timelineNodeKind: TodayOpenContinuityNodeKind {
        if item.isProtected {
            return .protected
        }
        if item.isFixed {
            return .fixed
        }
        return .current
    }
}

struct TodayFlagshipStateComparison: View {
    let currentLabel: String
    let currentTruth: String
    let proposedLabel: String
    let proposedTruth: String
    let palette: TodayFlagshipPalette

    var body: some View {
        VStack(spacing: 0) {
            TodayFlagshipStateField(
                label: currentLabel,
                symbol: "checkmark.seal",
                truth: currentTruth,
                role: .current,
                palette: palette
            )
            .accessibilityIdentifier("tfcs-review-current-truth")

            TodayOpenContinuitySpine(
                kind: .proposed,
                palette: palette.openContinuity
            )
            .frame(height: 36)
            .accessibilityHidden(true)

            TodayFlagshipStateField(
                label: proposedLabel,
                symbol: "arrow.trianglehead.branch",
                truth: proposedTruth,
                role: .proposed,
                palette: palette
            )
            .accessibilityIdentifier("tfcs-proposed-truth")
        }
        .accessibilityElement(children: .contain)
    }
}

private extension TodayFlagshipReliefRole {
    var nodeKind: TodayOpenContinuityNodeKind {
        switch self {
        case .primary, .current:
            .current
        case .proposed:
            .proposed
        case .settled:
            .settled
        case .interrupted:
            .interrupted
        }
    }
}

struct TodayFlagshipEvidenceRow: View {
    let symbol: String
    let title: String
    let detail: String?
    let palette: TodayFlagshipPalette

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.tertiaryInk)
                .frame(width: 18)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(palette.primaryInk)
                if let detail {
                    Text(detail)
                        .font(.footnote)
                        .foregroundStyle(palette.secondaryInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

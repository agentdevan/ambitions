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
            .padding(.horizontal, 18)
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
                fieldShape
                    .strokeBorder(palette.localArticulation, lineWidth: 1)
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(roleAccent)
                            .frame(width: role == .primary ? 4 : 3)
                            .padding(.vertical, 13)
                    }
                    .accessibilityHidden(true)
            }
    }

    private var fieldShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: 4,
            bottomLeadingRadius: 4,
            bottomTrailingRadius: 18,
            topTrailingRadius: 18,
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

    private var roleAccent: Color {
        switch role {
        case .primary, .proposed:
            palette.articulationAccent
        case .current:
            palette.localArticulation
        case .settled:
            palette.settledAccent
        case .interrupted:
            palette.interruptionAccent
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
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(fill)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(accent.opacity(role == .current ? 0.45 : 0.90))
                .frame(height: role == .current ? 1 : 2)
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

            VStack(spacing: 0) {
                Circle()
                    .fill(markerColor)
                    .frame(width: 8, height: 8)
                    .overlay {
                        Circle().stroke(palette.semanticPlane, lineWidth: 2)
                    }

                if showsContinuation {
                    Rectangle()
                        .fill(palette.timelineRail)
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 10)
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

    private var markerColor: Color {
        if item.isProtected {
            return palette.settledAccent
        }
        if item.isFixed {
            return palette.articulationAccent
        }
        return palette.secondaryInk
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

            HStack(spacing: 9) {
                Rectangle()
                    .fill(palette.timelineRail)
                    .frame(height: 1)

                Image(systemName: "arrow.down")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(palette.articulationAccent)
                    .accessibilityHidden(true)

                Rectangle()
                    .fill(palette.timelineRail)
                    .frame(height: 1)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 7)

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

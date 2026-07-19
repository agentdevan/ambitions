import AmbitionsDesignSystem
import SwiftUI

private enum CaptureFirstRunGuideItem: String, CaseIterable, Identifiable {
    case captureAnything
    case startHere
    case createGoal
    case shapeTime
    case closeWithProof
    case inspectWhatAmbitionsKnows

    var id: String { rawValue }

    var title: String {
        switch self {
        case .captureAnything: "Private field"
        case .startHere: "Start here"
        case .createGoal: "Create goal"
        case .shapeTime: "Shape time"
        case .closeWithProof: "Add proof"
        case .inspectWhatAmbitionsKnows: "Review settings"
        }
    }

    var detail: String {
        switch self {
        case .captureAnything:
            "Type one real thing, then choose where it belongs."
        case .startHere:
            "Open Today when the thing needs one doable step."
        case .createGoal:
            "Use Goals when the thing needs a direction and a path."
        case .shapeTime:
            "Open Time when the thing needs room this week."
        case .closeWithProof:
            "Attach proof after a step changes something."
        case .inspectWhatAmbitionsKnows:
            "Use You for privacy, receipts, and local controls."
        }
    }

    var icon: String {
        switch self {
        case .captureAnything: "lock.shield"
        case .startHere: "sun.max"
        case .createGoal: "target"
        case .shapeTime: "calendar.badge.clock"
        case .closeWithProof: "checkmark.seal"
        case .inspectWhatAmbitionsKnows: "person.crop.circle"
        }
    }
}

struct CaptureFirstRunGuide: View {
    @Environment(\.ambitionTheme) private var theme

    var body: some View {
        CaptureStageGroup(state: .active, accessibilityIdentifier: "capture.empty.guide") {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "First run",
                    title: "What can happen next",
                    subtitle: "Capture stays private until you review where the input belongs."
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(CaptureFirstRunGuideItem.allCases) { item in
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            Image(systemName: item.icon)
                                .font(theme.typography.caption.weight(theme.icon.symbolWeight))
                                .foregroundStyle(theme.colors.textSecondary)
                                .frame(width: 20)
                                .accessibilityHidden(true)

                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                Text(item.title)
                                    .font(theme.typography.bodyEmphasized)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(item.detail)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer(minLength: 0)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .contain)
    }
}

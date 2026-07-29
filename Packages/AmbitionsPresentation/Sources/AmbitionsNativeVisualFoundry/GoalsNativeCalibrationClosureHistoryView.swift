import SwiftUI

public struct GoalsNativeCalibrationClosureHistoryPresentation: Equatable, Sendable {
    public let closureID: String
    public let goalID: String
    public let goalTitle: String
    public let lifeAreaTitle: String
    public let entries: [GoalsNativeCalibrationHistoryEntry]
    public let accessibilityReadingOrder: [String]
    public let isInspectionOnly: Bool

    public init(content: GoalsNativeCalibrationContent) {
        closureID = content.closure.id
        goalID = content.primaryGoal.id
        goalTitle = content.primaryGoal.title
        lifeAreaTitle = content.primaryGoal.lifeAreaTitle
        entries = content.closure.history
        accessibilityReadingOrder = [content.primaryGoal.title]
            + content.closure.history.map { "\($0.title). \($0.detail)" }
        isInspectionOnly = true
    }
}

struct GoalsNativeCalibrationClosureHistoryView: View {
    let content: GoalsNativeCalibrationContent
    let palette: GoalsNativeCalibrationPalette

    private var presentation: GoalsNativeCalibrationClosureHistoryPresentation {
        GoalsNativeCalibrationClosureHistoryPresentation(content: content)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                goalIdentity
                    .accessibilitySortPriority(5)
                trustCue
                    .accessibilitySortPriority(4)
                historyEntries
                    .accessibilitySortPriority(3)
            }
            .frame(maxWidth: 560, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 42)
        }
        .background(palette.canvas.ignoresSafeArea())
        .foregroundStyle(palette.primaryInk)
        .goalsNativeCalibrationDepthNavigation(title: "Closure history")
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("gnc-r03-closure-history")
    }

    private var goalIdentity: some View {
        HStack(alignment: .top, spacing: 14) {
            GoalsNativeCalibrationPursuitAnchor(
                goalID: presentation.goalID,
                resolution: .selected,
                palette: palette
            )
            .padding(.top, 3)

            VStack(alignment: .leading, spacing: 5) {
                Text(presentation.lifeAreaTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.secondaryInk)
                Text(presentation.goalTitle)
                    .font(GoalsNativeCalibrationTypographyRole.objectIdentity.font)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("gnc-r03-closure-history-goal")
    }

    private var trustCue: some View {
        HStack(alignment: .top, spacing: 11) {
            Image(systemName: "iphone")
                .font(.body.weight(.semibold))
                .foregroundStyle(palette.secondaryInk)
                .accessibilityHidden(true)
            Text("Retained with this local evaluation fixture. No cloud state is implied.")
                .font(.subheadline)
                .foregroundStyle(palette.secondaryInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(minHeight: 44)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("gnc-r03-closure-history-local")
    }

    private var historyEntries: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(presentation.entries.enumerated()), id: \.element.id) { index, entry in
                VStack(alignment: .leading, spacing: 7) {
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Circle()
                            .fill(index == 0 ? palette.primaryInk : palette.acceptedFoundation)
                            .frame(width: index == 0 ? 8 : 6, height: index == 0 ? 8 : 6)
                            .accessibilityHidden(true)
                        Text(entry.title)
                            .font(.headline)
                    }
                    Text(entry.detail)
                        .font(.body)
                        .foregroundStyle(palette.secondaryInk)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.leading, 18)
                }
                .padding(.vertical, 17)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .bottom) {
                    if index < presentation.entries.count - 1 {
                        Rectangle()
                            .fill(palette.separator)
                            .frame(height: palette.markerWidth)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(entry.title). \(entry.detail)")
                .accessibilityIdentifier("gnc-r03-closure-history-entry-\(entry.id)")
            }
        }
    }
}

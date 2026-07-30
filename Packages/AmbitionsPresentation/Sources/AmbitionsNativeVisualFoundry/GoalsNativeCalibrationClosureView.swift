import SwiftUI

public struct GoalsNativeCalibrationClosurePresentation: Equatable, Sendable {
    public let closureID: String
    public let goalID: String
    public let goalTitle: String
    public let lifeAreaTitle: String
    public let finalAcceptedTruth: String
    public let proofMoments: [String]
    public let relationshipResult: String
    public let remainingOpenItem: String
    public let isOutcomeAchieved: Bool
    public let isGoalClosed: Bool
    public let historyEntryCount: Int
    public let accessibilityReadingOrder: [String]
    public let isInspectionOnly: Bool

    public init(content: GoalsNativeCalibrationContent) {
        let closure = content.closure
        let proofByID = Dictionary(uniqueKeysWithValues: content.proofMoments.map { ($0.id, $0.title) })
        closureID = closure.id
        goalID = closure.goalID
        goalTitle = content.primaryGoal.title
        lifeAreaTitle = content.primaryGoal.lifeAreaTitle
        finalAcceptedTruth = closure.acceptedTruth
        proofMoments = closure.proofIDs.compactMap { proofByID[$0] }
        relationshipResult = closure.relationshipResult
        remainingOpenItem = closure.remainingOpenItem
        isOutcomeAchieved = closure.isOutcomeAchieved
        isGoalClosed = closure.isGoalClosed
        historyEntryCount = closure.history.count
        accessibilityReadingOrder = [
            content.primaryGoal.title,
            closure.acceptedTruth,
            proofMoments.joined(separator: ", "),
            closure.relationshipResult,
            closure.remainingOpenItem,
            "\(closure.history.count) retained history entries",
            "Return to Goal"
        ]
        isInspectionOnly = true
    }
}

struct GoalsNativeCalibrationClosureView: View {
    @AccessibilityFocusState private var closureIdentityFocused: Bool

    let content: GoalsNativeCalibrationContent
    let palette: GoalsNativeCalibrationPalette
    let viewHistory: () -> Void
    let returnToGoal: () -> Void

    private var presentation: GoalsNativeCalibrationClosurePresentation {
        GoalsNativeCalibrationClosurePresentation(content: content)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 27) {
                goalIdentity
                    .accessibilitySortPriority(9)
                settledTruth
                    .accessibilitySortPriority(8)
                proofFoundation
                    .accessibilitySortPriority(7)
                settledPathContinuity
                    .accessibilitySortPriority(6)
                protectedRelationship
                    .accessibilitySortPriority(5)
                remainingOpenWork
                    .accessibilitySortPriority(4)
                historyAction
                    .accessibilitySortPriority(3)
                returnAction
                    .accessibilitySortPriority(2)
            }
            .frame(maxWidth: 560, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 42)
        }
        .background(palette.canvas.ignoresSafeArea())
        .foregroundStyle(palette.primaryInk)
        .goalsNativeCalibrationDepthNavigation(title: "Goal closed")
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("gnc-r03-closure")
        .onAppear { closureIdentityFocused = true }
    }

    private var goalIdentity: some View {
        HStack(alignment: .top, spacing: 14) {
            GoalsNativeCalibrationPursuitAnchor(
                goalID: presentation.goalID,
                resolution: .focused,
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
        .accessibilityIdentifier("gnc-r03-closure-goal")
        .accessibilityFocused($closureIdentityFocused)
    }

    private var settledTruth: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 8) {
                settledMarker
                Text("Outcome achieved · Goal closed")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.secondaryInk)
            }
            Text(presentation.finalAcceptedTruth)
                .font(.title2.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Outcome achieved. Goal closed. \(presentation.finalAcceptedTruth)")
        .accessibilityIdentifier("gnc-r03-closure-truth")
    }

    private var settledMarker: some View {
        ZStack {
            Circle()
                .strokeBorder(palette.primaryInk, lineWidth: palette.markerWidth)
                .frame(width: 19, height: 19)
            Circle()
                .fill(palette.primaryInk)
                .frame(width: 7, height: 7)
        }
        .accessibilityHidden(true)
    }

    private var proofFoundation: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recorded support for this truth")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.secondaryInk)
            GoalsNativeCalibrationProofFoundation(
                moments: presentation.proofMoments,
                palette: palette,
                expanded: true
            )
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("gnc-r03-closure-proof")
    }

    private var settledPathContinuity: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("Settled Path remains inspectable")
                .font(.subheadline.weight(.semibold))

            HStack(alignment: .center, spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .fill(palette.acceptedFoundation.opacity(1 - Double(index) * 0.16))
                        .frame(width: CGFloat(28 - index * 5), height: CGFloat(5 + index))
                }
                Rectangle()
                    .fill(palette.separator)
                    .frame(maxWidth: .infinity)
                    .frame(height: palette.markerWidth)
                settledMarker
            }
            .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Completed and settled Path continuity remains inspectable")
        .accessibilityIdentifier("gnc-r03-closure-path-continuity")
    }

    private var protectedRelationship: some View {
        HStack(alignment: .top, spacing: 13) {
            VStack(spacing: 4) {
                Capsule()
                    .fill(palette.protectedBoundary)
                    .frame(width: max(3, palette.markerWidth + 1), height: 28)
                Capsule()
                    .fill(palette.primaryInk.opacity(0.44))
                    .frame(width: max(3, palette.markerWidth + 1))
            }
            .frame(width: 10)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text("Protected relationship retained")
                    .font(.subheadline.weight(.semibold))
                Text(presentation.relationshipResult)
                    .font(.title3.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("gnc-r03-closure-relationship")
    }

    private var remainingOpenWork: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Remaining open work")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.secondaryInk)
            Text(presentation.remainingOpenItem)
                .font(.body.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
            Text("This does not undo the achieved Goal outcome.")
                .font(.subheadline)
                .foregroundStyle(palette.secondaryInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 8)
        .overlay(alignment: .leading) {
            Capsule()
                .stroke(
                    palette.primaryInk.opacity(0.52),
                    style: StrokeStyle(lineWidth: palette.markerWidth, dash: [5, 5])
                )
                .frame(width: max(5, palette.markerWidth + 3))
        }
        .padding(.leading, 17)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("gnc-r03-closure-remaining")
    }

    private var historyAction: some View {
        Button(action: viewHistory) {
            HStack(spacing: 12) {
                Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                    .foregroundStyle(palette.secondaryInk)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Inspect local closure history")
                        .font(.headline)
                    Text("\(presentation.historyEntryCount) retained entries")
                        .font(.subheadline)
                        .foregroundStyle(palette.secondaryInk)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.forward")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.tertiaryInk)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens retained local history without changing the Goal")
        .accessibilityIdentifier("gnc-r03-closure-history-action")
    }

    private var returnAction: some View {
        Button(action: returnToGoal) {
            Label("Return to Goal", systemImage: "arrow.backward")
        }
        .buttonStyle(GoalsNativeCalibrationNavigationButtonStyle(palette: palette))
        .accessibilityHint("Returns to the focused Goal")
        .accessibilityIdentifier("gnc-r03-closure-return")
    }
}

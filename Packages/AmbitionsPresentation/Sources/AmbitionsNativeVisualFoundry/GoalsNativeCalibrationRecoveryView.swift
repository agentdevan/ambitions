import SwiftUI

public struct GoalsNativeCalibrationRecoveryPresentation: Equatable, Sendable {
    public let recoveryID: String
    public let goalID: String
    public let goalTitle: String
    public let lifeAreaTitle: String
    public let retainedAcceptedTruth: String
    public let proofMoments: [String]
    public let interruptionFact: String
    public let unchangedPathStatement: String
    public let interruptedMovement: String
    public let possibleNext: String
    public let actions: [String]
    public let accessibilityReadingOrder: [String]
    public let isInspectionOnly: Bool

    public init(content: GoalsNativeCalibrationContent) {
        let recovery = content.recovery
        let proofByID = Dictionary(uniqueKeysWithValues: content.proofMoments.map { ($0.id, $0.title) })
        recoveryID = recovery.id
        goalID = recovery.goalID
        goalTitle = content.primaryGoal.title
        lifeAreaTitle = content.primaryGoal.lifeAreaTitle
        retainedAcceptedTruth = recovery.retainedAcceptedTruth
        proofMoments = recovery.retainedProofIDs.compactMap { proofByID[$0] }
        interruptionFact = recovery.interruptionFact
        unchangedPathStatement = recovery.unchangedPathStatement
        interruptedMovement = content.goalPath.node(id: recovery.interruptedPathNodeID)?.title ?? "Current movement"
        possibleNext = content.goalPath.node(id: recovery.possibleNextPathNodeID)?.title ?? "Possible next"
        actions = ["Review current Path", "Inspect possible next", "Keep unresolved"]
        accessibilityReadingOrder = [
            content.primaryGoal.title,
            recovery.retainedAcceptedTruth,
            recovery.interruptionFact,
            recovery.unchangedPathStatement,
            possibleNext
        ] + actions
        isInspectionOnly = true
    }
}

struct GoalsNativeCalibrationRecoveryView: View {
    @AccessibilityFocusState private var recoveryIdentityFocused: Bool

    let content: GoalsNativeCalibrationContent
    let palette: GoalsNativeCalibrationPalette
    let reviewCurrentPath: () -> Void
    let inspectPossibleNext: () -> Void
    let keepUnresolved: () -> Void

    private var presentation: GoalsNativeCalibrationRecoveryPresentation {
        GoalsNativeCalibrationRecoveryPresentation(content: content)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                goalIdentity
                    .accessibilitySortPriority(8)
                acceptedTruth
                    .accessibilitySortPriority(7)
                interruptionSeam
                    .accessibilitySortPriority(6)
                pathContinuity
                    .accessibilitySortPriority(5)
                possibleNext
                    .accessibilitySortPriority(4)
                actions
                    .accessibilitySortPriority(3)
            }
            .frame(maxWidth: 560, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 42)
        }
        .background(palette.canvas.ignoresSafeArea())
        .foregroundStyle(palette.primaryInk)
        .goalsNativeCalibrationDepthNavigation(title: "Recovery")
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("gnc-r03-recovery")
        .onAppear { recoveryIdentityFocused = true }
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
        .accessibilityIdentifier("gnc-r03-recovery-goal")
        .accessibilityFocused($recoveryIdentityFocused)
    }

    private var acceptedTruth: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Accepted truth remains")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.secondaryInk)
            Text(presentation.retainedAcceptedTruth)
                .font(GoalsNativeCalibrationTypographyRole.truth.font)
                .fixedSize(horizontal: false, vertical: true)
            GoalsNativeCalibrationProofFoundation(
                moments: presentation.proofMoments,
                palette: palette,
                expanded: true
            )
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("gnc-r03-recovery-truth")
    }

    private var interruptionSeam: some View {
        HStack(alignment: .top, spacing: 13) {
            VStack(spacing: 4) {
                Capsule()
                    .fill(palette.primaryInk.opacity(0.56))
                    .frame(width: max(3, palette.markerWidth + 1), height: 24)
                Capsule()
                    .fill(palette.canvas)
                    .overlay {
                        Capsule().stroke(palette.primaryInk, lineWidth: palette.markerWidth)
                    }
                    .frame(width: max(5, palette.markerWidth + 3), height: 11)
                Capsule()
                    .fill(palette.primaryInk.opacity(0.32))
                    .frame(width: max(3, palette.markerWidth + 1), height: 22)
            }
            .frame(width: 12)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 7) {
                Text("Current movement interrupted")
                    .font(.subheadline.weight(.semibold))
                Text(presentation.interruptionFact)
                    .font(.title3.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
                Text(presentation.interruptedMovement)
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryInk)
            }
        }
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(palette.separator)
                .frame(height: palette.markerWidth)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("gnc-r03-recovery-interruption")
    }

    private var pathContinuity: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Path retained")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.secondaryInk)
            Text(presentation.unchangedPathStatement)
                .font(.body.weight(.medium))
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("gnc-r03-recovery-path-statement")
    }

    private var possibleNext: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Possible next · not accepted")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.secondaryInk)
            Text(presentation.possibleNext)
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 10)
        .overlay(alignment: .leading) {
            Capsule()
                .stroke(
                    palette.primaryInk.opacity(0.58),
                    style: StrokeStyle(lineWidth: palette.markerWidth, dash: [5, 5])
                )
                .frame(width: max(5, palette.markerWidth + 3))
        }
        .padding(.leading, 17)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("gnc-r03-recovery-possible-next")
    }

    private var actions: some View {
        VStack(spacing: 10) {
            Button(action: reviewCurrentPath) {
                Label("Review current Path", systemImage: "point.forward.to.point.capsulepath")
            }
            .buttonStyle(GoalsNativeCalibrationNavigationButtonStyle(palette: palette))
            .accessibilityHint("Inspects the unchanged Path at the interrupted current movement")
            .accessibilityIdentifier("gnc-r03-recovery-review-path")

            Button(action: inspectPossibleNext) {
                Label("Inspect possible next", systemImage: "arrow.forward")
            }
            .buttonStyle(GoalsNativeCalibrationNavigationButtonStyle(palette: palette))
            .accessibilityHint("Inspects a possible alternative without accepting it")
            .accessibilityIdentifier("gnc-r03-recovery-possible")

            Button(action: keepUnresolved) {
                Text("Keep unresolved")
            }
            .buttonStyle(.plain)
            .font(.headline)
            .foregroundStyle(palette.secondaryInk)
            .frame(maxWidth: .infinity, minHeight: 48)
            .contentShape(Rectangle())
            .accessibilityHint("Returns with accepted truth and Path unchanged")
            .accessibilityIdentifier("gnc-r03-recovery-keep")
        }
    }
}

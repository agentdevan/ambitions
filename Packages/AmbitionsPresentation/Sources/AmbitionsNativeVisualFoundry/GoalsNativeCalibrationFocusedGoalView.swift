import SwiftUI

public struct GoalsNativeCalibrationFocusedGoalPresentation: Equatable, Sendable {
    public let goalID: String
    public let goalTitle: String
    public let lifeAreaID: String
    public let lifeAreaTitle: String
    public let currentDirection: String
    public let currentTruth: String
    public let activeThread: String
    public let nextMovement: String
    public let materialConsequence: String
    public let proofMoments: [String]
    public let scheduleFit: String
    public let pathActionTitle: String

    public init(content: GoalsNativeCalibrationContent) {
        goalID = content.primaryGoal.id
        goalTitle = content.primaryGoal.title
        lifeAreaID = content.primaryGoal.lifeAreaID
        lifeAreaTitle = content.primaryGoal.lifeAreaTitle
        currentDirection = content.primaryGoal.currentDirection
        currentTruth = content.primaryGoal.currentAcceptedTruth
        activeThread = content.primaryGoal.activeThread
        nextMovement = content.primaryGoal.nextMeaningfulMovement
        materialConsequence = content.primaryGoal.materialConsequence
        proofMoments = content.linkedLens.proofPosture
        scheduleFit = content.primaryGoal.scheduleFit
        pathActionTitle = "View Goal Path"
    }
}

struct GoalsNativeCalibrationFocusedGoalView: View {
    let content: GoalsNativeCalibrationContent
    @Binding var state: GoalsNativeCalibrationJourneyState
    let palette: GoalsNativeCalibrationPalette

    private var presentation: GoalsNativeCalibrationFocusedGoalPresentation {
        GoalsNativeCalibrationFocusedGoalPresentation(content: content)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                identity
                currentPursuit
                consequenceAndFit
                recordedMoments
                depthActions
            }
            .frame(maxWidth: 560, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 18)
            .padding(.bottom, 36)
        }
        .background(palette.canvas.ignoresSafeArea())
        .foregroundStyle(palette.primaryInk)
        .goalsNativeCalibrationDepthNavigation(title: "Goal")
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("gnc-focused-goal")
    }

    private var identity: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                GoalsNativeCalibrationMarker(kind: .selectedGoal, palette: palette)
                    .padding(.top, 3)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Living pursuit")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(palette.accent)
                    Text(presentation.goalTitle)
                        .font(.largeTitle.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier("gnc-focused-goal-title")
                }
            }

            HStack(spacing: 9) {
                Image(systemName: "square.grid.2x2")
                    .foregroundStyle(palette.accent)
                    .accessibilityHidden(true)
                Text(presentation.lifeAreaTitle)
                    .font(.body.weight(.medium))
                    .accessibilityIdentifier("gnc-focused-goal-life-area")
                Text("Life Area")
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryInk)
            }
            .frame(minHeight: 44)
        }
    }

    private var currentPursuit: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Current direction")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.secondaryInk)
                Text(presentation.currentDirection)
                    .font(GoalsNativeCalibrationTypographyRole.relationship.font)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("gnc-focused-current-direction")
            }

            GoalsNativeCalibrationOpenRelief(palette: palette) {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("What is true")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(palette.accent)
                        Text(presentation.currentTruth)
                            .font(GoalsNativeCalibrationTypographyRole.truth.font)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("gnc-focused-current-truth")
                    }

                    relationshipLine(
                        label: "Active thread",
                        value: presentation.activeThread,
                        symbol: "point.forward.to.point.capsulepath",
                        identifier: "gnc-focused-active-thread"
                    )
                    relationshipLine(
                        label: "Next movement",
                        value: presentation.nextMovement,
                        symbol: "arrow.forward",
                        identifier: "gnc-focused-next-movement"
                    )
                }
            }
        }
    }

    private var consequenceAndFit: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text("What this protects")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.secondaryInk)
                Text(presentation.materialConsequence)
                    .font(GoalsNativeCalibrationTypographyRole.relationship.font)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "clock")
                    .foregroundStyle(palette.accent)
                    .accessibilityHidden(true)
                Text(presentation.scheduleFit)
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("gnc-focused-schedule-fit")
            }
            .frame(minHeight: 44, alignment: .top)
        }
    }

    private var recordedMoments: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("Recorded moments")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.secondaryInk)

            ForEach(presentation.proofMoments, id: \.self) { proof in
                HStack(spacing: 10) {
                    GoalsNativeCalibrationMarker(kind: .proof, palette: palette)
                    Text(proof)
                        .font(.subheadline)
                }
                .frame(minHeight: 30)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(presentation.proofMoments.joined(separator: ", "))
        .accessibilityIdentifier("gnc-focused-proof")
    }

    private var depthActions: some View {
        VStack(spacing: 0) {
            Button {
                _ = state.openRelationship()
            } label: {
                navigationRow(
                    title: content.relationship.relatedGoalTitle,
                    subtitle: "See the consequence shared with Relationships"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Inspect relationship with (content.relationship.relatedGoalTitle)")
            .accessibilityIdentifier("gnc-open-relationship")

            Rectangle().fill(palette.separator).frame(height: 1)

            Button {
                _ = state.openGoalPath()
            } label: {
                navigationRow(
                    title: presentation.pathActionTitle,
                    subtitle: "See current, next, and recorded pursuit moments"
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("gnc-view-goal-path")
        }
    }

    private func relationshipLine(
        label: String,
        value: String,
        symbol: String,
        identifier: String
    ) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: symbol)
                .foregroundStyle(palette.accent)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(palette.tertiaryInk)
                Text(value)
                    .font(.body.weight(.medium))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier(identifier)
            }
        }
    }

    private func navigationRow(title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(palette.primaryInk)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.forward")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.secondaryInk)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
        .padding(.vertical, 7)
        .contentShape(Rectangle())
    }
}

import SwiftUI

public enum GoalsNativeCalibrationFutureCertainty: Equatable, Sendable {
    case possible
    case conditional
}

public struct GoalsNativeCalibrationFuturePosture: Equatable, Sendable {
    public let certainty: GoalsNativeCalibrationFutureCertainty
    public let title: String

    public init(certainty: GoalsNativeCalibrationFutureCertainty, title: String) {
        self.certainty = certainty
        self.title = title
    }
}

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
    public let proofDisclosureTitle: String
    public let futurePostures: [GoalsNativeCalibrationFuturePosture]
    public let protectedRelationshipTitle: String

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
        proofDisclosureTitle = "\(content.linkedLens.proofPosture.count) recorded moments"
        futurePostures = [
            GoalsNativeCalibrationFuturePosture(
                certainty: .possible,
                title: content.primaryGoal.followingMovement
            ),
            GoalsNativeCalibrationFuturePosture(
                certainty: .conditional,
                title: content.goalPath.nodes.first { $0.state == .conditional }?.title ?? ""
            )
        ]
        protectedRelationshipTitle = content.relationship.relatedGoalTitle
    }
}

struct GoalsNativeCalibrationFocusedGoalView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.goalsNativeCalibrationForceReduceMotion) private var forceReduceMotion

    let content: GoalsNativeCalibrationContent
    @Binding var state: GoalsNativeCalibrationJourneyState
    let palette: GoalsNativeCalibrationPalette

    @State private var isProofExpanded = false
    @State private var isFutureExpanded = false

    private var presentation: GoalsNativeCalibrationFocusedGoalPresentation {
        GoalsNativeCalibrationFocusedGoalPresentation(content: content)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                identity
                    .padding(.bottom, 22)
                acceptedTruth
                currentMovement
                    .padding(.top, 20)
                futureField
                    .padding(.top, 24)
            }
            .frame(maxWidth: 560, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 52)
        }
        .background(palette.canvas.ignoresSafeArea())
        .foregroundStyle(palette.primaryInk)
        .goalsNativeCalibrationDepthNavigation(title: presentation.goalTitle)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("gnc-focused-goal")
    }

    private var identity: some View {
        HStack(alignment: .top, spacing: 12) {
            GoalsNativeCalibrationGoalSeam(palette: palette, emphasis: .focused)
                .padding(.top, 3)

            VStack(alignment: .leading, spacing: 6) {
                Text(presentation.lifeAreaTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.secondaryInk)
                    .accessibilityIdentifier("gnc-focused-goal-life-area")
                Text(presentation.goalTitle)
                    .font(.title.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("gnc-focused-goal-title")
                Text(presentation.currentDirection)
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var acceptedTruth: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("True now")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(palette.secondaryInk)
                Text(presentation.currentTruth)
                    .font(.title3.weight(.medium))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("gnc-focused-current-truth")
            }
            .padding(.leading, 16)
            .padding(.vertical, 16)
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(palette.primaryInk.opacity(0.62))
                    .frame(width: palette.markerWidth)
            }

            Button {
                withAnimation(shouldReduceMotion ? nil : .easeInOut(duration: 0.22)) {
                    isProofExpanded.toggle()
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle")
                        .foregroundStyle(palette.secondaryInk)
                        .accessibilityHidden(true)
                    Text(presentation.proofDisclosureTitle)
                        .font(.subheadline.weight(.medium))
                    Spacer(minLength: 8)
                    Image(systemName: isProofExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(palette.secondaryInk)
                        .accessibilityHidden(true)
                }
                .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
                .padding(.horizontal, 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityValue(isProofExpanded ? "Expanded" : "Collapsed")
            .accessibilityHint("Shows the recorded support for the accepted truth")
            .accessibilityIdentifier("gnc-focused-proof-disclosure")

            if isProofExpanded {
                VStack(alignment: .leading, spacing: 9) {
                    ForEach(presentation.proofMoments, id: \.self) { proof in
                        HStack(spacing: 9) {
                            Circle()
                                .fill(palette.secondaryInk)
                                .frame(width: 4, height: 4)
                                .accessibilityHidden(true)
                            Text(proof)
                                .font(.subheadline)
                        }
                    }
                }
                .padding(.leading, 44)
                .padding(.trailing, 16)
                .padding(.bottom, 14)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(presentation.proofMoments.joined(separator: ", "))
                .accessibilityIdentifier("gnc-focused-proof")
            }
        }
        .background(palette.relief.opacity(0.72))
    }

    private var currentMovement: some View {
        NavigationLink(value: GoalsNativeCalibrationRoute.goalPath(id: content.goalPath.id)) {
            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 4) {
                    Circle()
                        .fill(palette.accent)
                        .frame(width: 8, height: 8)
                    Rectangle()
                        .fill(palette.accent.opacity(0.44))
                        .frame(width: 2, height: 34)
                }
                .frame(width: 20)
                .padding(.top, 4)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Current movement")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(palette.accent)
                    Text(presentation.nextMovement)
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(presentation.activeThread)
                        .font(.subheadline)
                        .foregroundStyle(palette.secondaryInk)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.forward")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.tertiaryInk)
                    .frame(width: 20, height: 44)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, minHeight: 84, alignment: .leading)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Current movement, \(presentation.nextMovement)")
        .accessibilityHint("Opens Goal Path")
        .accessibilityIdentifier("gnc-current-movement-path")
    }

    private var futureField: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(shouldReduceMotion ? nil : .easeInOut(duration: 0.22)) {
                    isFutureExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("What may follow")
                            .font(.headline)
                        Text("One near possibility; later details remain open")
                            .font(.subheadline)
                            .foregroundStyle(palette.secondaryInk)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: isFutureExpanded ? "chevron.up" : "chevron.down")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(palette.secondaryInk)
                        .accessibilityHidden(true)
                }
                .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityValue(isFutureExpanded ? "Expanded" : "Collapsed")
            .accessibilityIdentifier("gnc-future-disclosure")

            if isFutureExpanded {
                certaintyPassage
                    .transition(.opacity)
            }
        }
    }

    private var certaintyPassage: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(presentation.futurePostures.enumerated()), id: \.offset) { index, posture in
                HStack(alignment: .top, spacing: 12) {
                    futureMarker(posture.certainty)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(posture.certainty == .possible ? "Possible next" : "Depends on what becomes true")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(palette.secondaryInk)
                        Text(posture.title)
                            .font(posture.certainty == .possible ? .body.weight(.medium) : .subheadline)
                            .foregroundStyle(
                                posture.certainty == .possible ? palette.primaryInk : palette.secondaryInk
                            )
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: index == 0 ? 72 : 66, alignment: .leading)
                .padding(.vertical, 8)
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier(
                    posture.certainty == .possible ? "gnc-future-possible" : "gnc-future-conditional"
                )
            }

            NavigationLink(
                value: GoalsNativeCalibrationRoute.relationship(
                    primaryGoalID: content.relationship.primaryGoalID,
                    relatedGoalID: content.relationship.relatedGoalID
                )
            ) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "shield.lefthalf.filled")
                        .foregroundStyle(palette.secondaryInk)
                        .frame(width: 24, height: 30)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(presentation.protectedRelationshipTitle)
                            .font(.body.weight(.semibold))
                        Text(content.relationship.practicalConsequence)
                            .font(.subheadline)
                            .foregroundStyle(palette.secondaryInk)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(palette.tertiaryInk)
                        .frame(width: 20, height: 44)
                        .accessibilityHidden(true)
                }
                .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
                .padding(.leading, 10)
                .padding(.vertical, 10)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(palette.secondaryInk.opacity(0.58))
                        .frame(width: palette.markerWidth)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(presentation.protectedRelationshipTitle)
            .accessibilityValue(content.relationship.practicalConsequence)
            .accessibilityHint("Inspects the consequential relationship")
            .accessibilityIdentifier("gnc-open-relationship")
        }
        .padding(.top, 12)
    }

    @ViewBuilder
    private func futureMarker(_ certainty: GoalsNativeCalibrationFutureCertainty) -> some View {
        switch certainty {
        case .possible:
            Circle()
                .strokeBorder(palette.secondaryInk, lineWidth: palette.markerWidth)
                .frame(width: 14, height: 14)
                .frame(width: 24, height: 30)
                .accessibilityHidden(true)
        case .conditional:
            Circle()
                .trim(from: 0.12, to: 0.68)
                .stroke(
                    palette.tertiaryInk,
                    style: StrokeStyle(lineWidth: palette.markerWidth, lineCap: .round, dash: [3, 3])
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 14, height: 14)
                .frame(width: 24, height: 30)
                .accessibilityHidden(true)
        }
    }

    private var shouldReduceMotion: Bool {
        reduceMotion || forceReduceMotion
    }
}

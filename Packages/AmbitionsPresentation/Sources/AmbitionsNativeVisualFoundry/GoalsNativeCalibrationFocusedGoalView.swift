import SwiftUI

public enum GoalsNativeCalibrationFutureCertainty: Equatable, Sendable {
    case possible
    case conditional
}

public enum GoalsNativeCalibrationFutureMaterialPresence: Equatable, Sendable {
    case partial
    case boundaryOnly
}

public enum GoalsNativeCalibrationPrimaryOperation: Equatable, Sendable {
    case currentMovement
}

public enum GoalsNativeCalibrationFutureBoundary: Equatable, Sendable {
    case protectedRelationship
}

public struct GoalsNativeCalibrationFuturePosture: Equatable, Sendable {
    public let certainty: GoalsNativeCalibrationFutureCertainty
    public let title: String
    public let materialPresence: GoalsNativeCalibrationFutureMaterialPresence

    public init(
        certainty: GoalsNativeCalibrationFutureCertainty,
        title: String,
        materialPresence: GoalsNativeCalibrationFutureMaterialPresence
    ) {
        self.certainty = certainty
        self.title = title
        self.materialPresence = materialPresence
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
    public let proofFoundation: [String]
    public let scheduleFit: String
    public let pathActionTitle: String
    public let proofDisclosureTitle: String
    public let futurePostures: [GoalsNativeCalibrationFuturePosture]
    public let protectedRelationshipTitle: String
    public let primaryOperation: GoalsNativeCalibrationPrimaryOperation
    public let futureBoundary: GoalsNativeCalibrationFutureBoundary

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
        proofFoundation = content.linkedLens.proofPosture
        scheduleFit = content.primaryGoal.scheduleFit
        pathActionTitle = "View Goal Path"
        proofDisclosureTitle = "\(content.linkedLens.proofPosture.count) recorded moments"
        futurePostures = [
            GoalsNativeCalibrationFuturePosture(
                certainty: .possible,
                title: content.primaryGoal.followingMovement,
                materialPresence: .partial
            ),
            GoalsNativeCalibrationFuturePosture(
                certainty: .conditional,
                title: content.goalPath.nodes.first { $0.state == .conditional }?.title ?? "",
                materialPresence: .boundaryOnly
            )
        ]
        protectedRelationshipTitle = content.relationship.relatedGoalTitle
        primaryOperation = .currentMovement
        futureBoundary = .protectedRelationship
    }
}

struct GoalsNativeCalibrationFocusedGoalView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.goalsNativeCalibrationForceReduceMotion) private var forceReduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let content: GoalsNativeCalibrationContent
    @Binding var state: GoalsNativeCalibrationJourneyState
    let palette: GoalsNativeCalibrationPalette

    @State private var isProofExpanded = false
    @State private var isFutureExpanded = false
    @AccessibilityFocusState private var accessibilityFocus: GoalsNativeCalibrationFocusAnchor?

    let depthEntryMode: GoalsNativeCalibrationDepthEntryMode

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
                depthEntry
                    .padding(.top, depthEntryMode == .active ? 0 : 14)
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
        .onAppear(perform: restoreAccessibilityFocus)
        .onChange(of: state.focusAnchor) { _, _ in
            restoreAccessibilityFocus()
        }
    }

    private var identity: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 16) {
                        focusedAnchor
                        VStack(alignment: .leading, spacing: 7) {
                            lifeAreaIdentity
                            goalIdentity
                        }
                    }
                    goalDirection
                }
            } else {
                HStack(alignment: .top, spacing: 15) {
                    focusedAnchor
                        .padding(.top, 4)
                    identityText
                }
            }
        }
    }

    private var focusedAnchor: some View {
        GoalsNativeCalibrationPursuitAnchor(
            goalID: presentation.goalID,
            resolution: .focused,
            palette: palette
        )
        .accessibilityIdentifier("gnc-focused-pursuit-anchor")
    }

    private var identityText: some View {
        VStack(alignment: .leading, spacing: 7) {
            lifeAreaIdentity
            goalIdentity
            goalDirection
        }
    }

    private var lifeAreaIdentity: some View {
        Text(presentation.lifeAreaTitle)
            .font((dynamicTypeSize.isAccessibilitySize ? Font.headline : .subheadline).weight(.semibold))
            .foregroundStyle(palette.secondaryInk)
            .accessibilityIdentifier("gnc-focused-goal-life-area")
    }

    private var goalIdentity: some View {
        Text(presentation.goalTitle)
            .font((dynamicTypeSize.isAccessibilitySize ? Font.title3 : .title2).weight(.bold))
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier("gnc-focused-goal-title")
    }

    private var goalDirection: some View {
        Text(presentation.currentDirection)
            .font(.body)
            .foregroundStyle(palette.secondaryInk)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var acceptedTruth: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 9) {
                Text("Accepted now")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.secondaryInk)
                Text(presentation.currentTruth)
                    .font(GoalsNativeCalibrationTypographyRole.truth.font)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("gnc-focused-current-truth")
            }

            Button {
                withAnimation(shouldReduceMotion ? nil : .easeInOut(duration: 0.22)) {
                    isProofExpanded.toggle()
                }
            } label: {
                HStack(alignment: .center, spacing: 14) {
                    GoalsNativeCalibrationProofFoundation(
                        moments: presentation.proofFoundation,
                        palette: palette,
                        expanded: isProofExpanded
                    )
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Recorded support")
                            .font(.subheadline.weight(.semibold))
                        Text(presentation.proofDisclosureTitle)
                            .font(.subheadline)
                            .foregroundStyle(palette.secondaryInk)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: isProofExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(palette.secondaryInk)
                        .accessibilityHidden(true)
                }
                .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityValue(isProofExpanded ? "Expanded" : "Collapsed")
            .accessibilityHint("Shows the recorded support for the accepted truth")
            .accessibilityIdentifier("gnc-focused-proof-disclosure")

            if isProofExpanded {
                Text("Together, these moments establish the accepted truth above.")
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(presentation.proofMoments.joined(separator: ", "))
                .accessibilityIdentifier("gnc-focused-proof")
            }
        }
        .padding(.vertical, 18)
        .overlay(alignment: .bottom) {
            HStack(spacing: 5) {
                ForEach(Array(presentation.proofMoments.indices), id: \.self) { index in
                    Capsule()
                        .fill(palette.acceptedFoundation.opacity(1 - Double(index) * 0.16))
                        .frame(maxWidth: index == 0 ? .infinity : 64)
                        .frame(height: 5)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var currentMovement: some View {
        NavigationLink(value: GoalsNativeCalibrationRoute.goalPath(id: content.goalPath.id)) {
            HStack(alignment: .top, spacing: 12) {
                Capsule()
                    .fill(palette.accent)
                    .frame(width: 6, height: 62)
                    .frame(width: 20)
                .padding(.top, 4)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Current movement")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(palette.secondaryInk)
                    Text(presentation.nextMovement)
                        .font(.title3.weight(.bold))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(presentation.activeThread)
                        .font(.body)
                        .foregroundStyle(palette.secondaryInk)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.forward")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.tertiaryInk)
                    .frame(width: 20, height: 44)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, minHeight: 108, alignment: .leading)
            .padding(.vertical, 14)
            .overlay(alignment: .bottomLeading) {
                HStack(spacing: 5) {
                    Capsule()
                        .fill(palette.accent.opacity(0.44))
                        .frame(maxWidth: .infinity)
                    Capsule()
                        .fill(palette.futurePossibility)
                        .frame(width: 54)
                    Capsule()
                        .fill(palette.futurePossibility.opacity(0.62))
                        .frame(width: 28)
                }
                .frame(height: 5)
                .padding(.leading, 32)
                .padding(.trailing, 24)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Current movement, \(presentation.nextMovement)")
        .accessibilityValue("Primary operation")
        .accessibilityHint("Opens Goal Path")
        .accessibilityIdentifier("gnc-current-movement-path")
        .accessibilityFocused($accessibilityFocus, equals: .currentMovement)
    }

    @ViewBuilder
    private var depthEntry: some View {
        switch depthEntryMode {
        case .active:
            EmptyView()
        case .recovery:
            NavigationLink(value: GoalsNativeCalibrationRoute.recovery(id: content.recovery.id)) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "pause.circle")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(palette.secondaryInk)
                        .frame(width: 28, height: 44)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current movement interrupted")
                            .font(.body.weight(.semibold))
                        Text(content.recovery.interruptionFact)
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
                .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint("Inspects retained truth and recovery choices")
            .accessibilityIdentifier("gnc-r03-recovery-entry")
            .accessibilityFocused($accessibilityFocus, equals: .recoveryEntry)
        case .closure:
            NavigationLink(value: GoalsNativeCalibrationRoute.closure(id: content.closure.id)) {
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: "circle.circle")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(palette.secondaryInk)
                        .frame(width: 28, height: 44)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Inspect closed Goal")
                            .font(.body.weight(.semibold))
                        Text(content.closure.acceptedTruth)
                            .font(.subheadline)
                            .foregroundStyle(palette.secondaryInk)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(palette.tertiaryInk)
                        .frame(width: 20, height: 44)
                        .accessibilityHidden(true)
                }
                .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint("Inspects closure, retained history, and open work")
            .accessibilityIdentifier("gnc-r03-closure-entry")
        }
    }

    private var futureField: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button {
                withAnimation(shouldReduceMotion ? nil : .easeInOut(duration: 0.22)) {
                    isFutureExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("The pursuit ahead")
                            .font(.headline)
                        Text("The next possibility is taking shape; later truth remains open.")
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

            certaintyOverview

            if isFutureExpanded {
                certaintyPassage
                    .transition(.opacity)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("gnc-future-field")
    }

    private var certaintyOverview: some View {
        VStack(alignment: .leading, spacing: 12) {
            certaintyBand(
                title: presentation.futurePostures[0].title,
                presence: .partial,
                label: "Possible next"
            )
            certaintyBand(
                title: presentation.futurePostures[1].title,
                presence: .boundaryOnly,
                label: "Conditional"
            )
            relationshipBoundary
        }
    }

    private func certaintyBand(
        title: String,
        presence: GoalsNativeCalibrationFutureMaterialPresence,
        label: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { geometry in
                switch presence {
                case .partial:
                    Capsule()
                        .fill(palette.futurePossibility)
                        .frame(width: geometry.size.width * 0.72, height: 9)
                case .boundaryOnly:
                    Capsule()
                        .stroke(
                            palette.tertiaryInk,
                            style: StrokeStyle(lineWidth: palette.markerWidth, dash: [4, 5])
                        )
                        .frame(width: geometry.size.width * 0.46, height: 9)
                }
            }
            .frame(height: 9)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.secondaryInk)
                Text(title)
                    .font(presence == .partial ? .body.weight(.medium) : .subheadline)
                    .foregroundStyle(presence == .partial ? palette.primaryInk : palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var relationshipBoundary: some View {
        NavigationLink(
            value: GoalsNativeCalibrationRoute.relationship(
                primaryGoalID: content.relationship.primaryGoalID,
                relatedGoalID: content.relationship.relatedGoalID
            )
        ) {
            HStack(alignment: .top, spacing: 12) {
                Capsule()
                    .fill(palette.protectedBoundary)
                    .frame(width: 6, height: 54)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Protected by \(presentation.protectedRelationshipTitle)")
                        .font(.body.weight(.semibold))
                    if isFutureExpanded {
                        Text(content.relationship.practicalConsequence)
                            .font(.subheadline)
                            .foregroundStyle(palette.secondaryInk)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.forward")
                    .foregroundStyle(palette.tertiaryInk)
                    .frame(width: 20, height: 44)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(presentation.protectedRelationshipTitle)
        .accessibilityValue(content.relationship.practicalConsequence)
        .accessibilityHint("Inspects the consequential relationship")
        .accessibilityIdentifier("gnc-open-relationship")
        .accessibilityFocused($accessibilityFocus, equals: .relationshipEntry)
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

    private func restoreAccessibilityFocus() {
        switch state.focusAnchor {
        case .currentMovement, .relationshipEntry, .recoveryEntry:
            accessibilityFocus = state.focusAnchor
        default:
            break
        }
    }
}

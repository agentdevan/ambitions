import SwiftUI

public struct GoalsNativeCalibrationPathEvidencePresentation: Equatable, Sendable {
    public let goalID: String
    public let goalTitle: String
    public let lifeAreaTitle: String
    public let pathID: String
    public let nodeID: String
    public let nodeTitle: String
    public let nodeState: GoalsNativeCalibrationPathNodeState
    public let nodeDetail: String
    public let proofMoments: [GoalsNativeCalibrationProofMoment]
    public let isInspectionOnly = true

    public init?(content: GoalsNativeCalibrationContent, nodeID: String) {
        guard let node = content.goalPath.node(id: nodeID) else { return nil }
        let proofByID = Dictionary(
            uniqueKeysWithValues: content.proofMoments.map { ($0.id, $0) }
        )
        goalID = content.primaryGoal.id
        goalTitle = content.primaryGoal.title
        lifeAreaTitle = content.primaryGoal.lifeAreaTitle
        pathID = content.goalPath.id
        self.nodeID = node.id
        nodeTitle = node.title
        nodeState = node.state
        nodeDetail = node.detail
        proofMoments = node.proofIDs.compactMap { proofByID[$0] }
    }
}

struct GoalsNativeCalibrationPathEvidenceView: View {
    let content: GoalsNativeCalibrationContent
    let nodeID: String
    let palette: GoalsNativeCalibrationPalette

    private var presentation: GoalsNativeCalibrationPathEvidencePresentation? {
        GoalsNativeCalibrationPathEvidencePresentation(content: content, nodeID: nodeID)
    }

    var body: some View {
        ScrollView {
            if let presentation {
                VStack(alignment: .leading, spacing: 26) {
                    identity(presentation)
                    position(presentation)
                    evidence(presentation)
                    inspectionBoundary
                }
                .frame(maxWidth: 600, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 52)
            }
        }
        .background(palette.canvas.ignoresSafeArea())
        .foregroundStyle(palette.primaryInk)
        .goalsNativeCalibrationDepthNavigation(title: "Proof and History")
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("gnc-r03-path-evidence")
    }

    private func identity(
        _ presentation: GoalsNativeCalibrationPathEvidencePresentation
    ) -> some View {
        HStack(alignment: .top, spacing: 15) {
            GoalsNativeCalibrationPursuitAnchor(
                goalID: presentation.goalID,
                resolution: .selected,
                palette: palette
            )
            .padding(.top, 3)
            VStack(alignment: .leading, spacing: 6) {
                Text(presentation.lifeAreaTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.secondaryInk)
                Text(presentation.goalTitle)
                    .font(.title2.weight(.bold))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                Text("Goal Path evidence")
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryInk)
            }
        }
    }

    private func position(
        _ presentation: GoalsNativeCalibrationPathEvidencePresentation
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(presentation.nodeState.label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.accent)
            Text(presentation.nodeTitle)
                .font(.title3.weight(.bold))
                .fixedSize(horizontal: false, vertical: true)
            Text(presentation.nodeDetail)
                .font(GoalsNativeCalibrationTypographyRole.truth.font)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 18)
        .overlay(alignment: .topLeading) {
            HStack(spacing: 6) {
                Capsule().fill(palette.primaryInk.opacity(0.72)).frame(width: 54, height: 3)
                Capsule().fill(palette.acceptedFoundation).frame(width: 25, height: 3)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("gnc-r03-path-evidence-position")
    }

    @ViewBuilder
    private func evidence(
        _ presentation: GoalsNativeCalibrationPathEvidencePresentation
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recorded support")
                .font(.headline)
            if presentation.proofMoments.isEmpty {
                Text("No Proof is attached to this unresolved Path position.")
                    .font(.body)
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                ForEach(presentation.proofMoments) { proof in
                    HStack(alignment: .top, spacing: 13) {
                        GoalsNativeCalibrationMarker(kind: .proof, palette: palette)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(proof.title)
                                .font(.body.weight(.semibold))
                            Text("Substantiates this accepted Path truth")
                                .font(.subheadline)
                                .foregroundStyle(palette.secondaryInk)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Proof, \(proof.title), substantiates this accepted Path truth")
                    .accessibilityIdentifier("gnc-r03-path-proof-\(proof.id)")
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("gnc-r03-path-evidence-proof")
    }

    private var inspectionBoundary: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lock.open")
                .foregroundStyle(palette.secondaryInk)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text("Inspection only")
                    .font(.subheadline.weight(.semibold))
                Text("Nothing on this Path changes while you inspect its Proof and history.")
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(minHeight: 48)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("gnc-r03-path-evidence-nonmutating")
    }
}

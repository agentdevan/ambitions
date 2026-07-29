import SwiftUI

struct GoalsNativeCalibrationPathIdentity: View {
    let presentation: GoalsNativeCalibrationPathPresentation
    let usesAccessibilityLayout: Bool
    let palette: GoalsNativeCalibrationPalette

    var body: some View {
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
                    .font(identityFont)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("gnc-path-goal-title")
                Text("Accepted truth anchors the path; later positions remain increasingly open.")
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var identityFont: Font {
        usesAccessibilityLayout ? .title3.weight(.bold) : .title2.weight(.bold)
    }
}

struct GoalsNativeCalibrationPathSpatialField: View {
    let presentation: GoalsNativeCalibrationPathPresentation
    let selectedNodeID: String
    @Binding var horizontalAnchorID: String?
    let palette: GoalsNativeCalibrationPalette
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(alignment: .top, spacing: 22) {
                GoalsNativeCalibrationPathRecordedSupportField(
                    nodes: presentation.recordedSupport,
                    selectedNodeID: selectedNodeID,
                    palette: palette,
                    onSelect: onSelect
                )
                .id(presentation.recordedSupport.first?.id)

                GoalsNativeCalibrationPathCurrentSeamField(
                    node: presentation.currentSeam,
                    acceptedTruth: presentation.acceptedTruth,
                    isSelected: selectedNodeID == presentation.currentNodeID,
                    palette: palette,
                    onSelect: onSelect
                )
                .id(presentation.currentNodeID)

                GoalsNativeCalibrationPathNearMovementField(
                    node: presentation.nearMovement,
                    isSelected: selectedNodeID == presentation.nextNodeID,
                    palette: palette,
                    onSelect: onSelect
                )
                .id(presentation.nextNodeID)

                GoalsNativeCalibrationPathOpenFutureField(
                    nodes: presentation.openFuture,
                    selectedNodeID: selectedNodeID,
                    palette: palette,
                    onSelect: onSelect
                )

                GoalsNativeCalibrationPathClosureField(
                    node: presentation.closurePosture,
                    isSelected: selectedNodeID == presentation.closurePosture.id,
                    palette: palette,
                    onSelect: onSelect
                )
                .id(presentation.closurePosture.id)
            }
            .scrollTargetLayout()
            .padding(.vertical, 4)
            .padding(.trailing, 24)
        }
        .scrollIndicators(.visible)
        .scrollPosition(id: $horizontalAnchorID, anchor: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Goal Path, eight movements with declining future certainty")
        .accessibilityIdentifier("gnc-r03-path-horizontal")
    }
}

private struct GoalsNativeCalibrationPathRecordedSupportField: View {
    let nodes: [GoalsNativeCalibrationPathNode]
    let selectedNodeID: String
    let palette: GoalsNativeCalibrationPalette
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            GoalsNativeCalibrationPathPostureLabel(title: "Recorded support", palette: palette)
            ForEach(nodes) { node in
                Button {
                    onSelect(node.id)
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        GoalsNativeCalibrationPathMarker(
                            state: node.state,
                            isSelected: selectedNodeID == node.id,
                            palette: palette,
                            scale: .compact
                        )
                        recordedText(for: node)
                    }
                    .frame(width: 170, alignment: .leading)
                    .frame(minHeight: 48, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(node.title)
                .accessibilityValue(GoalsNativeCalibrationPathAccessibility.value(
                    for: node,
                    isSelected: selectedNodeID == node.id
                ))
                .accessibilityIdentifier("gnc-r03-path-node-\(node.id)")
                .id(node.id)
            }
        }
        .padding(.top, 16)
    }

    private func recordedText(for node: GoalsNativeCalibrationPathNode) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(node.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.primaryInk)
                .lineLimit(2)
            if node.proof.isEmpty == false {
                Text(proofCount(for: node))
                    .font(.caption)
                    .foregroundStyle(palette.secondaryInk)
            }
        }
    }

    private func proofCount(for node: GoalsNativeCalibrationPathNode) -> String {
        "\(node.proof.count) recorded \(node.proof.count == 1 ? "moment" : "moments")"
    }
}

private struct GoalsNativeCalibrationPathCurrentSeamField: View {
    let node: GoalsNativeCalibrationPathNode
    let acceptedTruth: String
    let isSelected: Bool
    let palette: GoalsNativeCalibrationPalette
    let onSelect: (String) -> Void

    var body: some View {
        Button {
            onSelect(node.id)
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    GoalsNativeCalibrationPathMarker(
                        state: node.state,
                        isSelected: isSelected,
                        palette: palette,
                        scale: .regular
                    )
                    GoalsNativeCalibrationPathPostureLabel(title: "Accepted now", palette: palette)
                }
                Text(acceptedTruth)
                    .font(GoalsNativeCalibrationTypographyRole.truth.font)
                    .foregroundStyle(palette.primaryInk)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("gnc-r03-path-current-truth")
                Text(node.title)
                    .font(.headline)
                    .foregroundStyle(palette.primaryInk)
                Text("Current movement")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.accent)
            }
            .frame(minHeight: 220, alignment: .topLeading)
            .padding(.leading, 18)
            .containerRelativeFrame(.horizontal, alignment: .leading)
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(palette.primaryInk.opacity(0.66))
                    .frame(width: palette.markerWidth + 1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(node.title)
        .accessibilityValue("Current position. \(acceptedTruth)")
        .accessibilityIdentifier("gnc-r03-path-node-\(node.id)")
    }
}

private struct GoalsNativeCalibrationPathNearMovementField: View {
    let node: GoalsNativeCalibrationPathNode
    let isSelected: Bool
    let palette: GoalsNativeCalibrationPalette
    let onSelect: (String) -> Void

    var body: some View {
        Button {
            onSelect(node.id)
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                GoalsNativeCalibrationPathMarker(
                    state: node.state,
                    isSelected: isSelected,
                    palette: palette,
                    scale: .regular
                )
                GoalsNativeCalibrationPathPostureLabel(title: "Near movement", palette: palette)
                Text(node.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(palette.primaryInk)
                    .fixedSize(horizontal: false, vertical: true)
                Text(node.detail)
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryInk)
                    .lineLimit(3)
            }
            .frame(minHeight: 202, alignment: .topLeading)
            .padding(.top, 18)
            .containerRelativeFrame(.horizontal, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(node.title)
        .accessibilityValue(GoalsNativeCalibrationPathAccessibility.value(
            for: node,
            isSelected: isSelected
        ))
        .accessibilityIdentifier("gnc-r03-path-node-\(node.id)")
    }
}

private struct GoalsNativeCalibrationPathOpenFutureField: View {
    let nodes: [GoalsNativeCalibrationPathNode]
    let selectedNodeID: String
    let palette: GoalsNativeCalibrationPalette
    let onSelect: (String) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 30) {
            ForEach(Array(nodes.enumerated()), id: \.element.id) { index, node in
                GoalsNativeCalibrationPathFutureNode(
                    node: node,
                    certaintyIndex: index,
                    isSelected: selectedNodeID == node.id,
                    palette: palette,
                    onSelect: onSelect
                )
                .id(node.id)
            }
        }
    }
}

private struct GoalsNativeCalibrationPathFutureNode: View {
    let node: GoalsNativeCalibrationPathNode
    let certaintyIndex: Int
    let isSelected: Bool
    let palette: GoalsNativeCalibrationPalette
    let onSelect: (String) -> Void

    var body: some View {
        Button {
            onSelect(node.id)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                GoalsNativeCalibrationPathMarker(
                    state: node.state,
                    isSelected: isSelected,
                    palette: palette,
                    scale: markerScale
                )
                GoalsNativeCalibrationPathPostureLabel(title: posture, palette: palette)
                Text(node.title)
                    .font(titleFont)
                    .foregroundStyle(titleColor)
                    .fixedSize(horizontal: false, vertical: true)
                Capsule()
                    .fill(palette.futurePossibility.opacity(materialOpacity))
                    .frame(width: certaintyIndex == 0 ? 74 : 38, height: certaintyIndex == 0 ? 7 : 5)
                    .accessibilityHidden(true)
            }
            .frame(width: certaintyIndex == 0 ? 176 : 150, alignment: .topLeading)
            .frame(minHeight: 180, alignment: .topLeading)
            .padding(.top, CGFloat(30 + certaintyIndex * 30))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(certaintyIndex == 0 ? 0.92 : 0.72)
        .accessibilityLabel(node.title)
        .accessibilityValue(GoalsNativeCalibrationPathAccessibility.value(
            for: node,
            isSelected: isSelected
        ))
        .accessibilityIdentifier("gnc-r03-path-node-\(node.id)")
    }

    private var markerScale: GoalsNativeCalibrationPathMarkerScale {
        certaintyIndex == 0 ? .regular : .compact
    }

    private var posture: String {
        certaintyIndex == 0 ? "Taking shape" : "Conditional"
    }

    private var titleFont: Font {
        certaintyIndex == 0 ? .headline : .subheadline.weight(.semibold)
    }

    private var titleColor: Color {
        certaintyIndex == 0 ? palette.primaryInk : palette.secondaryInk
    }

    private var materialOpacity: Double {
        certaintyIndex == 0 ? 0.92 : 0.46
    }
}

private struct GoalsNativeCalibrationPathClosureField: View {
    let node: GoalsNativeCalibrationPathNode
    let isSelected: Bool
    let palette: GoalsNativeCalibrationPalette
    let onSelect: (String) -> Void

    var body: some View {
        Button {
            onSelect(node.id)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                GoalsNativeCalibrationPathMarker(
                    state: node.state,
                    isSelected: isSelected,
                    palette: palette,
                    scale: .regular
                )
                GoalsNativeCalibrationPathPostureLabel(title: "Closure posture", palette: palette)
                Text(node.title)
                    .font(.headline)
                    .foregroundStyle(palette.primaryInk)
                    .fixedSize(horizontal: false, vertical: true)
                Text("An outcome boundary, not a percentage.")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryInk)
            }
            .frame(width: 176, alignment: .topLeading)
            .frame(minHeight: 176, alignment: .topLeading)
            .padding(.top, 42)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(node.title)
        .accessibilityValue(GoalsNativeCalibrationPathAccessibility.value(
            for: node,
            isSelected: isSelected
        ))
        .accessibilityIdentifier("gnc-r03-path-node-\(node.id)")
    }
}

struct GoalsNativeCalibrationPathSemanticList: View {
    let presentation: GoalsNativeCalibrationPathPresentation
    let selectedNodeID: String
    let palette: GoalsNativeCalibrationPalette
    let onSelect: (String) -> Void

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(Array(presentation.nodes.enumerated()), id: \.element.id) { index, node in
                GoalsNativeCalibrationPathSemanticNode(
                    node: node,
                    position: index + 1,
                    count: presentation.nodes.count,
                    isSelected: selectedNodeID == node.id,
                    palette: palette,
                    onSelect: onSelect
                )
                .id(node.id)
                if index < presentation.nodes.count - 1 {
                    Divider()
                        .overlay(palette.separator)
                        .padding(.leading, 54)
                        .accessibilityHidden(true)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Goal Path, eight ordered movements")
        .accessibilityIdentifier("gnc-r03-path-accessibility-list")
    }
}

private struct GoalsNativeCalibrationPathSemanticNode: View {
    let node: GoalsNativeCalibrationPathNode
    let position: Int
    let count: Int
    let isSelected: Bool
    let palette: GoalsNativeCalibrationPalette
    let onSelect: (String) -> Void

    var body: some View {
        Button {
            onSelect(node.id)
        } label: {
            HStack(alignment: .top, spacing: 14) {
                GoalsNativeCalibrationPathMarker(
                    state: node.state,
                    isSelected: isSelected,
                    palette: palette,
                    scale: .regular
                )
                semanticText
                Spacer(minLength: 8)
                Text("\(position) of \(count)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(palette.tertiaryInk)
            }
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(node.title)
        .accessibilityValue(GoalsNativeCalibrationPathAccessibility.value(
            for: node,
            isSelected: isSelected
        ))
        .accessibilityHint("Movement \(position) of \(count)")
        .accessibilityIdentifier("gnc-r03-path-node-\(node.id)")
    }

    private var semanticText: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(node.state.label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? palette.accent : palette.secondaryInk)
            Text(node.title)
                .font(.body.weight(.semibold))
                .foregroundStyle(palette.primaryInk)
                .fixedSize(horizontal: false, vertical: true)
            Text(node.detail)
                .font(.subheadline)
                .foregroundStyle(palette.secondaryInk)
                .fixedSize(horizontal: false, vertical: true)
            if node.proof.isEmpty == false {
                Text("Recorded support: \(node.proof.joined(separator: ", "))")
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct GoalsNativeCalibrationPathSelectedDetail: View {
    let pathID: String
    let node: GoalsNativeCalibrationPathSelectedNodePresentation
    let palette: GoalsNativeCalibrationPalette

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            selectedIdentity
            Text(node.detail)
                .font(GoalsNativeCalibrationTypographyRole.truth.font)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("gnc-r03-path-selected-detail")
            proofFoundation
            evidenceLink
        }
        .padding(.top, 20)
        .overlay(alignment: .topLeading) {
            HStack(spacing: 7) {
                Capsule().fill(palette.primaryInk.opacity(0.7)).frame(width: 56, height: 3)
                Capsule().fill(palette.acceptedFoundation).frame(width: 24, height: 3)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(node.title)
        .accessibilityValue("\(node.state.label), selected")
        .accessibilityIdentifier("gnc-r03-path-selected-node")
    }

    private var selectedIdentity: some View {
        HStack(alignment: .top, spacing: 12) {
            GoalsNativeCalibrationPathMarker(
                state: node.state,
                isSelected: true,
                palette: palette,
                scale: .regular
            )
            VStack(alignment: .leading, spacing: 5) {
                Text(node.state.label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.accent)
                Text(node.title)
                    .font(.title3.weight(.bold))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder
    private var proofFoundation: some View {
        if node.proofMomentTitles.isEmpty {
            Text("No recorded Proof is attached to this unresolved position.")
                .font(.subheadline)
                .foregroundStyle(palette.secondaryInk)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("Proof supporting this position")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.secondaryInk)
                GoalsNativeCalibrationProofFoundation(
                    moments: node.proofMomentTitles,
                    palette: palette,
                    expanded: true
                )
            }
        }
    }

    private var evidenceLink: some View {
        NavigationLink(
            value: GoalsNativeCalibrationRoute.pathEvidence(pathID: pathID, nodeID: node.id)
        ) {
            HStack(spacing: 10) {
                Text("Inspect Proof and history")
                    .font(.headline)
                Spacer(minLength: 8)
                Image(systemName: "chevron.forward")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.tertiaryInk)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens evidence for this exact Path position")
        .accessibilityIdentifier("gnc-r03-path-evidence-action")
    }
}

private struct GoalsNativeCalibrationPathPostureLabel: View {
    let title: String
    let palette: GoalsNativeCalibrationPalette

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(palette.secondaryInk)
            .textCase(.uppercase)
    }
}

enum GoalsNativeCalibrationPathMarkerScale {
    case compact
    case regular
}

struct GoalsNativeCalibrationPathMarker: View {
    let state: GoalsNativeCalibrationPathNodeState
    let isSelected: Bool
    let palette: GoalsNativeCalibrationPalette
    let scale: GoalsNativeCalibrationPathMarkerScale

    private var frame: CGFloat { scale == .compact ? 32 : 42 }
    private var shape: CGFloat { scale == .compact ? 18 : 26 }

    var body: some View {
        ZStack {
            markerShape
            markerCenter
        }
        .frame(width: frame, height: frame)
        .overlay {
            if isSelected {
                Circle()
                    .stroke(palette.accent, lineWidth: palette.markerWidth)
                    .padding(scale == .compact ? 2 : 1)
            }
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var markerShape: some View {
        switch state {
        case .completed:
            Circle()
                .strokeBorder(palette.secondaryInk, lineWidth: palette.markerWidth)
                .frame(width: shape, height: shape)
        case .settled:
            Circle()
                .strokeBorder(palette.primaryInk, lineWidth: palette.markerWidth)
                .frame(width: shape + 2, height: shape + 2)
                .overlay {
                    Circle()
                        .strokeBorder(palette.secondaryInk, lineWidth: 1)
                        .frame(width: shape * 0.62, height: shape * 0.62)
                }
        case .current:
            Circle()
                .strokeBorder(palette.primaryInk, lineWidth: palette.markerWidth + 0.6)
                .frame(width: shape + 3, height: shape + 3)
        case .next:
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .strokeBorder(palette.primaryInk, lineWidth: palette.markerWidth)
                .frame(width: shape - 2, height: shape - 2)
                .rotationEffect(.degrees(45))
        case .planned:
            Circle()
                .strokeBorder(palette.secondaryInk, lineWidth: palette.markerWidth)
                .frame(width: shape, height: shape)
        case .conditional:
            Circle()
                .stroke(
                    palette.secondaryInk,
                    style: StrokeStyle(lineWidth: palette.markerWidth, dash: [3, 4])
                )
                .frame(width: shape, height: shape)
        case .finish:
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .strokeBorder(palette.primaryInk, lineWidth: palette.markerWidth)
                .frame(width: shape, height: shape)
        }
    }

    @ViewBuilder
    private var markerCenter: some View {
        switch state {
        case .completed:
            Image(systemName: "checkmark")
                .font(.caption2.weight(.bold))
                .foregroundStyle(palette.secondaryInk)
        case .settled, .current, .finish:
            Circle()
                .fill(state == .current ? palette.accent : palette.primaryInk)
                .frame(width: centerSize, height: centerSize)
        case .next, .planned, .conditional:
            EmptyView()
        }
    }

    private var centerSize: CGFloat { scale == .compact ? 5 : 7 }
}

private enum GoalsNativeCalibrationPathAccessibility {
    static func value(
        for node: GoalsNativeCalibrationPathNode,
        isSelected: Bool
    ) -> String {
        let selected = isSelected ? ", selected" : ""
        let proof = node.proof.isEmpty ? "" : ", \(node.proof.count) recorded moments"
        return "\(node.state.label)\(selected)\(proof)"
    }
}

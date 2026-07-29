import SwiftUI

public struct GoalsNativeCalibrationPathPresentation: Equatable, Sendable {
    public let goalID: String
    public let goalTitle: String
    public let lifeAreaTitle: String
    public let pathID: String
    public let nodes: [GoalsNativeCalibrationPathNode]
    public let currentNodeID: String
    public let nextNodeID: String
    public let jumpTitles = ["Start", "Now", "Next", "Finish"]

    public init(content: GoalsNativeCalibrationContent) {
        goalID = content.primaryGoal.id
        goalTitle = content.primaryGoal.title
        lifeAreaTitle = content.primaryGoal.lifeAreaTitle
        pathID = content.goalPath.id
        nodes = content.goalPath.nodes
        currentNodeID = content.goalPath.currentNodeID
        nextNodeID = content.goalPath.nextNodeID
    }

    public var visibleText: [String] {
        [goalTitle, lifeAreaTitle]
            + nodes.flatMap { [$0.title, $0.state.label, $0.detail] + $0.proof }
            + jumpTitles
    }

    public var recordedProofMoments: [String] {
        nodes.flatMap(\.proof)
    }
}

struct GoalsNativeCalibrationPathView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let content: GoalsNativeCalibrationContent
    @Binding var state: GoalsNativeCalibrationJourneyState
    let palette: GoalsNativeCalibrationPalette

    @State private var horizontalAnchorID: String?

    private var presentation: GoalsNativeCalibrationPathPresentation {
        GoalsNativeCalibrationPathPresentation(content: content)
    }

    private var selectedNode: GoalsNativeCalibrationPathNode {
        presentation.nodes.first { $0.id == state.selectedPathNodeID }
            ?? presentation.nodes.first { $0.id == presentation.currentNodeID }
            ?? presentation.nodes[0]
    }

    private var usesOrderedPath: Bool { dynamicTypeSize.isAccessibilitySize }

    var body: some View {
        ScrollViewReader { verticalProxy in
            ScrollView {
                VStack(alignment: .leading, spacing: usesOrderedPath ? 24 : 22) {
                    identity
                    pathField
                    jumpControls(verticalProxy: verticalProxy)
                    selectedNodeDetail
                }
                .frame(maxWidth: 620, alignment: .leading)
                .padding(.horizontal, usesOrderedPath ? 20 : 24)
                .padding(.top, 12)
                .padding(.bottom, 42)
            }
            .onAppear {
                horizontalAnchorID = presentation.currentNodeID
            }
        }
        .background(palette.canvas.ignoresSafeArea())
        .foregroundStyle(palette.primaryInk)
        .goalsNativeCalibrationDepthNavigation(title: "Goal Path")
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("gnc-goal-path")
    }

    private var identity: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Goal Path")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.accent)
            Text(presentation.goalTitle)
                .font(.largeTitle.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("gnc-path-goal-title")
            HStack(spacing: 9) {
                Image(systemName: "square.grid.2x2")
                    .foregroundStyle(palette.accent)
                    .accessibilityHidden(true)
                Text(presentation.lifeAreaTitle)
                    .font(.body.weight(.medium))
                Text("Life Area")
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryInk)
            }
            .frame(minHeight: 44)
        }
    }

    @ViewBuilder
    private var pathField: some View {
        if usesOrderedPath {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(presentation.nodes.enumerated()), id: \.element.id) { index, node in
                    orderedNode(node, position: index + 1)
                        .id(node.id)
                    if index < presentation.nodes.count - 1 {
                        Rectangle()
                            .fill(palette.separator)
                            .frame(width: 1, height: 16)
                            .padding(.leading, 21)
                            .accessibilityHidden(true)
                    }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Goal Path, eight ordered movements")
            .accessibilityIdentifier("gnc-path-accessibility-list")
        } else {
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 0) {
                    ForEach(Array(presentation.nodes.enumerated()), id: \.element.id) { index, node in
                        standardNode(node, position: index + 1)
                            .id(node.id)
                        if index < presentation.nodes.count - 1 {
                            Rectangle()
                                .fill(palette.separator)
                                .frame(width: 24, height: 1)
                                .padding(.top, 19)
                                .accessibilityHidden(true)
                        }
                    }
                }
                .scrollTargetLayout()
                .padding(.vertical, 4)
            }
            .scrollIndicators(.visible)
            .scrollPosition(id: $horizontalAnchorID, anchor: .leading)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Goal Path, eight movements")
            .accessibilityIdentifier("gnc-path-horizontal")
        }
    }

    private func standardNode(
        _ node: GoalsNativeCalibrationPathNode,
        position: Int
    ) -> some View {
        Button {
            select(node.id)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                GoalsNativeCalibrationPathMarker(
                    state: node.state,
                    isSelected: state.selectedPathNodeID == node.id,
                    palette: palette
                )
                Text(node.state.label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(
                        state.selectedPathNodeID == node.id ? palette.accent : palette.secondaryInk
                    )
                Text(node.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.primaryInk)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 148, alignment: .topLeading)
            .frame(minHeight: 112, alignment: .top)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(node.title)
        .accessibilityValue(accessibilityValue(for: node))
        .accessibilityHint("Movement \(position) of \(presentation.nodes.count)")
        .accessibilityIdentifier("gnc-path-node-\(node.id)")
    }

    private func orderedNode(
        _ node: GoalsNativeCalibrationPathNode,
        position: Int
    ) -> some View {
        Button {
            select(node.id)
        } label: {
            HStack(alignment: .top, spacing: 14) {
                GoalsNativeCalibrationPathMarker(
                    state: node.state,
                    isSelected: state.selectedPathNodeID == node.id,
                    palette: palette
                )
                VStack(alignment: .leading, spacing: 5) {
                    Text(node.state.label)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(
                            state.selectedPathNodeID == node.id ? palette.accent : palette.secondaryInk
                        )
                    Text(node.title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(palette.primaryInk)
                        .fixedSize(horizontal: false, vertical: true)
                    if node.id == presentation.currentNodeID {
                        Text("The movement in focus now")
                            .font(.subheadline)
                            .foregroundStyle(palette.secondaryInk)
                    } else if node.id == presentation.nextNodeID {
                        Text("The next meaningful movement")
                            .font(.subheadline)
                            .foregroundStyle(palette.secondaryInk)
                    }
                }
                Spacer(minLength: 8)
                Text("\(position) of \(presentation.nodes.count)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(palette.tertiaryInk)
            }
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(node.title)
        .accessibilityValue(accessibilityValue(for: node))
        .accessibilityHint("Movement \(position) of \(presentation.nodes.count)")
        .accessibilityIdentifier("gnc-path-node-\(node.id)")
    }

    @ViewBuilder
    private func jumpControls(verticalProxy: ScrollViewProxy) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Jump within this path")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.secondaryInk)

            if usesOrderedPath {
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 8
                ) {
                    ForEach(GoalsNativeCalibrationPathJump.allCases, id: \.self) { jump in
                        jumpButton(jump) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                verticalProxy.scrollTo(state.selectedPathNodeID, anchor: .center)
                            }
                        }
                    }
                }
            } else {
                HStack(spacing: 8) {
                    ForEach(GoalsNativeCalibrationPathJump.allCases, id: \.self) { jump in
                        jumpButton(jump) {
                            horizontalAnchorID = state.selectedPathNodeID
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("gnc-path-jump-controls")
    }

    private func jumpButton(
        _ jump: GoalsNativeCalibrationPathJump,
        afterSelection: @escaping () -> Void
    ) -> some View {
        Button(jump.title) {
            guard state.jumpTo(jump) else { return }
            afterSelection()
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(palette.primaryInk)
        .frame(maxWidth: .infinity, minHeight: 46)
        .background(palette.inset, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityLabel("Jump to \(jump.title)")
        .accessibilityIdentifier("gnc-path-jump-\(jump.rawValue)")
    }

    private var selectedNodeDetail: some View {
        GoalsNativeCalibrationOpenRelief(palette: palette) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    GoalsNativeCalibrationPathMarker(
                        state: selectedNode.state,
                        isSelected: true,
                        palette: palette
                    )
                    VStack(alignment: .leading, spacing: 5) {
                        Text(selectedNode.state.label)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(palette.accent)
                        Text(selectedNode.title)
                            .font(.title3.weight(.semibold))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Text(selectedNode.detail)
                    .font(GoalsNativeCalibrationTypographyRole.truth.font)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("gnc-path-selected-detail")

                if presentation.recordedProofMoments.isEmpty == false {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Recorded on this path")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(palette.secondaryInk)
                        ForEach(presentation.recordedProofMoments, id: \.self) { proof in
                            HStack(spacing: 9) {
                                GoalsNativeCalibrationMarker(kind: .proof, palette: palette)
                                Text(proof)
                                    .font(.subheadline)
                            }
                            .frame(minHeight: 30)
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(presentation.recordedProofMoments.joined(separator: ", "))
                    .accessibilityIdentifier("gnc-path-proof-history")
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("gnc-path-selected-node")
    }

    private func select(_ nodeID: String) {
        guard state.selectPathNode(id: nodeID) else { return }
        horizontalAnchorID = nodeID
    }

    private func accessibilityValue(for node: GoalsNativeCalibrationPathNode) -> String {
        state.selectedPathNodeID == node.id
            ? "\(node.state.label), selected"
            : node.state.label
    }
}

private struct GoalsNativeCalibrationPathMarker: View {
    let state: GoalsNativeCalibrationPathNodeState
    let isSelected: Bool
    let palette: GoalsNativeCalibrationPalette

    var body: some View {
        ZStack {
            markerShape
            markerCenter
        }
        .frame(width: 40, height: 40)
        .overlay {
            if isSelected {
                Circle()
                    .stroke(palette.accent, lineWidth: 1)
                    .padding(1)
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
                .frame(width: 24, height: 24)
        case .settled:
            Circle()
                .strokeBorder(palette.primaryInk, lineWidth: palette.markerWidth)
                .frame(width: 26, height: 26)
                .overlay {
                    Circle()
                        .strokeBorder(palette.secondaryInk, lineWidth: 1)
                        .frame(width: 17, height: 17)
                }
        case .current:
            Circle()
                .strokeBorder(palette.accent, lineWidth: palette.markerWidth + 0.5)
                .frame(width: 27, height: 27)
        case .next:
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .strokeBorder(palette.primaryInk, lineWidth: palette.markerWidth)
                .frame(width: 21, height: 21)
                .rotationEffect(.degrees(45))
        case .planned:
            Circle()
                .strokeBorder(palette.secondaryInk, lineWidth: palette.markerWidth)
                .frame(width: 22, height: 22)
        case .conditional:
            Circle()
                .stroke(
                    palette.secondaryInk,
                    style: StrokeStyle(lineWidth: palette.markerWidth, dash: [3, 3])
                )
                .frame(width: 24, height: 24)
        case .finish:
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .strokeBorder(palette.primaryInk, lineWidth: palette.markerWidth)
                .frame(width: 25, height: 25)
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
                .frame(width: state == .finish ? 7 : 6, height: state == .finish ? 7 : 6)
        case .next, .planned, .conditional:
            EmptyView()
        }
    }
}

extension GoalsNativeCalibrationPathJump {
    var title: String {
        switch self {
        case .start: "Start"
        case .now: "Now"
        case .next: "Next"
        case .finish: "Finish"
        }
    }
}

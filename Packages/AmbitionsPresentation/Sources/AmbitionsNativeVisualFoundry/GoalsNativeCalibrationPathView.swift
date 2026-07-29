import SwiftUI

public struct GoalsNativeCalibrationPathSelectedNodePresentation: Equatable, Sendable {
    public let id: String
    public let title: String
    public let state: GoalsNativeCalibrationPathNodeState
    public let detail: String
    public let proofMomentIDs: [String]
    public let proofMomentTitles: [String]
}

public struct GoalsNativeCalibrationPathPresentation: Equatable, Sendable {
    public let goalID: String
    public let goalTitle: String
    public let lifeAreaTitle: String
    public let acceptedTruth: String
    public let pathID: String
    public let nodes: [GoalsNativeCalibrationPathNode]
    public let currentNodeID: String
    public let nextNodeID: String
    public let proofMoments: [GoalsNativeCalibrationProofMoment]
    public let jumpTitles = ["Start", "Now", "Next", "Finish"]

    public init(content: GoalsNativeCalibrationContent) {
        goalID = content.primaryGoal.id
        goalTitle = content.primaryGoal.title
        lifeAreaTitle = content.primaryGoal.lifeAreaTitle
        acceptedTruth = content.primaryGoal.currentAcceptedTruth
        pathID = content.goalPath.id
        nodes = content.goalPath.nodes
        currentNodeID = content.goalPath.currentNodeID
        nextNodeID = content.goalPath.nextNodeID
        proofMoments = content.proofMoments
    }

    public var recordedSupport: [GoalsNativeCalibrationPathNode] {
        Array(nodes.prefix { $0.id != currentNodeID })
    }

    public var currentSeam: GoalsNativeCalibrationPathNode {
        nodes.first { $0.id == currentNodeID } ?? nodes[0]
    }

    public var nearMovement: GoalsNativeCalibrationPathNode {
        nodes.first { $0.id == nextNodeID } ?? currentSeam
    }

    public var openFuture: [GoalsNativeCalibrationPathNode] {
        guard
            let nextIndex = nodes.firstIndex(where: { $0.id == nextNodeID }),
            let finishIndex = nodes.firstIndex(where: { $0.state == .finish }),
            nextIndex + 1 < finishIndex
        else { return [] }
        return Array(nodes[(nextIndex + 1)..<finishIndex])
    }

    public var closurePosture: GoalsNativeCalibrationPathNode {
        nodes.first { $0.state == .finish } ?? nodes[nodes.count - 1]
    }

    public let usesContinuousConnector = false
    public let usesCompactJumpMenu = true

    public var semanticNodeOrder: [String] { nodes.map(\.id) }
    public var accessibilityCurrentNodeID: String { currentNodeID }
    public var accessibilityNextNodeID: String { nextNodeID }

    public var visibleText: [String] {
        [goalTitle, lifeAreaTitle, acceptedTruth]
            + nodes.flatMap { [$0.title, $0.state.label, $0.detail] + $0.proof }
            + jumpTitles
    }

    public var recordedProofMoments: [String] {
        nodes.flatMap(\.proof)
    }

    public func selectedNode(id: String) -> GoalsNativeCalibrationPathSelectedNodePresentation? {
        guard let node = nodes.first(where: { $0.id == id }) else { return nil }
        let proofByID = Dictionary(uniqueKeysWithValues: proofMoments.map { ($0.id, $0.title) })
        return GoalsNativeCalibrationPathSelectedNodePresentation(
            id: node.id,
            title: node.title,
            state: node.state,
            detail: node.detail,
            proofMomentIDs: node.proofIDs,
            proofMomentTitles: node.proofIDs.compactMap { proofByID[$0] }
        )
    }
}

struct GoalsNativeCalibrationPathView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let content: GoalsNativeCalibrationContent
    @Binding var state: GoalsNativeCalibrationJourneyState
    let palette: GoalsNativeCalibrationPalette

    @State private var horizontalAnchorID: String?
    @AccessibilityFocusState private var accessibilityFocusedNodeID: String?

    private var presentation: GoalsNativeCalibrationPathPresentation {
        GoalsNativeCalibrationPathPresentation(content: content)
    }

    private var selectedNode: GoalsNativeCalibrationPathSelectedNodePresentation {
        presentation.selectedNode(id: state.selectedPathNodeID)
            ?? presentation.selectedNode(id: presentation.currentNodeID)
            ?? presentation.selectedNode(id: presentation.nodes[0].id)!
    }

    private var usesOrderedPath: Bool { dynamicTypeSize.isAccessibilitySize }

    var body: some View {
        ScrollViewReader { verticalProxy in
            ScrollView {
                VStack(alignment: .leading, spacing: usesOrderedPath ? 28 : 24) {
                    GoalsNativeCalibrationPathIdentity(
                        presentation: presentation,
                        usesAccessibilityLayout: usesOrderedPath,
                        palette: palette
                    )
                    pathField
                    jumpMenu(verticalProxy: verticalProxy)
                    GoalsNativeCalibrationPathSelectedDetail(
                        pathID: presentation.pathID,
                        node: selectedNode,
                        palette: palette
                    )
                    .accessibilityFocused(
                        $accessibilityFocusedNodeID,
                        equals: selectedNode.id
                    )
                }
                .frame(maxWidth: 660, alignment: .leading)
                .padding(.horizontal, usesOrderedPath ? 20 : 24)
                .padding(.top, 10)
                .padding(.bottom, 52)
            }
            .onAppear {
                horizontalAnchorID = state.selectedPathNodeID
                accessibilityFocusedNodeID = state.selectedPathNodeID
            }
            .onChange(of: state.selectedPathNodeID) { _, nodeID in
                accessibilityFocusedNodeID = nodeID
            }
        }
        .background(palette.canvas.ignoresSafeArea())
        .foregroundStyle(palette.primaryInk)
        .goalsNativeCalibrationDepthNavigation(title: "Goal Path")
        .sensoryFeedback(.selection, trigger: state.selectedPathNodeID)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("gnc-r03-path")
    }

    @ViewBuilder
    private var pathField: some View {
        if usesOrderedPath {
            GoalsNativeCalibrationPathSemanticList(
                presentation: presentation,
                selectedNodeID: state.selectedPathNodeID,
                palette: palette,
                onSelect: select
            )
        } else {
            GoalsNativeCalibrationPathSpatialField(
                presentation: presentation,
                selectedNodeID: state.selectedPathNodeID,
                horizontalAnchorID: $horizontalAnchorID,
                palette: palette,
                onSelect: select
            )
        }
    }

    private func jumpMenu(verticalProxy: ScrollViewProxy) -> some View {
        HStack(spacing: 12) {
            Menu {
                ForEach(GoalsNativeCalibrationPathJump.allCases, id: \.self) { jump in
                    Button {
                        guard state.jumpTo(jump) else { return }
                        if usesOrderedPath {
                            verticalProxy.scrollTo(state.selectedPathNodeID, anchor: .center)
                        } else {
                            horizontalAnchorID = state.selectedPathNodeID
                        }
                    } label: {
                        Label(jump.title, systemImage: jump.symbolName)
                    }
                }
            } label: {
                Label("Jump within Path", systemImage: "arrow.up.and.down.text.horizontal")
                    .font(.subheadline.weight(.semibold))
                    .frame(minHeight: 44)
            }
            .accessibilityLabel("Jump within Goal Path")
            .accessibilityValue(selectedNode.title)
            .accessibilityIdentifier("gnc-r03-path-jump-menu")

            Spacer(minLength: 8)

            Text(selectedNode.state.label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.secondaryInk)
        }
    }

    private func select(_ nodeID: String) {
        guard state.selectPathNode(id: nodeID) else { return }
        horizontalAnchorID = nodeID
        accessibilityFocusedNodeID = nodeID
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

    var symbolName: String {
        switch self {
        case .start: "backward.end"
        case .now: "scope"
        case .next: "forward"
        case .finish: "forward.end"
        }
    }
}

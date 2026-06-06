import AmbitionsDesignSystem
import SwiftUI

struct GoalLifePathView: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var focusedNodeID: String?

    let state: GoalLifePathState

    init(overview: GoalsOverview, privacySensitive: Bool = false) {
        self.state = GoalLifePathState(overview: overview, privacySensitive: privacySensitive)
    }

    init(state: GoalLifePathState) {
        self.state = state
    }

    var body: some View {
        AppCard(state: state.visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                header

                if dynamicTypeSize.isAccessibilitySize {
                    accessibilityPathStack
                } else {
                    visualPathStack
                }

                if state.alternateRoutes.isEmpty == false {
                    alternateRoutes
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(state.accessibilityLabel)
        .accessibilityValue(state.accessibilityValue)
        .accessibilityHint(state.accessibilityHint)
        .accessibilityIdentifier("goals.life-path")
        .ambitionPanelAccessibility()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                Text("Thread Focus")
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.accentWarm)

                Text(state.badge)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.stateStyle(for: state.visualState).accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .padding(.horizontal, theme.spacing.xs)
                    .padding(.vertical, theme.spacing.xxxs)
                    .background(Capsule(style: .continuous).fill(theme.stateStyle(for: state.visualState).fill))
                    .overlay(Capsule(style: .continuous).strokeBorder(theme.stateStyle(for: state.visualState).stroke, lineWidth: 1))
            }

            Text(state.title)
                .font(theme.typography.section)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(state.subtitle)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var visualPathStack: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            ForEach(Array(state.nodes.enumerated()), id: \.element.id) { index, node in
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    GoalLifePathNodeView(
                        node: node,
                        isFocused: focusedNodeID == node.id,
                        onFocus: { focus(node) }
                    )

                    if index < state.nodes.count - 1 {
                        GoalLifePathConnectorView(
                            tone: connectorTone(after: node),
                            reducedMotion: reduceMotion
                        )
                        .padding(.top, 30)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
    }

    private var accessibilityPathStack: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            ForEach(state.nodes) { node in
                GoalLifePathNodeView(
                    node: node,
                    isFocused: focusedNodeID == node.id,
                    onFocus: { focus(node) }
                )
            }
        }
    }

    private var alternateRoutes: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text("Alternate routes")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 168), spacing: theme.spacing.xs)], spacing: theme.spacing.xs) {
                ForEach(state.alternateRoutes) { route in
                    let style = theme.stateStyle(for: route.state)
                    HStack(alignment: .top, spacing: theme.spacing.xs) {
                        Image(systemName: route.symbolName)
                            .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                            .foregroundStyle(style.accent)
                            .frame(width: 24, height: 24)
                            .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                            Text(route.title)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textPrimary)
                                .lineLimit(2)
                            Text(route.detail)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                                .lineLimit(2)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 70, alignment: .topLeading)
                    .padding(theme.spacing.xs)
                    .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(style.fill))
                    .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(style.stroke, lineWidth: 1))
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(route.title). \(route.detail)")
                }
            }
        }
    }

    private func focus(_ node: GoalLifePathNodeState) {
        withAnimation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true)) {
            focusedNodeID = focusedNodeID == node.id ? nil : node.id
        }
    }

    private func connectorTone(after node: GoalLifePathNodeState) -> AmbitionVisualState {
        switch node.kind {
        case .risk:
            .warning
        case .proof:
            .success
        case .current, .next, .start:
            .selected
        }
    }
}

private struct GoalLifePathNodeView: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let node: GoalLifePathNodeState
    let isFocused: Bool
    let onFocus: () -> Void

    var body: some View {
        let style = theme.stateStyle(for: isFocused ? .pressed : node.state)
        Button(action: onFocus) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                ZStack {
                    Circle()
                        .fill(style.fill)
                        .frame(width: 50, height: 50)
                        .overlay(Circle().stroke(style.stroke, lineWidth: 1))
                        .shadow(color: style.glow.opacity(node.kind == .proof ? 0.18 : 0.10), radius: 14, x: 0, y: 8)

                    Image(systemName: node.symbolName)
                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                        .foregroundStyle(style.accent)
                        .accessibilityHidden(true)
                }

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(node.label)
                        .font(theme.typography.micro)
                        .foregroundStyle(style.accent)
                    Text(node.title)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(isFocused ? node.focusDetail : node.detail)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(isFocused ? 4 : 2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 154, alignment: .topLeading)
            .padding(theme.spacing.xs)
            .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(style.fill.opacity(isFocused ? 1 : 0.72)))
            .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(style.stroke, lineWidth: 1))
            .scaleEffect(isFocused && reduceMotion == false ? 1.015 : 1)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(node.label). \(node.title). \(node.detail). \(node.nonColorMeaning)")
        .accessibilityHint("Focuses this path node without opening a new screen.")
    }
}

private struct GoalLifePathConnectorView: View {
    @Environment(\.ambitionTheme) private var theme

    let tone: AmbitionVisualState
    let reducedMotion: Bool

    var body: some View {
        let style = theme.stateStyle(for: tone)
        VStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(style.accent.opacity(index == 1 ? 0.48 : 0.24))
                    .frame(width: reducedMotion ? 18 : CGFloat(14 + (index * 8)), height: 3)
            }
        }
        .frame(width: 34, height: 50, alignment: .center)
        .accessibilityHidden(true)
    }
}

struct GoalLifePathState: Sendable, Hashable {
    let title: String
    let subtitle: String
    let badge: String
    let visualState: AmbitionVisualState
    let nodes: [GoalLifePathNodeState]
    let alternateRoutes: [GoalLifePathAlternateRouteState]
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String

    init(overview: GoalsOverview, privacySensitive: Bool = false) {
        let activeCards = overview.bands.first(where: { $0.kind == .activeDirection })?.cards ?? []
        let pressureCards = overview.bands.first(where: { $0.kind == .pressure })?.cards ?? []
        let recentCards = overview.bands.first(where: { $0.kind == .recentMovement })?.cards ?? []
        let primary = activeCards.first ?? overview.bands.flatMap(\.cards).first
        let risk = pressureCards.first
        let proofCard = activeCards.first(where: { $0.proofSummary.count > 0 }) ?? primary

        let displayTitle = privacySensitive ? "Private ambition path" : primary?.title ?? overview.hero.title
        let displaySubtitle = privacySensitive
            ? "Titles are hidden, but the path still shows where attention, proof, and risk live."
            : "A calm read on where this ambition starts, what is moving, what is proven, and what may need a different route."

        var pathNodes: [GoalLifePathNodeState] = [
            GoalLifePathNodeState(
                id: "start",
                kind: .start,
                label: "Start",
                title: privacySensitive ? "Private start" : primary?.phaseSummary ?? "First visible shape",
                detail: privacySensitive ? "Start context hidden." : primary?.weekRelationship ?? "The path begins once a goal has shape.",
                focusDetail: privacySensitive ? "Private context stays hidden in this preview state." : primary?.subtitle ?? overview.hero.dominantTruth,
                nonColorMeaning: "Start node",
                symbolName: "smallcircle.filled.circle",
                state: .selected
            ),
            GoalLifePathNodeState(
                id: "current",
                kind: .current,
                label: "Current",
                title: privacySensitive ? "Current stage" : primary?.phaseSummary ?? "Current stage",
                detail: privacySensitive ? "Current path detail hidden." : primary?.progressLabel ?? overview.hero.dominantTruth,
                focusDetail: privacySensitive ? "The current stage can be reviewed without exposing private goal titles." : primary?.pressureSummary ?? overview.hero.pressureSummary,
                nonColorMeaning: "Current stage node",
                symbolName: "scope",
                state: primary?.renderState.visualState ?? .selected
            ),
        ]

        if let proofCard, proofCard.proofSummary.count > 0 {
            pathNodes.append(
                GoalLifePathNodeState(
                    id: "proof",
                    kind: .proof,
                    label: "Proof",
                    title: "\(proofCard.proofSummary.count) proof \(proofCard.proofSummary.count == 1 ? "signal" : "signals")",
                    detail: privacySensitive ? "Proof detail hidden." : proofCard.proofSummary.latestTitle ?? proofCard.proofSummary.detail,
                    focusDetail: privacySensitive ? "Proof exists, but private evidence text is hidden." : proofCard.proofSummary.detail,
                    nonColorMeaning: "Proof marker",
                    symbolName: "checkmark.seal",
                    state: .success
                )
            )
        }

        if let risk {
            pathNodes.append(
                GoalLifePathNodeState(
                    id: "risk",
                    kind: .risk,
                    label: risk.posture == .atRisk ? "Blocker" : "Risk",
                    title: privacySensitive ? "Attention needed" : risk.renderState.title,
                    detail: privacySensitive ? "Risk detail hidden." : risk.nextStepHint,
                    focusDetail: privacySensitive ? "Resolve the visible risk without exposing private context." : risk.pressureSummary,
                    nonColorMeaning: risk.posture == .atRisk ? "Blocker marker" : "Risk marker",
                    symbolName: "exclamationmark.triangle",
                    state: .warning
                )
            )
        }

        pathNodes.append(
            GoalLifePathNodeState(
                id: "next",
                kind: .next,
                label: "Next",
                title: privacySensitive ? "Next visible step" : primary?.nextVisibleStep.title ?? overview.heroPrimaryAction.title,
                detail: privacySensitive ? "Step detail hidden." : primary?.nextVisibleStep.detail ?? primary?.nextStepHint ?? overview.heroPrimaryAction.subtitle,
                focusDetail: privacySensitive ? "The next step remains visible as a role, not private content." : primary?.nextStepHint ?? overview.heroPrimaryAction.subtitle,
                nonColorMeaning: "Next-step node",
                symbolName: "arrow.up.right.circle",
                state: primary?.nextVisibleStep.isAvailable == false ? .warning : .selected
            )
        )

        let routeCandidates = Array(pressureCards.dropFirst()) + Array(recentCards.prefix(2))
        let routes = routeCandidates.prefix(3).map { card in
            GoalLifePathAlternateRouteState(
                id: card.id,
                title: privacySensitive ? "Private alternate route" : card.title,
                detail: privacySensitive ? "Alternate route detail hidden." : card.phaseSummary,
                symbolName: card.posture == .atRisk ? "exclamationmark.triangle" : "arrow.triangle.branch",
                state: card.posture == .atRisk || card.posture == .crowded ? .warning : card.renderState.visualState
            )
        }

        self.title = displayTitle
        self.subtitle = displaySubtitle
        self.badge = risk == nil ? "Path clear" : "Route attention"
        self.visualState = risk == nil ? .selected : .warning
        self.nodes = pathNodes
        self.alternateRoutes = Array(routes)
        self.accessibilityLabel = "Goals Thread Focus"
        self.accessibilityValue = pathNodes.map { "\($0.label), \($0.title)" }.joined(separator: ". ")
        self.accessibilityHint = privacySensitive
            ? "Private preview hides titles while preserving path, proof, risk, and next-step structure."
            : "Review one goal thread from start through current stage, proof, risk, and the next step that can feed Today."
    }
}

struct GoalLifePathNodeState: Identifiable, Sendable, Hashable {
    enum Kind: Sendable, Hashable {
        case start
        case current
        case proof
        case risk
        case next
    }

    let id: String
    let kind: Kind
    let label: String
    let title: String
    let detail: String
    let focusDetail: String
    let nonColorMeaning: String
    let symbolName: String
    let state: AmbitionVisualState
}

struct GoalLifePathAlternateRouteState: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let detail: String
    let symbolName: String
    let state: AmbitionVisualState
}

#if DEBUG
private extension GoalLifePathState {
    static let earlyPreview = GoalLifePathState(overview: PreviewGoalsScenarios.createdOverview)
    static let activePreview = GoalLifePathState(overview: PreviewGoalsScenarios.overview)
    static let proofRichPreview = GoalLifePathState(overview: PreviewGoalsScenarios.overview)
    static let riskPreview = GoalLifePathState(overview: PreviewGoalsScenarios.overview)
    static let alternateRoutePreview = GoalLifePathState(overview: PreviewGoalsScenarios.overview)
    static let privatePreview = GoalLifePathState(overview: PreviewGoalsScenarios.overview, privacySensitive: true)
}

#Preview("Goals Thread Focus Early") {
    GoalLifePathView(state: .earlyPreview)
        .padding()
        .background(LivingSurfaceBackground(context: .goals, state: .active, intensity: 0.72))
        .ambitionTheme(.dark)
}

#Preview("Goals Thread Focus Active") {
    GoalLifePathView(state: .activePreview)
        .padding()
        .background(LivingSurfaceBackground(context: .goals, state: .active, intensity: 0.72))
        .ambitionTheme(.dark)
}

#Preview("Goals Thread Focus Proof Rich") {
    GoalLifePathView(state: .proofRichPreview)
        .padding()
        .background(LivingSurfaceBackground(context: .goals, state: .active, intensity: 0.72))
        .ambitionTheme(.dark)
}

#Preview("Goals Thread Focus Risk") {
    GoalLifePathView(state: .riskPreview)
        .padding()
        .background(LivingSurfaceBackground(context: .goals, state: .pressured, intensity: 0.72))
        .ambitionTheme(.dark)
}

#Preview("Goals Thread Focus Alternate Route") {
    GoalLifePathView(state: .alternateRoutePreview)
        .padding()
        .background(LivingSurfaceBackground(context: .goals, state: .active, intensity: 0.72))
        .ambitionTheme(.dark)
}

#Preview("Goals Thread Focus Private") {
    GoalLifePathView(state: .privatePreview)
        .padding()
        .background(LivingSurfaceBackground(context: .goals, state: .active, intensity: 0.72))
        .ambitionTheme(.dark)
}

#Preview("Goals Thread Focus Large Type") {
    GoalLifePathView(state: .activePreview)
        .padding()
        .background(LivingSurfaceBackground(context: .goals, state: .active, intensity: 0.72))
        .ambitionTheme(.dark)
        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}

#Preview("Goals Thread Focus Reduce Motion") {
    GoalLifePathView(state: .activePreview)
        .padding()
        .background(LivingSurfaceBackground(context: .goals, state: .active, intensity: 0.72))
        .ambitionTheme(.dark)
        .transaction { transaction in
            transaction.disablesAnimations = true
        }
}
#endif

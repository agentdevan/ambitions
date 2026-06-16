import AmbitionsDesignSystem
import SwiftUI

struct GoalsObjectStagePrimitiveContract: Equatable {
    let primitiveID: String
    let ownerSurface: String
    let productObject: String
    let stageName: String
    let firstViewportStructure: String
    let replacesFirstViewportStructures: [String]
    let sourceTrustLineOrder: [String]
    let accessibilityFallbacks: [String]
    let screenshotIdentifier: String
    let avoidsGenericGoalRootOutput: Bool
    let reservesTabBarClearance: Bool

    static let current = GoalsObjectStagePrimitiveContract(
        primitiveID: "goals-object-stage",
        ownerSurface: "Goals",
        productObject: "Constellation Atlas + Orbital Lens",
        stageName: "Constellation Atlas",
        firstViewportStructure: "Full-bleed Constellation Atlas object stage with compact equal-weight life areas, Orbital Lens inspection, proof, source, receipt, and Today relationship lines.",
        replacesFirstViewportStructures: [
            "rounded equal-weight area band",
            "rounded Direction Atlas container",
            "rounded Constellation Atlas container",
            "rounded relationship field shell",
            "rounded Orbital Lens container",
            "rounded Atlas lane blocks",
            "source/proof/trust blocks"
        ],
        sourceTrustLineOrder: [
            "life area",
            "context",
            "history",
            "review",
            "Today link"
        ],
        accessibilityFallbacks: [
            "VoiceOver names Your Direction before life area, Orbital Lens, source, proof, receipt, and Today relationships",
            "Dynamic Type preserves Constellation Atlas title, life area order, Orbital Lens order, and relationship lane order",
            "Reduce Motion keeps the Constellation Atlas relationship field static",
            "Increase Contrast strengthens object-stage rules and relationship markers",
            "Differentiate Without Color exposes life area, source, proof, receipt, and Today link as text"
        ],
        screenshotIdentifier: "GoalsObjectStage",
        avoidsGenericGoalRootOutput: true,
        reservesTabBarClearance: true
    )
}

struct GoalsConstellationAtlasStage: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @State private var isOrbitalLensExpanded: Bool

    let overview: GoalsOverview
    let onPrimaryAction: (GoalsAtlasPrimaryAction) -> Void
    let screenshotProofState: GoalsScreenshotProofState

    init(
        overview: GoalsOverview,
        onPrimaryAction: @escaping (GoalsAtlasPrimaryAction) -> Void,
        screenshotProofState: GoalsScreenshotProofState = .defaultAtlas
    ) {
        self.overview = overview
        self.onPrimaryAction = onPrimaryAction
        self.screenshotProofState = screenshotProofState
        _isOrbitalLensExpanded = State(initialValue: screenshotProofState.expandsOrbitalLens)
    }

    private var primaryGoal: GoalsAtlasSurfaceState? {
        overview.bands
            .first(where: { $0.kind == .activeDirection })?
            .cards
            .first ?? overview.bands.flatMap(\.cards).first
    }

    private var pressureGoal: GoalsAtlasSurfaceState? {
        overview.bands
            .first(where: { $0.kind == .pressure })?
            .cards
            .first
    }

    private var atlasNodes: [GoalsLifeAreaItemState] {
        Array(overview.lifeAreas.items.prefix(4))
    }

    private var displayedLifeAreaItems: [GoalsLifeAreaItemState] {
        guard screenshotProofState.highlightsSelectedLifeArea,
              let selectedIndex = overview.lifeAreas.items.firstIndex(where: { $0.title == overview.orbitalLens.selectedLifeAreaTitle }) else {
            return overview.lifeAreas.items
        }

        var items = overview.lifeAreas.items
        let selected = items.remove(at: selectedIndex)
        return [selected] + items
    }

    private var proofSummary: GoalProofSummary? {
        primaryGoal?.proofSummary
    }

    private var laneStates: [GoalMissionControlLaneState] {
        let proof = proofSummary
        let blocker = pressureGoal
        let next = primaryGoal?.nextVisibleStep
        let momentum = primaryGoal?.momentumIntegrity

        return [
            GoalMissionControlLaneState(
                id: "context",
                title: "Context",
                value: overview.isSeeded ? "Preview source" : "Local source",
                detail: overview.constellationAtlasSourceFirstViewportSummary,
                symbolName: "link",
                state: .active,
                level: 0.72
            ),
            GoalMissionControlLaneState(
                id: "history",
                title: "History",
                value: (proof?.count ?? 0) > 0 ? "\(proof?.count ?? 0) saved" : "Visible path",
                detail: (proof?.count ?? 0) > 0
                    ? overview.constellationAtlasProofFirstViewportSummary
                    : "Proof path visible.",
                symbolName: "checkmark.seal",
                state: (proof?.count ?? 0) > 0 ? .proof : .calm,
                level: min(1, max(0.24, Double(proof?.count ?? 0) / 4.0)),
                showsProofPulse: (proof?.count ?? 0) > 0
            ),
            GoalMissionControlLaneState(
                id: "next-step",
                title: "Next step",
                value: next?.isAvailable == false ? "Needs review" : "Ready",
                detail: next?.title ?? primaryGoal?.nextStepHint ?? overview.heroPrimaryAction.title,
                symbolName: "scope",
                state: next?.isAvailable == false ? .stale : .active,
                level: next?.isAvailable == false ? 0.38 : 0.76
            ),
            GoalMissionControlLaneState(
                id: "pressure",
                title: "Pressure",
                value: blocker == nil ? "Clear" : blocker?.renderState.title ?? "Needs attention",
                detail: blocker?.pressureSummary ?? momentum?.detail ?? overview.hero.pressureSummary,
                symbolName: "wind",
                state: blocker == nil ? .calm : .pressured,
                level: blocker == nil ? 0.22 : 0.74
            )
        ]
    }

    var body: some View {
        let objectStageContract = GoalsObjectStagePrimitiveContract.current

        VStack(alignment: .leading, spacing: theme.spacing.md) {
            contextCrown
            if screenshotProofState.prioritizesOrbitalLens {
                orbitalLens
                equalWeightLifeAreaBand
                atlasObject
            } else {
                equalWeightLifeAreaBand
                atlasObject
                orbitalLens
            }
            sourceProofTrustAffordance
            nativeDock
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("goals.constellation-atlas.stage")
        .accessibilityValue(objectStageContract.firstViewportStructure)
    }

    private var contextCrown: some View {
        HStack(alignment: .center, spacing: theme.spacing.sm) {
            Image(systemName: "scope")
                .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.colors.accentPrimary)
                .frame(width: 38, height: 38)
                .background(Circle().fill(theme.colors.surfaceOverlay))
                .overlay(Circle().stroke(theme.colors.strokeSubtle, lineWidth: 1))

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text("Goals")
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.accentWarm)
                    .textCase(.uppercase)
                Text("Your Direction")
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                Text("Life areas, proof, source, and Today connection stay in one direction object.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("goals.context-crown")
    }

    private var equalWeightLifeAreaBand: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                Text("Equal-weight areas")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                Text("Manual order, same size")
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
            }

            LazyVGrid(columns: equalWeightLifeAreaGridColumns, alignment: .leading, spacing: theme.spacing.xs) {
                ForEach(Array(displayedLifeAreaItems.prefix(4))) { item in
                    equalWeightLifeAreaChip(
                        item,
                        isSelected: screenshotProofState.highlightsSelectedLifeArea
                            && item.title == overview.orbitalLens.selectedLifeAreaTitle
                    )
                }
            }
        }
        .padding(.vertical, theme.spacing.sm)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(colorSchemeContrast == .increased ? 0.74 : 0.34))
                .frame(height: colorSchemeContrast == .increased ? 1.5 : 1)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(colorSchemeContrast == .increased ? 0.66 : 0.28))
                .frame(height: colorSchemeContrast == .increased ? 1.5 : 1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Equal-weight Life Areas")
        .accessibilityValue(overview.lifeAreas.equalWeightSummary)
        .accessibilityHint("Areas use the same size and manual controls for visibility and order.")
        .accessibilityIdentifier("goals.life-areas.equal-weight-band")
    }

    private func equalWeightLifeAreaChip(_ item: GoalsLifeAreaItemState, isSelected: Bool) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            if isSelected {
                Image(systemName: "scope")
                    .font(theme.typography.micro.weight(.semibold))
                    .foregroundStyle(theme.colors.accentPrimary)
                    .accessibilityHidden(true)
            }
            Text(equalWeightLifeAreaTitleLabel(for: item))
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .allowsTightening(true)
            Text(equalWeightLifeAreaTraceLabel(for: item))
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(minHeight: 48, alignment: .topLeading)
        .padding(.vertical, theme.spacing.xs)
        .padding(.horizontal, theme.spacing.xs)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(isSelected ? theme.colors.accentPrimary.opacity(0.88) : theme.colors.strokeSubtle.opacity(0.46))
                .frame(height: isSelected || colorSchemeContrast == .increased ? 1.5 : 1)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(colorSchemeContrast == .increased ? 0.66 : 0.24))
                .frame(height: colorSchemeContrast == .increased ? 1.5 : 1)
        }
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(isSelected ? theme.colors.accentPrimary.opacity(0.88) : theme.colors.strokeSubtle.opacity(0.34))
                .frame(width: isSelected || colorSchemeContrast == .increased ? 3 : 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.accessibilityLabel)
        .accessibilityValue(isSelected ? "Selected Life Area. \(item.accessibilityValue)" : item.accessibilityValue)
        .accessibilityHint(item.accessibilityHint)
        .accessibilityIdentifier("goals.life-area.\(item.id)")
    }

    private var atlasObject: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack(alignment: .top, spacing: theme.spacing.md) {
                atlasRelationshipField

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(primaryGoal?.title ?? overview.hero.title)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .allowsTightening(true)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(overview.hero.dominantTruth)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(overview.constellationAtlasFirstViewportTrustSummary)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    atlasInlineTrustDepth
                }
            }
        }
        .padding(.vertical, theme.spacing.md)
        .background(atlasObjectTexture)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.colors.accentPrimary.opacity(colorSchemeContrast == .increased ? 0.82 : 0.52))
                .frame(height: colorSchemeContrast == .increased ? 2.25 : 1.5)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(colorSchemeContrast == .increased ? 0.74 : 0.30))
                .frame(height: colorSchemeContrast == .increased ? 1.5 : 1)
        }
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(theme.colors.accentPrimary.opacity(colorSchemeContrast == .increased ? 0.90 : 0.56))
                .frame(width: colorSchemeContrast == .increased ? 4 : 2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Your Direction. \(primaryGoal?.title ?? overview.hero.title). \(overview.constellationAtlasAccessibilityValue)")
        .accessibilityIdentifier("goals.constellation-atlas.object")
    }

    private var equalWeightLifeAreaGridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: theme.spacing.xs, alignment: .topLeading),
            GridItem(.flexible(), spacing: theme.spacing.xs, alignment: .topLeading),
            GridItem(.flexible(), spacing: theme.spacing.xs, alignment: .topLeading),
            GridItem(.flexible(), spacing: theme.spacing.xs, alignment: .topLeading)
        ]
    }

    private var atlasObjectTexture: some View {
        ProductMeaningCanvasEngine(
            role: .goalsRelationship,
            visualState: .selected,
            accessibilityIdentifier: "goals.constellation-atlas.relationship-canvas-engine"
        )
        .accessibilityHidden(true)
    }

    private var atlasRelationshipField: some View {
        ZStack {
            LinearGradient(
                colors: [
                    theme.colors.canvasElevated.opacity(0.20),
                    theme.colors.surfaceOverlay.opacity(0.12),
                    .clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: theme.spacing.xs) {
                ForEach(Array(atlasNodes.enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: theme.spacing.xs) {
                        Circle()
                            .fill(theme.stateStyle(for: item.state).accent)
                            .frame(width: nodeSize, height: nodeSize)
                            .overlay(Circle().stroke(theme.colors.textPrimary.opacity(0.28), lineWidth: 1))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(atlasRelationshipTitleLabel(for: item))
                                .font(theme.typography.caption.weight(.semibold))
                                .foregroundStyle(theme.colors.textPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.70)
                                .allowsTightening(true)
                            Text(atlasRelationshipTraceLabel(for: item))
                                .font(theme.typography.micro)
                                .foregroundStyle(theme.colors.textTertiary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.70)
                                .allowsTightening(true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: index.isMultiple(of: 2) ? .leading : .trailing)
                }

                if atlasNodes.isEmpty {
                    Text("No life areas yet")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }
            .padding(theme.spacing.sm)
        }
        .frame(width: 104)
        .frame(minHeight: 128)
        .accessibilityHidden(true)
    }

    private var atlasInlineTrustDepth: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            ForEach(Array(laneStates.prefix(2))) { lane in
                atlasLane(lane, isCompact: true)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("goals.atlas.inline-trust-depth")
    }

    private var orbitalLens: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Button {
                let toggle = {
                    isOrbitalLensExpanded.toggle()
                }
                if reduceMotion {
                    toggle()
                } else {
                    withAnimation(.snappy(duration: 0.24), toggle)
                }
            } label: {
                orbitalLensHeader
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("goals.orbital-lens.toggle")

            Text(overview.orbitalLens.collapsedSummary)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if isOrbitalLensExpanded {
                orbitalLensExpanded
            }
        }
        .padding(.vertical, theme.spacing.md)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(
                    screenshotProofState.prioritizesOrbitalLens || colorSchemeContrast == .increased
                        ? theme.colors.accentPrimary.opacity(0.74)
                        : theme.colors.strokeSubtle.opacity(0.52)
                )
                .frame(height: screenshotProofState.prioritizesOrbitalLens || colorSchemeContrast == .increased ? 1.75 : 1)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(colorSchemeContrast == .increased ? 0.66 : 0.28))
                .frame(height: colorSchemeContrast == .increased ? 1.5 : 1)
        }
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(theme.colors.accentPrimary.opacity(screenshotProofState.prioritizesOrbitalLens ? 0.82 : 0.42))
                .frame(width: screenshotProofState.prioritizesOrbitalLens || colorSchemeContrast == .increased ? 4 : 2)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(overview.orbitalLens.accessibilityLabel)
        .accessibilityValue(overview.orbitalLens.accessibilityValue)
        .accessibilityHint(overview.orbitalLens.accessibilityHint)
        .accessibilityIdentifier("goals.orbital-lens.collapsed")
    }

    private var orbitalLensHeader: some View {
        HStack(spacing: theme.spacing.xs) {
            Image(systemName: "circle.dotted")
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(overview.orbitalLens.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(overview.orbitalLens.selectedLifeAreaTitle)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
            }
            Spacer()
            HStack(spacing: theme.spacing.xs) {
                Text(isOrbitalLensExpanded ? "Expanded" : "Collapsed")
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
                Image(systemName: "chevron.down")
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                    .rotationEffect(.degrees(isOrbitalLensExpanded ? 180 : 0))
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .contentShape(Rectangle())
    }

    private var orbitalLensExpanded: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            if screenshotProofState.prioritizesOrbitalLens {
                orbitalLensRow(title: "Proof available", value: overview.orbitalLens.proofSummary, systemImage: "checkmark.seal")
                    .accessibilityIdentifier("goals.orbital-lens.proof")
                orbitalLensRow(title: "Context", value: overview.orbitalLens.sourceSummary, systemImage: "link")
                    .accessibilityIdentifier("goals.orbital-lens.source")
                orbitalLensRow(title: "Why this?", value: overview.orbitalLens.whyThisSummary, systemImage: "questionmark.circle")
                    .accessibilityIdentifier("goals.orbital-lens.why")
            } else {
                orbitalLensRow(title: "Selected area", value: overview.orbitalLens.selectedLifeAreaSummary, systemImage: "scope")
                orbitalLensRow(title: "Active thread", value: overview.orbitalLens.activeThreadTitle, systemImage: "arrow.triangle.branch")
                orbitalLensRow(title: "Recommended step", value: overview.orbitalLens.recommendedStepTitle, systemImage: "figure.walk")
                orbitalLensRow(title: "Feeds Today", value: overview.orbitalLens.feedsTodaySummary, systemImage: "sun.max")
                orbitalLensRow(title: "Proof available", value: overview.orbitalLens.proofSummary, systemImage: "checkmark.seal")
                    .accessibilityIdentifier("goals.orbital-lens.proof")
                orbitalLensRow(title: "Context", value: overview.orbitalLens.sourceSummary, systemImage: "link")
                    .accessibilityIdentifier("goals.orbital-lens.source")
                orbitalLensRow(title: "Why this?", value: overview.orbitalLens.whyThisSummary, systemImage: "questionmark.circle")
                    .accessibilityIdentifier("goals.orbital-lens.why")
                orbitalLensRow(title: overview.orbitalLens.statusSummary, value: "Status remains part of the direction thread, not a separate queue.", systemImage: "waveform.path")
            }

            if let target = overview.orbitalLens.target {
                Button {
                    onPrimaryAction(GoalsAtlasPrimaryAction(
                        kind: .openGoal,
                        title: overview.orbitalLens.openThreadLabel,
                        subtitle: overview.orbitalLens.activeThreadTitle,
                        systemImage: "arrow.up.right.circle",
                        target: target,
                        state: .selected
                    ))
                } label: {
                    Label(overview.orbitalLens.openThreadLabel, systemImage: "arrow.up.right.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
                .accessibilityHint("Opens the goal thread connected to this Atlas lens.")
                .accessibilityIdentifier("goals.orbital-lens.open-thread")
            }
        }
        .padding(.top, theme.spacing.xs)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("goals.orbital-lens.expanded")
    }

    private func orbitalLensRow(title: String, value: String, systemImage: String) -> some View {
        let isProofEmphasized = screenshotProofState.highlightsProof && title == "Proof available"
        return HStack(alignment: .top, spacing: theme.spacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(isProofEmphasized ? theme.colors.accentWarm : theme.colors.accentPrimary)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                Text(value)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(isProofEmphasized ? theme.spacing.xs : 0)
        .background {
            if isProofEmphasized {
                theme.colors.accentWarm.opacity(0.14)
            }
        }
        .overlay(alignment: .leading) {
            if isProofEmphasized {
                Rectangle()
                    .fill(theme.colors.accentWarm.opacity(0.78))
                    .frame(width: 3)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var sourceProofTrustAffordance: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            affordance(title: "Context", value: overview.isSeeded ? "Preview data" : "Local Goals")
            affordance(title: "Review", value: (proofSummary?.count ?? 0) > 0 ? "Proof attached" : "Ready before change")
            affordance(title: "Today link", value: "Visible before start")
        }
        .accessibilityIdentifier("goals.source-proof-trust")
    }

    private var nativeDock: some View {
        HStack(spacing: theme.spacing.sm) {
            Button {
                onPrimaryAction(overview.heroPrimaryAction)
            } label: {
                Label(overview.heroPrimaryAction.title, systemImage: overview.heroPrimaryAction.systemImage)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(AmbitionButtonStyle(tier: .hero, state: overview.heroPrimaryAction.state))
            .accessibilityHint(overview.heroPrimaryAction.subtitle)
            .accessibilityIdentifier("goals.hero.primary-action")

            Button {
                onPrimaryAction(GoalsAtlasPrimaryAction(
                    kind: .createGoal,
                    title: "Shape direction",
                    subtitle: "Create a goal without changing anything silently.",
                    systemImage: "plus",
                    target: nil,
                    state: .selected
                ))
            } label: {
                Image(systemName: "plus")
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .default))
            .accessibilityLabel("Shape direction")
            .accessibilityHint("Opens goal creation. No Goal is created automatically.")
            .accessibilityIdentifier("goals.atlas-dock.create")
        }
        .accessibilityIdentifier("goals.native-dock")
    }

    private func atlasLane(_ lane: GoalMissionControlLaneState, isCompact: Bool = false) -> some View {
        let style = theme.stateStyle(for: lane.state.ambitionState)
        return VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(spacing: theme.spacing.xs) {
                Image(systemName: lane.symbolName)
                    .foregroundStyle(style.accent)
                Text(lane.title)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
            }
            Text(lane.value)
                .font(isCompact ? theme.typography.caption.weight(.semibold) : theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text(lane.detail)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(.vertical, isCompact ? theme.spacing.xs : theme.spacing.sm)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(style.stroke.opacity(colorSchemeContrast == .increased ? 0.86 : 0.44))
                .frame(height: colorSchemeContrast == .increased ? 1.5 : 1)
        }
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(style.accent.opacity(colorSchemeContrast == .increased ? 0.90 : 0.54))
                .frame(width: colorSchemeContrast == .increased ? 4 : 2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("goals.atlas-lane.\(lane.id)")
    }

    private func affordance(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(title)
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textTertiary)
            Text(value)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, theme.spacing.sm)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(0.42))
                .frame(height: 1)
        }
    }

    private var nodeSize: CGFloat {
        20
    }

    private func equalWeightLifeAreaTraceLabel(for item: GoalsLifeAreaItemState) -> String {
        item.todayTraceSummary.localizedCaseInsensitiveContains("Today") ? "Today" : item.todayTraceSummary
    }

    private func equalWeightLifeAreaTitleLabel(for item: GoalsLifeAreaItemState) -> String {
        item.title == "Relationships" ? "Relations" : item.title
    }

    private func atlasRelationshipTraceLabel(for item: GoalsLifeAreaItemState) -> String {
        item.todayTraceSummary.localizedCaseInsensitiveContains("Today") ? "Today" : "Linked"
    }

    private func atlasRelationshipTitleLabel(for item: GoalsLifeAreaItemState) -> String {
        item.title == "Relationships" ? "Relations" : item.title
    }
}

struct GoalMissionControlLanes: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    let overview: GoalsOverview
    let onPrimaryAction: (GoalsAtlasPrimaryAction) -> Void

    private var primaryGoal: GoalsAtlasSurfaceState? {
        overview.bands
            .first(where: { $0.kind == .activeDirection })?
            .cards
            .first ?? overview.bands.flatMap(\.cards).first
    }

    private var pressureGoal: GoalsAtlasSurfaceState? {
        overview.bands
            .first(where: { $0.kind == .pressure })?
            .cards
            .first
    }

    private var lanes: [GoalMissionControlLaneState] {
        let proof = primaryGoal?.proofSummary
        let blocker = pressureGoal
        let next = primaryGoal?.nextVisibleStep
        let momentum = primaryGoal?.momentumIntegrity

        return [
            GoalMissionControlLaneState(
                id: "history",
                title: "History",
                value: (proof?.count ?? 0) > 0 ? "\(proof?.count ?? 0) saved" : "Not yet",
                detail: proof?.latestTitle ?? proof?.detail ?? "Proof will appear after progress is saved.",
                symbolName: "checkmark.seal",
                state: (proof?.count ?? 0) > 0 ? .proof : .calm,
                level: min(1, max(0.18, Double(proof?.count ?? 0) / 4.0)),
                showsProofPulse: (proof?.count ?? 0) > 0
            ),
            GoalMissionControlLaneState(
                id: "blockers",
                title: "Blockers",
                value: blocker == nil ? "Clear" : blocker?.renderState.title ?? "Needs attention",
                detail: blocker?.nextStepHint ?? "No true blocker is leading the atlas right now.",
                symbolName: "exclamationmark.triangle",
                state: blocker == nil ? .calm : .pressured,
                level: blocker == nil ? 0.18 : pressureLevel(for: blocker)
            ),
            GoalMissionControlLaneState(
                id: "next-step",
                title: "Next Step",
                value: next?.isAvailable == false ? "Needs review" : "Ready",
                detail: next?.title ?? primaryGoal?.nextStepHint ?? overview.heroPrimaryAction.title,
                symbolName: "scope",
                state: next?.isAvailable == false ? .stale : .active,
                level: next?.isAvailable == false ? 0.38 : 0.74
            ),
            GoalMissionControlLaneState(
                id: "momentum",
                title: "Momentum",
                value: momentum?.title ?? primaryGoal?.progressLabel ?? "Quiet",
                detail: momentum?.detail ?? overview.hero.pressureSummary,
                symbolName: "waveform.path.ecg",
                state: momentum?.visualState == .success ? .proof : .active,
                level: max(0.24, primaryGoal?.progressValue ?? 0.28)
            ),
        ]
    }

    var body: some View {
        AdaptiveModuleChrome(
            title: "Your Direction",
            subtitle: "Life areas stay equal-weight while Thread Focus keeps one real thread connected to Today.",
            context: .goals,
            state: pressureGoal == nil ? .active : .pressured,
            evidence: "Photo-matched DAV06 reference inspected"
        ) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                heroHeader

                MissionControlLaneGrid(
                    items: lanes.map(MissionControlLaneItem.init(atlasLane:)),
                    density: .expanded,
                    animatedReveal: true,
                    hasAppeared: hasAppeared
                )

                GoalsHeroPrimaryActionButton(
                    action: overview.heroPrimaryAction,
                    accessibilityIdentifier: "goals.hero-card",
                    handler: onPrimaryAction
                )
            }
        }
        .overlay(alignment: .topTrailing) {
            PressureGlow(
                level: pressureGoal == nil ? 0.28 : pressureLevel(for: pressureGoal),
                context: .goals,
                label: "Goal direction pressure"
            )
            .frame(width: 150)
            .padding(theme.spacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("goals.mission-control-lanes")
        .onAppear {
            hasAppeared = true
        }
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                Text("Feeds Today")
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.accentWarm)

                Text(primaryGoal?.renderState.title ?? "Ready")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.stateStyle(for: primaryGoal?.renderState.visualState ?? .default).accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .padding(.horizontal, theme.spacing.xs)
                    .padding(.vertical, theme.spacing.xxxs)
                    .background(
                        Capsule(style: .continuous)
                            .fill(theme.stateStyle(for: primaryGoal?.renderState.visualState ?? .default).fill)
                    )
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(theme.stateStyle(for: primaryGoal?.renderState.visualState ?? .default).stroke, lineWidth: 1)
                    }
            }

            Text(primaryGoal?.title ?? overview.hero.title)
                .font(theme.typography.title)
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .allowsTightening(true)
                .fixedSize(horizontal: false, vertical: true)

            Text(overview.hero.dominantTruth)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(overview.constellationAtlasCompactInspectionSummary)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("goals.constellation-atlas.inspection-summary")
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel([
            "Goals. Your Direction",
            primaryGoal?.title ?? overview.hero.title,
            primaryGoal?.renderState.title ?? "Ready",
            overview.hero.dominantTruth,
            overview.constellationAtlasCompactInspectionSummary
        ].joined(separator: ". "))
    }

    private func pressureLevel(for goal: GoalsAtlasSurfaceState?) -> Double {
        guard let goal else { return 0.18 }

        switch goal.posture {
        case .atRisk:
            return 0.74
        case .crowded:
            return 0.66
        case .stalled:
            return 0.54
        case .active:
            return 0.42
        case .lowerPriority, .achieved:
            return 0.28
        }
    }
}

struct GoalMissionControlLaneState: Identifiable, Sendable {
    let id: String
    let title: String
    let value: String
    let detail: String
    let symbolName: String
    let state: LivingVisualState
    let level: Double
    var showsProofPulse: Bool = false
}

struct GoalsHeroSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let overview: GoalsOverview
    let onPrimaryAction: (GoalsAtlasPrimaryAction) -> Void

    var body: some View {
        ObjectStageHero(state: overview.heroPrimaryAction.state) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text(overview.hero.eyebrow)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.accentWarm)
                    Text(overview.hero.title)
                        .font(theme.typography.hero)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(overview.hero.subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(overview.hero.dominantTruth)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(overview.hero.pressureSummary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.xs) {
                        ForEach(overview.hero.contextPills) { pill in
                            TagPill(pill.title, icon: pill.icon, state: pill.state)
                        }
                    }
                }

                if overview.hero.attentionPills.isEmpty == false {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: theme.spacing.xs) {
                            ForEach(overview.hero.attentionPills) { pill in
                                TagPill(pill.title, icon: pill.icon, state: pill.state)
                            }
                        }
                    }
                }

                GoalsHeroPrimaryActionButton(
                    action: overview.heroPrimaryAction,
                    handler: onPrimaryAction
                )
            }
        }
        .accessibilityIdentifier("goals.hero-card")
        .ambitionPanelAccessibility()
    }
}

private struct GoalsHeroPrimaryActionButton: View {
    @Environment(\.ambitionTheme) private var theme

    let action: GoalsAtlasPrimaryAction
    var accessibilityIdentifier = "goals.hero.primary-action"
    let handler: (GoalsAtlasPrimaryAction) -> Void

    var body: some View {
        Button {
            handler(action)
        } label: {
            HStack(alignment: .center, spacing: theme.spacing.sm) {
                Image(systemName: action.systemImage)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(action.title)
                        .font(theme.typography.bodyEmphasized)
                    Text(action.subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(AmbitionButtonStyle(tier: .hero, state: action.state))
        .accessibilityHint(action.subtitle)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

struct GoalsWeekPressureSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let summary: GoalsWeekPressureSummary

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(summary.title)
                            .font(theme.typography.section)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(summary.subtitle)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                    Spacer()
                    TagPill(summary.pill.title, icon: summary.pill.icon, state: summary.pill.state)
                }

                HStack(spacing: theme.spacing.sm) {
                    metricBlock(title: "Alive", value: summary.leadingMetric)
                    metricBlock(title: "Stretch", value: summary.trailingMetric)
                }
            }
        }
        .accessibilityIdentifier("goals.week-pressure")
        .ambitionPanelAccessibility()
    }

    @ViewBuilder
    private func metricBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
            Text(value)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
    }
}

struct GoalsPortfolioMaturitySurface: View {
    @Environment(\.ambitionTheme) private var theme

    let summary: GoalPortfolioMaturitySummary

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: summary.title, subtitle: summary.subtitle)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: theme.spacing.sm)], spacing: theme.spacing.sm) {
                    maturitySignal(summary.scopeSignal)
                    maturitySignal(summary.stuckWorkSignal)
                    maturitySignal(summary.proofSignal)
                    maturitySignal(summary.nextStepSignal)
                }

                if summary.archiveLearning.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text("Archive learning")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                        ForEach(summary.archiveLearning, id: \.self) { line in
                            Text(line)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(theme.spacing.sm)
                    .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(summary.accessibilityLabel)
        .accessibilityValue(summary.accessibilityValue)
        .accessibilityHint(summary.accessibilityHint)
        .accessibilityIdentifier("goals.portfolio-maturity")
        .ambitionPanelAccessibility()
    }

    @ViewBuilder
    private func maturitySignal(_ signal: GoalPortfolioMaturitySignal) -> some View {
        let style = theme.stateStyle(for: signal.state)
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(signal.title)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
            Text(signal.detail)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .topLeading)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(style.fill))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(style.stroke, lineWidth: 1))
    }
}

struct GoalsLifecycleRailSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let segments: [GoalLifecycleRailSegment]

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: "Ambition portfolio", subtitle: "Previous, active, and future goals stay oriented without becoming a spreadsheet.")

                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    ForEach(segments) { segment in
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            HStack(spacing: theme.spacing.xs) {
                                Text(segment.title)
                                    .font(theme.typography.bodyEmphasized)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Spacer(minLength: theme.spacing.xs)
                                Text("\(segment.count)")
                                    .font(theme.typography.section)
                                    .foregroundStyle(theme.stateStyle(for: segment.state).accent)
                            }
                            Text(segment.subtitle)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(theme.spacing.sm)
                        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
                        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.stateStyle(for: segment.state).stroke, lineWidth: 1))
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(segments.map { "\($0.title), \($0.count) goals" }.joined(separator: ". "))
        .accessibilityIdentifier("goals.lifecycle-rail")
        .ambitionPanelAccessibility()
    }
}

struct GoalStateChipsSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let chips: [GoalStateChipState]

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                SectionHeader(title: "State signals", subtitle: "Kept in view, waiting, blocked, parked, completed, and cancelled remain distinct.")
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: theme.spacing.xs)], alignment: .leading, spacing: theme.spacing.xs) {
                    ForEach(chips) { chip in
                        TagPill(
                            "\(chip.lifecycleState.title) \(chip.count)",
                            icon: chip.lifecycleState.icon,
                            state: chip.count == 0 ? .default : chip.lifecycleState.visualState
                        )
                        .accessibilityLabel("\(chip.count) \(chip.lifecycleState.title.lowercased()) goals")
                    }
                }
            }
        }
        .accessibilityIdentifier("goals.state-chips")
        .ambitionPanelAccessibility()
    }
}

struct GoalsLifeAreasPanel: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalsLifeAreasOverviewState
    let zoomMode: GoalsSemanticZoomMode
    let onZoomModeChange: (GoalsSemanticZoomMode) -> Void

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: state.title, subtitle: state.subtitle)
                Text(state.equalWeightSummary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("goals.life-areas.equal-weight-summary")

                if state.controls.isEmpty == false {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: theme.spacing.xs) {
                            ForEach(state.controls) { control in
                                Label(control.title, systemImage: control.systemImage)
                                    .font(theme.typography.caption.weight(.semibold))
                                    .foregroundStyle(theme.colors.textPrimary)
                                    .padding(.horizontal, theme.spacing.sm)
                                    .padding(.vertical, theme.spacing.xs)
                                    .background(
                                        Capsule(style: .continuous)
                                            .fill(theme.colors.surfaceOverlay.opacity(0.54))
                                    )
                                    .overlay(
                                        Capsule(style: .continuous)
                                            .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                                    )
                                    .accessibilityHint(control.accessibilityHint)
                                    .accessibilityIdentifier("goals.life-areas.control.\(control.id)")
                            }
                        }
                        .padding(.vertical, 1)
                    }
                    .accessibilityIdentifier("goals.life-areas.controls")
                }

                SegmentedFilterBar(
                    items: state.availableZoomModes,
                    selection: Binding(
                        get: { zoomMode },
                        set: { newZoomMode in
                            onZoomModeChange(newZoomMode)
                        }
                    )
                ) { $0.title }
                .accessibilityIdentifier("goals.semantic-zoom-mode")
                .accessibilityLabel("Life Areas view")
                .accessibilityHint("Switches between map and list presentations.")

                if state.items.isEmpty {
                    EmptyStateCard(
                        title: state.emptyTitle,
                        message: state.emptyMessage,
                        icon: "square.grid.2x2"
                    )
                } else if zoomMode == .map {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 172), spacing: theme.spacing.sm)], alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(state.items) { item in
                            LifeAreaMapTile(item: item)
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(state.items) { item in
                            LifeAreaListRow(item: item)
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(state.accessibilityLabel)
        .accessibilityValue(state.accessibilityValue)
        .accessibilityHint(state.accessibilityHint)
        .accessibilityIdentifier("goals.life-areas-panel")
        .ambitionPanelAccessibility()
    }
}

private struct LifeAreaMapTile: View {
    @Environment(\.ambitionTheme) private var theme

    let item: GoalsLifeAreaItemState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .top, spacing: theme.spacing.xs) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(item.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(item.subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(2)
                }
                Spacer(minLength: theme.spacing.xs)
                TagPill(item.nextFocus, state: item.state)
                    .lineLimit(2)
            }

            HStack(spacing: theme.spacing.xs) {
                countPill(title: "Goals", count: item.activeGoalCount, state: item.state)
                countPill(title: "North Stars", count: item.northStarCount, state: item.northStarCount > 0 ? .selected : .default)
                countPill(title: "One-Step", count: item.oneStepGoalCount, state: item.oneStepGoalCount > 0 ? .selected : .default)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.stateStyle(for: item.state).stroke, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.accessibilityLabel)
        .accessibilityValue(item.accessibilityValue)
        .accessibilityHint(item.accessibilityHint)
    }

    @ViewBuilder
    private func countPill(title: String, count: Int, state: AmbitionVisualState) -> some View {
        TagPill("\(title) \(count)", state: count == 0 ? .default : state)
            .accessibilityLabel("\(count) \(title)")
    }
}

private struct LifeAreaListRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: GoalsLifeAreaItemState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(item.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(item.nextFocus)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
                Spacer()
                TagPill(item.subtitle, state: item.state)
            }

            if item.goalReferences.isEmpty == false {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    ForEach(item.goalReferences) { goal in
                        HStack(alignment: .top, spacing: theme.spacing.xs) {
                            Image(systemName: "scope")
                                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                .foregroundStyle(theme.stateStyle(for: goal.state).accent)
                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                Text(goal.title)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(goal.subtitle)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.accessibilityLabel)
        .accessibilityValue(item.accessibilityValue)
        .accessibilityHint(item.accessibilityHint)
    }
}

struct GoalsNorthStarsRailSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalsNorthStarsRailState

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: state.title, subtitle: state.subtitle)

                if state.items.isEmpty {
                    EmptyStateCard(
                        title: state.emptyTitle,
                        message: state.emptyMessage,
                        icon: "north.star"
                    )
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            ForEach(state.items) { item in
                                NorthStarRailItem(item: item)
                                    .frame(width: 240)
                            }
                        }
                        .padding(.vertical, 1)
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(state.accessibilityLabel)
        .accessibilityValue(state.accessibilityValue)
        .accessibilityHint(state.accessibilityHint)
        .accessibilityIdentifier("goals.north-stars-rail")
        .ambitionPanelAccessibility()
    }
}

private struct NorthStarRailItem: View {
    @Environment(\.ambitionTheme) private var theme

    let item: GoalsNorthStarRailItemState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .top, spacing: theme.spacing.xs) {
                Image(systemName: "north.star")
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.stateStyle(for: item.state).accent)
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(item.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(item.lifeAreaLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }

            Text(item.subtitle)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(3)

            HStack(spacing: theme.spacing.xs) {
                TagPill(item.postureLabel, state: item.state)
                TagPill(item.readinessLabel, state: item.canBeShaped ? .selected : .default)
            }

            Text(item.canBeShaped ? item.shapeIntoGoalLabel : item.suggestedNextAction)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.stateStyle(for: item.state).stroke, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.accessibilityLabel)
        .accessibilityValue(item.accessibilityValue)
        .accessibilityHint(item.accessibilityHint)
    }
}

struct GoalsOneStepGoalsPanel: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalsOneStepGoalsPanelState
    let onPromote: (GoalsOneStepGoalPanelItemState) -> Void

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: state.title, subtitle: state.subtitle)

                if state.items.isEmpty {
                    EmptyStateCard(
                        title: state.emptyTitle,
                        message: state.emptyMessage,
                        icon: "checkmark.circle"
                    )
                } else {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(state.items) { item in
                            OneStepGoalPanelRow(item: item, onPromote: onPromote)
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(state.accessibilityLabel)
        .accessibilityValue(state.accessibilityValue)
        .accessibilityHint(state.accessibilityHint)
        .accessibilityIdentifier("goals.one-step-goals-panel")
        .ambitionPanelAccessibility()
    }
}

private struct OneStepGoalPanelRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: GoalsOneStepGoalPanelItemState
    let onPromote: (GoalsOneStepGoalPanelItemState) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(item.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(item.subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(2)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: theme.spacing.xxxs) {
                    TagPill(item.statusLabel, state: item.state)
                    Text(item.areaLabel)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }

            HStack(alignment: .center, spacing: theme.spacing.xs) {
                if let timingLabel = item.timingLabel {
                    TagPill(timingLabel, icon: "calendar", state: item.state)
                }
                TagPill(item.suggestedNextAction, state: item.state)
                Spacer(minLength: theme.spacing.xs)
                if item.canPromoteToGoal {
                    Button {
                        onPromote(item)
                    } label: {
                        Label(item.promoteLabel, systemImage: "arrow.up.right.circle")
                            .font(theme.typography.caption)
                    }
                    .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
                    .accessibilityHint("Opens goal creation. No Goal is created automatically.")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.stateStyle(for: item.state).stroke, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.accessibilityLabel)
        .accessibilityValue(item.accessibilityValue)
        .accessibilityHint(item.accessibilityHint)
    }
}

struct GoalsAtlasBandSection: View {
    @Environment(\.ambitionTheme) private var theme

    let band: GoalsAtlasBand

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: band.title, subtitle: band.subtitle)

                if band.cards.isEmpty {
                    EmptyStateCard(
                        title: "Nothing to surface here yet",
                        message: band.subtitle,
                        icon: "scope"
                    )
                } else {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(band.cards) { card in
                            NavigationLink(value: card.target) {
                                GoalsAtlasSurfaceView(card: card)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("goals.surface.open.\(card.target.goalID ?? card.target.draftID ?? card.id)")
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("goals.band.\(band.kind.rawValue)")
        .ambitionPanelAccessibility()
    }
}

struct GoalsAtlasSurfaceView: View {
    @Environment(\.ambitionTheme) private var theme

    let card: GoalsAtlasSurfaceState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    HStack(spacing: theme.spacing.xs) {
                        TagPill(card.lifecycleState.title, icon: card.lifecycleState.icon, state: card.lifecycleState.visualState)
                        TagPill(card.weather.title, icon: card.weather.icon, state: card.weather.visualState)
                    }

                    Text(card.title)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)

                    Text(card.subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)

                VStack(alignment: .trailing, spacing: theme.spacing.xxxs) {
                    Text(card.modeLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                    Text(card.timingLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text("Next visible step")
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
                Text(card.nextVisibleStep.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                if card.nextVisibleStep.detail.isEmpty == false {
                    Text(card.nextVisibleStep.detail)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(theme.spacing.sm)
            .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceSecondary.opacity(0.7)))

            HStack(alignment: .top, spacing: theme.spacing.sm) {
                signalColumn(title: "History", headline: card.proofSummary.title, body: card.proofSummary.detail, state: card.proofSummary.visualState)
                signalColumn(title: "Weather", headline: card.weather.title, body: card.weatherSummary, state: card.weather.visualState)
            }

            signalColumn(title: "Momentum", headline: card.momentumIntegrity.title, body: card.momentumIntegrity.detail, state: card.momentumIntegrity.visualState)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                if let supportLabel = card.supportLabel {
                    Text(supportLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }

                if let shellSummary = card.shellSummary {
                    GoalShellSummaryCompactView(summary: shellSummary)
                        .padding(.top, theme.spacing.xxxs)
                }
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .accessibilityIdentifier("goals.surface.\(card.id)")
        .accessibilityLabel("\(card.title). State \(card.lifecycleState.title). Weather \(card.weather.title), \(card.weatherSummary). Next visible step, \(card.nextVisibleStep.title). Proof, \(card.proofSummary.title). Momentum, \(card.momentumIntegrity.title).")
        .ambitionPanelAccessibility()
    }

    @ViewBuilder
    private func signalColumn(title: String, headline: String, body: String, state: AmbitionVisualState) -> some View {
        let style = theme.stateStyle(for: state)
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
            Text(headline)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textPrimary)
            Text(body)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(style.fill))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(style.stroke, lineWidth: 1))
    }
}

struct GoalsLowerPriorityDisclosureSection: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalsLowerPriorityState
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: state.title, subtitle: state.subtitle) {
                    Button(isExpanded ? "Hide" : state.disclosureTitle, action: onToggle)
                        .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                        .accessibilityIdentifier("goals.lower-priority.toggle")
                }

                if isExpanded {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(state.cards) { card in
                            NavigationLink(value: card.target) {
                                GoalsAtlasSurfaceView(card: card)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .transition(.ambitionPanel)
                }
            }
        }
        .accessibilityIdentifier("goals.band.lower-priority")
        .ambitionPanelAccessibility()
    }
}

struct GoalsHorizonLadderSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalsHorizonLadderState

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: state.title, subtitle: state.subtitle)

                if state.rungs.isEmpty {
                    EmptyStateCard(
                        title: "The ladder appears once goals have a visible phase or path.",
                        message: "It stays shallow here so direction stays legible without pulling Goal Detail forward.",
                        icon: "stairs"
                    )
                } else {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(state.rungs) { rung in
                            NavigationLink(value: rung.target) {
                                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                    HStack(alignment: .top, spacing: theme.spacing.sm) {
                                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                            Text(rung.title)
                                                .font(theme.typography.bodyEmphasized)
                                                .foregroundStyle(theme.colors.textPrimary)
                                            Text(rung.summary)
                                                .font(theme.typography.caption)
                                                .foregroundStyle(theme.colors.textSecondary)
                                        }
                                        Spacer()
                                        TagPill(rung.signalLabel, state: rung.state)
                                    }

                                    HStack(spacing: theme.spacing.sm) {
                                        Text(rung.milestoneLabel)
                                            .font(theme.typography.caption)
                                            .foregroundStyle(theme.colors.textTertiary)
                                        Text(rung.highlight)
                                            .font(theme.typography.caption)
                                            .foregroundStyle(theme.colors.textSecondary)
                                            .lineLimit(2)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(theme.spacing.sm)
                                .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("goals.horizon-ladder")
        .ambitionPanelAccessibility()
    }
}

struct GoalAtlasPreviewSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalAtlasPreviewState

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: state.title, subtitle: state.subtitle)

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(state.groups) { group in
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(group.title)
                                    .font(theme.typography.bodyEmphasized)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Spacer()
                                Text(group.subtitle)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textTertiary)
                            }

                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                ForEach(group.items) { item in
                                    HStack(alignment: .top, spacing: theme.spacing.sm) {
                                        Circle()
                                            .fill(theme.stateStyle(for: item.state).accent)
                                            .frame(width: 8, height: 8)
                                            .padding(.top, 6)
                                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                            Text(item.title)
                                                .font(theme.typography.caption)
                                                .foregroundStyle(theme.colors.textPrimary)
                                            Text(item.subtitle)
                                                .font(theme.typography.caption)
                                                .foregroundStyle(theme.colors.textSecondary)
                                                .lineLimit(2)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(theme.spacing.sm)
                        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Life areas. \(state.groups.map { "\($0.title), \($0.items.count) visible goals" }.joined(separator: ". "))")
        .accessibilityIdentifier("goals.atlas-preview")
        .ambitionPanelAccessibility()
    }
}

struct GoalArchiveSummarySurface: View {
    @Environment(\.ambitionTheme) private var theme

    let summary: GoalPortfolioArchiveSummary

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                SectionHeader(title: summary.title, subtitle: summary.subtitle)
                HStack(spacing: theme.spacing.xs) {
                    ForEach(summary.chips) { chip in
                        TagPill(
                            "\(chip.lifecycleState.title) \(chip.count)",
                            icon: chip.lifecycleState.icon,
                            state: chip.count == 0 ? .default : chip.lifecycleState.visualState
                        )
                        .accessibilityLabel("\(chip.count) \(chip.lifecycleState.title.lowercased()) archive goals")
                    }
                }
            }
        }
        .accessibilityIdentifier("goals.archive-summary")
        .ambitionPanelAccessibility()
    }
}

struct GoalSuggestionSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let step: GoalDetailStepItem

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Text(step.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Spacer()
                TagPill(step.statusLabel, state: step.state)
            }

            Text(step.summary)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)

            Text(step.timingLabel)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
    }
}

struct GoalDetailHeroSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let detail: GoalDetailPresentation

    var body: some View {
        ObjectStageHero(state: detail.headline.renderState.visualState, accent: detail.supportModeActive ? theme.colors.accentWarm : nil) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                        Text(detail.headline.eyebrow)
                            .font(theme.typography.micro)
                            .foregroundStyle(theme.colors.accentWarm)
                        Text(detail.headline.title)
                            .font(theme.typography.hero)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(detail.headline.subtitle)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                    Spacer(minLength: theme.spacing.sm)
                    VStack(alignment: .trailing, spacing: theme.spacing.xs) {
                        TagPill(detail.headline.modeLabel, state: detail.headline.renderState.visualState)
                        TagPill(detail.headline.timingLabel, state: .default)
                    }
                }

                ProgressRail(
                    title: detail.progress.label,
                    progress: detail.progress.value,
                    trailingValue: "\(Int(detail.progress.value * 100))%",
                    state: detail.headline.renderState.visualState
                )

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(detail.strategicStatus.title)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(detail.strategicStatus.summary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                    Text(detail.strategicStatus.supportingDetail)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(detail.intent)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)

                    if let supportLabel = detail.headline.supportLabel {
                        Text(supportLabel)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }
            }
        }
        .accessibilityIdentifier("goal-detail.strategic-header")
        .ambitionPanelAccessibility()
    }
}

struct GoalDetailFilmstripSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let stages: [GoalPathStage]

    var body: some View {
        GoalDetailSectionSurface(title: "Lifecycle path", subtitle: "Current position, proof, risk, and horizon stay visible before deeper tactics.") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: theme.spacing.sm) {
                    ForEach(stages) { stage in
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            HStack(alignment: .top, spacing: theme.spacing.xs) {
                                Image(systemName: symbol(for: stage))
                                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                    .foregroundStyle(color(for: stage))
                                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                    Text(stage.statusLabel)
                                        .font(theme.typography.micro)
                                        .foregroundStyle(theme.colors.textTertiary)
                                    Text(stage.title)
                                        .font(theme.typography.bodyEmphasized)
                                        .foregroundStyle(theme.colors.textPrimary)
                                }
                                Spacer(minLength: theme.spacing.sm)
                                TagPill(stage.stepCountLabel, state: stage.state)
                            }

                            markerRow(for: stage)

                            Text(stage.summary)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                                .lineLimit(3)

                            if let highlight = stage.highlight {
                                Text(highlight)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textTertiary)
                                    .lineLimit(2)
                            }
                        }
                        .frame(width: 220, alignment: .leading)
                        .padding(theme.spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                                .fill(theme.colors.surfaceOverlay)
                        )
                        .overlay(alignment: .leading) {
                            Rectangle()
                                .fill(color(for: stage))
                                .frame(width: 3)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(stage.title)
                        .accessibilityValue(stage.accessibilitySummary)
                        .accessibilityHint("Path stage marker. No color is required to understand this state.")
                    }
                }
                .padding(.vertical, 1)
            }
        }
        .accessibilityIdentifier("goal-detail.path-filmstrip")
    }

    @ViewBuilder
    private func markerRow(for stage: GoalPathStage) -> some View {
        HStack(spacing: theme.spacing.xs) {
            Label(stage.lifecycleMarkerLabel, systemImage: symbol(for: stage))
                .labelStyle(.titleAndIcon)
            Text(stage.progressShapeLabel)

            if let proof = stage.proofMarkerLabel {
                Label(proof, systemImage: "checkmark.seal")
                    .labelStyle(.titleAndIcon)
            }

            if let risk = stage.riskMarkerLabel {
                Label(risk, systemImage: "exclamationmark.triangle")
                    .labelStyle(.titleAndIcon)
            }

            if let route = stage.routeIndicatorLabel {
                Label(route, systemImage: "arrow.triangle.branch")
                    .labelStyle(.titleAndIcon)
            }
        }
        .font(theme.typography.micro)
        .foregroundStyle(theme.colors.textTertiary)
        .lineLimit(2)
    }

    private func color(for stage: GoalPathStage) -> Color {
        switch stage.position {
        case .completed:
            return theme.colors.success
        case .current:
            return theme.colors.accentPrimary
        case .blocked:
            return theme.colors.warning
        case .upcoming:
            return theme.colors.textTertiary
        }
    }

    private func symbol(for stage: GoalPathStage) -> String {
        switch stage.position {
        case .completed:
            "checkmark.seal"
        case .current:
            "scope"
        case .blocked:
            "exclamationmark.triangle"
        case .upcoming:
            "arrow.triangle.branch"
        }
    }
}

struct LifePathThreadSurface: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let state: LifePathThreadState

    var body: some View {
        GoalDetailSectionSurface(title: state.title, subtitle: state.subtitle) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                if dynamicTypeSize.isAccessibilitySize {
                    accessibleThread
                } else {
                    visualThread
                }

                if state.proofBeads.isEmpty == false {
                    proofBeads
                }

                if state.riskPinches.isEmpty == false {
                    riskPinches
                }

                if state.alternateRouteFolds.isEmpty == false {
                    alternateRouteFold
                }

                sourceFold
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(state.accessibilityLabel)
        .accessibilityValue(state.accessibilityValue)
        .accessibilityHint(state.accessibilityHint)
        .accessibilityIdentifier("goal-detail.life-path-thread")
    }

    private var visualThread: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(state.nodes.enumerated()), id: \.element.id) { index, node in
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    VStack(spacing: theme.spacing.xs) {
                        nodeMarker(node)

                        if index < state.nodes.count - 1 {
                            Capsule(style: .continuous)
                                .fill(theme.stateStyle(for: node.state).stroke)
                                .frame(width: 3, height: 42)
                                .accessibilityHidden(true)
                        }
                    }

                    nodeBody(node)
                        .padding(.bottom, index < state.nodes.count - 1 ? theme.spacing.sm : 0)
                }
            }
        }
    }

    private var accessibleThread: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            ForEach(state.nodes) { node in
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    nodeMarker(node)
                    nodeBody(node)
                }
            }
        }
    }

    private func nodeMarker(_ node: LifePathThreadNode) -> some View {
        let style = theme.stateStyle(for: node.state)

        return ZStack {
            Circle()
                .fill(style.fill)
                .frame(width: 42, height: 42)
                .overlay(Circle().stroke(style.stroke, lineWidth: 1))

            Image(systemName: node.symbolName)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(style.accent)
                .accessibilityHidden(true)
        }
        .overlay(alignment: .bottomTrailing) {
            Text("\(node.order)")
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textPrimary)
                .frame(width: 20, height: 20)
                .background(Circle().fill(theme.colors.surfaceOverlay))
                .overlay(Circle().stroke(style.stroke, lineWidth: 1))
        }
    }

    private func nodeBody(_ node: LifePathThreadNode) -> some View {
        let style = theme.stateStyle(for: node.state)

        return VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                Text(node.roleLabel)
                    .font(theme.typography.micro)
                    .foregroundStyle(style.accent)

                Text(node.statusLabel)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)

                Spacer(minLength: theme.spacing.xs)

                TagPill(node.stepCountLabel, state: node.state)
            }

            Text(node.title)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(node.summary)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Label(node.markerLabel, systemImage: node.symbolName)
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(style.stroke, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Order \(node.order). \(node.roleLabel). \(node.title). \(node.nonColorMeaning)")
    }

    private var proofBeads: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            SectionHeader(title: "Proof beads", subtitle: "Evidence attaches to the thread without becoming the path itself.")
            ForEach(state.proofBeads) { bead in
                markerPill(title: bead.title, summary: bead.summary, symbolName: "checkmark.seal", state: bead.state)
            }
        }
    }

    private var riskPinches: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            SectionHeader(title: "Risk pinch", subtitle: "Friction is marked by role and copy, not color alone.")
            ForEach(state.riskPinches) { pinch in
                markerPill(title: pinch.title, summary: pinch.summary, symbolName: "exclamationmark.triangle", state: pinch.state)
            }
        }
    }

    private var alternateRouteFold: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            SectionHeader(title: "AlternateRouteFold", subtitle: "Branches stay folded until the user reviews tradeoffs.")
            ForEach(state.alternateRouteFolds) { fold in
                markerPill(title: fold.title, summary: "\(fold.summary) \(fold.reviewLabel)", symbolName: "arrow.triangle.branch", state: fold.state)
            }
        }
    }

    private var sourceFold: some View {
        let source = state.sourceFold

        return ObjectStageSurface(state: source.state) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Label(source.title, systemImage: "doc.text.magnifyingglass")
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)

                Text(source.summary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)

                Text(source.breadcrumbLabels.joined(separator: " > "))
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
                    .lineLimit(2)

                Text(source.privacyLabel)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
    }

    private func markerPill(title: String, summary: String, symbolName: String, state: AmbitionVisualState) -> some View {
        let style = theme.stateStyle(for: state)

        return HStack(alignment: .top, spacing: theme.spacing.xs) {
            Image(systemName: symbolName)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(style.accent)
                .frame(width: 24, height: 24)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(summary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.xs)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(style.fill))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(style.stroke, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title). \(summary)")
    }
}

struct GoalDetailNextMovementSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let movement: GoalDetailNextMovement

    var body: some View {
        GoalDetailSectionSurface(title: "What matters next", subtitle: "One step first, before the rest of the path.") {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(movement.title)
                            .font(theme.typography.section)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(movement.summary)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                    Spacer()
                    TagPill(movement.timingLabel, state: movement.state)
                }

                Text(movement.rationale)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .accessibilityIdentifier("goal-detail.next-movement")
    }
}

struct GoalDetailTrajectorySurface: View {
    @Environment(\.ambitionTheme) private var theme

    let trajectory: GoalDetailTrajectoryState

    var body: some View {
        GoalDetailSectionSurface(title: "Current phase and momentum", subtitle: "Phase truth stays strategic instead of reading like admin.") {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(trajectory.phaseTitle)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(trajectory.phaseSummary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    trajectoryLine(title: "Milestone", detail: trajectory.milestoneSummary)
                    trajectoryLine(title: "Momentum", detail: trajectory.momentumSummary)
                    trajectoryLine(title: "Timeline", detail: trajectory.timelineSummary)
                }
            }
        }
    }

    @ViewBuilder
    private func trajectoryLine(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(title)
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textTertiary)
            Text(detail)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
        }
    }
}

struct GoalDetailRecentMovementSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let movement: GoalDetailRecentMovementState

    var body: some View {
        GoalDetailSectionSurface(title: movement.title, subtitle: movement.summary) {
            if movement.items.isEmpty {
                Text("No recent movement is visible yet.")
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
            } else {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(movement.items) { item in
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            TagPill(item.categoryLabel, state: item.state)
                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                Text(item.title)
                                    .font(theme.typography.bodyEmphasized)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(item.subtitle)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                                Text(item.timestamp)
                                    .font(theme.typography.micro)
                                    .foregroundStyle(theme.colors.textTertiary)
                            }
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("goal-detail.recent-movement")
    }
}

struct GoalActionGrid: View {
    @Environment(\.ambitionTheme) private var theme

    let actions: [GoalDetailActionState]
    let handler: (GoalDetailActionKind) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: theme.spacing.xs)], spacing: theme.spacing.xs) {
            ForEach(actions) { action in
                Button {
                    handler(action.kind)
                } label: {
                    Label(action.title, systemImage: action.systemImage)
                        .font(theme.typography.caption)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .padding(.vertical, theme.spacing.xs)
                }
                .buttonStyle(AmbitionPressableButtonStyle(state: action.state))
            }
        }
    }
}

struct GoalDetailSectionSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let subtitle: String?
    let content: AnyView

    init<Content: View>(title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = AnyView(content())
    }

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: title, subtitle: subtitle)
                content
            }
        }
        .ambitionPanelAccessibility()
    }
}

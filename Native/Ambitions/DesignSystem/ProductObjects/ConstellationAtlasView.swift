import AmbitionsDesignSystem
import SwiftUI

struct ConstellationAtlasView: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @State private var isOrbitalLensExpanded: Bool
    @State private var selectedLifeAreaID: String?

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
        _selectedLifeAreaID = State(initialValue: screenshotProofState.highlightsSelectedLifeArea ? overview.lifeAreas.items.first(where: { $0.title == overview.orbitalLens.selectedLifeAreaTitle })?.id : nil)
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

    private var selectedLifeAreaTitle: String? {
        if let selectedLifeAreaID,
           let selected = overview.lifeAreas.items.first(where: { $0.id == selectedLifeAreaID }) {
            return selected.title
        }
        guard screenshotProofState.highlightsSelectedLifeArea else { return nil }
        return overview.orbitalLens.selectedLifeAreaTitle
    }

    private var displayedLifeAreaItems: [GoalsLifeAreaItemState] {
        guard let selectedLifeAreaTitle,
              let selectedIndex = overview.lifeAreas.items.firstIndex(where: { $0.title == selectedLifeAreaTitle }) else {
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
                value: overview.isSeeded ? "Preview context" : "Local source",
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
                    : "Proof and smaller steps stay visible inside the thread.",
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
        let stageScene = GoalsLens.makeStageScene(for: overview)

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
        .accessibilityValue(overview.constellationAtlasAccessibilityValue)
        .accessibilityHint(stageScene.satisfiesArchitectureTree
            ? "Life Areas, proof, and the Today connection stay available for review."
            : "Goal relationships stay available for review.")
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
                Text("Life areas, threads, smaller steps, and proof stay connected to Today.")
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
                Text("Life areas")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                Text("Choose an area, then open its step path")
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
            }

            LazyVGrid(columns: equalWeightLifeAreaGridColumns, alignment: .leading, spacing: theme.spacing.xs) {
                ForEach(Array(displayedLifeAreaItems.prefix(4))) { item in
                    equalWeightLifeAreaChip(
                        item,
                        isSelected: item.id == selectedLifeAreaID
                            || (screenshotProofState.highlightsSelectedLifeArea && item.title == overview.orbitalLens.selectedLifeAreaTitle)
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
        .accessibilityLabel("Life Areas")
        .accessibilityValue(overview.lifeAreas.equalWeightSummary)
        .accessibilityHint("Choose an area to inspect its active thread.")
        .accessibilityIdentifier("goals.life-areas.equal-weight-band")
    }

    private func equalWeightLifeAreaChip(_ item: GoalsLifeAreaItemState, isSelected: Bool) -> some View {
        Button {
            let selection = {
                selectedLifeAreaID = item.id
                isOrbitalLensExpanded = true
            }
            if reduceMotion {
                selection()
            } else {
                withAnimation(.snappy(duration: 0.24), selection)
            }
        } label: {
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
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
        .accessibilityHint("Choose this Life Area to open its active thread lens. \(item.accessibilityHint)")
        .accessibilityIdentifier("goals.life-area.\(item.id).button")
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

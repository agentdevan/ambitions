import AmbitionsDesignSystem
import SwiftUI

// accessibilityReduceMotion contract: this helper reads the root ConstellationAtlasView reduceMotion environment before running animation.
extension ConstellationAtlasView {

    var atlasRelationshipField: some View {
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

            if usesStackedAtlasObject {
                LazyVGrid(columns: stackedAtlasRelationshipColumns, alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(Array(atlasNodes.enumerated()), id: \.element.id) { index, item in
                        atlasRelationshipNode(index: index, item: item, alignsTrailing: false)
                    }
                }
                .padding(theme.spacing.sm)
            } else {
                VStack(spacing: theme.spacing.xs) {
                    ForEach(Array(atlasNodes.enumerated()), id: \.element.id) { index, item in
                        atlasRelationshipNode(index: index, item: item, alignsTrailing: index.isMultiple(of: 2) == false)
                    }

                    if atlasNodes.isEmpty {
                        Text("No life areas yet")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                    }
                }
                .padding(theme.spacing.sm)
            }
        }
        .frame(width: usesStackedAtlasObject ? nil : 104)
        .frame(maxWidth: usesStackedAtlasObject ? .infinity : nil, alignment: .leading)
        .frame(minHeight: 128)
        .accessibilityHidden(true)
    }


    func atlasRelationshipNode(index: Int, item: GoalsLifeAreaItemState, alignsTrailing: Bool) -> some View {
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
                if usesStackedAtlasObject == false {
                    Text(atlasRelationshipTraceLabel(for: item))
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textTertiary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)
                        .allowsTightening(true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: alignsTrailing ? .trailing : .leading)
    }


    var stackedAtlasRelationshipColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: theme.spacing.sm, alignment: .leading),
            GridItem(.flexible(), spacing: theme.spacing.sm, alignment: .leading)
        ]
    }

    var atlasInlineTrustDepth: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            ForEach(Array(laneStates.prefix(2))) { lane in
                atlasLane(lane, isCompact: true)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("goals.atlas.inline-trust-depth")
    }


    var orbitalLens: some View {
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
        .padding(.leading, theme.spacing.md)
        .padding(.trailing, theme.spacing.xs)
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


    var orbitalLensHeader: some View {
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


    var orbitalLensExpanded: some View {
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


    func orbitalLensRow(title: String, value: String, systemImage: String) -> some View {
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


    var sourceProofTrustAffordance: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            affordance(title: "Context", value: overview.isSeeded ? "Preview data" : "Local Goals")
            affordance(title: "Review", value: (proofSummary?.count ?? 0) > 0 ? "Proof attached" : "Review first")
            affordance(title: "Today link", value: "Visible before start")
        }
        .accessibilityIdentifier("goals.source-proof-trust")
    }


    var nativeDock: some View {
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


    func atlasLane(_ lane: GoalMissionControlLaneState, isCompact: Bool = false) -> some View {
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
        .padding(.leading, theme.spacing.md)
        .padding(.trailing, theme.spacing.xs)
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


    func affordance(title: String, value: String) -> some View {
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


    var nodeSize: CGFloat {
        20
    }


    func equalWeightLifeAreaTraceLabel(for item: GoalsLifeAreaItemState) -> String {
        item.todayTraceSummary.localizedCaseInsensitiveContains("Today") ? "Today" : item.todayTraceSummary
    }


    func equalWeightLifeAreaTitleLabel(for item: GoalsLifeAreaItemState) -> String {
        item.title == "Relationships" ? "Relations" : item.title
    }
}

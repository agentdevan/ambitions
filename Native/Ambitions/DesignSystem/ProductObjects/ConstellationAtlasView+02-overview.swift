import AmbitionsDesignSystem
import SwiftUI

// accessibilityReduceMotion contract: animation in this extracted atlas helper is gated by the root reduceMotion environment value.
extension ConstellationAtlasView {
    var primaryGoal: GoalsAtlasSurfaceState? {
        overview.bands
            .first(where: { $0.kind == .activeDirection })?
            .cards
            .first ?? overview.bands.flatMap(\.cards).first
    }


    var pressureGoal: GoalsAtlasSurfaceState? {
        overview.bands
            .first(where: { $0.kind == .pressure })?
            .cards
            .first
    }


    var atlasNodes: [GoalsLifeAreaItemState] {
        Array(overview.lifeAreas.items.prefix(4))
    }


    var selectedLifeAreaTitle: String? {
        if let selectedLifeAreaID,
           let selected = overview.lifeAreas.items.first(where: { $0.id == selectedLifeAreaID }) {
            return selected.title
        }
        guard screenshotProofState.highlightsSelectedLifeArea else { return nil }
        return overview.orbitalLens.selectedLifeAreaTitle
    }


    var displayedLifeAreaItems: [GoalsLifeAreaItemState] {
        guard let selectedLifeAreaTitle,
              let selectedIndex = overview.lifeAreas.items.firstIndex(where: { $0.title == selectedLifeAreaTitle }) else {
            return overview.lifeAreas.items
        }

        var items = overview.lifeAreas.items
        let selected = items.remove(at: selectedIndex)
        return [selected] + items
    }


    var proofSummary: GoalProofSummary? {
        primaryGoal?.proofSummary
    }


    var laneStates: [GoalMissionControlLaneState] {
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


    var contextCrown: some View {
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


    var equalWeightLifeAreaBand: some View {
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


    func equalWeightLifeAreaChip(_ item: GoalsLifeAreaItemState, isSelected: Bool) -> some View {
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


    var atlasObject: some View {
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


    var equalWeightLifeAreaGridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: theme.spacing.xs, alignment: .topLeading),
            GridItem(.flexible(), spacing: theme.spacing.xs, alignment: .topLeading),
            GridItem(.flexible(), spacing: theme.spacing.xs, alignment: .topLeading),
            GridItem(.flexible(), spacing: theme.spacing.xs, alignment: .topLeading)
        ]
    }


    var atlasObjectTexture: some View {
        ProductMeaningCanvasEngine(
            role: .goalsRelationship,
            visualState: .selected,
            accessibilityIdentifier: "goals.constellation-atlas.relationship-canvas-engine"
        )
        .accessibilityHidden(true)
    }
}

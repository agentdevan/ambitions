import AmbitionsDesignSystem
import SwiftUI

/// Mutation/accessibility/proof contract: root actions only navigate or launch typed Capture context; they do not fabricate goal, proof, or Today state.
struct GoalsObjectView: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let overview: GoalsOverview
    let screenshotProofState: GoalsScreenshotProofState
    let onPrimaryAction: (GoalsAtlasPrimaryAction) -> Void
    let onOpenLifeArea: (GoalsLifeAreaAtlasRegion) -> Void
    let onCreate: (CaptureTypedRouteKind, GoalsLifeAreaAtlasRegion?) -> Void

    private var regions: [GoalsLifeAreaAtlasRegion] {
        GoalsLifeAreaAtlasRegion.regions(from: overview)
    }

    var body: some View {
        LifeAreaAtlasField(
            regions: regions,
            primaryAction: overview.heroPrimaryAction,
            screenshotProofState: screenshotProofState,
            isReduceMotionEnabled: reduceMotion,
            onPrimaryAction: onPrimaryAction,
            onOpenLifeArea: onOpenLifeArea,
            onCreate: onCreate
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel(GoalsAccessibility.rootSummary(regions: regions))
    }
}

private struct LifeAreaAtlasField: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let regions: [GoalsLifeAreaAtlasRegion]
    let primaryAction: GoalsAtlasPrimaryAction
    let screenshotProofState: GoalsScreenshotProofState
    let isReduceMotionEnabled: Bool
    let onPrimaryAction: (GoalsAtlasPrimaryAction) -> Void
    let onOpenLifeArea: (GoalsLifeAreaAtlasRegion) -> Void
    let onCreate: (CaptureTypedRouteKind, GoalsLifeAreaAtlasRegion?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            atlasHeader
            atlasStateRibbon
            atlasObject
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
    }
}

private extension LifeAreaAtlasField {
    var focusRegion: GoalsLifeAreaAtlasRegion? {
        regions.first { $0.hasActivity } ?? regions.first
    }

    var proofRegion: GoalsLifeAreaAtlasRegion? {
        regions.first { ($0.proofCount + $0.receiptCount) > 0 } ?? focusRegion
    }

    var highlightedRegionID: String? {
        if screenshotProofState.highlightsProof {
            return proofRegion?.id
        }
        if screenshotProofState.highlightsSelectedLifeArea {
            return focusRegion?.id
        }
        return nil
    }

    var atlasRibbonState: AmbitionVisualState {
        if screenshotProofState.highlightsProof {
            return .success
        }
        if screenshotProofState.highlightsSelectedLifeArea {
            return .selected
        }
        return primaryAction.state
    }

    var atlasRibbonIcon: String {
        if screenshotProofState.highlightsProof {
            return "checkmark.seal"
        }
        if screenshotProofState.highlightsSelectedLifeArea {
            return "scope"
        }
        return primaryAction.systemImage
    }

    var atlasRibbonTitle: String {
        if screenshotProofState.highlightsProof {
            return "Proof visible"
        }
        if screenshotProofState.highlightsSelectedLifeArea {
            return "Selected area"
        }
        switch primaryAction.state {
        case .warning:
            return "Recovery focus"
        default:
            return "Active thread"
        }
    }

    var atlasRibbonDetail: String {
        if screenshotProofState.highlightsProof {
            let region = proofRegion
            return region?.proofHistoryLabel ?? "Evidence and receipts stay attached to this direction."
        }
        if screenshotProofState.highlightsSelectedLifeArea {
            let region = focusRegion
            return [region?.title, region?.primaryCountLabel]
                .compactMap { $0 }
                .joined(separator: " / ")
        }
        return primaryAction.subtitle
    }

    var atlasHeader: some View {
        HStack(alignment: .center, spacing: theme.spacing.md) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text("Life Area Atlas")
                    .font(theme.typography.title)
                    .foregroundStyle(theme.colors.textPrimary)
                    .accessibilityIdentifier("goals.life-area-atlas.title")
                Text("Life areas, active threads, and loose steps stay connected to Today.")
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: theme.spacing.sm)

            Button {
                onCreate(.goalSeed, nil)
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: theme.icon.mediumSize, weight: .semibold))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .foregroundStyle(theme.colors.accentPrimary)
            .accessibilityLabel("Add goal")
            .accessibilityHint("Opens Capture with Goals context.")
            .accessibilityIdentifier("goals.capture-plus")
        }
    }

    var atlasStateRibbon: some View {
        let style = theme.stateStyle(for: atlasRibbonState)
        return HStack(alignment: .center, spacing: theme.spacing.sm) {
            Image(systemName: atlasRibbonIcon)
                .font(.system(size: theme.icon.smallSize, weight: .semibold))
                .foregroundStyle(style.accent)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(style.fill)
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(atlasRibbonTitle)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                Text(atlasRibbonDetail)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: theme.spacing.xs)
        }
        .padding(.vertical, theme.spacing.xs)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(style.accent.opacity(0.72))
                .frame(width: screenshotProofState == .defaultAtlas ? 2 : 3)
        }
        .padding(.leading, theme.spacing.xs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(atlasRibbonTitle)
        .accessibilityValue(atlasRibbonDetail)
        .accessibilityIdentifier("goals.life-area-atlas.state-ribbon")
    }

    @ViewBuilder
    var atlasObject: some View {
        if usesListAtlas {
            atlasListObject
        } else {
            radialAtlasObject
        }
    }

    var radialAtlasObject: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let center = CGPoint(x: size.width * 0.5, y: size.height * (dynamicTypeSize.isAccessibilitySize ? 0.50 : 0.47))
            let radiusX = max(96, size.width * (dynamicTypeSize.isAccessibilitySize ? 0.31 : 0.38))
            let radiusY = max(104, size.height * (dynamicTypeSize.isAccessibilitySize ? 0.28 : 0.30))

            ZStack {
                atlasObjectAccessibilityMarker
                    .position(x: 0.5, y: 0.5)

                ProductMeaningCanvasEngine(
                    role: .goalsRelationship,
                    marks: regions.map { ProductMeaningCanvasMark(id: $0.id, intensity: $0.atlasIntensity) },
                    visualState: primaryAction.state,
                    accessibilityIdentifier: "goals.life-area-atlas.meaning-canvas"
                )
                .opacity(0.24)
                .accessibilityHidden(true)

                ForEach(Array(regions.enumerated()), id: \.element.id) { index, region in
                    let point = atlasPoint(index: index, count: regions.count, center: center, radiusX: radiusX, radiusY: radiusY)

                    Path { path in
                        path.move(to: center)
                        path.addLine(to: point)
                    }
                    .stroke(region.atlasTint(theme).opacity(region.hasActivity ? 0.42 : 0.18), lineWidth: region.hasActivity ? 1.6 : 1)
                    .accessibilityHidden(true)

                    LifeAreaAtlasNode(
                        region: region,
                        isSelected: highlightedRegionID == region.id && screenshotProofState.highlightsSelectedLifeArea,
                        isProofHighlighted: highlightedRegionID == region.id && screenshotProofState.highlightsProof,
                        onOpen: { onOpenLifeArea(region) },
                        onCreate: { onCreate(.goalSeed, region) }
                    )
                    .frame(width: nodeWidth, height: nodeHeight)
                    .position(point)
                }

                AtlasCurrentStepObject(
                    action: primaryAction,
                    isProofHighlighted: screenshotProofState.highlightsProof,
                    onOpen: { onPrimaryAction(primaryAction) }
                )
                .frame(width: dynamicTypeSize.isAccessibilitySize ? 180 : 160)
                .position(center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 560 : 395)
    }

    var atlasListObject: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            atlasObjectAccessibilityMarker

            AtlasCurrentStepObject(
                action: primaryAction,
                isProofHighlighted: screenshotProofState.highlightsProof,
                onOpen: { onPrimaryAction(primaryAction) }
            )
            .accessibilityIdentifier("goals.current-step.open")

            LazyVStack(alignment: .leading, spacing: theme.spacing.sm) {
                ForEach(regions) { region in
                    LifeAreaAtlasListRow(
                        region: region,
                        isSelected: highlightedRegionID == region.id && screenshotProofState.highlightsSelectedLifeArea,
                        isProofHighlighted: highlightedRegionID == region.id && screenshotProofState.highlightsProof,
                        onOpen: { onOpenLifeArea(region) },
                        onCreate: { onCreate(.goalSeed, region) }
                    )
                }
            }
        }
        .padding(.top, theme.spacing.sm)
    }

    var usesListAtlas: Bool {
        dynamicTypeSize >= .xxxLarge
    }

    var atlasObjectAccessibilityMarker: some View {
        Rectangle()
            .fill(theme.colors.textPrimary.opacity(0.01))
            .frame(width: 1, height: 1)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Life Area Atlas object")
            .accessibilityIdentifier("goals.life-area-atlas.object")
    }

    var nodeWidth: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 148 : 124
    }

    var nodeHeight: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 118 : 96
    }

    func atlasPoint(
        index: Int,
        count: Int,
        center: CGPoint,
        radiusX: CGFloat,
        radiusY: CGFloat
    ) -> CGPoint {
        let angle = (-CGFloat.pi / 2) + (2 * CGFloat.pi * CGFloat(index) / CGFloat(max(count, 1)))
        return CGPoint(
            x: center.x + cos(angle) * radiusX,
            y: center.y + sin(angle) * radiusY
        )
    }
}

extension GoalsLifeAreaAtlasRegion {
    var atlasIntensity: Double {
        min(1, max(0.18, Double(activeGoalCount + looseStepCount + proofCount + receiptCount + thoughtCount) / 6.0))
    }

    func atlasTint(_ theme: AmbitionTheme) -> Color {
        if activeGoalCount > 0 {
            return theme.colors.accentPrimary
        }
        if looseStepCount > 0 {
            return theme.colors.accentSecondary
        }
        return theme.colors.textTertiary
    }
}

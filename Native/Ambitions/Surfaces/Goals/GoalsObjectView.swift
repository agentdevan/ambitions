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
            isReduceMotionEnabled: reduceMotion,
            onPrimaryAction: onPrimaryAction,
            onOpenLifeArea: onOpenLifeArea,
            onCreate: onCreate
        )
        .accessibilityIdentifier("goals.life-area-atlas")
        .accessibilityElement(children: .contain)
        .accessibilityLabel(GoalsAccessibility.rootSummary(regions: regions))
    }
}

private struct LifeAreaAtlasField: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let regions: [GoalsLifeAreaAtlasRegion]
    let primaryAction: GoalsAtlasPrimaryAction
    let isReduceMotionEnabled: Bool
    let onPrimaryAction: (GoalsAtlasPrimaryAction) -> Void
    let onOpenLifeArea: (GoalsLifeAreaAtlasRegion) -> Void
    let onCreate: (CaptureTypedRouteKind, GoalsLifeAreaAtlasRegion?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            atlasHeader
            atlasObject
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
    }
}

private extension LifeAreaAtlasField {
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

    var atlasObject: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let center = CGPoint(x: size.width * 0.5, y: size.height * 0.50)
            let radiusX = max(96, size.width * (dynamicTypeSize.isAccessibilitySize ? 0.31 : 0.38))
            let radiusY = max(112, size.height * (dynamicTypeSize.isAccessibilitySize ? 0.28 : 0.34))

            ZStack {
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
                        onOpen: { onOpenLifeArea(region) },
                        onCreate: { onCreate(region.isOpenField ? .noteThought : .goalSeed, region) }
                    )
                    .frame(width: nodeWidth, height: nodeHeight)
                    .position(point)
                }

                AtlasCurrentStepObject(
                    action: primaryAction,
                    onOpen: { onPrimaryAction(primaryAction) }
                )
                .frame(width: dynamicTypeSize.isAccessibilitySize ? 180 : 160)
                .position(center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 560 : 430)
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

private struct LifeAreaAtlasNode: View {
    @Environment(\.ambitionTheme) private var theme

    let region: GoalsLifeAreaAtlasRegion
    let onOpen: () -> Void
    let onCreate: () -> Void

    var body: some View {
        Button(action: region.hasActivity ? onOpen : onCreate) {
            VStack(alignment: .center, spacing: theme.spacing.xs) {
                ZStack {
                    Circle()
                        .fill(region.atlasTint(theme).opacity(region.hasActivity ? 0.26 : 0.12))
                    Image(systemName: region.symbolName)
                        .font(.system(size: theme.icon.smallSize, weight: .semibold))
                        .foregroundStyle(region.hasActivity ? region.atlasTint(theme) : theme.colors.textSecondary)
                }
                .frame(width: 36, height: 36)
                .accessibilityHidden(true)

                Text(region.title)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)

                Text(region.primaryCountLabel)
                    .font(theme.typography.micro)
                    .foregroundStyle(region.hasActivity ? region.atlasTint(theme) : theme.colors.textTertiary)
                    .lineLimit(1)

                if region.hasActivity {
                    ActivityMarks(region: region)
                } else {
                    Label(region.isOpenField ? "Add thought" : "Add goal", systemImage: "plus.circle")
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.74)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.plain)
        .contentShape(Capsule())
        .accessibilityIdentifier("goals.life-area.\(region.id)")
        .accessibilityLabel(region.accessibilityLabel)
        .accessibilityValue(region.accessibilityValue)
        .accessibilityHint(region.accessibilityHint)
    }
}

private struct ActivityMarks: View {
    @Environment(\.ambitionTheme) private var theme

    let region: GoalsLifeAreaAtlasRegion

    var body: some View {
        HStack(spacing: theme.spacing.xs) {
            mark(count: region.activeGoalCount, symbol: "target", label: "goals")
            mark(count: region.looseStepCount, symbol: "smallcircle.filled.circle", label: "steps")
            mark(count: region.thoughtCount, symbol: "sparkle", label: "thoughts")
            mark(count: region.proofCount + region.receiptCount, symbol: "seal", label: "history")
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func mark(count: Int, symbol: String, label: String) -> some View {
        if count > 0 {
            Image(systemName: symbol)
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textSecondary)
                .accessibilityLabel("\(count) \(label)")
        }
    }
}

private struct AtlasCurrentStepObject: View {
    @Environment(\.ambitionTheme) private var theme

    let action: GoalsAtlasPrimaryAction
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .center, spacing: theme.spacing.xs) {
                Image(systemName: action.systemImage)
                    .font(.system(size: theme.icon.largeSize, weight: .semibold))
                    .foregroundStyle(theme.colors.accentPrimary)
                    .accessibilityHidden(true)

                Text("Start here")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textSecondary)
                    .textCase(.uppercase)
                    .lineLimit(1)

                Text(action.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)

                Text(action.subtitle)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.74)
            }
            .padding(theme.spacing.sm)
        }
        .buttonStyle(.plain)
        .contentShape(Capsule())
        .accessibilityIdentifier("goals.current-step.open")
        .accessibilityLabel(action.title)
        .accessibilityHint(action.subtitle)
    }
}

private extension GoalsLifeAreaAtlasRegion {
    var atlasIntensity: Double {
        min(1, max(0.18, Double(activeGoalCount + looseStepCount + proofCount + receiptCount + thoughtCount) / 6.0))
    }

    func atlasTint(_ theme: AmbitionTheme) -> Color {
        if isOpenField {
            return theme.colors.accentWarm
        }
        if activeGoalCount > 0 {
            return theme.colors.accentPrimary
        }
        if looseStepCount > 0 {
            return theme.colors.accentSecondary
        }
        return theme.colors.textTertiary
    }
}

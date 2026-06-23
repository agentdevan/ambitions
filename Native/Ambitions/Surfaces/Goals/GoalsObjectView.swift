import AmbitionsDesignSystem
import SwiftUI

// Mutation/accessibility/proof contract: root actions only navigate or launch typed Capture context; they do not fabricate goal, proof, or Today state.
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
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            atlasHeader
            LazyVGrid(columns: columns, alignment: .leading, spacing: theme.spacing.sm) {
                ForEach(regions) { region in
                    LifeAreaRegionButton(
                        region: region,
                        onOpen: { onOpenLifeArea(region) },
                        onCreate: { onCreate(region.isOpenField ? .noteThought : .goalSeed, region) }
                    )
                }
            }
            .accessibilityIdentifier("goals.life-area-atlas.regions")

            if let target = overview.heroPrimaryAction.target {
                Button {
                    onPrimaryAction(GoalsAtlasPrimaryAction(
                        kind: .openGoal,
                        title: "Open step",
                        subtitle: overview.heroPrimaryAction.subtitle,
                        systemImage: "arrow.right",
                        target: target,
                        state: overview.heroPrimaryAction.state
                    ))
                } label: {
                    CurrentStepLift(title: overview.heroPrimaryAction.title, subtitle: overview.heroPrimaryAction.subtitle)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("goals.current-step.open")
            }
        }
        .padding(theme.spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfacePrimary.opacity(0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                        .stroke(theme.colors.surfaceSecondary.opacity(0.34), lineWidth: 1)
                )
        )
        .accessibilityIdentifier("goals.life-area-atlas")
        .accessibilityElement(children: .contain)
        .accessibilityLabel(GoalsAccessibility.rootSummary(regions: regions))
    }

    private var atlasHeader: some View {
        HStack(alignment: .center, spacing: theme.spacing.md) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text("Life Areas")
                    .font(theme.typography.title)
                    .foregroundStyle(theme.colors.textPrimary)
                    .accessibilityIdentifier("goals.life-area-atlas.title")
                Text("Choose the part of life that needs shape.")
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
            .accessibilityLabel("Add in Goals")
            .accessibilityHint("Opens Capture with Goals context.")
            .accessibilityIdentifier("goals.capture-plus")
        }
    }

    private var columns: [GridItem] {
        [
            GridItem(.flexible(minimum: 132), spacing: theme.spacing.sm),
            GridItem(.flexible(minimum: 132), spacing: theme.spacing.sm)
        ]
    }
}

private struct LifeAreaRegionButton: View {
    @Environment(\.ambitionTheme) private var theme

    let region: GoalsLifeAreaAtlasRegion
    let onOpen: () -> Void
    let onCreate: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Button(action: onOpen) {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    regionContent
                }
                .frame(minHeight: 154, alignment: .topLeading)
                .padding(theme.spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                        .fill(region.hasActivity ? theme.colors.surfaceOverlay : theme.colors.canvas.opacity(0.54))
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                                .stroke(region.hasActivity ? theme.colors.accentPrimary.opacity(0.24) : theme.colors.surfaceSecondary.opacity(0.28), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)

            if region.hasActivity == false {
                Button(action: onCreate) {
                    Label(region.isOpenField ? "Add thought" : "Add goal", systemImage: "plus.circle")
                        .font(theme.typography.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(theme.colors.textSecondary)
                .padding(.leading, theme.spacing.md)
                .padding(.bottom, theme.spacing.md)
                .accessibilityIdentifier("goals.life-area.\(region.id).create")
            }
        }
        .accessibilityIdentifier("goals.life-area.\(region.id)")
        .accessibilityLabel(region.accessibilityLabel)
        .accessibilityValue(region.accessibilityValue)
        .accessibilityHint(region.accessibilityHint)
    }

    private var regionContent: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(alignment: .center, spacing: theme.spacing.sm) {
                    ZStack {
                        Circle()
                            .fill(region.hasActivity ? theme.colors.accentPrimary.opacity(0.16) : theme.colors.surfaceOverlay)
                        Image(systemName: region.symbolName)
                            .font(.system(size: theme.icon.smallSize, weight: .semibold))
                            .foregroundStyle(region.hasActivity ? theme.colors.accentPrimary : theme.colors.textSecondary)
                    }
                    .frame(width: 34, height: 34)
                    .accessibilityHidden(true)

                    Spacer(minLength: theme.spacing.xs)

                    Text(region.primaryCountLabel)
                        .font(theme.typography.micro)
                        .foregroundStyle(region.hasActivity ? theme.colors.accentPrimary : theme.colors.textTertiary)
                }

                Text(region.title)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(region.summary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                if region.hasActivity {
                    ActivityMarks(region: region)
                } else {
                    Spacer(minLength: theme.spacing.lg)
                }
            }
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
            Label("\(count)", systemImage: symbol)
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textSecondary)
                .accessibilityLabel("\(count) \(label)")
        }
    }
}

private struct CurrentStepLift: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .center, spacing: theme.spacing.md) {
            Image(systemName: "arrow.forward.circle")
                .font(.system(size: theme.icon.mediumSize, weight: .semibold))
                .foregroundStyle(theme.colors.accentPrimary)
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(subtitle)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: theme.spacing.sm)
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
    }
}

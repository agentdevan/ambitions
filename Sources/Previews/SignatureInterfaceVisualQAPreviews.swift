#if canImport(SwiftUI)
import SwiftUI

struct SignatureInterfaceVisualQAPreviewGallery: View {
    @Environment(\.ambitionTheme) private var theme

    private let columns = [
        GridItem(.adaptive(minimum: 240), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                SectionHeader(
                    eyebrow: "SI16",
                    title: "Preview Fixture And Visual QA",
                    subtitle: "Deterministic preview states for Today, Goals, Time, and You, plus accessibility notes, privacy states, and future LDI visual hooks."
                )

                LazyVGrid(columns: columns, alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(SI16PreviewFixtureCatalog.surfaceCoverageRows) { row in
                        surfaceCoverageTile(row)
                    }
                }

                LazyVGrid(columns: columns, alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(SI16PreviewFixtureCatalog.fixtures) { fixture in
                        fixtureTile(fixture)
                    }
                }

                SectionHeader(
                    eyebrow: "AFI13",
                    title: "Visual QA And Drift Gallery",
                    subtitle: "Scorecard targets and pass/fail drift examples for Today, Goals, Time, and You, with Motion treated as behavior and Capture as global composer. Rendered proof remains Yellow until screenshots and human visual review exist."
                )

                LazyVGrid(columns: columns, alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(AFI13VisualQACatalog.scorecards) { entry in
                        scorecardTile(entry)
                    }
                }

                LazyVGrid(columns: columns, alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(AFI13VisualQACatalog.driftGallery) { example in
                        driftTile(example)
                    }
                }
            }
            .padding(theme.spacing.lg)
        }
        .background(LivingSurfaceBackground(context: .trust, state: .calm).ignoresSafeArea())
        .ambitionTheme(.dark)
    }

    private func fixtureTile(_ fixture: SI16VisualQAFixture) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                AmbitionsStatusSymbol(fixture.statusRole, style: .inline)

                Text(fixture.ownerSurface)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }

            Text(fixture.stateFamily.title)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(fixture.primaryObject)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(fixture.screenshotName)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)

            Text(fixture.nonColorNote)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.64))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(fixture.previewName). \(fixture.accessibilityNote)")
        .accessibilityValue("\(fixture.reduceMotionNote) \(fixture.nonColorNote)")
    }

    private func surfaceCoverageTile(_ row: SI16PreviewSurfaceCoverageRow) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                AmbitionsStatusSymbol(row.fixtures.first?.statusRole ?? .needsReview, style: .inline)

                Text(row.ownerSurface)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }

            Text(row.primaryObject)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(row.accessibilityNote)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                ForEach(row.fixtures) { fixture in
                    fixturePill(fixture)
                }
            }

            Text(row.nonColorNote)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, minHeight: 190, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.72))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(row.accessibilitySummary)
        .accessibilityValue("Preview fixtures: \(row.fixtures.count). Screenshot not captured.")
    }

    private func fixturePill(_ fixture: SI16VisualQAFixture) -> some View {
        HStack(spacing: theme.spacing.xxs) {
            AmbitionsStatusSymbol(fixture.statusRole, style: .inline)
            Text(fixture.stateFamily.title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textPrimary)
        }
        .padding(.horizontal, theme.spacing.sm)
        .padding(.vertical, theme.spacing.xs)
        .background(
            Capsule(style: .continuous)
                .fill(theme.colors.surfacePrimary.opacity(0.72))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(fixture.previewName). \(fixture.nonColorNote)")
    }

    private func scorecardTile(_ entry: AFI13VisualQAScorecardEntry) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                AmbitionsStatusSymbol(.needsReview, style: .inline)

                Text(entry.status)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }

            Text(entry.surface)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(entry.primaryObject)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Target \(entry.targetScore), minimum \(entry.minimumScore)")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.64))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(entry.surface). \(entry.primaryObject). \(entry.status). \(entry.yellowReason)")
        .accessibilityValue("Target \(entry.targetScore), minimum \(entry.minimumScore).")
    }

    private func driftTile(_ example: AFI13VisualDriftGalleryExample) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text(example.category)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(example.passPattern)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(example.failPattern)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.48))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(example.category). Pass: \(example.passPattern). Fail: \(example.failPattern).")
        .accessibilityValue(example.redLabel)
    }
}

#Preview("SI16 Preview Fixture Visual QA") {
    SignatureInterfaceVisualQAPreviewGallery()
}

#Preview("SI16 Preview Fixture Dynamic Type") {
    SignatureInterfaceVisualQAPreviewGallery()
        .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("SI16 Preview Fixture Static Motion") {
    SignatureInterfaceVisualQAPreviewGallery()
        .transaction { transaction in
            transaction.disablesAnimations = true
        }
}
#endif

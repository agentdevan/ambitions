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
                    subtitle: "Deterministic preview states for SI primitives, accessibility notes, privacy states, and future LDI visual hooks."
                )

                LazyVGrid(columns: columns, alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(SI16PreviewFixtureCatalog.fixtures) { fixture in
                        fixtureTile(fixture)
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
        .accessibilityValue(fixture.reduceMotionNote)
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

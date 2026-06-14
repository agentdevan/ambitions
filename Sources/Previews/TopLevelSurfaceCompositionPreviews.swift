#if canImport(SwiftUI)
import SwiftUI

struct TopLevelSurfaceCompositionPreviewGallery: View {
    @Environment(\.ambitionTheme) private var theme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                SectionHeader(
                    eyebrow: "SI17",
                    title: "Top-Level Surface Composition",
                    subtitle: "Five root surfaces keep one primary Ambitions object with distinct supporting modules."
                )

                ForEach(AmbitionsTopLevelSurfaceComposition.allCases) { surface in
                    TopLevelSurfaceCompositionBar(
                        surface: surface,
                        state: surface == .motion ? .selected : .default
                    )
                }
            }
            .padding(theme.spacing.lg)
        }
        .background(theme.colors.canvas)
    }
}

#Preview("SI17 Top-Level Surface Composition") {
    TopLevelSurfaceCompositionPreviewGallery()
        .ambitionTheme(.dark)
}

#Preview("SI17 Top-Level Surface Dynamic Type") {
    TopLevelSurfaceCompositionPreviewGallery()
        .environment(\.dynamicTypeSize, .accessibility3)
        .ambitionTheme(.dark)
}

#Preview("SI17 Top-Level Surface Static Motion") {
    TopLevelSurfaceCompositionPreviewGallery()
        .ambitionTheme(.dark)
}
#endif

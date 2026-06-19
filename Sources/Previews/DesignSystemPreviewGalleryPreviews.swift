#if canImport(SwiftUI)
import SwiftUI

struct DesignSystemPreviewGallery_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DesignSystemPreviewGallery()
                .previewDisplayName("Dark")

            DesignSystemPreviewGallery()
                .ambitionTheme(.light)
                .preferredColorScheme(.light)
                .previewDisplayName("Light Hook")

            DesignSystemPreviewGallery()
                .environment(\.dynamicTypeSize, .accessibility3)
                .previewDisplayName("SI02 High Dynamic Type")
        }
    }
}
#endif

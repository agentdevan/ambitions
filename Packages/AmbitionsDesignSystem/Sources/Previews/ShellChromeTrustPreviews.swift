#if canImport(SwiftUI)
import SwiftUI

#if DEBUG
#Preview("Local Ambitions Lockup") {
    VStack(alignment: .leading, spacing: 16) {
        LocalAmbitionsLockup()
        SourceTrustChrome(sourceLabel: "Local", productLabel: "Ambitions")
    }
    .padding(24)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(AmbitionTheme.dark.shell.canvasGradient)
    .ambitionTheme(.dark)
}
#endif
#endif

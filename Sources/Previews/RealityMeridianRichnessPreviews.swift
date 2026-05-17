#if canImport(SwiftUI)
import SwiftUI

#if DEBUG
#Preview("Reality Meridian Time Band") {
    VStack(alignment: .leading, spacing: 24) {
        RealityMeridianTimeBand(date: Date(timeIntervalSince1970: 45_300))
        RealityMeridianCurrentTimeCursor(date: Date(timeIntervalSince1970: 45_300), presentation: .railOverlay)
    }
    .padding(24)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(AmbitionTheme.dark.shell.canvasGradient)
    .ambitionTheme(.dark)
}
#endif
#endif

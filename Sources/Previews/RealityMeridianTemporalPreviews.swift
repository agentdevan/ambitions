#if canImport(SwiftUI)
import SwiftUI

#if DEBUG
#Preview("Reality Meridian Temporal Primitives") {
    VStack(alignment: .leading, spacing: 18) {
        RealityMeridianCurrentTimeCursor(date: Date(timeIntervalSince1970: 45_300.0))
        RealityMeridianScheduledNode(timeLabel: "10:00 AM", title: "Scheduled step", isActive: false)
        RealityMeridianScheduledNode(timeLabel: "12:15 PM", title: "Current focus window", isActive: true)
    }
    .padding(24)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(AmbitionTheme.dark.shell.canvasGradient)
    .ambitionTheme(.dark)
}
#endif
#endif

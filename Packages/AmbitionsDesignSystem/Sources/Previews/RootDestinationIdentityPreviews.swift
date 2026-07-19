#if canImport(SwiftUI)
import SwiftUI

#if DEBUG
#Preview("Root Destination Identity Rail") {
    VStack(alignment: .leading, spacing: 18) {
        RootDestinationIdentityRail(selected: .today)
        RootDestinationIdentityRail(selected: .time)
        Text(BottomNavigationContract.requiredTitleSequence)
            .font(AmbitionTheme.dark.typography.caption)
            .foregroundStyle(AmbitionTheme.dark.colors.textSecondary)
    }
    .padding(24)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    .background(AmbitionTheme.dark.shell.canvasGradient)
    .ambitionTheme(.dark)
}
#endif
#endif

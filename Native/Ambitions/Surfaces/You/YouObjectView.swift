import SwiftUI

struct YouObjectView: View {
    let profileProjection: YouDashboard
    let onOpenDetail: (YouRootDetail) -> Void

    var body: some View {
        UserSystemProfileRootView(
            profileProjection: profileProjection,
            onOpenDetail: onOpenDetail
        )
        .accessibilityLabel("User profile")
        .accessibilityValue("Local profile and settings.")
    }
}

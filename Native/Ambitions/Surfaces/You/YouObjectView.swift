import SwiftUI

struct YouObjectView: View {
    let profileProjection: YouDashboard
    let onOpenDetail: (YouRootDetail) -> Void

    var body: some View {
        UserSystemProfileRootView(
            profileProjection: profileProjection,
            onOpenDetail: onOpenDetail
        )
        .accessibilityLabel("User System Profile")
        .accessibilityValue("User System Profile with privacy, receipts, account, and settings status.")
    }
}

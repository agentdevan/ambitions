import SwiftUI

struct YouObjectView: View {
    let profileProjection: YouDashboard
    let onOpenDetail: (YouRootDetail) -> Void

    var body: some View {
        UserSystemProfileRootView(
            profileProjection: profileProjection,
            onOpenDetail: onOpenDetail
        )
        .accessibilityLabel("You settings")
        .accessibilityValue("Local settings with privacy, receipts, account, and app preferences.")
    }
}

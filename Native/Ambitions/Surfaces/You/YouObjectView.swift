import SwiftUI

struct YouObjectView: View {
    let profileProjection: YouDashboard
    let onOpenDetail: (YouRootDetail) -> Void

    var body: some View {
        PersonalSystemCenterRootView(
            profileProjection: profileProjection,
            onOpenDetail: onOpenDetail
        )
        .accessibilityLabel(YouAccessibility.rootSummary(
            profileState: profileProjection.constitution.title,
            privacyState: profileProjection.trustCenter.title,
            accountState: profileProjection.accountSection.title,
            receiptState: profileProjection.trustHistoryCenter.title
        ))
    }
}

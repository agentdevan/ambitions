import AmbitionsDesignSystem
import SwiftUI

struct AppShellScaffold<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let title: String
    let subtitle: String?
    let posture: AppShellHeaderPosture
    let backButtonAccessibilityIdentifier: String?
    let onBack: (() -> Void)?
    let trailingButtons: [AppShellHeaderButton]
    let reservesPrimaryObjectTopClearance: Bool
    let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        posture: AppShellHeaderPosture,
        backButtonAccessibilityIdentifier: String? = nil,
        onBack: (() -> Void)? = nil,
        trailingButtons: [AppShellHeaderButton] = [],
        reservesPrimaryObjectTopClearance: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.posture = posture
        self.backButtonAccessibilityIdentifier = backButtonAccessibilityIdentifier
        self.onBack = onBack
        self.trailingButtons = trailingButtons
        self.reservesPrimaryObjectTopClearance = reservesPrimaryObjectTopClearance
        self.content = content()
    }

    var body: some View {
        scaffoldedContent
            .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private var scaffoldedContent: some View {
        content
            .padding(.top, topContentClearance)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear
                    .frame(height: bottomChromeClearance)
                    .accessibilityHidden(true)
            }
            .safeAreaInset(edge: .top, spacing: topInsetSpacing) {
                headerRail
                    .hidden()
                    .accessibilityHidden(true)
            }
            .overlay(alignment: .top) {
                headerRail
                    .safeAreaPadding(.top)
                    .zIndex(1)
            }
    }

    private var headerRail: some View {
                AppShellHeaderRail(
                    title: title,
                    subtitle: subtitle,
                    posture: posture,
                    backButtonAccessibilityIdentifier: backButtonAccessibilityIdentifier,
                    onBack: onBack,
                    trailingButtons: trailingButtons
                )
                .accessibilityIdentifier("shell.flagship.chrome.header")
    }

    private var bottomChromeClearance: CGFloat {
        if onBack != nil {
            return StageSafeAreaPolicy.drilldownBottomClearance(
                dynamicTypeIsAccessibilitySize: dynamicTypeSize.isAccessibilitySize
            )
        }
        return 0
    }

    private var topInsetSpacing: CGFloat {
        StageSafeAreaPolicy.topInsetSpacing(
            hasBackButton: onBack != nil,
            dynamicTypeIsAccessibilitySize: dynamicTypeSize.isAccessibilitySize
        )
    }

    private var topContentClearance: CGFloat {
        StageSafeAreaPolicy.topContentClearance(
            reservesPrimaryObjectTopClearance: reservesPrimaryObjectTopClearance,
            dynamicTypeIsAccessibilitySize: dynamicTypeSize.isAccessibilitySize
        )
    }
}

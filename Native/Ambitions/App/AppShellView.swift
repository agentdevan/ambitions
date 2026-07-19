import AmbitionsDesignSystem
import SwiftUI

private struct AppShellAdditionalRootBottomClearanceKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    var appShellAdditionalRootBottomClearance: CGFloat {
        get { self[AppShellAdditionalRootBottomClearanceKey.self] }
        set { self[AppShellAdditionalRootBottomClearanceKey.self] = newValue }
    }
}

struct AppShellScaffold<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.appShellAdditionalRootBottomClearance) private var additionalRootBottomClearance

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
        GeometryReader { proxy in
            content
                .padding(.top, topContentClearance)
                .frame(
                    width: proxy.size.width,
                    height: max(0, proxy.size.height - hardBottomViewportClearance),
                    alignment: .top
                )
                .clipped()
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Color.clear
                .frame(height: softBottomChromeClearance)
                .allowsHitTesting(false)
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
            .overlay {
                backSwipeLayer
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
        return StageSafeAreaPolicy.stageContentBottomClearance(
            routeDepth: .root,
            overlayPresentation: .none,
            dynamicTypeIsAccessibilitySize: dynamicTypeSize.isAccessibilitySize
        ) + additionalRootBottomClearance
    }

    private var hardBottomViewportClearance: CGFloat {
        onBack == nil ? bottomChromeClearance : 0
    }

    private var softBottomChromeClearance: CGFloat {
        onBack == nil ? 0 : bottomChromeClearance
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

    @ViewBuilder
    private var backSwipeLayer: some View {
        if onBack != nil {
            GeometryReader { proxy in
                HStack(spacing: 0) {
                    if layoutDirection == .rightToLeft {
                        Spacer(minLength: 0)
                    }
                    Color.clear
                        .frame(width: SurfaceGestureMap.edgeBackSwipeStartWidth(screenWidth: proxy.size.width))
                        .frame(maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .gesture(backSwipeGesture(screenWidth: proxy.size.width))
                        .accessibilityHidden(true)
                    if layoutDirection == .leftToRight {
                        Spacer(minLength: 0)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .accessibilityHidden(true)
        }
    }

    private func backSwipeGesture(screenWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 12, coordinateSpace: .local)
            .onEnded { value in
                let startDistance = layoutDirection == .rightToLeft
                    ? screenWidth - value.startLocation.x
                    : value.startLocation.x
                let horizontalTranslation = layoutDirection == .rightToLeft
                    ? -value.translation.width
                    : value.translation.width
                guard SurfaceGestureMap.isEdgeBackSwipe(
                    startDistanceFromLeadingEdge: startDistance,
                    horizontalTranslation: horizontalTranslation,
                    verticalTranslation: value.translation.height,
                    screenWidth: screenWidth
                ) else {
                    return
                }
                onBack?()
            }
    }
}

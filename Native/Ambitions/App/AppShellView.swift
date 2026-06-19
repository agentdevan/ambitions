import AmbitionsDesignSystem
import SwiftUI

enum AppShellHeaderPosture: String, Sendable {
    case execution
    case direction
    case shaping
    case reflection
    case utility

    var title: String {
        switch self {
        case .execution: "Execution"
        case .direction: "Direction"
        case .shaping: "Shaping"
        case .reflection: "Reflection"
        case .utility: "Utility"
        }
    }

    var modeLens: AmbitionModeLens {
        switch self {
        case .execution: .focus
        case .direction: .focus
        case .shaping: .time
        case .reflection: .review
        case .utility: .focus
        }
    }

    var headerLensTitle: String {
        switch self {
        case .shaping:
            "Capacity"
        default:
            modeLens.title
        }
    }

    var ambientStatus: AmbitionAmbientStatus {
        switch self {
        case .execution: .protected
        case .direction: .steady
        case .shaping: .tight
        case .reflection: .clear
        case .utility: .steady
        }
    }

    var systemImage: String {
        switch self {
        case .execution: "bolt.fill"
        case .direction: "target"
        case .shaping: "calendar.badge.clock"
        case .reflection: "chart.line.uptrend.xyaxis"
        case .utility: "slider.horizontal.3"
        }
    }

    var continuityMessage: String {
        switch self {
        case .execution:
            "Today keeps one important step in view."
        case .direction:
            "Goals keeps direction connected to the next step."
        case .shaping:
            "Time shapes the week only with confirmation."
        case .reflection:
            "Reviews carry proof forward without changing plans silently."
        case .utility:
            "You keeps controls, memory, and privacy visible."
        }
    }
}

struct AppShellHeaderButton {
    let kind: AppShellContextualToolbarAction.Kind?
    let title: String
    let systemImage: String
    let accessibilityIdentifier: String
    let accessibilityLabel: String
    let accessibilityHint: String?
    let keyboardShortcut: AppShellHeaderKeyboardShortcut?
    let action: () -> Void

    init(
        kind: AppShellContextualToolbarAction.Kind? = nil,
        title: String,
        systemImage: String,
        accessibilityIdentifier: String,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        keyboardShortcut: AppShellHeaderKeyboardShortcut? = nil,
        action: @escaping () -> Void
    ) {
        self.kind = kind
        self.title = title
        self.systemImage = systemImage
        self.accessibilityIdentifier = accessibilityIdentifier
        self.accessibilityLabel = accessibilityLabel ?? title
        self.accessibilityHint = accessibilityHint
        self.keyboardShortcut = keyboardShortcut
        self.action = action
    }
}

struct AppShellHeaderKeyboardShortcut {
    let key: KeyEquivalent
    let modifiers: EventModifiers
}

enum AppShellGeometry {
    static func topInsetSpacing(hasBackButton: Bool, dynamicTypeIsAccessibilitySize: Bool) -> CGFloat {
        0
    }

    static func topContentClearance(
        reservesPrimaryObjectTopClearance: Bool,
        dynamicTypeIsAccessibilitySize: Bool
    ) -> CGFloat {
        guard reservesPrimaryObjectTopClearance else { return 0 }
        return dynamicTypeIsAccessibilitySize ? 132 : 92
    }
}

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
            return dynamicTypeSize.isAccessibilitySize ? 64 : 34
        }
        return 0
    }

    private var topInsetSpacing: CGFloat {
        AppShellGeometry.topInsetSpacing(
            hasBackButton: onBack != nil,
            dynamicTypeIsAccessibilitySize: dynamicTypeSize.isAccessibilitySize
        )
    }

    private var topContentClearance: CGFloat {
        AppShellGeometry.topContentClearance(
            reservesPrimaryObjectTopClearance: reservesPrimaryObjectTopClearance,
            dynamicTypeIsAccessibilitySize: dynamicTypeSize.isAccessibilitySize
        )
    }
}

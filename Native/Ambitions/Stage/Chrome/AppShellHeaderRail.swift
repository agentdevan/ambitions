import AmbitionsDesignSystem
import SwiftUI

struct AppShellHeaderRail: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let title: String
    let subtitle: String?
    let posture: AppShellHeaderPosture
    let backButtonAccessibilityIdentifier: String?
    let onBack: (() -> Void)?
    let trailingButtons: [AppShellHeaderButton]

    var body: some View {
        VStack(spacing: 0) {
            headerRow
            divider
        }
        .frame(maxWidth: .infinity)
        .background(headerMaterial)
        .shadow(color: headerShadowColor, radius: headerShadowRadius, x: 0, y: 6)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilitySummary)
        .accessibilityIdentifier("shell.header.rail")
    }

    private var headerRow: some View {
        HStack(alignment: .center, spacing: theme.spacing.sm) {
            leadingControl

            if shouldShowTitleBlock {
                titleBlock
            } else {
                Spacer(minLength: 0)
            }

            Spacer(minLength: theme.spacing.sm)
            trailingControls
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.top, headerTopClearance)
        .padding(.bottom, headerBottomClearance)
        .frame(maxWidth: .infinity)
        .background(headerMaterial)
    }

    @ViewBuilder
    private var leadingControl: some View {
        if let onBack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: theme.icon.smallSize, weight: .semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .frame(width: theme.panel.minimumTapTarget, height: theme.panel.minimumTapTarget)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(backButtonAccessibilityIdentifier ?? "shell.header.back-button")
            .accessibilityLabel("Back")
        } else {
            rootContextCrown
        }
    }

    private var rootContextCrown: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
            Circle()
                .fill(rootCrownAccent)
                .frame(width: 5, height: 5)
                .accessibilityHidden(true)

            Text(title.uppercased())
                .font(theme.typography.micro.weight(.bold))
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Text(rootCrownContext)
                .font(theme.typography.micro.weight(.semibold))
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(shouldWrapHeaderContext ? 2 : 1)
                .minimumScaleFactor(0.74)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: shouldWrapHeaderContext)
        }
        .layoutPriority(2)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("shell.header.context-crown")
    }

    private var titleBlock: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
            Text(title)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .accessibilityIdentifier("shell.header.title")

            Text(headerSubtitle)
                .font(theme.typography.micro.weight(.semibold))
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(shouldWrapHeaderContext ? 2 : 1)
                .minimumScaleFactor(0.78)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: shouldWrapHeaderContext)
                .accessibilityIdentifier("shell.header.subtitle")
        }
        .layoutPriority(2)
    }

    private var trailingControls: some View {
        Group {
            if AppShellContextualToolbarCatalog.shouldCompressActions(
                dynamicTypeIsAccessibilitySize: dynamicTypeSize.isAccessibilitySize,
                actionCount: trailingButtons.count
            ) {
                Menu {
                    ForEach(Array(trailingButtons.enumerated()), id: \.offset) { entry in
                        menuButton(entry.element)
                    }
                } label: {
                    Label("Actions", systemImage: "ellipsis")
                        .labelStyle(.iconOnly)
                        .frame(width: theme.panel.minimumTapTarget, height: theme.panel.minimumTapTarget)
                }
                .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                .accessibilityIdentifier("shell.header.action-cluster-menu")
                .accessibilityLabel("Actions")
                .accessibilityHint("Shows contextual actions for this surface, including Capture.")
            } else {
                HStack(spacing: theme.spacing.xs) {
                    ForEach(Array(trailingButtons.enumerated()), id: \.offset) { entry in
                        headerButton(entry.element)
                    }
                }
            }
        }
        .layoutPriority(1)
    }

    private func menuButton(_ button: AppShellHeaderButton) -> some View {
        Button {
            AppShellSensoryFeedbackPolicy.emit(.headerAction, reduceMotionEnabled: reduceMotion)
            button.action()
        } label: {
            Label(button.title, systemImage: button.systemImage)
        }
        .accessibilityIdentifier(button.accessibilityIdentifier)
        .accessibilityLabel(button.accessibilityLabel)
        .accessibilityHint(button.accessibilityHint ?? "")
    }

    @ViewBuilder
    private func headerButton(_ button: AppShellHeaderButton) -> some View {
        let base = Button {
            AppShellSensoryFeedbackPolicy.emit(.headerAction, reduceMotionEnabled: reduceMotion)
            button.action()
        } label: {
            Label(button.title, systemImage: button.systemImage)
                .labelStyle(.iconOnly)
                .frame(width: theme.panel.minimumTapTarget, height: theme.panel.minimumTapTarget)
        }
        .buttonStyle(AmbitionPressableButtonStyle(state: .default))
        .accessibilityIdentifier(button.accessibilityIdentifier)
        .accessibilityLabel(button.accessibilityLabel)
        .accessibilityHint(button.accessibilityHint ?? "")

        if let shortcut = button.keyboardShortcut {
            base.keyboardShortcut(shortcut.key, modifiers: shortcut.modifiers)
        } else {
            base
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: 0)
    }

    private var shouldShowTitleBlock: Bool {
        onBack != nil
    }

    private var headerSubtitle: String {
        guard let subtitle else { return posture.title }
        return "\(subtitle) · \(posture.headerLensTitle)"
    }

    private var rootCrownContext: String {
        if dynamicTypeSize.isAccessibilitySize {
            return posture.headerLensTitle
        }
        return "· \(subtitle ?? posture.title)"
    }

    private var shouldWrapHeaderContext: Bool {
        dynamicTypeSize >= .xxLarge
    }

    private var rootCrownAccent: Color {
        switch posture.ambientStatus {
        case .clear: theme.shell.statusClear
        case .steady: theme.shell.statusSteady
        case .tight: theme.shell.statusTight
        case .fragile: theme.shell.statusFragile
        case .atRisk: theme.shell.statusAtRisk
        case .recovered: theme.shell.statusRecovered
        case .protected: theme.shell.statusProtected
        }
    }

    private var headerMaterial: AnyShapeStyle {
        if onBack == nil {
            return AnyShapeStyle(theme.colors.canvas.opacity(theme.mode == .dark ? 0.28 : 0.22))
        }
        return AnyShapeStyle(theme.colors.canvas.opacity(theme.mode == .dark ? 0.46 : 0.34))
    }

    private var headerShadowColor: Color {
        .clear
    }

    private var headerShadowRadius: CGFloat {
        0
    }

    private var headerTopClearance: CGFloat {
        if onBack == nil {
            return dynamicTypeSize.isAccessibilitySize ? 10 : 6
        }
        return dynamicTypeSize.isAccessibilitySize ? theme.spacing.xl : theme.spacing.lg
    }

    private var headerBottomClearance: CGFloat {
        if onBack == nil {
            return dynamicTypeSize.isAccessibilitySize ? 6 : 4
        }
        return theme.spacing.xs
    }

    private var accessibilitySummary: String {
        [
            "Shell context crown",
            title,
            headerSubtitle,
            posture.continuityMessage
        ].joined(separator: ". ")
    }
}

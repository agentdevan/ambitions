import AmbitionsDesignSystem
import SwiftUI
import XCTest

@MainActor
final class GroupedNavigationListDesignSystemTests: XCTestCase {
    func testD03RowKindsCoverCanonicalGroupedNavigationVariants() {
        XCTAssertEqual(Set(GroupedNavigationRowKind.allCases), [
            .navigation,
            .disclosure,
            .preference,
            .status,
            .destructive
        ])

        for kind in GroupedNavigationRowKind.allCases {
            XCTAssertFalse(kind.accessibilityRole.isEmpty)
        }
    }

    func testD03GroupedRowsCompileWithHumanCopyAndAccessibilityInputs() {
        _ = GroupedNavigationList {
            GroupedNavigationSection(
                title: "Privacy",
                footer: "Destructive actions require confirmation."
            ) {
                GroupedNavigationRow(
                    title: "Privacy",
                    subtitle: "Review what is visible.",
                    systemImage: "lock",
                    trailingValue: "On",
                    accessibilityValue: "On",
                    accessibilityHint: "Opens privacy settings.",
                    action: {}
                )

                GroupedDisclosureNavigationRow(
                    title: "What Ambitions knows",
                    subtitle: "Review saved context.",
                    systemImage: "checkmark.shield",
                    badge: .init("Local", state: .trust),
                    accessibilityValue: "Local",
                    accessibilityHint: "Opens saved context.",
                    action: {}
                )

                GroupedPreferenceRow(
                    title: "Private item",
                    subtitle: "Hide details in shared views.",
                    systemImage: "eye.slash",
                    isOn: .constant(true),
                    accessibilityHint: "Turns private display on or off."
                )

                GroupedStatusNavigationRow(
                    title: "Looks doable",
                    subtitle: "Current planning state.",
                    systemImage: "checkmark.circle",
                    value: "On track",
                    state: .success,
                    accessibilityValue: "On track",
                    accessibilityHint: "Opens planning details.",
                    action: {}
                )

                GroupedDestructiveActionRow(
                    title: "Delete review history",
                    subtitle: "Opens a confirmation step.",
                    systemImage: "trash",
                    accessibilityHint: "Opens delete confirmation.",
                    action: {}
                )
            }
        }
    }

    func testD03ThemeTokensProvideAccessibleGroupedRowTargets() {
        for mode in AmbitionThemeMode.allCases {
            let theme = AmbitionTheme.theme(for: mode)

            XCTAssertGreaterThanOrEqual(theme.panel.minimumTapTarget, 44)
            XCTAssertGreaterThanOrEqual(theme.spacing.compact, 12)
            XCTAssertGreaterThanOrEqual(theme.radius.md, 12)
            XCTAssertFalse(AmbitionSemanticState.trust.accessibilityText.isEmpty)
            XCTAssertFalse(AmbitionSemanticState.accessibilityUnverified.accessibilityText.isEmpty)
        }
    }

    func testRootSettingsRowsCompileWithLongLabelsThatPreviouslyWrappedBadly() {
        let stressLabels = [
            "Integrations",
            "Personalization",
            "Accessibility",
            "Widgets / Live Activities / Shortcuts",
            "What Ambitions Knows"
        ]

        _ = GroupedNavigationList {
            GroupedNavigationSection(title: "Stress") {
                ForEach(stressLabels, id: \.self) { label in
                    GroupedDisclosureNavigationRow(
                        title: label,
                        subtitle: "Concise one-line subtitle.",
                        systemImage: "gearshape",
                        badge: .init("Local", state: .neutral),
                        accessibilityValue: "Local",
                        action: {}
                    )
                }
            }
        }

        XCTAssertFalse(stressLabels.contains { $0.contains("-") })
        XCTAssertFalse(stressLabels.contains { $0.contains("\n") })
    }

    func testSI03SurfaceShellAndOverlayZoneCompileWithGroupedNavigationHub() {
        let primaryAction = AmbitionsSurfaceHeaderAction(
            title: "Open command",
            systemImage: "command",
            accessibilityIdentifier: "test.si03.command",
            action: {}
        )

        _ = AmbitionsSurfaceShell(
            kind: .utilityHub,
            title: "You",
            subtitle: "Personal system center.",
            statusMessage: "Routes remain owned by Today, Goals, Time, Motion, and You with global Capture.",
            primaryAction: primaryAction
        ) {
            GroupedNavigationList {
                GroupedNavigationSection(title: "Trust") {
                    GroupedDisclosureNavigationRow(
                        title: "What Ambitions knows",
                        subtitle: "Review saved context.",
                        systemImage: "checkmark.shield",
                        badge: .init("Private", state: .protected),
                        accessibilityHint: "Opens saved context.",
                        action: {}
                    )
                }
            }

            ShellOverlayZone(
                title: "Return path",
                subtitle: "Temporary overlay.",
                isPresented: true,
                onDismiss: {}
            ) {
                Text("Owned overlay content")
            }
        }
    }
}

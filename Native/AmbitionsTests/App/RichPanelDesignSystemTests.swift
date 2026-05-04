import AmbitionsDesignSystem
import XCTest

final class RichPanelDesignSystemTests: XCTestCase {
    func testBatch63PanelKindsCoverCanonicalPanelTypes() {
        XCTAssertEqual(Set(AmbitionPanelKind.allCases), [
            .heroDecision,
            .progress,
            .timeline,
            .schedule,
            .insight,
            .recovery,
            .trust,
            .capture,
            .review,
            .settingsPreference
        ])
    }

    func testBatch63SemanticStatesCoverRequiredNonColorLabels() {
        let requiredStates: Set<AmbitionSemanticState> = [
            .confidenceHigh,
            .confidenceMedium,
            .confidenceLow,
            .recovery,
            .waiting,
            .protected,
            .focus,
            .capture,
            .trust,
            .review,
            .calendarDerived,
            .accessibilityVerified,
            .accessibilityUnverified
        ]

        XCTAssertTrue(Set(AmbitionSemanticState.allCases).isSuperset(of: requiredStates))
        for state in requiredStates {
            XCTAssertFalse(state.label.isEmpty)
            XCTAssertFalse(state.icon.isEmpty)
            XCTAssertFalse(state.accessibilityText.isEmpty)
        }
    }

    func testWarmLightAndDarkThemeExposePanelTokenScale() {
        for mode in AmbitionThemeMode.allCases {
            let theme = AmbitionTheme.theme(for: mode)

            XCTAssertGreaterThanOrEqual(theme.spacing.micro, 4)
            XCTAssertEqual(theme.spacing.tight, 8)
            XCTAssertEqual(theme.spacing.compact, 12)
            XCTAssertEqual(theme.spacing.standard, 16)
            XCTAssertEqual(theme.spacing.heroInner, 20)
            XCTAssertEqual(theme.spacing.sectionBreak, 24)
            XCTAssertEqual(theme.spacing.majorBreak, 32)

            XCTAssertGreaterThanOrEqual(theme.panel.minimumTapTarget, 44)
            XCTAssertGreaterThan(theme.panel.heroRadius, theme.panel.compactRadius)
            XCTAssertGreaterThan(theme.panel.visualSlotMinimumHeight, 0)
            XCTAssertGreaterThan(theme.borders.selectedWidth, 0)
            XCTAssertGreaterThan(theme.borders.semanticOpacity, 0)
        }
    }

    func testPanelConfigurationDefaultsProvideAccessibleStateAndIcon() {
        for kind in AmbitionPanelKind.allCases {
            let configuration = AmbitionRichPanelConfiguration(kind: kind, title: "Demo")

            XCTAssertEqual(configuration.kind, kind)
            XCTAssertFalse(configuration.semanticState.label.isEmpty)
            XCTAssertFalse(configuration.semanticState.icon.isEmpty)
            XCTAssertFalse(kind.defaultEyebrow.isEmpty)
            XCTAssertFalse(kind.defaultIcon.isEmpty)
        }
    }

    func testAccentFamiliesRemainAvailableAcrossAppearanceModes() {
        for mode in AmbitionThemeMode.allCases {
            for family in AmbitionAccentFamily.allCases {
                let theme = AmbitionTheme.theme(for: mode, accentFamily: family)
                XCTAssertEqual(theme.accentFamily, family)
                XCTAssertEqual(theme.mode, mode)
            }
        }
    }

    func testSI02PanelEmphasisCoversModuleAndStateOwners() {
        let required: Set<PanelEmphasis> = [
            .orientation,
            .action,
            .receipt,
            .proof,
            .source,
            .recovery,
            .setup,
            .pressure,
            .quiet
        ]

        XCTAssertEqual(Set(PanelEmphasis.allCases), required)
        for emphasis in PanelEmphasis.allCases {
            XCTAssertFalse(emphasis.title.isEmpty)
            XCTAssertFalse(emphasis.icon.isEmpty)
            XCTAssertFalse(emphasis.accessibilityText.isEmpty)
            XCTAssertFalse(emphasis.semanticState.accessibilityText.isEmpty)
        }
    }

    func testSI02AdaptivePanelConfigurationCarriesAccessibleState() {
        let loading = AdaptivePanelConfiguration(
            emphasis: .action,
            title: "Finding the safest action",
            status: "Working",
            isLoading: true
        )
        let disabled = AdaptivePanelConfiguration(
            emphasis: .recovery,
            title: "Recovery paused",
            status: "Unavailable",
            isDisabled: true
        )
        let privatePanel = AdaptivePanelConfiguration(
            emphasis: .source,
            title: "Private source",
            isPrivacySensitive: true
        )

        XCTAssertEqual(loading.state, .loading)
        XCTAssertEqual(disabled.state, .disabled)
        XCTAssertEqual(privatePanel.state, .selected)
        XCTAssertTrue(privatePanel.defaultAccessibilityLabel.contains("private"))
        XCTAssertTrue(loading.defaultAccessibilityLabel.contains("loading"))
        XCTAssertTrue(disabled.defaultAccessibilityLabel.contains("disabled"))
    }

    func testSI02ActionRolesMapToExistingButtonTiers() {
        XCTAssertEqual(AmbitionsActionRole.primary.tier, .primary)
        XCTAssertEqual(AmbitionsActionRole.secondary.tier, .secondary)
        XCTAssertEqual(AmbitionsActionRole.quiet.tier, .tertiary)
        XCTAssertEqual(AmbitionsActionRole.recovery.tier, .recovery)
        XCTAssertEqual(AmbitionsActionRole.destructive.tier, .destructive)

        for role in AmbitionsActionRole.allCases {
            XCTAssertFalse(role.defaultIcon.isEmpty)
        }
    }
}

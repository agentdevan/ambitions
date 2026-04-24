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
}

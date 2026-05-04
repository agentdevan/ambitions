import AmbitionsDesignSystem
import SwiftUI
import XCTest

final class PanelDensitySizeDesignSystemTests: XCTestCase {
    func testD04DefaultConfigurationIsBalancedComfortable() {
        let configuration = AmbitionPanelDisplayConfiguration.default

        XCTAssertEqual(configuration.density, .balanced)
        XCTAssertEqual(configuration.size, .comfortable)
        XCTAssertEqual(configuration.effectiveDensity, .balanced)
    }

    func testD04MatrixCoversEveryDensityAndSizeCombination() {
        let combinations = AmbitionDisplayDensity.allCases.flatMap { density in
            AmbitionPanelSize.allCases.map { size in
                AmbitionPanelDisplayConfiguration(density: density, size: size)
            }
        }

        XCTAssertEqual(combinations.count, 9)
        XCTAssertEqual(Set(combinations), Set([
            .init(density: .minimal, size: .compact),
            .init(density: .minimal, size: .comfortable),
            .init(density: .minimal, size: .large),
            .init(density: .balanced, size: .compact),
            .init(density: .balanced, size: .comfortable),
            .init(density: .balanced, size: .large),
            .init(density: .detailed, size: .compact),
            .init(density: .detailed, size: .comfortable),
            .init(density: .detailed, size: .large)
        ]))
    }

    func testD04CriticalPanelsCannotFullyHideInAnyCombination() {
        let theme = AmbitionTheme.theme(for: .dark)
        let criticalPanels = AmbitionPanelImportance.allCases.filter(\.isCritical)

        for density in AmbitionDisplayDensity.allCases {
            for size in AmbitionPanelSize.allCases {
                let configuration = AmbitionPanelDisplayConfiguration(density: density, size: size)
                for panel in criticalPanels {
                    let decision = theme.panelDisplayDecision(
                        for: panel,
                        configuration: configuration
                    )

                    XCTAssertNotEqual(decision.visibility, .hidden, "\(panel) hid in \(density) \(size)")
                    XCTAssertTrue(decision.preservesCriticalState)
                    XCTAssertTrue(decision.preservesPrimaryAction)
                    XCTAssertTrue(decision.voiceOverSummaryRequired)
                    XCTAssertFalse(decision.colorOnlyMeaningAllowed)
                    XCTAssertFalse(decision.motionRequiredForStateClarity)
                }
            }
        }
    }

    func testD04OptionalPanelsCanHideOrCollapseWithoutAffectingCriticalState() {
        let theme = AmbitionTheme.theme(for: .dark)

        let minimalCompact = theme.panelDisplayDecision(
            for: .optional,
            configuration: .init(density: .minimal, size: .compact)
        )
        XCTAssertEqual(minimalCompact.visibility, .hidden)
        XCTAssertFalse(minimalCompact.preservesCriticalState)

        let balancedCompact = theme.panelDisplayDecision(
            for: .optional,
            configuration: .init(density: .balanced, size: .compact)
        )
        XCTAssertEqual(balancedCompact.visibility, .hidden)

        let detailedComfortable = theme.panelDisplayDecision(
            for: .optional,
            configuration: .init(density: .detailed, size: .comfortable)
        )
        XCTAssertEqual(detailedComfortable.visibility, .full)
        XCTAssertTrue(detailedComfortable.showsSupportingDetail)
    }

    func testD04CompactPreservesTapTargetsAndDoesNotCramDetailedDensity() {
        let theme = AmbitionTheme.theme(for: .light)
        let requestedDetailedCompact = AmbitionPanelDisplayConfiguration(
            density: .detailed,
            size: .compact
        )
        let decision = theme.panelDisplayDecision(
            for: .supporting,
            configuration: requestedDetailedCompact
        )

        XCTAssertEqual(requestedDetailedCompact.effectiveDensity, .balanced)
        XCTAssertGreaterThanOrEqual(decision.metrics.minimumTapTarget, 44)
        XCTAssertFalse(decision.allowsDetailedInformation)
        XCTAssertFalse(decision.showsSupportingDetail)
    }

    func testD04LargePanelsShowFewerNeighborsWithoutStretchingControls() {
        let theme = AmbitionTheme.theme(for: .dark)
        let large = AmbitionPanelDisplayConfiguration(density: .balanced, size: .large)
        let comfortable = AmbitionPanelDisplayConfiguration.default

        XCTAssertLessThan(large.maximumNeighboringPanels, comfortable.maximumNeighboringPanels)

        let largeMetrics = theme.panelDisplayMetrics(for: large)
        let comfortableMetrics = theme.panelDisplayMetrics(for: comfortable)

        XCTAssertGreaterThan(largeMetrics.panelPadding, comfortableMetrics.panelPadding)
        XCTAssertLessThanOrEqual(largeMetrics.controlScale, 1.05)
    }

    func testD04DynamicTypeForcesSaferDensityWhenNeeded() {
        let detailedLarge = AmbitionPanelDisplayConfiguration(
            density: .detailed,
            size: .large
        )
        let detailedComfortable = AmbitionPanelDisplayConfiguration(
            density: .detailed,
            size: .comfortable
        )

        XCTAssertEqual(
            detailedComfortable.resolved(for: .extraExtraLarge).density,
            .balanced
        )
        XCTAssertEqual(
            detailedLarge.resolved(for: .accessibilityExtraLarge).density,
            .minimal
        )
    }

    func testD04HeroPanelsStayAnchoredAndFull() {
        let theme = AmbitionTheme.theme(for: .dark)

        for density in AmbitionDisplayDensity.allCases {
            for size in AmbitionPanelSize.allCases {
                let decision = theme.panelDisplayDecision(
                    for: .heroDecision,
                    configuration: .init(density: density, size: size)
                )

                XCTAssertEqual(decision.visibility, .full)
            }
        }
    }

    func testEB26CognitiveLoadModesMapToSafeDisplayProfiles() {
        let theme = AmbitionTheme.theme(for: .dark)

        for mode in AmbitionCognitiveLoadMode.allCases {
            let profile = AmbitionCognitiveLoadDisplayProfile(mode: mode)
            let heroDecision = theme.panelDisplayDecision(
                for: .heroDecision,
                configuration: profile.configuration
            )
            let trustDecision = theme.panelDisplayDecision(
                for: .trustActionNeeded,
                configuration: profile.configuration
            )

            XCTAssertEqual(profile.mode, mode)
            XCTAssertFalse(profile.explanationLabel.isEmpty)
            XCTAssertTrue(profile.voiceOverSummaryRequired)
            XCTAssertFalse(profile.colorOnlyMeaningAllowed)
            XCTAssertEqual(heroDecision.visibility, .full)
            XCTAssertNotEqual(trustDecision.visibility, .hidden)
        }
    }

    func testEB26LargeDynamicTypeForcesLowInterfaceDensity() {
        let profile = AmbitionCognitiveLoadDisplayProfile(
            mode: .balanced,
            densityLevel: .high,
            panelSize: .comfortable,
            contentSizeCategory: .accessibilityExtraLarge
        )

        XCTAssertEqual(profile.densityLevel, .low)
        XCTAssertEqual(profile.configuration.effectiveDensity, .minimal)
        XCTAssertTrue(profile.keepsOptionalPanelsCollapsed)
    }

    func testEB26ReduceMotionDisablesAmbientMotionWithoutChangingMeaning() {
        let normal = AmbitionCognitiveLoadDisplayProfile(
            mode: .balanced,
            reduceMotion: false
        )
        let reduced = AmbitionCognitiveLoadDisplayProfile(
            mode: .balanced,
            reduceMotion: true
        )

        XCTAssertTrue(normal.allowsAmbientMotion)
        XCTAssertFalse(reduced.allowsAmbientMotion)
        XCTAssertEqual(normal.explanationLabel, reduced.explanationLabel)
        XCTAssertTrue(reduced.voiceOverSummaryRequired)
    }

    func testEB26RecoveryModeUsesLargeLowDensityNonColorMeaning() {
        let profile = AmbitionCognitiveLoadDisplayProfile(mode: .recovery)

        XCTAssertEqual(profile.densityLevel, .low)
        XCTAssertEqual(profile.panelSize, .large)
        XCTAssertTrue(profile.keepsOptionalPanelsCollapsed)
        XCTAssertFalse(profile.colorOnlyMeaningAllowed)
        XCTAssertTrue(profile.explanationLabel.localizedCaseInsensitiveContains("non-shaming"))
    }
}

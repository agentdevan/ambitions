import XCTest
@testable import Ambitions
@testable import AmbitionsDesignSystem

final class IconographyStatusDesignSystemTests: XCTestCase {
    func testSI14StatusGrammarCoversRequiredFamilies() {
        XCTAssertEqual(Set(AmbitionsStatusSymbolFamily.allCases), [
            .proof,
            .source,
            .privacy,
            .pressure,
            .recovery,
            .system
        ])

        for family in AmbitionsStatusSymbolFamily.allCases {
            XCTAssertFalse(
                AmbitionsStatusSymbolRole.allCases.filter { $0.family == family }.isEmpty,
                "Missing status roles for \(family.rawValue)"
            )
        }
    }

    func testSI14StatusRolesAlwaysPairSymbolWithVisibleLabelAndNonColorCue() {
        for role in AmbitionsStatusSymbolRole.allCases {
            XCTAssertFalse(role.title.isEmpty)
            XCTAssertFalse(role.detail.isEmpty)
            XCTAssertFalse(role.symbolName.isEmpty)
            XCTAssertFalse(role.shapeCue.isEmpty)
            XCTAssertTrue(role.nonColorCue.contains(role.symbolName))
            XCTAssertTrue(role.nonColorCue.contains(role.title))
            XCTAssertTrue(role.accessibilityLabel.contains(role.title))
            XCTAssertTrue(role.accessibilityLabel.contains(role.family.title))
        }
    }

    func testSI14StatusGrammarIncludesFutureLDIHookStatesWithoutRuntimeClaims() {
        let hooks = Set(AmbitionsStatusSymbolRole.allCases.filter(\.isFutureLDIVisualHook))

        XCTAssertEqual(hooks, [
            .sourceConflict,
            .syncUnavailable,
            .packUnavailable,
            .professionalBoundary,
            .unsafeBlocked,
            .crisisSupport
        ])

        for hook in hooks {
            XCTAssertFalse(hook.detail.localizedCaseInsensitiveContains("server"))
            XCTAssertFalse(hook.detail.localizedCaseInsensitiveContains("model"))
            XCTAssertFalse(hook.detail.localizedCaseInsensitiveContains("runtime"))
        }
    }

    func testSI14ExistingStateMapsUseStatusGrammar() {
        XCTAssertEqual(SourceFreshnessState.stale.statusSymbolRole, .sourceStale)
        XCTAssertEqual(SourceFreshnessState.denied.statusSymbolRole, .sourceDenied)
        XCTAssertEqual(SourceFreshnessState.localOnly.statusSymbolRole, .localOnly)
        XCTAssertEqual(TrustReceiptLayerKind.proofSaved.statusSymbolRole, .proofSaved)
        XCTAssertEqual(TrustReceiptLayerKind.sourceConflict.statusSymbolRole, .sourceConflict)
        XCTAssertEqual(TrustReceiptLayerKind.professionalBoundary.statusSymbolRole, .professionalBoundary)
        XCTAssertEqual(AmbitionsLoadingState.sourceConflict.statusSymbolRole, .sourceConflict)
        XCTAssertEqual(AmbitionsLoadingState.privacySensitive.statusSymbolRole, .privacySensitive)
        XCTAssertEqual(AmbitionsLoadingState.crisisSupport.statusSymbolRole, .crisisSupport)
    }

    func testSI14ReduceMotionSemanticsAreStaticForEveryRole() {
        for role in AmbitionsStatusSymbolRole.allCases {
            XCTAssertTrue(role.reduceMotionSemantics.localizedCaseInsensitiveContains("static"))
            XCTAssertTrue(role.reduceMotionSemantics.localizedCaseInsensitiveContains("label"))
        }
    }

    func testFCP26EveryStatusRoleHasAllowedPlacementAndShapeCue() {
        for role in AmbitionsStatusSymbolRole.allCases {
            XCTAssertFalse(role.allowedPlacements.isEmpty, role.rawValue)
            XCTAssertFalse(role.placementSummary.isEmpty, role.rawValue)
            XCTAssertTrue(role.allowedPlacements.contains(.statusBadge), role.rawValue)
            XCTAssertTrue(role.shapeCue.contains(role.symbolName), role.rawValue)
            XCTAssertFalse(role.nonColorCue.localizedCaseInsensitiveContains("color-only"))
            XCTAssertFalse(role.accessibilityLabel.localizedCaseInsensitiveContains("AI confidence"))
        }
    }

    func testFCP26ObjectDegradedCardsRenderThroughStatusGrammar() {
        let loadingPresentations = FlagshipObjectStateOwner.allCases.map {
            DegradedStateOrchestrator.objectLoading($0)
        }
        let unavailablePresentations = FlagshipObjectStateOwner.allCases.map {
            DegradedStateOrchestrator.objectUnavailable($0)
        }

        XCTAssertTrue(loadingPresentations.allSatisfy { $0.statusRole == .loading })

        for presentation in unavailablePresentations {
            XCTAssertTrue(
                presentation.statusRole.allowedPlacements.contains(.loadingDegradedCard),
                presentation.title
            )
            XCTAssertFalse(presentation.statusRole.title.isEmpty)
            XCTAssertFalse(presentation.statusRole.shapeCue.isEmpty)
        }

        let missionControl = DegradedStateOrchestrator.objectUnavailable(.missionControlTimeSpine)
        XCTAssertEqual(missionControl.statusRole, .needsReview)
        XCTAssertTrue(missionControl.statusRole.placementSummary.contains("Loading or degraded card"))
    }
}

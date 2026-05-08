import AmbitionsDesignSystem
@testable import Ambitions
import XCTest

final class LoadingDegradedStateDesignSystemTests: XCTestCase {
    func testSI13StateMatrixCoversLoadingEmptyAndDegradedFamilies() {
        let requiredStates: Set<AmbitionsLoadingState> = [
            .loading,
            .empty,
            .noDataYet,
            .disabledPendingValidation,
            .staleSource,
            .partialSource,
            .deniedSource,
            .sourceConflict,
            .packUnavailable,
            .iCloudUnavailable,
            .localOnly,
            .updatePending,
            .privacySensitive,
            .crisisSupport,
            .unsafeBlocked,
            .waiting,
            .needsReview,
            .recovery,
            .overwhelmingDay,
            .setupNeeded
        ]

        XCTAssertEqual(Set(AmbitionsLoadingState.allCases), requiredStates)
    }

    func testSI13StatesExposeNextActionsAndReduceMotionEquivalents() {
        for state in AmbitionsLoadingState.allCases {
            XCTAssertFalse(state.title.isEmpty)
            XCTAssertFalse(state.message.isEmpty)
            XCTAssertFalse(state.symbolName.isEmpty)
            XCTAssertFalse(state.action.title.isEmpty)
            XCTAssertFalse(state.reduceMotionEquivalent.isEmpty)
            XCTAssertTrue(state.accessibilityAnnouncement.localizedCaseInsensitiveContains("Reduce Motion"))
        }
    }

    func testSI13SourcePrivacyAndLocalStatesDoNotUseColorOnlyMeaning() {
        let sourceStates: Set<AmbitionsLoadingState> = [
            .staleSource,
            .partialSource,
            .deniedSource,
            .sourceConflict,
            .packUnavailable,
            .iCloudUnavailable,
            .localOnly,
            .privacySensitive
        ]

        for state in sourceStates {
            XCTAssertFalse(state.title.isEmpty)
            XCTAssertFalse(state.message.isEmpty)
            XCTAssertFalse(state.symbolName.isEmpty)
            XCTAssertNotEqual(state.action, .wait)
        }
    }

    func testSI13LDIHookStatesStayVisualOnlyWithoutRuntimeClaims() {
        let ldiHookStates = AmbitionsLoadingState.allCases.filter(\.isFutureLDIVisualHook)

        XCTAssertEqual(Set(ldiHookStates), [
            .sourceConflict,
            .packUnavailable,
            .iCloudUnavailable,
            .updatePending,
            .crisisSupport,
            .unsafeBlocked
        ])

        let combined = ldiHookStates
            .map { "\($0.title) \($0.message) \($0.accessibilityAnnouncement)" }
            .joined(separator: " ")

        XCTAssertFalse(combined.localizedCaseInsensitiveContains("cloud synced"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("server"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("production model"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("automatic commitment"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("release ready"))
    }

    func testFCP25FlagshipObjectStateMatrixIsObjectSpecificAndHonest() {
        let entries = FlagshipObjectStateMatrix.entries
        let owners = Set(entries.map(\.owner))

        XCTAssertEqual(owners, Set(FlagshipObjectStateOwner.allCases))
        XCTAssertEqual(owners.count, 8)

        for entry in entries {
            XCTAssertEqual(entry.loadingState, .loading)
            XCTAssertFalse(entry.owner.title.isEmpty)
            XCTAssertFalse(entry.owner.icon.isEmpty)
            XCTAssertFalse(entry.boundary.isEmpty)
            XCTAssertTrue(entry.accessibilitySummary.contains(entry.owner.title))
            XCTAssertFalse(entry.accessibilitySummary.localizedCaseInsensitiveContains("generic error"))
            XCTAssertFalse(entry.accessibilitySummary.localizedCaseInsensitiveContains("fake progress"))
            XCTAssertFalse(entry.accessibilitySummary.localizedCaseInsensitiveContains("skeleton"))
        }
    }

    func testFCP25ObjectLoadingAndUnavailableCardsAvoidGenericErrorAndHiddenMutationClaims() {
        let presentations = FlagshipObjectStateOwner.allCases.flatMap { owner in
            [
                DegradedStateOrchestrator.objectLoading(owner),
                DegradedStateOrchestrator.objectUnavailable(owner)
            ]
        }
        let combinedCopy = presentations
            .flatMap { [$0.title, $0.explanation, $0.primaryAction.title, $0.icon] }
            .joined(separator: " ")

        XCTAssertTrue(combinedCopy.contains("Start Here"))
        XCTAssertTrue(combinedCopy.contains("Constellation Atlas"))
        XCTAssertTrue(combinedCopy.contains("Atmosphere Composer"))
        XCTAssertTrue(combinedCopy.contains("LifeShape Field"))
        XCTAssertTrue(combinedCopy.contains("Personal System Center"))
        XCTAssertFalse(combinedCopy.localizedCaseInsensitiveContains("generic error"))
        XCTAssertFalse(combinedCopy.localizedCaseInsensitiveContains("fake progress"))
        XCTAssertFalse(combinedCopy.localizedCaseInsensitiveContains("automatic reroute"))
        XCTAssertFalse(combinedCopy.localizedCaseInsensitiveContains("calendar write"))
        XCTAssertFalse(combinedCopy.localizedCaseInsensitiveContains("cloud synced"))
        XCTAssertTrue(combinedCopy.localizedCaseInsensitiveContains("no silent"))
    }
}

import AmbitionsDesignSystem
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
}

import AmbitionsDesignSystem
import XCTest

final class TrustReceiptLayerDesignSystemTests: XCTestCase {
    func testSI10TrustReceiptKindsCoverLDIVisualReceiptHooksWithoutRuntimeClaims() {
        let requiredKinds: Set<TrustReceiptLayerKind> = [
            .dreamHandling,
            .sourceChange,
            .mutation,
            .unsafeRedirect,
            .sourceConflict,
            .professionalBoundary
        ]

        XCTAssertTrue(requiredKinds.isSubset(of: Set(TrustReceiptLayerKind.allCases)))
    }

    func testSI10TrustReceiptAccessibilitySummaryIsSourceFreshnessAndPrivacyBound() {
        let item = TrustReceiptLayerItem(
            id: "source-review",
            kind: .sourceConflict,
            title: "Source conflict",
            summary: "Two sources disagree, so Ambitions asks for review before anything changes.",
            sourceLabel: "Local source index",
            freshness: .stale,
            privacyLabel: "Private source",
            undoLabel: "No commitment changed",
            reviewLabel: "Review source"
        )

        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Source conflict"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Local source index"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Review source"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Private source"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("No commitment changed"))
    }

    func testSI10SourceFreshnessStatesAvoidUnsupportedClaimLanguage() {
        let combined = SourceFreshnessState.allCases
            .map { "\($0.label) \($0.detail)" }
            .joined(separator: " ")

        XCTAssertFalse(combined.localizedCaseInsensitiveContains("certified"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("guaranteed"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("production ready"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("cloud synced"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("AI confidence"))
    }
}

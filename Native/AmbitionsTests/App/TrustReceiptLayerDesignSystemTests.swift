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
            whyLabel: "Sources disagree, so no change is made without review.",
            changeLabel: "Nothing changed yet.",
            undoLabel: "No commitment changed",
            correctionLabel: "Correction stays available.",
            reviewLabel: "Review source"
        )

        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Source conflict"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Local source index"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Review source"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Private source"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Sources disagree"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Nothing changed yet"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Correction stays available"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("No commitment changed"))
    }

    func testFCP06ReceiptDrawerSectionsPreserveTrustFacts() {
        let item = TrustReceiptLayerItem(
            id: "receipt-drawer",
            kind: .moved,
            title: "Moved to Goal",
            summary: "Capture placement changed after user confirmation.",
            sourceLabel: "Capture route",
            freshness: .fresh,
            privacyLabel: "Private item",
            whyLabel: "The user confirmed the placement.",
            changeLabel: "The capture moved; no goal was silently changed.",
            undoLabel: "Move back",
            correctionLabel: "Placement can be corrected.",
            reviewLabel: "Review receipt"
        )
        let section = ReceiptDrawerSection(
            id: "recent",
            title: "Recent receipts",
            subtitle: "Consequences remain reviewable.",
            items: [item]
        )

        XCTAssertEqual(section.items.first?.id, "receipt-drawer")
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Capture route"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Fresh source"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Private item"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("The user confirmed"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("no goal was silently changed"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Placement can be corrected"))
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

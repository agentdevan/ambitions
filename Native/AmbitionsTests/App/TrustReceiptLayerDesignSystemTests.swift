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

    func testFE04PrimitiveSystemContractNamesSharedPrimitiveRolesWithoutGenericLanguage() {
        let expectedRoles: Set<FE04PrimitiveRole> = [
            .graphiteRecess,
            .quietGlassShelf,
            .inspectableStrip,
            .ambientVignette,
            .seamLine,
            .luminousTrace,
            .meridianNode,
            .currentTimeGlow,
            .proofTrail,
            .receiptDrawer,
            .sourceFreshnessBadge,
            .closurePrompt,
            .startHere,
            .lifeShape,
            .atmosphereComposer,
            .constellationLane,
            .userSystemProfile
        ]

        XCTAssertEqual(Set(FE04PrimitiveSystemContract.roles), expectedRoles)
        XCTAssertTrue(FE04PrimitiveSystemContract.validationFailures().isEmpty)

        let combined = FE04PrimitiveSystemContract.roles
            .map(\.accessibilitySummary)
            .joined(separator: " ")

        XCTAssertFalse(combined.localizedCaseInsensitiveContains("dashboard"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("task list"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("chatbot"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("production ready"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("release ready"))
    }

    func testFE04PrimitiveBindingsCoverSourceFreshnessReceiptAndRealityMeridianRoles() {
        XCTAssertEqual(SourceFreshnessState.stale.fe04Role, .sourceFreshnessBadge)
        XCTAssertEqual(ReceiptDrawerSection(id: "recent", title: "Recent receipts", items: []).fe04Role, .receiptDrawer)
        XCTAssertEqual(
            ProofBead(
                id: "proof",
                title: "Proof saved",
                summary: "Source stays attached.",
                sourceLabel: "Source: local",
                freshness: .fresh,
                privacyLabel: "Private proof"
            ).fe04Role,
            .proofTrail
        )
        XCTAssertEqual(RealityMeridianTemporalWindow().fe04Role, .lifeShape)
        XCTAssertEqual(RealityMeridianCurrentTimeCursor().fe04Role, .currentTimeGlow)
        XCTAssertEqual(
            RealityMeridianScheduledNode(timeLabel: "10:00 AM", title: "Scheduled step").fe04Role,
            .meridianNode
        )
    }

    func testSI10TrustReceiptAccessibilitySummaryIsSourceFreshnessAndPrivacyBound() {
        let item = TrustReceiptLayerItem(
            id: "undo-recovery",
            kind: .undone,
            title: "Undo recorded",
            summary: "The prior receipt was reversed and the reversal stayed visible.",
            sourceLabel: "Recovery receipt",
            freshness: .localOnly,
            privacyLabel: "Private undo",
            whyLabel: "The user reversed the earlier change.",
            changeLabel: "The reversal was recorded locally.",
            undoLabel: "Undo unavailable",
            correctionLabel: "Correction stays available.",
            reviewLabel: "Review undo"
        )

        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Undo recorded"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Recovery receipt"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Local only"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Private undo"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Review undo"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("The user reversed"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("The reversal was recorded locally"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Correction stays available"))
        XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Undo unavailable"))
        XCTAssertFalse(item.accessibilitySummary.localizedCaseInsensitiveContains("cloud"))
        XCTAssertFalse(item.accessibilitySummary.localizedCaseInsensitiveContains("backend"))
        XCTAssertFalse(item.accessibilitySummary.localizedCaseInsensitiveContains("AI confidence"))
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
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("backend"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("AI confidence"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("release ready"))
    }

    func testFCP12ProofBeadCarriesSourceFreshnessPrivacyCorrectionAndStaleReview() {
        let bead = ProofBead(
            id: "proof-stale",
            title: "Proposal draft saved",
            summary: "The draft exists, but the source is older.",
            sourceLabel: "Source: Manual save",
            freshness: .stale,
            privacyLabel: "Private to this goal unless exported.",
            timestampLabel: "2026-03-01T12:00:00Z",
            correctionLabel: "Correction can be reviewed from the proof source.",
            staleReviewLabel: "Review before recommendations use this proof."
        )

        XCTAssertTrue(bead.requiresReviewBeforeRecommendation)
        XCTAssertEqual(bead.visibleSummary, "The draft exists, but the source is older.")
        XCTAssertTrue(bead.accessibilitySummary.localizedCaseInsensitiveContains("Source: Manual save"))
        XCTAssertTrue(bead.accessibilitySummary.localizedCaseInsensitiveContains("Review before recommendations"))
        XCTAssertTrue(bead.accessibilitySummary.localizedCaseInsensitiveContains("Private to this goal"))
        XCTAssertTrue(bead.accessibilitySummary.localizedCaseInsensitiveContains("Correction can be reviewed"))
    }

    func testFCP12ProofPrivacyRedactionPreservesRoleWhileHidingDetail() {
        let bead = ProofBead(
            id: "proof-private",
            title: "Private proof",
            summary: "Specific private details",
            sourceLabel: "Source: Imported file",
            freshness: .partial,
            privacyLabel: "Private detail hidden.",
            redactedDetail: "Proof detail hidden."
        )

        XCTAssertTrue(bead.isRedacted)
        XCTAssertEqual(bead.visibleSummary, "Proof detail hidden.")
        XCTAssertTrue(bead.requiresReviewBeforeRecommendation)
        XCTAssertFalse(bead.accessibilitySummary.contains("Specific private details"))
    }

    func testFCP06ProofBeadKeepsFreshnessPrivacyAndRecoveryLabelsVisible() {
        let bead = ProofBead(
            id: "proof-recovery",
            title: "Recovery proof",
            summary: "The recovery path stayed visible.",
            sourceLabel: "Source: Recovery receipt",
            freshness: .blocked,
            privacyLabel: "Protected state",
            timestampLabel: "2026-05-18T12:10:00Z",
            correctionLabel: "Correction unavailable",
            staleReviewLabel: "Blocked safely until review"
        )

        XCTAssertTrue(bead.accessibilitySummary.localizedCaseInsensitiveContains("Recovery proof"))
        XCTAssertTrue(bead.accessibilitySummary.localizedCaseInsensitiveContains("Source: Recovery receipt"))
        XCTAssertTrue(bead.accessibilitySummary.localizedCaseInsensitiveContains("Blocked safely until review"))
        XCTAssertTrue(bead.accessibilitySummary.localizedCaseInsensitiveContains("Protected state"))
        XCTAssertTrue(bead.accessibilitySummary.localizedCaseInsensitiveContains("Correction unavailable"))
    }
}

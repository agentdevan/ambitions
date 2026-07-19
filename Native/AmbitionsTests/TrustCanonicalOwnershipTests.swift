@testable import Ambitions
import XCTest

final class TrustCanonicalOwnershipTests: XCTestCase {
    func testCanonicalTrustFilesExist() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Trust/InspectionSurface.swift",
            "Native/Ambitions/Trust/ProofInspectionView.swift",
            "Native/Ambitions/Trust/SourceInspectionView.swift",
            "Native/Ambitions/Trust/SourceInspectionModels.swift",
            "Native/Ambitions/Trust/PrivacyInspectionView.swift",
            "Native/Ambitions/Trust/HistoryInspectionView.swift",
            "Native/Ambitions/Trust/ReceiptInspectionView.swift",
            "Native/Ambitions/Trust/RuntimeExplanationPolicy.swift",
            "Native/Ambitions/Trust/TrustDisclosureLevel.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing canonical Trust owner: \(requiredPath)"
            )
        }
    }

    func testRuntimeExplanationPolicyKeepsInspectionAsDetailNotRootSurface() {
        let policy = RuntimeExplanationPolicy.detailInspection

        XCTAssertEqual(policy.disclosureLevel(for: .proof), .evidence)
        XCTAssertEqual(policy.disclosureLevel(for: .source), .evidence)
        XCTAssertEqual(policy.disclosureLevel(for: .privacy), .sensitive)
        XCTAssertEqual(policy.disclosureLevel(for: .history), .summary)
        XCTAssertEqual(policy.disclosureLevel(for: .receipt), .receipt)
        XCTAssertTrue(policy.explanation(for: .history).contains("not an activity feed"))
        XCTAssertTrue(policy.localOnlySummary.contains("private data"))
        XCTAssertFalse(policy.localOnlySummary.localizedCaseInsensitiveContains("release " + "ready"))
    }

    func testInspectionSurfaceStatesHaveAccessibleReviewItems() {
        for kind in TrustInspectionKind.allCases {
            let state = InspectionSurfaceState.make(kind: kind, policy: .detailInspection)

            XCTAssertEqual(state.kind, kind)
            XCTAssertEqual(state.ownerSurface, "You")
            XCTAssertFalse(state.contextualRouteLabel.isEmpty)
            XCTAssertFalse(state.visibleConsequenceSummary.isEmpty)
            XCTAssertTrue(state.localBoundarySummary.localizedCaseInsensitiveContains("private data"))
            XCTAssertTrue(state.claimBoundarySummary.localizedCaseInsensitiveContains("not release readiness"))
            XCTAssertEqual(state.items.count, 3)
            XCTAssertTrue(state.accessibilityIdentifier.contains("trust.\(kind.rawValue).inspection-surface"))
            XCTAssertTrue(state.accessibilityValue.contains("Opens from \(state.contextualRouteLabel) in You"))
            XCTAssertTrue(state.items.allSatisfy { $0.detail.isEmpty == false })
        }
    }

    func testInspectionSurfaceStatesAvoidDiagnosticDashboardAndReadinessCopy() {
        let forbiddenFragments = [
            "dashboard",
            "debug",
            "diagnostic",
            "admin",
            "console",
            "release " + "ready",
            "app store " + "ready",
            "testflight " + "ready",
        ]

        for kind in TrustInspectionKind.allCases {
            let state = InspectionSurfaceState.make(kind: kind, policy: .detailInspection)
            let visibleCopy = [
                state.title,
                state.subtitle,
                state.ownerSurface,
                state.contextualRouteLabel,
                state.visibleConsequenceSummary,
                state.localBoundarySummary,
                state.claimBoundarySummary,
                state.accessibilityValue,
                state.accessibilityHint,
            ].joined(separator: " ")

            for fragment in forbiddenFragments {
                XCTAssertFalse(
                    visibleCopy.localizedCaseInsensitiveContains(fragment),
                    "\(kind.rawValue) leaked forbidden trust copy: \(fragment)"
                )
            }
        }
    }

    func testTrustInspectionRoutesStayContextualUnderYou() {
        XCTAssertEqual(YouRootDetail.trustCenter.routeTarget, .privacy)
        XCTAssertEqual(YouRootDetail.receiptsHistory.routeTarget, .receiptsHistory)
        XCTAssertEqual(YouRootDetail.sourceSettings.routeTarget, .sourceSettings)
        XCTAssertEqual(YouRootDetail.localDataControls.routeTarget, .localDataControls)
        XCTAssertEqual(YouRootDetail.proof.routeTarget, .history)
    }

    func testCanonicalDetailViewsRouteThroughInspectionSurface() throws {
        let root = repoRoot()
        let proof = try source("Native/Ambitions/Trust/ProofInspectionView.swift", root: root)
        let sourceView = try source("Native/Ambitions/Trust/SourceInspectionView.swift", root: root)
        let privacy = try source("Native/Ambitions/Trust/PrivacyInspectionView.swift", root: root)
        let receipt = try source("Native/Ambitions/Trust/ReceiptInspectionView.swift", root: root)
        let history = try source("Native/Ambitions/Trust/HistoryInspectionView.swift", root: root)

        XCTAssertTrue(proof.contains("InspectionSurface(kind: .proof)"))
        XCTAssertTrue(sourceView.contains("SourceInspectionPresentation"))
        XCTAssertTrue(sourceView.contains("trust.source.inspection-detail"))
        XCTAssertTrue(privacy.contains("InspectionSurface(kind: .privacy)"))
        XCTAssertTrue(receipt.contains("InspectionSurface(kind: .receipt)"))
        XCTAssertTrue(history.contains("InspectionSurface(kind: .history)"))
        XCTAssertTrue(history.contains("actions.openTimeRoute(.weeklyReview)"))
    }

    func testCanonicalTrustSourceAvoidsRootSurfaceAndDiagnosticLanguage() throws {
        let root = repoRoot()
        let relativePaths = [
            "Native/Ambitions/Trust/InspectionSurface.swift",
            "Native/Ambitions/Trust/ProofInspectionView.swift",
            "Native/Ambitions/Trust/SourceInspectionView.swift",
            "Native/Ambitions/Trust/SourceInspectionModels.swift",
            "Native/Ambitions/Trust/PrivacyInspectionView.swift",
            "Native/Ambitions/Trust/HistoryInspectionView.swift",
            "Native/Ambitions/Trust/ReceiptInspectionView.swift",
            "Native/Ambitions/Trust/RuntimeExplanationPolicy.swift",
        ]
        let sourceCopy = try relativePaths.map { try source($0, root: root) }.joined(separator: "\n")

        XCTAssertFalse(sourceCopy.contains("AppTab.trust"))
        XCTAssertFalse(sourceCopy.contains("case trust"))
        XCTAssertFalse(sourceCopy.localizedCaseInsensitiveContains("dashboard"))
        XCTAssertFalse(sourceCopy.localizedCaseInsensitiveContains("debug"))
        XCTAssertFalse(sourceCopy.localizedCaseInsensitiveContains("diagnostic"))
        XCTAssertFalse(sourceCopy.localizedCaseInsensitiveContains("admin"))
        XCTAssertFalse(sourceCopy.localizedCaseInsensitiveContains("console"))
    }
}

private extension TrustCanonicalOwnershipTests {
    func source(_ relativePath: String, root: URL) throws -> String {
        try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
    }

    func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Trust")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}

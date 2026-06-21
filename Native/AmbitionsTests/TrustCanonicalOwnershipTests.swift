@testable import Ambitions
import XCTest

final class TrustCanonicalOwnershipTests: XCTestCase {
    func testCanonicalTrustFilesExist() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Trust/InspectionSurface.swift",
            "Native/Ambitions/Trust/ProofInspectionView.swift",
            "Native/Ambitions/Trust/SourceInspectionView.swift",
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
    }

    func testInspectionSurfaceStatesHaveAccessibleReviewItems() {
        for kind in TrustInspectionKind.allCases {
            let state = InspectionSurfaceState.make(kind: kind, policy: .detailInspection)

            XCTAssertEqual(state.kind, kind)
            XCTAssertEqual(state.items.count, 3)
            XCTAssertTrue(state.accessibilityIdentifier.contains("trust.\(kind.rawValue).inspection-surface"))
            XCTAssertFalse(state.accessibilityValue.isEmpty)
            XCTAssertTrue(state.items.allSatisfy { $0.detail.isEmpty == false })
        }
    }

    func testCanonicalDetailViewsRouteThroughInspectionSurface() throws {
        let root = repoRoot()
        let proof = try source("Native/Ambitions/Trust/ProofInspectionView.swift", root: root)
        let sourceView = try source("Native/Ambitions/Trust/SourceInspectionView.swift", root: root)
        let privacy = try source("Native/Ambitions/Trust/PrivacyInspectionView.swift", root: root)
        let receipt = try source("Native/Ambitions/Trust/ReceiptInspectionView.swift", root: root)
        let history = try source("Native/Ambitions/Trust/HistoryInspectionView.swift", root: root)

        XCTAssertTrue(proof.contains("InspectionSurface(kind: .proof)"))
        XCTAssertTrue(sourceView.contains("InspectionSurface(kind: .source)"))
        XCTAssertTrue(privacy.contains("InspectionSurface(kind: .privacy)"))
        XCTAssertTrue(receipt.contains("InspectionSurface(kind: .receipt)"))
        XCTAssertTrue(history.contains("InspectionSurface(kind: .history)"))
        XCTAssertTrue(history.contains("actions.openTimeRoute(.weeklyReview)"))
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

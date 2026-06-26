@testable import Ambitions
import XCTest

final class SourceInspectionPresentationTests: XCTestCase {
    func testSourceInspectionCoversRequiredStates() {
        XCTAssertEqual(
            Set(SourceInspectionState.allCases),
            [
                .current,
                .stale,
                .staleCritical,
                .unavailable,
                .conflicted,
                .revoked,
                .unsupported,
                .reviewRequired,
            ]
        )

        let fixtures = SourceInspectionPresentationFixtures.all
        XCTAssertEqual(fixtures.map(\.state), SourceInspectionState.allCases)
        XCTAssertTrue(fixtures.allSatisfy { $0.hiddenByDefaultSummary.contains("only when requested") })
        XCTAssertTrue(fixtures.allSatisfy { $0.privacySummary.contains("Personal goals") })
        XCTAssertTrue(fixtures.allSatisfy { $0.privacySummary.contains("account secrets") })
    }

    func testBlockedStatesAreHonestAboutCurrentUse() {
        let blockedStates: Set<SourceInspectionState> = [
            .staleCritical,
            .unavailable,
            .conflicted,
            .revoked,
            .unsupported,
            .reviewRequired,
        ]

        for presentation in SourceInspectionPresentationFixtures.all where blockedStates.contains(presentation.state) {
            XCTAssertTrue(presentation.state.blocksCurrentUse, presentation.state.rawValue)
            XCTAssertTrue(
                presentation.contextRows.contains {
                    $0.title == "Use" &&
                        ($0.detail.localizedCaseInsensitiveContains("cannot") ||
                            $0.detail.localizedCaseInsensitiveContains("blocked"))
                },
                presentation.state.rawValue
            )
        }
    }

    func testCopyAuditRejectsArchitectureAndDebugTerms() {
        XCTAssertEqual(SourceInspectionCopyAudit.validate(SourceInspectionPresentationFixtures.all), [])

        let invalid = SourceInspectionPresentation.make(
            id: "invalid",
            state: .current,
            publicDetail: SourceInspectionPublicDetail(
                sourceName: "R2 object debug shard",
                sourceKind: "Adapter",
                referenceTitle: "Private graph manifest internals",
                retrievedLabel: "Current",
                freshnessLabel: "Current",
                useLabel: "Available"
            ),
            useContext: "Compiler lattice context",
            reviewAction: "No review needed."
        )

        let failures = SourceInspectionCopyAudit.validate(invalid)
        XCTAssertTrue(failures.contains { $0.contains("r2 object") })
        XCTAssertTrue(failures.contains { $0.contains("private graph") })
        XCTAssertTrue(failures.contains { $0.contains("adapter") })
        XCTAssertTrue(failures.contains { $0.contains("compiler") })
    }

    func testSourceInspectionViewIsTrustDetailRendererNotRootSurface() throws {
        let source = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/Trust/SourceInspectionView.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(source.contains("SourceInspectionPresentation"))
        XCTAssertTrue(source.contains("SourceInspectionPresentationFixtures.defaultDetail"))
        XCTAssertTrue(source.contains("trust.source.inspection-detail"))
        XCTAssertFalse(source.localizedCaseInsensitiveContains("tabview"))
        XCTAssertFalse(source.localizedCaseInsensitiveContains("root destination"))
        XCTAssertFalse(source.localizedCaseInsensitiveContains("dashboard"))
    }

    private func repoRoot() -> URL {
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

import XCTest
@testable import Ambitions

final class RepoTruthAuditLedgerTests: XCTestCase {
    func testAuditEntryRoundTripsThroughJSON() throws {
        let entry = RepoTruthAuditEntry(
            id: "native-ambitions-app-apptab-swift",
            path: "Native/Ambitions/App/AmbitionsSurface.swift",
            currentResponsibility: "Canonical four-surface shell registry plus legacy route compatibility.",
            canonicalLayer: .app,
            productOwner: .stageShell,
            implementationStatus: .realImplementation,
            designTruthViolations: [],
            languageViolations: [],
            runtimeMutationBehavior: .projectionOnly,
            accessibilityCoverage: .notApplicable,
            chromeSafeAreaRisk: .none,
            splitRecommendation: .keep,
            proofRequired: [.build, .focusedTests, .architectureConformanceScan],
            status: .green
        )

        let data = try JSONEncoder().encode(entry)
        let decoded = try JSONDecoder().decode(RepoTruthAuditEntry.self, from: data)

        XCTAssertEqual(decoded, entry)
        XCTAssertEqual(decoded.id, "native-ambitions-app-apptab-swift")
        XCTAssertEqual(decoded.path, "Native/Ambitions/App/AmbitionsSurface.swift")
    }

    func testAuditVocabulariesDoNotExposeUnknownCases() {
        let allRawValues: [String] =
            RepoTruthCanonicalLayer.allCases.map(\.rawValue) +
            RepoTruthProductOwner.allCases.map(\.rawValue) +
            RepoTruthImplementationStatus.allCases.map(\.rawValue) +
            RepoTruthMutationBehavior.allCases.map(\.rawValue) +
            RepoTruthAccessibilityCoverage.allCases.map(\.rawValue) +
            RepoTruthChromeSafeAreaRisk.allCases.map(\.rawValue) +
            RepoTruthSplitRecommendation.allCases.map(\.rawValue) +
            RepoTruthProofArtifactRequirement.allCases.map(\.rawValue) +
            RepoTruthAuditStatus.allCases.map(\.rawValue)

        XCTAssertFalse(allRawValues.contains("unknown"))
        XCTAssertTrue(RepoTruthImplementationStatus.allCases.contains(.realBoundaryAdapter))
        XCTAssertTrue(RepoTruthImplementationStatus.allCases.contains(.obsoleteArchitecture))
        XCTAssertTrue(RepoTruthProofArtifactRequirement.allCases.contains(.forbiddenLanguageScan))
    }

    func testStatusVocabularyMatchesTrainLedgerTerms() {
        XCTAssertEqual(
            Set(RepoTruthAuditStatus.allCases.map(\.rawValue)),
            Set(["Green", "Yellow", "Red", "Delete", "Keep", "Split", "Replace", "Test-only"])
        )
    }
}

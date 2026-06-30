import XCTest
@testable import Ambitions

final class SourceAtlasCoverageRuntimeFixtureModelsTests: XCTestCase {
    func testPromotedCoverageFixturesDecodeAndValidateAsNativeRuntimeInputs() throws {
        let fixtures = try Self.loadPromotedCoverageFixtures()

        XCTAssertGreaterThanOrEqual(fixtures.count, 25)
        XCTAssertTrue(fixtures.allSatisfy(\.isValidRuntimeFixtureInput))
        XCTAssertTrue(fixtures.allSatisfy { $0.runtimeBoundary.isValueModelOnly })
        XCTAssertTrue(fixtures.allSatisfy { $0.canDriveRuntimeProofAlone == false })
        XCTAssertTrue(fixtures.allSatisfy(\.generatedDerivativeNotice))
        XCTAssertTrue(fixtures.allSatisfy(\.cannotSatisfyProofAlone))
        XCTAssertTrue(fixtures.allSatisfy { $0.candidateScore >= 85 })
        XCTAssertTrue(fixtures.allSatisfy { $0.validatedForRuntimeFixtureUseDoesNotThrow })
    }

    func testCoverageFixturesWireEveryPromotedRuntimeFamily() throws {
        let families = Set(try Self.loadPromotedCoverageFixtures().map(\.family))

        XCTAssertTrue(families.contains(.runtime))
        XCTAssertTrue(families.contains(.startHere))
        XCTAssertTrue(families.contains(.realityMeridian))
        XCTAssertTrue(families.contains(.closure))
        XCTAssertTrue(families.contains(.recovery))
        XCTAssertTrue(families.contains(.freshness))
        XCTAssertTrue(families.contains(.privacy))
        XCTAssertTrue(families.contains(.replay))
    }

    func testCoverageFixtureCannotBecomeRuntimeProofWhenDerivativeBoundaryIsMissing() throws {
        var fixture = try XCTUnwrap(Self.loadPromotedCoverageFixtures().first)
        fixture = SourceAtlasCoverageRuntimeFixture(
            id: fixture.id,
            version: fixture.version,
            family: fixture.family,
            candidateID: fixture.candidateID,
            scenarioIDs: fixture.scenarioIDs,
            inputHash: fixture.inputHash,
            candidateScore: fixture.candidateScore,
            generatedDerivativeNotice: false,
            cannotSatisfyProofAlone: false,
            expectedTestBehavior: fixture.expectedTestBehavior,
            privacyBoundary: fixture.privacyBoundary,
            localOnlyRequirement: fixture.localOnlyRequirement
        )

        XCTAssertTrue(fixture.validationIssues.contains(.missingDerivativeNotice))
        XCTAssertTrue(fixture.validationIssues.contains(.missingProofBoundary))
        XCTAssertFalse(fixture.isValidRuntimeFixtureInput)
        XCTAssertThrowsError(try fixture.validatedForRuntimeFixtureUse())
    }

    func testCoverageFixtureRejectsRuntimeUnsafeBoundaryLanguage() throws {
        let fixture = try XCTUnwrap(Self.loadPromotedCoverageFixtures().first)
        let unsafe = SourceAtlasCoverageRuntimeFixture(
            id: fixture.id,
            version: fixture.version,
            family: fixture.family,
            candidateID: fixture.candidateID,
            scenarioIDs: fixture.scenarioIDs,
            inputHash: fixture.inputHash,
            candidateScore: fixture.candidateScore,
            generatedDerivativeNotice: fixture.generatedDerivativeNotice,
            cannotSatisfyProofAlone: fixture.cannotSatisfyProofAlone,
            expectedTestBehavior: fixture.expectedTestBehavior,
            privacyBoundary: "Requires external service before use.",
            localOnlyRequirement: "Requires API key before validation."
        )

        XCTAssertTrue(unsafe.validationIssues.contains(.unsafeNetworkOrProviderBoundary))
        XCTAssertFalse(unsafe.isValidRuntimeFixtureInput)
    }
}

private extension SourceAtlasCoverageRuntimeFixtureModelsTests {
    static func loadPromotedCoverageFixtures() throws -> [SourceAtlasCoverageRuntimeFixture] {
        let root = repoRoot()
        let fixtureRoot = root.appendingPathComponent("source-atlas/fixtures", isDirectory: true)
        let enumerator = try XCTUnwrap(FileManager.default.enumerator(
            at: fixtureRoot,
            includingPropertiesForKeys: nil
        ))
        let fixtureURLs = enumerator
            .compactMap { $0 as? URL }
            .filter { $0.pathExtension == "json" }
            .sorted { $0.path < $1.path }

        XCTAssertFalse(fixtureURLs.isEmpty)
        return try fixtureURLs.map { url in
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(SourceAtlasCoverageRuntimeFixture.self, from: data)
        }
    }

    static func repoRoot() -> URL {
        let start = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()

        var current = start
        let fileManager = FileManager.default

        while true {
            let fixtureRoot = current
                .appendingPathComponent("source-atlas", isDirectory: true)
                .appendingPathComponent("fixtures", isDirectory: true)
            if fileManager.fileExists(atPath: fixtureRoot.path, isDirectory: nil) {
                return current
            }

            let parent = current.deletingLastPathComponent()
            if parent.path == current.path {
                return start
            }

            current = parent
        }
    }
}

private extension SourceAtlasCoverageRuntimeFixture {
    var validatedForRuntimeFixtureUseDoesNotThrow: Bool {
        do {
            _ = try validatedForRuntimeFixtureUse()
            return true
        } catch {
            return false
        }
    }
}

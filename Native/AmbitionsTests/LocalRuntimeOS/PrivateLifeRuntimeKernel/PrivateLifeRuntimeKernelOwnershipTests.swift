import XCTest
@testable import Ambitions

final class PrivateLifeRuntimeKernelOwnershipTests: XCTestCase {
    func testKernelSourceLeavesLiveUnderCanonicalLocalRuntimeOSOwner() throws {
        let repositoryRoot = try Self.repositoryRoot()
        let owner = repositoryRoot.appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel", isDirectory: true)
        let legacyRuntimeOwner = repositoryRoot.appendingPathComponent("Native/Ambitions/Core/Runtime", isDirectory: true)

        let requiredLeaves = [
            "DecisionKernel.swift",
            "RecommendationKernel.swift",
            "CapacityFitKernel.swift",
            "RecoveryKernel.swift",
            "ClosureKernel.swift",
            "ProofKernel.swift",
            "AdaptationKernel.swift",
            "ExplanationKernel.swift",
            "ReplayableDecisionTrace.swift",
            "PersonalizationFactorLedger.swift"
        ]

        for leaf in requiredLeaves {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: owner.appendingPathComponent(leaf).path),
                "\(leaf) must live under Core/LocalRuntimeOS/PrivateLifeRuntimeKernel."
            )
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: legacyRuntimeOwner.appendingPathComponent(leaf).path),
                "\(leaf) must not remain under Core/Runtime."
            )
        }

        let forbiddenLegacyFiles = [
            "PrivateLifeRuntimeKernelContracts+02-PrivateLifeRuntimeKernel.swift",
            "PrivateLifeRuntimeKernelContracts+02-PrivateLifeRuntimeKernel+02-boundary.swift",
            "PrivateLifeRuntimeKernelContracts+02-PrivateLifeRuntimeKernel+03-lifeContextCadence.swift",
            "PrivateLifeRuntimeKernelContracts+02-PrivateLifeRuntimeKernel+04-traceReasonSignature.swift",
            "ReplayableDecisionTraceModels.swift",
            "PersonalizationFactorLedgerModels.swift"
        ]

        for file in forbiddenLegacyFiles {
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: legacyRuntimeOwner.appendingPathComponent(file).path),
                "\(file) must not remain in the legacy runtime owner."
            )
        }
    }

    func testTypedSignalKernelPreservesDeterministicLifeContextEffects() {
        let projection = LifeContextFixtureProfiles.cityWorkshopLaunchWithoutEquipment()
            .projection(asOf: Date(timeIntervalSince1970: 1_780_000_000))
        let closure = ClosureKernel().assess(projection: projection)
        let signals = AdaptationKernel().signals(for: projection, readiness: closure.readiness)
        let capacity = CapacityFitKernel().evaluate(
            projection: projection,
            readiness: closure.readiness,
            signals: signals
        )
        let recovery = RecoveryKernel().evaluate(
            projection: projection,
            readiness: closure.readiness,
            signals: signals
        )
        let explanation = ExplanationKernel().makeExplanation(
            goalText: "Launch a weekend workshop.",
            readiness: closure.readiness,
            projection: projection,
            signals: signals
        )

        XCTAssertEqual(closure.readiness, .ready)
        XCTAssertTrue(signals.contains(.homePracticeAccess))
        XCTAssertTrue(signals.contains(.equipmentContext))
        XCTAssertTrue(signals.contains(.localAccess))
        XCTAssertEqual(capacity.cadence, "local access cadence")
        XCTAssertEqual(capacity.urgency, "focused")
        XCTAssertEqual(recovery.milestone, "confirm equipment and local practice")
        XCTAssertTrue(explanation.contains("equipment and local practice matter before maker-space access"))
    }

    private static func repositoryRoot() throws -> URL {
        var directory = URL(fileURLWithPath: #filePath)
        while directory.pathComponents.count > 1 {
            let candidate = directory.appendingPathComponent("project.yml")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return directory
            }
            directory.deleteLastPathComponent()
        }
        throw XCTSkip("Unable to locate repository root from #filePath.")
    }
}

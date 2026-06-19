import XCTest
@testable import AmbitionsExperienceKernel

final class AmbitionsExperienceKernelTests: XCTestCase {
    func testTodayContract() {
        let today = AmbitionsSurfaceContracts.contract(for: .today)
        XCTAssertEqual(today.primaryObject, .realityMeridian)
        XCTAssertTrue(today.decisionLayers.contains(.startHere))
    }

    func testRelockedSurfaceContractsUseCurrentProductObjects() {
        XCTAssertEqual(AmbitionsSurface.allCases, [.today, .goals, .time, .you])
        XCTAssertEqual(AmbitionsSurfaceContracts.contract(for: .goals).primaryObject, .constellationAtlas)
        XCTAssertEqual(AmbitionsSurfaceContracts.contract(for: .you).primaryObject, .userSystemProfile)
        XCTAssertTrue(AmbitionsPrimaryObject.allCases.contains(.atmosphereComposer))
    }

    func testCompilerProtectsProtectedTime() {
        let state = AmbitionsExperienceCompiler.compile(AmbitionsPreviewFixtures.protectedTodayInput)
        XCTAssertEqual(state.fit, .protectedTime)
    }

    func testSourceQualityOrdering() {
        XCTAssertGreaterThan(AmbitionsSourceQuality.directUserCommitment.rawValue, AmbitionsSourceQuality.staleSignal.rawValue)
    }

    func testProofReplayRequiresDigests() {
        let trace = AmbitionsReplayTrace(events: [
            .init(kind: .recommendationCompiled, beforeDigest: "before", afterDigest: "after", explanation: "Compiled locally")
        ])
        XCTAssertTrue(trace.isReplayable)
    }

    func testTokenCountIsControlled() {
        XCTAssertTrue(AmbitionsTokenPolicy.isControlledCount())
    }

    func testReducerEmitsRuntimeState() {
        let state = AmbitionsExperienceReducer.reduce(input: AmbitionsPreviewFixtures.normalTodayInput)
        XCTAssertEqual(state.surface, .today)
        XCTAssertEqual(state.primaryObject, .realityMeridian)
        XCTAssertFalse(state.effects.isEmpty)
    }

    func testSnapshotMatrixCoverage() {
        XCTAssertEqual(AmbitionsSnapshotMatrix.required.count, AmbitionsSurface.allCases.count * AmbitionsSnapshotVariant.allCases.count)
    }

    func testReleaseAuthorityRequiresXcodeEvidence() {
        let report = AmbitionsReleaseAuthority.evaluate(.init(packageLintPassed: true, repoTruthAuditPassed: true, xcodeBuildPassed: false, xcodeTestsPassed: false, screenshotMatrixCount: 0, accessibilityReviewed: false, performanceReviewed: false, rollbackDocumented: false))
        XCTAssertEqual(report.color, .red)
    }

}

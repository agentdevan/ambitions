@testable import Ambitions
import XCTest

final class DiagnosticsCanonicalOwnershipTests: XCTestCase {
    func testCanonicalDiagnosticsFilesExist() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Diagnostics/RuntimeDiagnostics.swift",
            "Native/Ambitions/Diagnostics/StageDiagnostics.swift",
            "Native/Ambitions/Diagnostics/RenderDiagnostics.swift",
            "Native/Ambitions/Diagnostics/StoreDiagnostics.swift",
            "Native/Ambitions/Diagnostics/CrashTriageNotes.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing canonical diagnostics owner: \(requiredPath)"
            )
        }
    }

    func testDiagnosticsOwnersProduceNoDeterministicBlockers() {
        let checks = RuntimeDiagnostics.defaultChecks +
            StageDiagnostics.defaultChecks +
            RenderDiagnostics.defaultChecks +
            StoreDiagnostics.defaultChecks

        XCTAssertFalse(checks.isEmpty)
        XCTAssertFalse(checks.contains(where: \.blocksGreen))
        XCTAssertTrue(checks.allSatisfy { $0.owner.isEmpty == false })
        XCTAssertTrue(checks.allSatisfy { $0.proofRequirement.isEmpty == false })
    }

    func testStageAndRuntimeDiagnosticsKeepCanonBoundariesVisible() {
        XCTAssertEqual(StageDiagnostics.rootSurfaces, [.today, .goals, .time, .you])
        XCTAssertTrue(RuntimeDiagnostics.actionFlowStages.contains("StageAction"))
        XCTAssertTrue(RuntimeDiagnostics.actionFlowStages.contains("proof artifact"))
        XCTAssertFalse(RuntimeDiagnostics.actionFlowStages.contains("Motion destination"))
    }

    func testRenderStoreAndCrashDiagnosticsBindExistingOwners() {
        XCTAssertEqual(Set(RenderDiagnostics.requiredRoles), Set(CanvasPrimitiveObjectRole.allCases))
        XCTAssertTrue(StoreDiagnostics.localStoreOwners.contains("Core/Persistence"))
        XCTAssertEqual(CrashTriageNotes.note(id: "mutation-crash")?.owner, "Core/Runtime")
    }
}

private extension DiagnosticsCanonicalOwnershipTests {
    func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Diagnostics")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}

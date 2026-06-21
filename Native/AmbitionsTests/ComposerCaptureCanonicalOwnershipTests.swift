@testable import Ambitions
import XCTest

final class ComposerCaptureCanonicalOwnershipTests: XCTestCase {
    func testCanonicalCaptureFilesExist() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Composer/Capture/CaptureSurface.swift",
            "Native/Ambitions/Composer/Capture/CaptureObjectView.swift",
            "Native/Ambitions/Composer/Capture/CaptureInteractions.swift",
            "Native/Ambitions/Composer/Capture/CaptureAccessibility.swift",
            "Native/Ambitions/Composer/Capture/CaptureInputModel.swift",
            "Native/Ambitions/Composer/Capture/CaptureRoutingPreview.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing canonical Composer/Capture owner: \(requiredPath)"
            )
        }
    }

    func testCaptureInputModelAndInteractionsPreserveSaveRules() {
        let empty = CaptureInputModel(
            text: "   ",
            routePreview: nil,
            error: nil,
            presentationMode: .globalComposer
        )
        let ready = CaptureInputModel(
            text: "Buy replacement notebook",
            routePreview: nil,
            error: nil,
            presentationMode: .globalComposer
        )
        let saving = CaptureInputModel(
            text: "Buy replacement notebook",
            routePreview: nil,
            error: nil,
            presentationMode: .globalComposer,
            isSaving: true
        )

        XCTAssertFalse(CaptureInteractions.canSubmit(empty))
        XCTAssertTrue(CaptureInteractions.canSubmit(ready))
        XCTAssertFalse(CaptureInteractions.canSubmit(saving))
        XCTAssertEqual(CaptureInteractions.livingState(for: ready, hasActionReceipt: false), .active)
        XCTAssertEqual(CaptureInteractions.livingState(for: empty, hasActionReceipt: false), .empty)
        XCTAssertEqual(CaptureInteractions.livingState(for: ready, hasActionReceipt: true), .proof)
    }

    func testCaptureAccessibilityCarriesMutationProofContract() {
        let input = CaptureInputModel(
            text: "Ask Sam about Friday",
            routePreview: nil,
            error: nil,
            presentationMode: .globalComposer
        )
        let accessibility = CaptureAccessibility.composer(
            input: input,
            proofContract: .localSave,
            actionMessage: CaptureActionMessage(title: "Saved locally", body: "Receipt ready.")
        )

        XCTAssertEqual(accessibility.label, "Capture")
        XCTAssertTrue(accessibility.value.contains("Ready to Place"))
        XCTAssertTrue(accessibility.hint.contains("Saves the capture through the local Capture runtime"))
        XCTAssertEqual(accessibility.announcement, "Saved locally. Receipt ready.")
        XCTAssertEqual(accessibility.proofArtifactID, "capture-proof-savedlocally")
    }

    func testProductionCaptureSurfacesUseCanonicalObjectViewAndSurfaceWrapper() throws {
        let root = repoRoot()
        let composer = try source("Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift", root: root)
        let activated = try source("Native/Ambitions/App/AppShellActivatedCaptureSeam.swift", root: root)
        let quiet = try source("Native/Ambitions/Stage/Overlays/QuietCommandCaptureOverlay.swift", root: root)
        let surface = try source("Native/Ambitions/Composer/Capture/CaptureSurface.swift", root: root)

        XCTAssertTrue(composer.contains("CaptureObjectView("))
        XCTAssertTrue(composer.contains("CaptureInteractions.livingState"))
        XCTAssertTrue(composer.contains("CaptureAccessibility.composer"))
        XCTAssertTrue(activated.contains("CaptureObjectView("))
        XCTAssertTrue(quiet.contains("CaptureObjectView("))
        XCTAssertTrue(surface.contains("CaptureComposerSurface(shellMode: presentationMode)"))
        XCTAssertFalse(surface.contains("TabView"))
    }
}

private extension ComposerCaptureCanonicalOwnershipTests {
    func source(_ relativePath: String, root: URL) throws -> String {
        try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
    }

    func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Composer/Capture")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}

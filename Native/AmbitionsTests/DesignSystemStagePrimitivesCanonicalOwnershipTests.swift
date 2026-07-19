@testable import Ambitions
import XCTest

final class DesignSystemStagePrimitivesCanonicalOwnershipTests: XCTestCase {
    func testCanonicalStagePrimitiveFilesExist() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/DesignSystem/StagePrimitives/ProductObjectFrame.swift",
            "Native/Ambitions/DesignSystem/StagePrimitives/ContextCrown.swift",
            "Native/Ambitions/DesignSystem/StagePrimitives/ContinuityDock.swift",
            "Native/Ambitions/DesignSystem/StagePrimitives/CaptureAccessPoint.swift",
            "Native/Ambitions/DesignSystem/StagePrimitives/SurfaceMorphBackdrop.swift",
            "Native/Ambitions/DesignSystem/StagePrimitives/TrustSeam.swift",
            "Native/Ambitions/DesignSystem/StagePrimitives/ReceiptSurface.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing canonical stage primitive owner: \(requiredPath)"
            )
        }
    }

    func testCaptureAccessPointOwnsToolbarPolicy() {
        let access = CaptureAccessPoint.toolbar

        XCTAssertEqual(access.title, "Capture")
        XCTAssertEqual(access.systemImage, "square.and.pencil")
        XCTAssertEqual(access.accessibilityIdentifier(for: .today), "shell.today.capture-button")
        XCTAssertEqual(CaptureAccessPoint.activeComposer.accessibilityLabel, "Capture composer")
    }

    func testHeaderAndToolbarUseCanonicalStagePrimitives() throws {
        let root = repoRoot()
        let header = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/Stage/Chrome/AppShellHeaderRail.swift"),
            encoding: .utf8
        )
        let toolbar = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/Stage/Chrome/AppShellContextualToolbarCatalog.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(header.contains("ContextCrown("))
        XCTAssertTrue(toolbar.contains("CaptureAccessPoint.toolbar"))
        XCTAssertTrue(toolbar.contains("CaptureAccessPoint.activeComposer"))
    }
}

private extension DesignSystemStagePrimitivesCanonicalOwnershipTests {
    func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/DesignSystem/StagePrimitives")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}

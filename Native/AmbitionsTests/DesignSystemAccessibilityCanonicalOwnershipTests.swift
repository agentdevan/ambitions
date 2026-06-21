@testable import Ambitions
import SwiftUI
import XCTest

final class DesignSystemAccessibilityCanonicalOwnershipTests: XCTestCase {
    func testCanonicalAccessibilityPolicyFilesExist() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/DesignSystem/Accessibility/AccessibilityLabelPolicy.swift",
            "Native/Ambitions/DesignSystem/Accessibility/VoiceOverFocusPolicy.swift",
            "Native/Ambitions/DesignSystem/Accessibility/DynamicTypePolicy.swift",
            "Native/Ambitions/DesignSystem/Accessibility/ReduceMotionPolicy.swift",
            "Native/Ambitions/DesignSystem/Accessibility/ReduceTransparencyPolicy.swift",
            "Native/Ambitions/DesignSystem/Accessibility/ContrastPolicy.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing canonical accessibility policy owner: \(requiredPath)"
            )
        }
    }

    func testRootComposerPolicyPreservesFocusMotionTransparencyAndContrastContracts() {
        let policy = AccessibilityLabelPolicy.rootComposer(
            label: "Capture",
            value: "Ready to Place",
            hint: "Saves locally with receipt proof."
        )

        XCTAssertTrue(policy.isCanonSafe)
        XCTAssertEqual(policy.focusPolicy.initialTarget, .composerInput)
        XCTAssertEqual(policy.focusPolicy.mutationTarget, .proofReceipt)
        XCTAssertEqual(policy.dynamicTypePolicy.layoutMode(for: .accessibility5), .singleColumn)
        XCTAssertEqual(policy.reduceMotionPolicy.mode(reduceMotion: true), .staticState)
        XCTAssertEqual(policy.reduceTransparencyPolicy.material(reduceTransparency: true), .solid)
        XCTAssertTrue(policy.contrastPolicy.passesInteractiveTextFloor)
    }

    func testPrimaryObjectPolicyKeepsObjectAndActionReachableAtAccessibilitySizes() {
        let policy = AccessibilityLabelPolicy.primaryObject(
            label: "Open Field",
            value: "Needs placement",
            hint: "Review the suggested route."
        )

        XCTAssertEqual(policy.focusPolicy.initialTarget, .primaryObject)
        XCTAssertEqual(policy.dynamicTypePolicy.layoutMode(for: .accessibility3), .stacked)
        XCTAssertGreaterThanOrEqual(policy.dynamicTypePolicy.minimumTapTarget, 44)
        XCTAssertEqual(policy.reduceMotionPolicy.mode(reduceMotion: false), .morph)
        XCTAssertEqual(policy.reduceMotionPolicy.mode(reduceMotion: true), .fade)
        XCTAssertTrue(policy.reduceTransparencyPolicy.keepsTrustSeamVisible)
        XCTAssertGreaterThanOrEqual(policy.contrastPolicy.minimumBodyContrastRatio, 7)
    }

    func testCaptureAccessibilityUsesCanonicalPolicyOwners() throws {
        let root = repoRoot()
        let source = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/Composer/Capture/CaptureAccessibility.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(source.contains("AccessibilityLabelPolicy.rootComposer"))
        XCTAssertTrue(source.contains("AccessibilityLabelPolicy.primaryObject"))
    }
}

private extension DesignSystemAccessibilityCanonicalOwnershipTests {
    func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/DesignSystem/Accessibility")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}

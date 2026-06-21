@testable import Ambitions
import XCTest

final class LanguageCanonicalOwnershipTests: XCTestCase {
    func testCanonicalLanguageOwnerFilesExist() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Language/UserFacingLanguage.swift",
            "Native/Ambitions/Language/RuntimeVocabulary.swift",
            "Native/Ambitions/Language/SurfaceCopyPolicy.swift",
            "Native/Ambitions/Language/ForbiddenTopLevelTerms.swift",
            "Native/Ambitions/Language/CopyBudget.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing canonical Language owner: \(requiredPath)"
            )
        }
    }

    func testUserFacingLanguageOwnsPersistentSurfaceAndActionCopy() {
        XCTAssertEqual(UserFacingLanguage.persistentSurfaces, ["Today", "Goals", "Time", "You"])
        XCTAssertEqual(ProductCopy.Today.startHere, UserFacingLanguage.Action.startHere)
        XCTAssertEqual(ProductCopy.Today.recommendedStep, UserFacingLanguage.Action.recommendedStep)
        XCTAssertEqual(ProductCopy.Goals.objectTitle, UserFacingLanguage.Object.constellationAtlas)
        XCTAssertEqual(RuntimeVocabulary.canonicalRootSurfaceSet, Set(["Today", "Goals", "Time", "You"]))
    }

    func testSurfaceCopyPolicyRejectsRemovedRootCanonAndOversizedCopy() {
        XCTAssertEqual(
            SurfaceCopyPolicy.validateRootSurfaceCopy(
                surfaceName: "Today",
                title: "Open the Plan tab",
                detail: "A short line"
            ),
            [.forbiddenTerm("Plan tab")]
        )

        let violations = SurfaceCopyPolicy.validateRootSurfaceCopy(
            surfaceName: "Motion",
            title: String(repeating: "A", count: CopyBudget.title.maximumCharacters + 1),
            detail: String(repeating: "B", count: CopyBudget.detail.maximumCharacters + 1)
        )

        XCTAssertTrue(violations.contains(.unknownRootSurface("Motion")))
        XCTAssertTrue(violations.contains(.titleTooLong(49)))
        XCTAssertTrue(violations.contains(.detailTooLong(161)))
    }

    func testForbiddenLanguageAuditRoutesThroughSurfaceCopyPolicy() {
        XCTAssertEqual(ForbiddenLanguageAudit.violation(in: "Show the Motion tab"), "Motion tab")
        XCTAssertNil(ForbiddenLanguageAudit.violation(in: "Open Time and review the LifeShape Field."))
    }
}

private extension LanguageCanonicalOwnershipTests {
    func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Language")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}

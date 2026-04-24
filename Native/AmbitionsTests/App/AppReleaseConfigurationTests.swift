import XCTest

final class AppReleaseConfigurationTests: XCTestCase {
    func testLaunchBuildAdvertisesIPhoneOnlyPortraitOnlyScope() throws {
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()

        let infoURL = repoRoot.appendingPathComponent("Native/Ambitions/Support/Info.plist")
        let infoData = try Data(contentsOf: infoURL)
        let info = try XCTUnwrap(
            PropertyListSerialization.propertyList(from: infoData, options: [], format: nil) as? [String: Any]
        )
        let orientations = try XCTUnwrap(info["UISupportedInterfaceOrientations"] as? [String])
        XCTAssertEqual(orientations, ["UIInterfaceOrientationPortrait"])
        XCTAssertNil(info["UISupportedInterfaceOrientations~ipad"])

        let projectYML = try String(contentsOf: repoRoot.appendingPathComponent("project.yml"), encoding: .utf8)
        XCTAssertTrue(projectYML.contains("TARGETED_DEVICE_FAMILY: \"1\""))
        XCTAssertFalse(projectYML.contains("TARGETED_DEVICE_FAMILY: \"1,2\""))
    }
}

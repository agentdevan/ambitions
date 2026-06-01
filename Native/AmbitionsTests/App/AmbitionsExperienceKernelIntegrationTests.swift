import XCTest
@testable import Ambitions

final class AmbitionsExperienceKernelIntegrationTests: XCTestCase {
    func testRealAppTargetCanSeeExperienceKernelPackage() {
        XCTAssertEqual(AmbitionsExperienceKernelIntegration.packageProductName, "AmbitionsExperienceKernel")
        XCTAssertEqual(AmbitionsExperienceKernelIntegration.canonicalSurfaceCount, 5)
        XCTAssertEqual(AmbitionsExperienceKernelIntegration.todayPrimaryObjectName, "realityMeridian")
    }
}

import Foundation

enum VisualRegressionHarness {
    static let screenshotCommand = "scripts/ambitions-run-ui-screenshot-matrix.sh"
    static let requiredReview = "Screenshot paths are not proof until visually reviewed."
    static let realDeviceChecklist = RealDeviceRenderChecklist.items
}

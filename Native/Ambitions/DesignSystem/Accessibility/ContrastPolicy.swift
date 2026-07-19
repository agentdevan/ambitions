import Foundation

struct ContrastPolicy: Equatable, Sendable {
    let minimumBodyContrastRatio: Double
    let minimumLargeTextContrastRatio: Double
    let usesShapeBeyondColor: Bool
    let keepsProofLabelsVisible: Bool

    var passesInteractiveTextFloor: Bool {
        minimumBodyContrastRatio >= 4.5 && usesShapeBeyondColor && keepsProofLabelsVisible
    }

    static let rootSurface = ContrastPolicy(
        minimumBodyContrastRatio: 4.5,
        minimumLargeTextContrastRatio: 3,
        usesShapeBeyondColor: true,
        keepsProofLabelsVisible: true
    )

    static let primaryObject = ContrastPolicy(
        minimumBodyContrastRatio: 7,
        minimumLargeTextContrastRatio: 4.5,
        usesShapeBeyondColor: true,
        keepsProofLabelsVisible: true
    )
}

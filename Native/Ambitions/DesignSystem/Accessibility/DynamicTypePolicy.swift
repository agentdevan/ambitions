import SwiftUI

struct DynamicTypePolicy: Equatable, Sendable {
    enum LayoutMode: String, Equatable, Sendable {
        case inline
        case stacked
        case singleColumn
    }

    let maximumUsefulSize: DynamicTypeSize
    let preservesPrimaryAction: Bool
    let layoutModeAtAccessibilitySize: LayoutMode
    let minimumTapTarget: Double

    func layoutMode(for size: DynamicTypeSize) -> LayoutMode {
        size.isAccessibilitySize ? layoutModeAtAccessibilitySize : .inline
    }

    static let surfaceDefault = DynamicTypePolicy(
        maximumUsefulSize: .accessibility5,
        preservesPrimaryAction: true,
        layoutModeAtAccessibilitySize: .singleColumn,
        minimumTapTarget: 44
    )

    static let primaryObject = DynamicTypePolicy(
        maximumUsefulSize: .accessibility5,
        preservesPrimaryAction: true,
        layoutModeAtAccessibilitySize: .stacked,
        minimumTapTarget: 48
    )
}

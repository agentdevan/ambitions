import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public enum FlagshipSpacing {
    public static let compact: CGFloat = 8
    public static let standard: CGFloat = 16
    public static let generous: CGFloat = 24
}

public enum FlagshipShape {
    public static let controlRadius: CGFloat = 12
    public static let containerRadius: CGFloat = 20
}

public enum FlagshipSemanticColor {
#if canImport(UIKit)
    public static let canvas = Color(uiColor: .systemBackground)
    public static let elevated = Color(uiColor: .secondarySystemBackground)
#else
    public static let canvas = Color(nsColor: .windowBackgroundColor)
    public static let elevated = Color(nsColor: .underPageBackgroundColor)
#endif
    public static let primaryText = Color.primary
    public static let secondaryText = Color.secondary
    public static let action = Color.accentColor
}

public struct FlagshipMinimumTargetModifier: ViewModifier {
    public init() {}

    public func body(content: Content) -> some View {
        content.frame(minWidth: 44, minHeight: 44)
    }
}

public extension View {
    func flagshipMinimumTarget() -> some View {
        modifier(FlagshipMinimumTargetModifier())
    }
}

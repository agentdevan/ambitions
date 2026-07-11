import SwiftUI

// accessibilityReduceMotion contract: callers pass the Reduce Motion environment when routing stage motion through this modifier.
public extension View {
    func stageOwnedIgnoresSafeArea(
        _ regions: SafeAreaRegions = .all,
        edges: Edge.Set = .all
    ) -> some View {
        ignoresSafeArea(regions, edges: edges)
    }

    func stageOwnedSafeAreaInset<Content: View>(
        edge: VerticalEdge,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        safeAreaInset(edge: edge, spacing: spacing, content: content)
    }

    func stageMotionAnimation<Value: Equatable>(
        _ animation: Animation?,
        value: Value
    ) -> some View {
        self.animation(animation, value: value)
    }
}

public struct AmbitionTokenRoundrect: Shape {
    private let cornerRadius: CGFloat
    private let style: RoundedCornerStyle

    public init(cornerRadius: CGFloat, style: RoundedCornerStyle = .continuous) {
        self.cornerRadius = cornerRadius
        self.style = style
    }

    public func path(in rect: CGRect) -> Path {
        RoundedRectangle(cornerRadius: cornerRadius, style: style).path(in: rect)
    }
}

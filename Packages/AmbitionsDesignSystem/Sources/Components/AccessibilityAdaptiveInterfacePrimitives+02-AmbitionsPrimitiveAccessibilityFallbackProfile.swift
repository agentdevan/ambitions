#if canImport(SwiftUI)
import SwiftUI

public struct AmbitionsPrimitiveAccessibilityFallbackProfile: Identifiable, Hashable, Sendable {
    public static let requiredAxes: Set<AmbitionsPrimitiveAccessibilityFallbackAxis> = [
        .dynamicType,
        .reduceMotion,
        .reduceTransparency,
        .increaseContrast
    ]

    public let primitiveID: String
    public let owningSurface: AmbitionsPrimaryObjectSurface
    public let productObject: String
    public let runtimeInspectionBoundary: String
    public let behaviors: [AmbitionsPrimitiveAccessibilityFallbackBehavior]

    public var id: String { primitiveID }

    public init(
        primitiveID: String,
        owningSurface: AmbitionsPrimaryObjectSurface,
        productObject: String,
        runtimeInspectionBoundary: String,
        behaviors: [AmbitionsPrimitiveAccessibilityFallbackBehavior]
    ) {
        self.primitiveID = primitiveID
        self.owningSurface = owningSurface
        self.productObject = productObject
        self.runtimeInspectionBoundary = runtimeInspectionBoundary
        self.behaviors = behaviors
    }

    public static func contract(
        primitiveID: String,
        owningSurface: AmbitionsPrimaryObjectSurface,
        productObject: String,
        dynamicTypeFallback: String,
        reduceMotionFallback: String,
        reduceTransparencyFallback: String,
        increaseContrastFallback: String
    ) -> AmbitionsPrimitiveAccessibilityFallbackProfile {
        AmbitionsPrimitiveAccessibilityFallbackProfile(
            primitiveID: primitiveID,
            owningSurface: owningSurface,
            productObject: productObject,
            runtimeInspectionBoundary: "Owner surfaces provide source, receipt, and reason inspection labels; this fallback contract changes presentation only.",
            behaviors: [
                AmbitionsPrimitiveAccessibilityFallbackBehavior(
                    axis: .dynamicType,
                    visibleFallback: dynamicTypeFallback,
                    evidenceSummary: "Text can wrap or stack while preserving the primary object, source, and action order.",
                    manualProofStillRequired: "Accessibility-size rendered review remains required before public claims."
                ),
                AmbitionsPrimitiveAccessibilityFallbackBehavior(
                    axis: .reduceMotion,
                    visibleFallback: reduceMotionFallback,
                    evidenceSummary: "Motion emphasis is replaced by static state labels and preserved action affordances.",
                    manualProofStillRequired: "Reduce Motion walkthrough remains required before public claims."
                ),
                AmbitionsPrimitiveAccessibilityFallbackBehavior(
                    axis: .reduceTransparency,
                    visibleFallback: reduceTransparencyFallback,
                    evidenceSummary: "Material translucency can flatten into an opaque semantic surface without hiding state.",
                    manualProofStillRequired: "Reduce Transparency screenshot review remains required before public claims."
                ),
                AmbitionsPrimitiveAccessibilityFallbackBehavior(
                    axis: .increaseContrast,
                    visibleFallback: increaseContrastFallback,
                    evidenceSummary: "Contrast relies on symbol, text, and border semantics rather than color-only meaning.",
                    manualProofStillRequired: "Increase Contrast visual review remains required before public claims."
                )
            ]
        )
    }

    public static let sourceTrustStrip = AmbitionsPrimitiveAccessibilityFallbackProfile.contract(
        primitiveID: "source-trust-strip",
        owningSurface: .today,
        productObject: "Source / Trust / Receipt strip",
        dynamicTypeFallback: "Stack source, freshness, trust, and receipt items vertically at accessibility text sizes.",
        reduceMotionFallback: "Keep the strip static; no animated state transition is required to understand source or receipt status.",
        reduceTransparencyFallback: "Use an opaque semantic fill behind each item when transparency is reduced.",
        increaseContrastFallback: "Strengthen the item border and preserve role labels beside symbols."
    )

    public var recordedAxes: Set<AmbitionsPrimitiveAccessibilityFallbackAxis> {
        Set(behaviors.map(\.axis))
    }

    public var recordsRequiredBehaviors: Bool {
        Self.requiredAxes.isSubset(of: recordedAxes)
    }

    public var publicClaimAllowed: Bool { false }
    public var changesRuntimeBehavior: Bool { false }

    public func behavior(for axis: AmbitionsPrimitiveAccessibilityFallbackAxis) -> AmbitionsPrimitiveAccessibilityFallbackBehavior {
        behaviors.first(where: { $0.axis == axis }) ?? AmbitionsPrimitiveAccessibilityFallbackBehavior(
            axis: axis,
            visibleFallback: "Fallback missing.",
            evidenceSummary: "Fallback missing.",
            manualProofStillRequired: "Manual review required."
        )
    }

    public var accessibilitySummary: String {
        let axisSummary = behaviors.map { "\($0.axis.title): \($0.visibleFallback)" }.joined(separator: " ")
        return "\(primitiveID). \(productObject). \(owningSurface.objectTitle). \(runtimeInspectionBoundary) \(axisSummary)"
    }
}

public struct AmbitionsPrimitiveAccessibilityFallbackModifier: ViewModifier {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    let profile: AmbitionsPrimitiveAccessibilityFallbackProfile

    public init(profile: AmbitionsPrimitiveAccessibilityFallbackProfile) {
        self.profile = profile
    }

    public func body(content: Content) -> some View {
        content
            .padding(dynamicTypeSize.isAccessibilitySize ? theme.spacing.xxs : 0)
            .transaction { transaction in
                if reduceMotion {
                    transaction.animation = nil
                }
            }
            .background {
                if reduceTransparency {
                    RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                        .fill(AmbitionPrimitiveSemanticToken.accessibilityFallbackSurface.color(in: theme))
                }
            }
            .overlay {
                if colorSchemeContrast == .increased {
                    RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                        .stroke(AmbitionPrimitiveSemanticToken.accessibilityContrastStroke.color(in: theme).opacity(0.58), lineWidth: 1)
                }
            }
            .accessibilityHint(Text(activeAccessibilityHint))
    }

    var activeAccessibilityHint: String {
        var hints: [String] = []

        if dynamicTypeSize.isAccessibilitySize {
            hints.append(profile.behavior(for: .dynamicType).visibleFallback)
        }
        if reduceMotion {
            hints.append(profile.behavior(for: .reduceMotion).visibleFallback)
        }
        if reduceTransparency {
            hints.append(profile.behavior(for: .reduceTransparency).visibleFallback)
        }
        if colorSchemeContrast == .increased {
            hints.append(profile.behavior(for: .increaseContrast).visibleFallback)
        }

        return hints.isEmpty ? profile.accessibilitySummary : hints.joined(separator: " ")
    }
}

public extension View {
    func ambitionsPrimitiveAccessibilityFallback(
        _ profile: AmbitionsPrimitiveAccessibilityFallbackProfile
    ) -> some View {
        modifier(AmbitionsPrimitiveAccessibilityFallbackModifier(profile: profile))
    }
}
#endif

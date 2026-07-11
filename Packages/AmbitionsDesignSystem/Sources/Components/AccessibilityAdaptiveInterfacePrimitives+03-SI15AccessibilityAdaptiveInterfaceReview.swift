#if canImport(SwiftUI)
import SwiftUI

public enum SI15AccessibilityAdaptiveInterfaceReview {
    public static let ownerBatch = "SI15"
    public static let releaseClaimsAllowed = false
    public static let runtimeBehaviorChanged = false

    public static let sourceFiles: [String] = [
        "Packages/AmbitionsDesignSystem/Sources/Components/AccessibilityAdaptiveInterfacePrimitives.swift",
        "Packages/AmbitionsDesignSystem/Sources/Components/LoadingDegradedStatePrimitives.swift",
        "Packages/AmbitionsDesignSystem/Sources/Components/IconographyStatusPrimitives.swift",
        "Packages/AmbitionsDesignSystem/Sources/Previews/AccessibilityAdaptiveInterfacePreviews.swift",
        "Native/AmbitionsTests/App/AccessibilityAdaptiveInterfaceDesignSystemTests.swift"
    ]

    public static let requirements: [AmbitionsAdaptiveRequirement] = {
        AmbitionsAdaptiveReviewLane.allCases.flatMap { lane in
            AmbitionsAdaptiveAxis.allCases.map { axis in
                AmbitionsAdaptiveRequirement(
                    lane: lane,
                    axis: axis,
                    visibleFallback: visibleFallback(for: axis, lane: lane),
                    voiceOverSummary: voiceOverSummary(for: axis, lane: lane),
                    responsibilityScope: responsibilityScope(for: axis),
                    responsibilitySummary: responsibilitySummary(for: axis),
                    reduceMotionEquivalent: lane.loadingState.reduceMotionEquivalent,
                    manualProofStillRequired: manualProof(for: axis),
                    staticMotionMeaning: staticMotionMeaning(for: axis),
                    hitAreaStrategy: hitAreaStrategy(for: axis),
                    contrastTransparencyStrategy: contrastTransparencyStrategy(for: axis)
                )
            }
        }
    }()

    public static let primaryObjectAccessibilitySummaries: [AmbitionsPrimaryObjectAccessibilitySummary] = [
        AmbitionsPrimaryObjectAccessibilitySummary(
            surface: .today,
            activeObjectSummary: "Keep decision-first nonvisual clarity for the top recommendation and next recommended step.",
            dynamicTypeStrategy: "Preserve decision and action order at large sizes; secondary atmosphere details may collapse to short summaries.",
            staticMotionEquivalent: "Replace animated urgency cues with text-first status + explicit `Start now` path.",
            expandedHitAreaStrategy: "Primary lane and controls are full-width touch targets with 48pt minimum and spacing between secondary controls.",
            contrastTransparencyStrategy: "Status symbolism stays readable in high-contrast and low-opacity reductions; sensitive context is hidden behind summary-first copy."
        ),
        AmbitionsPrimaryObjectAccessibilitySummary(
            surface: .goals,
            activeObjectSummary: "Expose mission progress through text, evidence labels, and ordered receipt lines before decorative field movement.",
            dynamicTypeStrategy: "Prioritize title, status, and recommendation line; compress constellation metadata into a readable digest.",
            staticMotionEquivalent: "Replace subtle pulse or drift visuals with anchored text states and static phase tags.",
            expandedHitAreaStrategy: "Goal-level card opens are converted to list-item sized action controls with large vertical spacing.",
            contrastTransparencyStrategy: "Differentiate goal states through symbols + copy; avoid color-only distinctions and opacity-only focus markers."
        ),
        AmbitionsPrimaryObjectAccessibilitySummary(
            surface: .time,
            activeObjectSummary: "Represent availability and capacity through structured text before texture-like motion visuals.",
            dynamicTypeStrategy: "Preserve schedule intent with compact rows; reduce decorative LifeShape density at accessibility sizes.",
            staticMotionEquivalent: "Freeze temporal motion textures and keep the same sequence as an ordered text timeline.",
            expandedHitAreaStrategy: "Protect repeated window chips with a single expanded control for each period and explicit boundary labels.",
            contrastTransparencyStrategy: "Use explicit labels for protected, available, and occupied context when contrast or transparency changes."
        ),
        AmbitionsPrimaryObjectAccessibilitySummary(
            surface: .motion,
            activeObjectSummary: "Communicate proof and progress through concise state labels; avoid analytics-like graphs as primary comprehension.",
            dynamicTypeStrategy: "Keep proof path and closure status visible first; trim repeated progress ornaments if text wraps.",
            staticMotionEquivalent: "Translate trace-like progress into ordered bullet-like progression text and explicit completion receipts.",
            expandedHitAreaStrategy: "Increase touch area for small proof markers and repeated control clusters with grouped row controls.",
            contrastTransparencyStrategy: "Use textual proof markers and role semantics when color and transparency are restricted."
        ),
        AmbitionsPrimaryObjectAccessibilitySummary(
            surface: .you,
            activeObjectSummary: "Prioritize trust and governance settings with clear section names and inspectable profile-state text.",
            dynamicTypeStrategy: "Maintain grouped section hierarchy in type scaling; collapse long governance explanations to short summaries.",
            staticMotionEquivalent: "Remove motion emphasis and keep toggle and state changes with static section transitions.",
            expandedHitAreaStrategy: "Keep sensitive toggles and recovery controls to touch targets with clear primary affordances.",
            contrastTransparencyStrategy: "Surface profile boundaries through text and icons when contrast and transparency are reduced."
        ),
        AmbitionsPrimaryObjectAccessibilitySummary(
            surface: .capture,
            activeObjectSummary: "Expose composer intent and action result through clear summary text, without treating Capture as a tab.",
            dynamicTypeStrategy: "Keep contextual composer entry + primary action visible; collapse ornamental atmosphere details first.",
            staticMotionEquivalent: "Static preview text confirms capture state and safety rails when motion is reduced.",
            expandedHitAreaStrategy: "Primary composer entry and submit/undo actions receive expanded hit regions and redundant labels.",
            contrastTransparencyStrategy: "Ensure capture safety cues remain in plain language for users with reduced color and reduced opacity."
        )
    ]

    public static func requirements(for lane: AmbitionsAdaptiveReviewLane) -> [AmbitionsAdaptiveRequirement] {
        requirements.filter { $0.lane == lane }
    }

    public static func requirement(for surface: AmbitionsPrimaryObjectSurface) -> AmbitionsPrimaryObjectAccessibilitySummary {
        guard
            let summary = primaryObjectAccessibilitySummaries.first(where: { $0.surface == surface })
        else {
            return AmbitionsPrimaryObjectAccessibilitySummary(
                surface: .today,
                activeObjectSummary: "Review pending.",
                dynamicTypeStrategy: "Review pending.",
                staticMotionEquivalent: "Review pending.",
                expandedHitAreaStrategy: "Review pending.",
                contrastTransparencyStrategy: "Review pending."
            )
        }

        return summary
    }

    static func visibleFallback(
        for axis: AmbitionsAdaptiveAxis,
        lane: AmbitionsAdaptiveReviewLane
    ) -> String {
        switch axis {
        case .dynamicType:
            return "\(lane.cognitiveLoadMode.title) density keeps the main decision visible at accessibility text sizes."
        case .voiceOver:
            return "\(lane.statusRole.title) is paired with a visible label and ordered before supporting detail."
        case .reduceMotion:
            return "Static status, label, and next action replace motion for \(lane.title)."
        case .nonColorMeaning:
            return "\(lane.statusRole.symbolName) and \(lane.statusRole.title) carry meaning without color."
        case .tapTarget:
            return "Primary review or recovery action remains a full-width native target."
        case .privacySafeExposure:
            return "Sensitive detail uses summary language before any private content is shown."
        case .cognitiveLoad:
            return "\(lane.cognitiveLoadMode.purposeLabel)"
        }
    }

    static func voiceOverSummary(
        for axis: AmbitionsAdaptiveAxis,
        lane: AmbitionsAdaptiveReviewLane
    ) -> String {
        "\(ownerBatch). \(lane.title). \(axis.title). \(lane.statusRole.accessibilityLabel)"
    }

    static func responsibilityScope(for axis: AmbitionsAdaptiveAxis) -> AmbitionsAccessibilityResponsibilityScope {
        switch axis {
        case .dynamicType, .voiceOver:
            return .globalHelper
        case .reduceMotion, .nonColorMeaning, .tapTarget:
            return .primitiveResponsibility
        case .privacySafeExposure, .cognitiveLoad:
            return .surfaceSpecific
        }
    }

    static func responsibilitySummary(for axis: AmbitionsAdaptiveAxis) -> String {
        responsibilityScope(for: axis).summary
    }

    static func manualProof(for axis: AmbitionsAdaptiveAxis) -> String {
        switch axis {
        case .dynamicType:
            return "Rendered accessibility-size screenshots are still required before public claims."
        case .voiceOver:
            return "Manual VoiceOver traversal is still required before public claims."
        case .reduceMotion:
            return "A toggled Reduce Motion walkthrough is still required before public claims."
        case .nonColorMeaning:
            return "Human contrast and non-color review are still required before public claims."
        case .tapTarget:
            return "Manual tap-target and motor review are still required before public claims."
        case .privacySafeExposure:
            return "Human privacy review is still required before public claims."
        case .cognitiveLoad:
            return "Human cognitive-load review is still required before public claims."
        }
    }

    static func staticMotionMeaning(for axis: AmbitionsAdaptiveAxis) -> String {
        switch axis {
        case .dynamicType:
            return "Primary labels remain fixed in sequence while text scales."
        case .voiceOver:
            return "Focus order and spoken summary remain deterministic."
        case .reduceMotion:
            return "Motion-based emphasis is replaced by static state labels and receipt text."
        case .nonColorMeaning:
            return "Symbol + role text describe meaning without color movement."
        case .tapTarget:
            return "Action boundaries stay obvious without gesture animation cues."
        case .privacySafeExposure:
            return "Private content exposure is explained via explicit consent copy."
        case .cognitiveLoad:
            return "No new motion or timing rhythm changes; state transitions remain straightforward."
        }
    }

    static func hitAreaStrategy(for axis: AmbitionsAdaptiveAxis) -> String {
        switch axis {
        case .dynamicType:
            return "Row spacing and target height scale to keep actions touchable after text grows."
        case .voiceOver:
            return "Accessible controls remain single-focus and grouped by primary object."
        case .reduceMotion:
            return "Tap targets stay explicit for each required action in static mode."
        case .nonColorMeaning:
            return "Control labels and symbols stay padded to avoid precision taps."
        case .tapTarget:
            return "Guarantee 48pt minimum target for repeated controls and traces."
        case .privacySafeExposure:
            return "Primary consent control keeps a full-width touch target."
        case .cognitiveLoad:
            return "Motor path stays minimal with one primary action and one safe secondary action."
        }
    }

    static func contrastTransparencyStrategy(for axis: AmbitionsAdaptiveAxis) -> String {
        switch axis {
        case .dynamicType:
            return "Use type and spacing adjustments over opacity-based hierarchy."
        case .voiceOver:
            return "Text and symbol semantics survive when contrast/transparency shifts."
        case .reduceMotion:
            return "No reliance on opacity shimmer; states remain text-first and semantic."
        case .nonColorMeaning:
            return "Symbol names plus captions remain the meaning source, not color."
        case .tapTarget:
            return "Avoid transparency-only selection marks."
        case .privacySafeExposure:
            return "Safe/unsafe states are explicit strings with contrast-safe borders."
        case .cognitiveLoad:
            return "Important status remains readable with stronger text role hierarchy."
        }
    }
}

public struct AmbitionsAdaptiveRequirementRow: View {
    @Environment(\.ambitionTheme) private var theme

    let requirement: AmbitionsAdaptiveRequirement

    public init(_ requirement: AmbitionsAdaptiveRequirement) {
        self.requirement = requirement
    }

    public var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            AmbitionsStatusSymbol(requirement.statusRole, style: .inline)

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(requirement.axis.title)
                    .font(theme.typography.bodySecondary)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(nil)

                Text(requirement.responsibilitySummary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)

                Text(requirement.visibleFallback)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(nil)
            }

            Spacer(minLength: theme.spacing.sm)
        }
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay.opacity(0.72))
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(requirement.voiceOverSummary)
        .accessibilityValue("Manual proof required. \(requirement.manualProofStillRequired)")
        .accessibilityIdentifier("si15.adaptive.requirement.\(requirement.id)")
    }
}
#endif

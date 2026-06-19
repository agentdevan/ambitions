#if canImport(SwiftUI)
import SwiftUI

public struct AmbitionSemanticCompilerOutput: Equatable, Sendable {
    public let input: AmbitionSemanticCompilerInput
    public let typographyRole: AmbitionSemanticTypographyRole
    public let visualState: AmbitionSemanticState
    public let colorTokenName: String
    public let materialRole: AmbitionSemanticMaterialRole
    public let symbolName: String
    public let motionToken: AmbitionInteractionToken
    public let reducedMotionEquivalent: String
    public let nonColorCues: [String]
    public let hapticPolicy: AmbitionHapticPolicy
    public let causalityContext: AmbitionSemanticCausalityContext?

    public init(
        input: AmbitionSemanticCompilerInput,
        typographyRole: AmbitionSemanticTypographyRole,
        visualState: AmbitionSemanticState,
        colorTokenName: String,
        materialRole: AmbitionSemanticMaterialRole,
        symbolName: String,
        motionToken: AmbitionInteractionToken,
        reducedMotionEquivalent: String,
        nonColorCues: [String],
        hapticPolicy: AmbitionHapticPolicy,
        causalityContext: AmbitionSemanticCausalityContext? = nil
    ) {
        self.input = input
        self.typographyRole = typographyRole
        self.visualState = visualState
        self.colorTokenName = colorTokenName
        self.materialRole = materialRole
        self.symbolName = symbolName
        self.motionToken = motionToken
        self.reducedMotionEquivalent = reducedMotionEquivalent
        self.nonColorCues = nonColorCues
        self.hapticPolicy = hapticPolicy
        self.causalityContext = causalityContext
    }

    public var accessibilitySummary: String {
        let cueSummary = nonColorCues.joined(separator: ", ")
        let provenanceSummary = causalityContext?.inspectionSummary ?? "No runtime provenance referenced."
        return "\(input.rawValue). Typography: \(typographyRole.tokenName). Visual state: \(visualState.label). Color token: \(colorTokenName). Material role: \(materialRole.tokenName). Symbol: \(symbolName). Reduce Motion: \(reducedMotionEquivalent). Non-color cues: \(cueSummary). \(provenanceSummary)"
    }

    public var hapticBoundary: String {
        switch hapticPolicy.intent {
        case .none:
            return "Haptics remain silent and visible meaning carries the state."
        case .some(.selection):
            return "Haptics reinforce a deliberate choice and never replace the visible state."
        case .some(.completion):
            return "Haptics reinforce a completed user action and never replace the receipt or proof surface."
        case .some(.correction):
            return "Haptics reinforce a user correction and never imply praise or penalty."
        case .some(.reschedule):
            return "Haptics reinforce a user-initiated timing change and never become the only signal."
        case .some(.routeChange):
            return "Haptics reinforce a user-initiated route change and never replace orientation text."
        case .some(.warning):
            return "Haptics stay secondary to the visible boundary copy."
        }
    }
}

public enum AmbitionSemanticCompiler {
    public static func compile(
        _ input: AmbitionSemanticCompilerInput,
        causalityContext: AmbitionSemanticCausalityContext? = nil
    ) -> AmbitionSemanticCompilerOutput {
        switch input {
        case .startHereRecommendation:
            return AmbitionSemanticCompilerOutput(
                input: input,
                typographyRole: .heroDisplay,
                visualState: .focus,
                colorTokenName: "semanticColors.focus",
                materialRole: .hero,
                symbolName: "sparkles",
                motionToken: .panelReveal,
                reducedMotionEquivalent: "Static recommendation card, selected label, and because line.",
                nonColorCues: ["recommendation label", "because line", "selected action"],
                hapticPolicy: .none,
                causalityContext: causalityContext
            )
        case .routeOrientation:
            return AmbitionSemanticCompilerOutput(
                input: input,
                typographyRole: .title,
                visualState: .focus,
                colorTokenName: "semanticColors.focus",
                materialRole: .band,
                symbolName: "arrow.triangle.branch",
                motionToken: .routeOrientation,
                reducedMotionEquivalent: "Immediate destination title, preserved back path, and selected row label.",
                nonColorCues: ["route label", "selected destination", "back path preserved"],
                hapticPolicy: .userInitiated(.routeChange),
                causalityContext: causalityContext
            )
        case .proofReceipt:
            return AmbitionSemanticCompilerOutput(
                input: input,
                typographyRole: .sectionTitle,
                visualState: .success,
                colorTokenName: "colors.success",
                materialRole: .elevated,
                symbolName: "checkmark.seal.fill",
                motionToken: .proofConfirm,
                reducedMotionEquivalent: "Static receipt or proof label with source and undo or correction text.",
                nonColorCues: ["receipt title", "source label", "undo or correction path"],
                hapticPolicy: .userInitiated(.completion),
                causalityContext: causalityContext
            )
        case .sourceFreshness:
            return AmbitionSemanticCompilerOutput(
                input: input,
                typographyRole: .bodySecondary,
                visualState: .review,
                colorTokenName: "semanticColors.review",
                materialRole: .overlay,
                symbolName: "doc.text.magnifyingglass",
                motionToken: .sourceCheck,
                reducedMotionEquivalent: "Static source-state label before any commitment can move.",
                nonColorCues: ["source state label", "freshness copy", "review affordance"],
                hapticPolicy: .none,
                causalityContext: causalityContext
            )
        case .captureDraft:
            return AmbitionSemanticCompilerOutput(
                input: input,
                typographyRole: .bodyPrimary,
                visualState: .capture,
                colorTokenName: "semanticColors.capture",
                materialRole: .widget,
                symbolName: "tray.and.arrow.down.fill",
                motionToken: .panelReveal,
                reducedMotionEquivalent: "Instant capture context with unchanged hierarchy and draft state.",
                nonColorCues: ["text field focus", "draft state", "placement after content"],
                hapticPolicy: .none,
                causalityContext: causalityContext
            )
        case .lifeShapeReview:
            return AmbitionSemanticCompilerOutput(
                input: input,
                typographyRole: .titleCompact,
                visualState: .calendarDerived,
                colorTokenName: "semanticColors.calendarDerived",
                materialRole: .quietGlass,
                symbolName: "calendar.badge.clock",
                motionToken: .reviewRequired,
                reducedMotionEquivalent: "Static capacity and pressure label with review-needed action.",
                nonColorCues: ["capacity label", "pressure text", "review-needed action"],
                hapticPolicy: .none,
                causalityContext: causalityContext
            )
        case .recoveryClosure:
            return AmbitionSemanticCompilerOutput(
                input: input,
                typographyRole: .bodyEmphasized,
                visualState: .recovery,
                colorTokenName: "semanticColors.recovery",
                materialRole: .success,
                symbolName: "arrow.uturn.backward.circle.fill",
                motionToken: .correctionNeeded,
                reducedMotionEquivalent: "Static recovery label and next action without shake or reward motion.",
                nonColorCues: ["recovery label", "next action", "reversible choice"],
                hapticPolicy: .userInitiated(.correction),
                causalityContext: causalityContext
            )
        case .privacyBoundary:
            return AmbitionSemanticCompilerOutput(
                input: input,
                typographyRole: .caption,
                visualState: .protected,
                colorTokenName: "semanticColors.protected",
                materialRole: .graphiteRecess,
                symbolName: "lock.shield.fill",
                motionToken: .privacyBoundary,
                reducedMotionEquivalent: "Static privacy label with no private-detail reveal.",
                nonColorCues: ["private item", "boundary copy", "no detail reveal"],
                hapticPolicy: .none,
                causalityContext: causalityContext
            )
        case .unsafeRedirect:
            return AmbitionSemanticCompilerOutput(
                input: input,
                typographyRole: .caption,
                visualState: .risk,
                colorTokenName: "semanticColors.risk",
                materialRole: .warning,
                symbolName: "exclamationmark.triangle.fill",
                motionToken: .unsafeRedirect,
                reducedMotionEquivalent: "Static safety redirect label and professional-boundary copy.",
                nonColorCues: ["safety boundary", "alternate action", "professional copy"],
                hapticPolicy: .none,
                causalityContext: causalityContext
            )
        case .localOnlySettle:
            return AmbitionSemanticCompilerOutput(
                input: input,
                typographyRole: .micro,
                visualState: .protected,
                colorTokenName: "semanticColors.protected",
                materialRole: .canvas,
                symbolName: "lock.fill",
                motionToken: .localOnlySettle,
                reducedMotionEquivalent: "Static local-only label and unchanged data-boundary text.",
                nonColorCues: ["local-only label", "data boundary", "no remote claim"],
                hapticPolicy: .none,
                causalityContext: causalityContext
            )
        }
    }
}

public enum AmbitionFlagshipMotionObject: String, CaseIterable, Sendable {
    case startHere
    case realityMeridian
    case receiptDrawer
    case sourceFold
    case missionControlTimeSpine
    case actionClosureDiamond
    case lifeShapeField
    case captureComposer

    public var motionPolicy: AmbitionObjectMotionPolicy {
        switch self {
        case .startHere:
            return AmbitionObjectMotionPolicy(
                objectTitle: "Start Here",
                owner: "Today",
                motionToken: .selectionConfirm,
                stateMeaning: "The recommended starting point became selected by the user.",
                nonMotionCues: ["selected label", "because line", "time fit proof"],
                hapticBoundary: "Selection haptic only after a user chooses Start Here."
            )
        case .realityMeridian:
            return AmbitionObjectMotionPolicy(
                objectTitle: "Reality Meridian",
                owner: "Today",
                motionToken: .routeOrientation,
                stateMeaning: "The day rail advanced to a visible execution position.",
                nonMotionCues: ["rail position", "Now/Next/Later text", "selected value"],
                hapticBoundary: "Route haptic only when the user changes orientation."
            )
        case .receiptDrawer:
            return AmbitionObjectMotionPolicy(
                objectTitle: "Receipt Drawer",
                owner: "Shared trust",
                motionToken: .proofConfirm,
                stateMeaning: "A receipt, consequence, or reversibility state settled.",
                nonMotionCues: ["receipt title", "source label", "undo or correction affordance"],
                hapticBoundary: "Confirmation haptic only when a user closes or saves a receipt."
            )
        case .sourceFold:
            return AmbitionObjectMotionPolicy(
                objectTitle: "Source Fold",
                owner: "Shared trust",
                motionToken: .sourceCheck,
                stateMeaning: "Freshness, conflict, or review boundaries became visible.",
                nonMotionCues: ["source state label", "review affordance", "freshness copy"],
                hapticBoundary: "No haptic; source state is review context, not a reward."
            )
        case .missionControlTimeSpine:
            return AmbitionObjectMotionPolicy(
                objectTitle: "Constellation Atlas",
                owner: "Goals",
                motionToken: .panelReveal,
                stateMeaning: "Goal direction became legible across life areas, proof, pressure, and next steps.",
                nonMotionCues: ["lane title", "selected lane detail", "proof or blocker marker"],
                hapticBoundary: "No haptic until the Goals implementation defines a user-initiated lane action."
            )
        case .actionClosureDiamond:
            return AmbitionObjectMotionPolicy(
                objectTitle: "Action Closure Diamond",
                owner: "Today / Recovery",
                motionToken: .proofConfirm,
                stateMeaning: "Outcome, consequence, proof, and recovery settled after user closure.",
                nonMotionCues: ["facet label", "still-counts copy", "next recovery action"],
                hapticBoundary: "Confirmation haptic only after a user records closure."
            )
        case .lifeShapeField:
            return AmbitionObjectMotionPolicy(
                objectTitle: "LifeShape Field",
                owner: "Time",
                motionToken: .reviewRequired,
                stateMeaning: "Capacity, pressure, or defaults need review before shape changes.",
                nonMotionCues: ["capacity label", "pressure text", "review-needed action"],
                hapticBoundary: "No haptic; LifeShape changes must remain review-first and non-calendar-like."
            )
        case .captureComposer:
            return AmbitionObjectMotionPolicy(
                objectTitle: "Capture Atmosphere Composer",
                owner: "Capture",
                motionToken: .panelReveal,
                stateMeaning: "Text-first capture context became available before placement appears.",
                nonMotionCues: ["text field focus", "draft state", "placement appears after content"],
                hapticBoundary: "No haptic while typing; placement feedback waits for user action."
            )
        }
    }
}

public extension AmbitionFlagshipMotionObject {
    @available(*, deprecated, renamed: "realityMeridian")
    static var realityRail: Self { .realityMeridian }

    @available(*, deprecated, renamed: "lifeShapeField")
    static var lifeShapeMap: Self { .lifeShapeField }
}

public struct AmbitionObjectMotionPolicy: Equatable, Sendable {
    public let objectTitle: String
    public let owner: String
    public let motionToken: AmbitionInteractionToken
    public let stateMeaning: String
    public let nonMotionCues: [String]
    public let hapticBoundary: String

    public init(
        objectTitle: String,
        owner: String,
        motionToken: AmbitionInteractionToken,
        stateMeaning: String,
        nonMotionCues: [String],
        hapticBoundary: String
    ) {
        self.objectTitle = objectTitle
        self.owner = owner
        self.motionToken = motionToken
        self.stateMeaning = stateMeaning
        self.nonMotionCues = nonMotionCues
        self.hapticBoundary = hapticBoundary
    }

    public var motionPreset: DAVMotionPreset {
        motionToken.davMotionPreset
    }

    public var hapticPolicy: AmbitionHapticPolicy {
        motionToken.hapticPolicy
    }

    public var reduceMotionEquivalent: String {
        "\(motionToken.reduceMotionEquivalent) Non-motion cues: \(nonMotionCues.joined(separator: ", "))."
    }

    public var accessibilitySummary: String {
        "\(objectTitle). \(stateMeaning) Reduce Motion: \(reduceMotionEquivalent)"
    }

    public var preservesMeaningWithoutMotion: Bool {
        reduceMotionEquivalent.isEmpty == false &&
        nonMotionCues.isEmpty == false &&
        nonMotionCues.allSatisfy { $0.isEmpty == false }
    }
}
#endif

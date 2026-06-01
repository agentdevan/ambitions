#if canImport(SwiftUI)
import SwiftUI

public enum AmbitionMotionPattern: CaseIterable, Sendable {
    case completion
    case correction
    case reschedule
    case routeChange
    case panelEntry
}

public enum AmbitionInteractionPurpose: String, CaseIterable, Sendable {
    case orientation
    case confirmation
    case uncertaintyReduction

    public var title: String {
        switch self {
        case .orientation:
            return "Orientation"
        case .confirmation:
            return "Confirmation"
        case .uncertaintyReduction:
            return "Uncertainty reduction"
        }
    }
}

public enum AmbitionHapticPolicy: Equatable, Sendable {
    case none
    case userInitiated(AmbitionTheme.HapticIntent)

    public var intent: AmbitionTheme.HapticIntent? {
        switch self {
        case .none:
            return nil
        case .userInitiated(let intent):
            return intent
        }
    }
}

public enum AmbitionInteractionToken: String, CaseIterable, Sendable {
    case routeOrientation
    case panelReveal
    case selectionConfirm
    case proofConfirm
    case correctionNeeded
    case sourceCheck
    case reviewRequired
    case privacyBoundary
    case unsafeRedirect
    case recompilePending
    case localOnlySettle

    public var purpose: AmbitionInteractionPurpose {
        switch self {
        case .routeOrientation, .panelReveal, .recompilePending:
            return .orientation
        case .selectionConfirm, .proofConfirm:
            return .confirmation
        case .correctionNeeded, .sourceCheck, .reviewRequired, .privacyBoundary, .unsafeRedirect, .localOnlySettle:
            return .uncertaintyReduction
        }
    }

    public var motionPattern: AmbitionMotionPattern {
        switch self {
        case .routeOrientation:
            return .routeChange
        case .panelReveal, .privacyBoundary:
            return .panelEntry
        case .selectionConfirm, .proofConfirm:
            return .completion
        case .correctionNeeded, .reviewRequired, .unsafeRedirect:
            return .correction
        case .sourceCheck, .recompilePending:
            return .reschedule
        case .localOnlySettle:
            return .panelEntry
        }
    }

    public var davMotionPreset: DAVMotionPreset {
        switch self {
        case .routeOrientation:
            return .railProgress
        case .panelReveal, .privacyBoundary:
            return .softReveal
        case .selectionConfirm, .localOnlySettle:
            return .stateSettle
        case .proofConfirm:
            return .receiptConfirmation
        case .correctionNeeded, .sourceCheck, .reviewRequired, .unsafeRedirect, .recompilePending:
            return .stateSettle
        }
    }

    public var hapticPolicy: AmbitionHapticPolicy {
        switch self {
        case .selectionConfirm:
            return .userInitiated(.selection)
        case .proofConfirm:
            return .userInitiated(.completion)
        case .routeOrientation:
            return .userInitiated(.routeChange)
        case .correctionNeeded:
            return .userInitiated(.correction)
        case .panelReveal, .sourceCheck, .reviewRequired, .privacyBoundary, .unsafeRedirect, .recompilePending, .localOnlySettle:
            return .none
        }
    }

    public var title: String {
        switch self {
        case .routeOrientation:
            return "Route orientation"
        case .panelReveal:
            return "Panel reveal"
        case .selectionConfirm:
            return "Selection confirmed"
        case .proofConfirm:
            return "Proof confirmed"
        case .correctionNeeded:
            return "Correction needed"
        case .sourceCheck:
            return "Source check"
        case .reviewRequired:
            return "Review required"
        case .privacyBoundary:
            return "Privacy boundary"
        case .unsafeRedirect:
            return "Unsafe redirect"
        case .recompilePending:
            return "Recompile pending"
        case .localOnlySettle:
            return "Local-only settle"
        }
    }

    public var reduceMotionEquivalent: String {
        switch self {
        case .routeOrientation:
            return "Immediate destination title, preserved back path, and selected row label."
        case .panelReveal:
            return "Instant panel reveal with unchanged hierarchy and status text."
        case .selectionConfirm:
            return "Static selected label, symbol, and VoiceOver value."
        case .proofConfirm:
            return "Static receipt/proof label with source and undo or correction text."
        case .correctionNeeded:
            return "Static correction label and next action without shake or reward motion."
        case .sourceCheck:
            return "Static source-state label before any commitment can move."
        case .reviewRequired:
            return "Static review label and explicit user-review affordance."
        case .privacyBoundary:
            return "Static privacy label with no private-detail reveal."
        case .unsafeRedirect:
            return "Static safety redirect label and professional-boundary copy."
        case .recompilePending:
            return "Static impact label that says review is needed before changes apply."
        case .localOnlySettle:
            return "Static local-only label and unchanged data-boundary text."
        }
    }

    public var hapticBoundary: String {
        switch self {
        case .routeOrientation:
            return "Route haptics stay user initiated and only follow an explicit orientation change."
        case .panelReveal:
            return "Panel reveal stays silent and does not use reward-style haptics."
        case .selectionConfirm:
            return "Selection haptics stay user initiated and only follow a deliberate choice."
        case .proofConfirm:
            return "Proof haptics stay user initiated and only follow a user-recorded closure or save."
        case .correctionNeeded:
            return "Correction haptics stay user initiated and never imply praise or penalty."
        case .sourceCheck:
            return "Source state stays quiet while review or freshness copy carries the meaning."
        case .reviewRequired:
            return "Review state stays quiet while the review affordance carries the meaning."
        case .privacyBoundary:
            return "Privacy boundaries stay quiet and never use haptics to disclose private content."
        case .unsafeRedirect:
            return "Unsafe redirects stay quiet and use clear boundary copy instead of feedback haptics."
        case .recompilePending:
            return "Pending changes stay quiet and wait for user review before any feedback appears."
        case .localOnlySettle:
            return "Local-only settle stays quiet and keeps the data boundary explicit in text."
        }
    }

    public var accessibilitySummary: String {
        "\(title). \(purpose.title). Reduce Motion: \(reduceMotionEquivalent) Haptics: \(hapticBoundary)"
    }

    public var allowsAutomaticHaptics: Bool {
        hapticPolicy.intent != nil
    }
}

public enum AmbitionSemanticTypographyRole: String, CaseIterable, Sendable {
    case heroDisplay
    case title
    case titleCompact
    case sectionTitle
    case bodyPrimary
    case bodyEmphasized
    case bodySecondary
    case caption
    case micro
    case numeric

    public var tokenName: String {
        rawValue
    }

    public func font(theme: AmbitionTheme) -> Font {
        switch self {
        case .heroDisplay:
            return theme.typography.heroDisplay
        case .title:
            return theme.typography.title
        case .titleCompact:
            return theme.typography.titleCompact
        case .sectionTitle:
            return theme.typography.sectionTitle
        case .bodyPrimary:
            return theme.typography.bodyPrimary
        case .bodyEmphasized:
            return theme.typography.bodyEmphasized
        case .bodySecondary:
            return theme.typography.bodySecondary
        case .caption:
            return theme.typography.caption
        case .micro:
            return theme.typography.micro
        case .numeric:
            return theme.typography.numeric
        }
    }
}

public enum AmbitionSemanticMaterialRole: String, CaseIterable, Sendable {
    case hero
    case band
    case widget
    case overlay
    case elevated
    case canvas
    case success
    case warning
    case celebration
    case quietGlass
    case graphiteRecess
    case luminousTrace

    public var tokenName: String {
        rawValue
    }
}

public struct AmbitionSemanticCausalityContext: Equatable, Sendable {
    public let sourceRecordSeamID: String
    public let receiptSeamID: String
    public let replayTraceSeamID: String
    public let whatAmbitionsKnowsSeamID: String
    public let sourceRecordLabel: String
    public let receiptLabel: String
    public let replayTraceLabel: String
    public let inspectionSurfaceLabel: String

    public init(
        sourceRecordSeamID: String,
        receiptSeamID: String,
        replayTraceSeamID: String,
        whatAmbitionsKnowsSeamID: String,
        sourceRecordLabel: String,
        receiptLabel: String,
        replayTraceLabel: String,
        inspectionSurfaceLabel: String
    ) {
        self.sourceRecordSeamID = sourceRecordSeamID
        self.receiptSeamID = receiptSeamID
        self.replayTraceSeamID = replayTraceSeamID
        self.whatAmbitionsKnowsSeamID = whatAmbitionsKnowsSeamID
        self.sourceRecordLabel = sourceRecordLabel
        self.receiptLabel = receiptLabel
        self.replayTraceLabel = replayTraceLabel
        self.inspectionSurfaceLabel = inspectionSurfaceLabel
    }

    public static let runtimeProvenanceInspection = AmbitionSemanticCausalityContext(
        sourceRecordSeamID: "SourceRecord",
        receiptSeamID: "Receipt",
        replayTraceSeamID: "ReplayTrace",
        whatAmbitionsKnowsSeamID: "What Ambitions knows",
        sourceRecordLabel: "SourceRecord",
        receiptLabel: "Receipt",
        replayTraceLabel: "ReplayTrace",
        inspectionSurfaceLabel: "What Ambitions knows"
    )

    public var inspectionSummary: String {
        "You / \(whatAmbitionsKnowsSeamID) can inspect \(sourceRecordSeamID), \(receiptSeamID), and \(replayTraceSeamID) through the \(inspectionSurfaceLabel) seam."
    }
}

public enum AmbitionSemanticCompilerInput: String, CaseIterable, Sendable {
    case startHereRecommendation
    case routeOrientation
    case proofReceipt
    case sourceFreshness
    case captureDraft
    case lifeShapeReview
    case recoveryClosure
    case privacyBoundary
    case unsafeRedirect
    case localOnlySettle
}

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

public extension AnyTransition {
    static var ambitionPanel: AnyTransition {
        ambitionTransition(.panelEntry)
    }

    static func ambitionTransition(_ pattern: AmbitionMotionPattern) -> AnyTransition {
        switch pattern {
        case .completion:
            return .asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .center)),
                removal: .opacity.combined(with: .scale(scale: 0.96, anchor: .center))
            )
        case .correction:
            return .asymmetric(
                insertion: .opacity.combined(with: .move(edge: .top)),
                removal: .opacity
            )
        case .reschedule:
            return .asymmetric(
                insertion: .opacity.combined(with: .move(edge: .trailing)),
                removal: .opacity.combined(with: .move(edge: .leading))
            )
        case .routeChange:
            return .asymmetric(
                insertion: .opacity.combined(with: .move(edge: .trailing)),
                removal: .opacity.combined(with: .move(edge: .leading))
            )
        case .panelEntry:
            return .asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.985, anchor: .top)),
                removal: .opacity.combined(with: .scale(scale: 0.99, anchor: .top))
            )
        }
    }

    static func ambitionInteraction(
        _ token: AmbitionInteractionToken,
        reduceMotion: Bool
    ) -> AnyTransition {
        token.davMotionPreset.transition(reduceMotion: reduceMotion)
    }
}

public extension Animation {
    static func ambitionMotion(
        _ pattern: AmbitionMotionPattern,
        theme: AmbitionTheme,
        reduceMotion: Bool
    ) -> Animation? {
        switch pattern {
        case .routeChange:
            return theme.motion.routeAnimation(reduceMotion: reduceMotion)
        case .completion, .correction, .reschedule, .panelEntry:
            return theme.motion.animation(reduceMotion: reduceMotion, emphasis: pattern == .panelEntry)
        }
    }

    static func ambitionInteraction(
        _ token: AmbitionInteractionToken,
        theme: AmbitionTheme,
        reduceMotion: Bool
    ) -> Animation? {
        token.davMotionPreset.animation(theme: theme, reduceMotion: reduceMotion)
    }
}

public extension View {
    @ViewBuilder
    func ambitionHaptic<T: Equatable>(
        _ intent: AmbitionTheme.HapticIntent,
        trigger: T
    ) -> some View {
        sensoryFeedback(hapticFeedback(for: intent), trigger: trigger)
    }

    @ViewBuilder
    func ambitionInteractionHaptic<T: Equatable>(
        _ token: AmbitionInteractionToken,
        trigger: T,
        isEnabled: Bool = true
    ) -> some View {
        if isEnabled, let intent = token.hapticPolicy.intent {
            ambitionHaptic(intent, trigger: trigger)
        } else {
            self
        }
    }

    private func hapticFeedback(for intent: AmbitionTheme.HapticIntent) -> SensoryFeedback {
        switch intent {
        case .selection, .routeChange:
            return .selection
        case .completion:
            return .success
        case .correction:
            return .alignment
        case .reschedule:
            return .impact(weight: .light, intensity: 0.75)
        case .warning:
            return .warning
        }
    }
}
#endif

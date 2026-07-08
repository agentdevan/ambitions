import AmbitionsDesignSystem
import Foundation

extension PreviewFixtures {
    static let defaultExternalBrainScenarios: [ExternalBrainPreviewScenario] = [
        ExternalBrainPreviewScenario(
            id: "eb35-capture-needs-place",
            title: "Capture ready for review",
            surface: "Capture",
            fixtureOwner: "Native/Ambitions/PreviewSupport/PreviewFixtures.swift",
            sourceTruth: "Universal Capture / Smart Attachment",
            commandIntent: .quickCapture,
            memoryQuery: nil,
            privacyBoundary: "Local capture text only; no durable memory claim.",
            accessibilityExpectation: "Plain receipt, non-color route state, and editable review path.",
            yellowLimit: "No screenshot proof or human VoiceOver proof in EB35.",
            expectedEvidence: ["capture fixture", "smart attachment route", "receipt copy"]
        ),
        ExternalBrainPreviewScenario(
            id: "eb35-memory-context-recall",
            title: "Memory context recall",
            surface: "Search Ambitions",
            fixtureOwner: "Native/Ambitions/Services/MemoryLensService.swift",
            sourceTruth: "Personal context / Trust",
            commandIntent: .memoryLens,
            memoryQuery: "safe context recall",
            privacyBoundary: "Searches source-grounded context without creating durable memory.",
            accessibilityExpectation: "Result rows must expose source, confidence, and review state.",
            yellowLimit: "Rendered Search screenshots remain future-owned.",
            expectedEvidence: ["memory query", "source evidence", "review boundary"]
        ),
        ExternalBrainPreviewScenario(
            id: "eb35-correction-trail",
            title: "Correction trail requires review",
            surface: "Search Ambitions",
            fixtureOwner: "Native/Ambitions/Services/MemoryLensService.swift",
            sourceTruth: "Personal context / User Control",
            commandIntent: .memoryLens,
            memoryQuery: "Correction trail",
            privacyBoundary: "Correction signals cannot become durable memory without review.",
            accessibilityExpectation: "Review-before-memory state must be spoken as text.",
            yellowLimit: "Durable correction/delete/export behavior remains future-owned.",
            expectedEvidence: ["correction trail query", "requires review", "no durable claim"]
        ),
        ExternalBrainPreviewScenario(
            id: "eb35-command-surface-contract",
            title: "Command surface safety contract",
            surface: "Shell command",
            fixtureOwner: "Native/Ambitions/App/ShellCommandModels.swift",
            sourceTruth: "Command Surface / Trust",
            commandIntent: .quickTimePatch,
            memoryQuery: nil,
            privacyBoundary: "Routes to Time without calendar writes or silent reshaping.",
            accessibilityExpectation: "Command explanation must name destination and fallback.",
            yellowLimit: "No rendered command UI proof in EB35.",
            expectedEvidence: ["command contract", "fallback", "no calendar write"]
        ),
        ExternalBrainPreviewScenario(
            id: "eb35-trust-memory-controls",
            title: "Trust and memory controls",
            surface: "You",
            fixtureOwner: "Native/Ambitions/Surfaces/You/Projection/YouFeatureService.swift",
            sourceTruth: "Trust Center / What Ambitions Knows",
            commandIntent: nil,
            memoryQuery: nil,
            privacyBoundary: "Memory, receipts, privacy, and correction controls stay visible.",
            accessibilityExpectation: "Rows need labels, hints, and non-color status text.",
            yellowLimit: "Human trust review and device proof remain future-owned.",
            expectedEvidence: ["you fixture", "memory controls", "receipt audit"]
        ),
        ExternalBrainPreviewScenario(
            id: "eb35-overloaded-recovery",
            title: "Overloaded recovery path",
            surface: "Today / Time",
            fixtureOwner: "Sources/Previews/DynamicAdaptiveVisualPreviews.swift",
            sourceTruth: "Cognitive Load / Recovery",
            commandIntent: .quickRecovery,
            memoryQuery: nil,
            privacyBoundary: "Recovery posture changes no saved plans silently.",
            accessibilityExpectation: "Reduce Motion and low-load copy must preserve meaning.",
            yellowLimit: "EB35 records the scenario; UI proof remains DAV/SIG-owned.",
            expectedEvidence: ["recovery scenario", "no shame copy", "no silent mutation"]
        )
    ]
}

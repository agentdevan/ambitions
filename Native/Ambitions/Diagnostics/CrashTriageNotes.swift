import Foundation

struct CrashTriageNote: Identifiable, Sendable, Equatable {
    let id: String
    let owner: String
    let trigger: String
    let firstAction: String
    let proofRequirement: String
}

enum CrashTriageNotes {
    static let defaultNotes: [CrashTriageNote] = [
        CrashTriageNote(
            id: "launch-crash",
            owner: "App",
            trigger: "App exits before first stage render.",
            firstAction: "Inspect launch dependency wiring, local store opening, and stage host initialization.",
            proofRequirement: "Attach focused launch or unit-test evidence before claiming recovery."
        ),
        CrashTriageNote(
            id: "mutation-crash",
            owner: "Core/LocalRuntimeOS",
            trigger: "App exits during command, mutation, or proof recording.",
            firstAction: "Replay the runtime command path through mutation and proof owners.",
            proofRequirement: "Focused runtime mutation tests must pass after the repair."
        ),
        CrashTriageNote(
            id: "render-crash",
            owner: "Rendering/CanvasPrimitives",
            trigger: "App exits while rendering a primary object.",
            firstAction: "Inspect render budget, semantic mirror availability, and reduced-motion fallback.",
            proofRequirement: "Focused render diagnostics and screenshot review must cover the repaired object."
        )
    ]

    static func note(id: String) -> CrashTriageNote? {
        defaultNotes.first { $0.id == id }
    }
}

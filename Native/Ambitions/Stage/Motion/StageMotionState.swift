import AmbitionsDesignSystem
import Foundation
import SwiftUI

struct MotionCurrentProjection {
    let crown: MotionContextCrownState
    let field: MotionCurrentFieldState
    let lanes: [MotionLaneState]
    let affordance: MotionSourceReceiptAffordanceState
    let dockActions: [MotionDockAction]

    static var fixture: MotionCurrentProjection {
        fixture(renderState: .emptyStructure)
    }

    static func fixture(renderState: MotionCurrentRenderState) -> MotionCurrentProjection {
        MotionCurrentProjection(
            crown: MotionContextCrownState(
                eyebrow: "Motion",
                title: "Motion Current",
                summary: "What moved, what needs recovery, and where to return.",
                chips: [
                    MotionChipState(title: "Local", icon: "iphone", semanticState: .protected),
                    MotionChipState(title: "Source-led", icon: "link", semanticState: .trust),
                    MotionChipState(title: "Review", icon: "checkmark.seal", semanticState: .success)
                ]
            ),
            field: renderState.field,
            lanes: [
                MotionLaneState(
                    id: "history",
                    title: "What moved",
                    status: "History available",
                    summary: "Recent movement stays attached to the step or goal it came from.",
                    icon: "checkmark.seal",
                    colorRole: .proof,
                    markers: [
                        MotionChipState(title: "Origin", icon: "point.topleft.down.curvedto.point.bottomright.up", semanticState: .focus),
                        MotionChipState(title: "Proof seam", icon: "seal", semanticState: .success),
                        MotionChipState(title: "Review path", icon: "doc.text", semanticState: .trust)
                    ],
                    items: [
                        MotionLaneItemState(
                            id: "no-proof-yet",
                            title: "No proof yet",
                            stateLabel: "Seed",
                            source: "Today or Capture",
                            proof: "Open path",
                            receipt: "Created on close",
                            semanticState: .neutral
                        ),
                        MotionLaneItemState(
                            id: "proof-available",
                            title: "Proof available",
                            stateLabel: "Attached",
                            source: "Closure",
                            proof: "Visible",
                            receipt: "Linked",
                            semanticState: .success
                        ),
                        MotionLaneItemState(
                            id: "proof-transferred",
                            title: "Proof transferred",
                            stateLabel: "Carried",
                            source: "Goals",
                            proof: "Preserved",
                            receipt: "Transfer note",
                            semanticState: .trust
                        ),
                        MotionLaneItemState(
                            id: "source-unavailable",
                            title: "Context is light",
                            stateLabel: "Held",
                            source: "Needs local source",
                            proof: "Not widened",
                            receipt: "No change",
                            semanticState: .caution
                        )
                    ]
                ),
                MotionLaneState(
                    id: "recovery",
                    title: "What needs recovery",
                    status: "Calm route",
                    summary: "A lighter route can rejoin Today with source, reason, and consent visible.",
                    icon: "arrow.uturn.backward.circle",
                    colorRole: .recovery,
                    markers: [
                        MotionChipState(title: "Still counts", icon: "checkmark.circle", semanticState: .recovery),
                        MotionChipState(title: "Lighter path", icon: "leaf", semanticState: .focus),
                        MotionChipState(title: "Consent", icon: "hand.raised", semanticState: .trust)
                    ],
                    items: [
                        MotionLaneItemState(
                            id: "recovery-active",
                            title: "Recovery active",
                            stateLabel: "In motion",
                            source: "Today closure",
                            proof: "Minimum kept",
                            receipt: "Calm route",
                            semanticState: .recovery
                        ),
                        MotionLaneItemState(
                            id: "recovery-complete",
                            title: "Recovery complete",
                            stateLabel: "Stable",
                            source: "Today",
                            proof: "Still counts",
                            receipt: "Saved",
                            semanticState: .success
                        ),
                        MotionLaneItemState(
                            id: "stalled-returnable",
                            title: "Stalled but returnable",
                            stateLabel: "Returnable",
                            source: "Motion",
                            proof: "Held",
                            receipt: "Return",
                            semanticState: .focus
                        ),
                        MotionLaneItemState(
                            id: "receipt-linked",
                            title: "Receipt linked",
                            stateLabel: "Traceable",
                            source: "Review",
                            proof: "Related",
                            receipt: "Open",
                            semanticState: .trust
                        )
                    ]
                ),
                MotionLaneState(
                    id: "reentry",
                    title: "Where to return",
                    status: "Return",
                    summary: "A paused thread keeps one calm return point and a clear owner.",
                    icon: "arrowshape.turn.up.forward",
                    colorRole: .reentry,
                    markers: [
                        MotionChipState(title: "Owner", icon: "person.crop.circle", semanticState: .protected),
                        MotionChipState(title: "Return", icon: "arrow.forward.circle", semanticState: .focus),
                        MotionChipState(title: "Next seam", icon: "line.3.horizontal.decrease", semanticState: .trust)
                    ],
                    items: [
                        MotionLaneItemState(
                            id: "reentry-available",
                            title: "Re-entry available",
                            stateLabel: "Ready",
                            source: "Today",
                            proof: "Last honest point",
                            receipt: "Open path",
                            semanticState: .focus
                        ),
                        MotionLaneItemState(
                            id: "life-area-development",
                            title: "Life-area development",
                            stateLabel: "Developing",
                            source: "Capture or Goals",
                            proof: "Provisional",
                            receipt: "Reviewable",
                            semanticState: .protected
                        ),
                        MotionLaneItemState(
                            id: "changed-object",
                            title: "Changed object",
                            stateLabel: "Rerouted",
                            source: "Goals",
                            proof: "Reattached",
                            receipt: "Change note",
                            semanticState: .trust
                        )
                    ]
                )
            ],
            affordance: MotionSourceReceiptAffordanceState(
                title: "History available",
                items: [
                    MotionAffordanceItem(label: "Context", value: "Local record", icon: "link", semanticState: .trust),
                    MotionAffordanceItem(label: "History", value: "Attached after closure", icon: "seal", semanticState: .success),
                    MotionAffordanceItem(label: "Review", value: "Visible before change", icon: "doc.text", semanticState: .trust)
                ]
            ),
            dockActions: [
                MotionDockAction(id: "today", title: "Open Today"),
                MotionDockAction(id: "goals", title: "Open Goals"),
                MotionDockAction(id: "time", title: "Open Time"),
                MotionDockAction(id: "trust", title: "Open Trust")
            ]
        )
    }
}

enum MotionCurrentRenderState: String, CaseIterable {
    case emptyStructure = "empty"
    case proofAvailable = "history"
    case recoveryActive = "recovery"
    case reentryAvailable = "reentry"
    case sourceUnavailable = "context"

    static var launchArgument: MotionCurrentRenderState {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-AmbitionsMotionRenderState"),
              arguments.indices.contains(index + 1),
              let state = MotionCurrentRenderState(rawValue: arguments[index + 1].lowercased()) else {
            return .proofAvailable
        }
        return state
    }

    var field: MotionCurrentFieldState {
        switch self {
        case .emptyStructure:
            MotionCurrentFieldState(
                title: "No proof yet",
                summary: "Motion is holding the thread until closure creates proof.",
                source: "Local source",
                proof: "Empty proof state",
                receipt: "Review path before change",
                control: "Inspect source, open the future receipt path, or wait for closure."
            )
        case .proofAvailable:
            MotionCurrentFieldState(
                title: "Proof available",
                summary: "Saved proof stays attached to its source, receipt, and return point.",
                source: "Closure source",
                proof: "Proof visible in lane",
                receipt: "Linked receipt",
                control: "Open the proof path or keep the current thread in place."
            )
        case .recoveryActive:
            MotionCurrentFieldState(
                title: "Recovery active",
                summary: "A lighter route is active with source, reason, and consent visible.",
                source: "Today closure",
                proof: "Minimum proof kept",
                receipt: "Calm route receipt",
                control: "Continue gently or inspect the recovery path first."
            )
        case .reentryAvailable:
            MotionCurrentFieldState(
                title: "Re-entry available",
                summary: "A paused thread has one calm return point and a clear owner.",
                source: "Today return point",
                proof: "Last honest point",
                receipt: "Open path receipt",
                control: "Start again from the visible return point."
            )
        case .sourceUnavailable:
            MotionCurrentFieldState(
                title: "Context is light",
                summary: "Motion holds the thread in place until the local source can be inspected.",
                source: "Needs local source",
                proof: "Not widened",
                receipt: "No change applied",
                control: "Keep the thread held until source context is available."
            )
        }
    }
}

struct MotionContextCrownState {
    let eyebrow: String
    let title: String
    let summary: String
    let chips: [MotionChipState]
}

struct MotionCurrentFieldState {
    let title: String
    let summary: String
    let source: String
    let proof: String
    let receipt: String
    let control: String
}

struct MotionLaneState: Identifiable {
    enum ColorRole {
        case proof
        case recovery
        case reentry
    }

    let id: String
    let title: String
    let status: String
    let summary: String
    let icon: String
    let colorRole: ColorRole
    let markers: [MotionChipState]
    let items: [MotionLaneItemState]

    func color(_ theme: AmbitionTheme) -> Color {
        switch colorRole {
        case .proof:
            theme.colors.accentSecondary
        case .recovery:
            theme.colors.accentWarm
        case .reentry:
            theme.colors.success
        }
    }

    var rhythmTitle: String {
        title.replacingOccurrences(of: " lane", with: "")
    }
}

struct MotionLaneItemState: Identifiable {
    let id: String
    let title: String
    let stateLabel: String
    let source: String
    let proof: String
    let receipt: String
    let semanticState: AmbitionSemanticState
}

struct MotionChipState: Identifiable {
    let title: String
    let icon: String
    let semanticState: AmbitionSemanticState

    var id: String { "\(title)-\(icon)" }
}

struct MotionSourceReceiptAffordanceState {
    let title: String
    let items: [MotionAffordanceItem]
}

struct MotionAffordanceItem: Identifiable {
    let label: String
    let value: String
    let icon: String
    let semanticState: AmbitionSemanticState

    var id: String { label.motionSlug }
}

struct MotionDockAction: Identifiable {
    let id: String
    let title: String
}

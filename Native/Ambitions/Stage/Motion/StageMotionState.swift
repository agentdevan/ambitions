import AmbitionsDesignSystem
import Foundation
import SwiftUI

struct MotionCurrentProjection {
    let crown: MotionContextCrownState
    let field: MotionCurrentFieldState
    let lanes: [MotionLaneState]
    let affordance: MotionSourceReceiptAffordanceState
    let dockActions: [MotionDockAction]

    #if DEBUG
        static var fixture: MotionCurrentProjection {
            debugFixture(renderState: .emptyStructure)
        }

        static func fixture(renderState: MotionCurrentRenderState) -> MotionCurrentProjection {
            debugFixture(renderState: renderState)
        }

        static func debugFixture(renderState: MotionCurrentRenderState) -> MotionCurrentProjection {
            MotionCurrentProjection(
                crown: MotionContextCrownState(
                    eyebrow: "Today",
                    title: "What changed",
                    summary: "The changed Step keeps its return point and recovery state.",
                    chips: [
                        MotionChipState(title: "Local", icon: "iphone", semanticState: .protected),
                        MotionChipState(title: "Attached", icon: "link", semanticState: .trust),
                        MotionChipState(title: "Review", icon: "checkmark.seal", semanticState: .success),
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
                            MotionChipState(title: "Saved", icon: "seal", semanticState: .success),
                            MotionChipState(title: "Review", icon: "doc.text", semanticState: .trust),
                        ],
                        items: [
                            MotionLaneItemState(
                                id: "no-history-yet",
                                title: "No history yet",
                                stateLabel: "Seed",
                                changedObject: "Today or Capture",
                                changeState: "Open path",
                                returnPoint: "Created on close",
                                semanticState: .neutral
                            ),
                            MotionLaneItemState(
                                id: "history-available",
                                title: "History available",
                                stateLabel: "Attached",
                                changedObject: "Closed Step",
                                changeState: "Visible",
                                returnPoint: "Linked",
                                semanticState: .success
                            ),
                            MotionLaneItemState(
                                id: "history-carried",
                                title: "History carried",
                                stateLabel: "Carried",
                                changedObject: "Goal thread",
                                changeState: "Preserved",
                                returnPoint: "Transfer note",
                                semanticState: .trust
                            ),
                            MotionLaneItemState(
                                id: "context-light",
                                title: "Context is light",
                                stateLabel: "Held",
                                changedObject: "Held Step",
                                changeState: "Not widened",
                                returnPoint: "No change",
                                semanticState: .caution
                            ),
                        ]
                    ),
                    MotionLaneState(
                        id: "recovery",
                        title: "What needs recovery",
                        status: "Calm path",
                        summary: "A lighter path can rejoin Today with reason and consent visible.",
                        icon: "arrow.uturn.backward.circle",
                        colorRole: .recovery,
                        markers: [
                            MotionChipState(title: "Still counts", icon: "checkmark.circle", semanticState: .recovery),
                            MotionChipState(title: "Lighter path", icon: "leaf", semanticState: .focus),
                            MotionChipState(title: "Consent", icon: "hand.raised", semanticState: .trust),
                        ],
                        items: [
                            MotionLaneItemState(
                                id: "recovery-active",
                                title: "Recovery active",
                                stateLabel: "In motion",
                                changedObject: "Today Step",
                                changeState: "Minimum kept",
                                returnPoint: "Calm route",
                                semanticState: .recovery
                            ),
                            MotionLaneItemState(
                                id: "recovery-complete",
                                title: "Recovery complete",
                                stateLabel: "Stable",
                                changedObject: "Today",
                                changeState: "Still counts",
                                returnPoint: "Saved",
                                semanticState: .success
                            ),
                            MotionLaneItemState(
                                id: "stalled-returnable",
                                title: "Stalled but returnable",
                                stateLabel: "Returnable",
                                changedObject: "Today",
                                changeState: "Held",
                                returnPoint: "Return",
                                semanticState: .focus
                            ),
                            MotionLaneItemState(
                                id: "history-linked",
                                title: "History linked",
                                stateLabel: "Linked",
                                changedObject: "Reviewed Step",
                                changeState: "Related",
                                returnPoint: "Open",
                                semanticState: .trust
                            ),
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
                            MotionChipState(title: "Next step", icon: "line.3.horizontal.decrease", semanticState: .trust),
                        ],
                        items: [
                            MotionLaneItemState(
                                id: "reentry-available",
                                title: "Re-entry available",
                                stateLabel: "Ready",
                                changedObject: "Today",
                                changeState: "Last honest point",
                                returnPoint: "Open path",
                                semanticState: .focus
                            ),
                            MotionLaneItemState(
                                id: "life-area-development",
                                title: "Life-area development",
                                stateLabel: "Developing",
                                changedObject: "Capture or Goals",
                                changeState: "Provisional",
                                returnPoint: "Reviewable",
                                semanticState: .protected
                            ),
                            MotionLaneItemState(
                                id: "changed-object",
                                title: "Changed object",
                                stateLabel: "Rerouted",
                                changedObject: "Goals",
                                changeState: "Reattached",
                                returnPoint: "Change note",
                                semanticState: .trust
                            ),
                        ]
                    ),
                ],
                affordance: MotionSourceReceiptAffordanceState(
                    title: "History available",
                    items: [
                        MotionAffordanceItem(label: "Context", value: "On this device", icon: "link", semanticState: .trust),
                        MotionAffordanceItem(label: "History", value: "Attached after closure", icon: "seal", semanticState: .success),
                        MotionAffordanceItem(label: "Review", value: "Visible before change", icon: "doc.text", semanticState: .trust),
                    ]
                ),
                dockActions: []
            )
        }
    #endif
}

#if DEBUG
    enum MotionCurrentRenderState: String, CaseIterable {
        case emptyStructure = "empty"
        case proofAvailable = "history"
        case recoveryActive = "recovery"
        case reentryAvailable = "reentry"
        case contextLight = "context"

        static var launchArgument: MotionCurrentRenderState {
            let arguments = ProcessInfo.processInfo.arguments
            guard let index = arguments.firstIndex(of: "-AmbitionsMotionRenderState"),
                  arguments.indices.contains(index + 1),
                  let state = MotionCurrentRenderState(rawValue: arguments[index + 1].lowercased())
            else {
                return .proofAvailable
            }
            return state
        }

        var field: MotionCurrentFieldState {
            switch self {
            case .emptyStructure:
                MotionCurrentFieldState(
                    title: "No change yet",
                    summary: "The Step stays held until closure creates history.",
                    changedObject: "Held Step",
                    changeState: "No history yet",
                    returnPoint: "Review before change",
                    control: "Return to the Step or wait for closure."
                )
            case .proofAvailable:
                MotionCurrentFieldState(
                    title: "History available",
                    summary: "Saved history stays attached to its return point.",
                    changedObject: "Closed Step",
                    changeState: "Visible",
                    returnPoint: "Linked history",
                    control: "Review history or keep the current thread in place."
                )
            case .recoveryActive:
                MotionCurrentFieldState(
                    title: "Recovery active",
                    summary: "A lighter path is active with reason and consent visible.",
                    changedObject: "Today Step",
                    changeState: "Minimum kept",
                    returnPoint: "Calm path",
                    control: "Continue gently or inspect the recovery path first."
                )
            case .reentryAvailable:
                MotionCurrentFieldState(
                    title: "Re-entry available",
                    summary: "A paused thread has one calm return point and a clear owner.",
                    changedObject: "Paused thread",
                    changeState: "Last honest point",
                    returnPoint: "Open path",
                    control: "Start again from the visible return point."
                )
            case .contextLight:
                MotionCurrentFieldState(
                    title: "Context is light",
                    summary: "The changed Step stays held until there is enough local context.",
                    changedObject: "Held Step",
                    changeState: "Not widened",
                    returnPoint: "No change applied",
                    control: "Keep the Step held until context is available."
                )
            }
        }
    }
#endif

struct MotionContextCrownState {
    let eyebrow: String
    let title: String
    let summary: String
    let chips: [MotionChipState]
}

struct MotionCurrentFieldState {
    let title: String
    let summary: String
    let changedObject: String
    let changeState: String
    let returnPoint: String
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

    func tint(_ theme: AmbitionTheme) -> Color {
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
        title.replacingOccurrences(of: " path", with: "")
    }
}

struct MotionLaneItemState: Identifiable {
    let id: String
    let title: String
    let stateLabel: String
    let changedObject: String
    let changeState: String
    let returnPoint: String
    let semanticState: AmbitionSemanticState
}

struct MotionChipState: Identifiable {
    let title: String
    let icon: String
    let semanticState: AmbitionSemanticState

    var id: String {
        "\(title)-\(icon)"
    }
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

    var id: String {
        label.motionSlug
    }
}

struct MotionDockAction: Identifiable {
    let id: String
    let title: String
}

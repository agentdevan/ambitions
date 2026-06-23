#if DEBUG

import SwiftUI
import AmbitionsDesignSystem

#Preview("SI09 Capture Field") {
    @Previewable @State var text = "Book dentist before Friday"
    let preview = CaptureDraftRoutePreview(
        originalText: "Book dentist before Friday",
        placementShelfTitle: "Field-first Capture",
        postInputStateTitle: "Ready to Place",
        receiptTitle: "Saved as Step · Today",
        summary: "Looks like a standalone step.",
        understoodLabel: "Looks like a capture that could stay open until a placement is decided.",
        suggestedPlacementLabel: "Step · Today",
        mayAffectLabel: "May support: Local context only.",
        approvalNeededLabel: "No approval needed yet.",
        changeableLabels: ["Change", "Decide later"],
        safeFallbackLabel: "Decide later",
        routeProofTitle: "Route evidence",
        routeProofDetail: "Local text only; no calendar, network, account, or cloud route.",
        destinationLabel: "Today",
        objectTypeLabel: "Step",
        appearanceLabel: "Today",
        consequenceLabel: "Adds a visible Step to Today after you confirm.",
        privacyLabel: "Private item",
        localSourceLabel: "Local source: typed in Capture",
        correctionLabel: "Correction: change the route before saving",
        receiptSeamLabel: "Review history: save creates a local capture receipt",
        resolverFoldTitle: "Resolver Fold",
        resolverWhyLabel: "Local resolver: Step based on local text only.",
        correctionReceiptLabel: "Correction receipt: saved route changes are recorded locally and stay reviewable.",
        correctionControlLabels: [
            "Place somewhere else: choose a route below.",
            "Not a goal: no Goal is created unless you choose Goal.",
            "Not now: Decide later keeps it out of Today.",
            "Decide later: save to Needs placement.",
            "Discard: clear the composer before saving.",
            "Archive: after saving, take it out of active review."
        ],
        primaryActionTitle: "Place it",
        changeActionTitle: "Change",
        safeActionTitle: "Decide later",
        stagedInputs: CaptureStagedInputProjection.supported(sourceSurface: "Capture"),
        semanticState: "savedStandalone",
        clarificationQuestion: nil,
        choices: [
            CaptureDraftRouteChoice(id: "task", title: "Step", routeType: .task, isSelected: true),
            CaptureDraftRouteChoice(id: "goal", title: "Goal", routeType: .goal, isSelected: false),
            CaptureDraftRouteChoice(id: "idea", title: "Needs placement", routeType: .idea, isSelected: false)
        ],
        accessibilityLabel: "Suggested capture route",
        accessibilityValue: "Step, Today, private item",
        accessibilityHint: "Choose a route or save the suggested placement.",
        planInsertionCandidate: nil
    )

    CaptureAtmosphereComposer(
        text: $text,
        routePreview: preview,
        error: nil,
        isSubmitEnabled: true,
        onSubmit: {},
        onMicrophone: {},
        onRouteChoice: { _ in }
    )
    .padding()
    .background(LivingSurfaceBackground(context: .capture, state: .active))
}

#endif

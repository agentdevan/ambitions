import Foundation

struct SmartAttachmentCaptureDecision: Sendable, Equatable {
    let result: SmartAttachmentResult
    let selectedRouteType: SmartAttachmentRouteType?

    var receiptLine: String { result.receiptLine }
    var summary: String {
        if selectedRouteType != nil, let explanation = result.explanation {
            return explanation
        }
        return result.captureAssumptionSummary
    }
    var routeType: SmartAttachmentRouteType { result.selectedCandidate?.target.routeType ?? .idea }
    var destinationLabel: String { result.selectedCandidate?.target.displaySegments.joined(separator: " · ") ?? "Needs a Place" }
    var clarification: SmartAttachmentClarification? { result.clarification }
    var actions: [SmartAttachmentActionLabel] { result.actions }
    var privacyLevel: ActionReceiptPrivacyLevel { result.privacyLevel }

    var accessibilityLabel: String {
        "Smart Attachment route"
    }

    var accessibilityValue: String {
        "\(receiptLine). \(destinationLabel)."
    }

    var accessibilityHint: String? {
        guard actions.isEmpty == false else { return nil }
        return actions.map(\.title).joined(separator: ", ")
    }

    func createCaptureRequest(rawText: String, sourceType: CaptureSourceType? = nil) -> CreateCaptureRequest {
        CreateCaptureRequest(
            rawText: rawText,
            sourceType: sourceType,
            linkedGoalID: result.selectedCandidate?.target.destinationKind == .existingGoal
                ? result.selectedCandidate?.target.destinationID
                : nil,
            triage: CaptureTriageMetadata(destination: result.captureRoute.triageDestination, hint: summary),
            kind: result.captureKind,
            route: result.captureRoute,
            triageStatus: result.triageStatus,
            assumptionSummary: summary
        )
    }
}

struct SmartAttachmentCaptureAdapter: Sendable {
    private let router: any SmartAttachmentRouting

    init(router: any SmartAttachmentRouting = DefaultSmartAttachmentService()) {
        self.router = router
    }

    func decision(
        rawText: String,
        sourceType: CaptureSourceType? = nil,
        sourceSurface: String? = nil,
        selectedRouteType: SmartAttachmentRouteType? = nil,
        candidates: [SmartAttachmentDestinationCandidate] = []
    ) -> SmartAttachmentCaptureDecision? {
        let input = SmartAttachmentInput(
            rawText: rawText,
            sourceContext: SmartAttachmentSourceContext(
                sourceType: sourceType,
                sourceSurface: sourceSurface
            )
        )
        guard input.rawText.isEmpty == false else { return nil }

        if let selectedRouteType {
            return SmartAttachmentCaptureDecision(
                result: manualResult(
                    for: selectedRouteType,
                    input: input
                ),
                selectedRouteType: selectedRouteType
            )
        }

        return SmartAttachmentCaptureDecision(
            result: router.route(input, candidates: candidates, maxCandidateCount: 5),
            selectedRouteType: nil
        )
    }

    private func manualResult(
        for routeType: SmartAttachmentRouteType,
        input: SmartAttachmentInput
    ) -> SmartAttachmentResult {
        switch routeType {
        case .task:
            return SmartAttachmentResult(
                id: stableID(prefix: "manual.task", text: input.rawText),
                input: input,
                resultState: .savedStandalone,
                confidence: .medium,
                selectedCandidate: standaloneCandidate(routeType: .task, placementLabel: "Today"),
                receiptLine: "Saved as Task · Today",
                explanation: "Saved as a standalone Task without creating a Goal or calendar event.",
                actions: [.change, .goal, .idea],
                privacyLevel: .privateItem
            )
        case .goal:
            return SmartAttachmentResult(
                id: stableID(prefix: "manual.goal", text: input.rawText),
                input: input,
                resultState: .savedStandalone,
                confidence: .medium,
                selectedCandidate: standaloneCandidate(routeType: .goal, placementLabel: "Creative"),
                receiptLine: "Saved as Goal · Creative",
                explanation: "Saved as a Goal seed; full Goal creation stays explicit.",
                actions: [.change, .task, .idea],
                privacyLevel: .privateItem
            )
        default:
            return SmartAttachmentResult(
                id: stableID(prefix: "manual.needs-place", text: input.rawText),
                input: input,
                resultState: .savedToNeedsPlace,
                confidence: .low,
                selectedCandidate: needsPlaceCandidate(),
                receiptLine: "Saved to Needs a Place",
                explanation: "Held without pressure until you choose a clearer route.",
                actions: [.change, .task, .goal],
                privacyLevel: .privateItem
            )
        }
    }

    private func standaloneCandidate(
        routeType: SmartAttachmentRouteType,
        placementLabel: String
    ) -> SmartAttachmentCandidate {
        SmartAttachmentCandidate(
            id: "candidate.manual.\(routeType.rawValue)",
            target: SmartAttachmentRouteTarget(
                id: "target.manual.\(routeType.rawValue)",
                routeType: routeType,
                destinationKind: .standalone,
                placementLabel: placementLabel
            ),
            score: 1,
            evidenceLabels: ["Chosen route"]
        )
    }

    private func needsPlaceCandidate() -> SmartAttachmentCandidate {
        SmartAttachmentCandidate(
            id: "candidate.manual.needs-place",
            target: SmartAttachmentRouteTarget(
                id: "target.manual.needs-place",
                routeType: .idea,
                destinationKind: .needsPlace,
                destinationLabel: "Needs a Place"
            ),
            score: 0,
            evidenceLabels: ["Needs a Place"]
        )
    }

    private func stableID(prefix: String, text: String) -> String {
        let normalized = text
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.isEmpty == false }
            .joined(separator: "-")
        return [prefix, normalized.isEmpty ? "empty" : String(normalized.prefix(48))]
            .joined(separator: ".")
    }
}

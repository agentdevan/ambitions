import Foundation

struct CaptureRouteResolveRequest: Sendable, Equatable {
    let intakeReceipt: CaptureIntakeJournalReceipt
    let rawText: String
    let requestedKind: CaptureKind?
    let requestedRoute: CaptureRoute?
    let deadlineText: String?
    let contextLensHint: NowContextLens?
    let priorityHints: CapturePriorityHints
    let sourceType: CaptureSourceType?
    let sourceSurface: String

    init(
        intakeReceipt: CaptureIntakeJournalReceipt,
        rawText: String,
        requestedKind: CaptureKind?,
        requestedRoute: CaptureRoute?,
        deadlineText: String?,
        contextLensHint: NowContextLens?,
        priorityHints: CapturePriorityHints,
        sourceType: CaptureSourceType?,
        sourceSurface: String
    ) {
        self.intakeReceipt = intakeReceipt
        self.rawText = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        self.requestedKind = requestedKind
        self.requestedRoute = requestedRoute
        self.deadlineText = CaptureRoutingStableID.optional(deadlineText)
        self.contextLensHint = contextLensHint
        self.priorityHints = priorityHints
        self.sourceType = sourceType
        self.sourceSurface = CaptureRoutingStableID.required(sourceSurface)
    }
}

struct CaptureRouteDecision: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let intakeRecordID: String
    let captureID: String
    let kind: CaptureKind
    let route: CaptureRoute
    let triageStatus: CaptureTriageStatus
    let commitmentKind: NowCommitmentKind?
    let deadlineText: String?
    let deadlineKind: CaptureDeadlineKind
    let contextLensHint: NowContextLens?
    let priorityHints: CapturePriorityHints
    let assumptionSummary: String
    let decisionSummary: String
    let sourceType: CaptureSourceType?
    let sourceSurface: String
    let privacy: EventLedgerPrivacyClassification
    let runtimeEvent: RuntimeEvent
    let runtimeTrace: CaptureRoutingRuntimeTrace
    let checksum: String

    init(
        request: CaptureRouteResolveRequest,
        classification: CaptureClassification
    ) {
        intakeRecordID = request.intakeReceipt.journalRecordID
        captureID = request.intakeReceipt.captureID
        kind = classification.kind
        route = classification.route
        triageStatus = classification.triageStatus
        commitmentKind = classification.commitmentKind
        deadlineText = classification.deadlineText
        deadlineKind = classification.deadlineKind
        contextLensHint = classification.contextLensHint
        priorityHints = classification.priorityHints
        assumptionSummary = classification.assumptionSummary
        decisionSummary = "Capture route decided as \(classification.route.rawValue) / \(classification.kind.rawValue)."
        sourceType = request.sourceType
        sourceSurface = request.sourceSurface
        privacy = request.intakeReceipt.privacy
        id = CaptureRoutingStableID.make(
            prefix: "capture-routing.decision",
            components: [intakeRecordID, captureID, route.rawValue, kind.rawValue]
        )
        runtimeTrace = CaptureRoutingRuntimeTrace.make(owner: "CaptureRouteResolver", sourceID: id)
        runtimeEvent = RuntimeEvent(
            commandID: request.intakeReceipt.runtimeTrace.commandID,
            actor: .user,
            source: Self.commandSource(for: request.sourceType),
            target: AmbitionsCommandTarget(captureID: captureID, destination: .captureInbox),
            privacy: privacy,
            localOnly: true,
            occurredAt: request.intakeReceipt.occurredAt,
            payload: .captureRouteDecided(
                RuntimeCaptureRouteEventPayload(
                    captureID: captureID,
                    route: route,
                    kind: kind,
                    decisionSummary: decisionSummary
                )
            ),
            metadata: [
                "captureRouteDecisionID": id,
                "captureIntakeRecordID": intakeRecordID,
                "runtimeTraceID": runtimeTrace.id,
                "sourceSurface": sourceSurface
            ]
        )
        checksum = CaptureRoutingStableID.checksum(
            prefix: "capture-routing.decision",
            components: [
                id,
                intakeRecordID,
                captureID,
                kind.rawValue,
                route.rawValue,
                triageStatus.rawValue,
                commitmentKind?.rawValue ?? "",
                deadlineText ?? "",
                deadlineKind.rawValue,
                contextLensHint?.rawValue ?? "",
                assumptionSummary,
                runtimeTrace.checksum
            ]
        )
    }

    var classification: CaptureClassification {
        CaptureClassification(
            kind: kind,
            route: route,
            triageStatus: triageStatus,
            commitmentKind: commitmentKind,
            deadlineText: deadlineText,
            deadlineKind: deadlineKind,
            contextLensHint: contextLensHint,
            priorityHints: priorityHints,
            assumptionSummary: assumptionSummary
        )
    }

    private static func commandSource(for sourceType: CaptureSourceType?) -> AmbitionsCommandSource {
        switch sourceType {
        case .some(.appIntent):
            return .appIntent
        case .some(.notification):
            return .notification
        case .some(.shareExtensionText), .some(.shareExtensionURL):
            return .capture
        case .some(.todayQuickCapture):
            return .today
        case .some(.shellComposer), nil:
            return .capture
        }
    }
}

struct CaptureRouteResolver: Sendable {
    func resolve(_ request: CaptureRouteResolveRequest) throws -> CaptureRouteDecision {
        guard request.intakeReceipt.canClassify else {
            throw CaptureIntakeJournalError.missingDurableReceipt(request.intakeReceipt.journalRecordID)
        }
        let classification = CaptureClassifier.classify(
            text: request.rawText,
            requestedKind: request.requestedKind,
            requestedRoute: request.requestedRoute,
            deadlineText: request.deadlineText,
            contextLensHint: request.contextLensHint,
            priorityHints: request.priorityHints
        )
        return CaptureRouteDecision(request: request, classification: classification)
    }
}

import Foundation

extension AmbitionsCommandExecutor {
    func executeQuickCapture(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext
    ) async -> AmbitionsCommandExecutionResult {
        guard captureService != nil else {
            return AmbitionsCommandExecutionResult(
                status: .blocked,
                summary: "Quick capture is valid, but capture persistence is unavailable in this execution context.",
                target: command.target,
                metadata: ["blockedBy": "missing_capture_service"]
            )
        }
        guard let text = command.content.primaryText else {
            return blockedResult(for: .invalid, command: command)
        }
        let sourceType = captureSourceType(for: command)

        let smartAttachment = smartAttachmentService?.route(
                SmartAttachmentInput(
                    rawText: text,
                    sourceContext: SmartAttachmentSourceContext(
                        sourceType: sourceType,
                        sourceSurface: context.sourceSurface,
                        commandID: command.id
                    )
                ),
                candidates: [],
                maxCandidateCount: 5
            )
        let captureID = "capture.\(command.id)"
        let resolvedRoute = command.content.destinationRoute ?? smartAttachment?.captureRoute ?? .captureInbox
        let resolvedKind = captureKind(for: command.content.commitmentKind) ?? smartAttachment?.captureKind ?? .raw
        var metadata: [String: String] = [
                "captureID": captureID,
                "commandOperation": command.operation.rawValue,
                "commandSource": command.source.rawValue,
                "captureSourceType": sourceType.rawValue,
                "captureRoute": resolvedRoute.rawValue,
                "captureKind": resolvedKind.rawValue,
                "captureLocalOnly": "true",
                "captureMaterialization": "pending_authority_commit",
            ]
        if let smartAttachment {
            metadata["smartAttachmentResult"] = smartAttachment.resultState.rawValue
            metadata["smartAttachmentConfidence"] = smartAttachment.confidence.rawValue
            metadata["smartAttachmentReceipt"] = smartAttachment.receiptLine
        }
        return AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: smartAttachment?.receiptLine ?? "Saved to Needs a Place",
            route: .captureInbox,
            target: AmbitionsCommandTarget(
                goalID: command.target.goalID,
                captureID: captureID,
                destination: .captureInbox
            ),
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: metadata
        )
    }

    func materializeQuickCapture(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext,
        committedResult: AmbitionsCommandExecutionResult
    ) async -> AmbitionsCommandExecutionResult {
        guard let captureService,
              let text = command.content.primaryText,
              let captureID = committedResult.target?.captureID else { return committedResult }
        let sourceType = captureSourceType(for: command)
        let smartAttachment = smartAttachmentService?.route(
            SmartAttachmentInput(rawText: text, sourceContext: SmartAttachmentSourceContext(sourceType: sourceType, sourceSurface: context.sourceSurface, commandID: command.id)),
            candidates: [], maxCandidateCount: 5
        )
        do {
            let existing = try await captureService.listCaptures().first(where: { $0.id == captureID })
            let capture: Capture
            if let existing {
                capture = existing
            } else if let snapshot = await authorityCaptureSnapshot(commandID: command.id),
                      let materializer = captureService as? any CaptureSnapshotMaterializing {
                try await materializer.materializeCaptureSnapshot(snapshot)
                capture = snapshot
            } else {
                capture = try await captureService.createCapture(
                    CreateCaptureRequest(
                        rawText: text,
                        requestedID: captureID,
                        sourceType: sourceType,
                        linkedGoalID: command.target.goalID,
                        triage: externalCreationTriageMetadata(for: command),
                        kind: captureKind(for: command.content.commitmentKind) ?? smartAttachment?.captureKind,
                        route: command.content.destinationRoute ?? smartAttachment?.captureRoute,
                        triageStatus: smartAttachment?.triageStatus,
                        commitmentKind: command.content.commitmentKind,
                        deadlineText: command.content.deadlineText ?? command.content.dueText,
                        deadlineKind: command.content.deadlineText == nil && command.content.dueText == nil ? .none : .hard,
                        contextLensHint: command.content.contextLens,
                        priorityHints: CapturePriorityHints(commandHints: command.content.priorityHints),
                        assumptionSummary: smartAttachment?.captureAssumptionSummary
                    ), now: context.now
                )
            }
            var metadata = ["captureMaterialization": "saved", "captureMaturityState": capture.maturityState.rawValue]
            var ledgerIDs = committedResult.eventLedgerEntryIDs
            if context.allowsEventLedgerEmission, let eventLedger {
                let event = EventLedgerEntry.commandCaptureCreated(
                    command: command,
                    capture: capture,
                    occurredAt: DomainTimestamp.string(from: context.now)
                )
                do {
                    try await eventLedger.append(event)
                    ledgerIDs.append(event.id)
                    metadata["eventLedgerEmission"] = "saved_post_authority"
                } catch {
                    metadata["eventLedgerEmission"] = "needs_recovery"
                }
            }
            let enriched = committedResult.mergingMetadata(metadata)
            return AmbitionsCommandExecutionResult(
                status: enriched.status,
                summary: enriched.summary,
                route: enriched.route,
                target: enriched.target,
                eventLedgerEntryIDs: ledgerIDs,
                recommendationExplanationIDs: enriched.recommendationExplanationIDs,
                metadata: enriched.metadata
            )
        } catch {
            return committedResult.mergingMetadata(["captureMaterialization": "needs_recovery", "captureMaterializationError": String(describing: error)])
        }
    }

    private func authorityCaptureSnapshot(commandID: String) async -> Capture? {
        guard let runtimeEvents,
              let envelopes = try? await runtimeEvents.fetchEvents(matching: .commandID(commandID), limit: nil)
        else { return nil }
        return envelopes.reversed().compactMap { envelope -> Capture? in
            guard case let .domainMutation(record) = envelope.event.payload,
                  let event = try? record.decodedEvent(),
                  case let .captureCreated(created) = event
            else { return nil }
            return created.capture
        }.first
    }


    func executeRouteCommitment(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext
    ) async -> AmbitionsCommandExecutionResult {
        guard let captureService else {
            return AmbitionsCommandExecutionResult(status: .blocked, summary: "Commitment routing is unavailable without capture persistence.", target: command.target, metadata: ["blockedBy": "missing_capture_service"])
        }

        do {
            let capture: Capture?
            if let captureID = command.target.captureID {
                capture = try await captureService.markAsOneTimeCommitment(
                    id: captureID,
                    deadlineText: command.content.deadlineText ?? command.content.dueText,
                    contextLensHint: command.content.contextLens,
                    now: context.now
                )
            } else if let text = command.content.primaryText {
                capture = try await captureService.createCapture(
                    CreateCaptureRequest(
                        rawText: text,
                        sourceType: captureSourceType(for: command.source),
                        kind: .oneTimeCommitment,
                        route: .timeSeed,
                        commitmentKind: .oneTime,
                        deadlineText: command.content.deadlineText ?? command.content.dueText,
                        deadlineKind: command.content.deadlineText == nil && command.content.dueText == nil ? .none : .hard,
                        contextLensHint: command.content.contextLens,
                        priorityHints: CapturePriorityHints(commandHints: command.content.priorityHints),
                        assumptionSummary: "I treated this as a one-time commitment."
                    ),
                    now: context.now
                )
            } else {
                return blockedResult(for: .invalid, command: command)
            }

            guard let capture else {
                return AmbitionsCommandExecutionResult(status: .blocked, summary: "Capture not found for commitment routing.", target: command.target, metadata: ["blockedBy": "missing_capture"])
            }
            return captureResult(command: command, capture: capture, summary: "Commitment represented as a Time-owned planning idea. Scheduling remains deferred to canonical planning.")
        } catch {
            return AmbitionsCommandExecutionResult(status: .failed, summary: error.localizedDescription, target: command.target, metadata: ["error": String(describing: error)])
        }
    }


    func executeCaptureRoute(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext,
        kind: CaptureKind,
        route: CaptureRoute
    ) async -> AmbitionsCommandExecutionResult {
        guard let captureService else {
            return AmbitionsCommandExecutionResult(status: .blocked, summary: "Capture routing is unavailable without capture persistence.", target: command.target, metadata: ["blockedBy": "missing_capture_service"])
        }
        guard let captureID = command.target.captureID else {
            return blockedResult(for: .needsMissingTarget, command: command)
        }

        do {
            let capture = try await captureService.updateCaptureRoute(
                CaptureRouteUpdateRequest(
                    id: captureID,
                    kind: kind,
                    route: route,
                    deadlineText: command.content.deadlineText ?? command.content.dueText,
                    contextLensHint: command.content.contextLens,
                    priorityHints: CapturePriorityHints(commandHints: command.content.priorityHints),
                    waitingMetadata: route == .waiting ? CaptureWaitingMetadata(blockedBy: command.content.notes, waitingOn: command.content.title) : nil
                ),
                now: context.now
            )
            guard let capture else {
                return AmbitionsCommandExecutionResult(status: .blocked, summary: "Capture not found for routing.", target: command.target, metadata: ["blockedBy": "missing_capture"])
            }
            return captureResult(command: command, capture: capture, summary: "Capture route updated.")
        } catch {
            return AmbitionsCommandExecutionResult(status: .failed, summary: error.localizedDescription, target: command.target, metadata: ["error": String(describing: error)])
        }
    }


    func executeArchive(_ command: AmbitionsCommand, context: CommandExecutionContext) async -> AmbitionsCommandExecutionResult {
        guard let captureService else {
            return AmbitionsCommandExecutionResult(status: .blocked, summary: "Archive is unavailable without capture persistence.", target: command.target, metadata: ["blockedBy": "missing_capture_service"])
        }
        guard let captureID = command.target.captureID else {
            return blockedResult(for: .needsMissingTarget, command: command)
        }

        do {
            guard let capture = try await captureService.markCaptureArchived(id: captureID, now: context.now) else {
                return AmbitionsCommandExecutionResult(status: .blocked, summary: "Capture not found for archive.", target: command.target, metadata: ["blockedBy": "missing_capture"])
            }
            return captureResult(command: command, capture: capture, summary: "Capture archived.")
        } catch {
            return AmbitionsCommandExecutionResult(status: .failed, summary: error.localizedDescription, target: command.target, metadata: ["error": String(describing: error)])
        }
    }


    func executeAttachToGoal(_ command: AmbitionsCommand, context: CommandExecutionContext) async -> AmbitionsCommandExecutionResult {
        guard let captureService else {
            return AmbitionsCommandExecutionResult(status: .blocked, summary: "Goal attachment is unavailable without capture persistence.", target: command.target, metadata: ["blockedBy": "missing_capture_service"])
        }
        guard let captureID = command.target.captureID, let goalID = command.target.goalID else {
            return blockedResult(for: .needsMissingTarget, command: command)
        }

        do {
            guard let binding = try await captureService.attachCaptureToGoal(AttachCaptureToGoalRequest(captureID: captureID, goalID: goalID), now: context.now) else {
                return AmbitionsCommandExecutionResult(status: .blocked, summary: "Capture not found for goal attachment.", target: command.target, metadata: ["blockedBy": "missing_capture"])
            }
            return captureResult(command: command, capture: binding.capture, summary: "Capture attached to goal.")
        } catch {
            return AmbitionsCommandExecutionResult(status: .failed, summary: error.localizedDescription, target: command.target, metadata: ["error": String(describing: error)])
        }
    }


    func executeDeadlineChange(_ command: AmbitionsCommand, context: CommandExecutionContext) async -> AmbitionsCommandExecutionResult {
        guard command.target.captureID != nil else {
            return AmbitionsCommandExecutionResult(status: .unsupported, summary: "Deadline changes are executable for captures only in this build.", target: command.target, metadata: ["blockedBy": "owning_system_not_implemented"])
        }
        return await executeCaptureRoute(command, context: context, kind: command.content.commitmentKind == .oneTime ? .deadlineTask : .raw, route: .timeSeed)
    }


    func executePriorityChange(_ command: AmbitionsCommand, context: CommandExecutionContext) async -> AmbitionsCommandExecutionResult {
        guard command.target.captureID != nil else {
            return AmbitionsCommandExecutionResult(status: .unsupported, summary: "Priority changes are executable for captures only in this build.", target: command.target, metadata: ["blockedBy": "owning_system_not_implemented"])
        }
        return await executeCaptureRoute(command, context: context, kind: .raw, route: .captureInbox)
    }


    func executePlanSeedRepresentation(_ command: AmbitionsCommand, context: CommandExecutionContext) async -> AmbitionsCommandExecutionResult {
        if case let .schedule(value) = command.typedPayload,
           case .createItem = value.action {
            guard let stepID = command.target.stepID, let timeID = command.target.timeID else {
                return AmbitionsCommandExecutionResult(
                    status: .blocked,
                    summary: "Time placement needs a canonical step and time block before authority commit.",
                    target: command.target,
                    metadata: ["blockedBy": "missing_semantic_time_target"]
                )
            }
            return AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: "Time placement proposal prepared for authority commit.",
                route: .time,
                target: command.target,
                metadata: [
                    "timePlacementMaterialization": "authority_only",
                    "stepID": stepID,
                    "timeBlockID": timeID,
                ]
            )
        }
        guard let captureService else {
            return AmbitionsCommandExecutionResult(status: .blocked, summary: "Time-owned planning representation is unavailable without capture persistence.", target: command.target, metadata: ["blockedBy": "missing_capture_service"])
        }
        guard let captureID = command.target.captureID else {
            return AmbitionsCommandExecutionResult(status: .unsupported, summary: "Creating new time items is represented through Capture 2.0 only when a capture target exists.", target: command.target, metadata: ["blockedBy": "plan_2_not_implemented"])
        }
        do {
            guard let capture = try await captureService.routeToTimeSeed(id: captureID, now: context.now) else {
                return AmbitionsCommandExecutionResult(status: .blocked, summary: "Capture not found for time-owned planning routing.", target: command.target, metadata: ["blockedBy": "missing_capture"])
            }
            return captureResult(command: command, capture: capture, summary: "Capture represented as a Time-owned planning idea. Scheduling is not implemented in this build.")
        } catch {
            return AmbitionsCommandExecutionResult(status: .failed, summary: error.localizedDescription, target: command.target, metadata: ["error": String(describing: error)])
        }
    }
}

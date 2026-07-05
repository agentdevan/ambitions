import Foundation

extension AmbitionsCommandExecutor {
    func executeQuickCapture(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext
    ) async -> AmbitionsCommandExecutionResult {
        guard let captureService else {
            return AmbitionsCommandExecutionResult(
                status: .blocked,
                summary: "Quick capture is valid, but capture persistence is unavailable in this execution context.",
                target: command.target,
                metadata: ["blockedBy": "missing_capture_service"]
            )
        }
        guard let text = command.payload.primaryText else {
            return blockedResult(for: .invalid, command: command)
        }
        let sourceType = captureSourceType(for: command)

        do {
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
            let capture = try await captureService.createCapture(
                CreateCaptureRequest(
                    rawText: text,
                    sourceType: sourceType,
                    linkedGoalID: command.target.goalID,
                    triage: externalCreationTriageMetadata(for: command),
                    revisitAfter: nil,
                    kind: captureKind(for: command.payload.commitmentKind) ?? smartAttachment?.captureKind,
                    route: route(for: command.payload.destinationRoute) ?? smartAttachment?.captureRoute,
                    triageStatus: smartAttachment?.triageStatus,
                    commitmentKind: command.payload.commitmentKind,
                    deadlineText: command.payload.deadlineText ?? command.payload.dueText,
                    deadlineKind: command.payload.deadlineText == nil && command.payload.dueText == nil ? .none : .hard,
                    contextLensHint: command.payload.contextLens,
                    priorityHints: CapturePriorityHints(commandHints: command.payload.priorityHints),
                    assumptionSummary: smartAttachment?.captureAssumptionSummary
                ),
                now: context.now
            )
            var eventIDs: [String] = []
            var metadata: [String: String] = [
                "captureID": capture.id,
                "commandKind": command.kind.rawValue,
                "commandSource": command.source.rawValue,
                "captureSourceType": sourceType.rawValue,
                "captureRoute": capture.route.rawValue,
                "captureMaturityState": capture.maturityState.rawValue,
                "captureLocalOnly": String(capture.localOnly)
            ]
            if let smartAttachment {
                metadata["smartAttachmentResult"] = smartAttachment.resultState.rawValue
                metadata["smartAttachmentConfidence"] = smartAttachment.confidence.rawValue
                metadata["smartAttachmentReceipt"] = smartAttachment.receiptLine
                metadata["smartAttachmentRoute"] = smartAttachment.selectedCandidate?.target.routeType.rawValue
                metadata["smartAttachmentDestination"] = smartAttachment.selectedCandidate?.target.destinationKind.rawValue
            }

            if context.allowsEventLedgerEmission, let eventLedger {
                let event = EventLedgerEntry.commandCaptureCreated(
                    command: command,
                    capture: capture,
                    occurredAt: DomainTimestamp.string(from: context.now)
                )
                do {
                    try await eventLedger.append(event)
                    eventIDs = [event.id]
                } catch {
                    metadata["eventLedgerEmission"] = "failed"
                }
            }

            return AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: smartAttachment?.receiptLine ?? "Saved to Needs a Place",
                route: .captureInbox,
                target: AmbitionsCommandTarget(
                    goalID: command.target.goalID,
                    captureID: capture.id,
                    destination: .captureInbox
                ),
                eventLedgerEntryIDs: eventIDs,
                recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
                metadata: metadata
            )
        } catch {
            return AmbitionsCommandExecutionResult(
                status: .failed,
                summary: error.localizedDescription,
                target: command.target,
                metadata: ["error": String(describing: error)]
            )
        }
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
                    deadlineText: command.payload.deadlineText ?? command.payload.dueText,
                    contextLensHint: command.payload.contextLens,
                    now: context.now
                )
            } else if let text = command.payload.primaryText {
                capture = try await captureService.createCapture(
                    CreateCaptureRequest(
                        rawText: text,
                        sourceType: captureSourceType(for: command.source),
                        kind: .oneTimeCommitment,
                        route: .timeSeed,
                        commitmentKind: .oneTime,
                        deadlineText: command.payload.deadlineText ?? command.payload.dueText,
                        deadlineKind: command.payload.deadlineText == nil && command.payload.dueText == nil ? .none : .hard,
                        contextLensHint: command.payload.contextLens,
                        priorityHints: CapturePriorityHints(commandHints: command.payload.priorityHints),
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
                    deadlineText: command.payload.deadlineText ?? command.payload.dueText,
                    contextLensHint: command.payload.contextLens,
                    priorityHints: CapturePriorityHints(commandHints: command.payload.priorityHints),
                    waitingMetadata: route == .waiting ? CaptureWaitingMetadata(blockedBy: command.payload.notes, waitingOn: command.payload.title) : nil
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
        return await executeCaptureRoute(command, context: context, kind: command.payload.commitmentKind == .oneTime ? .deadlineTask : .raw, route: .timeSeed)
    }


    func executePriorityChange(_ command: AmbitionsCommand, context: CommandExecutionContext) async -> AmbitionsCommandExecutionResult {
        guard command.target.captureID != nil else {
            return AmbitionsCommandExecutionResult(status: .unsupported, summary: "Priority changes are executable for captures only in this build.", target: command.target, metadata: ["blockedBy": "owning_system_not_implemented"])
        }
        return await executeCaptureRoute(command, context: context, kind: .raw, route: .captureInbox)
    }


    func executePlanSeedRepresentation(_ command: AmbitionsCommand, context: CommandExecutionContext) async -> AmbitionsCommandExecutionResult {
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

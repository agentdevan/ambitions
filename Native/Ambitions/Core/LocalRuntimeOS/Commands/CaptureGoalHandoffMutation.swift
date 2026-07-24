import CryptoKit
import Foundation

struct GoalImmutableIdentity: Sendable, Codable, Equatable {
    let id: String
    let createdAt: String

    init(_ goal: Goal) {
        id = goal.id
        createdAt = goal.createdAt
    }

    func matches(_ goal: Goal) -> Bool {
        goal.id == id && goal.createdAt == createdAt
    }
}

struct CaptureGoalHandoffPlan: Sendable, Codable, Equatable {
    let captureID: String
    let goalID: String
    let expectedCapture: Capture
    let expectedGoalIdentity: GoalImmutableIdentity
    let updatedCapture: Capture

    static func decode(command: AmbitionsCommand) -> Self? {
        guard case let .capture(value) = command.canonicalPayload,
              case let .attachToGoal(plan) = value.action else { return nil }
        return plan
    }
}

struct CaptureGoalHandoffRequest: Sendable, Equatable {
    let captureID: String
    let goalID: String
}

enum CaptureGoalHandoffOutcome: Sendable, Equatable {
    case attached(captureID: String, goalID: String, receiptID: String)
    case alreadyAttached(captureID: String, goalID: String)
    case failed(captureID: String, goalID: String, reason: String)

    var isAttached: Bool {
        switch self {
        case .attached, .alreadyAttached: true
        case .failed: false
        }
    }
}

enum CaptureGoalHandoffError: Error, LocalizedError, Equatable {
    case captureUnavailable
    case goalUnavailable
    case invalidTransition(CaptureStatus)
    case alreadyBoundToDifferentGoal(String)
    case staleCapture
    case recreatedGoal
    case materializerUnavailable

    var errorDescription: String? {
        switch self {
        case .captureUnavailable: "The source capture is no longer available."
        case .goalUnavailable: "The created goal is no longer available."
        case let .invalidTransition(status): "A capture in \(status.title) cannot be attached."
        case let .alreadyBoundToDifferentGoal(goalID): "The capture is already attached to goal \(goalID)."
        case .staleCapture: "The capture changed before it could be attached."
        case .recreatedGoal: "The original created goal no longer exists."
        case .materializerUnavailable: "The capture-to-goal handoff cannot be saved on this device."
        }
    }
}

struct PreparedCaptureGoalHandoff: Sendable {
    let command: AmbitionsCommand
    let context: CommandExecutionContext
}

struct CaptureGoalHandoffPlanner: Sendable {
    let repositories: AppRepositories

    func prepare(_ request: CaptureGoalHandoffRequest, now: Date) async throws -> PreparedCaptureGoalHandoff {
        guard let capture = try await repositories.captures.capture(id: request.captureID) else {
            throw CaptureGoalHandoffError.captureUnavailable
        }
        guard let goal = try await repositories.goals.goal(id: request.goalID) else {
            throw CaptureGoalHandoffError.goalUnavailable
        }
        if capture.status == .goalBound,
           let linkedGoalID = capture.linkedGoalID,
           linkedGoalID != goal.id {
            throw CaptureGoalHandoffError.alreadyBoundToDifferentGoal(linkedGoalID)
        }
        guard capture.status.canTransition(to: .goalBound) else {
            throw CaptureGoalHandoffError.invalidTransition(capture.status)
        }
        let expectedCaptureChecksum = try Self.checksum(capture)
        let commandID = [
            "command.stage.capture-goal-handoff", capture.id, goal.id,
            "expected", expectedCaptureChecksum
        ].joined(separator: ".")
        let updated = attachedCapture(capture, goalID: goal.id, now: now)
        let plan = CaptureGoalHandoffPlan(
            captureID: capture.id,
            goalID: goal.id,
            expectedCapture: capture,
            expectedGoalIdentity: GoalImmutableIdentity(goal),
            updatedCapture: updated
        )
        let command = AmbitionsCommand(
            id: commandID,
            source: .capture,
            typedPayload: .capture(CaptureCommand(
                action: .attachToGoal(plan),
                target: AmbitionsCommandTarget(goalID: goal.id, captureID: capture.id, destination: .goals),
                content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Attach capture to created goal"))
            )),
            createdAt: DomainTimestamp.string(from: now),
            actor: .user,
            sourceSurface: "Stage",
            privacy: .privateUserText
        )
        return PreparedCaptureGoalHandoff(
            command: command,
            context: CommandExecutionContext(now: now, actor: .user, sourceSurface: "Stage")
        )
    }

    private static func checksum(_ capture: Capture) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return SHA256.hash(data: try encoder.encode(capture))
            .map { String(format: "%02x", $0) }
            .joined()
    }

    private func attachedCapture(_ capture: Capture, goalID: String, now: Date) -> Capture {
        Capture(
            id: capture.id,
            createdAt: capture.createdAt,
            updatedAt: DomainTimestamp.string(from: now),
            rawText: capture.rawText,
            sourceType: capture.sourceType,
            status: .goalBound,
            linkedGoalID: goalID,
            triage: CaptureTriageMetadata(destination: .attachToGoal, hint: capture.triage?.hint),
            revisitAfter: capture.revisitAfter,
            kind: .goalSupportingTask,
            route: .goalAttachment,
            triageStatus: .routed,
            commitmentKind: .goalSupporting,
            deadlineText: capture.deadlineText,
            deadlineKind: capture.deadlineKind,
            contextLensHint: capture.contextLensHint,
            priorityHints: CapturePriorityHints(
                importance: capture.priorityHints.importance,
                urgency: capture.priorityHints.urgency,
                consequence: capture.priorityHints.consequence,
                deadline: capture.priorityHints.deadline,
                effort: capture.priorityHints.effort,
                contextFit: capture.priorityHints.contextFit,
                optionalSomeday: capture.priorityHints.optionalSomeday,
                passive: capture.priorityHints.passive,
                goalSupporting: true
            ),
            goalRelationship: CaptureGoalRelationship(
                goalID: goalID,
                relationshipKind: .nextAction,
                note: capture.goalRelationship?.note
            ),
            deliverableHint: capture.deliverableHint,
            scopeItemHint: capture.scopeItemHint,
            waitingMetadata: capture.waitingMetadata,
            assumptionSummary: "This capture is attached to an existing goal.",
            correctionActions: capture.correctionActions,
            recommendationExplanationIDs: capture.recommendationExplanationIDs,
            localOnly: capture.localOnly,
            privacy: capture.privacy
        )
    }
}

protocol CaptureGoalHandoffMaterializing: Sendable {
    func validate(_ plan: CaptureGoalHandoffPlan) async throws
    func materialize(_ plan: CaptureGoalHandoffPlan) async throws
}

struct RepositoryCaptureGoalHandoffMaterializer: CaptureGoalHandoffMaterializing {
    let repositories: AppRepositories

    func validate(_ plan: CaptureGoalHandoffPlan) async throws {
        guard let goal = try await repositories.goals.goal(id: plan.goalID) else {
            throw CaptureGoalHandoffError.goalUnavailable
        }
        guard plan.expectedGoalIdentity.matches(goal) else { throw CaptureGoalHandoffError.recreatedGoal }
        guard let capture = try await repositories.captures.capture(id: plan.captureID) else {
            throw CaptureGoalHandoffError.captureUnavailable
        }
        if capture == plan.updatedCapture { return }
        guard capture == plan.expectedCapture else { throw CaptureGoalHandoffError.staleCapture }
    }

    func materialize(_ plan: CaptureGoalHandoffPlan) async throws {
        _ = plan
        throw CaptureGoalHandoffError.materializerUnavailable
    }
}

struct CaptureGoalHandoffService: Sendable {
    let repositories: AppRepositories
    let runtimeClient: RuntimeCommandClient

    func perform(_ request: CaptureGoalHandoffRequest, now: Date) async -> CaptureGoalHandoffOutcome {
        do {
            if let capture = try await repositories.captures.capture(id: request.captureID),
               capture.status == .goalBound {
                guard capture.linkedGoalID == request.goalID else {
                    return .failed(
                        captureID: request.captureID,
                        goalID: request.goalID,
                        reason: CaptureGoalHandoffError.alreadyBoundToDifferentGoal(
                            capture.linkedGoalID ?? "unknown"
                        ).localizedDescription
                    )
                }
                guard try await repositories.goals.goal(id: request.goalID) != nil else {
                    return .failed(
                        captureID: request.captureID,
                        goalID: request.goalID,
                        reason: CaptureGoalHandoffError.goalUnavailable.localizedDescription
                    )
                }
                return .alreadyAttached(captureID: request.captureID, goalID: request.goalID)
            }
            let prepared = try await CaptureGoalHandoffPlanner(repositories: repositories).prepare(request, now: now)
            let result = await runtimeClient.execute(prepared.command, prepared.context)
            guard result.status == .succeeded,
                  result.target?.captureID == request.captureID,
                  result.target?.goalID == request.goalID,
                  result.metadata["runtimeProjectionStoreStatus"] == "saved",
                  result.metadata["captureGoalHandoffMaterialization"] == "saved_post_authority",
                  await Self.hasMatchingGoalsProjection(result, client: runtimeClient),
                  let receiptID = result.metadata["runtimeReceiptID"] else {
                return .failed(
                    captureID: request.captureID,
                    goalID: request.goalID,
                    reason: result.metadata["captureGoalHandoffMaterializationError"]
                        ?? result.metadata["runtimeProjectionStoreError"]
                        ?? result.summary
                )
            }
            return .attached(captureID: request.captureID, goalID: request.goalID, receiptID: receiptID)
        } catch {
            return .failed(captureID: request.captureID, goalID: request.goalID, reason: error.localizedDescription)
        }
    }

    private static func hasMatchingGoalsProjection(
        _ result: AmbitionsCommandExecutionResult,
        client: RuntimeCommandClient
    ) async -> Bool {
        guard let projection = try? await client.projection(.goals) else { return false }
        let ids = result.metadata["runtimeMaterializedProjectionCursorIDs"]?
            .split(separator: ",").map(String.init) ?? []
        let sequences = result.metadata["runtimeMaterializedProjectionCursorSequences"]?
            .split(separator: ",").compactMap { Int64($0) } ?? []
        let checksums = result.metadata["runtimeMaterializedProjectionCursorChecksums"]?
            .split(separator: ",").map(String.init) ?? []
        guard ids.count == sequences.count, ids.count == checksums.count,
              let index = ids.firstIndex(of: ProjectionID.goals.rawValue) else { return false }
        return projection.projectionID == ProjectionID.goals.rawValue
            && projection.eventSequence == sequences[index]
            && projection.cursorChecksum == checksums[index]
    }
}

extension AmbitionsCommand {
    var isCaptureGoalHandoffMutation: Bool {
        CaptureGoalHandoffPlan.decode(command: self) != nil
    }
}

extension AmbitionsCommandExecutor {
    func executeCaptureGoalHandoff(_ command: AmbitionsCommand) async -> AmbitionsCommandExecutionResult {
        guard let plan = CaptureGoalHandoffPlan.decode(command: command),
              plan.captureID == command.target.captureID,
              plan.goalID == command.target.goalID else {
            return AmbitionsCommandExecutionResult(
                status: .blocked,
                summary: "Capture-to-goal handoff plan is missing or does not match its target.",
                route: .goals,
                target: command.target,
                metadata: ["blockedBy": "capture_goal_handoff_plan_invalid"]
            )
        }
        do {
            guard let captureGoalHandoffMaterializer else {
                throw CaptureGoalHandoffError.materializerUnavailable
            }
            try await captureGoalHandoffMaterializer.validate(plan)
        } catch {
            return AmbitionsCommandExecutionResult(
                status: .blocked,
                summary: "Capture-to-goal handoff could not be committed because its source changed.",
                route: .goals,
                target: command.target,
                metadata: ["blockedBy": "capture_goal_handoff_stale_or_unavailable"]
            )
        }
        return AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Capture-to-goal handoff committed.",
            route: .goals,
            target: command.target,
            metadata: [
                "captureGoalHandoffMaterialization": "pending_authority_commit",
                "projectionReloadRequired": "true"
            ]
        )
    }

    func materializeCaptureGoalHandoff(
        _ command: AmbitionsCommand,
        committedResult: AmbitionsCommandExecutionResult
    ) async -> AmbitionsCommandExecutionResult {
        guard let captureGoalHandoffMaterializer else {
            return committedResult.mergingMetadata([
                "captureGoalHandoffMaterialization": "needs_recovery",
                "captureGoalHandoffMaterializationError": "materializer_unavailable"
            ])
        }
        do {
            let envelopes = try await runtimeEvents?.fetchEvents(matching: .commandID(command.id), limit: nil) ?? []
            guard let plan = try envelopes.compactMap({ envelope -> CaptureGoalHandoffPlan? in
                guard case let .domainMutation(record) = envelope.event.payload,
                      case let .captureGoalHandoffApplied(value) = try record.decodedEvent() else { return nil }
                return value
            }).first else {
                throw CaptureGoalHandoffError.materializerUnavailable
            }
            try await captureGoalHandoffMaterializer.materialize(plan)
            return committedResult.mergingMetadata([
                "captureGoalHandoffMaterialization": "saved_post_authority"
            ])
        } catch {
            return committedResult.mergingMetadata([
                "captureGoalHandoffMaterialization": "needs_recovery",
                "captureGoalHandoffMaterializationError": String(describing: error)
            ])
        }
    }
}

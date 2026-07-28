import Foundation

private let protectedStepPlacementGuardVersion = "protected_step_placement_policy.native.v1"

struct ProtectedStepPlacementWindow: Codable, Sendable, Equatable, Hashable {
    let start: Date
    let end: Date

    init?(start: Date, end: Date) {
        guard end > start else { return nil }
        self.start = start
        self.end = end
    }

    func intersects(_ other: ProtectedStepPlacementWindow) -> Bool {
        start < other.end && other.start < end
    }
}

enum ProtectedStepPlacementDecisionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case allowed
    case requiresExplicitApproval = "requires_explicit_approval"
    case blockedFromSilentMovement = "blocked_from_silent_movement"
    case pendingReview = "pending_review"
}

enum ProtectedStepPlacementTrigger: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case automatic
    case userInitiated = "user_initiated"
    case missedRecoveryMoveIt = "missed_recovery_move_it"
    case externalSurface = "external_surface"
}

enum ProtectedStepPlacementAutomationPolicy: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case notApplicable = "not_applicable"
    case allowedByExistingPolicy = "allowed_by_existing_policy"
    case notMature = "not_mature"
}

enum ProtectedStepPlacementContextQuality: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case sufficient
    case lowContext = "low_context"
}

struct ProtectedStepPlacementDecision: Codable, Sendable, Equatable, Hashable {
    let kind: ProtectedStepPlacementDecisionKind
    let stepID: String
    let trigger: ProtectedStepPlacementTrigger
    let protectedWindow: ProtectedStepPlacementWindow
    let placementChanged: Bool
    let affectsProtectedWindow: Bool
    let requiresExplicitApproval: Bool
    let canApplySilently: Bool
    let canApplyWithExplicitAction: Bool
    let requiresAccount: Bool
    let localOnly: Bool
    let summary: String
    let userImpactSummary: String
    let blockedFacts: [String]
    let degradedFacts: [String]
    let schemaVersion: String
}

struct ProtectedStepPlacementPolicy: Sendable {
    private let protectedWindowDuration: TimeInterval

    init(protectedDays: Int = 7) {
        self.protectedWindowDuration = TimeInterval(max(protectedDays, 1) * 24 * 60 * 60)
    }

    func evaluate(
        now: Date,
        stepID: String,
        originalPlacement: ProtectedStepPlacementWindow?,
        proposedPlacement: ProtectedStepPlacementWindow?,
        trigger: ProtectedStepPlacementTrigger,
        explicitUserApproval: Bool,
        automationPolicy: ProtectedStepPlacementAutomationPolicy,
        contextQuality: ProtectedStepPlacementContextQuality,
        localOnly: Bool
    ) -> ProtectedStepPlacementDecision {
        let protectedWindow = ProtectedStepPlacementWindow(
            start: now,
            end: now.addingTimeInterval(protectedWindowDuration)
        )!
        let normalizedStepID = stepID.trimmingCharacters(in: .whitespacesAndNewlines)

        guard normalizedStepID.isEmpty == false, let proposedPlacement else {
            return decision(
                .blockedFromSilentMovement,
                stepID: normalizedStepID.isEmpty ? "unknown-step" : normalizedStepID,
                trigger: trigger,
                protectedWindow: protectedWindow,
                placementChanged: true,
                affectsProtectedWindow: false,
                requiresExplicitApproval: true,
                canApplySilently: false,
                canApplyWithExplicitAction: false,
                localOnly: localOnly,
                summary: "Placement could not be evaluated without a Step and proposed window.",
                userImpactSummary: "Review is needed before this placement changes.",
                blockedFacts: ["Missing placement facts prevent a safe scheduled Step change."]
            )
        }

        guard localOnly else {
            return decision(
                .blockedFromSilentMovement,
                stepID: normalizedStepID,
                trigger: trigger,
                protectedWindow: protectedWindow,
                placementChanged: true,
                affectsProtectedWindow: proposedPlacement.intersects(protectedWindow),
                requiresExplicitApproval: true,
                canApplySilently: false,
                canApplyWithExplicitAction: false,
                localOnly: false,
                summary: "Protected placement is local-only.",
                userImpactSummary: "No scheduled Step placement was changed.",
                blockedFacts: ["Protected placement cannot depend on account, network, R2, or hosted services."]
            )
        }

        let placementChanged = originalPlacement.map { $0 != proposedPlacement } ?? true
        let affectsProtectedWindow = proposedPlacement.intersects(protectedWindow) ||
            (originalPlacement?.intersects(protectedWindow) ?? false)

        guard placementChanged else {
            return decision(
                .allowed,
                stepID: normalizedStepID,
                trigger: trigger,
                protectedWindow: protectedWindow,
                placementChanged: false,
                affectsProtectedWindow: affectsProtectedWindow,
                requiresExplicitApproval: false,
                canApplySilently: true,
                canApplyWithExplicitAction: true,
                localOnly: true,
                summary: "Placement is unchanged.",
                userImpactSummary: "No scheduled placement changes."
            )
        }

        if affectsProtectedWindow {
            switch trigger {
            case .automatic:
                if explicitUserApproval {
                    return allowedExplicitDecision(
                        stepID: normalizedStepID,
                        trigger: trigger,
                        protectedWindow: protectedWindow,
                        summary: "Approved automatic placement may apply inside the protected window."
                    )
                }
                return decision(
                    .blockedFromSilentMovement,
                    stepID: normalizedStepID,
                    trigger: trigger,
                    protectedWindow: protectedWindow,
                    placementChanged: true,
                    affectsProtectedWindow: true,
                    requiresExplicitApproval: true,
                    canApplySilently: false,
                    canApplyWithExplicitAction: false,
                    localOnly: true,
                    summary: "Automatic placement cannot silently move a Step inside the next seven days.",
                    userImpactSummary: "Review this before the scheduled placement changes.",
                    blockedFacts: ["Scheduled placement inside the next seven days requires explicit awareness or approval."]
                )
            case .userInitiated, .missedRecoveryMoveIt, .externalSurface:
                guard explicitUserApproval else {
                    return decision(
                        .requiresExplicitApproval,
                        stepID: normalizedStepID,
                        trigger: trigger,
                        protectedWindow: protectedWindow,
                        placementChanged: true,
                        affectsProtectedWindow: true,
                        requiresExplicitApproval: true,
                        canApplySilently: false,
                        canApplyWithExplicitAction: false,
                        localOnly: true,
                        summary: "Placement inside the next seven days needs an explicit user action.",
                        userImpactSummary: impactSummary(for: trigger, approved: false),
                        blockedFacts: ["The Step remains in place until the user approves the change."]
                    )
                }
                return allowedExplicitDecision(
                    stepID: normalizedStepID,
                    trigger: trigger,
                    protectedWindow: protectedWindow,
                    summary: "Explicit user action approved a protected placement change."
                )
            }
        }

        guard trigger == .automatic else {
            return allowedExplicitDecision(
                stepID: normalizedStepID,
                trigger: trigger,
                protectedWindow: protectedWindow,
                summary: "User-initiated placement outside the protected window may apply."
            )
        }

        guard contextQuality == .sufficient, automationPolicy == .allowedByExistingPolicy else {
            return decision(
                .pendingReview,
                stepID: normalizedStepID,
                trigger: trigger,
                protectedWindow: protectedWindow,
                placementChanged: true,
                affectsProtectedWindow: false,
                requiresExplicitApproval: true,
                canApplySilently: false,
                canApplyWithExplicitAction: false,
                localOnly: true,
                summary: "Automatic future placement is pending review until the runtime policy is explicit.",
                userImpactSummary: "The proposed future placement is held for review.",
                degradedFacts: ["Automation policy is not mature enough to silently adjust scheduled placement."]
            )
        }

        return decision(
            .allowed,
            stepID: normalizedStepID,
            trigger: trigger,
            protectedWindow: protectedWindow,
            placementChanged: true,
            affectsProtectedWindow: false,
            requiresExplicitApproval: false,
            canApplySilently: true,
            canApplyWithExplicitAction: true,
            localOnly: true,
            summary: "Automatic placement outside the protected window is allowed by existing policy.",
            userImpactSummary: "A future placement outside the next seven days may change."
        )
    }

    func evaluate(
        command: AmbitionsCommand,
        context: CommandExecutionContext
    ) -> ProtectedStepPlacementDecision? {
        guard case let .schedule(schedule) = command.typedPayload else { return nil }
        switch schedule.action {
        case .schedule, .placeStep, .calendarWrite: break
        case .createItem, .protectWindow, .correctWindow, .undo, .ritual: return nil
        }
        guard let stepID = command.protectedPlacementStepID,
              let proposedPlacement = command.protectedPlacementWindow(
                startKeys: ["proposedStartAt", "startAt", "start", "windowStart", "destinationStartAt"],
                endKeys: ["proposedEndAt", "endAt", "end", "windowEnd", "destinationEndAt"],
                durationKeys: ["approvedDurationMinutes", "durationMinutes"]
              ) else {
            return nil
        }

        let originalPlacement = command.protectedPlacementWindow(
            startKeys: ["originalStartAt", "originalStart", "currentStartAt", "currentStart", "previousStartAt", "previousStart", "originalWindowStart"],
            endKeys: ["originalEndAt", "originalEnd", "currentEndAt", "currentEnd", "previousEndAt", "previousEnd", "originalWindowEnd"],
            durationKeys: ["originalDurationMinutes", "currentDurationMinutes", "durationMinutes"]
        )

        return evaluate(
            now: context.now,
            stepID: stepID,
            originalPlacement: originalPlacement,
            proposedPlacement: proposedPlacement,
            trigger: command.protectedPlacementTrigger,
            explicitUserApproval: command.hasExplicitProtectedPlacementApproval,
            automationPolicy: command.protectedPlacementAutomationPolicy,
            contextQuality: command.protectedPlacementContextQuality,
            localOnly: command.localOnly
        )
    }

    private func allowedExplicitDecision(
        stepID: String,
        trigger: ProtectedStepPlacementTrigger,
        protectedWindow: ProtectedStepPlacementWindow,
        summary: String
    ) -> ProtectedStepPlacementDecision {
        decision(
            .allowed,
            stepID: stepID,
            trigger: trigger,
            protectedWindow: protectedWindow,
            placementChanged: true,
            affectsProtectedWindow: true,
            requiresExplicitApproval: false,
            canApplySilently: false,
            canApplyWithExplicitAction: true,
            localOnly: true,
            summary: summary,
            userImpactSummary: impactSummary(for: trigger, approved: true)
        )
    }

    private func decision(
        _ kind: ProtectedStepPlacementDecisionKind,
        stepID: String,
        trigger: ProtectedStepPlacementTrigger,
        protectedWindow: ProtectedStepPlacementWindow,
        placementChanged: Bool,
        affectsProtectedWindow: Bool,
        requiresExplicitApproval: Bool,
        canApplySilently: Bool,
        canApplyWithExplicitAction: Bool,
        localOnly: Bool,
        summary: String,
        userImpactSummary: String,
        blockedFacts: [String] = [],
        degradedFacts: [String] = []
    ) -> ProtectedStepPlacementDecision {
        ProtectedStepPlacementDecision(
            kind: kind,
            stepID: stepID,
            trigger: trigger,
            protectedWindow: protectedWindow,
            placementChanged: placementChanged,
            affectsProtectedWindow: affectsProtectedWindow,
            requiresExplicitApproval: requiresExplicitApproval,
            canApplySilently: canApplySilently,
            canApplyWithExplicitAction: canApplyWithExplicitAction,
            requiresAccount: false,
            localOnly: localOnly,
            summary: summary,
            userImpactSummary: userImpactSummary,
            blockedFacts: blockedFacts,
            degradedFacts: degradedFacts,
            schemaVersion: protectedStepPlacementGuardVersion
        )
    }

    private func impactSummary(for trigger: ProtectedStepPlacementTrigger, approved: Bool) -> String {
        switch trigger {
        case .missedRecoveryMoveIt:
            return approved
                ? "Move it is explicit. What changed? The Step gets a new placement, and Still counts remains true."
                : "Move it needs review before the Step changes placement. Still counts."
        case .userInitiated:
            return approved
                ? "The user approved this scheduled placement change."
                : "Review the placement change before applying it."
        case .externalSurface:
            return approved
                ? "The external action was confirmed before changing scheduled placement."
                : "Open Ambitions to review this scheduled placement change."
        case .automatic:
            return approved
                ? "The automatic placement change has explicit approval."
                : "Review this automatic placement change before it applies."
        }
    }
}

private extension AmbitionsCommand {
    var protectedPlacementStepID: String? {
        target.stepID ?? calendarWriteCommandIntent?.destinationStepID?.rawValue
    }

    var protectedPlacementTrigger: ProtectedStepPlacementTrigger {
        if let trigger = timePlacementCommandIntent?.trigger ?? calendarWriteCommandIntent?.placement?.trigger {
            return trigger
        }
        if actor == .system || source == .system {
            return .automatic
        }
        if actor == .externalSurface || [.widget, .liveActivity, .appIntent, .notification, .deepLink].contains(source) {
            return .externalSurface
        }
        return .userInitiated
    }

    var hasExplicitProtectedPlacementApproval: Bool {
        if let explicit = timePlacementCommandIntent?.explicitUserApproval ?? calendarWriteCommandIntent?.placement?.explicitUserApproval {
            return explicit
        }
        switch protectedPlacementTrigger {
        case .userInitiated, .missedRecoveryMoveIt:
            return actor == .user
        case .automatic, .externalSurface:
            return false
        }
    }

    var protectedPlacementAutomationPolicy: ProtectedStepPlacementAutomationPolicy {
        timePlacementCommandIntent?.automationPolicy ?? calendarWriteCommandIntent?.placement?.automationPolicy ?? .notMature
    }

    var protectedPlacementContextQuality: ProtectedStepPlacementContextQuality {
        timePlacementCommandIntent?.contextQuality ?? calendarWriteCommandIntent?.placement?.contextQuality ?? .sufficient
    }

    func protectedPlacementWindow(
        startKeys: [String],
        endKeys: [String],
        durationKeys: [String]
    ) -> ProtectedStepPlacementWindow? {
        let placement = timePlacementCommandIntent ?? calendarWriteCommandIntent?.placement
        guard let placement else { return nil }
        let original = startKeys.contains(where: { $0.hasPrefix("original") || $0.hasPrefix("current") || $0.hasPrefix("previous") })
        guard let start = DomainTimestamp.date(from: original ? placement.originalStart ?? "" : placement.start),
              let end = DomainTimestamp.date(from: original ? placement.originalEnd ?? "" : placement.end) else { return nil }
        return ProtectedStepPlacementWindow(start: start, end: end)
    }
}

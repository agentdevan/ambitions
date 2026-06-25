import Foundation

private let priorityPlacementPolicyVersion = "priority_placement_policy.native.v1"

enum PlacementPriority: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case low
    case normal
    case high

    var userFacingLabel: String {
        switch self {
        case .low:
            return "Low"
        case .normal:
            return "Normal"
        case .high:
            return "High"
        }
    }

    static func userFacingValue(from rawValue: String) -> PlacementPriority? {
        let normalized = rawValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
        switch normalized {
        case "low":
            return .low
        case "normal":
            return .normal
        case "high":
            return .high
        default:
            return nil
        }
    }
}

enum PlacementPrioritySource: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case userOverride = "user_override"
    case commandHint = "command_hint"
    case defaulted = "defaulted"
    case lowContext = "low_context"
}

enum PriorityPlacementReviewDisposition: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case readyForReview = "ready_for_review"
    case pendingReview = "pending_review"
    case deferSuggestion = "defer_suggestion"
}

struct PriorityPlacementInput: Sendable, Equatable, Hashable {
    let stepID: String
    let priority: PlacementPriority?
    let source: PlacementPrioritySource
    let userOverride: PlacementPriority?
    let contextQuality: ProtectedStepPlacementContextQuality
    let localOnly: Bool

    init(
        stepID: String,
        priority: PlacementPriority? = nil,
        source: PlacementPrioritySource = .defaulted,
        userOverride: PlacementPriority? = nil,
        contextQuality: ProtectedStepPlacementContextQuality = .sufficient,
        localOnly: Bool = true
    ) {
        self.stepID = stepID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.priority = priority
        self.source = source
        self.userOverride = userOverride
        self.contextQuality = contextQuality
        self.localOnly = localOnly
    }

    static func fromCommand(_ command: AmbitionsCommand) -> PriorityPlacementInput {
        let metadataPriority = command.payload.metadata["placementPriority"]
            ?? command.payload.metadata["priority"]
            ?? command.payload.metadata["userPriority"]
        let userOverride = metadataPriority.flatMap(PlacementPriority.userFacingValue(from:))
        let hintedPriority = userOverride ?? PlacementPriority.fromHints(command.payload.priorityHints)
        let source: PlacementPrioritySource
        if userOverride != nil {
            source = .userOverride
        } else if hintedPriority != nil {
            source = .commandHint
        } else if Self.contextQuality(from: command) == .lowContext {
            source = .lowContext
        } else {
            source = .defaulted
        }

        return PriorityPlacementInput(
            stepID: command.target.stepID ?? command.payload.metadata["stepID"] ?? "unknown-step",
            priority: hintedPriority,
            source: source,
            userOverride: userOverride,
            contextQuality: Self.contextQuality(from: command),
            localOnly: command.localOnly
        )
    }

    private static func contextQuality(from command: AmbitionsCommand) -> ProtectedStepPlacementContextQuality {
        let raw = command.payload.metadata["protectedPlacementContextQuality"]
            ?? command.payload.metadata["contextQuality"]
        return raw.flatMap(ProtectedStepPlacementContextQuality.init(rawValue:)) ?? .sufficient
    }
}

struct PriorityPlacementDecision: Codable, Sendable, Equatable, Hashable {
    let priority: PlacementPriority
    let source: PlacementPrioritySource
    let userOverride: PlacementPriority?
    let reviewDisposition: PriorityPlacementReviewDisposition
    let protectedPlacementKind: ProtectedStepPlacementDecisionKind?
    let requiresExplicitApproval: Bool
    let canBypassProtectedApproval: Bool
    let requiresAccount: Bool
    let localOnly: Bool
    let reviewNote: String
    let blockedFacts: [String]
    let degradedFacts: [String]
    let schemaVersion: String

    var isUserOverride: Bool {
        userOverride != nil || source == .userOverride
    }
}

struct PriorityPlacementPolicy: Sendable {
    func evaluate(
        input: PriorityPlacementInput,
        protectedPlacementDecision: ProtectedStepPlacementDecision? = nil
    ) -> PriorityPlacementDecision {
        let normalizedPriority = input.userOverride ?? input.priority ?? .normal
        let protectedRequiresApproval = protectedPlacementDecision?.requiresExplicitApproval ?? false
        let blockedFacts = input.localOnly ? [] : ["Priority placement must stay local and account-free."]

        if input.localOnly == false {
            return decision(
                priority: normalizedPriority,
                source: input.source,
                userOverride: input.userOverride,
                reviewDisposition: .pendingReview,
                protectedPlacementDecision: protectedPlacementDecision,
                requiresExplicitApproval: true,
                reviewNote: "This needs review.",
                blockedFacts: blockedFacts
            )
        }

        if input.contextQuality == .lowContext {
            return decision(
                priority: normalizedPriority,
                source: input.source == .userOverride ? .userOverride : .lowContext,
                userOverride: input.userOverride,
                reviewDisposition: .pendingReview,
                protectedPlacementDecision: protectedPlacementDecision,
                requiresExplicitApproval: protectedRequiresApproval,
                reviewNote: "Priority can help Ambitions choose what to review first, but this still needs review.",
                degradedFacts: ["Low context cannot create confident priority placement."]
            )
        }

        switch normalizedPriority {
        case .high:
            return decision(
                priority: .high,
                source: input.source,
                userOverride: input.userOverride,
                reviewDisposition: .readyForReview,
                protectedPlacementDecision: protectedPlacementDecision,
                requiresExplicitApproval: protectedRequiresApproval,
                reviewNote: "Priority can help Ambitions choose what to review first, but this move still needs approval."
            )
        case .normal:
            return decision(
                priority: .normal,
                source: input.source,
                userOverride: input.userOverride,
                reviewDisposition: .readyForReview,
                protectedPlacementDecision: protectedPlacementDecision,
                requiresExplicitApproval: protectedRequiresApproval,
                reviewNote: "Priority can help Ambitions choose what to review first."
            )
        case .low:
            return decision(
                priority: .low,
                source: input.source,
                userOverride: input.userOverride,
                reviewDisposition: .deferSuggestion,
                protectedPlacementDecision: protectedPlacementDecision,
                requiresExplicitApproval: protectedRequiresApproval,
                reviewNote: "Priority is Low, so Ambitions can hold this for review before making room."
            )
        }
    }

    private func decision(
        priority: PlacementPriority,
        source: PlacementPrioritySource,
        userOverride: PlacementPriority?,
        reviewDisposition: PriorityPlacementReviewDisposition,
        protectedPlacementDecision: ProtectedStepPlacementDecision?,
        requiresExplicitApproval: Bool,
        reviewNote: String,
        blockedFacts: [String] = [],
        degradedFacts: [String] = []
    ) -> PriorityPlacementDecision {
        PriorityPlacementDecision(
            priority: priority,
            source: source,
            userOverride: userOverride,
            reviewDisposition: reviewDisposition,
            protectedPlacementKind: protectedPlacementDecision?.kind,
            requiresExplicitApproval: requiresExplicitApproval,
            canBypassProtectedApproval: false,
            requiresAccount: false,
            localOnly: blockedFacts.isEmpty,
            reviewNote: reviewNote,
            blockedFacts: blockedFacts,
            degradedFacts: degradedFacts,
            schemaVersion: priorityPlacementPolicyVersion
        )
    }
}

private extension PlacementPriority {
    static func fromHints(_ hints: AmbitionsCommandPriorityHints) -> PlacementPriority? {
        if hints.userPreference == .high || hints.importance == .high || hints.urgency == .high || hints.deadline == .high {
            return .high
        }
        if hints.userPreference == .low || hints.importance == .low || hints.urgency == .low || hints.deadline == .low {
            return .low
        }
        if hints.hasAnySignal {
            return .normal
        }
        return nil
    }
}

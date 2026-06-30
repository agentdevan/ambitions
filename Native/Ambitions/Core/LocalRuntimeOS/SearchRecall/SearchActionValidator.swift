import Foundation

let searchActionValidatorSchemaVersion = "search_recall_action_validator.native.v1"

enum SearchActionValidationState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case allowed
    case deniedPrivacy
    case deniedMissingTarget
    case deniedCommandValidation
    case deniedNonLocal
    case deniedFamily
}

struct SearchActionValidationReport: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let resultID: String
    let state: SearchActionValidationState
    let commandValidationState: AmbitionsCommandValidationState
    let reasons: [String]
    let validatedAt: String
    let schemaVersion: String

    init(
        resultID: String,
        state: SearchActionValidationState,
        commandValidationState: AmbitionsCommandValidationState,
        reasons: [String],
        validatedAt: String,
        schemaVersion: String = searchActionValidatorSchemaVersion
    ) {
        self.id = "\(resultID).validation.\(state.rawValue)"
        self.resultID = resultID
        self.state = state
        self.commandValidationState = commandValidationState
        self.reasons = Array(Set(reasons.filter { $0.isEmpty == false })).sorted()
        self.validatedAt = validatedAt
        self.schemaVersion = schemaVersion
    }

    var isAllowed: Bool {
        state == .allowed
    }
}

struct SearchActionValidator: Sendable {
    func validate(
        result: FindActInspectResult,
        query: SearchRecallQuery,
        actionKind: SearchRecallActionKind = .open,
        validatedAt: String
    ) -> SearchActionValidationReport {
        let action = actionKind == .open ? result.primaryAction : result.inspectAction
        if query.allowedPrivacy.contains(result.privacy) == false {
            return report(
                result: result,
                state: .deniedPrivacy,
                commandState: action.validationState,
                reasons: ["Result privacy class is not included in the query privacy set."],
                validatedAt: validatedAt
            )
        }

        if let allowedFamilies = query.allowedFamilies, allowedFamilies.contains(result.family) == false {
            return report(
                result: result,
                state: .deniedFamily,
                commandState: action.validationState,
                reasons: ["Result family is not included in the query family set."],
                validatedAt: validatedAt
            )
        }

        if query.requiresLocalOnly, result.localOnly == false || action.localOnly == false {
            return report(
                result: result,
                state: .deniedNonLocal,
                commandState: action.validationState,
                reasons: ["Search action is not marked local-only."],
                validatedAt: validatedAt
            )
        }

        if action.validationState != .valid {
            return report(
                result: result,
                state: .deniedCommandValidation,
                commandState: action.validationState,
                reasons: ["Search action command validation is \(action.validationState.rawValue)."],
                validatedAt: validatedAt
            )
        }

        if hasActionTarget(action.target) == false {
            return report(
                result: result,
                state: .deniedMissingTarget,
                commandState: .needsMissingTarget,
                reasons: ["Search action has no object target or destination."],
                validatedAt: validatedAt
            )
        }

        return report(
            result: result,
            state: .allowed,
            commandState: .valid,
            reasons: ["Search action can produce a local command without private egress."],
            validatedAt: validatedAt
        )
    }

    private func hasActionTarget(_ target: AmbitionsCommandTarget) -> Bool {
        target.goalID != nil ||
            target.captureID != nil ||
            target.timeID != nil ||
            target.reviewID != nil ||
            target.stepID != nil ||
            target.deliverableID != nil ||
            target.scopeItemID != nil ||
            target.recommendationID != nil ||
            target.explanationID != nil ||
            target.destination != nil
    }

    private func report(
        result: FindActInspectResult,
        state: SearchActionValidationState,
        commandState: AmbitionsCommandValidationState,
        reasons: [String],
        validatedAt: String
    ) -> SearchActionValidationReport {
        SearchActionValidationReport(
            resultID: result.id,
            state: state,
            commandValidationState: commandState,
            reasons: reasons,
            validatedAt: validatedAt
        )
    }
}

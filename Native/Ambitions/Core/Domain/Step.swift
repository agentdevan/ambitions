import Foundation

struct StepActionability: Codable, Sendable, Equatable {
    let action: String
    let completionDefinition: String
    let evidenceOfCompletion: [String]
    let fallbackMicroStep: String
    let contextRequirements: [String]
}

struct Step: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let sectionID: String
    let title: String
    let summary: String?
    let type: StepType
    let state: StepLifecycleState
    let owner: GoalActor
    let timing: GoalTiming
    let dependencyStepIDs: [String]
    let isOptional: Bool
    let isRepeatable: Bool
    let evidenceRequired: Bool
    let successSignals: [String]
    let actionability: StepActionability
}

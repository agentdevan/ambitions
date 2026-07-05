import AmbitionsDesignSystem
import SwiftUI

// Accessibility companion: TodayStepReplacementSheet renders the proof, receipt, and VoiceOver review copy for this replacement blueprint.

    struct ReplacementBlueprint {
        let kind: StepCandidateKind
        let label: String
        let title: String
        let summary: String
        let minutes: Int
        let energy: Double
        let goalContribution: Double
        let deadlineContribution: Double
        let futurePressureImpact: Double
        let opportunityCost: Double
        let approvalRequired: Bool
        let validity: CandidateValidity
        let accessRequirements: [String]
        let equipmentRequirements: [String]
        let facilityRequirements: [String]
    }

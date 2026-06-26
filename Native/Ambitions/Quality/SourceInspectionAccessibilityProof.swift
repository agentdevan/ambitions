import Foundation

enum SourceInspectionAccessibilityConfiguration: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case voiceOver
    case dynamicTypeXXXL = "dynamic_type_xxxl"
    case reduceMotion = "reduce_motion"
    case privacyRedaction = "privacy_redaction"
    case hiddenByDefault = "hidden_by_default"
    case semanticStateAnnouncement = "semantic_state_announcement"
}

struct SourceInspectionAccessibilityProofRow: Identifiable, Codable, Sendable, Equatable, Hashable {
    let id: String
    let state: SourceInspectionState
    let configuration: SourceInspectionAccessibilityConfiguration
    let evidenceSummary: String
    let blocksPublicAccessibilityClaim: Bool
}

struct SourceInspectionAccessibilityProof: Codable, Sendable, Equatable, Hashable {
    let rows: [SourceInspectionAccessibilityProofRow]
    let renderedProofRequiredForPublicClaim: Bool
    let physicalDeviceProofRequiredForPublicClaim: Bool

    static func make(
        presentations: [SourceInspectionPresentation] = SourceInspectionPresentationFixtures.all
    ) -> SourceInspectionAccessibilityProof {
        let rows = presentations.flatMap { presentation in
            SourceInspectionAccessibilityConfiguration.allCases.map { configuration in
                SourceInspectionAccessibilityProofRow(
                    id: "\(presentation.state.rawValue)-\(configuration.rawValue)",
                    state: presentation.state,
                    configuration: configuration,
                    evidenceSummary: evidenceSummary(for: presentation, configuration: configuration),
                    blocksPublicAccessibilityClaim: true
                )
            }
        }

        return SourceInspectionAccessibilityProof(
            rows: rows,
            renderedProofRequiredForPublicClaim: true,
            physicalDeviceProofRequiredForPublicClaim: true
        )
    }

    func validationFailures() -> [String] {
        var failures: [String] = []
        let expectedRowCount = SourceInspectionState.allCases.count * SourceInspectionAccessibilityConfiguration.allCases.count
        if rows.count != expectedRowCount {
            failures.append("Source inspection accessibility proof must cover every state and required configuration.")
        }

        for state in SourceInspectionState.allCases {
            let stateRows = rows.filter { $0.state == state }
            if Set(stateRows.map(\.configuration)) != Set(SourceInspectionAccessibilityConfiguration.allCases) {
                failures.append("Source inspection accessibility proof is missing configuration coverage for \(state.rawValue).")
            }
            if stateRows.contains(where: { $0.evidenceSummary.isEmpty }) {
                failures.append("Source inspection accessibility proof rows must keep evidence summaries populated for \(state.rawValue).")
            }
        }

        if rows.contains(where: { $0.blocksPublicAccessibilityClaim == false }) {
            failures.append("Source inspection accessibility source proof must not claim public accessibility certification.")
        }
        if renderedProofRequiredForPublicClaim == false || physicalDeviceProofRequiredForPublicClaim == false {
            failures.append("Source inspection accessibility proof must keep rendered and device proof required for public claims.")
        }

        return failures
    }

    private static func evidenceSummary(
        for presentation: SourceInspectionPresentation,
        configuration: SourceInspectionAccessibilityConfiguration
    ) -> String {
        switch configuration {
        case .voiceOver:
            "\(presentation.accessibilityLabel). \(presentation.accessibilityValue)"
        case .dynamicTypeXXXL:
            "Rows use wrapping body text and preserve the state label before secondary details."
        case .reduceMotion:
            presentation.reduceMotionSummary
        case .privacyRedaction:
            presentation.redactionSummary
        case .hiddenByDefault:
            presentation.hiddenByDefaultSummary
        case .semanticStateAnnouncement:
            presentation.semanticAnnouncement
        }
    }
}

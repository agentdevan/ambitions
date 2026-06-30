import Foundation

struct PlanningRuleCounterfactualDiff: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let selectedTraceID: String
    let alternativeTraceID: String
    let selectedStepID: String
    let alternativeStepID: String
    let selectedStepTitle: String
    let alternativeStepTitle: String
    let selectedRank: Double
    let alternativeRank: Double
    let rankDelta: Double
    let selectedLocalFitLabel: String
    let alternativeLocalFitLabel: String
    let sourceRecordID: String
    let receiptID: String
    let replayTraceID: String
    let runtimeSnapshotReferenceID: String?
    let privacyClass: AFEPStoragePrivacyClass
    let exportPolicy: AFEPExportPolicy
    let redactionClass: RuntimeSnapshotFieldRedactionClass
    let summary: String
    let schemaVersion: String

    init(
        selectedTraceID: String,
        alternativeTraceID: String,
        selectedStepID: String,
        alternativeStepID: String,
        selectedStepTitle: String,
        alternativeStepTitle: String,
        selectedRank: Double,
        alternativeRank: Double,
        selectedLocalFitLabel: String,
        alternativeLocalFitLabel: String,
        sourceRecordID: String,
        receiptID: String,
        replayTraceID: String,
        runtimeSnapshotReferenceID: String? = nil,
        privacyClass: AFEPStoragePrivacyClass = .localOnly,
        exportPolicy: AFEPExportPolicy = .redacted,
        redactionClass: RuntimeSnapshotFieldRedactionClass = .localOnly,
        schemaVersion: String = planningRuleCounterfactualDiffSchemaVersion
    ) {
        self.selectedTraceID = selectedTraceID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.alternativeTraceID = alternativeTraceID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.selectedStepID = selectedStepID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.alternativeStepID = alternativeStepID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.selectedStepTitle = selectedStepTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        self.alternativeStepTitle = alternativeStepTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        self.selectedRank = selectedRank
        self.alternativeRank = alternativeRank
        self.rankDelta = ((alternativeRank - selectedRank) * 100).rounded() / 100
        self.selectedLocalFitLabel = selectedLocalFitLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        self.alternativeLocalFitLabel = alternativeLocalFitLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordID = sourceRecordID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.receiptID = receiptID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.replayTraceID = replayTraceID.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedRuntimeSnapshotReferenceID = runtimeSnapshotReferenceID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.runtimeSnapshotReferenceID = trimmedRuntimeSnapshotReferenceID?.isEmpty == true ? nil : trimmedRuntimeSnapshotReferenceID
        self.privacyClass = privacyClass
        self.exportPolicy = exportPolicy
        self.redactionClass = redactionClass
        self.summary = "Selected \(self.selectedStepTitle) stays ahead of \(self.alternativeStepTitle) by a deterministic local rank delta."
        self.schemaVersion = schemaVersion
        self.id = "planning-rule-counterfactual.\(self.selectedStepID).\(self.alternativeStepID)"
    }

    var isExportSafe: Bool {
        exportPolicy.isExportSafe && redactionClass != .redacted
    }

    var visibleCopy: [String] {
        [selectedStepTitle, alternativeStepTitle, selectedLocalFitLabel, alternativeLocalFitLabel, summary]
    }

    var hasVisibleCopyGuardrailViolation: Bool {
        visibleCopy.contains { text in
            let lowercased = text.lowercased()
            return lowercased.contains("ai ") ||
                lowercased.contains("assistant") ||
                lowercased.contains("confidence") ||
                text.contains("%")
        }
    }
}

extension PlanningRuleTrace {
    static func counterfactualDiffs(
        selected selectedSelection: PlanningNextStepSelection,
        alternatives: [PlanningNextStepSelection],
        runtimeSnapshotReferenceID: String? = nil
    ) -> [PlanningRuleCounterfactualDiff] {
        let selectedTrace = trace(for: selectedSelection)

        return alternatives.enumerated().map { index, alternative in
            let alternativeTrace = trace(for: alternative)
            return PlanningRuleCounterfactualDiff(
                selectedTraceID: selectedTrace.id,
                alternativeTraceID: alternativeTrace.id,
                selectedStepID: selectedSelection.step.id,
                alternativeStepID: alternative.step.id,
                selectedStepTitle: selectedSelection.step.title,
                alternativeStepTitle: alternative.step.title,
                selectedRank: 0,
                alternativeRank: Double(index + 1),
                selectedLocalFitLabel: selectedTrace.localFitLabel,
                alternativeLocalFitLabel: alternativeTrace.localFitLabel,
                sourceRecordID: selectedTrace.sourceRecordID,
                receiptID: selectedTrace.receiptID,
                replayTraceID: selectedTrace.replayTraceID,
                runtimeSnapshotReferenceID: runtimeSnapshotReferenceID
            )
        }
    }

    static func trace(for selection: PlanningNextStepSelection) -> PlanningRuleTrace {
        if let ruleTrace = selection.candidate.ruleTrace {
            return ruleTrace
        }

        return PlanningRuleTrace(
            id: "planning-rule-trace.\(selection.goal.id).\(selection.step.id)",
            sourceRecordID: "SourceRecord.planning.\(selection.goal.id).\(selection.step.id)",
            receiptID: "Receipt.planning.\(selection.goal.id).\(selection.step.id)",
            replayTraceID: "ReplayTrace.planning.\(selection.goal.id).\(selection.step.id)",
            contextVector: PlanningRuleContextVector(
                goalMode: selection.goal.mode,
                timingFit: selection.step.timing.timingType.rawValue,
                feasibilityLevel: .tight,
                fragilityLevel: .moderate,
                activeStepState: selection.step.state,
                hasIncompleteDependencies: false,
                learnedFitScore: selection.candidate.learnedFitScore,
                timelineRiskScore: selection.candidate.timelineRiskScore,
                energyLearningAdjustment: selection.candidate.energyLearning?.rankingAdjustment,
                sharedLifePressureScore: nil,
                preferredShortSteps: selection.goal.planningStrategy.preferShortSteps,
                reviewCadenceDays: selection.goal.timing.progressReviewCadenceDays ?? selection.goal.planningStrategy.revisitCadenceDays ?? PlanningPace(goalTempo: selection.goal.timing.tempo).defaultReviewCadenceDays
            ),
            ruleReasons: [],
            fallbackReasonIDs: [],
            confidence: selection.candidate.evaluation.recommendationConfidence,
            explanationSummary: "Local deterministic rules ranked this step.",
            controlVisibility: "You / Search Ambitions can inspect the local trace.",
            inspectionSurfaceTitle: "Search Ambitions",
            localOnly: true
        )
    }
}

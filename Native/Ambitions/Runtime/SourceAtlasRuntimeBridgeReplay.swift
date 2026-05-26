import Foundation

struct SourceAtlasRuntimeBridgeReplay: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let schemaVersion: String
    let generatedAt: String
    let inspectionSurfaceTitle: String
    let inspectionSummary: String
    let intent: SourceAtlasBridgeIntentMatchSummary
    let packSelection: SourceAtlasPackSelection
    let pathComposition: PersonalPathComposition
    let pathTradeoffCount: Int
    let stepCandidateField: StepCandidateField
    let selectedRecommendation: SourceAtlasBridgeRecommendationSummary
    let factorLedgerFingerprint: String
    let simulationSummary: StepImpactSimulation
    let receipts: [SourceAtlasBridgeReceipt]
    let localOnly: Bool

    init(
        intentMatch: SourceAtlasIntentMatch,
        packSelection: SourceAtlasPackSelection,
        pathComposition: PersonalPathComposition,
        stepCandidateField: StepCandidateField,
        factorLedger: PersonalizationFactorLedger,
        correctionInput: SourceAtlasBridgeCorrectionInput? = nil,
        generatedAt: String,
        localOnly: Bool
    ) {
        self.generatedAt = generatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        inspectionSurfaceTitle = "What Ambitions knows"
        inspectionSummary = "You / What Ambitions knows can inspect this SourceRecord, Receipt, and ReplayTrace."
        intent = SourceAtlasBridgeIntentMatchSummary(match: intentMatch, selection: packSelection)
        self.packSelection = packSelection
        self.pathComposition = pathComposition
        pathTradeoffCount = pathComposition.pathTradeoffs.count
        self.stepCandidateField = stepCandidateField
        selectedRecommendation = SourceAtlasBridgeRecommendationSummary(stepCandidateField.selectedCandidate ?? stepCandidateField.candidates.first ?? Self.fallbackCandidate())
        factorLedgerFingerprint = factorLedger.replayProjection.stableFingerprint
        simulationSummary = selectedRecommendation.impactSimulation
        receipts = Self.receipts(
            intent: intent,
            packSelection: packSelection,
            pathComposition: pathComposition,
            pathTradeoffCount: pathComposition.pathTradeoffs.count,
            stepCandidateField: stepCandidateField,
            inspectionSurfaceTitle: inspectionSurfaceTitle,
            inspectionSummary: inspectionSummary,
            factorLedgerFingerprint: factorLedgerFingerprint,
            correctionInput: correctionInput,
            generatedAt: self.generatedAt,
            localOnly: localOnly
        )
        self.localOnly = localOnly
        schemaVersion = sourceAtlasBridgeReplaySchemaVersion
        id = CandidateSource.stableIdentifier(
            prefix: "source-atlas.bridge-replay",
            components: [
                self.generatedAt,
                factorLedgerFingerprint,
                stepCandidateField.selectedCandidateID,
                pathComposition.selectedPath.id,
                packSelection.selectedPackIDs.joined(separator: ",")
            ]
        )
    }

    var receiptKinds: [SourceAtlasBridgeReceiptKind] {
        receipts.map(\.kind)
    }
}

private extension SourceAtlasRuntimeBridgeReplay {
    static func receipts(
        intent: SourceAtlasBridgeIntentMatchSummary,
        packSelection: SourceAtlasPackSelection,
        pathComposition: PersonalPathComposition,
        pathTradeoffCount: Int,
        stepCandidateField: StepCandidateField,
        inspectionSurfaceTitle: String,
        inspectionSummary: String,
        factorLedgerFingerprint: String,
        correctionInput: SourceAtlasBridgeCorrectionInput?,
        generatedAt: String,
        localOnly: Bool
    ) -> [SourceAtlasBridgeReceipt] {
        var receipts: [SourceAtlasBridgeReceipt] = []

        receipts.append(
            SourceAtlasBridgeReceipt(
                kind: .sourceAtlasIntentMatched,
                recordedAt: generatedAt,
                summary: "Source Atlas matched the raw intent.",
                details: [
                    "raw=\(intent.rawGoalText)",
                    "normalized=\(intent.normalizedGoalIntent)",
                    "confidence=\(intent.confidenceBand.rawValue)",
                    "matched-domains=\(intent.matchedDomainIDs.joined(separator: ","))",
                    "matched-skills=\(intent.matchedSkillSliceIDs.joined(separator: ","))",
                    "matched-roles=\(intent.matchedRoleIDs.joined(separator: ","))",
                    "selected-packs=\(intent.selectedPackIDs.joined(separator: ","))",
                    "rejected-packs=\(intent.rejectedPackIDs.joined(separator: ","))"
                ],
                relatedIDs: intent.selectedPackIDs + intent.rejectedPackIDs,
                isRedacted: intent.rawGoalTextWasRedacted
            )
        )

        if packSelection.selectedPackIDs.isEmpty == false {
            receipts.append(
                SourceAtlasBridgeReceipt(
                    kind: .sourceAtlasPackSelected,
                    recordedAt: generatedAt,
                    summary: "Source Atlas selected runtime packs.",
                    details: [
                        "selected=\(packSelection.selectedPackIDs.joined(separator: ","))",
                        "source-state=\(packSelection.sourceState.rawValue)",
                        "freshness=\(packSelection.freshnessState.rawValue)",
                        "risk=\(packSelection.riskState.rawValue)",
                        "review=\(packSelection.reviewState.rawValue)",
                        "can-drive-runtime=\(packSelection.canDriveRuntime)",
                        "requires-user-review=\(packSelection.requiredUserReview)"
                    ],
                    relatedIDs: packSelection.selectedPackIDs
                )
            )
        }

        if packSelection.rejectedPackIDs.isEmpty == false {
            receipts.append(
                SourceAtlasBridgeReceipt(
                    kind: .sourceAtlasPackRejected,
                    recordedAt: generatedAt,
                    summary: "Source Atlas rejected runtime packs.",
                    details: packSelection.rejectedPackIDs.map { packID in
                        let reasons = packSelection.rejectionReasons[packID]?.joined(separator: ",") ?? "unknown"
                        return "\(packID): \(reasons)"
                    },
                    relatedIDs: packSelection.rejectedPackIDs
                )
            )
        }

        receipts.append(
            SourceAtlasBridgeReceipt(
                kind: .sourceAtlasPathComposed,
                recordedAt: generatedAt,
                summary: "Source Atlas composed the selected path.",
                details: [
                    "selected-path=\(pathComposition.selectedPath.id)",
                    "selected-path-nodes=\(pathComposition.selectedPath.selectedNodeIDs.joined(separator: ","))",
                    "path-count=\(pathComposition.pathInstances.count)",
                    "rejected-path-count=\(pathComposition.rejectedPaths.count)",
                    "path-tradeoff-count=\(pathTradeoffCount)",
                    "alternative-path-set=\(pathComposition.alternativePathSet?.personalPathInstanceIDs.joined(separator: ",") ?? "none")"
                ],
                relatedIDs: [pathComposition.selectedPath.id] + pathComposition.rejectedPaths.map(\.id)
            )
        )

        if pathComposition.rejectedPaths.isEmpty == false {
            receipts.append(
                SourceAtlasBridgeReceipt(
                    kind: .sourceAtlasPathRejected,
                    recordedAt: generatedAt,
                    summary: "Source Atlas retained rejected paths for replay.",
                    details: pathComposition.rejectedPaths.map { path in
                        "\(path.id): \(path.pathSummary)"
                    },
                    relatedIDs: pathComposition.rejectedPaths.map(\.id)
                )
            )
        }

        if pathComposition.rejectedPaths.contains(where: { $0.staleNodes.isEmpty == false || $0.missingSourceNodes.isEmpty == false }) ||
            packSelection.rejectedPackIDs.contains(where: { packSelection.rejectionReasons[$0]?.contains(where: { $0 == "stale" || $0 == "review-required" }) == true }) {
            let blockedPathIDs = pathComposition.rejectedPaths
                .filter { $0.staleNodes.isEmpty == false || $0.missingSourceNodes.isEmpty == false }
                .map(\.id)
            let blockedPackIDs = packSelection.rejectedPackIDs.filter { packID in
                packSelection.rejectionReasons[packID]?.contains(where: { $0 == "stale" || $0 == "review-required" }) == true
            }
            receipts.append(
                SourceAtlasBridgeReceipt(
                    kind: .sourceAtlasFreshnessBlocked,
                    recordedAt: generatedAt,
                    summary: "Source Atlas blocked freshness-sensitive replay inputs.",
                    details: [
                        "blocked-paths=\(blockedPathIDs.joined(separator: ","))",
                        "blocked-packs=\(blockedPackIDs.joined(separator: ","))"
                    ],
                    relatedIDs: blockedPathIDs + blockedPackIDs
                )
            )
        }

        receipts.append(
            SourceAtlasBridgeReceipt(
                kind: .sourceAtlasStepCandidatesExpanded,
                recordedAt: generatedAt,
                summary: "Source Atlas expanded step candidates.",
                details: [
                    "candidate-count=\(stepCandidateField.candidates.count)",
                    "selected-candidate=\(stepCandidateField.selectedCandidateID)",
                    "rejected-candidates=\(stepCandidateField.rankingTrace.rejectedCandidateIDs.joined(separator: ","))",
                    "source-provenance=\(stepCandidateField.sourceProvenance.map(\.rawValue).joined(separator: ","))",
                    "factor-ledger-fingerprint=\(factorLedgerFingerprint)"
                ],
                relatedIDs: [stepCandidateField.selectedCandidateID] + stepCandidateField.candidateIDs
            )
        )

        if stepCandidateField.selectedCandidate?.kind == .fallback {
            receipts.append(
                SourceAtlasBridgeReceipt(
                    kind: .sourceAtlasUnsupportedGoalFallback,
                    recordedAt: generatedAt,
                    summary: "Source Atlas fell back to a safe unsupported-goal step.",
                    details: [
                        "selected-candidate=\(stepCandidateField.selectedCandidateID)",
                        "selected-kind=\(stepCandidateField.selectedCandidate?.kind.rawValue ?? "unknown")",
                        "semantic-summary=\(stepCandidateField.rankingTrace.semanticSummary)"
                    ],
                    relatedIDs: [stepCandidateField.selectedCandidateID]
                )
            )
        }

        if let correctionInput, correctionInput.rejectedCandidateHistory.isEmpty == false {
            for record in correctionInput.rejectedCandidateHistory {
                let redactedReason = record.reason.redactedLabel
                let customText = record.reason.customTextForLearning.map { _ in "[redacted]" }
                receipts.append(
                    SourceAtlasBridgeReceipt(
                        kind: .sourceAtlasUserCorrectionApplied,
                        recordedAt: record.recordedAt,
                        summary: "Source Atlas applied a user correction.",
                        details: [
                            "candidate=\(record.candidateID)",
                            "source-step=\(record.sourceStepID)",
                            "reason=\(redactedReason)",
                            "custom-text=\(customText ?? "none")",
                            "skipped-reason=\(record.skippedReason)"
                        ],
                        relatedIDs: [record.candidateID, record.sourceStepID],
                        isRedacted: record.reason.hasSensitiveText
                    )
                )
            }
        }

        receipts.append(
            SourceAtlasBridgeReceipt(
                kind: .sourceAtlasReplayGenerated,
                recordedAt: generatedAt,
                summary: "Source Atlas replay snapshot generated.",
                details: [
                    "replay-id=\(CandidateSource.stableIdentifier(prefix: "source-atlas.bridge-replay.snapshot", components: [generatedAt, factorLedgerFingerprint, stepCandidateField.selectedCandidateID]))",
                    "selected-recommendation=\(stepCandidateField.selectedCandidateID)",
                    "factor-ledger-fingerprint=\(factorLedgerFingerprint)",
                    "inspection-surface=\(inspectionSurfaceTitle)",
                    "inspection-summary=\(inspectionSummary)",
                    "receipt-count=\(receipts.count + 1)",
                    "local-only=\(localOnly)"
                ],
                relatedIDs: [stepCandidateField.selectedCandidateID],
                isRedacted: false
            )
        )

        return receipts
    }

    static func fallbackCandidate() -> StepCandidate {
        StepCandidate(
            sourceStepID: "source-atlas-fallback-step",
            source: .fallback,
            kind: .fallback,
            title: "Continue the goal thread",
            summary: "The Source Atlas path did not yield a safe source-backed step.",
            accessibilitySummary: "Fallback step.",
            estimatedMinutes: 5,
            estimatedEnergyCost: 0.2,
            goalContribution: 0.2,
            deadlineContribution: 0.1,
            futurePressureImpact: 0.2,
            opportunityCost: 0.3,
            approvalRequired: false,
            validity: .fallback,
            rejectionRisk: CandidateRejectionRisk(
                id: "source-atlas-fallback-risk",
                level: .moderate,
                summary: "Fallback quality",
                requiresReview: false
            ),
            semanticAnchor: "source-atlas-fallback",
            generatedAt: "2026-05-22T00:00:00Z",
            sourceStepIsOptional: true,
            sourceStepIsExecutable: false
        )
    }
}

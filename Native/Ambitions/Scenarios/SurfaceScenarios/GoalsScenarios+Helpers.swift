import AmbitionsDesignSystem
import Foundation

extension PreviewGoalsScenarios {
    static func previewMissionControl(
        title: String,
        currentTruth: String,
        nextTitle: String,
        proofItems: [GoalEvidenceItem],
        timelineKind: GoalDetailTimelineItemKind,
        riskTitle: String = "No major visible risk"
    ) -> GoalDetailMissionControlState {
        let hasProof = proofItems.isEmpty == false
        let riskIsCalm = riskTitle == "No major visible risk"
        let nextAvailable = nextTitle != "No next step needed"
        let proofHeadline = hasProof ? "\(proofItems.count) proof point\(proofItems.count == 1 ? "" : "s")" : "No proof yet"
        let proofBeads = proofItems.map { item in
            ProofBead(
                id: item.id,
                title: item.title,
                summary: item.subtitle,
                sourceLabel: "Source: Preview proof",
                freshness: .fresh,
                privacyLabel: "Preview proof stays local.",
                timestampLabel: item.timestamp,
                correctionLabel: "Correction can be reviewed from the proof source."
            )
        }
        let riskItems = riskIsCalm ? [] : [
            GoalDetailRiskState(
                id: "preview-risk-\(title)",
                title: riskTitle,
                summary: "This goal needs review before more planning.",
                state: .warning
            )
        ]
        let archiveState = GoalDetailArchiveState(
            title: timelineKind == .completed ? "Completed" : timelineKind == .cancelled ? "Archived" : timelineKind == .parked ? "Parked" : "Archive ready",
            statusLabel: timelineKind == .completed ? "Completed" : timelineKind == .cancelled ? "Closed" : timelineKind == .parked ? "Review later" : "Active",
            summary: timelineKind == .completed ? "This goal is complete and preserved." : timelineKind == .cancelled ? "This goal is closed without being treated as failure." : timelineKind == .parked ? "This goal is intentionally quiet for now." : "Archive learning will appear when this goal is parked, completed, or closed.",
            learning: timelineKind == .completed ? "Latest proof stays attached when available." : "Nothing needs to be archived right now.",
            state: timelineKind == .completed ? .success : timelineKind == .parked ? .default : .selected
        )
        return GoalDetailMissionControlState(
            currentTruth: currentTruth,
            primaryNextMove: GoalNextVisibleStep(
                title: nextTitle,
                detail: nextAvailable ? "Keep this as the primary contained Step." : "This goal is not asking for action.",
                isAvailable: nextAvailable
            ),
            sourceLabel: "Based on this goal",
            proofBoundaryLabel: hasProof ? "Proof stays attached to this goal" : "Proof is visible when saved",
            ownershipLabel: "You own the path",
            breadcrumb: GoalDetailBreadcrumbState(title: "Path", labels: ["Career", title], fallbackUsed: false),
            lanes: [
                GoalDetailMissionLaneState(kind: .overview, title: "Overview", headline: timelineKind.title, summary: currentTruth, detail: "Next: \(nextTitle)", badgeTitle: "State", systemImage: "rectangle.and.text.magnifyingglass", state: .selected),
                GoalDetailMissionLaneState(kind: .path, title: "Path", headline: "Current phase", summary: "Next milestone: \(nextTitle)", detail: "Preview path data is bounded to this goal.", badgeTitle: "Current", systemImage: "point.topleft.down.curvedto.point.bottomright.up", state: .selected),
                GoalDetailMissionLaneState(kind: .steps, title: "Steps", headline: nextTitle, summary: nextAvailable ? "Keep this as the primary contained Step." : "No action is needed right now.", detail: "", badgeTitle: nextAvailable ? "Next step" : "Closed", systemImage: "scope", state: nextAvailable ? .selected : .default),
                GoalDetailMissionLaneState(kind: .proof, title: "Proof", headline: proofHeadline, summary: hasProof ? "Evidence is visible." : "Needs evidence", detail: proofItems.first.map { "Latest: \($0.title)" } ?? "No proof has been recorded for this goal yet.", badgeTitle: hasProof ? "Evidence visible" : "No proof yet", systemImage: "checkmark.seal", state: hasProof ? .selected : .default),
                GoalDetailMissionLaneState(kind: .decisions, title: "Decisions", headline: "No decisions yet", summary: "Decision trail stays here when this goal changes.", detail: "", badgeTitle: "No decisions", systemImage: "arrow.triangle.branch", state: .default),
                GoalDetailMissionLaneState(kind: .risks, title: "Risks", headline: riskItems.first?.title ?? "No major risk visible", summary: riskItems.first?.summary ?? "Nothing in this preview is asking for rescue.", detail: "", badgeTitle: riskIsCalm ? "Calm" : "Needs review", systemImage: "exclamationmark.triangle", state: riskIsCalm ? .success : .warning),
                GoalDetailMissionLaneState(kind: .archive, title: "Archive", headline: archiveState.title, summary: archiveState.summary, detail: archiveState.learning, badgeTitle: archiveState.statusLabel, systemImage: "archivebox", state: archiveState.state),
            ],
            timeline: GoalDetailTimelineState(
                title: "Storyline",
                subtitle: "A compact read on what happened, what is current, and what is only a possible next step.",
                items: [
                    GoalDetailTimelineItemState(id: "started-\(title)", kind: .started, title: "Started", summary: "Preview start", timestamp: nil, state: .default, isFuture: false),
                    GoalDetailTimelineItemState(id: "current-\(title)", kind: timelineKind, title: timelineKind.title, summary: currentTruth, timestamp: nil, state: timelineKind == .completed ? .success : timelineKind == .waiting ? .warning : .default, isFuture: false),
                    GoalDetailTimelineItemState(id: "next-\(title)", kind: .next, title: nextTitle, summary: nextAvailable ? "Possible next step." : "No future certainty is claimed.", timestamp: nil, state: nextAvailable ? .selected : .default, isFuture: nextAvailable),
                ]
            ),
            assumptions: [
                GoalDetailAssumptionState(id: "next-step", title: "This goal has a next step.", status: nextAvailable ? "Visible" : "Closed", whyItMatters: "The screen should lead with one step, not a long step dump.", correctionLabel: nextAvailable ? "Change next step" : nil, state: nextAvailable ? .selected : .default),
                GoalDetailAssumptionState(id: "proof", title: "This goal has enough proof.", status: hasProof ? "Proof visible" : "No proof yet", whyItMatters: "Progress should be backed by something observable.", correctionLabel: "Add proof later", state: hasProof ? .selected : .default),
            ],
            proofRail: GoalDetailProofRailState(title: "Proof", subtitle: hasProof ? "Proof keeps source, freshness, privacy, correction, and review visible." : "Evidence will appear here when it is recorded.", items: proofItems, spineBeads: proofBeads, emptyTitle: "No proof yet", emptyMessage: "Add proof later when there is something real to show."),
            decisions: GoalDetailDecisionsState(title: "Decisions", subtitle: "Decision trail stays here when this goal changes.", items: [], emptyTitle: "No decisions yet", emptyMessage: "When you change, park, or explain this goal, the reason will stay visible here."),
            risks: GoalDetailRisksState(title: "Risks", subtitle: riskItems.isEmpty ? "No major risk is visible from this goal data." : "Risks stay explicit so recovery can stay calm.", items: riskItems, emptyTitle: "No major risk visible", emptyMessage: "Nothing in this goal is asking for rescue right now."),
            archive: archiveState,
            receipts: GoalDetailReceiptsState(title: "What changed", subtitle: "Goal-related receipts stay visible here when the current data source provides them.", items: [], emptyTitle: "No receipts yet", emptyMessage: "Receipts will appear here after goal changes are recorded.")
        )
    }

    static func trustHeavyExplainabilityState() -> GoalExplainabilityState {
        GoalExplainabilityState(
            whisper: GoalTrustWhisperState(
                title: "Trust whisper",
                subtitle: "This recommendation is leading because the release-readiness path is tight and the copy drift is still fresh.",
                pillLine: "Likely fit • Waiting on newer input • Some source context needs review",
                pills: [
                    GoalTrustWhisperPillState(id: "confidence", title: "Likely fit", icon: "checkmark.shield", state: .selected),
                    GoalTrustWhisperPillState(id: "freshness", title: "Waiting on newer input", icon: "clock.badge.exclamationmark", state: .warning),
                    GoalTrustWhisperPillState(id: "sources", title: "Some source context needs review", icon: "text.magnifyingglass", state: .warning),
                    GoalTrustWhisperPillState(id: "contradictions", title: "1 conflict needs review", icon: "exclamationmark.bubble", state: .warning)
                ]
            ),
            whyThis: GoalWhyThisState(
                compactSummary: "The release-readiness path is still being shaped around the smallest truthful documentation fix.",
                lines: [
                    "Interpretation: Docs and trust copy are still the leverage point.",
                    "Path: Refreshing copy unlocks cleaner validation and calmer handoff.",
                    "Now: Newer platform checks could still change what the app should claim."
                ]
            ),
            sourceAudit: GoalSourceAuditSectionState(rows: [
                GoalSourceAuditRowState(
                    id: "source-1",
                    resourceID: "resource-1",
                    title: "Manual platform verification notes",
                    subtitle: "Unsigned release evidence",
                    detailLabels: ["Provenance: Manual", "Trust: Medium", "Freshness: Stale"],
                    state: .warning
                ),
                GoalSourceAuditRowState(
                    id: "source-2",
                    resourceID: "resource-2",
                    title: "You trust copy",
                    subtitle: "Repo-local source of truth",
                    detailLabels: ["Provenance: Local", "Trust: High", "Freshness: Fresh"],
                    state: .default
                )
            ]),
            freshness: GoalFreshnessState(
                posture: .stale,
                postureLabel: "Stale",
                severityLabel: "Warning",
                detailLabels: ["Flag: manual_follow_up"]
            ),
            confidence: GoalConfidenceState(
                understandingConfidence: .medium,
                pathConfidence: .medium,
                detailLabels: ["Understanding: Medium", "Path: Medium", "Uncertainty: manual verification"]
            ),
            contradictions: [
                GoalContradictionSummaryState(
                    id: "contradiction-1",
                    code: .inputTimingConflict,
                    title: "Outdated verification",
                    summary: "The release note and the latest manual follow-up no longer fully agree.",
                    severityLabel: "Blocking",
                    state: .warning
                )
            ],
            correctionControls: [
                GoalCorrectionControlState(
                    id: "control-1",
                    title: "Update this assumption",
                    subtitle: "The release note should stay conservative until the next manual check lands.",
                    kind: .dismissContradiction,
                    artifactKind: .contradictionShape,
                    teachingSignalKind: .contradictionDispositionCorrection,
                    payload: .contradictionDisposition(
                        GoalTeachingContradictionDispositionCorrection(correctedDisposition: .dismissed)
                    ),
                    target: GoalTeachingCaptureTarget(
                        artifactKind: .contradictionShape,
                        candidateID: "candidate-1",
                        stageID: "stage-1",
                        contradictionCode: .inputTimingConflict,
                        contradictionArtifactRefs: []
                    ),
                    state: .warning
                )
            ],
            appliedTeachingBadges: [
                GoalAppliedTeachingBadgeState(
                    id: "badge-1",
                    signalID: "signal-1",
                    title: "Support Not Relevant",
                    subtitle: "Previous correction kept copy conservative.",
                    state: .selected
                )
            ]
        )
    }

    static func starterExplainabilityState() -> GoalExplainabilityState {
        GoalExplainabilityState(
            whisper: GoalTrustWhisperState(
                title: "Trust whisper",
                subtitle: "This starter path is deliberately light because the first real signal matters more than overexplaining.",
                pillLine: "Needs confirmation • Updated recently • Source context looks stable",
                pills: [
                    GoalTrustWhisperPillState(id: "confidence", title: "Needs confirmation", icon: "checkmark.shield", state: .warning),
                    GoalTrustWhisperPillState(id: "freshness", title: "Updated recently", icon: "clock.arrow.circlepath", state: .success),
                    GoalTrustWhisperPillState(id: "sources", title: "Source context looks stable", icon: "text.magnifyingglass", state: .success),
                    GoalTrustWhisperPillState(id: "contradictions", title: "No conflicts surfaced", icon: "checkmark.circle", state: .success)
                ]
            ),
            whyThis: GoalWhyThisState(
                compactSummary: "The first experiment stays small so the goal can learn from real evidence instead of imaginary certainty.",
                lines: [
                    "Interpretation: Learning goals should start with low-pressure signal.",
                    "Path: One rough pass will teach more than overplanning."
                ]
            ),
            sourceAudit: GoalSourceAuditSectionState(rows: []),
            freshness: GoalFreshnessState(posture: .currentEnough, postureLabel: "Fresh", severityLabel: "Light", detailLabels: ["Flag: none"]),
            confidence: GoalConfidenceState(understandingConfidence: .low, pathConfidence: .low, detailLabels: ["Understanding: Low", "Path: Low"]),
            contradictions: [],
            correctionControls: [],
            appliedTeachingBadges: []
        )
    }

    static func supportExplainabilityState() -> GoalExplainabilityState {
        GoalExplainabilityState(
            whisper: GoalTrustWhisperState(
                title: "Trust whisper",
                subtitle: "This support path is leading with collaborative posture so the plan stays helpful without taking ownership.",
                pillLine: "Strong fit • Updated recently • Source context looks stable",
                pills: [
                    GoalTrustWhisperPillState(id: "confidence", title: "Strong fit", icon: "checkmark.shield", state: .success),
                    GoalTrustWhisperPillState(id: "freshness", title: "Updated recently", icon: "clock.arrow.circlepath", state: .success),
                    GoalTrustWhisperPillState(id: "sources", title: "Source context looks stable", icon: "text.magnifyingglass", state: .success),
                    GoalTrustWhisperPillState(id: "contradictions", title: "No conflicts surfaced", icon: "checkmark.circle", state: .success)
                ]
            ),
            whyThis: GoalWhyThisState(
                compactSummary: "The next step stays collaborative because support goals should keep the other person as the real owner.",
                lines: [
                    "Interpretation: This is a support path, not delegated compliance.",
                    "Path: A calm check-in preserves momentum without pressure."
                ]
            ),
            sourceAudit: GoalSourceAuditSectionState(rows: []),
            freshness: GoalFreshnessState(posture: .currentEnough, postureLabel: "Fresh", severityLabel: "Light", detailLabels: ["Flag: none"]),
            confidence: GoalConfidenceState(understandingConfidence: .high, pathConfidence: .high, detailLabels: ["Understanding: High", "Path: High"]),
            contradictions: [],
            correctionControls: [],
            appliedTeachingBadges: []
        )
    }

    static func card(
        id: String,
        target: GoalRouteTarget,
        title: String,
        subtitle: String,
        modeLabel: String,
        posture: GoalsBoardPosture,
        renderState: GoalRenderState,
        progressValue: Double,
        progressLabel: String,
        timingLabel: String,
        weekRelationship: String,
        phaseSummary: String,
        milestoneSummary: String,
        pressureSummary: String,
        nextStepHint: String,
        lifecycleState: GoalPortfolioLifecycleState = .active,
        weather: GoalWeatherState = .clear,
        proofSummary: GoalProofSummary = GoalProofSummary(title: "2 proof points", detail: "Last proof: Goal list structure drafted", count: 2, latestTitle: "Goal list structure drafted", visualState: .selected),
        momentumIntegrity: GoalMomentumIntegrity = GoalMomentumIntegrity(title: "Building proof", detail: "Evidence and a next step both exist.", visualState: .selected),
        supportLabel: String? = nil,
        priorityLabel: String
    ) -> GoalsBoardCardState {
        let nextVisibleStep = GoalNextVisibleStep(title: nextStepHint, detail: "soon · proof useful", isAvailable: true)
        return GoalsBoardCardState(
            id: id,
            target: target,
            title: title,
            subtitle: subtitle,
            modeLabel: modeLabel,
            posture: posture,
            renderState: renderState,
            progressValue: progressValue,
            progressLabel: progressLabel,
            timingLabel: timingLabel,
            weekRelationship: weekRelationship,
            phaseSummary: phaseSummary,
            milestoneSummary: milestoneSummary,
            pressureSummary: pressureSummary,
            nextStepHint: nextStepHint,
            lifecycleState: lifecycleState,
            weather: weather,
            weatherSummary: weather == .clear ? "Proof and the next step are visible." : "This goal needs attention.",
            proofSummary: proofSummary,
            nextVisibleStep: nextVisibleStep,
            momentumIntegrity: momentumIntegrity,
            supportLabel: supportLabel,
            priorityLabel: priorityLabel,
            manualPriorityRank: Int(priorityLabel.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0,
            shellSummary: nil
        )
    }
}

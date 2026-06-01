import XCTest
@testable import Ambitions

final class RecommendationExplanationModelsTests: XCTestCase {
    func testExplanationTypeTaxonomyCoversBatch66Reasons() {
        XCTAssertEqual(
            Set(RecommendationExplanationType.allCases),
            [
                .whyThis,
                .whyNow,
                .whyChanged,
                .whyScheduled,
                .whyDeferred,
                .whyRecovered,
                .whyPrioritized,
                .whyDisplaced,
                .whyRouted,
                .whyGoalChanged,
                .whyPlanChanged,
                .whyContextLens,
                .whyCalendarAware,
                .whyBelievable,
                .whyNotBelievable
            ]
        )
    }

    func testEvidenceCategoryTaxonomyCoversDecisionInputs() {
        XCTAssertEqual(
            Set(RecommendationExplanationEvidenceCategory.allCases),
            [
                .userInput,
                .memoryEvent,
                .goalState,
                .captureState,
                .planState,
                .sourceTruth,
                .calendarDerived,
                .deadline,
                .priority,
                .urgency,
                .consequence,
                .effort,
                .contextLens,
                .capacity,
                .recovery,
                .path,
                .deliverable,
                .scopeChange,
                .assumption,
                .userCorrection,
                .systemDefault
            ]
        )
    }

    func testConfidenceAndUncertaintyDefaultsAreConservative() {
        let explanation = RecommendationExplanation(
            id: "explanation-defaults",
            type: .whyRouted,
            title: "Why routed",
            summary: "I routed this to Plan because it looks like a one-time commitment.",
            recommendationTitle: "Create spreadsheet and send it to Kaylee",
            lastUpdatedAt: "2026-04-24T12:00:00Z",
            source: .capture
        )
        let uncertainty = RecommendationExplanationUncertainty(
            id: "uncertain-eod",
            summary: "I am not certain whether EOD means 5 PM for you."
        )

        XCTAssertEqual(explanation.confidence, .medium)
        XCTAssertTrue(explanation.localOnly)
        XCTAssertEqual(explanation.privacy, .standard)
        XCTAssertEqual(uncertainty.severity, .medium)
        XCTAssertTrue(uncertainty.canBeReducedByUser)
    }

    func testAssumptionsAreReadableAndCorrectable() {
        let assumption = RecommendationExplanationAssumption(
            id: "assumption-work-task",
            summary: "I assumed this is a work task.",
            fieldKey: "domain_context"
        )

        XCTAssertEqual(assumption.summary, "I assumed this is a work task.")
        XCTAssertEqual(assumption.confidence, .medium)
        XCTAssertTrue(assumption.isUserCorrectable)
    }

    func testTodayExplanationSummariesRoundTripWithoutExternalAssistantFraming() throws {
        XCTAssertEqual(
            Set(TodayExplanationSummaryKind.allCases),
            [.used, .needsReview, .notUsed]
        )

        let explanation = RecommendationExplanation(
            id: "today-explanation-summaries",
            type: .whyThis,
            title: "Today explanation summaries",
            summary: "Local context is categorized for Today explanations.",
            recommendationTitle: "Start here",
            lastUpdatedAt: "2026-04-24T12:00:00Z",
            source: .today,
            todaySummaries: [
                TodayExplanationSummary(
                    id: "summary-used",
                    kind: .used,
                    summary: "Used: travel radius, available facility, tryout date.",
                    detail: "Local facts are actively shaping the recommendation.",
                    sourceLabel: "Life Context"
                ),
                TodayExplanationSummary(
                    id: "summary-review",
                    kind: .needsReview,
                    summary: "Needs review: older training history.",
                    detail: "This context should be checked before runtime use.",
                    sourceLabel: "Historical context"
                ),
                TodayExplanationSummary(
                    id: "summary-not-used",
                    kind: .notUsed,
                    summary: "Not used: paused injury note.",
                    detail: "Paused context stays visible but outside runtime use.",
                    sourceLabel: "Paused context"
                )
            ]
        )

        let decoded = try PersistenceCoding.decode(
            RecommendationExplanation.self,
            from: PersistenceCoding.encode(explanation)
        )
        let visibleCopy = ([decoded.title, decoded.summary] + decoded.todaySummaries.flatMap {
            [$0.kind.title, $0.summary, $0.detail ?? "", $0.sourceLabel]
        }).joined(separator: " ")

        XCTAssertEqual(Set(decoded.todaySummaries.map(\TodayExplanationSummary.kind)), [
            TodayExplanationSummaryKind.used,
            TodayExplanationSummaryKind.needsReview,
            TodayExplanationSummaryKind.notUsed
        ])
        XCTAssertEqual(
            decoded.todaySummaries.first(where: { $0.kind == .used })?.summary,
            "Used: travel radius, available facility, tryout date."
        )
        XCTAssertEqual(
            decoded.todaySummaries.first(where: { $0.kind == .needsReview })?.kind.title,
            "Needs review"
        )
        XCTAssertTrue(visibleCopy.localizedCaseInsensitiveContains("used: travel radius"))
        XCTAssertTrue(visibleCopy.localizedCaseInsensitiveContains("needs review: older training history"))
        XCTAssertTrue(visibleCopy.localizedCaseInsensitiveContains("not used: paused injury note"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("cloud"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("assistant"))
    }

    func testCorrectionActionsRepresentUserTuningWithoutUI() {
        XCTAssertEqual(
            Set(RecommendationExplanationCorrectionActionKind.allCases),
            [
                .changeDomainContext,
                .changeDeadline,
                .changeImportance,
                .changeUrgency,
                .changeConsequence,
                .changeRoute,
                .markGoalSupporting,
                .markOneTimeTask,
                .markOptionalSomeday,
                .dismissRecommendation,
                .explainMore
            ]
        )

        let action = RecommendationExplanationCorrectionAction(
            id: "correct-route",
            kind: .changeRoute,
            title: "Move this to Waiting",
            targetFieldKey: "route"
        )

        XCTAssertEqual(action.kind, .changeRoute)
        XCTAssertEqual(action.targetFieldKey, "route")
    }

    func testPriorityContextDeadlineAndConsequenceEvidenceCanBeRepresented() {
        let explanation = RecommendationExplanation(
            id: "explanation-priority-reality",
            type: .whyPrioritized,
            title: "Why this is higher priority",
            summary: "This has a hard deadline and real consequence, so it outranks passive flexible work.",
            recommendationTitle: "Build the crib",
            evidence: [
                RecommendationExplanationEvidence(id: "deadline", category: .deadline, title: "Hard deadline", summary: "Before the baby arrives."),
                RecommendationExplanationEvidence(id: "priority", category: .priority, title: "High priority"),
                RecommendationExplanationEvidence(id: "urgency", category: .urgency, title: "Urgent"),
                RecommendationExplanationEvidence(id: "consequence", category: .consequence, title: "Real-world consequence"),
                RecommendationExplanationEvidence(id: "effort", category: .effort, title: "Requires a work block"),
                RecommendationExplanationEvidence(id: "context", category: .contextLens, title: "Home context fit")
            ],
            lastUpdatedAt: "2026-04-24T12:00:00Z",
            source: .recommendation
        )

        XCTAssertTrue(explanation.containsDeadlineEvidence)
        XCTAssertTrue(explanation.containsPriorityRealityEvidence)
        XCTAssertTrue(explanation.containsContextLensEvidence)
        XCTAssertTrue(explanation.evidenceCategories.isSuperset(of: [.deadline, .priority, .urgency, .consequence, .effort, .contextLens]))
    }

    func testGoalScopeDeliverableAndRouteEvidenceCanBeRepresented() {
        let explanation = RecommendationExplanation(
            id: "explanation-goal-path-change",
            type: .whyGoalChanged,
            title: "Why the path changed",
            summary: "Adding a deliverable changed the remaining roadmap.",
            recommendationTitle: "Update album path",
            evidence: [
                RecommendationExplanationEvidence(id: "song-added", category: .deliverable, title: "Song added"),
                RecommendationExplanationEvidence(id: "scope", category: .scopeChange, title: "Scope changed"),
                RecommendationExplanationEvidence(id: "route", category: .planState, title: "Scheduled before release")
            ],
            lastUpdatedAt: "2026-04-24T12:00:00Z",
            source: .goalDetail
        )

        XCTAssertTrue(explanation.containsGoalScopeOrDeliverableEvidence)
        XCTAssertTrue(explanation.evidenceCategories.contains(.planState))
    }

    func testExplanationsCanReferenceEventLedgerIdsAndPreservePrivacyMarkers() {
        let entry = EventLedgerEntry(
            id: "ledger-calendar-1",
            kind: .calendarContextObserved,
            occurredAt: "2026-04-24T12:00:00Z",
            source: .calendar,
            title: "Calendar context observed",
            summary: "Busy until 3 PM.",
            trust: EventLedgerTrustMetadata(confidence: 0.8),
            privacy: .calendarDerived
        )
        let evidence = RecommendationExplanationEvidence.fromEventLedgerEntry(entry)
        let explanation = RecommendationExplanation(
            id: "explanation-calendar-aware",
            type: .whyCalendarAware,
            title: "Why calendar-aware",
            summary: "The suggestion uses local calendar-derived pressure.",
            recommendationTitle: "Defer deep work",
            evidence: [evidence],
            lastUpdatedAt: "2026-04-24T12:00:00Z",
            source: .plan,
            relations: RecommendationExplanationRelations(eventLedgerEntryIDs: [entry.id]),
            privacy: .calendarDerived
        )

        XCTAssertEqual(evidence.category, .calendarDerived)
        XCTAssertEqual(evidence.eventLedgerEntryID, entry.id)
        XCTAssertEqual(evidence.confidence, .high)
        XCTAssertTrue(explanation.referencesEventLedger)
        XCTAssertTrue(explanation.containsCalendarDerivedEvidence)
        XCTAssertEqual(explanation.privacy, .calendarDerived)
        XCTAssertTrue(explanation.localOnly)
    }

    func testEvidenceBoundarySummaryNamesLocalEvidenceAndCorrectionAvailability() {
        let explanation = RecommendationExplanation(
            id: "explanation-boundary-evidence",
            type: .whyChanged,
            title: "Why changed",
            summary: "A correction changed the recommendation.",
            recommendationTitle: "Use the lighter version",
            evidence: [
                RecommendationExplanationEvidence(
                    id: "correction",
                    category: .userCorrection,
                    title: "Correction",
                    sourceID: "correction-1"
                )
            ],
            assumptions: [
                RecommendationExplanationAssumption(
                    id: "assumption-energy",
                    summary: "I assumed this needs a lighter version.",
                    fieldKey: "energy_fit"
                )
            ],
            userCorrectableFields: ["energy_fit"],
            correctionActions: [
                RecommendationExplanationCorrectionAction(
                    id: "correct-energy",
                    kind: .changeImportance,
                    title: "Use a different fit",
                    targetFieldKey: "energy_fit"
                )
            ],
            lastUpdatedAt: "2026-05-03T23:50:00Z",
            source: .recommendation
        )

        let boundary = explanation.evidenceBoundarySummary

        XCTAssertEqual(boundary.evidenceLabel, "Uses local explanation evidence")
        XCTAssertEqual(boundary.inferenceBoundaryLabel, "Inference stated and correctable")
        XCTAssertEqual(boundary.userControlLabel, "Correction available")
        XCTAssertEqual(boundary.privacyLabel, "Local-only")
        XCTAssertEqual(boundary.citedSourceIDs, ["correction-1"])
        XCTAssertFalse(boundary.isEvidenceLight)
        XCTAssertTrue(boundary.hasCorrectableInference)
        XCTAssertFalse(boundary.requiresSensitiveReview)
    }

    func testEvidenceBoundarySummaryKeepsEvidenceLightRecommendationsHonest() {
        let explanation = RecommendationExplanation(
            id: "explanation-boundary-light",
            type: .whyThis,
            title: "Why this",
            summary: "This is a default suggestion.",
            recommendationTitle: "Start small",
            lastUpdatedAt: "2026-05-03T23:55:00Z",
            source: .system
        )

        let boundary = explanation.evidenceBoundarySummary

        XCTAssertEqual(boundary.evidenceLabel, "Evidence-light")
        XCTAssertEqual(boundary.inferenceBoundaryLabel, "No stated inference")
        XCTAssertEqual(boundary.userControlLabel, "Review only")
        XCTAssertTrue(boundary.isEvidenceLight)
        XCTAssertFalse(boundary.hasCorrectableInference)
    }

    func testEvidenceBoundarySummaryFlagsCalendarDerivedPrivacyBoundary() {
        let entry = EventLedgerEntry(
            id: "ledger-calendar-boundary",
            kind: .calendarContextObserved,
            occurredAt: "2026-05-03T23:58:00Z",
            source: .calendar,
            title: "Calendar context observed",
            privacy: .calendarDerived
        )
        let explanation = RecommendationExplanation(
            id: "explanation-boundary-calendar",
            type: .whyCalendarAware,
            title: "Why calendar-aware",
            summary: "The suggestion uses calendar-derived pressure.",
            recommendationTitle: "Move deep work",
            evidence: [RecommendationExplanationEvidence.fromEventLedgerEntry(entry)],
            lastUpdatedAt: "2026-05-03T23:59:00Z",
            source: .plan,
            relations: RecommendationExplanationRelations(eventLedgerEntryIDs: [entry.id]),
            privacy: .calendarDerived
        )

        let boundary = explanation.evidenceBoundarySummary

        XCTAssertEqual(boundary.evidenceLabel, "Cites local records")
        XCTAssertEqual(boundary.privacyLabel, "Calendar-derived")
        XCTAssertEqual(boundary.citedSourceIDs, [entry.id])
        XCTAssertTrue(boundary.requiresSensitiveReview)
    }

    func testRecommendationEvidenceModelSummarizesLocalCitedEvidence() {
        let entry = EventLedgerEntry(
            id: "ledger-priority-1",
            kind: .priorityChanged,
            occurredAt: "2026-05-12T12:00:00Z",
            source: .goalEngine,
            title: "Priority changed",
            summary: "The goal became time-sensitive.",
            trust: EventLedgerTrustMetadata(confidence: 0.76)
        )
        let explanation = RecommendationExplanation(
            id: "explanation-evidence-model",
            type: .whyPrioritized,
            title: "Why this rose",
            summary: "Local records show priority and deadline pressure.",
            recommendationTitle: "Finish the grant packet",
            evidence: [
                RecommendationExplanationEvidence.fromEventLedgerEntry(entry),
                RecommendationExplanationEvidence(
                    id: "deadline",
                    category: .deadline,
                    title: "Deadline",
                    sourceID: "deadline-1"
                )
            ],
            assumptions: [
                RecommendationExplanationAssumption(
                    id: "assumption-energy",
                    summary: "I assumed this fits an afternoon work block.",
                    fieldKey: "energy_fit"
                )
            ],
            uncertainty: [
                RecommendationExplanationUncertainty(
                    id: "uncertainty-duration",
                    summary: "The exact duration is unclear."
                )
            ],
            userCorrectableFields: ["duration"],
            correctionActions: [
                RecommendationExplanationCorrectionAction(
                    id: "correct-energy",
                    kind: .changeImportance,
                    title: "Change fit",
                    targetFieldKey: "energy_fit"
                )
            ],
            lastUpdatedAt: "2026-05-12T12:01:00Z",
            source: .recommendation,
            relations: RecommendationExplanationRelations(eventLedgerEntryIDs: [entry.id])
        )

        let model = explanation.recommendationEvidenceModel

        XCTAssertEqual(model.explanationID, explanation.id)
        XCTAssertEqual(model.strength, .citedLocalRecords)
        XCTAssertEqual(model.categories, [.deadline, .priority])
        XCTAssertEqual(model.categoryCounts[.deadline], 1)
        XCTAssertEqual(model.categoryCounts[.priority], 1)
        XCTAssertEqual(model.citedSourceIDs, ["deadline-1", entry.id])
        XCTAssertEqual(model.eventLedgerEntryIDs, [entry.id])
        XCTAssertEqual(model.assumptionIDs, ["assumption-energy"])
        XCTAssertEqual(model.uncertaintyIDs, ["uncertainty-duration"])
        XCTAssertEqual(model.correctableFieldKeys, ["duration", "energy_fit"])
        XCTAssertTrue(model.usesDeadlineEvidence)
        XCTAssertTrue(model.usesPriorityRealityEvidence)
        XCTAssertFalse(model.requiresSensitiveReview)
        XCTAssertTrue(model.canDriveRecommendation)
    }

    func testRecommendationEvidenceModelBlocksEvidenceLightAndSensitiveRecommendations() {
        let evidenceLight = RecommendationExplanation(
            id: "explanation-evidence-light-model",
            type: .whyThis,
            title: "Why this",
            summary: "A default suggestion.",
            recommendationTitle: "Start small",
            lastUpdatedAt: "2026-05-12T12:02:00Z",
            source: .system
        ).recommendationEvidenceModel

        let calendarDerived = RecommendationExplanation(
            id: "explanation-calendar-model",
            type: .whyCalendarAware,
            title: "Why calendar-aware",
            summary: "Calendar pressure changed the suggestion.",
            recommendationTitle: "Move deep work",
            evidence: [
                RecommendationExplanationEvidence(
                    id: "calendar",
                    category: .calendarDerived,
                    title: "Calendar pressure"
                )
            ],
            lastUpdatedAt: "2026-05-12T12:03:00Z",
            source: .calendar,
            privacy: .calendarDerived
        ).recommendationEvidenceModel

        XCTAssertEqual(evidenceLight.strength, .evidenceLight)
        XCTAssertFalse(evidenceLight.canDriveRecommendation)
        XCTAssertEqual(calendarDerived.strength, .reviewRequired)
        XCTAssertTrue(calendarDerived.requiresSensitiveReview)
        XCTAssertFalse(calendarDerived.canDriveRecommendation)
    }

    func testSourceAtlasCurrentResultCanSupportRecommendationEvidence() {
        let result = Self.sourceAtlasResult(
            sourceState: .officialCurrent,
            freshnessState: .current,
            riskState: .low,
            reviewState: .approved,
            provenanceSourceIDs: ["source-official"],
            fallbackReason: .none
        )
        let evidence = RecommendationExplanationEvidence.fromSourceAtlasQueryResult(result)
        let explanation = RecommendationExplanation(
            id: "explanation-source-atlas-current",
            type: .whyThis,
            title: "Why this source supports the step",
            summary: "The source is current and approved.",
            recommendationTitle: "Review the sourced step",
            evidence: [evidence],
            lastUpdatedAt: "2026-05-13T06:30:00Z",
            source: .recommendation
        )

        let model = explanation.recommendationEvidenceModel

        XCTAssertEqual(evidence.category, .sourceTruth)
        XCTAssertEqual(evidence.metadata["sourceAtlasCanSupportCurrentUse"], "true")
        XCTAssertNil(evidence.metadata["sourceAtlasRecommendationBlockReason"])
        XCTAssertTrue(model.usesSourceAtlasEvidence)
        XCTAssertEqual(model.sourceAtlasBlockReasons, [])
        XCTAssertTrue(model.canDriveRecommendation)
    }

    func testSourceAtlasBlockedStatesCannotDriveRecommendationEvidence() {
        let blockedResults = [
            Self.sourceAtlasResult(sourceState: .sourceNeeded, freshnessState: .unknown, fallbackReason: .sourceNeeded),
            Self.sourceAtlasResult(sourceState: .stale, freshnessState: .stale, fallbackReason: .stale),
            Self.sourceAtlasResult(sourceState: .contradicted, fallbackReason: .contradicted),
            Self.sourceAtlasResult(sourceState: .revoked, freshnessState: .stale, fallbackReason: .revoked),
            Self.sourceAtlasResult(sourceState: .officialCurrent, riskState: .high, reviewState: .required, fallbackReason: .reviewRequired)
        ]

        for result in blockedResults {
            let evidence = RecommendationExplanationEvidence.fromSourceAtlasQueryResult(result)
            let explanation = RecommendationExplanation(
                id: "explanation-source-atlas-\((result.fallbackReason ?? .none).rawValue)",
                type: .whyThis,
                title: "Why this source needs review",
                summary: "The source state is not current support.",
                recommendationTitle: "Review the sourced step",
                evidence: [evidence],
                lastUpdatedAt: "2026-05-13T06:31:00Z",
                source: .recommendation
            )

            let model = explanation.recommendationEvidenceModel

            XCTAssertEqual(evidence.metadata["sourceAtlasCanSupportCurrentUse"], "false")
            XCTAssertEqual(evidence.metadata["sourceAtlasRecommendationBlockReason"], (result.fallbackReason ?? .none).rawValue)
            XCTAssertEqual(model.sourceAtlasBlockReasons, [(result.fallbackReason ?? .none).rawValue])
            XCTAssertFalse(model.canDriveRecommendation)
        }
    }

    func testRecommendationTraceNormalizesOrderSensitiveInputsAndTrimsIdentifiers() {
        let ordered = RecommendationTrace(
            id: " trace-1 ",
            recommendationID: " recommendation-1 ",
            source: RecommendationTraceSource(
                citedSourceIDs: [" source-b ", "source-a", "source-b"],
                sourceAtlasBlockReasons: [" block-b ", "block-a", "block-b"],
                localEvidenceCategories: [.priority, .sourceTruth, .priority],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: " explanation-1 ",
                summary: "A current source and local context support the suggestion.",
                evidenceCategoryIDs: [" category-b ", "category-a", "category-b"]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [" block-b ", "block-a", "block-b"],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: [" uncertainty-b ", "uncertainty-a", "uncertainty-b"],
                summaries: [" Summary B ", "Summary A", "Summary B"]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: [" correct-b ", "correct-a", "correct-b"],
                controlActionIDs: [" open ", "adjust", "open"],
                correctableFieldKeys: [" field-b ", "field-a", "field-b"],
                hasRequiredControl: true
            ),
            receiptBehavior: .available(
                receiptIDs: [" receipt-b ", "receipt-a", "receipt-b"],
                actionReceiptIDs: [" action-b ", "action-a", "action-b"],
                proofReferenceIDs: [" proof-b ", "proof-a", "proof-b"]
            )
        )
        let reordered = RecommendationTrace(
            id: "trace-1",
            recommendationID: "recommendation-1",
            source: RecommendationTraceSource(
                citedSourceIDs: ["source-a", "source-b"],
                sourceAtlasBlockReasons: ["block-a", "block-b"],
                localEvidenceCategories: [.sourceTruth, .priority],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "explanation-1",
                summary: "A current source and local context support the suggestion.",
                evidenceCategoryIDs: ["category-a", "category-b"]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: ["block-a", "block-b"],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: ["uncertainty-a", "uncertainty-b"],
                summaries: ["Summary A", "Summary B"]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: ["correct-a", "correct-b"],
                controlActionIDs: ["adjust", "open"],
                correctableFieldKeys: ["field-a", "field-b"],
                hasRequiredControl: true
            ),
            receiptBehavior: .available(
                receiptIDs: ["receipt-a", "receipt-b"],
                actionReceiptIDs: ["action-a", "action-b"],
                proofReferenceIDs: ["proof-a", "proof-b"]
            )
        )

        XCTAssertEqual(ordered, reordered)
        XCTAssertEqual(ordered.id, "trace-1")
        XCTAssertEqual(ordered.recommendationID, "recommendation-1")
        XCTAssertEqual(ordered.source.citedSourceIDs, ["source-a", "source-b"])
        XCTAssertEqual(ordered.source.sourceAtlasBlockReasons, ["block-a", "block-b"])
        XCTAssertEqual(ordered.source.localEvidenceCategories, [.priority, .sourceTruth])
        XCTAssertEqual(ordered.reason.evidenceCategoryIDs, ["category-a", "category-b"])
        XCTAssertEqual(ordered.fit.blockReasons, ["block-a", "block-b"])
        XCTAssertEqual(ordered.uncertainty.uncertaintyIDs, ["uncertainty-a", "uncertainty-b"])
        XCTAssertEqual(ordered.uncertainty.summaries, ["Summary A", "Summary B"])
        XCTAssertEqual(ordered.control.correctionActionIDs, ["correct-a", "correct-b"])
        XCTAssertEqual(ordered.control.controlActionIDs, ["adjust", "open"])
        XCTAssertEqual(ordered.control.correctableFieldKeys, ["field-a", "field-b"])
        XCTAssertEqual(ordered.receiptBehavior.receiptIDs, ["receipt-a", "receipt-b"])
        XCTAssertEqual(ordered.receiptBehavior.actionReceiptIDs, ["action-a", "action-b"])
        XCTAssertEqual(ordered.receiptBehavior.proofReferenceIDs, ["proof-a", "proof-b"])
        XCTAssertTrue(ordered.isComplete)
        XCTAssertTrue(ordered.canDriveRecommendationBehavior)
    }

    func testCompleteRecommendationTraceCarriesSourceReasonFitUncertaintyControlAndReceipt() {
        let result = Self.sourceAtlasResult(
            sourceState: .officialCurrent,
            freshnessState: .current,
            riskState: .low,
            reviewState: .approved,
            provenanceSourceIDs: ["source-official"],
            fallbackReason: .none
        )
        let evidence = RecommendationExplanationEvidence.fromSourceAtlasQueryResult(
            result,
            title: "Current source"
        )
        let explanation = RecommendationExplanation(
            id: "explanation-trace-complete",
            type: .whyThis,
            title: "Why this",
            summary: "A current source and local correction history support this recommendation.",
            recommendationTitle: "Review the sourced step",
            evidence: [evidence],
            uncertainty: [
                RecommendationExplanationUncertainty(
                    id: "uncertainty-duration",
                    summary: "The exact duration still needs review."
                )
            ],
            userCorrectableFields: ["duration"],
            correctionActions: [
                RecommendationExplanationCorrectionAction(
                    id: "correct-duration",
                    kind: .changeUrgency,
                    title: "Adjust duration",
                    targetFieldKey: "duration"
                )
            ],
            lastUpdatedAt: "2026-05-13T06:40:00Z",
            source: .recommendation
        )

        let trace = RecommendationTrace(
            explanation: explanation,
            fitState: .fits,
            receiptBehavior: .available(actionReceiptIDs: ["action-receipt-1"], proofReferenceIDs: ["proof-1"])
        )

        XCTAssertTrue(trace.isComplete)
        XCTAssertTrue(trace.canDriveRecommendationBehavior)
        XCTAssertEqual(trace.source.citedSourceIDs, ["source-official"])
        XCTAssertEqual(trace.reason.explanationID, explanation.id)
        XCTAssertEqual(trace.reason.evidenceCategoryIDs, ["source_truth"])
        XCTAssertEqual(trace.fit.state, .fits)
        XCTAssertEqual(trace.uncertainty.uncertaintyIDs, ["uncertainty-duration"])
        XCTAssertEqual(trace.control.correctableFieldKeys, ["duration"])
        XCTAssertEqual(trace.receiptBehavior.state, .receiptAvailable)
    }

    func testRecommendationTraceBlocksEvidenceLightSourceBlockedMissingControlAndMissingReceipt() {
        let evidenceLight = RecommendationExplanation(
            id: "explanation-trace-light",
            type: .whyThis,
            title: "Why this",
            summary: "A default suggestion.",
            recommendationTitle: "Start small",
            lastUpdatedAt: "2026-05-13T06:41:00Z",
            source: .system
        )
        let evidenceLightTrace = RecommendationTrace(
            explanation: evidenceLight,
            fitState: .fits,
            receiptBehavior: .available(actionReceiptIDs: ["action-receipt-1"])
        )

        let blockedResult = Self.sourceAtlasResult(
            sourceState: .sourceNeeded,
            freshnessState: .unknown,
            provenanceSourceIDs: [],
            fallbackReason: .sourceNeeded
        )
        let blockedExplanation = RecommendationExplanation(
            id: "explanation-trace-source-needed",
            type: .whyThis,
            title: "Why this needs source review",
            summary: "The source state does not support recommendation behavior yet.",
            recommendationTitle: "Review source first",
            evidence: [.fromSourceAtlasQueryResult(blockedResult)],
            uncertainty: [
                RecommendationExplanationUncertainty(
                    id: "uncertainty-source",
                    summary: "The required source is missing."
                )
            ],
            userCorrectableFields: ["source"],
            correctionActions: [
                RecommendationExplanationCorrectionAction(
                    id: "correct-source",
                    kind: .changeRoute,
                    title: "Add or review source",
                    targetFieldKey: "source"
                )
            ],
            lastUpdatedAt: "2026-05-13T06:42:00Z",
            source: .recommendation
        )
        let blockedTrace = RecommendationTrace(
            explanation: blockedExplanation,
            fitState: .sourceNeeded,
            receiptBehavior: .missing()
        )

        XCTAssertFalse(evidenceLightTrace.isComplete)
        XCTAssertFalse(evidenceLightTrace.canDriveRecommendationBehavior)
        XCTAssertFalse(blockedTrace.canDriveRecommendationBehavior)
        XCTAssertEqual(blockedTrace.source.sourceAtlasBlockReasons, ["source_needed"])
        XCTAssertEqual(blockedTrace.fit.state, .sourceNeeded)
        XCTAssertEqual(blockedTrace.receiptBehavior.state, .receiptMissing)
    }

    func testRecommendationTraceAppliesInspectableRejectionLearningToFutureRanking() throws {
        let correction = CorrectionFoldRecord.recommendation(
            id: "recommendation-correction-low-energy",
            recommendationID: "recommendation-previous",
            from: .stillUseful,
            to: .rejectedLowEnergyContext,
            reason: "This kind of step does not fit low-energy context.",
            occurredAt: "2026-05-13T10:30:43Z"
        )
        let influence = try XCTUnwrap(
            CorrectionFoldRecommendationLearningInfluence(
                correction: correction,
                similarRecommendationSignalKeys: ["capacity", "energy_fit"]
            )
        )
        let trace = RecommendationTrace(
            id: "trace-low-energy-learning",
            recommendationID: "recommendation-future",
            source: RecommendationTraceSource(
                citedSourceIDs: ["source-current"],
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.capacity],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "explanation-low-energy-learning",
                summary: "Local source context supports reviewing this step.",
                evidenceCategoryIDs: ["capacity"]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: ["uncertainty-energy"],
                summaries: ["Energy fit may need review."]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: ["correct-energy"],
                controlActionIDs: ["reject"],
                correctableFieldKeys: ["energy_fit"],
                hasRequiredControl: true
            ),
            receiptBehavior: .available(actionReceiptIDs: ["action-receipt-1"]),
            rejectionLearningInfluences: [influence]
        )

        XCTAssertTrue(trace.isComplete)
        XCTAssertTrue(trace.hasInspectableRejectionLearning)
        XCTAssertEqual(
            trace.rejectionLearningRankAdjustment,
            CorrectionFoldRecommendationLearningAdjustment.downrankLowEnergyContext.baseRankAdjustment
        )
        XCTAssertFalse(trace.isSuppressedByRejectionLearning)
        XCTAssertTrue(trace.canDriveRecommendationBehavior)
    }

    func testRecommendationTraceSuppressesExactPreviouslyRejectedRecommendation() throws {
        let correction = CorrectionFoldRecord.recommendation(
            id: "recommendation-correction-already-done",
            recommendationID: "recommendation-previous",
            from: .stillUseful,
            to: .rejectedAlreadyDone,
            reason: "This was already handled.",
            occurredAt: "2026-05-13T10:30:43Z"
        )
        let influence = try XCTUnwrap(CorrectionFoldRecommendationLearningInfluence(correction: correction))
        let trace = RecommendationTrace(
            id: "trace-exact-rejection",
            recommendationID: "recommendation-previous",
            source: RecommendationTraceSource(
                citedSourceIDs: ["source-current"],
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.sourceTruth],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "explanation-exact-rejection",
                summary: "This exact recommendation has already been rejected as handled.",
                evidenceCategoryIDs: ["source_truth"]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: ["uncertainty-rejection"],
                summaries: ["Rejection learning suppresses this exact item."]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: ["correct-rejection"],
                controlActionIDs: ["reject"],
                correctableFieldKeys: ["rejection_learning"],
                hasRequiredControl: true
            ),
            receiptBehavior: .available(actionReceiptIDs: ["action-receipt-1"]),
            rejectionLearningInfluences: [influence]
        )

        XCTAssertTrue(trace.hasInspectableRejectionLearning)
        XCTAssertEqual(
            trace.rejectionLearningRankAdjustment,
            CorrectionFoldRecommendationLearningAdjustment.suppressExactRecommendation.baseRankAdjustment
        )
        XCTAssertTrue(trace.isSuppressedByRejectionLearning)
        XCTAssertFalse(trace.canDriveRecommendationBehavior)
    }

    func testRecommendationTraceDecodesLegacyPayloadWithoutRejectionLearningInfluences() throws {
        let trace = RecommendationTrace(
            id: "trace-legacy-compatible",
            recommendationID: "recommendation-legacy-compatible",
            source: RecommendationTraceSource(
                citedSourceIDs: ["source-current"],
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.sourceTruth],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "explanation-legacy-compatible",
                summary: "Local source context supports this recommendation.",
                evidenceCategoryIDs: ["source_truth"]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: ["uncertainty-legacy"],
                summaries: ["Legacy payload has no rejection learning key."]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: ["correct-source"],
                controlActionIDs: ["reject"],
                correctableFieldKeys: ["source_truth"],
                hasRequiredControl: true
            ),
            receiptBehavior: .available(actionReceiptIDs: ["action-receipt-1"])
        )
        let data = try JSONEncoder().encode(trace)
        var payload = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        payload.removeValue(forKey: "rejectionLearningInfluences")
        let legacyData = try JSONSerialization.data(withJSONObject: payload)

        let decoded = try JSONDecoder().decode(RecommendationTrace.self, from: legacyData)

        XCTAssertEqual(decoded.rejectionLearningInfluences, [])
        XCTAssertEqual(decoded.rejectionLearningRankAdjustment, 0)
        XCTAssertFalse(decoded.hasInspectableRejectionLearning)
        XCTAssertTrue(decoded.canDriveRecommendationBehavior)
    }

    func testRecommendationTrustSeamProjectsCompleteTraceIntoVisibleSections() {
        let trace = RecommendationTrace(
            id: "trace-complete",
            recommendationID: "recommendation-1",
            source: RecommendationTraceSource(
                citedSourceIDs: ["source-current"],
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.sourceTruth, .priority],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "explanation-1",
                summary: "A current source and local priority context support this recommendation.",
                evidenceCategoryIDs: ["source_truth", "priority"]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: ["uncertainty-duration"],
                summaries: ["Duration still needs review."]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: ["correct-duration"],
                controlActionIDs: ["review-source"],
                correctableFieldKeys: ["duration"],
                hasRequiredControl: true
            ),
            receiptBehavior: .available(actionReceiptIDs: ["action-receipt-1"], proofReferenceIDs: ["proof-1"])
        )

        let seam = RecommendationTrustSeamState(trace: trace)

        XCTAssertEqual(
            seam.sectionKinds,
            [.source, .reason, .fit, .uncertainty, .controls, .receiptBehavior]
        )
        XCTAssertTrue(seam.canProceed)
        XCTAssertTrue(seam.needsReview)
        XCTAssertEqual(seam.localOnlyLabel, "Local-only")
        XCTAssertEqual(seam.section(.source)?.state, .ready)
        XCTAssertEqual(seam.section(.reason)?.state, .ready)
        XCTAssertEqual(seam.section(.fit)?.state, .ready)
        XCTAssertEqual(seam.section(.uncertainty)?.state, .reviewNeeded)
        XCTAssertEqual(seam.section(.controls)?.state, .ready)
        XCTAssertEqual(seam.section(.receiptBehavior)?.state, .ready)
        XCTAssertEqual(seam.section(.source)?.referenceIDs, ["priority", "source-current", "source_truth"])
        XCTAssertFalse(seam.hasVisibleCopyGuardrailViolation)
    }

    func testRecommendationTrustSeamSurfacesSourceNeededStaleAndBlockedStates() {
        let blockedReasons = ["source_needed", "stale"]
        let trace = RecommendationTrace(
            id: "trace-source-needed",
            recommendationID: "recommendation-source-needed",
            source: RecommendationTraceSource(
                citedSourceIDs: [],
                sourceAtlasBlockReasons: blockedReasons,
                localEvidenceCategories: [.sourceTruth],
                canSupportRecommendation: false
            ),
            reason: RecommendationTraceReason(
                explanationID: "explanation-source-needed",
                summary: "The source state needs review before this recommendation can guide behavior.",
                evidenceCategoryIDs: ["source_truth"]
            ),
            fit: RecommendationTraceFit(
                state: .sourceNeeded,
                blockReasons: blockedReasons,
                canDriveRecommendation: false
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: ["uncertainty-source"],
                summaries: ["Source freshness needs review."]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: ["correct-source"],
                controlActionIDs: [],
                correctableFieldKeys: ["source"],
                hasRequiredControl: true
            ),
            receiptBehavior: .required()
        )

        let seam = RecommendationTrustSeamState(trace: trace)

        XCTAssertFalse(seam.canProceed)
        XCTAssertTrue(seam.needsReview)
        XCTAssertEqual(seam.section(.source)?.state, .blocked)
        XCTAssertEqual(seam.section(.fit)?.state, .missing)
        XCTAssertEqual(seam.section(.receiptBehavior)?.state, .reviewNeeded)
        XCTAssertEqual(seam.section(.fit)?.referenceIDs, blockedReasons)
        XCTAssertEqual(seam.section(.source)?.summary, "Needs source review before this can guide behavior.")
        XCTAssertFalse(seam.hasVisibleCopyGuardrailViolation)
    }

    func testRecommendationTrustSeamBlocksMissingReceiptAndControlBehavior() {
        let trace = RecommendationTrace(
            id: "trace-missing-control-receipt",
            recommendationID: "recommendation-missing-control-receipt",
            source: RecommendationTraceSource(
                citedSourceIDs: ["source-current"],
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.sourceTruth],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "explanation-missing-control-receipt",
                summary: "A current source supports review, but controls and receipt proof are missing.",
                evidenceCategoryIDs: ["source_truth"]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: ["uncertainty-receipt"],
                summaries: ["Receipt behavior needs review."]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: [],
                controlActionIDs: [],
                correctableFieldKeys: [],
                hasRequiredControl: false
            ),
            receiptBehavior: .missing()
        )

        let seam = RecommendationTrustSeamState(trace: trace)

        XCTAssertFalse(trace.isComplete)
        XCTAssertFalse(seam.canProceed)
        XCTAssertTrue(seam.needsReview)
        XCTAssertEqual(seam.section(.controls)?.state, .missing)
        XCTAssertEqual(seam.section(.controls)?.summary, "Needs a correction or review control.")
        XCTAssertEqual(seam.section(.receiptBehavior)?.state, .missing)
        XCTAssertEqual(seam.section(.receiptBehavior)?.summary, "Needs a receipt before behavior changes.")
        XCTAssertFalse(seam.hasVisibleCopyGuardrailViolation)
    }

    func testRecommendationTrustSeamVisibleCopyAvoidsGuardrailLanguage() {
        let trace = RecommendationTrace(
            id: "trace-copy-guardrails",
            recommendationID: "recommendation-copy-guardrails",
            source: RecommendationTraceSource(
                citedSourceIDs: ["source-current"],
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.sourceTruth],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "explanation-copy-guardrails",
                summary: "Local source context supports reviewing this step.",
                evidenceCategoryIDs: ["source_truth"]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: [],
                summaries: []
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: ["correct-source"],
                controlActionIDs: [],
                correctableFieldKeys: ["source"],
                hasRequiredControl: true
            ),
            receiptBehavior: .notApplicable()
        )

        let seam = RecommendationTrustSeamState(trace: trace)
        let visibleCopy = seam.visibleCopy.joined(separator: " ")

        XCTAssertFalse(seam.hasVisibleCopyGuardrailViolation)
        XCTAssertFalse(visibleCopy.contains("%"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("confidence"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("assistant"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("dash" + "board"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("best " + "next " + "move"))
    }

    func testRecommendationTraceReasonGraphIsDeterministicAndExportSafe() throws {
        let trace = RecommendationTrace(
            id: "trace-graph",
            recommendationID: "recommendation-graph",
            source: RecommendationTraceSource(
                citedSourceIDs: [" source-b ", "source-a", "source-b"],
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.sourceTruth, .priority],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "explanation-graph",
                summary: "Local source context supports this recommendation.",
                evidenceCategoryIDs: [" priority ", "source_truth", "priority"]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [" block-b ", "block-a", "block-b"],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: [" uncertainty-b ", "uncertainty-a", "uncertainty-b"],
                summaries: [" Summary B ", "Summary A", "Summary B"]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: [" correct-b ", "correct-a", "correct-b"],
                controlActionIDs: [" open ", "adjust", "open"],
                correctableFieldKeys: [" field-b ", "field-a", "field-b"],
                hasRequiredControl: true
            ),
            receiptBehavior: .available(
                receiptIDs: [" receipt-b ", "receipt-a", "receipt-b"],
                actionReceiptIDs: [" action-b ", "action-a", "action-b"],
                proofReferenceIDs: [" proof-b ", "proof-a", "proof-b"]
            )
        )

        let graph = trace.reasonGraph(
            runtimeSnapshotReferenceIDs: [" snapshot-b ", "snapshot-a", "snapshot-b"],
            replayTraceIDs: [" replay-b ", "replay-a", "replay-b"],
            localFitLabels: [" fit-b ", "fit-a", "fit-b"]
        )
        let decoded = try PersistenceCoding.decode(
            RecommendationTraceReasonGraph.self,
            from: PersistenceCoding.encode(graph)
        )

        XCTAssertEqual(decoded, graph)
        XCTAssertEqual(graph.id, "trace.trace-graph.reason_graph")
        XCTAssertEqual(graph.recommendationID, "recommendation-graph")
        XCTAssertEqual(graph.sourceIDs, ["source-a", "source-b"])
        XCTAssertEqual(graph.receiptIDs, ["action-a", "action-b", "proof-a", "proof-b", "receipt-a", "receipt-b"])
        XCTAssertEqual(graph.replayTraceIDs, ["replay-a", "replay-b"])
        XCTAssertEqual(graph.runtimeSnapshotReferenceIDs, ["snapshot-a", "snapshot-b"])
        XCTAssertEqual(graph.localFitLabels, ["fit-a", "fit-b"])
        XCTAssertEqual(graph.nodes.map(\.id), graph.nodes.map(\.id).sorted())
        XCTAssertEqual(graph.edges.map(\.id), graph.edges.map(\.id).sorted())
        XCTAssertEqual(graph.counterfactualDiffs.map(\.id), graph.counterfactualDiffs.map(\.id).sorted())
        let nodeIDs = Set(graph.nodes.map(\.id))
        XCTAssertTrue(graph.edges.allSatisfy { nodeIDs.contains($0.fromNodeID) && nodeIDs.contains($0.toNodeID) })
        XCTAssertTrue(graph.nodes.contains { $0.kind == .uncertainty })
        XCTAssertTrue(graph.isExportSafe)
        XCTAssertFalse(graph.hasVisibleCopyGuardrailViolation)

        let visibleCopy = graph.visibleCopy.joined(separator: " ")
        XCTAssertTrue(visibleCopy.contains("Local-only redacted export"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("confidence"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("assistant"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("dash" + "board"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("best " + "next " + "move"))
    }

    func testPlanningRuleCounterfactualDiffsStayDeterministicAndInspectable() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T09:30:00Z"))
        let selectedGoal = makeGoal(id: "goal-selected-diff", stepID: "step-selected-diff", dueAt: "2026-04-22T12:00:00Z")
        let alternativeGoal = makeGoal(id: "goal-alternative-diff", stepID: "step-alternative-diff", dueAt: "2026-04-24T12:00:00Z")

        let ranked = PlanningNextStepSelector().rankedSelections(goals: [selectedGoal, alternativeGoal], now: now)
        let selected = try XCTUnwrap(ranked.first)
        let alternatives = Array(ranked.dropFirst())
        let diffs = PlanningRuleTrace.counterfactualDiffs(
            selected: selected,
            alternatives: alternatives,
            runtimeSnapshotReferenceID: "runtime-snapshot-1"
        )
        let decoded = try PersistenceCoding.decode(
            [PlanningRuleCounterfactualDiff].self,
            from: PersistenceCoding.encode(diffs)
        )

        XCTAssertEqual(decoded, diffs)
        XCTAssertEqual(diffs.map { $0.id }, diffs.map { $0.id }.sorted())
        XCTAssertTrue(diffs.allSatisfy { $0.isExportSafe })
        XCTAssertFalse(diffs.contains { $0.hasVisibleCopyGuardrailViolation })
        XCTAssertEqual(diffs.first?.selectedStepID, selected.step.id)
        XCTAssertEqual(diffs.first?.selectedTraceID, selected.candidate.ruleTrace?.id)
        XCTAssertEqual(diffs.first?.sourceRecordID, selected.candidate.ruleTrace?.sourceRecordID)
        XCTAssertEqual(diffs.first?.runtimeSnapshotReferenceID, "runtime-snapshot-1")
        XCTAssertEqual(diffs.first?.rankDelta, 1)
        XCTAssertTrue(diffs.first?.summary.contains(selected.step.title) ?? false)
        XCTAssertTrue(diffs.first?.summary.contains(alternatives.first?.step.title ?? "") ?? false)
        XCTAssertFalse(diffs.flatMap { $0.visibleCopy }.joined(separator: " ").localizedCaseInsensitiveContains("confidence"))
        XCTAssertFalse(diffs.flatMap { $0.visibleCopy }.joined(separator: " ").localizedCaseInsensitiveContains("assistant"))
        XCTAssertFalse(diffs.flatMap { $0.visibleCopy }.joined(separator: " ").localizedCaseInsensitiveContains("dash" + "board"))
        XCTAssertFalse(diffs.flatMap { $0.visibleCopy }.joined(separator: " ").localizedCaseInsensitiveContains("best " + "next " + "move"))
    }
}

private extension RecommendationExplanationModelsTests {
    static func sourceAtlasResult(
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState = .current,
        riskState: SourceAtlasRequirementRiskState = .low,
        reviewState: SourceAtlasRequirementReviewState = .approved,
        provenanceSourceIDs: [String] = ["source-official"],
        fallbackReason: SourceAtlasQueryFallbackReason
    ) -> SourceAtlasQueryResult {
        SourceAtlasQueryResult(
            id: "result-\(fallbackReason.rawValue)-\(sourceState.rawValue)",
            packID: "source-pack-1",
            domainID: "career",
            goalIntent: "starter_goal",
            claimID: "claim-1",
            requirementID: "requirement-1",
            sourceState: sourceState,
            freshnessState: freshnessState,
            riskState: riskState,
            riskClass: .careerContext,
            reviewState: reviewState,
            provenanceSourceIDs: provenanceSourceIDs,
            proofEntryIDs: ["proof-1"],
            fallbackReason: fallbackReason,
            sourceNeededDetail: nil
        )
    }

    func makeGoal(
        id: String,
        stepID: String,
        dueAt: String,
        stepState: StepLifecycleState = .planned,
        dependencyStepIDs: [String] = []
    ) -> Goal {
        let actor = GoalActor(actorID: "self", displayName: "You", ownership: .self, roleLabel: "Primary owner", isPrimary: true)
        let timing = GoalTiming(
            tempo: .deadlineBased,
            timingType: .dueAt,
            startsOn: nil,
            dueAt: dueAt,
            targetBy: nil,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: nil,
            repeatEveryDays: nil,
            progressReviewCadenceDays: 7
        )
        let strategy = PlanningStrategy(
            strategyKind: .sequential,
            allowParallelSteps: false,
            maxActiveSteps: 3,
            preferredSectionOrder: [.activeSteps],
            defaultStepType: .actionUnit,
            autoGenerateReviewSection: false,
            preferShortSteps: true,
            revisitCadenceDays: 7
        )
        let progress = ProgressStrategy(
            metricKind: .stepCompletion,
            rollupMethod: .ratio,
            targetStepCount: nil,
            targetEvidenceCount: nil,
            targetMinutes: nil,
            supportsUntimedProgress: true,
            countsChildGoals: false,
            countsSupportGoals: false
        )
        let step = Step(
            id: stepID,
            sectionID: "section-\(id)",
            title: "Do the next thing",
            summary: nil,
            type: .actionUnit,
            state: stepState,
            owner: actor,
            timing: timing,
            dependencyStepIDs: dependencyStepIDs,
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: true,
            successSignals: ["Done"],
            actionability: StepActionability(
                action: "Do it",
                completionDefinition: "Done",
                evidenceOfCompletion: ["Done"],
                fallbackMicroStep: "Start",
                contextRequirements: []
            )
        )
        let plan = GoalPlan(
            id: "plan-\(id)",
            goalID: id,
            version: goalEnginePlanVersion,
            generatedAt: "2026-04-15T12:00:00Z",
            summary: nil,
            strategy: strategy,
            sections: [
                PlanSection(
                    id: "section-\(id)",
                    goalID: id,
                    title: "Active",
                    summary: nil,
                    kind: .activeSteps,
                    orderIndex: 0,
                    steps: [step]
                )
            ],
            assumptions: [],
            lint: PlanLintResult(goalID: id, planVersion: goalEnginePlanVersion, isValid: true, issueCount: 0, issues: [])
        )
        return Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: id,
            revision: 1,
            createdAt: "2026-04-15T12:00:00Z",
            updatedAt: "2026-04-15T12:00:00Z",
            state: .active,
            title: id,
            summary: nil,
            mode: .project,
            relationshipKind: .independent,
            actor: actor,
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: [],
            timing: timing,
            planningStrategy: strategy,
            progressStrategy: progress,
            plan: plan
        )
    }
}

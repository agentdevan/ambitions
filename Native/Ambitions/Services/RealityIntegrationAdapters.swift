import Foundation

enum RealityIntegrationAdapter {
    static func calendarContextObservedEntry(
        snapshot: RealitySnapshot,
        occurredAt: Date,
        actionName: String
    ) -> EventLedgerEntry {
        EventLedgerEntry(
            id: "ledger.reality.calendar.\(Int(occurredAt.timeIntervalSince1970))",
            kind: .calendarContextObserved,
            occurredAt: DomainTimestamp.string(from: occurredAt),
            source: .plan,
            title: "Calendar context observed",
            summary: "Plan used derived calendar availability locally for \(actionName).",
            semanticState: snapshot.calendarContext?.permissionState.rawValue,
            tone: .neutral,
            trust: EventLedgerTrustMetadata(confidence: snapshot.calendarContext?.hasCalendarReadAccess == true ? 0.8 : 0.4),
            evidenceReferences: [
                EventLedgerEvidenceReference(
                    id: snapshot.id,
                    kind: .calendarContext,
                    occurredAt: DomainTimestamp.string(from: snapshot.generatedAt),
                    summary: "\(snapshot.availability.calendarDerivedBusyCount) derived busy windows"
                )
            ],
            metadata: [
                "actionName": actionName,
                "permissionState": snapshot.calendarContext?.permissionState.rawValue ?? CalendarPermissionState.unavailable.rawValue,
                "derivedBusyWindowCount": "\(snapshot.availability.calendarDerivedBusyCount)",
                "openWindowCount": "\(snapshot.openWindowCandidates.count)"
            ],
            payload: [
                "horizonStart": DomainTimestamp.string(from: snapshot.horizonStart),
                "horizonEnd": DomainTimestamp.string(from: snapshot.horizonEnd)
            ],
            privacy: .calendarDerived
        )
    }

    static func calendarBlockScheduledEntry(
        block: ScheduledAmbitionsBlock,
        occurredAt: Date
    ) -> EventLedgerEntry {
        EventLedgerEntry(
            id: "ledger.reality.block.\(block.id)",
            kind: block.relatedPlanID == nil ? .itemScheduled : .planScheduled,
            occurredAt: DomainTimestamp.string(from: occurredAt),
            source: .plan,
            goalID: block.relatedGoalID,
            captureID: block.relatedCaptureID,
            planID: block.relatedPlanID,
            title: "Calendar block created",
            summary: "A user-confirmed Ambitions block was created in Calendar.",
            semanticState: block.contextLens.rawValue,
            tone: .positive,
            trust: EventLedgerTrustMetadata(confidence: 0.9, isUserConfirmed: block.isUserConfirmed),
            evidenceReferences: [
                EventLedgerEvidenceReference(
                    id: block.id,
                    kind: .plan,
                    occurredAt: DomainTimestamp.string(from: block.start),
                    summary: "scheduled_ambitions_block"
                )
            ],
            metadata: [
                "contextLens": block.contextLens.rawValue,
                "calendarEventWritten": block.calendarEventIdentifier == nil ? "false" : "true"
            ],
            payload: [
                "blockID": block.id,
                "start": DomainTimestamp.string(from: block.start),
                "end": DomainTimestamp.string(from: block.end)
            ],
            privacy: .standard
        )
    }

    static func calendarAwareExplanation(
        snapshot: RealitySnapshot,
        ledgerEntryID: String? = nil
    ) -> RecommendationExplanation {
        let evidence = RecommendationExplanationEvidence(
            id: "evidence.reality.calendar.\(snapshot.id)",
            category: .calendarDerived,
            title: "Calendar-derived availability",
            summary: snapshot.availability.summary,
            sourceID: snapshot.id,
            eventLedgerEntryID: ledgerEntryID,
            confidence: snapshot.calendarContext?.hasCalendarReadAccess == true ? .high : .low,
            isCalendarDerived: true,
            metadata: [
                "openWindowCount": "\(snapshot.openWindowCandidates.count)",
                "calendarBusyWindowCount": "\(snapshot.availability.calendarDerivedBusyCount)"
            ]
        )
        return RecommendationExplanation(
            id: "explanation.reality.calendar.\(snapshot.id)",
            type: snapshot.openWindowCandidates.isEmpty ? .whyNotBelievable : .whyCalendarAware,
            title: snapshot.openWindowCandidates.isEmpty ? "Why time looks tight" : "Why Plan is calendar-aware",
            summary: snapshot.calendarContext?.explanation ?? snapshot.availability.summary,
            recommendationTitle: snapshot.openWindowCandidates.isEmpty ? "Keep this unscheduled until there is room" : "Use the visible open windows",
            recommendationSummary: snapshot.availability.summary,
            confidence: snapshot.calendarContext?.hasCalendarReadAccess == true ? .high : .low,
            evidence: [evidence],
            uncertainty: snapshot.calendarContext?.hasCalendarReadAccess == true ? [] : [
                RecommendationExplanationUncertainty(
                    id: "uncertainty.calendar.permission",
                    summary: "Calendar access is unavailable, so this uses baseline planning windows only.",
                    severity: .medium
                )
            ],
            lastUpdatedAt: DomainTimestamp.string(from: snapshot.generatedAt),
            source: .plan,
            relations: RecommendationExplanationRelations(
                eventLedgerEntryIDs: [ledgerEntryID].compactMap { $0 }
            ),
            privacy: snapshot.privacy,
            localOnly: true
        )
    }

    static func scheduledBlockExplanation(
        block: ScheduledAmbitionsBlock,
        ledgerEntryID: String? = nil
    ) -> RecommendationExplanation {
        RecommendationExplanation(
            id: "explanation.reality.block.\(block.id)",
            type: .whyScheduled,
            title: "Why this was scheduled",
            summary: "This block was written only after explicit user confirmation.",
            recommendationTitle: "Keep the confirmed block on the plan",
            recommendationSummary: "Calendar contains the user-confirmed Ambitions block.",
            confidence: .high,
            evidence: [
                RecommendationExplanationEvidence(
                    id: "evidence.reality.block.\(block.id)",
                    category: .planState,
                    title: "User-confirmed Ambitions block",
                    summary: "Calendar write used Ambitions-created schedule data, not raw calendar event details.",
                    sourceID: block.id,
                    eventLedgerEntryID: ledgerEntryID,
                    confidence: .high,
                    metadata: [
                        "contextLens": block.contextLens.rawValue,
                        "calendarEventWritten": block.calendarEventIdentifier == nil ? "false" : "true"
                    ]
                )
            ],
            lastUpdatedAt: DomainTimestamp.string(from: block.start),
            source: .plan,
            relations: RecommendationExplanationRelations(
                goalIDs: [block.relatedGoalID].compactMap { $0 },
                captureIDs: [block.relatedCaptureID].compactMap { $0 },
                planIDs: [block.relatedPlanID].compactMap { $0 },
                eventLedgerEntryIDs: [ledgerEntryID].compactMap { $0 }
            ),
            privacy: .standard,
            localOnly: true
        )
    }
}

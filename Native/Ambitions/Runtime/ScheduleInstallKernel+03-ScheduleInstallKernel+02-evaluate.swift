import Foundation

extension ScheduleInstallKernel {
    func evaluate(_ input: ScheduleInstallInput) -> ScheduleInstallRecord {
        var issues = baselineIssues(for: input)
        let selectedVariant = selectedVariant(for: input)
        let preview = makePreview(input: input, selectedVariant: selectedVariant)
        issues.formUnion(previewIssues(preview, input: input))

        let selectedWindow = selectedWindow(for: preview, decision: input.decision)
        issues.formUnion(windowIssues(selectedWindow, protectedTimeProof: input.protectedTimeProof))
        issues.formUnion(decisionIssues(input.decision))
        issues.formUnion(rollbackIssues(input.rollbackPlan, decision: input.decision))

        let sortedIssues = sortedIssues(issues)
        let rollbackTrace = sortedIssues.isEmpty ? makeRollbackTrace(input: input, preview: preview) : nil
        let installReceipt = sortedIssues.isEmpty ? makeReceipt(input: input, preview: preview, selectedWindow: selectedWindow, rollbackTrace: rollbackTrace) : nil
        return makeRecord(input: input, preview: preview, installReceipt: installReceipt, rollbackTrace: rollbackTrace, issues: issues)
    }


    func baselineIssues(for input: ScheduleInstallInput) -> Set<ScheduleInstallIssue> {
        var issues: Set<ScheduleInstallIssue> = []
        if input.elasticityRecord.canDriveElasticitySegment == false {
            issues.insert(.elasticityBlocked)
        }
        if input.elasticityRecord.trace.replayTraceIDs.isEmpty {
            issues.insert(.missingElasticityTrace)
        }
        if input.elasticityRecord.receipts.isEmpty {
            issues.insert(.missingElasticityReceipt)
        }
        if selectedVariant(for: input) == nil {
            issues.insert(.missingSelectedVariant)
        }
        if input.candidateWindows.isEmpty {
            issues.insert(.missingSchedulePreview)
        }
        if input.localOnly == false {
            issues.insert(.nonLocalRuntimeBoundary)
        }
        return issues
    }


    func makePreview(
        input: ScheduleInstallInput,
        selectedVariant: StepElasticityVariant?
    ) -> ScheduleInstallPreview? {
        guard input.elasticityRecord.canDriveElasticitySegment, let selectedVariant else {
            return nil
        }
        let windows = input.candidateWindows.sorted { lhs, rhs in
            if lhs.startAt == rhs.startAt {
                return lhs.id < rhs.id
            }
            return lhs.startAt < rhs.startAt
        }
        guard windows.isEmpty == false else {
            return nil
        }
        let sourceRecordIDs = normalizedIDs(
            selectedVariant.sourceRecordIDs +
                input.elasticityRecord.receipts.flatMap(\.sourceRecordIDs) +
                windows.flatMap(\.sourceRecordIDs) +
                (input.protectedTimeProof?.sourceRecordIDs ?? [])
        )
        let receiptIDs = normalizedIDs(
            selectedVariant.receiptIDs +
                input.elasticityRecord.receipts.flatMap(\.receiptIDs) +
                windows.flatMap(\.receiptIDs) +
                (input.protectedTimeProof?.receiptIDs ?? [])
        )
        let replayTraceIDs = normalizedIDs(
            input.elasticityRecord.trace.replayTraceIDs +
                windows.compactMap(\.replayTraceID) +
                [input.protectedTimeProof?.replayTraceID].compactMap { $0 }
        )
        let routes = normalizedIDs(
            windows.compactMap(\.whatAmbitionsKnowsRoute) +
                [input.protectedTimeProof?.whatAmbitionsKnowsRoute, selectedVariant.whatAmbitionsKnowsRoute].compactMap { $0 }
        )
        return ScheduleInstallPreview(
            id: stableIdentifier(
                prefix: "schedule-install.preview",
                components: [
                    input.elasticityRecord.goalReferenceID,
                    selectedVariant.id,
                    windows.map(\.id).joined(separator: ",")
                ]
            ),
            selectedVariantID: selectedVariant.id,
            selectedWindowID: input.decision?.selectedWindowID,
            candidateWindows: windows,
            protectedWindowIDs: windows.filter(\.isProtectedTime).map(\.id).sorted(),
            sourceRecordIDs: sourceRecordIDs,
            receiptIDs: receiptIDs,
            replayTraceIDs: replayTraceIDs,
            whatAmbitionsKnowsRoutes: routes
        )
    }


    func selectedVariant(for input: ScheduleInstallInput) -> StepElasticityVariant? {
        guard let selectedVariantID = input.selectedVariantID, selectedVariantID.isEmpty == false else {
            return nil
        }
        return input.elasticityRecord.variants.first { $0.id == selectedVariantID }
    }


    func selectedWindow(
        for preview: ScheduleInstallPreview?,
        decision: ScheduleInstallDecision?
    ) -> ScheduleInstallTimeWindow? {
        guard let selectedWindowID = decision?.selectedWindowID else {
            return nil
        }
        return preview?.candidateWindows.first { $0.id == selectedWindowID }
    }


    func previewIssues(_ preview: ScheduleInstallPreview?, input: ScheduleInstallInput) -> Set<ScheduleInstallIssue> {
        guard let preview else {
            return [.missingSchedulePreview]
        }
        var issues: Set<ScheduleInstallIssue> = []
        if preview.sourceRecordIDs.isEmpty {
            issues.insert(.missingSourceRecord)
        }
        if preview.receiptIDs.isEmpty {
            issues.insert(.missingReceipt)
        }
        if preview.replayTraceIDs.isEmpty {
            issues.insert(.missingReplayTrace)
        }
        if preview.whatAmbitionsKnowsRoutes.isEmpty {
            issues.insert(.missingInspectionRoute)
        }
        if preview.protectedWindowIDs.isEmpty == false && input.protectedTimeProof?.isInspectable != true {
            issues.insert(.missingProtectedTimeProof)
        }
        for window in preview.candidateWindows where window.isInspectable == false {
            issues.insert(.invalidTimeWindow)
            if window.sourceRecordIDs.isEmpty {
                issues.insert(.missingSourceRecord)
            }
            if window.receiptIDs.isEmpty {
                issues.insert(.missingReceipt)
            }
            if window.replayTraceID == nil {
                issues.insert(.missingReplayTrace)
            }
            if window.whatAmbitionsKnowsRoute == nil {
                issues.insert(.missingInspectionRoute)
            }
        }
        return issues
    }


    func windowIssues(
        _ window: ScheduleInstallTimeWindow?,
        protectedTimeProof: ScheduleInstallProtectedTimeProof?
    ) -> Set<ScheduleInstallIssue> {
        guard let window else {
            return [.missingSelectedWindow]
        }
        var issues: Set<ScheduleInstallIssue> = []
        if window.isInspectable == false {
            issues.insert(.invalidTimeWindow)
        }
        if window.isProtectedTime {
            issues.insert(.protectedTimeConflict)
            if protectedTimeProof?.isInspectable != true {
                issues.insert(.missingProtectedTimeProof)
            }
        }
        return issues
    }


    func decisionIssues(_ decision: ScheduleInstallDecision?) -> Set<ScheduleInstallIssue> {
        guard let decision else {
            return [.missingCommitDecision]
        }
        var issues: Set<ScheduleInstallIssue> = []
        if decision.kind != .commit || decision.userApproved == false {
            issues.insert(.installNotCommitted)
        }
        if decision.decisionReceiptID == nil {
            issues.insert(.missingDecisionReceipt)
        }
        if decision.isInspectable == false {
            if decision.sourceRecordIDs.isEmpty {
                issues.insert(.missingSourceRecord)
            }
            if decision.receiptIDs.isEmpty || decision.decisionReceiptID == nil {
                issues.insert(.missingReceipt)
            }
            if decision.replayTraceID == nil {
                issues.insert(.missingReplayTrace)
            }
            if decision.whatAmbitionsKnowsRoute == nil {
                issues.insert(.missingInspectionRoute)
            }
            issues.insert(.opaqueInstall)
        }
        if decision.localOnly == false {
            issues.insert(.nonLocalRuntimeBoundary)
        }
        if decision.silentlyMutatesTime {
            issues.insert(.silentTimeMutation)
        }
        return issues
    }


    func rollbackIssues(
        _ rollbackPlan: ScheduleInstallRollbackPlan?,
        decision: ScheduleInstallDecision?
    ) -> Set<ScheduleInstallIssue> {
        guard decision?.kind == .commit else {
            return []
        }
        guard let rollbackPlan else {
            return [.missingRollbackTrace]
        }
        var issues: Set<ScheduleInstallIssue> = []
        if rollbackPlan.isInspectable == false {
            issues.insert(.missingRollbackTrace)
            if rollbackPlan.sourceRecordIDs.isEmpty {
                issues.insert(.missingSourceRecord)
            }
            if rollbackPlan.receiptIDs.isEmpty || rollbackPlan.rollbackReceiptID.isEmpty {
                issues.insert(.missingReceipt)
            }
            if rollbackPlan.replayTraceID == nil {
                issues.insert(.missingReplayTrace)
            }
            if rollbackPlan.whatAmbitionsKnowsRoute == nil {
                issues.insert(.missingInspectionRoute)
            }
            if rollbackPlan.reversible == false {
                issues.insert(.irreversibleInstall)
            }
        }
        if rollbackPlan.localOnly == false {
            issues.insert(.nonLocalRuntimeBoundary)
        }
        return issues
    }
}

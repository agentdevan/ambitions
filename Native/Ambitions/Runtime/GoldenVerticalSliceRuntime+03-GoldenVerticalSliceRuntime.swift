import Foundation

extension GoldenVerticalSliceRuntime {
    func qualityFirewallSegment(from recommendedStep: RecommendedStepEligibility) -> RuntimeCoreChainSegment {
        RuntimeCoreChainSegment(
            kind: .qualityFirewall,
            state: recommendedStep.canShow ? .ready : .blocked,
            sourceRecordIDs: recommendedStep.sourceRecordIDs,
            receiptIDs: recommendedStep.receiptIDs,
            replayTraceID: recommendedStep.replayTraceID,
            whatAmbitionsKnowsRoute: recommendedStep.whatAmbitionsKnowsRoute,
            isReversible: true,
            canDriveVisibleExecution: recommendedStep.canShow,
            blocksDownstream: recommendedStep.canShow == false
        )
    }

    func sliceIssues(
        input: GoldenVerticalSliceInput,
        anyGoalRecord: AnyGoalCoverageRecord,
        recommendedStep: RecommendedStepEligibility,
        latticeRecord: MultiPathLatticeRecord,
        graphRecord: StepGraphCompilerRecord,
        elasticityRecord: StepElasticityRecord,
        scheduleRecord: ScheduleInstallRecord,
        consequenceRecord: LifeConsequenceRecord,
        safetyRecord: HighRiskSafetyGateRecord,
        runtimeCoreRecord: RuntimeCoreUmbrellaGateRecord
    ) -> Set<GoldenVerticalSliceIssue> {
        var issues: Set<GoldenVerticalSliceIssue> = []
        if input.localOnly == false {
            issues.insert(.nonLocalRuntimeBoundary)
        }
        if input.endUserBackground.isInspectable == false {
            issues.insert(.backgroundMissing)
        }
        if input.intake.isInspectable == false {
            issues.insert(.intakeMissing)
        }
        if input.intake.isMusicReleaseGoal == false {
            issues.insert(.notMusicReleaseGoal)
        }
        if anyGoalRecord.canContinueToStepQualityFirewall == false || anyGoalRecord.canGenerateVisibleStep == false {
            issues.insert(.anyGoalBlocked)
        }
        if recommendedStep.canShow == false {
            issues.insert(.stepQualityBlocked)
        }
        if latticeRecord.canDrivePathSelectionSegment == false {
            issues.insert(.pathSelectionBlocked)
        }
        if graphRecord.canDriveGraphCompilerSegment == false {
            issues.insert(.graphCompilerBlocked)
        }
        if elasticityRecord.canDriveElasticitySegment == false {
            issues.insert(.elasticityBlocked)
        }
        if scheduleRecord.canDriveScheduleInstallSegment == false {
            issues.insert(.scheduleInstallBlocked)
        }
        if consequenceRecord.canDriveConsequenceReflowSegment == false {
            issues.insert(.consequenceReflowBlocked)
        }
        if safetyRecord.canContinueToRuntimeCore == false || safetyRecord.canGenerateVisibleStep == false || safetyRecord.canInstallSchedule == false {
            issues.insert(.highRiskSafetyBlocked)
        }
        if runtimeCoreRecord.canOpenRuntimeCore == false {
            issues.insert(.runtimeCoreBlocked)
        }
        if input.completionProof.isInspectable == false {
            issues.insert(.completionProofMissing)
        }
        if input.completionProof.completedStepID != recommendedStep.candidateId {
            issues.insert(.completionDoesNotMatchRecommendedStep)
        }
        if input.replayOutput.isInspectable == false {
            issues.insert(.replayOutputMissing)
        }
        if replayMatchesRuntime(input: input, latticeRecord: latticeRecord, scheduleRecord: scheduleRecord, consequenceRecord: consequenceRecord, safetyRecord: safetyRecord) == false {
            issues.insert(.replayOutputDoesNotMatchRuntime)
        }
        if let shareProof = input.optionalShareProof, shareProof.isInspectable == false {
            issues.insert(.optionalShareProofBlocked)
        }
        if Set(input.endUserBackground.sourceRecordIDs).isSubset(of: Set(input.replayOutput.sourceRecordIDs)) == false {
            issues.insert(.backgroundNotCarriedIntoReplay)
        }
        return issues
    }

    func replayMatchesRuntime(
        input: GoldenVerticalSliceInput,
        latticeRecord: MultiPathLatticeRecord,
        scheduleRecord: ScheduleInstallRecord,
        consequenceRecord: LifeConsequenceRecord,
        safetyRecord: HighRiskSafetyGateRecord
    ) -> Bool {
        input.replayOutput.intakeReceiptID == input.intake.receiptIDs.first &&
            input.replayOutput.selectedPathReceiptID == latticeRecord.selectionReceipt?.id &&
            input.replayOutput.scheduleReceiptID == scheduleRecord.installReceipt?.id &&
            input.replayOutput.completionReceiptID == input.completionProof.receiptIDs.first &&
            input.replayOutput.reflowTraceID == consequenceRecord.trace.id &&
            input.replayOutput.safetyReceiptID == safetyRecord.receipt.id &&
            input.replayOutput.replayTraceIDs.contains(consequenceRecord.trace.id) &&
            input.replayOutput.replayTraceIDs.contains(safetyRecord.trace.id)
    }

    func allReceiptIDs(
        input: GoldenVerticalSliceInput,
        anyGoalRecord: AnyGoalCoverageRecord,
        recommendedStep: RecommendedStepEligibility,
        latticeRecord: MultiPathLatticeRecord,
        graphRecord: StepGraphCompilerRecord,
        elasticityRecord: StepElasticityRecord,
        scheduleRecord: ScheduleInstallRecord,
        consequenceRecord: LifeConsequenceRecord,
        safetyRecord: HighRiskSafetyGateRecord
    ) -> [String] {
        var receiptIDs = input.endUserBackground.receiptIDs
        receiptIDs.append(contentsOf: input.intake.receiptIDs)
        receiptIDs.append(contentsOf: anyGoalRecord.recoveryReceipt.receiptID.asArray)
        receiptIDs.append(contentsOf: recommendedStep.receiptIDs)
        if let latticeReceiptID = latticeRecord.selectionReceipt?.id {
            receiptIDs.append(latticeReceiptID)
        }
        receiptIDs.append(contentsOf: graphRecord.receipt?.receiptIDs ?? [])
        receiptIDs.append(contentsOf: elasticityRecord.receipts.flatMap(\.receiptIDs))
        receiptIDs.append(contentsOf: scheduleRecord.installReceipt?.receiptIDs ?? [])
        receiptIDs.append(contentsOf: consequenceRecord.receipts.flatMap(\.receiptIDs))
        receiptIDs.append(safetyRecord.receipt.id)
        receiptIDs.append(contentsOf: safetyRecord.receipt.receiptIDs)
        receiptIDs.append(contentsOf: input.completionProof.receiptIDs)
        receiptIDs.append(contentsOf: input.optionalShareProof?.receiptIDs ?? [])
        receiptIDs.append(contentsOf: input.replayOutput.receiptIDs)
        return normalizedIDs(receiptIDs)
    }

    func allReplayTraceIDs(
        input: GoldenVerticalSliceInput,
        anyGoalRecord: AnyGoalCoverageRecord,
        recommendedStep: RecommendedStepEligibility,
        latticeRecord: MultiPathLatticeRecord,
        graphRecord: StepGraphCompilerRecord,
        elasticityRecord: StepElasticityRecord,
        scheduleRecord: ScheduleInstallRecord,
        consequenceRecord: LifeConsequenceRecord,
        safetyRecord: HighRiskSafetyGateRecord
    ) -> [String] {
        var replayTraceIDs: [String] = []
        if let backgroundReplayTraceID = input.endUserBackground.replayTraceID {
            replayTraceIDs.append(backgroundReplayTraceID)
        }
        if let intakeReplayTraceID = input.intake.replayTraceID {
            replayTraceIDs.append(intakeReplayTraceID)
        }
        replayTraceIDs.append(anyGoalRecord.recoveryReceipt.replayTraceID)
        if let recommendedStepReplayTraceID = recommendedStep.replayTraceID {
            replayTraceIDs.append(recommendedStepReplayTraceID)
        }
        if let latticeReplayTraceID = latticeRecord.selectionReceipt?.replayTraceID {
            replayTraceIDs.append(latticeReplayTraceID)
        }
        replayTraceIDs.append(graphRecord.trace.id)
        replayTraceIDs.append(elasticityRecord.trace.id)
        replayTraceIDs.append(scheduleRecord.trace.id)
        replayTraceIDs.append(consequenceRecord.trace.id)
        replayTraceIDs.append(safetyRecord.trace.id)
        if let completionReplayTraceID = input.completionProof.replayTraceID {
            replayTraceIDs.append(completionReplayTraceID)
        }
        if let shareReplayTraceID = input.optionalShareProof?.replayTraceID {
            replayTraceIDs.append(shareReplayTraceID)
        }
        replayTraceIDs.append(contentsOf: input.replayOutput.replayTraceIDs)
        return normalizedIDs(replayTraceIDs)
    }

    func normalizedIDs(_ values: [String]) -> [String] {
        GoldenSliceEndUserBackground.normalizedIDs(values)
    }

    func sortedIssues(_ issues: Set<GoldenVerticalSliceIssue>) -> [GoldenVerticalSliceIssue] {
        issues.sorted { $0.rawValue < $1.rawValue }
    }

    func stableIdentifier(prefix: String, components: [String]) -> String {
        GoldenSliceEndUserBackground.stableIdentifier(prefix: prefix, components: components)
    }
}

extension String {
    var asArray: [String] {
        isEmpty ? [] : [self]
    }
}

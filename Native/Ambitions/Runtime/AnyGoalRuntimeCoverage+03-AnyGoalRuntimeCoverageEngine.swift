import Foundation

struct AnyGoalRuntimeCoverageEngine: Sendable, Equatable, Hashable {
    let requestBuilder: PrivacySafeCoverageRequestBuilder
    let arrivalDetector: CoverageSourceArrivalDetector

    init(
        requestBuilder: PrivacySafeCoverageRequestBuilder = PrivacySafeCoverageRequestBuilder(),
        arrivalDetector: CoverageSourceArrivalDetector = CoverageSourceArrivalDetector()
    ) {
        self.requestBuilder = requestBuilder
        self.arrivalDetector = arrivalDetector
    }

    func evaluate(_ input: AnyGoalCoverageInput, arrivalSignals: [CoverageSourceArrivalSignal] = []) -> AnyGoalCoverageRecord {
        let baseMode = operatingMode(for: input)
        let baseNeeds = makeCoverageNeeds(input: input, mode: baseMode)
        let arrivalTraces = arrivalDetector.detect(needs: baseNeeds, signals: arrivalSignals)
        let hasArrivedCandidate = arrivalTraces.contains { $0.state == .candidateForRecheck }
        let mode = hasArrivedCandidate && baseMode != .supported && baseMode != .unsafeBlocked && baseMode != .jurisdictionNeeded
            ? AnyGoalOperatingMode.sourceArrived
            : baseMode
        let needs = hasArrivedCandidate
            ? baseNeeds.map { need in
                makeCoverageNeed(input: input, mode: mode, lifecycleState: .coverageArrivedCandidate, privacyClass: need.privacyClass)
            }
            : baseNeeds
        let request = needs.compactMap { requestBuilder.build(from: $0, rawPrivateGoalText: input.rawGoalText) }.first
        let receipt = makeRecoveryReceipt(input: input, mode: mode, needs: needs)
        let handoff = mode == .jurisdictionNeeded ? makeJurisdictionHandoff(input: input) : nil
        let canContinueToStepQualityFirewall = mode == .supported
        return AnyGoalCoverageRecord(
            id: recordID(input: input, mode: mode, needs: needs, traces: arrivalTraces),
            goalReferenceID: input.id,
            family: input.family,
            operatingMode: mode,
            coverageNeeds: needs,
            privacySafeRequest: request,
            sourceArrivalTraces: arrivalTraces,
            recoveryReceipt: receipt,
            jurisdictionHandoff: handoff,
            canContinueToStepQualityFirewall: canContinueToStepQualityFirewall,
            canGenerateVisibleStep: canContinueToStepQualityFirewall
        )
    }

    func evaluate(_ inputs: [AnyGoalCoverageInput]) -> [AnyGoalCoverageRecord] {
        inputs.sorted { $0.id < $1.id }.map { evaluate($0) }
    }

    func operatingMode(for input: AnyGoalCoverageInput) -> AnyGoalOperatingMode {
        if input.localOnly == false || input.safetyState == .unsafe {
            return .unsafeBlocked
        }
        if input.jurisdictionState == .needed {
            return .jurisdictionNeeded
        }
        if input.supportState == .sourceBacked && input.sourceAuthority.canSupportCurrentUse && input.sourceAuthority.authorityIssueCodes.isEmpty {
            return .supported
        }
        if input.supportState == .unsupported {
            return .unsupportedCaptured
        }
        return .awaitingSource
    }

    func makeCoverageNeeds(input: AnyGoalCoverageInput, mode: AnyGoalOperatingMode) -> [CoverageNeed] {
        if mode == .supported {
            return []
        }
        let lifecycle: CoverageNeedLifecycleState
        switch mode {
        case .supported:
            lifecycle = .resolved
        case .unsupportedCaptured:
            lifecycle = .queuedLocal
        case .unsafeBlocked, .jurisdictionNeeded:
            lifecycle = .blocked
        case .awaitingSource:
            lifecycle = .waitingForCoverage
        case .sourceArrived:
            lifecycle = .coverageArrivedCandidate
        }
        return [makeCoverageNeed(input: input, mode: mode, lifecycleState: lifecycle, privacyClass: privacyClass(input: input, mode: mode))]
    }

    func makeCoverageNeed(
        input: AnyGoalCoverageInput,
        mode: AnyGoalOperatingMode,
        lifecycleState: CoverageNeedLifecycleState,
        privacyClass: CoverageNeedPrivacyClass
    ) -> CoverageNeed {
        let sourceTypes = normalizedMissingSourceTypes(input: input, mode: mode)
        let seedGaps = normalizedSeedGapCategories(input: input, mode: mode)
        let riskClass = riskClass(input: input, mode: mode)
        let dedupeKey = dedupeKey(input: input, sourceTypes: sourceTypes, seedGaps: seedGaps, riskClass: riskClass)
        return CoverageNeed(
            id: "coverage-need.\(dedupeKey)",
            goalReferenceID: input.id,
            operatingMode: mode,
            family: input.family,
            domain: input.domain,
            specificDomain: input.specificDomain,
            missingSourceTypes: sourceTypes,
            seedGapCategories: seedGaps,
            riskJurisdictionClass: riskClass,
            freshnessReviewClass: input.sourceAuthority.freshnessReviewClass,
            blockerReason: blockerReason(mode: mode, input: input),
            lifecycleState: lifecycleState,
            privacyClass: privacyClass,
            consentState: consentState(input: input, privacyClass: privacyClass),
            dedupeKey: dedupeKey,
            receiptRef: input.receiptID,
            sourceRecordIDs: input.sourceAuthority.sourceRecordIDs
        )
    }

    func normalizedMissingSourceTypes(input: AnyGoalCoverageInput, mode: AnyGoalOperatingMode) -> [CoverageNeedMissingSourceType] {
        var sourceTypes = Set(input.missingSourceTypes)
        switch mode {
        case .jurisdictionNeeded:
            sourceTypes.insert(.jurisdiction)
        case .unsafeBlocked:
            sourceTypes.insert(.highRiskReview)
        case .awaitingSource, .unsupportedCaptured:
            if sourceTypes.isEmpty {
                sourceTypes.insert(.publicSource)
            }
        case .sourceArrived:
            sourceTypes.insert(.releaseReceipt)
            sourceTypes.insert(.rollbackReceipt)
        case .supported:
            break
        }
        return sourceTypes.sorted { $0.rawValue < $1.rawValue }
    }

    func normalizedSeedGapCategories(input: AnyGoalCoverageInput, mode: AnyGoalOperatingMode) -> [CoverageNeedSeedGapCategory] {
        var seedGaps = Set(input.seedGapCategories)
        switch mode {
        case .jurisdictionNeeded:
            seedGaps.insert(.jurisdiction)
        case .unsafeBlocked:
            seedGaps.insert(.highRiskReview)
        case .awaitingSource, .unsupportedCaptured:
            if seedGaps.isEmpty {
                seedGaps.insert(.goalFamily)
            }
        case .sourceArrived:
            seedGaps.insert(.releaseReceipt)
            seedGaps.insert(.rollback)
        case .supported:
            break
        }
        return seedGaps.sorted { $0.rawValue < $1.rawValue }
    }

    func riskClass(input: AnyGoalCoverageInput, mode: AnyGoalOperatingMode) -> CoverageNeedRiskJurisdictionClass {
        switch mode {
        case .unsafeBlocked:
            return .unsafeBlocked
        case .jurisdictionNeeded:
            return .jurisdictionNeeded
        case .supported, .sourceArrived, .awaitingSource, .unsupportedCaptured:
            switch input.safetyState {
            case .safe:
                return input.family == .sensitivePrivate ? .standard : .low
            case .highRisk:
                return .highRiskReview
            case .unsafe:
                return .unsafeBlocked
            }
        }
    }

    func privacyClass(input: AnyGoalCoverageInput, mode: AnyGoalOperatingMode) -> CoverageNeedPrivacyClass {
        if mode == .unsafeBlocked || input.localOnly == false || input.family == .sensitivePrivate {
            return .blockedSensitive
        }
        if mode == .jurisdictionNeeded || input.safetyState == .highRisk {
            return .highRiskReviewOnly
        }
        return input.consentState == .allowed ? .remoteAbstractAllowed : .localAbstract
    }

    func consentState(input: AnyGoalCoverageInput, privacyClass: CoverageNeedPrivacyClass) -> CoverageConsentState {
        privacyClass == .remoteAbstractAllowed ? input.consentState : .notEligible
    }

    func blockerReason(mode: AnyGoalOperatingMode, input: AnyGoalCoverageInput) -> String {
        switch mode {
        case .supported:
            return "source_authority_current"
        case .unsupportedCaptured:
            return "unsupported_but_captured_without_fake_step"
        case .unsafeBlocked:
            return "unsafe_or_non_local_boundary_blocked"
        case .jurisdictionNeeded:
            return "jurisdiction_needed_before_runtime_pathing"
        case .awaitingSource:
            return input.sourceAuthority.authorityIssueCodes.first ?? "source_needed_before_runtime_pathing"
        case .sourceArrived:
            return "fresh_coverage_arrived_candidate_requires_local_recheck"
        }
    }

    func makeRecoveryReceipt(input: AnyGoalCoverageInput, mode: AnyGoalOperatingMode, needs: [CoverageNeed]) -> AnyGoalRecoveryReceipt {
        let blockedOutputs: [String]
        let allowedLocalActions: [String]
        let boundary: String
        switch mode {
        case .supported:
            blockedOutputs = []
            allowedLocalActions = ["continue_to_step_quality_firewall"]
            boundary = "source-backed local path may continue to Step Quality Firewall"
        case .unsupportedCaptured:
            blockedOutputs = ["visible_step", "schedule_install", "share_projection"]
            allowedLocalActions = ["capture_goal_locally", "explain_unsupported_boundary", "watch_for_coverage"]
            boundary = "unsupported goal captured locally; no fake Step or schedule output"
        case .unsafeBlocked:
            blockedOutputs = ["coverage_request", "visible_step", "schedule_install", "share_projection"]
            allowedLocalActions = ["preserve_block_receipt", "show_safe_recovery_boundary"]
            boundary = "unsafe or non-local route blocked before coverage demand or Step output"
        case .jurisdictionNeeded:
            blockedOutputs = ["coverage_request", "visible_step", "schedule_install", "share_projection"]
            allowedLocalActions = ["open_jurisdiction_handoff", "preserve_local_receipt"]
            boundary = "jurisdiction needed before runtime pathing"
        case .awaitingSource:
            blockedOutputs = ["visible_step", "schedule_install", "share_projection"]
            allowedLocalActions = ["queue_local_coverage_need", "watch_for_source_arrival", "explain_source_needed"]
            boundary = "context needed before pathing; local abstract coverage need only"
        case .sourceArrived:
            blockedOutputs = ["visible_step", "schedule_install", "share_projection"]
            allowedLocalActions = ["run_local_route_recheck", "inspect_arrival_trace"]
            boundary = "fresh coverage candidate arrived; local route recheck required before Step output"
        }
        return AnyGoalRecoveryReceipt(
            id: "any-goal-receipt.\(input.id).\(mode.rawValue)",
            goalReferenceID: input.id,
            mode: mode,
            receiptID: input.receiptID,
            replayTraceID: input.replayTraceID,
            sourceRecordIDs: input.sourceAuthority.sourceRecordIDs,
            coverageNeedIDs: needs.map(\.id).sorted(),
            whatAmbitionsKnowsRoute: input.whatAmbitionsKnowsRoute,
            boundary: boundary,
            allowedLocalActions: allowedLocalActions.sorted(),
            blockedOutputs: blockedOutputs.sorted()
        )
    }

    func makeJurisdictionHandoff(input: AnyGoalCoverageInput) -> AnyGoalJurisdictionHandoff {
        AnyGoalJurisdictionHandoff(
            id: "jurisdiction-handoff.\(input.id)",
            goalReferenceID: input.id,
            family: input.family,
            jurisdictionState: input.jurisdictionState,
            requestedJurisdictionID: input.requestedJurisdictionID,
            handoffRoute: "you://what-ambitions-knows/jurisdiction/\(input.id)",
            blockedOutputs: ["coverage_request", "visible_step", "schedule_install", "share_projection"].sorted()
        )
    }

    func dedupeKey(
        input: AnyGoalCoverageInput,
        sourceTypes: [CoverageNeedMissingSourceType],
        seedGaps: [CoverageNeedSeedGapCategory],
        riskClass: CoverageNeedRiskJurisdictionClass
    ) -> String {
        [
            input.family.rawValue,
            input.domain,
            input.specificDomain ?? "generic",
            sourceTypes.map(\.rawValue).joined(separator: "-"),
            seedGaps.map(\.rawValue).joined(separator: "-"),
            riskClass.rawValue
        ]
        .map(Self.safeComponent)
        .joined(separator: ".")
    }

    func recordID(
        input: AnyGoalCoverageInput,
        mode: AnyGoalOperatingMode,
        needs: [CoverageNeed],
        traces: [CoverageSourceArrivalTrace]
    ) -> String {
        [
            "any-goal",
            input.id,
            mode.rawValue,
            needs.map(\.id).joined(separator: ","),
            traces.map(\.id).joined(separator: ",")
        ]
        .map(Self.safeComponent)
        .joined(separator: ".")
    }

    static func safeComponent(_ value: String) -> String {
        value
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.isEmpty == false }
            .joined(separator: "-")
    }
}

extension PrivacySafeCoverageRequest {
    func containsPrivateMaterial(from rawGoalText: String) -> Bool {
        let rendered = [
            id,
            needID,
            dedupeKey,
            family.rawValue,
            domain,
            missingSourceTypes.map(\.rawValue).joined(separator: " "),
            seedGapCategories.map(\.rawValue).joined(separator: " "),
            riskJurisdictionClass.rawValue,
            redactionBoundary,
            consentState.rawValue,
            sourceRecordIDs.joined(separator: " ")
        ]
        .joined(separator: " ")
        .lowercased()
        let raw = rawGoalText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if raw.isEmpty == false && rendered.contains(raw) {
            return true
        }
        let tokens = raw
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count >= 5 }
        let allowedAbstractTokens = Set([
            "health",
            "legal",
            "civic",
            "finance",
            "moving",
            "creative",
            "family",
            "education",
            "repair",
            "travel",
            "private",
            "release",
            "source",
            "proof"
        ])
        return tokens.contains { token in
            allowedAbstractTokens.contains(token) == false && rendered.contains(token)
        }
    }
}

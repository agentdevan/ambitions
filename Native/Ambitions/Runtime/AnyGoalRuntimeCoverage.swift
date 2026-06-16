import Foundation

enum AnyGoalFamily: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case health
    case legalCivic = "legal_civic"
    case finance
    case moving
    case creative
    case family
    case education
    case repair
    case travel
    case sensitivePrivate = "sensitive_private"
}

enum AnyGoalOperatingMode: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case supported
    case unsupportedCaptured = "unsupported_captured"
    case unsafeBlocked = "unsafe_blocked"
    case jurisdictionNeeded = "jurisdiction_needed"
    case awaitingSource = "awaiting_source"
    case sourceArrived = "source_arrived"
}

enum AnyGoalSupportState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case sourceBacked = "source_backed"
    case sourceNeeded = "source_needed"
    case unsupported
}

enum AnyGoalSafetyState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case safe
    case highRisk = "high_risk"
    case unsafe
}

enum AnyGoalJurisdictionState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case notNeeded = "not_needed"
    case satisfied
    case needed
}

enum CoverageNeedMissingSourceType: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case publicSource = "public_source"
    case pack
    case seed
    case review
    case freshness
    case jurisdiction
    case releaseReceipt = "release_receipt"
    case rollbackReceipt = "rollback_receipt"
    case compatibility
    case highRiskReview = "high_risk_review"
}

enum CoverageNeedSeedGapCategory: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case goalFamily = "goal_family"
    case capability
    case starter
    case proof
    case elasticity
    case recovery
    case jurisdiction
    case replacement
    case highRiskReview = "high_risk_review"
    case sourceFreshness = "source_freshness"
    case sourceReview = "source_review"
    case compatibility
    case rollback
    case releaseReceipt = "release_receipt"
}

enum CoverageNeedRiskJurisdictionClass: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case low
    case standard
    case jurisdictionNeeded = "jurisdiction_needed"
    case highRiskReview = "high_risk_review"
    case unsafeBlocked = "unsafe_blocked"
    case unknownRisk = "unknown_risk"
}

enum CoverageNeedFreshnessReviewClass: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case currentMissing = "current_missing"
    case stale
    case reviewNeeded = "review_needed"
    case sourceChanged = "source_changed"
    case revoked
    case contradicted
    case unreviewed
    case unknown
}

enum CoverageNeedLifecycleState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case localDetected = "local_detected"
    case queuedLocal = "queued_local"
    case waitingForCoverage = "waiting_for_coverage"
    case coverageArrivedCandidate = "coverage_arrived_candidate"
    case routeRecheck = "route_recheck"
    case resolved
    case blocked
}

enum CoverageNeedPrivacyClass: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case localPrivate = "local_private"
    case localAbstract = "local_abstract"
    case remoteAbstractAllowed = "remote_abstract_allowed"
    case blockedSensitive = "blocked_sensitive"
    case highRiskReviewOnly = "high_risk_review_only"
}

enum CoverageConsentState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case notEligible = "not_eligible"
    case notRequested = "not_requested"
    case pending
    case allowed
    case denied
}

enum CoverageSourceArrivalState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case noMatch = "no_match"
    case candidateForRecheck = "candidate_for_recheck"
    case blockedByAuthority = "blocked_by_authority"
}

struct AnyGoalSourceAuthoritySnapshot: Codable, Sendable, Equatable, Hashable {
    let canSupportCurrentUse: Bool
    let sourceRecordIDs: [String]
    let sourceFingerprintIDs: [String]
    let authorityIssueCodes: [String]
    let freshnessReviewClass: CoverageNeedFreshnessReviewClass

    init(
        canSupportCurrentUse: Bool,
        sourceRecordIDs: [String],
        sourceFingerprintIDs: [String],
        authorityIssueCodes: [String] = [],
        freshnessReviewClass: CoverageNeedFreshnessReviewClass = .currentMissing
    ) {
        self.canSupportCurrentUse = canSupportCurrentUse
        self.sourceRecordIDs = Self.orderedUnique(sourceRecordIDs)
        self.sourceFingerprintIDs = Self.orderedUnique(sourceFingerprintIDs)
        self.authorityIssueCodes = Self.orderedUnique(authorityIssueCodes)
        self.freshnessReviewClass = freshnessReviewClass
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct CoverageNeed: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalReferenceID: String
    let operatingMode: AnyGoalOperatingMode
    let family: AnyGoalFamily
    let domain: String
    let specificDomain: String?
    let missingSourceTypes: [CoverageNeedMissingSourceType]
    let seedGapCategories: [CoverageNeedSeedGapCategory]
    let riskJurisdictionClass: CoverageNeedRiskJurisdictionClass
    let freshnessReviewClass: CoverageNeedFreshnessReviewClass
    let blockerReason: String
    let lifecycleState: CoverageNeedLifecycleState
    let privacyClass: CoverageNeedPrivacyClass
    let consentState: CoverageConsentState
    let dedupeKey: String
    let receiptRef: String
    let sourceRecordIDs: [String]

    var canBuildRemoteAbstractRequest: Bool {
        privacyClass == .remoteAbstractAllowed &&
            consentState == .allowed &&
            riskJurisdictionClass != .unsafeBlocked &&
            riskJurisdictionClass != .jurisdictionNeeded &&
            riskJurisdictionClass != .highRiskReview
    }
}

struct PrivacySafeCoverageRequest: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let needID: String
    let dedupeKey: String
    let family: AnyGoalFamily
    let domain: String
    let missingSourceTypes: [CoverageNeedMissingSourceType]
    let seedGapCategories: [CoverageNeedSeedGapCategory]
    let riskJurisdictionClass: CoverageNeedRiskJurisdictionClass
    let redactionBoundary: String
    let consentState: CoverageConsentState
    let sourceRecordIDs: [String]
}

struct CoverageSourceArrivalSignal: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let family: AnyGoalFamily
    let domain: String
    let sourceFingerprintID: String
    let sourceRecordIDs: [String]
    let missingSourceTypes: [CoverageNeedMissingSourceType]
    let seedGapCategories: [CoverageNeedSeedGapCategory]
    let canSupportCurrentUse: Bool
    let authorityIssueCodes: [String]
    let releaseReceiptIDs: [String]
    let rollbackReceiptIDs: [String]
    let observedAt: String

    init(
        id: String,
        family: AnyGoalFamily,
        domain: String,
        sourceFingerprintID: String,
        sourceRecordIDs: [String],
        missingSourceTypes: [CoverageNeedMissingSourceType],
        seedGapCategories: [CoverageNeedSeedGapCategory],
        canSupportCurrentUse: Bool,
        authorityIssueCodes: [String] = [],
        releaseReceiptIDs: [String],
        rollbackReceiptIDs: [String],
        observedAt: String
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.family = family
        self.domain = Self.normalizedDomain(domain)
        self.sourceFingerprintID = sourceFingerprintID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordIDs = AnyGoalSourceAuthoritySnapshot.orderedUnique(sourceRecordIDs)
        self.missingSourceTypes = Self.ordered(missingSourceTypes)
        self.seedGapCategories = Self.ordered(seedGapCategories)
        self.canSupportCurrentUse = canSupportCurrentUse
        self.authorityIssueCodes = AnyGoalSourceAuthoritySnapshot.orderedUnique(authorityIssueCodes)
        self.releaseReceiptIDs = AnyGoalSourceAuthoritySnapshot.orderedUnique(releaseReceiptIDs)
        self.rollbackReceiptIDs = AnyGoalSourceAuthoritySnapshot.orderedUnique(rollbackReceiptIDs)
        self.observedAt = observedAt.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct CoverageSourceArrivalTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let needID: String
    let signalID: String
    let state: CoverageSourceArrivalState
    let sourceFingerprintID: String
    let sourceRecordIDs: [String]
    let authorityIssueCodes: [String]
    let releaseReceiptIDs: [String]
    let rollbackReceiptIDs: [String]
    let requiresLocalRouteRecheck: Bool
}

struct AnyGoalRecoveryReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalReferenceID: String
    let mode: AnyGoalOperatingMode
    let receiptID: String
    let replayTraceID: String
    let sourceRecordIDs: [String]
    let coverageNeedIDs: [String]
    let whatAmbitionsKnowsRoute: String
    let boundary: String
    let allowedLocalActions: [String]
    let blockedOutputs: [String]
}

struct AnyGoalJurisdictionHandoff: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalReferenceID: String
    let family: AnyGoalFamily
    let jurisdictionState: AnyGoalJurisdictionState
    let requestedJurisdictionID: String?
    let handoffRoute: String
    let blockedOutputs: [String]
}

struct AnyGoalCoverageInput: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let rawGoalText: String
    let family: AnyGoalFamily
    let domain: String
    let specificDomain: String?
    let supportState: AnyGoalSupportState
    let safetyState: AnyGoalSafetyState
    let jurisdictionState: AnyGoalJurisdictionState
    let requestedJurisdictionID: String?
    let sourceAuthority: AnyGoalSourceAuthoritySnapshot
    let missingSourceTypes: [CoverageNeedMissingSourceType]
    let seedGapCategories: [CoverageNeedSeedGapCategory]
    let consentState: CoverageConsentState
    let localOnly: Bool
    let receiptID: String
    let replayTraceID: String
    let whatAmbitionsKnowsRoute: String

    init(
        id: String,
        rawGoalText: String,
        family: AnyGoalFamily,
        domain: String,
        specificDomain: String? = nil,
        supportState: AnyGoalSupportState,
        safetyState: AnyGoalSafetyState = .safe,
        jurisdictionState: AnyGoalJurisdictionState = .notNeeded,
        requestedJurisdictionID: String? = nil,
        sourceAuthority: AnyGoalSourceAuthoritySnapshot,
        missingSourceTypes: [CoverageNeedMissingSourceType],
        seedGapCategories: [CoverageNeedSeedGapCategory],
        consentState: CoverageConsentState = .notRequested,
        localOnly: Bool = true,
        receiptID: String,
        replayTraceID: String,
        whatAmbitionsKnowsRoute: String
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.rawGoalText = rawGoalText.trimmingCharacters(in: .whitespacesAndNewlines)
        self.family = family
        self.domain = Self.normalizedDomain(domain)
        self.specificDomain = Self.normalizedOptional(specificDomain)
        self.supportState = supportState
        self.safetyState = safetyState
        self.jurisdictionState = jurisdictionState
        self.requestedJurisdictionID = Self.normalizedOptional(requestedJurisdictionID)
        self.sourceAuthority = sourceAuthority
        self.missingSourceTypes = Self.ordered(missingSourceTypes)
        self.seedGapCategories = Self.ordered(seedGapCategories)
        self.consentState = consentState
        self.localOnly = localOnly
        self.receiptID = receiptID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.replayTraceID = replayTraceID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.whatAmbitionsKnowsRoute = whatAmbitionsKnowsRoute.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct AnyGoalCoverageRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalReferenceID: String
    let family: AnyGoalFamily
    let operatingMode: AnyGoalOperatingMode
    let coverageNeeds: [CoverageNeed]
    let privacySafeRequest: PrivacySafeCoverageRequest?
    let sourceArrivalTraces: [CoverageSourceArrivalTrace]
    let recoveryReceipt: AnyGoalRecoveryReceipt
    let jurisdictionHandoff: AnyGoalJurisdictionHandoff?
    let canContinueToStepQualityFirewall: Bool
    let canGenerateVisibleStep: Bool
}

struct PrivacySafeCoverageRequestBuilder: Sendable, Equatable, Hashable {
    func build(from need: CoverageNeed, rawPrivateGoalText: String? = nil) -> PrivacySafeCoverageRequest? {
        guard need.canBuildRemoteAbstractRequest else {
            return nil
        }
        let request = PrivacySafeCoverageRequest(
            id: "coverage-request.\(need.dedupeKey)",
            needID: need.id,
            dedupeKey: need.dedupeKey,
            family: need.family,
            domain: need.domain,
            missingSourceTypes: need.missingSourceTypes,
            seedGapCategories: need.seedGapCategories,
            riskJurisdictionClass: need.riskJurisdictionClass,
            redactionBoundary: "abstract family/capability/source gap only; no raw private goal text",
            consentState: need.consentState,
            sourceRecordIDs: need.sourceRecordIDs
        )
        guard let rawPrivateGoalText, rawPrivateGoalText.isEmpty == false else {
            return request
        }
        return request.containsPrivateMaterial(from: rawPrivateGoalText) ? nil : request
    }
}

struct CoverageSourceArrivalDetector: Sendable, Equatable, Hashable {
    func detect(needs: [CoverageNeed], signals: [CoverageSourceArrivalSignal]) -> [CoverageSourceArrivalTrace] {
        let sortedNeeds = needs.sorted { $0.id < $1.id }
        let sortedSignals = signals.sorted { $0.id < $1.id }
        return sortedNeeds.flatMap { need in
            sortedSignals.compactMap { signal in
                traceIfMatched(need: need, signal: signal)
            }
        }
        .sorted { $0.id < $1.id }
    }

    private func traceIfMatched(need: CoverageNeed, signal: CoverageSourceArrivalSignal) -> CoverageSourceArrivalTrace? {
        guard need.family == signal.family,
              need.domain == signal.domain,
              signal.sourceFingerprintID.isEmpty == false,
              intersects(need.missingSourceTypes, signal.missingSourceTypes) ||
                intersects(need.seedGapCategories, signal.seedGapCategories) else {
            return nil
        }

        let hasReleaseAndRollback = signal.releaseReceiptIDs.isEmpty == false && signal.rollbackReceiptIDs.isEmpty == false
        let state: CoverageSourceArrivalState = signal.canSupportCurrentUse &&
            signal.authorityIssueCodes.isEmpty &&
            signal.sourceRecordIDs.isEmpty == false &&
            hasReleaseAndRollback
            ? .candidateForRecheck
            : .blockedByAuthority

        return CoverageSourceArrivalTrace(
            id: "coverage-arrival.\(need.id).\(signal.id)",
            needID: need.id,
            signalID: signal.id,
            state: state,
            sourceFingerprintID: signal.sourceFingerprintID,
            sourceRecordIDs: signal.sourceRecordIDs,
            authorityIssueCodes: signal.authorityIssueCodes,
            releaseReceiptIDs: signal.releaseReceiptIDs,
            rollbackReceiptIDs: signal.rollbackReceiptIDs,
            requiresLocalRouteRecheck: state == .candidateForRecheck
        )
    }

    private func intersects<T: Hashable>(_ lhs: [T], _ rhs: [T]) -> Bool {
        Set(lhs).isDisjoint(with: Set(rhs)) == false
    }
}

struct AnyGoalRuntimeCoverageEngine: Sendable, Equatable, Hashable {
    private let requestBuilder: PrivacySafeCoverageRequestBuilder
    private let arrivalDetector: CoverageSourceArrivalDetector

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

    private func operatingMode(for input: AnyGoalCoverageInput) -> AnyGoalOperatingMode {
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

    private func makeCoverageNeeds(input: AnyGoalCoverageInput, mode: AnyGoalOperatingMode) -> [CoverageNeed] {
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

    private func makeCoverageNeed(
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

    private func normalizedMissingSourceTypes(input: AnyGoalCoverageInput, mode: AnyGoalOperatingMode) -> [CoverageNeedMissingSourceType] {
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

    private func normalizedSeedGapCategories(input: AnyGoalCoverageInput, mode: AnyGoalOperatingMode) -> [CoverageNeedSeedGapCategory] {
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

    private func riskClass(input: AnyGoalCoverageInput, mode: AnyGoalOperatingMode) -> CoverageNeedRiskJurisdictionClass {
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

    private func privacyClass(input: AnyGoalCoverageInput, mode: AnyGoalOperatingMode) -> CoverageNeedPrivacyClass {
        if mode == .unsafeBlocked || input.localOnly == false || input.family == .sensitivePrivate {
            return .blockedSensitive
        }
        if mode == .jurisdictionNeeded || input.safetyState == .highRisk {
            return .highRiskReviewOnly
        }
        return input.consentState == .allowed ? .remoteAbstractAllowed : .localAbstract
    }

    private func consentState(input: AnyGoalCoverageInput, privacyClass: CoverageNeedPrivacyClass) -> CoverageConsentState {
        privacyClass == .remoteAbstractAllowed ? input.consentState : .notEligible
    }

    private func blockerReason(mode: AnyGoalOperatingMode, input: AnyGoalCoverageInput) -> String {
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

    private func makeRecoveryReceipt(input: AnyGoalCoverageInput, mode: AnyGoalOperatingMode, needs: [CoverageNeed]) -> AnyGoalRecoveryReceipt {
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

    private func makeJurisdictionHandoff(input: AnyGoalCoverageInput) -> AnyGoalJurisdictionHandoff {
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

    private func dedupeKey(
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

    private func recordID(
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

    private static func safeComponent(_ value: String) -> String {
        value
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.isEmpty == false }
            .joined(separator: "-")
    }
}

private extension PrivacySafeCoverageRequest {
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

private extension AnyGoalCoverageInput {
    static func normalizedDomain(_ value: String) -> String {
        let normalized = value
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.isEmpty == false }
            .joined(separator: "_")
        return normalized.isEmpty ? "general" : normalized
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let value else {
            return nil
        }
        let normalized = normalizedDomain(value)
        return normalized == "general" ? nil : normalized
    }

    static func ordered(_ values: [CoverageNeedMissingSourceType]) -> [CoverageNeedMissingSourceType] {
        Array(Set(values)).sorted { $0.rawValue < $1.rawValue }
    }

    static func ordered(_ values: [CoverageNeedSeedGapCategory]) -> [CoverageNeedSeedGapCategory] {
        Array(Set(values)).sorted { $0.rawValue < $1.rawValue }
    }
}

private extension CoverageSourceArrivalSignal {
    static func normalizedDomain(_ value: String) -> String {
        AnyGoalCoverageInput.normalizedDomain(value)
    }

    static func ordered(_ values: [CoverageNeedMissingSourceType]) -> [CoverageNeedMissingSourceType] {
        AnyGoalCoverageInput.ordered(values)
    }

    static func ordered(_ values: [CoverageNeedSeedGapCategory]) -> [CoverageNeedSeedGapCategory] {
        AnyGoalCoverageInput.ordered(values)
    }
}

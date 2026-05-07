import Foundation

let ambitionsOSPerformanceEnergySchemaVersion = "ambitionsos_performance_energy.native.v1"

enum AmbitionsOSPerformanceWorkloadKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case projection
    case recommendation
    case sourceTraversal = "source_traversal"
    case proofTraversal = "proof_traversal"
    case localLanguagePlanning = "local_language_planning"
    case externalProjection = "external_projection"
    case backgroundMaintenance = "background_maintenance"
}

enum AmbitionsOSPerformanceSchedulerMode: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case immediate
    case userInitiated = "user_initiated"
    case deferred
    case idleOnly = "idle_only"
    case lowPowerFallback = "low_power_fallback"
    case blocked
}

enum AmbitionsOSEnergyDeviceState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case normal
    case lowPowerMode = "low_power_mode"
    case thermalPressure = "thermal_pressure"
    case oldDeviceFallback = "old_device_fallback"
    case offline
}

enum AmbitionsOSPerformanceEvidenceLevel: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case contractOnly = "contract_only"
    case simulatorMeasured = "simulator_measured"
    case deviceMeasured = "device_measured"
    case instrumentsMeasured = "instruments_measured"
}

enum AmbitionsOSPerformanceEnergyIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedBudget = "malformed_budget"
    case unboundedRuntime = "unbounded_runtime"
    case backgroundWorkNotDeferred = "background_work_not_deferred"
    case lowPowerFallbackMissing = "low_power_fallback_missing"
    case thermalFallbackMissing = "thermal_fallback_missing"
    case sourceTraversalBudgetMissing = "source_traversal_budget_missing"
    case localLanguageBudgetMissing = "local_language_budget_missing"
    case measurementPlanMissing = "measurement_plan_missing"
    case releaseClaimWithoutEvidence = "release_claim_without_evidence"
    case externalSensitiveProjectionRisk = "external_sensitive_projection_risk"
    case hiddenMutationRisk = "hidden_mutation_risk"
    case runtimeStoreBehavior = "runtime_store_behavior"
}

struct AmbitionsOSPerformanceBudgetEnvelope: Codable, Sendable, Equatable, Hashable {
    let maxInteractiveLatencyMilliseconds: Int
    let maxBackgroundDurationSeconds: Int
    let maxMemoryMegabytes: Int
    let maxTraversalItems: Int
    let maxWakeupsPerHour: Int
    let permitsBackgroundExecution: Bool

    init(
        maxInteractiveLatencyMilliseconds: Int,
        maxBackgroundDurationSeconds: Int,
        maxMemoryMegabytes: Int,
        maxTraversalItems: Int,
        maxWakeupsPerHour: Int,
        permitsBackgroundExecution: Bool = false
    ) {
        self.maxInteractiveLatencyMilliseconds = maxInteractiveLatencyMilliseconds
        self.maxBackgroundDurationSeconds = maxBackgroundDurationSeconds
        self.maxMemoryMegabytes = maxMemoryMegabytes
        self.maxTraversalItems = maxTraversalItems
        self.maxWakeupsPerHour = maxWakeupsPerHour
        self.permitsBackgroundExecution = permitsBackgroundExecution
    }

    var isBounded: Bool {
        maxInteractiveLatencyMilliseconds > 0 &&
            maxBackgroundDurationSeconds >= 0 &&
            maxMemoryMegabytes > 0 &&
            maxTraversalItems > 0 &&
            maxWakeupsPerHour >= 0
    }
}

struct AmbitionsOSPerformanceMeasurementPlan: Codable, Sendable, Equatable, Hashable {
    let evidenceLevel: AmbitionsOSPerformanceEvidenceLevel
    let metricIDs: [String]
    let fixtureGroups: [String]
    let requiresInstrumentsBeforeReleaseClaim: Bool
    let claimLanguage: String

    init(
        evidenceLevel: AmbitionsOSPerformanceEvidenceLevel = .contractOnly,
        metricIDs: [String],
        fixtureGroups: [String],
        requiresInstrumentsBeforeReleaseClaim: Bool = true,
        claimLanguage: String = "Contract budget only; measured device behavior is not claimed."
    ) {
        self.evidenceLevel = evidenceLevel
        self.metricIDs = Self.orderedUnique(metricIDs)
        self.fixtureGroups = Self.orderedUnique(fixtureGroups)
        self.requiresInstrumentsBeforeReleaseClaim = requiresInstrumentsBeforeReleaseClaim
        self.claimLanguage = claimLanguage.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isWellFormed: Bool {
        metricIDs.isEmpty == false &&
            fixtureGroups.isEmpty == false &&
            claimLanguage.isEmpty == false
    }

    var canSupportReleaseClaim: Bool {
        requiresInstrumentsBeforeReleaseClaim == false ||
            evidenceLevel == .deviceMeasured ||
            evidenceLevel == .instrumentsMeasured
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSPerformanceSchedulerContract: Codable, Sendable, Equatable, Hashable {
    let mode: AmbitionsOSPerformanceSchedulerMode
    let allowedDeviceStates: [AmbitionsOSEnergyDeviceState]
    let fallbackDeviceStates: [AmbitionsOSEnergyDeviceState]
    let requiresVisibleUserInitiation: Bool
    let allowsSilentMutation: Bool

    init(
        mode: AmbitionsOSPerformanceSchedulerMode,
        allowedDeviceStates: [AmbitionsOSEnergyDeviceState] = [.normal],
        fallbackDeviceStates: [AmbitionsOSEnergyDeviceState] = [.lowPowerMode, .thermalPressure, .oldDeviceFallback],
        requiresVisibleUserInitiation: Bool = true,
        allowsSilentMutation: Bool = false
    ) {
        self.mode = mode
        self.allowedDeviceStates = Self.orderedUnique(allowedDeviceStates)
        self.fallbackDeviceStates = Self.orderedUnique(fallbackDeviceStates)
        self.requiresVisibleUserInitiation = requiresVisibleUserInitiation
        self.allowsSilentMutation = allowsSilentMutation
    }

    var supportsLowPowerFallback: Bool {
        fallbackDeviceStates.contains(.lowPowerMode) || allowedDeviceStates.contains(.lowPowerMode)
    }

    var supportsThermalFallback: Bool {
        fallbackDeviceStates.contains(.thermalPressure) || allowedDeviceStates.contains(.thermalPressure)
    }

    private static func orderedUnique(_ values: [AmbitionsOSEnergyDeviceState]) -> [AmbitionsOSEnergyDeviceState] {
        Array(Set(values)).sorted { $0.rawValue < $1.rawValue }
    }
}

struct AmbitionsOSPerformanceEnergyBudget: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let workloadKind: AmbitionsOSPerformanceWorkloadKind
    let surface: AmbitionsOSControlPlaneSurface
    let envelope: AmbitionsOSPerformanceBudgetEnvelope
    let scheduler: AmbitionsOSPerformanceSchedulerContract
    let measurementPlan: AmbitionsOSPerformanceMeasurementPlan
    let sourceTraversalBudgetAttached: Bool
    let localLanguageBudgetAttached: Bool
    let projectsExternally: Bool
    let changesAppState: Bool
    let privacyClass: HumanProgressPrivacyClass
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let schemaVersion: String

    init(
        id: String,
        workloadKind: AmbitionsOSPerformanceWorkloadKind,
        surface: AmbitionsOSControlPlaneSurface,
        envelope: AmbitionsOSPerformanceBudgetEnvelope,
        scheduler: AmbitionsOSPerformanceSchedulerContract,
        measurementPlan: AmbitionsOSPerformanceMeasurementPlan,
        sourceTraversalBudgetAttached: Bool = false,
        localLanguageBudgetAttached: Bool = false,
        projectsExternally: Bool = false,
        changesAppState: Bool = false,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSPerformanceEnergySchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.workloadKind = workloadKind
        self.surface = surface
        self.envelope = envelope
        self.scheduler = scheduler
        self.measurementPlan = measurementPlan
        self.sourceTraversalBudgetAttached = sourceTraversalBudgetAttached
        self.localLanguageBudgetAttached = localLanguageBudgetAttached
        self.projectsExternally = projectsExternally
        self.changesAppState = changesAppState
        self.privacyClass = privacyClass
        self.runtimeBoundary = runtimeBoundary
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            schemaVersion == ambitionsOSPerformanceEnergySchemaVersion &&
            envelope.isBounded &&
            measurementPlan.isWellFormed
    }

    var requiresSourceTraversalBudget: Bool {
        workloadKind == .sourceTraversal || workloadKind == .proofTraversal
    }

    var requiresLocalLanguageBudget: Bool {
        workloadKind == .localLanguagePlanning
    }

    var isExternalProjectionSafe: Bool {
        privacyClass == .externalRedacted || privacyClass == .shareableByUser
    }
}

struct AmbitionsOSPerformanceEnergyValidator: Sendable, Equatable, Hashable {
    func validate(_ budget: AmbitionsOSPerformanceEnergyBudget) -> [AmbitionsOSPerformanceEnergyIssue] {
        var issues: Set<AmbitionsOSPerformanceEnergyIssue> = []

        validateShape(budget, issues: &issues)
        validateScheduler(budget, issues: &issues)
        validateInheritedBudgets(budget, issues: &issues)
        validateMeasurementAndClaims(budget, issues: &issues)
        validateRuntimeAndPrivacy(budget, issues: &issues)

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    private func validateShape(
        _ budget: AmbitionsOSPerformanceEnergyBudget,
        issues: inout Set<AmbitionsOSPerformanceEnergyIssue>
    ) {
        if budget.schemaVersion != ambitionsOSPerformanceEnergySchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if budget.isWellFormed == false {
            issues.insert(.malformedBudget)
        }
        if budget.envelope.isBounded == false {
            issues.insert(.unboundedRuntime)
        }
    }

    private func validateScheduler(
        _ budget: AmbitionsOSPerformanceEnergyBudget,
        issues: inout Set<AmbitionsOSPerformanceEnergyIssue>
    ) {
        if budget.workloadKind == .backgroundMaintenance &&
            budget.scheduler.mode != .deferred &&
            budget.scheduler.mode != .idleOnly &&
            budget.scheduler.mode != .lowPowerFallback &&
            budget.scheduler.mode != .blocked {
            issues.insert(.backgroundWorkNotDeferred)
        }
        if budget.scheduler.supportsLowPowerFallback == false {
            issues.insert(.lowPowerFallbackMissing)
        }
        if budget.scheduler.supportsThermalFallback == false {
            issues.insert(.thermalFallbackMissing)
        }
        if budget.scheduler.allowsSilentMutation {
            issues.insert(.hiddenMutationRisk)
        }
    }

    private func validateInheritedBudgets(
        _ budget: AmbitionsOSPerformanceEnergyBudget,
        issues: inout Set<AmbitionsOSPerformanceEnergyIssue>
    ) {
        if budget.requiresSourceTraversalBudget && budget.sourceTraversalBudgetAttached == false {
            issues.insert(.sourceTraversalBudgetMissing)
        }
        if budget.requiresLocalLanguageBudget && budget.localLanguageBudgetAttached == false {
            issues.insert(.localLanguageBudgetMissing)
        }
    }

    private func validateMeasurementAndClaims(
        _ budget: AmbitionsOSPerformanceEnergyBudget,
        issues: inout Set<AmbitionsOSPerformanceEnergyIssue>
    ) {
        if budget.measurementPlan.isWellFormed == false {
            issues.insert(.measurementPlanMissing)
        }
        if budget.measurementPlan.canSupportReleaseClaim == false {
            issues.insert(.releaseClaimWithoutEvidence)
        }
    }

    private func validateRuntimeAndPrivacy(
        _ budget: AmbitionsOSPerformanceEnergyBudget,
        issues: inout Set<AmbitionsOSPerformanceEnergyIssue>
    ) {
        if budget.projectsExternally && budget.isExternalProjectionSafe == false {
            issues.insert(.externalSensitiveProjectionRisk)
        }
        if budget.changesAppState || budget.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeStoreBehavior)
        }
    }
}

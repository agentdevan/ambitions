import Foundation

let ambitionsOSExperienceSchemaVersion = "ambitionsos_experience.native.v1"

enum AmbitionsOSExperiencePrimaryObject: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case startHere = "start_here"
    case realityRail = "reality_rail"
    case captureComposer = "capture_composer"
    case missionControl = "mission_control"
    case planReview = "plan_review"
    case personalSystemCenter = "personal_system_center"
    case proofReview = "proof_review"
    case none
}

enum AmbitionsOSExperienceWayfindingState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case oriented
    case needsLabel = "needs_label"
    case ambiguous
    case overloaded
}

enum AmbitionsOSExperienceDensityState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case calm
    case focused
    case reviewDense = "review_dense"
    case overloaded
    case dashboardDrift = "dashboard_drift"
}

enum AmbitionsOSExperienceIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedContract = "malformed_contract"
    case nonCanonicalSurface = "non_canonical_surface"
    case missingPrimaryObject = "missing_primary_object"
    case tooManyPrimaryDecisions = "too_many_primary_decisions"
    case tooManyVisibleSections = "too_many_visible_sections"
    case ambiguousWayfinding = "ambiguous_wayfinding"
    case todayFullPathDepth = "today_full_path_depth"
    case genericDashboardDrift = "generic_dashboard_drift"
    case forbiddenLanguage = "forbidden_language"
    case accessibilityReviewMissing = "accessibility_review_missing"
    case privacySafeLabelMissing = "privacy_safe_label_missing"
    case recoveryLanguageMissing = "recovery_language_missing"
    case hiddenMutationRisk = "hidden_mutation_risk"
    case runtimeStoreBehavior = "runtime_store_behavior"
}

enum AmbitionsOSExperienceCapacityState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case spacious
    case balanced
    case tight
    case depleted
}

enum AmbitionsOSExperienceProtectedPressure: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case clear
    case reserved
    case conflict
}

enum AmbitionsOSExperienceClosureResidue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case light
    case recovery
}

enum AmbitionsOSExperienceSourceFreshness: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case current
    case aging
    case stale
    case disputed
}

enum AmbitionsOSExperienceProofStrength: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case absent
    case supporting
    case strong
    case decisive
}

enum AmbitionsOSExperienceGoalPull: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case neutral
    case present
    case urgent
}

enum AmbitionsOSExperienceRecoveryNeed: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case gentle
    case required
}

enum AmbitionsOSExperiencePrivacyMode: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case standard
    case localOnly = "local_only"
    case sensitive
}

enum AmbitionsOSExperienceLivingVisualState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case calm
    case active
    case pressured
    case proof
    case recovery
    case sensitive
    case stale
    case empty

    var title: String {
        switch self {
        case .calm: "Calm"
        case .active: "Active"
        case .pressured: "Pressure visible"
        case .proof: "Proof visible"
        case .recovery: "Recovery"
        case .sensitive: "Sensitive"
        case .stale: "Needs review"
        case .empty: "Ready"
        }
    }
}

struct AmbitionsOSExperienceSemanticVisualInput: Codable, Sendable, Equatable, Hashable {
    let surface: AmbitionsOSControlPlaneSurface
    let capacity: AmbitionsOSExperienceCapacityState
    let protectedPressure: AmbitionsOSExperienceProtectedPressure
    let closureResidue: AmbitionsOSExperienceClosureResidue
    let sourceFreshness: AmbitionsOSExperienceSourceFreshness
    let proofStrength: AmbitionsOSExperienceProofStrength
    let goalPull: AmbitionsOSExperienceGoalPull
    let recoveryNeed: AmbitionsOSExperienceRecoveryNeed
    let privacyMode: AmbitionsOSExperiencePrivacyMode

    init(
        surface: AmbitionsOSControlPlaneSurface = .today,
        capacity: AmbitionsOSExperienceCapacityState = .balanced,
        protectedPressure: AmbitionsOSExperienceProtectedPressure = .clear,
        closureResidue: AmbitionsOSExperienceClosureResidue = .none,
        sourceFreshness: AmbitionsOSExperienceSourceFreshness = .current,
        proofStrength: AmbitionsOSExperienceProofStrength = .supporting,
        goalPull: AmbitionsOSExperienceGoalPull = .present,
        recoveryNeed: AmbitionsOSExperienceRecoveryNeed = .none,
        privacyMode: AmbitionsOSExperiencePrivacyMode = .standard
    ) {
        self.surface = surface
        self.capacity = capacity
        self.protectedPressure = protectedPressure
        self.closureResidue = closureResidue
        self.sourceFreshness = sourceFreshness
        self.proofStrength = proofStrength
        self.goalPull = goalPull
        self.recoveryNeed = recoveryNeed
        self.privacyMode = privacyMode
    }
}

struct AmbitionsOSExperienceDecorativeVariation: Sendable, Equatable, Hashable {
    let particlePhase: Int
    let grainSeed: Int
    let shimmerOffset: Double

    init(particlePhase: Int = 0, grainSeed: Int = 0, shimmerOffset: Double = 0) {
        self.particlePhase = particlePhase
        self.grainSeed = grainSeed
        self.shimmerOffset = shimmerOffset
    }
}

struct AmbitionsOSExperienceCompiledVisualState: Codable, Sendable, Equatable, Hashable {
    let livingState: AmbitionsOSExperienceLivingVisualState
    let intensity: Double
    let semanticCauseIDs: [String]
    let accessibilityLabel: String
    let snapshotKey: String
    let criticalSignature: String

    init(
        livingState: AmbitionsOSExperienceLivingVisualState,
        intensity: Double,
        semanticCauseIDs: [String],
        accessibilityLabel: String
    ) {
        self.livingState = livingState
        self.intensity = max(0, min(intensity, 1))
        self.semanticCauseIDs = semanticCauseIDs.sorted()
        self.accessibilityLabel = accessibilityLabel
        self.snapshotKey = ([livingState.rawValue, String(format: "%.2f", self.intensity)] + self.semanticCauseIDs)
            .joined(separator: "|")
        self.criticalSignature = ([livingState.rawValue] + self.semanticCauseIDs)
            .joined(separator: "|")
    }
}

struct AmbitionsOSExperienceCompiler: Sendable, Equatable, Hashable {
    func compile(
        _ input: AmbitionsOSExperienceSemanticVisualInput,
        decorativeVariation: AmbitionsOSExperienceDecorativeVariation? = nil
    ) -> AmbitionsOSExperienceCompiledVisualState {
        let causes = semanticCauseIDs(for: input)
        let state = livingState(for: input)
        return AmbitionsOSExperienceCompiledVisualState(
            livingState: state,
            intensity: intensity(for: input),
            semanticCauseIDs: causes,
            accessibilityLabel: accessibilityLabel(for: state, causes: causes)
        )
    }

    private func livingState(for input: AmbitionsOSExperienceSemanticVisualInput) -> AmbitionsOSExperienceLivingVisualState {
        if input.privacyMode == .sensitive || input.privacyMode == .localOnly {
            return .sensitive
        }
        if input.sourceFreshness == .stale || input.sourceFreshness == .disputed {
            return .stale
        }
        if input.recoveryNeed == .required || input.closureResidue == .recovery {
            return .recovery
        }
        if input.protectedPressure == .conflict || input.capacity == .depleted || input.capacity == .tight {
            return .pressured
        }
        if input.proofStrength == .strong || input.proofStrength == .decisive {
            return .proof
        }
        if input.goalPull == .present || input.goalPull == .urgent || input.protectedPressure == .reserved {
            return .active
        }
        return .calm
    }

    private func intensity(for input: AmbitionsOSExperienceSemanticVisualInput) -> Double {
        min(1, 0.20 +
            capacityWeight(input.capacity) +
            protectedPressureWeight(input.protectedPressure) +
            closureWeight(input.closureResidue) +
            freshnessWeight(input.sourceFreshness) +
            proofWeight(input.proofStrength) +
            goalPullWeight(input.goalPull) +
            recoveryWeight(input.recoveryNeed) +
            privacyWeight(input.privacyMode))
    }

    private func semanticCauseIDs(for input: AmbitionsOSExperienceSemanticVisualInput) -> [String] {
        [
            "surface.\(input.surface.rawValue)",
            "capacity.\(input.capacity.rawValue)",
            "protected_pressure.\(input.protectedPressure.rawValue)",
            "closure_residue.\(input.closureResidue.rawValue)",
            "source_freshness.\(input.sourceFreshness.rawValue)",
            "proof_strength.\(input.proofStrength.rawValue)",
            "goal_pull.\(input.goalPull.rawValue)",
            "recovery_need.\(input.recoveryNeed.rawValue)",
            "privacy_mode.\(input.privacyMode.rawValue)"
        ]
    }

    private func accessibilityLabel(for state: AmbitionsOSExperienceLivingVisualState, causes: [String]) -> String {
        let readableCauses = causes
            .map { $0.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: ".", with: " ") }
            .joined(separator: ", ")
        return "\(state.title). Caused by \(readableCauses)."
    }

    private func capacityWeight(_ state: AmbitionsOSExperienceCapacityState) -> Double {
        switch state {
        case .spacious: 0.00
        case .balanced: 0.04
        case .tight: 0.16
        case .depleted: 0.24
        }
    }

    private func protectedPressureWeight(_ pressure: AmbitionsOSExperienceProtectedPressure) -> Double {
        switch pressure {
        case .clear: 0.00
        case .reserved: 0.08
        case .conflict: 0.18
        }
    }

    private func closureWeight(_ residue: AmbitionsOSExperienceClosureResidue) -> Double {
        switch residue {
        case .none: 0.00
        case .light: 0.06
        case .recovery: 0.16
        }
    }

    private func freshnessWeight(_ freshness: AmbitionsOSExperienceSourceFreshness) -> Double {
        switch freshness {
        case .current: 0.00
        case .aging: 0.06
        case .stale: 0.18
        case .disputed: 0.22
        }
    }

    private func proofWeight(_ strength: AmbitionsOSExperienceProofStrength) -> Double {
        switch strength {
        case .absent: 0.00
        case .supporting: 0.04
        case .strong: 0.10
        case .decisive: 0.14
        }
    }

    private func goalPullWeight(_ pull: AmbitionsOSExperienceGoalPull) -> Double {
        switch pull {
        case .neutral: 0.00
        case .present: 0.06
        case .urgent: 0.16
        }
    }

    private func recoveryWeight(_ need: AmbitionsOSExperienceRecoveryNeed) -> Double {
        switch need {
        case .none: 0.00
        case .gentle: 0.08
        case .required: 0.18
        }
    }

    private func privacyWeight(_ mode: AmbitionsOSExperiencePrivacyMode) -> Double {
        switch mode {
        case .standard: 0.00
        case .localOnly: 0.10
        case .sensitive: 0.18
        }
    }
}

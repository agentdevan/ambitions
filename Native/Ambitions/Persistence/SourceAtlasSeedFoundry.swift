import Foundation

// Guard note: this Persistence boundary composes existing SourceRecord, Receipt, and ReplayTrace owners without introducing them.

enum SourceAtlasSeedReuseScope: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case domain
    case specificDomain = "specific_domain"
    case role
    case path
    case goalTemplate = "goal_template"
    case oneGoalOnly = "one_goal_only"

    var supportsReuse: Bool {
        self != .oneGoalOnly
    }
}

enum SourceAtlasSeedReleaseState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case accepted
    case rejected
    case superseded
}

struct SourceAtlasSeedReleaseRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let packID: String
    let seedID: String
    let packVersion: String
    let manifestVersionID: String
    let releaseState: SourceAtlasSeedReleaseState
    let accepted: Bool
    let releasedAt: Date
    let expiresAt: Date
    let checksum: String
    let sourceRecordIDs: [String]
    let claimIDs: [String]

    init(
        id: String,
        packID: String,
        seedID: String,
        packVersion: String,
        manifestVersionID: String,
        releaseState: SourceAtlasSeedReleaseState = .accepted,
        accepted: Bool = true,
        releasedAt: Date,
        expiresAt: Date,
        checksum: String,
        sourceRecordIDs: [String],
        claimIDs: [String]
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.packID = packID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.seedID = seedID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.packVersion = packVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        self.manifestVersionID = manifestVersionID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.releaseState = releaseState
        self.accepted = accepted
        self.releasedAt = releasedAt
        self.expiresAt = expiresAt
        self.checksum = checksum.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self.sourceRecordIDs = Self.orderedUnique(sourceRecordIDs)
        self.claimIDs = Self.orderedUnique(claimIDs)
    }

    var isAccepted: Bool {
        accepted && releaseState == .accepted
    }

    func isInsideFreshnessWindow(at checkedAt: Date, maximumWindowDays: Int) -> Bool {
        guard releasedAt <= checkedAt, checkedAt <= expiresAt else {
            return false
        }
        return ageInDays(at: checkedAt) <= max(maximumWindowDays, 0)
    }

    func ageInDays(at checkedAt: Date) -> Int {
        max(0, Int(floor(checkedAt.timeIntervalSince(releasedAt) / Self.day)))
    }

    func daysUntilExpiry(at checkedAt: Date) -> Int {
        max(0, Int(ceil(expiresAt.timeIntervalSince(checkedAt) / Self.day)))
    }

    private static let day: TimeInterval = 24 * 60 * 60

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()
    }
}

struct SourceAtlasReusableSeedDescriptor: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let packID: String
    let sourceSeedID: String
    let title: String
    let reuseScope: SourceAtlasSeedReuseScope
    let sourceRecordIDs: [String]
    let claimIDs: [String]
    let requirementIDs: [String]
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasRequirementFreshnessState
    let riskState: SourceAtlasRequirementRiskState
    let reviewState: SourceAtlasRequirementReviewState
    let riskClass: SourceAtlasRiskClass
    let storesFinalSchedule: Bool
    let releaseRecord: SourceAtlasSeedReleaseRecord?

    init(
        id: String,
        packID: String,
        sourceSeedID: String,
        title: String,
        reuseScope: SourceAtlasSeedReuseScope,
        sourceRecordIDs: [String],
        claimIDs: [String],
        requirementIDs: [String],
        sourceState: SourceAtlasRequirementSourceState = .officialCurrent,
        freshnessState: SourceAtlasRequirementFreshnessState = .current,
        riskState: SourceAtlasRequirementRiskState = .low,
        reviewState: SourceAtlasRequirementReviewState = .approved,
        riskClass: SourceAtlasRiskClass = .sportRules,
        storesFinalSchedule: Bool = false,
        releaseRecord: SourceAtlasSeedReleaseRecord?
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.packID = packID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceSeedID = sourceSeedID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.reuseScope = reuseScope
        self.sourceRecordIDs = Self.orderedUnique(sourceRecordIDs)
        self.claimIDs = Self.orderedUnique(claimIDs)
        self.requirementIDs = Self.orderedUnique(requirementIDs)
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.riskState = riskState
        self.reviewState = reviewState
        self.riskClass = riskClass
        self.storesFinalSchedule = storesFinalSchedule
        self.releaseRecord = releaseRecord
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()
    }
}

struct SourceAtlasSeedReusePolicy: Codable, Sendable, Equatable, Hashable {
    let maximumFreshnessWindowDays: Int
    let requireReleaseRecord: Bool
    let allowedReuseScopes: [SourceAtlasSeedReuseScope]
    let allowedRiskClasses: [SourceAtlasRiskClass]

    init(
        maximumFreshnessWindowDays: Int = 180,
        requireReleaseRecord: Bool = true,
        allowedReuseScopes: [SourceAtlasSeedReuseScope] = [.domain, .specificDomain, .role, .path, .goalTemplate],
        allowedRiskClasses: [SourceAtlasRiskClass] = [.lowRiskSkill, .hobby, .sportRules, .careerContext]
    ) {
        self.maximumFreshnessWindowDays = maximumFreshnessWindowDays
        self.requireReleaseRecord = requireReleaseRecord
        self.allowedReuseScopes = Self.orderedUnique(allowedReuseScopes)
        self.allowedRiskClasses = Self.orderedUnique(allowedRiskClasses)
    }

    func allows(_ scope: SourceAtlasSeedReuseScope) -> Bool {
        scope.supportsReuse && allowedReuseScopes.contains(scope)
    }

    func allows(_ riskClass: SourceAtlasRiskClass) -> Bool {
        allowedRiskClasses.contains(riskClass) && riskClass.requiresStrictReview == false
    }

    private static func orderedUnique<T: RawRepresentable & Hashable>(_ values: [T]) -> [T] where T.RawValue == String {
        Array(Set(values)).sorted { $0.rawValue < $1.rawValue }
    }
}

enum SourceAtlasSeedPackState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case current
    case stale
    case contradicted
    case revoked
    case invalidPack = "invalid_pack"
    case releaseBlocked = "release_blocked"
    case seedBlocked = "seed_blocked"
}

enum SourceAtlasSeedFoundryIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case missingSeedID = "missing_seed_id"
    case missingPackID = "missing_pack_id"
    case packMismatch = "pack_mismatch"
    case packInvalid = "pack_invalid"
    case seedMissingFromPack = "seed_missing_from_pack"
    case sourceBindingMissing = "source_binding_missing"
    case sourceBindingUnresolved = "source_binding_unresolved"
    case claimBindingMissing = "claim_binding_missing"
    case claimBindingUnresolved = "claim_binding_unresolved"
    case requirementBindingMissing = "requirement_binding_missing"
    case requirementBindingUnresolved = "requirement_binding_unresolved"
    case claimContradicted = "claim_contradicted"
    case claimRevoked = "claim_revoked"
    case claimCannotSupportCurrentUse = "claim_cannot_support_current_use"
    case requirementCannotSupportCurrentUse = "requirement_cannot_support_current_use"
    case releaseRecordMissing = "release_record_missing"
    case releaseRecordRejected = "release_record_rejected"
    case releaseRecordMismatch = "release_record_mismatch"
    case releaseRecordMissingBindings = "release_record_missing_bindings"
    case freshnessWindowExpired = "freshness_window_expired"
    case reuseScopeNotReusable = "reuse_scope_not_reusable"
    case reviewNotApproved = "review_not_approved"
    case riskNotAllowed = "risk_not_allowed"
    case storesFinalSchedule = "stores_final_schedule"
}

struct SourceAtlasSeedFoundryMatrixRow: Codable, Sendable, Equatable, Hashable {
    let packID: String
    let seedID: String
    let packState: SourceAtlasSeedPackState
    let reuseScope: SourceAtlasSeedReuseScope
    let releaseRecordID: String?
    let freshnessWindowDays: Int
    let daysUntilReleaseRecordExpiry: Int?
    let issueCodes: [String]
    let canSupportCurrentUse: Bool
}

struct SourceAtlasSeedEligibilityRecord: Codable, Sendable, Equatable, Hashable {
    let descriptor: SourceAtlasReusableSeedDescriptor
    let packState: SourceAtlasSeedPackState
    let issues: [SourceAtlasSeedFoundryIssue]
    let matrixRow: SourceAtlasSeedFoundryMatrixRow

    var canSupportCurrentUse: Bool {
        issues.isEmpty && packState == .current
    }
}

struct SourceAtlasSeedFoundry: Sendable, Equatable, Hashable {
    private let packValidator: SourceAtlasPackValidator

    init(packValidator: SourceAtlasPackValidator = SourceAtlasPackValidator()) {
        self.packValidator = packValidator
    }

    func evaluate(
        descriptor: SourceAtlasReusableSeedDescriptor,
        pack: SourceAtlasPack,
        checkedAt: Date,
        policy: SourceAtlasSeedReusePolicy = SourceAtlasSeedReusePolicy()
    ) -> SourceAtlasSeedEligibilityRecord {
        let issues = orderedIssues(
            issues(
                descriptor: descriptor,
                pack: pack,
                checkedAt: checkedAt,
                policy: policy
            )
        )
        let packState = state(for: issues)
        let matrixRow = SourceAtlasSeedFoundryMatrixRow(
            packID: descriptor.packID,
            seedID: descriptor.id,
            packState: packState,
            reuseScope: descriptor.reuseScope,
            releaseRecordID: descriptor.releaseRecord?.id,
            freshnessWindowDays: policy.maximumFreshnessWindowDays,
            daysUntilReleaseRecordExpiry: descriptor.releaseRecord?.daysUntilExpiry(at: checkedAt),
            issueCodes: issues.map(\.rawValue),
            canSupportCurrentUse: issues.isEmpty && packState == .current
        )
        return SourceAtlasSeedEligibilityRecord(
            descriptor: descriptor,
            packState: packState,
            issues: issues,
            matrixRow: matrixRow
        )
    }

    func matrix(
        descriptors: [SourceAtlasReusableSeedDescriptor],
        pack: SourceAtlasPack,
        checkedAt: Date,
        policy: SourceAtlasSeedReusePolicy = SourceAtlasSeedReusePolicy()
    ) -> [SourceAtlasSeedFoundryMatrixRow] {
        descriptors
            .map { evaluate(descriptor: $0, pack: pack, checkedAt: checkedAt, policy: policy).matrixRow }
            .sorted {
                if $0.packID != $1.packID {
                    return $0.packID < $1.packID
                }
                return $0.seedID < $1.seedID
            }
    }
}

private extension SourceAtlasSeedFoundry {
    func issues(
        descriptor: SourceAtlasReusableSeedDescriptor,
        pack: SourceAtlasPack,
        checkedAt: Date,
        policy: SourceAtlasSeedReusePolicy
    ) -> Set<SourceAtlasSeedFoundryIssue> {
        var issues: Set<SourceAtlasSeedFoundryIssue> = []

        if descriptor.id.isEmpty || descriptor.sourceSeedID.isEmpty {
            issues.insert(.missingSeedID)
        }
        if descriptor.packID.isEmpty {
            issues.insert(.missingPackID)
        }
        if descriptor.packID != pack.id {
            issues.insert(.packMismatch)
        }
        if packValidator.validate(pack).isEmpty == false {
            issues.insert(.packInvalid)
        }
        if policy.allows(descriptor.reuseScope) == false {
            issues.insert(.reuseScopeNotReusable)
        }
        if policy.allows(descriptor.riskClass) == false || descriptor.riskState.blocksCurrentProjection {
            issues.insert(.riskNotAllowed)
        }
        if descriptor.reviewState.blocksCurrentProjection {
            issues.insert(.reviewNotApproved)
        }
        if descriptor.freshnessState.blocksCurrentProjection || descriptor.sourceState.blocksCurrentProjection {
            issues.insert(.requirementCannotSupportCurrentUse)
        }

        validateSeedBinding(descriptor, pack: pack, issues: &issues)
        validateSourceBindings(descriptor, pack: pack, issues: &issues)
        validateClaimBindings(descriptor, pack: pack, issues: &issues)
        validateRequirementBindings(descriptor, pack: pack, issues: &issues)
        validateReleaseRecord(descriptor, pack: pack, checkedAt: checkedAt, policy: policy, issues: &issues)

        return issues
    }

    func validateSeedBinding(
        _ descriptor: SourceAtlasReusableSeedDescriptor,
        pack: SourceAtlasPack,
        issues: inout Set<SourceAtlasSeedFoundryIssue>
    ) {
        let seeds = pack.projections
            .flatMap(\.projectionProfiles)
            .flatMap(\.personalPathInstances)
            .flatMap(\.stepCandidateSeeds)
        guard let seed = seeds.first(where: { $0.id == descriptor.sourceSeedID }) else {
            issues.insert(.seedMissingFromPack)
            return
        }
        if descriptor.storesFinalSchedule || seed.storesFinalSchedule {
            issues.insert(.storesFinalSchedule)
        }
    }

    func validateSourceBindings(
        _ descriptor: SourceAtlasReusableSeedDescriptor,
        pack: SourceAtlasPack,
        issues: inout Set<SourceAtlasSeedFoundryIssue>
    ) {
        if descriptor.sourceRecordIDs.isEmpty {
            issues.insert(.sourceBindingMissing)
            return
        }
        let sourceIDs = Set(pack.sources.map(\.id))
        if descriptor.sourceRecordIDs.contains(where: { sourceIDs.contains($0) == false }) {
            issues.insert(.sourceBindingUnresolved)
        }
    }

    func validateClaimBindings(
        _ descriptor: SourceAtlasReusableSeedDescriptor,
        pack: SourceAtlasPack,
        issues: inout Set<SourceAtlasSeedFoundryIssue>
    ) {
        if descriptor.claimIDs.isEmpty {
            issues.insert(.claimBindingMissing)
            return
        }
        let claimsByID = Dictionary(uniqueKeysWithValues: pack.claims.map { ($0.id, $0) })
        for claimID in descriptor.claimIDs {
            guard let claim = claimsByID[claimID] else {
                issues.insert(.claimBindingUnresolved)
                continue
            }
            if claim.state == .contradicted || claim.freshness == .disputed {
                issues.insert(.claimContradicted)
            }
            if claim.state == .revoked || claim.freshness == .revoked {
                issues.insert(.claimRevoked)
            }
            if claim.canDriveCurrentRecommendation(using: pack.freshnessPolicy, riskPolicy: pack.riskPolicy) == false {
                issues.insert(.claimCannotSupportCurrentUse)
            }
        }
    }

    func validateRequirementBindings(
        _ descriptor: SourceAtlasReusableSeedDescriptor,
        pack: SourceAtlasPack,
        issues: inout Set<SourceAtlasSeedFoundryIssue>
    ) {
        if descriptor.requirementIDs.isEmpty {
            issues.insert(.requirementBindingMissing)
            return
        }
        let requirementsByID = Dictionary(uniqueKeysWithValues: pack.requirements.map { ($0.id, $0) })
        for requirementID in descriptor.requirementIDs {
            guard let requirement = requirementsByID[requirementID] else {
                issues.insert(.requirementBindingUnresolved)
                continue
            }
            if requirement.sourceState == .contradicted {
                issues.insert(.claimContradicted)
            }
            if requirement.sourceState == .revoked {
                issues.insert(.claimRevoked)
            }
            if requirement.canDriveCurrentRecommendation == false {
                issues.insert(.requirementCannotSupportCurrentUse)
            }
        }
    }

    func validateReleaseRecord(
        _ descriptor: SourceAtlasReusableSeedDescriptor,
        pack: SourceAtlasPack,
        checkedAt: Date,
        policy: SourceAtlasSeedReusePolicy,
        issues: inout Set<SourceAtlasSeedFoundryIssue>
    ) {
        guard let record = descriptor.releaseRecord else {
            if policy.requireReleaseRecord {
                issues.insert(.releaseRecordMissing)
            }
            return
        }
        if record.isAccepted == false {
            issues.insert(.releaseRecordRejected)
        }
        if record.packID != descriptor.packID ||
            record.packID != pack.id ||
            record.seedID != descriptor.id ||
            record.packVersion != pack.manifest.version ||
            record.manifestVersionID.isEmpty ||
            record.checksum.isEmpty {
            issues.insert(.releaseRecordMismatch)
        }
        if record.sourceRecordIDs.isEmpty ||
            record.claimIDs.isEmpty ||
            Set(record.sourceRecordIDs).isSuperset(of: descriptor.sourceRecordIDs) == false ||
            Set(record.claimIDs).isSuperset(of: descriptor.claimIDs) == false {
            issues.insert(.releaseRecordMissingBindings)
        }
        if record.isInsideFreshnessWindow(
            at: checkedAt,
            maximumWindowDays: policy.maximumFreshnessWindowDays
        ) == false {
            issues.insert(.freshnessWindowExpired)
        }
    }

    func state(for issues: [SourceAtlasSeedFoundryIssue]) -> SourceAtlasSeedPackState {
        if issues.contains(.packMismatch) {
            return .invalidPack
        }
        if issues.contains(.claimRevoked) {
            return .revoked
        }
        if issues.contains(.claimContradicted) {
            return .contradicted
        }
        if issues.contains(.packInvalid) {
            return .invalidPack
        }
        if issues.contains(.freshnessWindowExpired) {
            return .stale
        }
        if issues.contains(where: { issue in
            switch issue {
            case .releaseRecordMissing, .releaseRecordRejected, .releaseRecordMismatch, .releaseRecordMissingBindings:
                return true
            default:
                return false
            }
        }) {
            return .releaseBlocked
        }
        if issues.isEmpty == false {
            return .seedBlocked
        }
        return .current
    }

    func orderedIssues(_ issues: Set<SourceAtlasSeedFoundryIssue>) -> [SourceAtlasSeedFoundryIssue] {
        SourceAtlasSeedFoundryIssue.allCases.filter { issues.contains($0) }
    }
}

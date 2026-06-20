import Foundation

enum RuntimeCoreChainSegmentKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case pathSelection = "path_selection"
    case qualityFirewall = "quality_firewall"
    case graphCompiler = "graph_compiler"
    case elasticity = "elasticity"
    case scheduleInstall = "schedule_install"
    case consequenceReflow = "consequence_reflow"
    case highRiskSafety = "high_risk_safety"

    static let requiredOrder: [RuntimeCoreChainSegmentKind] = [
        .pathSelection,
        .qualityFirewall,
        .graphCompiler,
        .elasticity,
        .scheduleInstall,
        .consequenceReflow,
        .highRiskSafety
    ]

    var requiresReversibility: Bool {
        self == .scheduleInstall || self == .consequenceReflow
    }
}

enum RuntimeCoreChainSegmentState: String, Codable, Sendable, Equatable, Hashable {
    case ready
    case missing
    case review
    case blocked
}

enum RuntimeCoreUmbrellaGateIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case nonLocalRuntimeBoundary
    case missingSegment
    case duplicateSegment
    case segmentNeedsReview
    case segmentBlocked
    case blockedByUpstream
    case nonLocalOwner
    case missingSourceRecord
    case missingReceipt
    case missingReplayTrace
    case missingYouInspection
    case missingInspectionReadiness
    case irreversibleRequiredSegment
    case cannotDriveVisibleExecution
    case blocksDownstream
}

struct RuntimeCoreChainSegment: Codable, Sendable, Equatable, Hashable {
    let kind: RuntimeCoreChainSegmentKind
    let state: RuntimeCoreChainSegmentState
    let ownerID: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?
    let isLocallyOwned: Bool
    let isInspectionReady: Bool
    let isReversible: Bool
    let canDriveVisibleExecution: Bool
    let blocksDownstream: Bool

    init(
        kind: RuntimeCoreChainSegmentKind,
        state: RuntimeCoreChainSegmentState,
        ownerID: String = "private_life_runtime",
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceID: String?,
        whatAmbitionsKnowsRoute: String?,
        isLocallyOwned: Bool = true,
        isInspectionReady: Bool = true,
        isReversible: Bool = true,
        canDriveVisibleExecution: Bool = true,
        blocksDownstream: Bool = false
    ) {
        self.kind = kind
        self.state = state
        self.ownerID = ownerID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordIDs = Self.normalizedIDs(sourceRecordIDs)
        self.receiptIDs = Self.normalizedIDs(receiptIDs)
        self.replayTraceID = Self.normalizedOptionalID(replayTraceID)
        self.whatAmbitionsKnowsRoute = Self.normalizedOptionalID(whatAmbitionsKnowsRoute)
        self.isLocallyOwned = isLocallyOwned
        self.isInspectionReady = isInspectionReady
        self.isReversible = isReversible
        self.canDriveVisibleExecution = canDriveVisibleExecution
        self.blocksDownstream = blocksDownstream
    }

    private static func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }

    private static func normalizedOptionalID(_ value: String?) -> String? {
        guard let normalized = value?.trimmingCharacters(in: .whitespacesAndNewlines), normalized.isEmpty == false else {
            return nil
        }
        return normalized
    }
}

struct RuntimeCoreUmbrellaGateInput: Sendable, Equatable {
    let boundary: PrivateLifeRuntimeBoundary
    let segments: [RuntimeCoreChainSegment]

    init(
        boundary: PrivateLifeRuntimeBoundary = .localOnly,
        segments: [RuntimeCoreChainSegment]
    ) {
        self.boundary = boundary
        self.segments = segments
    }
}

struct RuntimeCoreUmbrellaGateRow: Codable, Sendable, Equatable, Hashable {
    let kind: RuntimeCoreChainSegmentKind
    let state: RuntimeCoreChainSegmentState
    let ownerID: String?
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?
    let issues: [RuntimeCoreUmbrellaGateIssue]

    var canDriveSegment: Bool {
        issues.isEmpty && state == .ready
    }
}

struct RuntimeCoreUmbrellaGateRecord: Sendable, Equatable {
    let id: String
    let isLocalOnly: Bool
    let canOpenRuntimeCore: Bool
    let gateIssues: [RuntimeCoreUmbrellaGateIssue]
    let rows: [RuntimeCoreUmbrellaGateRow]

    var blockedSegmentKinds: [RuntimeCoreChainSegmentKind] {
        rows.filter { $0.canDriveSegment == false }.map(\.kind)
    }
}

struct RuntimeCoreUmbrellaGate: Sendable, Equatable {
    func evaluate(_ input: RuntimeCoreUmbrellaGateInput) -> RuntimeCoreUmbrellaGateRecord {
        let groupedSegments = Dictionary(grouping: input.segments, by: \.kind)
        var upstreamOpen = true
        let rows = RuntimeCoreChainSegmentKind.requiredOrder.map { kind in
            let row = makeRow(
                kind: kind,
                candidates: groupedSegments[kind] ?? [],
                boundaryIsLocalOnly: input.boundary.isLocalOnly,
                upstreamOpen: upstreamOpen
            )
            if row.canDriveSegment == false || row.issues.contains(.blocksDownstream) {
                upstreamOpen = false
            }
            return row
        }
        var gateIssues: Set<RuntimeCoreUmbrellaGateIssue> = []
        if input.boundary.isLocalOnly == false {
            gateIssues.insert(.nonLocalRuntimeBoundary)
        }
        for row in rows {
            gateIssues.formUnion(row.issues)
        }
        let sortedGateIssues = gateIssues.sorted { $0.rawValue < $1.rawValue }
        let canOpenRuntimeCore = sortedGateIssues.isEmpty && rows.allSatisfy(\.canDriveSegment)

        return RuntimeCoreUmbrellaGateRecord(
            id: gateIdentifier(boundary: input.boundary, rows: rows, issues: sortedGateIssues),
            isLocalOnly: input.boundary.isLocalOnly,
            canOpenRuntimeCore: canOpenRuntimeCore,
            gateIssues: sortedGateIssues,
            rows: rows
        )
    }

    private func makeRow(
        kind: RuntimeCoreChainSegmentKind,
        candidates: [RuntimeCoreChainSegment],
        boundaryIsLocalOnly: Bool,
        upstreamOpen: Bool
    ) -> RuntimeCoreUmbrellaGateRow {
        guard let segment = candidates.sorted(by: segmentSort).first else {
            return RuntimeCoreUmbrellaGateRow(
                kind: kind,
                state: .missing,
                ownerID: nil,
                sourceRecordIDs: [],
                receiptIDs: [],
                replayTraceID: nil,
                whatAmbitionsKnowsRoute: nil,
                issues: [.missingSegment]
            )
        }

        var issues: Set<RuntimeCoreUmbrellaGateIssue> = []
        if boundaryIsLocalOnly == false {
            issues.insert(.nonLocalRuntimeBoundary)
        }
        if candidates.count > 1 {
            issues.insert(.duplicateSegment)
        }
        if upstreamOpen == false {
            issues.insert(.blockedByUpstream)
        }
        switch segment.state {
        case .ready:
            break
        case .missing:
            issues.insert(.missingSegment)
        case .review:
            issues.insert(.segmentNeedsReview)
        case .blocked:
            issues.insert(.segmentBlocked)
        }
        if segment.isLocallyOwned == false || segment.ownerID.isEmpty {
            issues.insert(.nonLocalOwner)
        }
        if segment.sourceRecordIDs.isEmpty {
            issues.insert(.missingSourceRecord)
        }
        if segment.receiptIDs.isEmpty {
            issues.insert(.missingReceipt)
        }
        if segment.replayTraceID == nil {
            issues.insert(.missingReplayTrace)
        }
        if segment.whatAmbitionsKnowsRoute == nil {
            issues.insert(.missingYouInspection)
        }
        if segment.isInspectionReady == false {
            issues.insert(.missingInspectionReadiness)
        }
        if kind.requiresReversibility && segment.isReversible == false {
            issues.insert(.irreversibleRequiredSegment)
        }
        if segment.canDriveVisibleExecution == false {
            issues.insert(.cannotDriveVisibleExecution)
        }
        if segment.blocksDownstream {
            issues.insert(.blocksDownstream)
        }

        return RuntimeCoreUmbrellaGateRow(
            kind: kind,
            state: segment.state,
            ownerID: segment.ownerID,
            sourceRecordIDs: segment.sourceRecordIDs,
            receiptIDs: segment.receiptIDs,
            replayTraceID: segment.replayTraceID,
            whatAmbitionsKnowsRoute: segment.whatAmbitionsKnowsRoute,
            issues: issues.sorted { $0.rawValue < $1.rawValue }
        )
    }

    private func segmentSort(_ lhs: RuntimeCoreChainSegment, _ rhs: RuntimeCoreChainSegment) -> Bool {
        [
            lhs.ownerID,
            lhs.sourceRecordIDs.joined(separator: ","),
            lhs.receiptIDs.joined(separator: ","),
            lhs.replayTraceID ?? "",
            lhs.whatAmbitionsKnowsRoute ?? ""
        ]
        .joined(separator: "|") < [
            rhs.ownerID,
            rhs.sourceRecordIDs.joined(separator: ","),
            rhs.receiptIDs.joined(separator: ","),
            rhs.replayTraceID ?? "",
            rhs.whatAmbitionsKnowsRoute ?? ""
        ]
        .joined(separator: "|")
    }

    private func gateIdentifier(
        boundary: PrivateLifeRuntimeBoundary,
        rows: [RuntimeCoreUmbrellaGateRow],
        issues: [RuntimeCoreUmbrellaGateIssue]
    ) -> String {
        let rowSignature = rows.map { row in
            [
                row.kind.rawValue,
                row.state.rawValue,
                row.ownerID ?? "missing-owner",
                row.sourceRecordIDs.joined(separator: ","),
                row.receiptIDs.joined(separator: ","),
                row.replayTraceID ?? "missing-replay",
                row.whatAmbitionsKnowsRoute ?? "missing-inspection",
                row.issues.map(\.rawValue).joined(separator: ",")
            ]
            .joined(separator: ":")
        }
        .joined(separator: "|")
        return [
            "runtime-core",
            "umbrella-gate",
            boundary.isLocalOnly ? "local-only" : "mixed-boundary",
            rowSignature,
            issues.map(\.rawValue).joined(separator: ",")
        ]
        .joined(separator: ".")
    }
}

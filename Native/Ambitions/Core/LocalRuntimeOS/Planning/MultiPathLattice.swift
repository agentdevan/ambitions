import Foundation

enum MultiPathLatticeSelectionState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case awaitingExplicitSelection = "awaiting_explicit_selection"
    case selected
    case blocked
}

enum MultiPathLatticeIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case malformedPortfolio = "malformed_portfolio"
    case multipleViablePathsRequired = "multiple_viable_paths_required"
    case explicitSelectionRequired = "explicit_selection_required"
    case selectedPathMissing = "selected_path_missing"
    case selectedPathBlocked = "selected_path_blocked"
    case missingSourceRecord = "missing_source_record"
    case missingReceipt = "missing_receipt"
    case missingReplayTrace = "missing_replay_trace"
    case missingInspectionRoute = "missing_inspection_route"
    case missingComparisonTradeoff = "missing_comparison_tradeoff"
    case comparisonNotReady = "comparison_not_ready"
    case missingSelectionReceipt = "missing_selection_receipt"
    case hiddenMutationRisk = "hidden_mutation_risk"
    case sourceReviewRequired = "source_review_required"
    case unsafeProjection = "unsafe_projection"
}

enum MultiPathTradeoffDimension: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case capacity
    case proofContinuity = "proof_continuity"
    case sourceConfidence = "source_confidence"
    case timeFit = "time_fit"
    case reversibility
    case privacyBoundary = "privacy_boundary"
}

struct MultiPathTradeoff: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let dimension: MultiPathTradeoffDimension
    let summary: String
    let weight: Int

    init(id: String, dimension: MultiPathTradeoffDimension, summary: String, weight: Int) {
        self.id = Self.normalizedID(id)
        self.dimension = dimension
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.weight = min(100, max(0, weight))
    }

    var isReady: Bool {
        id.isEmpty == false && summary.isEmpty == false
    }

    private static func normalizedID(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct MultiPathLatticeCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let summary: String
    let kind: AmbitionsOSAlternatePathKind
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?
    let tradeoffs: [MultiPathTradeoff]
    let requirementSlotIDs: [String]
    let transferableProofReceiptIDs: [String]
    let issues: [MultiPathLatticeIssue]

    var isViable: Bool {
        issues.isEmpty
    }

    var isComparisonReady: Bool {
        tradeoffs.isEmpty == false && tradeoffs.allSatisfy(\.isReady)
    }
}

struct MultiPathComparisonRow: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let pathID: String
    let tradeoffs: [MultiPathTradeoff]
    let issues: [MultiPathLatticeIssue]

    var isReady: Bool {
        issues.isEmpty
    }
}

struct MultiPathSelectionReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalReferenceID: String
    let selectedPathID: String
    let rejectedPathIDs: [String]
    let reason: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String
    let whatAmbitionsKnowsRoute: String
    let selectedAt: String
    let localOnly: Bool
}

struct MultiPathLatticePersistenceSnapshot: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalReferenceID: String
    let selectedPathID: String?
    let pathIDs: [String]
    let comparisonFingerprint: String
    let selectionReceiptID: String?
    let replayTraceID: String?
    let localOnly: Bool
}

struct MultiPathLatticeInput: Sendable, Equatable {
    let goalReferenceID: String
    let portfolio: AmbitionsOSPathPortfolio
    let selectedPathID: String?
    let selectionReason: String?
    let selectionReceiptID: String?
    let selectedAt: String?
    let sourceRecordIDsByPathID: [String: [String]]
    let receiptIDsByPathID: [String: [String]]
    let replayTraceIDsByPathID: [String: String]
    let whatAmbitionsKnowsRoutesByPathID: [String: String]
    let tradeoffsByPathID: [String: [MultiPathTradeoff]]

    init(
        goalReferenceID: String,
        portfolio: AmbitionsOSPathPortfolio,
        selectedPathID: String? = nil,
        selectionReason: String? = nil,
        selectionReceiptID: String? = nil,
        selectedAt: String? = nil,
        sourceRecordIDsByPathID: [String: [String]],
        receiptIDsByPathID: [String: [String]],
        replayTraceIDsByPathID: [String: String],
        whatAmbitionsKnowsRoutesByPathID: [String: String],
        tradeoffsByPathID: [String: [MultiPathTradeoff]]
    ) {
        self.goalReferenceID = goalReferenceID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.portfolio = portfolio
        self.selectedPathID = Self.normalizedOptional(selectedPathID)
        self.selectionReason = Self.normalizedOptional(selectionReason)
        self.selectionReceiptID = Self.normalizedOptional(selectionReceiptID)
        self.selectedAt = Self.normalizedOptional(selectedAt)
        self.sourceRecordIDsByPathID = sourceRecordIDsByPathID
        self.receiptIDsByPathID = receiptIDsByPathID
        self.replayTraceIDsByPathID = replayTraceIDsByPathID
        self.whatAmbitionsKnowsRoutesByPathID = whatAmbitionsKnowsRoutesByPathID
        self.tradeoffsByPathID = tradeoffsByPathID
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let normalized = value?.trimmingCharacters(in: .whitespacesAndNewlines), normalized.isEmpty == false else {
            return nil
        }
        return normalized
    }
}

struct MultiPathLatticeRecord: Sendable, Equatable {
    let id: String
    let goalReferenceID: String
    let selectionState: MultiPathLatticeSelectionState
    let candidates: [MultiPathLatticeCandidate]
    let comparisonRows: [MultiPathComparisonRow]
    let selectedPathID: String?
    let selectionReceipt: MultiPathSelectionReceipt?
    let persistenceSnapshot: MultiPathLatticePersistenceSnapshot
    let issues: [MultiPathLatticeIssue]

    var viablePathIDs: [String] {
        candidates.filter(\.isViable).map(\.id)
    }

    var canComparePaths: Bool {
        candidates.count >= 2 && comparisonRows.allSatisfy(\.isReady)
    }

    var canPersistSelection: Bool {
        selectionReceipt != nil && persistenceSnapshot.selectedPathID != nil
    }

    var canDrivePathSelectionSegment: Bool {
        selectionState == .selected && issues.isEmpty && canComparePaths && canPersistSelection
    }

    var runtimeCoreSegment: RuntimeCoreChainSegment {
        let selectedCandidate = candidates.first { $0.id == selectedPathID }
        let receiptIDs = Array(Set((selectedCandidate?.receiptIDs ?? []) + [selectionReceipt?.id].compactMap { $0 })).sorted()
        return RuntimeCoreChainSegment(
            kind: .pathSelection,
            state: canDrivePathSelectionSegment ? .ready : .blocked,
            sourceRecordIDs: selectedCandidate?.sourceRecordIDs ?? [],
            receiptIDs: receiptIDs,
            replayTraceID: selectedCandidate?.replayTraceID,
            whatAmbitionsKnowsRoute: selectedCandidate?.whatAmbitionsKnowsRoute,
            isReversible: true,
            canDriveVisibleExecution: canDrivePathSelectionSegment,
            blocksDownstream: canDrivePathSelectionSegment == false
        )
    }
}

struct MultiPathLatticeEngine: Sendable, Equatable {
    func evaluate(_ input: MultiPathLatticeInput) -> MultiPathLatticeRecord {
        let candidates = input.portfolio.paths
            .map { makeCandidate(from: $0, input: input) }
            .sorted { $0.id < $1.id }
        let comparisonRows = candidates
            .map { candidate in
                MultiPathComparisonRow(
                    id: stableIdentifier(prefix: "multi-path.comparison", components: [candidate.id]),
                    pathID: candidate.id,
                    tradeoffs: candidate.tradeoffs,
                    issues: candidate.isComparisonReady ? [] : [.missingComparisonTradeoff]
                )
            }
            .sorted { $0.pathID < $1.pathID }
        let issues = recordIssues(input: input, candidates: candidates, comparisonRows: comparisonRows)
        let selectionState = selectionState(input: input, issues: issues)
        let selectedCandidate = candidates.first { $0.id == input.selectedPathID }
        let selectionReceipt = makeSelectionReceipt(
            input: input,
            selectedCandidate: selectedCandidate,
            candidates: candidates,
            issues: issues
        )
        let persistenceSnapshot = makePersistenceSnapshot(
            input: input,
            candidates: candidates,
            comparisonRows: comparisonRows,
            selectionReceipt: selectionReceipt
        )

        return MultiPathLatticeRecord(
            id: stableIdentifier(
                prefix: "multi-path.lattice",
                components: [
                    input.goalReferenceID,
                    input.portfolio.id,
                    candidates.map(\.id).joined(separator: ","),
                    input.selectedPathID ?? "unselected",
                    persistenceSnapshot.comparisonFingerprint
                ]
            ),
            goalReferenceID: input.goalReferenceID,
            selectionState: selectionState,
            candidates: candidates,
            comparisonRows: comparisonRows,
            selectedPathID: input.selectedPathID,
            selectionReceipt: selectionReceipt,
            persistenceSnapshot: persistenceSnapshot,
            issues: issues
        )
    }

    private func makeCandidate(
        from path: AmbitionsOSAlternatePathCandidate,
        input: MultiPathLatticeInput
    ) -> MultiPathLatticeCandidate {
        let sourceRecordIDs = normalizedIDs(input.sourceRecordIDsByPathID[path.id] ?? [])
        let receiptIDs = normalizedIDs(input.receiptIDsByPathID[path.id] ?? [])
        let replayTraceID = normalizedOptional(input.replayTraceIDsByPathID[path.id])
        let inspectionRoute = normalizedOptional(input.whatAmbitionsKnowsRoutesByPathID[path.id])
        let tradeoffs = (input.tradeoffsByPathID[path.id] ?? []).sorted { $0.id < $1.id }
        var issues: Set<MultiPathLatticeIssue> = []

        if path.isWellFormed == false {
            issues.insert(.malformedPortfolio)
        }
        if sourceRecordIDs.isEmpty {
            issues.insert(.missingSourceRecord)
        }
        if receiptIDs.isEmpty {
            issues.insert(.missingReceipt)
        }
        if replayTraceID == nil {
            issues.insert(.missingReplayTrace)
        }
        if inspectionRoute == nil {
            issues.insert(.missingInspectionRoute)
        }
        if tradeoffs.isEmpty || tradeoffs.contains(where: { $0.isReady == false }) {
            issues.insert(.missingComparisonTradeoff)
        }
        if path.kind.requiresSourceReview &&
            (path.sourceState.canDriveSourceSensitiveRecommendation == false ||
             path.freshnessState.blocksHighRiskUse ||
             path.reviewState.blocksAutomaticMutation) {
            issues.insert(.sourceReviewRequired)
        }
        if path.externalProjectionRequested && path.privacyClass == .sensitive && path.isExternalProjectionSafe == false {
            issues.insert(.unsafeProjection)
        }

        return MultiPathLatticeCandidate(
            id: path.id,
            title: path.title,
            summary: path.summary,
            kind: path.kind,
            sourceRecordIDs: sourceRecordIDs,
            receiptIDs: receiptIDs,
            replayTraceID: replayTraceID,
            whatAmbitionsKnowsRoute: inspectionRoute,
            tradeoffs: tradeoffs,
            requirementSlotIDs: path.requirementSlotIDs,
            transferableProofReceiptIDs: path.transferableProofReceiptIDs,
            issues: issues.sorted { $0.rawValue < $1.rawValue }
        )
    }

    private func recordIssues(
        input: MultiPathLatticeInput,
        candidates: [MultiPathLatticeCandidate],
        comparisonRows: [MultiPathComparisonRow]
    ) -> [MultiPathLatticeIssue] {
        var issues: Set<MultiPathLatticeIssue> = []
        let portfolioIssues = input.portfolio.validationIssues
        if portfolioIssues.contains(.malformedPortfolio) ||
            portfolioIssues.contains(.malformedPath) ||
            portfolioIssues.contains(.missingActivePath) ||
            portfolioIssues.contains(.missingAlternativePath) {
            issues.insert(.malformedPortfolio)
        }
        if portfolioIssues.contains(.hiddenMutationRisk) || portfolioIssues.contains(.runtimeStoreBehavior) {
            issues.insert(.hiddenMutationRisk)
        }
        if portfolioIssues.contains(.sourceReviewRequired) ||
            portfolioIssues.contains(.professionalBoundaryReviewRequired) {
            issues.insert(.sourceReviewRequired)
        }
        if portfolioIssues.contains(.externalProjectionRisk) {
            issues.insert(.unsafeProjection)
        }

        if candidates.filter(\.isViable).count < 2 {
            issues.insert(.multipleViablePathsRequired)
        }
        if comparisonRows.contains(where: { $0.isReady == false }) {
            issues.insert(.comparisonNotReady)
        }
        guard let selectedPathID = input.selectedPathID else {
            issues.insert(.explicitSelectionRequired)
            return issues.sorted { $0.rawValue < $1.rawValue }
        }
        guard let selectedCandidate = candidates.first(where: { $0.id == selectedPathID }) else {
            issues.insert(.selectedPathMissing)
            return issues.sorted { $0.rawValue < $1.rawValue }
        }
        if selectedCandidate.isViable == false {
            issues.insert(.selectedPathBlocked)
        }
        if input.selectionReceiptID == nil {
            issues.insert(.missingSelectionReceipt)
        }
        if input.selectedAt == nil {
            issues.insert(.missingSelectionReceipt)
        }
        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    private func selectionState(
        input: MultiPathLatticeInput,
        issues: [MultiPathLatticeIssue]
    ) -> MultiPathLatticeSelectionState {
        if input.selectedPathID == nil {
            return .awaitingExplicitSelection
        }
        if issues.isEmpty {
            return .selected
        }
        return .blocked
    }

    private func makeSelectionReceipt(
        input: MultiPathLatticeInput,
        selectedCandidate: MultiPathLatticeCandidate?,
        candidates: [MultiPathLatticeCandidate],
        issues: [MultiPathLatticeIssue]
    ) -> MultiPathSelectionReceipt? {
        guard
            issues.isEmpty,
            let selectedCandidate,
            let selectionReceiptID = input.selectionReceiptID,
            let replayTraceID = selectedCandidate.replayTraceID,
            let inspectionRoute = selectedCandidate.whatAmbitionsKnowsRoute,
            let selectedAt = input.selectedAt
        else {
            return nil
        }
        return MultiPathSelectionReceipt(
            id: selectionReceiptID,
            goalReferenceID: input.goalReferenceID,
            selectedPathID: selectedCandidate.id,
            rejectedPathIDs: candidates.map(\.id).filter { $0 != selectedCandidate.id }.sorted(),
            reason: input.selectionReason ?? "Explicit local path selection",
            sourceRecordIDs: selectedCandidate.sourceRecordIDs,
            receiptIDs: Array(Set(selectedCandidate.receiptIDs + [selectionReceiptID])).sorted(),
            replayTraceID: replayTraceID,
            whatAmbitionsKnowsRoute: inspectionRoute,
            selectedAt: selectedAt,
            localOnly: true
        )
    }

    private func makePersistenceSnapshot(
        input: MultiPathLatticeInput,
        candidates: [MultiPathLatticeCandidate],
        comparisonRows: [MultiPathComparisonRow],
        selectionReceipt: MultiPathSelectionReceipt?
    ) -> MultiPathLatticePersistenceSnapshot {
        let pathIDs = candidates.map(\.id)
        let comparisonFingerprint = stableIdentifier(
            prefix: "multi-path.comparison",
            components: comparisonRows.flatMap { row in
                [row.pathID] + row.tradeoffs.map { "\($0.dimension.rawValue):\($0.id):\($0.weight)" }
            }
        )
        return MultiPathLatticePersistenceSnapshot(
            id: stableIdentifier(
                prefix: "multi-path.persistence",
                components: [
                    input.goalReferenceID,
                    pathIDs.joined(separator: ","),
                    selectionReceipt?.selectedPathID ?? "unselected",
                    comparisonFingerprint
                ]
            ),
            goalReferenceID: input.goalReferenceID,
            selectedPathID: selectionReceipt?.selectedPathID,
            pathIDs: pathIDs,
            comparisonFingerprint: comparisonFingerprint,
            selectionReceiptID: selectionReceipt?.id,
            replayTraceID: selectionReceipt?.replayTraceID,
            localOnly: true
        )
    }

    private func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }

    private func normalizedOptional(_ value: String?) -> String? {
        guard let normalized = value?.trimmingCharacters(in: .whitespacesAndNewlines), normalized.isEmpty == false else {
            return nil
        }
        return normalized
    }

    private func stableIdentifier(prefix: String, components: [String]) -> String {
        let tokens = components
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { $0.isEmpty == false }
            .map { value in
                value.map { character -> Character in
                    character.isLetter || character.isNumber ? character : "-"
                }
            }
            .map { String($0).replacingOccurrences(of: "--+", with: "-", options: .regularExpression) }
        return ([prefix] + tokens).joined(separator: ".")
    }
}

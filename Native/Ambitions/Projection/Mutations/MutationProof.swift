import Foundation

enum MutationProofState: String, Equatable, Sendable {
    case available
    case unavailable
}

struct MutationSnapshotReference: Equatable, Sendable {
    let id: String
    let surface: StageMutationTargetSurface
    let summary: String

    var isTypedReference: Bool {
        id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
}

struct MutationActionReference: Equatable, Sendable {
    let commandID: String
    let commandPayload: RuntimeCommandPayload
    let source: AmbitionsCommandSource
    let targetObjectIDs: [String]

    var isTypedReference: Bool {
        commandID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            commandPayload.diagnosticFamily.isEmpty == false &&
            commandPayload.diagnosticCase.isEmpty == false &&
            targetObjectIDs.isEmpty == false
    }
}

struct MutationProof: Equatable, Sendable {
    let artifactID: String
    let label: String
    let localOnly: Bool
    let state: MutationProofState
    let beforeSnapshot: MutationSnapshotReference?
    let action: MutationActionReference?
    let afterSnapshot: MutationSnapshotReference?
    let fallbackReason: String?

    var isTypedAvailable: Bool {
        state == .available &&
            artifactID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            localOnly &&
            beforeSnapshot?.isTypedReference == true &&
            action?.isTypedReference == true &&
            afterSnapshot?.isTypedReference == true
    }

    var isTypedUnavailableFallback: Bool {
        state == .unavailable &&
            fallbackReason?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            beforeSnapshot?.isTypedReference == true &&
            action?.isTypedReference == true
    }

    init(
        artifactID: String,
        label: String,
        localOnly: Bool,
        beforeSnapshot: MutationSnapshotReference,
        action: MutationActionReference,
        afterSnapshot: MutationSnapshotReference
    ) {
        self.artifactID = artifactID
        self.label = label
        self.localOnly = localOnly
        self.state = .available
        self.beforeSnapshot = beforeSnapshot
        self.action = action
        self.afterSnapshot = afterSnapshot
        self.fallbackReason = nil
    }

    static func unavailable(
        label: String,
        localOnly: Bool,
        beforeSnapshot: MutationSnapshotReference,
        action: MutationActionReference?,
        fallbackReason: String
    ) -> MutationProof {
        MutationProof(
            artifactID: "",
            label: label,
            localOnly: localOnly,
            state: .unavailable,
            beforeSnapshot: beforeSnapshot,
            action: action,
            afterSnapshot: nil,
            fallbackReason: fallbackReason
        )
    }

    private init(
        artifactID: String,
        label: String,
        localOnly: Bool,
        state: MutationProofState,
        beforeSnapshot: MutationSnapshotReference?,
        action: MutationActionReference?,
        afterSnapshot: MutationSnapshotReference?,
        fallbackReason: String?
    ) {
        self.artifactID = artifactID
        self.label = label
        self.localOnly = localOnly
        self.state = state
        self.beforeSnapshot = beforeSnapshot
        self.action = action
        self.afterSnapshot = afterSnapshot
        self.fallbackReason = fallbackReason
    }
}

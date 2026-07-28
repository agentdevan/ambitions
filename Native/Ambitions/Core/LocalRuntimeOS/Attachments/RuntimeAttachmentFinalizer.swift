import Foundation

struct RuntimeAttachmentFinalizationResult: Sendable, Equatable {
    let completedCount: Int
    let findings: [RuntimeAttachmentRecoveryFinding]
}

actor RuntimeAttachmentFinalizer {
    private let store: CanonicalRuntimeStore
    private let vault: RuntimeAttachmentVault

    init(store: CanonicalRuntimeStore, vault: RuntimeAttachmentVault) {
        self.store = store
        self.vault = vault
    }

    func finalizeDue(limit: Int, now: Date) async throws -> RuntimeAttachmentFinalizationResult {
        let work = try await store.dueAttachmentFinalizations(limit: limit, now: now)
        var completed = 0
        var findings: [RuntimeAttachmentRecoveryFinding] = []
        for item in work {
            try Task.checkCancellation()
            let authorityID = item.manifest.blobID.rawValue
            let occurrence = RuntimeAttachmentCodec.sha256(Data([
                "ambitions.attachment.finalization-occurrence.v1", item.manifestDigest,
                item.commandID.rawValue, item.receiptID.rawValue,
                String(item.lineage.eventSequence), String(item.expectedStateVersion),
            ].joined(separator: "\u{0}").utf8))
            guard try await store.beginAttachmentRecoveryAttempt(
                workKind: .finalization, authorityID: authorityID,
                occurrence: occurrence, now: now
            ) else {
                continue
            }
            do {
                guard let graph = try await store.attachmentAuthoritySnapshot(
                    revisionID: item.revisionID
                ),
                      graph.lifecycle.state == .referenced,
                      graph.lifecycle.stateVersion >= item.expectedStateVersion,
                      graph.manifest == item.manifest else {
                    throw RuntimeCanonicalAttachmentError.lifecycleConflict
                }
                try await vault.verifyAuthenticatedBlob(graph)
                let proof = try await vault.writeFinalizationMarker(
                    manifest: item.manifest, manifestDigest: item.manifestDigest,
                    receiptID: item.receiptID, lineage: item.lineage, finalizedAt: now
                )
                try await store.completeAttachmentFinalization(item, proof: proof)
                completed += 1
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                let fingerprint = Self.errorFingerprint(
                    workKind: .finalization, authorityID: authorityID, error: error
                )
                try await store.recordAttachmentRecoveryAttemptFailure(
                    workKind: .finalization, authorityID: authorityID,
                    errorFingerprint: fingerprint
                )
                let finding = RuntimeAttachmentRecoveryFinding(
                    issue: .finalizationMissing, blobID: item.manifest.blobID,
                    opaqueRelativeDirectory: item.manifest.opaqueRelativeDirectory,
                    evidenceFingerprint: fingerprint, observedAt: now
                )
                try await store.recordAttachmentRecoveryFinding(finding)
                findings.append(finding)
            }
        }
        return RuntimeAttachmentFinalizationResult(
            completedCount: completed, findings: findings
        )
    }

    static func errorFingerprint(
        workKind: RuntimeAttachmentRecoveryWorkKind,
        authorityID: String,
        error: any Error
    ) -> String {
        RuntimeAttachmentCodec.sha256(Data(
            "ambitions.attachment.recovery-error.v1\u{0}\(workKind.rawValue)\u{0}\(authorityID)\u{0}\(String(reflecting: type(of: error)))".utf8
        ))
    }
}

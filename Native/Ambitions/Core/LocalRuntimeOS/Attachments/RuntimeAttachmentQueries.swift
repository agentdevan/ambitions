import CryptoKit
import Foundation

enum RuntimeAttachmentReadPurpose: String, Sendable, Equatable, Hashable {
    case interactiveObjectDetail = "interactive_object_detail"
    case userInitiatedExport = "user_initiated_export"
}

struct RuntimeAttachmentReadGrant: Sendable, Equatable, Hashable {
    let revisionID: RuntimeAttachmentRevisionID
    let receiptID: RuntimeReceiptID
    let manifestDigest: String
    let privacy: EventLedgerPrivacyClassification
    let purpose: RuntimeAttachmentReadPurpose
    let expiresAt: Date
    fileprivate let authorityMAC: Data

    fileprivate static func authorityIssued(
        revisionID: RuntimeAttachmentRevisionID,
        receiptID: RuntimeReceiptID,
        manifestDigest: String,
        privacy: EventLedgerPrivacyClassification,
        purpose: RuntimeAttachmentReadPurpose,
        expiresAt: Date,
        authorityMAC: Data
    ) -> RuntimeAttachmentReadGrant {
        RuntimeAttachmentReadGrant(
            revisionID: revisionID, receiptID: receiptID,
            manifestDigest: manifestDigest, privacy: privacy,
            purpose: purpose, expiresAt: expiresAt, authorityMAC: authorityMAC
        )
    }

    fileprivate var authenticationMessage: Data {
        Data(
            "ambitions.attachment.read-grant.v3\u{0}\(revisionID.rawValue)\u{0}\(receiptID.rawValue)\u{0}\(manifestDigest)\u{0}\(privacy.rawValue)\u{0}\(purpose.rawValue)\u{0}\(expiresAt.timeIntervalSince1970)".utf8
        )
    }
}

struct RuntimeAuthenticatedAttachmentReadAuthority: Sendable, Equatable {
    let revisionID: RuntimeAttachmentRevisionID
    let blobID: RuntimeBlobID
    let manifestDigest: String
    let privacy: EventLedgerPrivacyClassification
    let receiptID: RuntimeReceiptID
    let commandID: RuntimeCommandID
    let lineage: RuntimeAuthorityLineageReference
    let authenticatedAt: Date
}

actor RuntimeAttachmentAccessAuthority {
    private let store: CanonicalRuntimeStore
    private let authenticationKey: SymmetricKey
    private let clock: @Sendable () -> Date

    init(
        store: CanonicalRuntimeStore,
        authenticationKey: SymmetricKey = SymmetricKey(size: .bits256),
        clock: @escaping @Sendable () -> Date = Date.init
    ) {
        self.store = store
        self.authenticationKey = authenticationKey
        self.clock = clock
    }

    func issueReadGrant(
        receiptID: RuntimeReceiptID,
        revisionID: RuntimeAttachmentRevisionID,
        purpose: RuntimeAttachmentReadPurpose,
        lifetime: TimeInterval = 5 * 60
    ) async throws -> RuntimeAttachmentReadGrant {
        guard lifetime > 0, lifetime <= 15 * 60 else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        let observedAt = clock()
        let authority = try await loadAuthority(
            receiptID: receiptID, revisionID: revisionID, observedAt: observedAt
        )
        let unsigned = RuntimeAttachmentReadGrant.authorityIssued(
            revisionID: revisionID, receiptID: receiptID,
            manifestDigest: authority.manifestDigest,
            privacy: authority.privacy, purpose: purpose,
            expiresAt: observedAt.addingTimeInterval(lifetime), authorityMAC: Data()
        )
        return .authorityIssued(
            revisionID: unsigned.revisionID, receiptID: unsigned.receiptID,
            manifestDigest: unsigned.manifestDigest, privacy: unsigned.privacy,
            purpose: unsigned.purpose, expiresAt: unsigned.expiresAt,
            authorityMAC: Data(HMAC<SHA256>.authenticationCode(
                for: unsigned.authenticationMessage, using: authenticationKey
            ))
        )
    }

    func authenticatedAuthority(
        grant: RuntimeAttachmentReadGrant,
        allowedPurpose: RuntimeAttachmentReadPurpose
    ) async throws -> RuntimeAuthenticatedAttachmentReadAuthority {
        let observedAt = clock()
        guard grant.purpose == allowedPurpose,
              grant.expiresAt > observedAt,
              grant.authorityMAC.count == 32 else {
            throw RuntimeCanonicalAttachmentError.quarantined
        }
        let expected = Data(HMAC<SHA256>.authenticationCode(
            for: grant.authenticationMessage, using: authenticationKey
        ))
        guard Self.constantTimeEquals(expected, grant.authorityMAC) else {
            throw RuntimeCanonicalAttachmentError.quarantined
        }
        let authority = try await loadAuthority(
            receiptID: grant.receiptID, revisionID: grant.revisionID,
            observedAt: observedAt
        )
        guard authority.manifestDigest == grant.manifestDigest,
              authority.privacy == grant.privacy else {
            throw RuntimeCanonicalAttachmentError.quarantined
        }
        return authority
    }

    private func loadAuthority(
        receiptID: RuntimeReceiptID,
        revisionID: RuntimeAttachmentRevisionID,
        observedAt: Date
    ) async throws -> RuntimeAuthenticatedAttachmentReadAuthority {
        try await store.withCanonicalReadTransaction { database in
            try CanonicalRuntimeAttachmentSchemaPlan.requireIntegratedSchema(in: database)
            var budget = RuntimeReceiptDecodedByteBudget(
                maximumBytes: RuntimeCommittedReceiptReadBounds.maximumAttachmentArtifactGraphBytes
            )
            let receipt = try RuntimeCommittedReceiptAuthority.loadAuthenticatedGraph(
                receiptID: receiptID, budget: &budget, database: database
            )
            guard receipt.core.facts.privacy.localOnly else {
                throw RuntimeCanonicalAttachmentError.quarantined
            }
            let links = try budget.query(
                """
                SELECT a.blob_id, a.manifest_digest, a.link_kind, a.artifact_digest
                FROM runtime_attachment_receipt_links AS a
                WHERE a.receipt_id = ? AND a.revision_id = ?
                  AND a.link_kind NOT IN ('finalization_intent','finalization')
                ORDER BY a.link_kind LIMIT 2
                """,
                bindings: [.text(receiptID.rawValue), .text(revisionID.rawValue)],
                database: database
            )
            guard links.count == 1,
                  case let .text(blobRaw)? = links[0].value(named: "blob_id"),
                  let blobID = RuntimeBlobID(rawValue: blobRaw),
                  case let .text(manifestDigest)? = links[0].value(named: "manifest_digest"),
                  case let .text(linkKind)? = links[0].value(named: "link_kind"),
                  linkKind == "reference",
                  case let .text(artifactDigest)? = links[0].value(named: "artifact_digest"),
                  receipt.core.facts.artifacts.contains(where: {
                      $0.kind == .attachmentRevision &&
                          $0.stableID == "\(revisionID.rawValue)#\(linkKind)" &&
                          $0.digest == artifactDigest
                  }),
                  RuntimeStoreManifestCodec.isSHA256Hex(manifestDigest) else {
                throw RuntimeCanonicalAttachmentError.quarantined
            }
            return RuntimeAuthenticatedAttachmentReadAuthority(
                revisionID: revisionID, blobID: blobID,
                manifestDigest: manifestDigest,
                privacy: receipt.core.facts.privacy.classification,
                receiptID: receiptID,
                commandID: receipt.core.facts.commandID,
                lineage: receipt.core.facts.lineage,
                authenticatedAt: observedAt
            )
        }
    }

    private static func constantTimeEquals(_ lhs: Data, _ rhs: Data) -> Bool {
        guard lhs.count == rhs.count else { return false }
        var difference: UInt8 = 0
        for index in lhs.indices {
            difference |= lhs[index] ^ rhs[index]
        }
        return difference == 0
    }
}

actor RuntimeAttachmentQueryService {
    private let store: CanonicalRuntimeStore
    private let vault: RuntimeAttachmentVault
    private let accessAuthority: RuntimeAttachmentAccessAuthority
    private let holdID: @Sendable () -> RuntimeBlobHoldID
    private let clock: @Sendable () -> Date

    init(
        store: CanonicalRuntimeStore,
        vault: RuntimeAttachmentVault,
        accessAuthority: RuntimeAttachmentAccessAuthority,
        holdID: @escaping @Sendable () -> RuntimeBlobHoldID = {
            RuntimeBlobHoldID(rawValue: UUID().uuidString.lowercased())!
        },
        clock: @escaping @Sendable () -> Date = Date.init
    ) {
        self.store = store
        self.vault = vault
        self.accessAuthority = accessAuthority
        self.holdID = holdID
        self.clock = clock
    }

    func readPage(
        grant: RuntimeAttachmentReadGrant,
        cursor: RuntimeAttachmentReadCursor?
    ) async throws -> RuntimeAttachmentReadPage {
        let authority = try await accessAuthority.authenticatedAuthority(
            grant: grant, allowedPurpose: .interactiveObjectDetail
        )
        if let cursor, cursor.nextChunkIndex <= 0 {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        let holdID = holdID()
        let holdAuthorityID = "read-grant:\(grant.receiptID.rawValue):\(holdID.rawValue)"
        let hold = RuntimeBlobRetentionHold(
            version: runtimeCanonicalAttachmentModelVersion, holdID: holdID,
            blobID: authority.blobID, kind: .receipt,
            authorityID: holdAuthorityID, retainUntil: grant.expiresAt,
            createdAt: authority.authenticatedAt
        )
        let snapshot = try await store.acquireAuthenticatedAttachmentReadHold(
            hold, revisionID: authority.revisionID,
            commandID: authority.commandID, receiptID: authority.receiptID,
            lineage: authority.lineage
        )
        let page: RuntimeAttachmentReadPage
        do {
            page = try await vault.readPage(snapshot: snapshot, cursor: cursor)
        } catch is CancellationError {
            do {
                try await store.releaseAttachmentRetentionHold(
                    holdID: holdID, blobID: hold.blobID, authorityID: holdAuthorityID,
                    commandID: authority.commandID, receiptID: authority.receiptID,
                    lineage: authority.lineage, at: clock()
                )
            } catch {
                // The authenticated hold is finite. Cancellation remains the
                // primary outcome even when immediate release cannot complete.
            }
            throw CancellationError()
        } catch {
            let readError = error
            do {
                try await store.releaseAttachmentRetentionHold(
                    holdID: holdID, blobID: hold.blobID, authorityID: holdAuthorityID,
                    commandID: authority.commandID, receiptID: authority.receiptID,
                    lineage: authority.lineage, at: clock()
                )
            } catch {
                throw RuntimeCanonicalAttachmentError.retentionHoldReleasePending
            }
            throw readError
        }
        do {
            try await store.releaseAttachmentRetentionHold(
                holdID: holdID, blobID: hold.blobID, authorityID: holdAuthorityID,
                commandID: authority.commandID, receiptID: authority.receiptID,
                lineage: authority.lineage, at: clock()
            )
        } catch is CancellationError {
            // No result has crossed this boundary. The finite hold remains
            // recoverable and cancellation must not be represented as success.
            throw CancellationError()
        } catch {
            throw RuntimeCanonicalAttachmentError.retentionHoldReleasePending
        }
        return page
    }
}

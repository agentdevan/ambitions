import Darwin
import Foundation
import XCTest
@testable import Ambitions

final class RuntimeAttachmentVaultTests: XCTestCase {
    func testOnlyOneVaultInstanceCanOwnAStorageRootAtATime() throws {
        let root = try XCTAttachmentFixtures.directory("single-owner")
        let first = try XCTAttachmentFixtures.vault(root: root, token: "first-owner")
        withExtendedLifetime(first) {
            do {
                _ = try XCTAttachmentFixtures.vault(root: root, token: "second-owner")
                XCTFail("A second vault must not acquire the same process storage authority")
            } catch let error as RuntimeCanonicalAttachmentError {
                XCTAssertEqual(error, .lifecycleConflict)
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testChunkedVaultRoundTripUsesAuthenticatedPaginationAndExactTerminalLength() async throws {
        let root = try XCTAttachmentFixtures.directory("round-trip")
        let vault = try XCTAttachmentFixtures.vault(root: root)
        let expected = Data((0..<40_000).map { UInt8($0 % 251) })
        let (bundle, _) = try await XCTAttachmentFixtures.stage(vault: vault, root: root, bytes: expected)
        var cursor: RuntimeAttachmentReadCursor?
        var actual = Data()
        repeat {
            let page = try await vault.readPage(graph: XCTAttachmentFixtures.graph(bundle), cursor: cursor)
            actual.append(page.bytes)
            cursor = page.nextCursor
        } while cursor != nil

        XCTAssertEqual(actual, expected)
        XCTAssertEqual(bundle.manifest.chunkCount, 3)
        XCTAssertEqual(bundle.manifest.plaintextByteCount, Int64(expected.count))
        XCTAssertGreaterThan(bundle.manifest.ciphertextByteCount, bundle.manifest.plaintextByteCount)
        try await vault.verifyAuthenticatedBlob(XCTAttachmentFixtures.graph(bundle))
    }

    func testCiphertextTamperingIsRejectedByPerChunkAuthentication() async throws {
        let fixture = try await makeFixture("tamper")
        let payload = XCTAttachmentFixtures.payloadURL(root: fixture.root, manifest: fixture.bundle.manifest)
        var bytes = try Data(contentsOf: payload)
        let firstCiphertext = firstChunkRange(bytes).lowerBound
        bytes[firstCiphertext] ^= 0xff
        try bytes.write(to: payload)

        await assertAttachmentError(.chunkAuthenticationFailed) {
            _ = try await fixture.vault.readPage(graph: XCTAttachmentFixtures.graph(fixture.bundle))
        }
    }

    func testTruncatedPayloadIsRejectedWithoutReturningTerminalSuccess() async throws {
        let fixture = try await makeFixture("truncated")
        let payload = XCTAttachmentFixtures.payloadURL(root: fixture.root, manifest: fixture.bundle.manifest)
        var bytes = try Data(contentsOf: payload)
        bytes.removeLast()
        try bytes.write(to: payload)

        await assertAttachmentError(.manifestInvalid) {
            try await fixture.vault.verifyAuthenticatedBlob(XCTAttachmentFixtures.graph(fixture.bundle))
        }
    }

    func testChunkReorderingCannotAuthenticateUnderIndexBoundAAD() async throws {
        let fixture = try await makeFixture("reordered")
        let payload = XCTAttachmentFixtures.payloadURL(root: fixture.root, manifest: fixture.bundle.manifest)
        let original = try Data(contentsOf: payload)
        let frames = chunkFrames(original)
        XCTAssertGreaterThanOrEqual(frames.count, 2)
        var reordered = original.prefix(frames[0].lowerBound)
        reordered.append(original[frames[1]])
        reordered.append(original[frames[0]])
        for frame in frames.dropFirst(2) { reordered.append(original[frame]) }
        try Data(reordered).write(to: payload)

        await assertAttachmentError(.chunkAuthenticationFailed) {
            _ = try await fixture.vault.readPage(graph: XCTAttachmentFixtures.graph(fixture.bundle))
        }
    }

    func testHeaderMutationIsRejectedBeforeAnyPlaintextIsReleased() async throws {
        let fixture = try await makeFixture("header")
        let payload = XCTAttachmentFixtures.payloadURL(root: fixture.root, manifest: fixture.bundle.manifest)
        var bytes = try Data(contentsOf: payload)
        bytes[4] ^= 0x01
        try bytes.write(to: payload)

        await assertAttachmentError(.manifestInvalid) {
            _ = try await fixture.vault.readPage(graph: XCTAttachmentFixtures.graph(fixture.bundle))
        }
    }

    func testTerminalDigestRejectsTrailingOrSubstitutedCiphertext() async throws {
        let fixture = try await makeFixture("terminal")
        let payload = XCTAttachmentFixtures.payloadURL(root: fixture.root, manifest: fixture.bundle.manifest)
        let handle = try FileHandle(forWritingTo: payload)
        try handle.seekToEnd()
        try handle.write(contentsOf: Data([0]))
        try handle.close()

        await assertAttachmentError(.manifestInvalid) {
            try await fixture.vault.verifyAuthenticatedBlob(XCTAttachmentFixtures.graph(fixture.bundle))
        }
    }

    func testEnvelopeMutationCannotRecoverTheDataEncryptionKey() async throws {
        let fixture = try await makeFixture("envelope")
        var wrapped = fixture.bundle.envelope.wrappedDataEncryptionKey
        wrapped[wrapped.startIndex] ^= 0xff
        let invalid = RuntimeBlobKeyEnvelope(
            version: fixture.bundle.envelope.version, blobID: fixture.bundle.envelope.blobID,
            wrappingKeyID: fixture.bundle.envelope.wrappingKeyID,
            wrappingKeyVersion: fixture.bundle.envelope.wrappingKeyVersion,
            algorithm: fixture.bundle.envelope.algorithm, nonce: fixture.bundle.envelope.nonce,
            wrappedDataEncryptionKey: wrapped,
            envelopeDigest: fixture.bundle.envelope.envelopeDigest
        )
        await assertAttachmentError(.keyEnvelopeInvalid) {
            _ = try await fixture.vault.readPage(
                graph: XCTAttachmentFixtures.graph(fixture.bundle, envelope: invalid)
            )
        }
    }

    func testReadCursorRejectsCrossBlobAndOutOfRangeAuthority() async throws {
        let fixture = try await makeFixture("cursor")
        let foreign = RuntimeAttachmentReadCursor(
            blobID: RuntimeBlobID(rawValue: "foreign-blob")!, nextChunkIndex: 1,
            plaintextBytesRead: Int64(RuntimeAttachmentLimits.minimumChunkBytes)
        )
        await assertAttachmentError(.invalidRecord) {
            _ = try await fixture.vault.readPage(
                graph: XCTAttachmentFixtures.graph(fixture.bundle), cursor: foreign
            )
        }
        let beyondTerminal = RuntimeAttachmentReadCursor(
            blobID: fixture.bundle.manifest.blobID,
            nextChunkIndex: fixture.bundle.manifest.chunkCount,
            plaintextBytesRead: fixture.bundle.manifest.plaintextByteCount
        )
        await assertAttachmentError(.invalidRecord) {
            _ = try await fixture.vault.readPage(
                graph: XCTAttachmentFixtures.graph(fixture.bundle), cursor: beyondTerminal
            )
        }
    }

    func testOpaquePathTraversalAndInvalidTokensAreDenied() async throws {
        XCTAssertFalse(RuntimeAttachmentCodec.validOpaqueDirectory("../outside"))
        XCTAssertFalse(RuntimeAttachmentCodec.validOpaqueDirectory("/absolute/path"))

        let root = try XCTAttachmentFixtures.directory("path-stage")
        let vault = try XCTAttachmentFixtures.vault(root: root, token: "../escape")
        await assertAttachmentError(.pathAuthorityDenied) {
            _ = try await XCTAttachmentFixtures.stage(vault: vault, root: root)
        }
    }

    func testSymbolicLinkSourceAndOwnedDirectoryAreDenied() async throws {
        let root = try XCTAttachmentFixtures.directory("symlink")
        let vault = try XCTAttachmentFixtures.vault(root: root)
        let real = root.appendingPathComponent("real.bin")
        let link = root.appendingPathComponent("link.bin")
        try Data(repeating: 1, count: 20_000).write(to: real)
        try FileManager.default.createSymbolicLink(at: link, withDestinationURL: real)
        let request = try stageRequest(source: link, size: 20_000)
        await assertAttachmentError(.pathAuthorityDenied) { _ = try await vault.stage(request) }

        let (bundle, _) = try await XCTAttachmentFixtures.stage(
            vault: vault, root: root, blob: "blob-owned-symlink",
            attachment: "attachment-owned-symlink", revision: "revision-owned-symlink"
        )
        let owned = root.appendingPathComponent(bundle.manifest.opaqueRelativeDirectory)
        let relocated = root.appendingPathComponent("relocated")
        try FileManager.default.moveItem(at: owned, to: relocated)
        try FileManager.default.createSymbolicLink(at: owned, withDestinationURL: relocated)
        await assertAttachmentError(.pathAuthorityDenied) {
            _ = try await vault.ownedBlobExists(bundle.manifest)
        }
    }

    func testStageRejectsEmptyOversizedAndMismatchedFileAuthority() async throws {
        let root = try XCTAttachmentFixtures.directory("size")
        let vault = try XCTAttachmentFixtures.vault(root: root)
        let empty = root.appendingPathComponent("empty.bin")
        try Data().write(to: empty)
        await assertAttachmentError(.invalidRecord) {
            _ = try await vault.stage(try self.stageRequest(source: empty, size: 0))
        }
        let source = root.appendingPathComponent("small.bin")
        try Data(repeating: 7, count: 20_000).write(to: source)
        await assertAttachmentError(.fileIdentityChanged) {
            _ = try await vault.stage(try self.stageRequest(source: source, size: 20_001))
        }
        await assertAttachmentError(.invalidRecord) {
            _ = try await vault.stage(try self.stageRequest(
                source: source, size: RuntimeAttachmentLimits.maximumAttachmentBytes + 1
            ))
        }
    }

    func testStageRejectsPathReplacementAfterAuthenticatedIntakeProof() async throws {
        let root = try XCTAttachmentFixtures.directory("proof-replacement")
        let vault = try XCTAttachmentFixtures.vault(root: root)
        let source = root.appendingPathComponent("replace.bin")
        let displaced = root.appendingPathComponent("replace-original.bin")
        let bytes = Data(repeating: 0x61, count: 20_000)
        try bytes.write(to: source)
        let request = try stageRequest(source: source, size: Int64(bytes.count))
        try FileManager.default.moveItem(at: source, to: displaced)
        try bytes.write(to: source)

        await assertAttachmentError(.fileIdentityChanged) {
            _ = try await vault.stage(request)
        }
    }

    func testStageRejectsHardLinkedPlaintextEvenWhenProofMatchesTheInode() async throws {
        let root = try XCTAttachmentFixtures.directory("proof-hardlink")
        let vault = try XCTAttachmentFixtures.vault(root: root)
        let source = root.appendingPathComponent("linked-source.bin")
        let alias = root.appendingPathComponent("linked-alias.bin")
        let bytes = Data(repeating: 0x62, count: 20_000)
        try bytes.write(to: source)
        let request = try stageRequest(source: source, size: Int64(bytes.count))
        guard Darwin.link(source.path, alias.path) == 0 else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }

        await assertAttachmentError(.pathAuthorityDenied) {
            _ = try await vault.stage(request)
        }
    }

    func testMalformedRawStagingNameCountsAgainstCapacityWithoutDenyingValidStage() async throws {
        let root = try XCTAttachmentFixtures.directory("raw-capacity")
        let vault = try XCTAttachmentFixtures.vault(root: root)
        try XCTAttachmentFixtures.createRawNamedFile(
            in: root, nameBytes: Array(".staging-".utf8) + [0xff]
        )

        let (bundle, _) = try await XCTAttachmentFixtures.stage(
            vault: vault, root: root, blob: "blob-raw-capacity",
            attachment: "attachment-raw-capacity", revision: "revision-raw-capacity"
        )
        XCTAssertEqual(bundle.manifest.blobID.rawValue, "blob-raw-capacity")
    }

    func testCancelledStageDoesNotPublishOwnedBlobAuthority() async throws {
        let root = try XCTAttachmentFixtures.directory("cancel")
        let vault = try XCTAttachmentFixtures.vault(root: root)
        let source = root.appendingPathComponent("cancel.bin")
        try Data(repeating: 8, count: 20_000).write(to: source)
        let task = Task {
            try await vault.stage(try stageRequest(source: source, size: 20_000))
        }
        task.cancel()
        do {
            _ = try await task.value
            XCTFail("Cancelled attachment staging must not report success")
        } catch is CancellationError {
            XCTAssertTrue(true)
        }
        let ownedDirectories = try await vault.ownedManifestDirectories(limit: 10)
        XCTAssertTrue(ownedDirectories.entries.isEmpty)
    }

    func testClaimedOrphanDeletionAuthenticatesManifestAndCapturedDirectoryIdentity() async throws {
        let fixture = try await makeFixture("delete")
        let inspection = try await fixture.vault.inspectOwnedManifest(fixture.bundle.manifest)
        let claim = RuntimeAttachmentManifestDeletionClaim(
            claimID: RuntimeAttachmentCodec.sha256(Data("claimed-orphan-delete".utf8)),
            blobID: inspection.manifest.blobID,
            manifestDigest: inspection.manifestDigest,
            opaqueRelativeDirectory: inspection.manifest.opaqueRelativeDirectory,
            observedDevice: inspection.directoryDevice,
            observedInode: inspection.directoryInode,
            claimedAt: XCTAttachmentFixtures.now,
            expiresAt: XCTAttachmentFixtures.now.addingTimeInterval(60),
            stateVersion: 1
        )
        let directory = fixture.root.appendingPathComponent(
            fixture.bundle.manifest.opaqueRelativeDirectory, isDirectory: true
        )
        try Data([1]).write(to: directory.appendingPathComponent("unexpected"))
        await assertAttachmentError(.pathAuthorityDenied) {
            _ = try await fixture.vault.prepareUnownedManifestDeletion(
                inspection, claim: claim, now: XCTAttachmentFixtures.now
            )
        }
        try FileManager.default.removeItem(at: directory.appendingPathComponent("unexpected"))
        let vaultClaim = try await fixture.vault.prepareUnownedManifestDeletion(
            inspection, claim: claim, now: XCTAttachmentFixtures.now
        )
        let proof = try await fixture.vault.finalizeUnownedManifestDeletion(
            vaultClaim, now: { XCTAttachmentFixtures.now.addingTimeInterval(1) }
        )
        XCTAssertEqual(proof.manifestDigest, inspection.manifestDigest)
        XCTAssertEqual(proof.directoryDevice, inspection.directoryDevice)
        XCTAssertEqual(proof.directoryInode, inspection.directoryInode)
        XCTAssertNotEqual(proof.directoryDevice, 0)
        XCTAssertNotEqual(proof.directoryInode, 0)
        let exists = try await fixture.vault.ownedBlobExists(fixture.bundle.manifest)
        XCTAssertFalse(exists)
    }

    func testDanglingOwnedDirectorySymlinkCannotProducePhysicalDeletionProof() async throws {
        let fixture = try await makeFixture("dangling-delete-proof")
        let directory = fixture.root.appendingPathComponent(
            fixture.bundle.manifest.opaqueRelativeDirectory, isDirectory: true
        )
        try FileManager.default.removeItem(at: directory)
        try FileManager.default.createSymbolicLink(
            at: directory,
            withDestinationURL: fixture.root.appendingPathComponent("missing-owned-directory")
        )
        let lease = RuntimeBlobGCLease(
            version: runtimeCanonicalAttachmentModelVersion,
            leaseID: RuntimeBlobGCLeaseID(rawValue: "lease-dangling-proof")!,
            blobID: fixture.bundle.manifest.blobID,
            expectedStateVersion: 1,
            ownerID: "vault-tests",
            acquiredAt: XCTAttachmentFixtures.now,
            expiresAt: XCTAttachmentFixtures.now.addingTimeInterval(60)
        )

        await assertAttachmentError(.pathAuthorityDenied) {
            _ = try await fixture.vault.prepareLeaseOwnedDeletion(
                RuntimeBlobGCWork(
                    revisionID: fixture.bundle.revision.revisionID,
                    manifest: fixture.bundle.manifest,
                    manifestDigest: fixture.bundle.revision.manifestDigest,
                    lifecycle: fixture.bundle.lifecycle,
                    deletionAuthorizationID: "vault-test"
                ),
                lease: lease,
                now: XCTAttachmentFixtures.now
            )
        }
        var metadata = stat()
        XCTAssertEqual(lstat(directory.path, &metadata), 0)
        XCTAssertEqual(metadata.st_mode & S_IFMT, S_IFLNK)
    }

    private func makeFixture(_ label: String) async throws -> (
        root: URL, vault: RuntimeAttachmentVault, bundle: RuntimeAttachmentStageBundle
    ) {
        let root = try XCTAttachmentFixtures.directory(label)
        let vault = try XCTAttachmentFixtures.vault(root: root)
        let (bundle, _) = try await XCTAttachmentFixtures.stage(vault: vault, root: root)
        return (root, vault, bundle)
    }

    private func stageRequest(
        source: URL,
        size: Int64
    ) throws -> RuntimeAttachmentVaultStageRequest {
        var metadata = stat()
        let isRegular = Darwin.stat(source.path, &metadata) == 0 &&
            (metadata.st_mode & S_IFMT) == S_IFREG && metadata.st_size > 0
        #if os(iOS)
        if isRegular {
            try FileManager.default.setAttributes(
                [.protectionKey: FileProtectionType.complete], ofItemAtPath: source.path
            )
        }
        #endif
        let revisionID = RuntimeAttachmentRevisionID(rawValue: "revision-direct-stage")!
        let blobID = RuntimeBlobID(rawValue: "blob-direct-stage")!
        let classification = RuntimeAttachmentContentClassification(
            normalizedFilename: "direct.bin",
            declaredContentType: "application/octet-stream",
            detectedContentType: "application/octet-stream",
            signatureVersion: 1,
            byteCount: size
        )
        let proof: RuntimeAttachmentValidatedIntakeProof
        if isRegular, size > 0, size <= RuntimeAttachmentLimits.maximumAttachmentBytes,
           let bytes = try? Data(contentsOf: source) {
            proof = try RuntimeAttachmentCodec.issueIntakeProof(
                revisionID: revisionID, blobID: blobID,
                ownedFilename: source.lastPathComponent,
                sourceDevice: UInt64(metadata.st_dev), sourceInode: UInt64(metadata.st_ino),
                device: UInt64(metadata.st_dev), inode: UInt64(metadata.st_ino),
                byteCount: size,
                plaintextDigest: RuntimeAttachmentCodec.sha256(bytes),
                classification: classification,
                issuedAt: XCTAttachmentFixtures.now,
                key: XCTAttachmentFixtures.intakeProofKey
            )
        } else {
            proof = RuntimeAttachmentValidatedIntakeProof(
                version: 1, revisionID: revisionID, blobID: blobID,
                ownedFilename: source.lastPathComponent,
                sourceDevice: 0, sourceInode: 0,
                device: 0, inode: 0, byteCount: size,
                plaintextDigest: String(repeating: "0", count: 64),
                classification: classification, protectionClass: .complete,
                issuedAt: XCTAttachmentFixtures.now, authenticationCode: Data()
            )
        }
        return RuntimeAttachmentVaultStageRequest(
            attachmentID: RuntimeAttachmentID(rawValue: "attachment-direct-stage")!,
            revisionID: revisionID, revision: 1,
            blobID: blobID, ownedPlaintextURL: source, intakeProof: proof,
            normalizedFilename: "direct.bin", declaredContentType: "application/octet-stream",
            detectedContentType: "application/octet-stream", privacy: .sensitive,
            dedupPolicy: .withinPrivacyDomain, provenance: XCTAttachmentFixtures.provenance(),
            reservationID: RuntimeBlobQuotaReservationID(rawValue: "reservation-direct-stage")!,
            expectedByteCount: size, retentionUntil: nil, createdAt: XCTAttachmentFixtures.now
        )
    }

    private func firstChunkRange(_ payload: Data) -> Range<Int> { chunkFrames(payload)[0].dropFirst(4) }

    private func chunkFrames(_ payload: Data) -> [Range<Int>] {
        let headerLength = readUInt32(payload, at: 0)
        var offset = 4 + headerLength
        var result: [Range<Int>] = []
        while offset < payload.count {
            let length = readUInt32(payload, at: offset)
            guard length > 0, offset + 4 + length <= payload.count else { break }
            result.append(offset..<(offset + 4 + length))
            offset += 4 + length
        }
        return result
    }

    private func readUInt32(_ data: Data, at offset: Int) -> Int {
        data[offset..<(offset + 4)].reduce(0) { ($0 << 8) | Int($1) }
    }

    private func assertAttachmentError(
        _ expected: RuntimeCanonicalAttachmentError,
        operation: () async throws -> Void
    ) async {
        do {
            try await operation()
            XCTFail("Expected \(expected)")
        } catch let actual as RuntimeCanonicalAttachmentError {
            XCTAssertEqual(actual, expected)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

private extension Range where Bound == Int {
    var dropFirst: Range<Int> { (lowerBound + 4)..<upperBound }
}

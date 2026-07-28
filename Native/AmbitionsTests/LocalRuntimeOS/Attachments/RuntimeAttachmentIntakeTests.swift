import Darwin
import Foundation
import XCTest
@testable import Ambitions

final class RuntimeAttachmentIntakeTests: XCTestCase {
    func testTextIntakeCopiesIntoOwnedBoundaryClassifiesAndStagesWithoutSourceMutation() async throws {
        let fixture = try makeFixture("text")
        let source = fixture.root.appendingPathComponent("source.txt")
        let bytes = Data("private local-first evidence\n".utf8)
        try bytes.write(to: source)
        let before = try Data(contentsOf: source)

        let result = await fixture.intake.stage(parts: [part(source: source, filename: "  source.txt  ")])

        XCTAssertFalse(result.wasCancelled)
        XCTAssertEqual(result.staged.count, 1)
        XCTAssertEqual(result.staged[0].revision.classification.normalizedFilename, "source.txt")
        XCTAssertEqual(result.staged[0].revision.classification.detectedContentType, "text/plain")
        XCTAssertEqual(result.staged[0].revision.classification.byteCount, Int64(bytes.count))
        XCTAssertEqual(try Data(contentsOf: source), before)
        XCTAssertTrue(try FileManager.default.contentsOfDirectory(atPath: fixture.intakeRoot.path).isEmpty)
    }

    func testSignatureAndDeclaredMIMEConflictIsQuarantinedWithoutPublishingVaultManifest() async throws {
        let fixture = try makeFixture("mime-conflict")
        let source = fixture.root.appendingPathComponent("image.png")
        try Data([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 1, 2, 3]).write(to: source)

        let result = await fixture.intake.stage(parts: [
            part(source: source, filename: "image.png", contentType: "text/plain")
        ])

        guard case let .quarantined(_, reason, fingerprint) = result.parts.first else {
            return XCTFail("MIME/signature conflict must be explicitly quarantined")
        }
        XCTAssertEqual(reason, .contentTypeMismatch)
        XCTAssertTrue(RuntimeStoreManifestCodec.isSHA256Hex(fingerprint))
        let owned = try await fixture.vault.ownedManifestDirectories(limit: 10)
        XCTAssertTrue(owned.entries.isEmpty)
    }

    func testUnknownSignatureIsQuarantinedAsSignatureMismatch() async throws {
        let fixture = try makeFixture("signature")
        let source = fixture.root.appendingPathComponent("opaque.dat")
        try Data(repeating: 0x01, count: 128).write(to: source)
        let result = await fixture.intake.stage(parts: [
            part(source: source, filename: "opaque.dat", contentType: "text/plain")
        ])
        guard case let .quarantined(_, reason, _) = result.parts.first else {
            return XCTFail("Unrecognized source must not be staged")
        }
        XCTAssertEqual(reason, .signatureMismatch)
    }

    func testExtensionAloneCannotAuthorizeAnUnsupportedPayloadSignature() async throws {
        let fixture = try makeFixture("extension-only")
        let source = fixture.root.appendingPathComponent("forged.png")
        try Data(repeating: 0x41, count: 128).write(to: source)
        let result = await fixture.intake.stage(parts: [
            part(source: source, filename: "forged.png", contentType: "image/png")
        ])
        guard case let .quarantined(_, reason, _) = result.parts.first else {
            return XCTFail("A filename extension must not act as content-signature authority")
        }
        XCTAssertEqual(reason, .signatureMismatch)
    }

    func testPlainTextRequiresCompleteStrictUTF8Validation() async throws {
        let fixture = try makeFixture("invalid-utf8")
        let source = fixture.root.appendingPathComponent("invalid.txt")
        try Data([0x66, 0x6f, 0x80, 0x6f]).write(to: source)
        let result = await fixture.intake.stage(parts: [part(source: source, filename: "invalid.txt")])
        guard case let .quarantined(_, reason, _) = result.parts.first else {
            return XCTFail("Malformed UTF-8 must not enter the encrypted vault")
        }
        XCTAssertEqual(reason, .signatureMismatch)
    }

    func testFailedAuthorizedIntakeReleasesQuotaAuthorization() async throws {
        let fixture = try makeFixture("quota-release")
        let source = fixture.root.appendingPathComponent("invalid.txt")
        try Data([0xff, 0xfe]).write(to: source)

        _ = await fixture.intake.stage(parts: [part(source: source, filename: "invalid.txt")])

        let released = await fixture.quotaAuthorizer.releasedReservationIDs()
        XCTAssertEqual(released, [RuntimeBlobQuotaReservationID(rawValue: "reservation-intake")!])
    }

    func testSizeLimitProducesPerPartQuarantineAndAllowsIndependentLaterPart() async throws {
        let fixture = try makeFixture("multi-part")
        let large = fixture.root.appendingPathComponent("large.txt")
        let valid = fixture.root.appendingPathComponent("valid.txt")
        try Data(repeating: 0x61, count: 30_000).write(to: large)
        try Data("valid".utf8).write(to: valid)
        let result = await fixture.intake.stage(parts: [
            part(source: large, filename: "large.txt", maximumBytes: 1_000),
            part(
                source: valid, filename: "valid.txt", attachment: "attachment-valid",
                revision: "revision-valid", blob: "blob-valid", reservation: "reservation-valid"
            ),
        ])

        XCTAssertEqual(result.parts.count, 2)
        guard case let .quarantined(_, firstReason, _) = result.parts[0] else {
            return XCTFail("Oversized part must be quarantined")
        }
        XCTAssertEqual(firstReason, .sizeLimitExceeded)
        guard case .staged = result.parts[1] else {
            return XCTFail("An independent later part must remain stageable")
        }
    }

    func testFilenameNormalizationCannotEscapeIntakeRoot() async throws {
        let fixture = try makeFixture("filename")
        let source = fixture.root.appendingPathComponent("valid.txt")
        try Data("valid".utf8).write(to: source)
        let result = await fixture.intake.stage(parts: [
            part(source: source, filename: "../../private\u{0}record.txt")
        ])
        guard case let .staged(bundle, _) = result.parts.first else {
            return XCTFail("A safe basename should be derived without retaining path authority")
        }
        XCTAssertEqual(bundle.revision.classification.normalizedFilename, "private-record.txt")
        XCTAssertFalse(bundle.revision.classification.normalizedFilename.contains(".."))
        XCTAssertFalse(bundle.revision.classification.normalizedFilename.contains("/"))
    }

    func testSymbolicLinkSourceIsQuarantinedAtTheBoundary() async throws {
        let fixture = try makeFixture("source-link")
        let source = fixture.root.appendingPathComponent("actual.txt")
        let link = fixture.root.appendingPathComponent("linked.txt")
        try Data("private".utf8).write(to: source)
        try FileManager.default.createSymbolicLink(at: link, withDestinationURL: source)
        let result = await fixture.intake.stage(parts: [part(source: link, filename: "linked.txt")])
        guard case let .quarantined(_, reason, _) = result.parts.first else {
            return XCTFail("A symbolic-link source must not be copied")
        }
        XCTAssertEqual(reason, .pathAuthorityViolation)
    }

    func testCancellationStopsBatchAndDoesNotMislabelUnattemptedPartsAsFailures() async throws {
        let fixture = try makeFixture("cancel")
        let source = fixture.root.appendingPathComponent("cancel.txt")
        try Data(repeating: 0x61, count: 64_000).write(to: source)
        let task = Task { await fixture.intake.stage(parts: [part(source: source, filename: "cancel.txt")]) }
        task.cancel()
        let result = await task.value
        XCTAssertTrue(result.wasCancelled)
        XCTAssertTrue(result.parts.isEmpty)
    }

    func testInterruptedOwnedIntakeFilesUseStableKeysetPagingAndExactRemoval() async throws {
        let fixture = try makeFixture("leftovers")
        try FileManager.default.createDirectory(
            at: fixture.intakeRoot, withIntermediateDirectories: true
        )
        let first = fixture.intakeRoot.appendingPathComponent("intake-a.part")
        let second = fixture.intakeRoot.appendingPathComponent("intake-b.part")
        try Data().write(to: first)
        try Data([1]).write(to: second)

        let pageOne = try await fixture.intake.ownedIntakeLeftovers(limit: 1)
        XCTAssertEqual(pageOne.entries.compactMap {
            if case let .owned(_, url) = $0 { url.lastPathComponent } else { nil }
        }, ["intake-a.part"])
        let cursor = try XCTUnwrap(pageOne.entries.first?.cursorKey)
        let pageTwo = try await fixture.intake.ownedIntakeLeftovers(
            limit: 1, afterCursorKey: cursor
        )
        XCTAssertEqual(pageTwo.entries.compactMap {
            if case let .owned(_, url) = $0 { url.lastPathComponent } else { nil }
        }, ["intake-b.part"])

        try await fixture.intake.removeOwnedIntakeLeftover(first)
        XCTAssertFalse(FileManager.default.fileExists(atPath: first.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: second.path))
    }

    func testInterruptedIntakeCleanupRejectsSymlinksAndPathsOutsideExactRoot() async throws {
        let fixture = try makeFixture("leftover-boundary")
        try FileManager.default.createDirectory(
            at: fixture.intakeRoot, withIntermediateDirectories: true
        )
        let outside = fixture.root.appendingPathComponent("outside.part")
        let linked = fixture.intakeRoot.appendingPathComponent("intake-link.part")
        try Data([1]).write(to: outside)
        try FileManager.default.createSymbolicLink(at: linked, withDestinationURL: outside)

        let malformed = try await fixture.intake.ownedIntakeLeftovers(limit: 10)
        XCTAssertTrue(malformed.entries.contains {
            if case let .malformed(finding) = $0 {
                return finding.error == .pathAuthorityDenied
            }
            return false
        })
        do {
            try await fixture.intake.removeOwnedIntakeLeftover(outside)
            XCTFail("Owned intake recovery must reject paths outside its exact root")
        } catch let error as RuntimeCanonicalAttachmentError {
            XCTAssertEqual(error, .pathAuthorityDenied)
        }
    }

    func testMalformedRawIntakeNameDoesNotDenyIndependentAuthorizedStaging() async throws {
        let fixture = try makeFixture("raw-capacity")
        try XCTAttachmentFixtures.createRawNamedFile(
            in: fixture.intakeRoot,
            nameBytes: Array("intake-".utf8) + [0xff] + Array(".part".utf8)
        )
        let source = fixture.root.appendingPathComponent("valid-after-malformed.txt")
        try Data("valid after malformed namespace entry".utf8).write(to: source)

        let result = await fixture.intake.stage(parts: [part(
            source: source, filename: "valid-after-malformed.txt",
            attachment: "attachment-after-malformed", revision: "revision-after-malformed",
            blob: "blob-after-malformed", reservation: "reservation-after-malformed"
        )])

        XCTAssertEqual(result.staged.count, 1)
        XCTAssertFalse(result.wasCancelled)
    }

    private func makeFixture(_ label: String) throws -> (
        root: URL, intakeRoot: URL, vault: RuntimeAttachmentVault,
        intake: RuntimeAttachmentIntake,
        quotaAuthorizer: RecordingRuntimeAttachmentQuotaAuthorizer
    ) {
        let root = try XCTAttachmentFixtures.directory(label)
        let vaultRoot = root.appendingPathComponent("vault", isDirectory: true)
        let intakeRoot = root.appendingPathComponent("intake", isDirectory: true)
        let vault = try XCTAttachmentFixtures.vault(root: vaultRoot)
        let quotaAuthorizer = RecordingRuntimeAttachmentQuotaAuthorizer()
        let intake = try RuntimeAttachmentIntake(
            intakeRoot: intakeRoot, vault: vault, quotaAuthorizer: quotaAuthorizer,
            intakeProofKey: XCTAttachmentFixtures.intakeProofKey,
            bufferBytes: RuntimeAttachmentLimits.minimumChunkBytes,
            intakeToken: { "intake-test-token" }, clock: { XCTAttachmentFixtures.now }
        )
        return (root, intakeRoot, vault, intake, quotaAuthorizer)
    }

    private func part(
        source: URL,
        filename: String,
        contentType: String = "text/plain",
        maximumBytes: Int64 = RuntimeAttachmentLimits.maximumAttachmentBytes,
        attachment: String = "attachment-intake",
        revision: String = "revision-intake",
        blob: String = "blob-intake",
        reservation: String = "reservation-intake"
    ) -> RuntimeAttachmentIntakePart {
        RuntimeAttachmentIntakePart(
            attachmentID: RuntimeAttachmentID(rawValue: attachment)!,
            revisionID: RuntimeAttachmentRevisionID(rawValue: revision)!, revision: 1,
            blobID: RuntimeBlobID(rawValue: blob)!, sourceURL: source,
            originalFilename: filename, declaredContentType: contentType, privacy: .sensitive,
            dedupPolicy: .withinPrivacyDomain, provenance: XCTAttachmentFixtures.provenance(),
            reservationID: RuntimeBlobQuotaReservationID(rawValue: reservation)!,
            expectedMaximumBytes: maximumBytes, retentionUntil: nil,
            requiresSecurityScopedAccess: false, acceptedAt: XCTAttachmentFixtures.now
        )
    }
}

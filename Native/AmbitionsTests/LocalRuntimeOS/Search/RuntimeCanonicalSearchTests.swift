import Foundation
import AmbitionsRuntimeSQLite
@testable import Ambitions
import XCTest

final class RuntimeCanonicalSearchTests: XCTestCase {
    func testQueryClampsDeliveryAndBindsEveryAccessFilter() throws {
        XCTAssertEqual(RuntimeCanonicalSearchQuery.maximumCandidateCount, 512)
        XCTAssertEqual(RuntimeCanonicalSearchQuery.maximumPostingWork, 8_192)
        let query = RuntimeCanonicalSearchQuery(
            text: " Goal goal ", allowedPrivacy: [.privateUserText],
            families: [.goal], deliveryCount: Int.max
        )
        XCTAssertEqual(query.deliveryCount, RuntimeCanonicalSearchQuery.maximumDeliveryCount)
        XCTAssertEqual(query.normalizedTokens, ["goal"])

        let cursor = RuntimeCanonicalSearchCursor(
            generationID: String(repeating: "a", count: 64),
            queryDigest: query.queryDigest, filterDigest: query.filterDigest,
            aggregateKind: .goal, aggregateID: try RuntimeAggregateID(validating: "goal-1")
        )
        XCTAssertTrue(cursor.isBound(to: cursor.generationID, query: query))
        XCTAssertFalse(cursor.isBound(to: String(repeating: "b", count: 64), query: query))
        XCTAssertFalse(cursor.isBound(
            to: cursor.generationID,
            query: RuntimeCanonicalSearchQuery(
                text: "goal", allowedPrivacy: [.standard], families: [.goal]
            )
        ))
    }

    func testTokenizerNormalizesCanonicalUnicodeAndBoundsUTF8Tokens() {
        XCTAssertEqual(
            RuntimeCanonicalSearchTokenizer.tokens(
                "CAFÉ cafe\u{301} 猫", maximumCount: 8
            ),
            ["café", "café", "猫"]
        )
        let oversized = String(repeating: "é", count: 128)
        let token = RuntimeCanonicalSearchTokenizer.tokens(
            oversized, maximumCount: 1
        ).first
        XCTAssertEqual(token?.first, "~")
        XCTAssertLessThanOrEqual(token?.utf8.count ?? .max, 128)
        XCTAssertFalse(RuntimeCanonicalSearchQuery(
            text: String(repeating: "a", count: 2_049),
            allowedPrivacy: [.standard], families: [.goal]
        ).inputIsSupported)
        let overflowingQuery = RuntimeCanonicalSearchQuery(
            text: (0..<17).map { "token\($0)" }.joined(separator: " "),
            allowedPrivacy: [.standard], families: [.goal]
        )
        XCTAssertFalse(overflowingQuery.inputIsSupported)
        XCTAssertTrue(overflowingQuery.normalizedTokens.isEmpty)
        let overflowingField = RuntimeCanonicalSearchTokenizer.tokenize(
            (0..<65).map { "field\($0)" }.joined(separator: " "), maximumCount: 64
        )
        XCTAssertTrue(overflowingField.exceededMaximumCount)
        XCTAssertEqual(overflowingField.tokens.count, 64)
    }

    func testMetadataExtractorPublishesOnlyAggregateKind() throws {
        let entry = try makeEntry()
        let metadata = try RuntimeCanonicalSearchMetadataExtractor.extract(
            entry: entry, allowedFields: [.aggregateKind]
        )
        XCTAssertEqual(metadata.title, "goal")
        XCTAssertEqual(metadata.body, "")
    }

    func testDocumentDigestBindsGenerationAggregatePrivacyAndSource() throws {
        let entry = try makeEntry()
        let generationID = String(repeating: "a", count: 64)
        let digest = RuntimeCanonicalSearchDocument.authorityDigest(
            generationID: generationID, aggregate: entry.aggregate,
            privacy: entry.privacy, localOnly: true, title: "goal", body: "",
            sourceCursor: entry.sourceCursor
        )
        let changed = RuntimeCanonicalSearchDocument.authorityDigest(
            generationID: generationID, aggregate: entry.aggregate,
            privacy: .sensitive, localOnly: true, title: "goal", body: "",
            sourceCursor: entry.sourceCursor
        )
        XCTAssertNotEqual(digest, changed)
    }

    func testSearchGenerationCertificateBindsDeclaredCoverage() throws {
        let definition = try XCTUnwrap(
            RuntimeCanonicalProjectionDefinitionRegistry.canonical().definitions[.search]
        )
        let cursor = makeCursor()
        let certificate = CanonicalRuntimeStore.canonicalSearchGenerationCertificateDigest(
            generationID: String(repeating: "a", count: 64),
            projectionGenerationID: String(repeating: "b", count: 64),
            coverage: .aggregateKindOnly,
            definitionDigest: definition.authorityDigest, sourceCursor: cursor,
            documentCount: 0, postingCount: 0, postingBytes: 0, shardCount: 0,
            rootDigest: RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal
        )
        XCTAssertEqual(certificate.count, 64)
        XCTAssertEqual(RuntimeCanonicalSearchCoverage.aggregateKindOnly.rawValue,
                       "aggregate_kind_only")
    }

    func testActionTokenCarriesCoverageAndGenerationAuthority() throws {
        let entry = try makeEntry()
        let definition = try XCTUnwrap(
            RuntimeCanonicalProjectionDefinitionRegistry.canonical().definitions[.search]
        )
        let query = RuntimeCanonicalSearchQuery(
            text: "goal", allowedPrivacy: [.standard], families: [.goal]
        )
        let generationID = String(repeating: "a", count: 64)
        let digest = RuntimeCanonicalSearchDocument.authorityDigest(
            generationID: generationID, aggregate: entry.aggregate,
            privacy: entry.privacy, localOnly: true, title: "goal", body: "",
            sourceCursor: entry.sourceCursor
        )
        let document = RuntimeCanonicalSearchDocument(
            generationID: generationID, aggregate: entry.aggregate,
            privacy: entry.privacy, localOnly: true, title: "goal", body: "",
            sourceCursor: entry.sourceCursor, digest: digest
        )
        let result = RuntimeCanonicalSearchResult(document: document)
        let authority = RuntimeCanonicalGenerationAuthority(
            projectionID: .search, generationID: String(repeating: "b", count: 64),
            definitionDigest: definition.authorityDigest,
            outputVersion: definition.outputVersion,
            sourceCursor: entry.sourceCursor,
            sourceChainDigest: String(repeating: "c", count: 64), entryCount: 1,
            entryRootDigest: String(repeating: "d", count: 64),
            privacyClasses: [.standard], localOnly: true,
            certificateDigest: String(repeating: "e", count: 64),
            fingerprint: String(repeating: "f", count: 64)
        )
        let truth = RuntimeCanonicalProjectionTruth(
            state: .available, authority: authority,
            expectedDefinitionVersion: definition.definitionVersion,
            sourceCursor: authority.sourceCursor, digest: authority.certificateDigest,
            repairEligible: false, reasonCode: nil
        )
        let page = RuntimeCanonicalSearchPage(
            generationID: generationID, coverage: .aggregateKindOnly,
            projectionCursor: entry.sourceCursor,
            projectionDigest: authority.certificateDigest, results: [result],
            nextCursor: nil, truth: truth,
            authorityFingerprint: String(repeating: "1", count: 64)
        )
        let token = try page.actionToken(for: result, query: query, definition: definition)
        XCTAssertEqual(token.coverage, .aggregateKindOnly)
        XCTAssertEqual(token.aggregate, entry.aggregate)
        XCTAssertEqual(token.accessPolicyDigest, query.accessPolicyDigest)
    }

    func testRelationalSearchSchemaHasPostingAndImmutabilityOwnership() {
        let sql = CanonicalRuntimeProjectionSchemaPlan.statements.joined(separator: "\n")
        XCTAssertTrue(sql.contains("runtime_canonical_search_postings"))
        XCTAssertFalse(sql.contains("runtime_canonical_search_token_stats"))
        XCTAssertTrue(sql.contains("runtime_canonical_search_postings_immutable_update"))
        XCTAssertTrue(sql.contains("runtime_canonical_search_documents_immutable_update"))
        XCTAssertTrue(sql.contains("aggregate_kind_only"))
        XCTAssertFalse(sql.contains("bm25"))
        XCTAssertFalse(sql.contains("CREATE VIRTUAL TABLE"))
    }

    func testDatabasePostingParityRejectsOmissionOrForgery() async throws {
        let database = try SQLiteDatabase(
            url: FileManager.default.temporaryDirectory.appendingPathComponent(
                "runtime-search-postings-\(UUID().uuidString).sqlite"
            )
        )
        try await database.transaction(.exclusive) { isolated in
            for statement in CanonicalRuntimeStore.schemaStatements +
                CanonicalRuntimeProjectionSchemaPlan.stagedIntegratedStatements {
                try isolated.execute(statement)
            }
            try isolated.execute("PRAGMA user_version = 5")
            let definition = try XCTUnwrap(
                RuntimeCanonicalProjectionDefinitionRegistry.canonical().definitions[.search]
            )
            let projectionID = String(repeating: "b", count: 64)
            let searchID = String(repeating: "c", count: 64)
            let hash = String(repeating: "a", count: 64)
            let empty = RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal
            try isolated.execute(
                """
                INSERT INTO runtime_canonical_projection_generations VALUES (
                    ?, 'runtime.search', 2, ?, 2, 1, 'event-1', ?, ?,
                    'invalidation.1.runtime.search', 'invalidation.1.runtime.search', ?,
                    0, 0, ?, '', 1, 'building', NULL, 1, NULL
                )
                """,
                bindings: [
                    .text(projectionID), .text(definition.authorityDigest), .text(hash),
                    .text(empty), .text(hash), .text(empty),
                ]
            )
            try isolated.execute(
                """
                INSERT INTO runtime_canonical_search_generations VALUES (
                    ?, ?, 'aggregate_kind_only', ?, 1, ?, 0, 0, 0, 0, ?,
                    'building', NULL, 1
                )
                """,
                bindings: [
                    .text(searchID), .text(projectionID),
                    .text(definition.authorityDigest), .text(hash), .text(empty),
                ]
            )
            let aggregate = RuntimeSemanticAggregate(
                kind: .goal, id: try RuntimeAggregateID(validating: "goal-1")
            )
            let cursor = RuntimeCanonicalReplayCursor(
                sequence: 1, eventID: "event-1", eventHash: hash
            )
            let digest = RuntimeCanonicalSearchDocument.authorityDigest(
                generationID: searchID, aggregate: aggregate, privacy: .standard,
                localOnly: true, title: "goal", body: "", sourceCursor: cursor
            )
            let document = RuntimeCanonicalSearchDocument(
                generationID: searchID, aggregate: aggregate, privacy: .standard,
                localOnly: true, title: "goal", body: "",
                sourceCursor: cursor, digest: digest
            )
            try isolated.execute(
                """
                INSERT INTO runtime_canonical_search_documents VALUES (
                    ?, 'goal', 'goal-1', 'standard', 1, 'goal', '',
                    1, 'event-1', ?, ?
                )
                """,
                bindings: [.text(searchID), .text(hash), .text(digest)]
            )
            for (field, text) in ["goal"].enumerated() {
                for (ordinal, token) in CanonicalRuntimeStore
                    .canonicalSearchTokens(text).enumerated() {
                    let posting = RuntimeTransactionDigest.digest([
                        "runtime.search.posting.v1", searchID, token, "goal", "goal-1",
                        String(field), String(ordinal), digest,
                    ])
                    try isolated.execute(
                        "INSERT INTO runtime_canonical_search_postings VALUES (?, ?, 'goal', 'goal-1', ?, ?, ?)",
                        bindings: [
                            .text(searchID), .text(token), .integer(Int64(field)),
                            .integer(Int64(ordinal)), .text(posting),
                        ]
                    )
                }
            }
            try CanonicalRuntimeStore.requireExactCanonicalSearchPostings(
                document: document, database: isolated
            )
            try isolated.execute(
                "INSERT INTO runtime_canonical_search_postings VALUES (?, 'forged', 'goal', 'goal-1', 0, 63, ?)",
                bindings: [.text(searchID), .text(String(repeating: "f", count: 64))]
            )
            XCTAssertThrowsError(
                try CanonicalRuntimeStore.requireExactCanonicalSearchPostings(
                    document: document, database: isolated
                )
            )
        }
    }

    func testNonemptySearchScrubReconcilesExpectedAndActualPostingsByKeyset() async throws {
        let database = try SQLiteDatabase(
            url: FileManager.default.temporaryDirectory.appendingPathComponent(
                "runtime-search-scrub-\(UUID().uuidString).sqlite"
            )
        )
        try await database.transaction(.exclusive) { isolated in
            for statement in CanonicalRuntimeStore.schemaStatements
                + CanonicalRuntimeProjectionSchemaPlan.stagedIntegratedStatements {
                try isolated.execute(statement)
            }
            try isolated.execute("PRAGMA user_version = 5")
            let definition = try XCTUnwrap(
                RuntimeCanonicalProjectionDefinitionRegistry.canonical().definitions[.search]
            )
            let projectionID = String(repeating: "b", count: 64)
            let searchID = String(repeating: "c", count: 64)
            let hash = String(repeating: "a", count: 64)
            let empty = RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal
            let cursor = RuntimeCanonicalReplayCursor(
                sequence: 1, eventID: "event-1", eventHash: hash
            )
            let invalidationDigest = RuntimeTransactionDigest.digest([
                "invalidation.1.runtime.search", "1", cursor.eventID, cursor.eventHash,
            ])
            try isolated.execute(
                """
                INSERT INTO runtime_canonical_projection_generations VALUES (
                    ?, 'runtime.search', 2, ?, 2, 1, 'event-1', ?, ?,
                    'invalidation.1.runtime.search', 'invalidation.1.runtime.search', ?,
                    0, 0, ?, '', 1, 'building', NULL, 1, NULL
                )
                """,
                bindings: [
                    .text(projectionID), .text(definition.authorityDigest), .text(hash),
                    .text(empty), .text(invalidationDigest), .text(empty),
                ]
            )
            try isolated.execute(
                """
                INSERT INTO runtime_canonical_search_generations VALUES (
                    ?, ?, 'aggregate_kind_only', ?, 1, ?, 0, 0, 0, 0, ?,
                    'building', NULL, 1
                )
                """,
                bindings: [
                    .text(searchID), .text(projectionID),
                    .text(definition.authorityDigest), .text(hash), .text(empty),
                ]
            )
            let aggregate = RuntimeSemanticAggregate(
                kind: .goal, id: try RuntimeAggregateID(validating: "goal-1")
            )
            let documentDigest = RuntimeCanonicalSearchDocument.authorityDigest(
                generationID: searchID, aggregate: aggregate, privacy: .standard,
                localOnly: true, title: "goal", body: "", sourceCursor: cursor
            )
            try isolated.execute(
                """
                INSERT INTO runtime_canonical_search_documents VALUES (
                    ?, 'goal', 'goal-1', 'standard', 1, 'goal', '',
                    1, 'event-1', ?, ?
                )
                """,
                bindings: [.text(searchID), .text(hash), .text(documentDigest)]
            )
            var postingCount = 0
            var postingBytes = 0
            for (field, text) in ["goal"].enumerated() {
                for (ordinal, token) in CanonicalRuntimeStore
                    .canonicalSearchTokens(text).enumerated() {
                    let digest = RuntimeTransactionDigest.digest([
                        "runtime.search.posting.v1", searchID, token, "goal", "goal-1",
                        String(field), String(ordinal), documentDigest,
                    ])
                    try isolated.execute(
                        "INSERT INTO runtime_canonical_search_postings VALUES (?, ?, 'goal', 'goal-1', ?, ?, ?)",
                        bindings: [
                            .text(searchID), .text(token), .integer(Int64(field)),
                            .integer(Int64(ordinal)), .text(digest),
                        ]
                    )
                    postingCount += 1
                    postingBytes += token.utf8.count + digest.utf8.count
                        + "goal".utf8.count + "goal-1".utf8.count + 16
                }
            }
            let searchRoot = RuntimeTransactionDigest.digest([
                "runtime.search.shard.v1", searchID, "0", empty,
                "goal", "goal-1", documentDigest,
            ])
            try isolated.execute(
                "INSERT INTO runtime_canonical_search_shards VALUES (?, 0, 'goal', 'goal-1', 'goal', 'goal-1', 1, ?, ?)",
                bindings: [.text(searchID), .text(empty), .text(searchRoot)]
            )
            let projectionCertificate = CanonicalRuntimeStore
                .canonicalProjectionGenerationCertificateDigest(
                    generationID: projectionID, projectionID: .search,
                    definitionDigest: definition.authorityDigest,
                    outputVersion: definition.outputVersion, sourceCursor: cursor,
                    sourceChainDigest: empty, entryCount: 0, shardCount: 0,
                    rootDigest: empty, privacy: "", localOnly: true,
                    invalidationDigest: invalidationDigest
                )
            try isolated.execute(
                "UPDATE runtime_canonical_projection_generations SET status = 'sealed', generation_certificate_digest = ?, sealed_at_ms = 1 WHERE generation_id = ?",
                bindings: [.text(projectionCertificate), .text(projectionID)]
            )
            let searchCertificate = CanonicalRuntimeStore
                .canonicalSearchGenerationCertificateDigest(
                    generationID: searchID, projectionGenerationID: projectionID,
                    coverage: .aggregateKindOnly,
                    definitionDigest: definition.authorityDigest,
                    sourceCursor: cursor, documentCount: 1,
                    postingCount: postingCount, postingBytes: postingBytes,
                    shardCount: 1, rootDigest: searchRoot
                )
            try isolated.execute(
                """
                UPDATE runtime_canonical_search_generations
                SET document_count = 1, posting_count = ?, posting_bytes = ?,
                    shard_count = 1, document_root_digest = ?, status = 'sealed',
                    generation_certificate_digest = ? WHERE generation_id = ?
                """,
                bindings: [
                    .integer(Int64(postingCount)), .integer(Int64(postingBytes)),
                    .text(searchRoot), .text(searchCertificate), .text(searchID),
                ]
            )
            try CanonicalRuntimeStore.scheduleCanonicalGenerationScrub(
                generationID: searchID, kind: "search", certificate: searchCertificate,
                nowMilliseconds: 1, database: isolated
            )
            _ = try CanonicalRuntimeStore.runOneCanonicalGenerationMaintenanceUnitInTransaction(
                ownerID: "search-scrub", nowMilliseconds: 2, rowLimit: 1,
                database: isolated
            )
            _ = try CanonicalRuntimeStore.runOneCanonicalGenerationMaintenanceUnitInTransaction(
                ownerID: "search-scrub", nowMilliseconds: 3, rowLimit: 1,
                database: isolated
            )
            for instant in 4..<(4 + postingCount) {
                _ = try CanonicalRuntimeStore.runOneCanonicalGenerationMaintenanceUnitInTransaction(
                    ownerID: "search-scrub", nowMilliseconds: Int64(instant), rowLimit: 1,
                    database: isolated
                )
            }
            XCTAssertEqual(
                try CanonicalRuntimeStore.runOneCanonicalGenerationMaintenanceUnitInTransaction(
                    ownerID: "search-scrub", nowMilliseconds: Int64(4 + postingCount),
                    rowLimit: 1, database: isolated
                ),
                .completed(generationID: searchID, kind: "search")
            )
            XCTAssertEqual(
                try isolated.query(
                    "SELECT observed_posting_count FROM runtime_canonical_scrub_certificates WHERE generation_id = ?",
                    bindings: [.text(searchID)]
                ).first?.value(named: "observed_posting_count"),
                .integer(Int64(postingCount))
            )

            for mismatch in ["count", "bytes"] {
                let malformedProjectionID = RuntimeTransactionDigest.digest([
                    "runtime.projection.scrub-mismatch", mismatch,
                ])
                let malformedSearchID = RuntimeTransactionDigest.digest([
                    "runtime.search.scrub-mismatch", mismatch,
                ])
                try isolated.execute(
                    """
                    INSERT INTO runtime_canonical_projection_generations VALUES (
                        ?, 'runtime.search', 2, ?, 2, 1, 'event-1', ?, ?,
                        ?, ?, ?, 0, 0, ?, '', 1, 'published', ?, 20, 20
                    )
                    """,
                    bindings: [
                        .text(malformedProjectionID), .text(definition.authorityDigest),
                        .text(hash), .text(empty),
                        .text("invalidation.scrub-mismatch.\(mismatch)"),
                        .text("invalidation.scrub-mismatch.\(mismatch)"),
                        .text(RuntimeTransactionDigest.digest([mismatch])), .text(empty),
                        .text(RuntimeTransactionDigest.digest([
                            "runtime.projection.scrub-mismatch.certificate", mismatch,
                        ])),
                    ]
                )
                try isolated.execute(
                    """
                    INSERT INTO runtime_canonical_search_generations VALUES (
                        ?, ?, 'aggregate_kind_only', ?, 1, ?, 0, 0, 0, 0, ?,
                        'building', NULL, 20
                    )
                    """,
                    bindings: [
                        .text(malformedSearchID), .text(malformedProjectionID),
                        .text(definition.authorityDigest), .text(hash), .text(empty),
                    ]
                )
                let malformedDocumentDigest = RuntimeCanonicalSearchDocument.authorityDigest(
                    generationID: malformedSearchID, aggregate: aggregate,
                    privacy: .standard, localOnly: true,
                    title: "goal", body: "", sourceCursor: cursor
                )
                try isolated.execute(
                    """
                    INSERT INTO runtime_canonical_search_documents VALUES (
                        ?, 'goal', 'goal-1', 'standard', 1, 'goal', '',
                        1, 'event-1', ?, ?
                    )
                    """,
                    bindings: [
                        .text(malformedSearchID), .text(hash),
                        .text(malformedDocumentDigest),
                    ]
                )
                var actualCount = 0
                var actualBytes = 0
                for (field, text) in ["goal"].enumerated() {
                    for (ordinal, token) in CanonicalRuntimeStore
                        .canonicalSearchTokens(text).enumerated() {
                        let digest = RuntimeTransactionDigest.digest([
                            "runtime.search.posting.v1", malformedSearchID, token,
                            "goal", "goal-1", String(field), String(ordinal),
                            malformedDocumentDigest,
                        ])
                        try isolated.execute(
                            "INSERT INTO runtime_canonical_search_postings VALUES (?, ?, 'goal', 'goal-1', ?, ?, ?)",
                            bindings: [
                                .text(malformedSearchID), .text(token),
                                .integer(Int64(field)), .integer(Int64(ordinal)),
                                .text(digest),
                            ]
                        )
                        actualCount += 1
                        actualBytes += token.utf8.count + digest.utf8.count
                            + "goal".utf8.count + "goal-1".utf8.count + 16
                    }
                }
                let malformedRoot = RuntimeTransactionDigest.digest([
                    "runtime.search.shard.v1", malformedSearchID, "0", empty,
                    "goal", "goal-1", malformedDocumentDigest,
                ])
                try isolated.execute(
                    "INSERT INTO runtime_canonical_search_shards VALUES (?, 0, 'goal', 'goal-1', 'goal', 'goal-1', 1, ?, ?)",
                    bindings: [
                        .text(malformedSearchID), .text(empty), .text(malformedRoot),
                    ]
                )
                let declaredCount = actualCount + (mismatch == "count" ? 1 : 0)
                let declaredBytes = actualBytes + (mismatch == "bytes" ? 1 : 0)
                let malformedCertificate = CanonicalRuntimeStore
                    .canonicalSearchGenerationCertificateDigest(
                        generationID: malformedSearchID,
                        projectionGenerationID: malformedProjectionID,
                        coverage: .aggregateKindOnly,
                        definitionDigest: definition.authorityDigest,
                        sourceCursor: cursor, documentCount: 1,
                        postingCount: declaredCount, postingBytes: declaredBytes,
                        shardCount: 1, rootDigest: malformedRoot
                    )
                try isolated.execute(
                    """
                    UPDATE runtime_canonical_search_generations
                    SET document_count = 1, posting_count = ?, posting_bytes = ?,
                        shard_count = 1, document_root_digest = ?, status = 'sealed',
                        generation_certificate_digest = ? WHERE generation_id = ?
                    """,
                    bindings: [
                        .integer(Int64(declaredCount)), .integer(Int64(declaredBytes)),
                        .text(malformedRoot), .text(malformedCertificate),
                        .text(malformedSearchID),
                    ]
                )
                try CanonicalRuntimeStore.scheduleCanonicalGenerationScrub(
                    generationID: malformedSearchID, kind: "search",
                    certificate: malformedCertificate,
                    nowMilliseconds: 20, database: isolated
                )
                var terminal: RuntimeCanonicalGenerationMaintenanceOutcome = .idle
                for instant in 21...30 {
                    terminal = try CanonicalRuntimeStore
                        .runOneCanonicalGenerationMaintenanceUnitInTransaction(
                            ownerID: "mismatch-scrub", nowMilliseconds: Int64(instant),
                            rowLimit: 128, database: isolated
                        )
                    if case .quarantined = terminal { break }
                }
                XCTAssertEqual(
                    terminal,
                    .quarantined(generationID: malformedSearchID, kind: "search"),
                    mismatch
                )
                XCTAssertEqual(try isolated.query(
                    "SELECT 1 FROM runtime_canonical_repair_requirements WHERE generation_id = ? AND state = 'required'",
                    bindings: [.text(malformedSearchID)]
                ).count, 1, mismatch)
            }
        }
    }

    func testPostingAuthorityRejectsCandidateSetBeyondDeclaredBackpressureLimit() async throws {
        let database = try SQLiteDatabase(
            url: FileManager.default.temporaryDirectory.appendingPathComponent(
                "runtime-search-backpressure-\(UUID().uuidString).sqlite"
            )
        )
        try await database.transaction(.exclusive) { isolated in
            for statement in CanonicalRuntimeStore.schemaStatements
                + CanonicalRuntimeProjectionSchemaPlan.stagedIntegratedStatements {
                try isolated.execute(statement)
            }
            try isolated.execute("PRAGMA user_version = 5")
            let definition = try XCTUnwrap(
                RuntimeCanonicalProjectionDefinitionRegistry.canonical().definitions[.search]
            )
            let projectionID = String(repeating: "d", count: 64)
            let searchID = String(repeating: "e", count: 64)
            let hash = String(repeating: "a", count: 64)
            let empty = RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal
            try isolated.execute(
                """
                INSERT INTO runtime_canonical_projection_generations VALUES (
                    ?, 'runtime.search', 2, ?, 2, 1, 'event-1', ?, ?,
                    'invalidation.1.runtime.search', 'invalidation.1.runtime.search', ?,
                    0, 0, ?, '', 1, 'building', NULL, 1, NULL
                )
                """,
                bindings: [
                    .text(projectionID), .text(definition.authorityDigest), .text(hash),
                    .text(empty), .text(String(repeating: "b", count: 64)), .text(empty),
                ]
            )
            try isolated.execute(
                """
                INSERT INTO runtime_canonical_search_generations VALUES (
                    ?, ?, 'aggregate_kind_only', ?, 1, ?, 0, 0, 0, 0, ?,
                    'building', NULL, 1
                )
                """,
                bindings: [
                    .text(searchID), .text(projectionID),
                    .text(definition.authorityDigest), .text(hash), .text(empty),
                ]
            )
            for index in 0...RuntimeCanonicalSearchQuery.maximumCandidateCount {
                let identifier = "goal-\(index)"
                try isolated.execute(
                    """
                    INSERT INTO runtime_canonical_search_documents VALUES (
                        ?, 'goal', ?, 'standard', 1, 'common', '', 1, 'event-1', ?, ?
                    )
                    """,
                    bindings: [
                        .text(searchID), .text(identifier), .text(hash),
                        .text(String(repeating: "c", count: 64)),
                    ]
                )
                try isolated.execute(
                    "INSERT INTO runtime_canonical_search_postings VALUES (?, 'common', 'goal', ?, 0, 0, ?)",
                    bindings: [
                        .text(searchID), .text(identifier),
                        .text(String(repeating: "f", count: 64)),
                    ]
                )
            }
            let cursor = RuntimeCanonicalReplayCursor(
                sequence: 1, eventID: "event-1", eventHash: hash
            )
            let projection = RuntimeCanonicalGenerationAuthority(
                projectionID: .search, generationID: projectionID,
                definitionDigest: definition.authorityDigest,
                outputVersion: definition.outputVersion, sourceCursor: cursor,
                sourceChainDigest: empty, entryCount: 0, entryRootDigest: empty,
                privacyClasses: [.standard], localOnly: true,
                certificateDigest: String(repeating: "1", count: 64),
                fingerprint: String(repeating: "2", count: 64)
            )
            let authority = RuntimeCanonicalSearchAuthority(
                projection: projection, generationID: searchID,
                coverage: .aggregateKindOnly,
                certificateDigest: String(repeating: "3", count: 64),
                fingerprint: String(repeating: "4", count: 64)
            )
            let query = RuntimeCanonicalSearchQuery(
                text: "common", allowedPrivacy: [.standard], families: [.goal]
            )
            XCTAssertThrowsError(try CanonicalRuntimeStore.readCanonicalSearchRows(
                authority: authority, query: query, tokens: query.normalizedTokens,
                cursor: nil, database: isolated
            )) { error in
                XCTAssertEqual(error as? RuntimeCanonicalSearchError, .queryTooBroad)
            }

            let postingProjectionID = String(repeating: "8", count: 64)
            let postingSaturationID = String(repeating: "9", count: 64)
            try isolated.execute(
                """
                INSERT INTO runtime_canonical_projection_generations VALUES (
                    ?, 'runtime.search', 2, ?, 2, 1, 'event-1', ?, ?,
                    'invalidation.posting-saturation', 'invalidation.posting-saturation', ?,
                    0, 0, ?, '', 1, 'building', NULL, 1, NULL
                )
                """,
                bindings: [
                    .text(postingProjectionID), .text(definition.authorityDigest),
                    .text(hash), .text(empty),
                    .text(RuntimeTransactionDigest.digest(["posting-saturation"])),
                    .text(empty),
                ]
            )
            try isolated.execute(
                """
                INSERT INTO runtime_canonical_search_generations VALUES (
                    ?, ?, 'aggregate_kind_only', ?, 1, ?, 0, 0, 0, 0, ?,
                    'building', NULL, 1
                )
                """,
                bindings: [
                    .text(postingSaturationID), .text(postingProjectionID),
                    .text(definition.authorityDigest), .text(hash), .text(empty),
                ]
            )
            let repeated = Array(repeating: "common", count: 64).joined(separator: " ")
            for index in 0..<65 {
                let identifier = "saturated-\(index)"
                let aggregate = RuntimeSemanticAggregate(
                    kind: .goal, id: try RuntimeAggregateID(validating: identifier)
                )
                let documentDigest = RuntimeCanonicalSearchDocument.authorityDigest(
                    generationID: postingSaturationID, aggregate: aggregate,
                    privacy: .standard, localOnly: true,
                    title: repeated, body: repeated, sourceCursor: cursor
                )
                try isolated.execute(
                    """
                    INSERT INTO runtime_canonical_search_documents VALUES (
                        ?, 'goal', ?, 'standard', 1, ?, ?, 1, 'event-1', ?, ?
                    )
                    """,
                    bindings: [
                        .text(postingSaturationID), .text(identifier),
                        .text(repeated), .text(repeated), .text(hash),
                        .text(documentDigest),
                    ]
                )
                for field in 0...1 {
                    for ordinal in 0..<64 {
                        let postingDigest = RuntimeTransactionDigest.digest([
                            "runtime.search.posting.v1", postingSaturationID, "common",
                            "goal", identifier, String(field), String(ordinal), documentDigest,
                        ])
                        try isolated.execute(
                            "INSERT INTO runtime_canonical_search_postings VALUES (?, 'common', 'goal', ?, ?, ?, ?)",
                            bindings: [
                                .text(postingSaturationID), .text(identifier),
                                .integer(Int64(field)), .integer(Int64(ordinal)),
                                .text(postingDigest),
                            ]
                        )
                    }
                }
            }
            let saturatedAuthority = RuntimeCanonicalSearchAuthority(
                projection: projection, generationID: postingSaturationID,
                coverage: .aggregateKindOnly,
                certificateDigest: String(repeating: "8", count: 64),
                fingerprint: String(repeating: "7", count: 64)
            )
            XCTAssertThrowsError(try CanonicalRuntimeStore.readCanonicalSearchRows(
                authority: saturatedAuthority, query: query,
                tokens: query.normalizedTokens, cursor: nil, database: isolated
            )) { error in
                XCTAssertEqual(error as? RuntimeCanonicalSearchError, .queryTooBroad)
            }
        }
    }

    private func makeCursor() -> RuntimeCanonicalReplayCursor {
        RuntimeCanonicalReplayCursor(
            sequence: 1, eventID: "event-1",
            eventHash: String(repeating: "a", count: 64)
        )
    }

    private func makeEntry() throws -> RuntimeCanonicalProjectionEntry {
        let bytes = Data("last-command-bytes-are-not-search-input".utf8)
        return RuntimeCanonicalProjectionEntry(
            aggregate: RuntimeSemanticAggregate(
                kind: .goal, id: try RuntimeAggregateID(validating: "goal-1")
            ), revision: 1, lifecycle: .active, canonicalStateBytes: bytes,
            canonicalStateDigest: LocalRuntimeStorageChecksum.sha256Hex(for: bytes),
            privacy: .standard, localOnly: true, sourceCursor: makeCursor()
        )
    }
}

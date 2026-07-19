import XCTest
@testable import Ambitions

final class LifeShapeDataContractTests: XCTestCase {
    func testRootLayerLanguageIsOpenProtectedPressureBuffer() {
        XCTAssertEqual(LifeShapeLayer.allCases.map(\.title), ["Open", "Protected", "Pressure", "Buffer"])
    }

    func testReadingKindsCoverUnavailableOpenProtectedPressureAndBuffer() {
        XCTAssertEqual(
            Set(LifeShapeReadingKind.allCases),
            Set([.unavailable, .open, .protected, .pressure, .buffer])
        )
    }

    func testBucketBuilderRequiresDerivationAndAccessibilitySummary() throws {
        let start = Date(timeIntervalSince1970: 1_800)
        let end = start.addingTimeInterval(1_800)
        let reading = LifeShapeReading(
            horizon: .day,
            kind: .open,
            title: "Open pocket",
            summary: "This pocket can hold a light Step.",
            capacityStatement: "Open capacity is available.",
            sourceDetail: "Built from local Time context."
        )
        let confidence = LifeShapeConfidence(level: .grounded, explanation: "Local inputs agree.")
        let missingDerivation = LifeShapeDerivation(inputRefs: [], ruleIDs: [], clockDerivation: "")
        let completeDerivation = derivation()

        XCTAssertThrowsError(
            try LifeShapeBucketBuilder.makeBucket(
                id: "bucket-missing-derivation",
                start: start,
                end: end,
                horizon: .day,
                layer: .open,
                reading: reading,
                derivation: missingDerivation,
                confidence: confidence,
                accessibilitySummary: "Open pocket. Open capacity is available."
            )
        ) { error in
            XCTAssertEqual(error as? LifeShapeContractViolation, .missingDerivation)
        }

        XCTAssertThrowsError(
            try LifeShapeBucketBuilder.makeBucket(
                id: "bucket-missing-accessibility",
                start: start,
                end: end,
                horizon: .day,
                layer: .open,
                reading: reading,
                derivation: completeDerivation,
                confidence: confidence,
                accessibilitySummary: "   "
            )
        ) { error in
            XCTAssertEqual(error as? LifeShapeContractViolation, .missingAccessibilitySummary)
        }

        let bucket = try LifeShapeBucketBuilder.makeBucket(
            id: "bucket-valid",
            start: start,
            end: end,
            horizon: .day,
            layer: .open,
            reading: reading,
            derivation: completeDerivation,
            confidence: confidence,
            accessibilitySummary: "Open pocket. Open capacity is available."
        )

        XCTAssertEqual(bucket.layer, .open)
        XCTAssertEqual(bucket.horizon, .day)
        XCTAssertFalse(bucket.derivation.inputRefs.isEmpty)
        XCTAssertFalse(bucket.derivation.ruleIDs.isEmpty)
        XCTAssertFalse(bucket.accessibilitySummary.isEmpty)
    }

    func testProjectionRequiresSemanticSummaryAndDerivedBuckets() throws {
        let bucket = try makeValidBucket(id: "now-bucket")
        let anchor = LifeShapeTodayAnchor(
            date: bucket.start,
            bucketID: bucket.id,
            accessibilitySummary: "Today starts inside the open pocket."
        )
        let row = LifeShapeHorizonRow(id: "row-day", horizon: .day, summary: "Day has one open pocket.", bucketIDs: [bucket.id])

        XCTAssertThrowsError(
            try LifeShapeBucketBuilder.makeProjection(
                generatedAt: bucket.start,
                currentDate: bucket.start,
                selectedLayer: .open,
                selectedHorizon: .day,
                nowBucketID: bucket.id,
                todayBuckets: [bucket],
                horizonRows: [row],
                primaryCaption: "This pocket can hold a light Step.",
                primaryAction: nil,
                todayAnchor: anchor,
                semanticSummary: ""
            )
        ) { error in
            XCTAssertEqual(error as? LifeShapeContractViolation, .missingAccessibilitySummary)
        }

        let projection = try LifeShapeBucketBuilder.makeProjection(
            generatedAt: bucket.start,
            currentDate: bucket.start,
            selectedLayer: .open,
            selectedHorizon: .day,
            nowBucketID: bucket.id,
            todayBuckets: [bucket],
            horizonRows: [row],
            primaryCaption: "This pocket can hold a light Step.",
            primaryAction: nil,
            todayAnchor: anchor,
            semanticSummary: "Time has one open pocket with derivation and accessibility."
        )

        XCTAssertEqual(projection.nowBucketID, "now-bucket")
        XCTAssertEqual(projection.todayBuckets.first?.derivation.ruleIDs.first?.rawValue, "lifeshape.test.open")
        XCTAssertEqual(projection.selectedLayer.title, "Open")
    }

    func testConstructionAuditBlocksUIUseOfRuntimeConstructorsAndBuilder() {
        let ui = LifeShapeSourceFile(
            path: "Native/Ambitions/Surfaces/Time/TimeObjectView.swift",
            contents: """
            let bucket = try LifeShapeBucket.runtimeValidated()
            let projection = try LifeShapeProjection.runtimeValidated()
            let other = LifeShapeBucketBuilder.makeBucket()
            """
        )
        let runtime = LifeShapeSourceFile(
            path: "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/LifeShapeBucketBuilder.swift",
            contents: "let bucket = try LifeShapeBucket.runtimeValidated()"
        )

        let report = LifeShapeConstructionAudit.auditUIConstruction([ui, runtime])

        XCTAssertTrue(report.containsFinding("construction.lifeshapebucket.runtimevalidated"))
        XCTAssertTrue(report.containsFinding("construction.lifeshapeprojection.runtimevalidated"))
        XCTAssertTrue(report.containsFinding("construction.lifeshapebucketbuilder."))
        XCTAssertFalse(report.findings.contains { $0.path.contains("LifeShapeBucketBuilder.swift") })
    }

    func testDerivationAuditPassesActualDomainContractFiles() throws {
        let files = try [
            "Native/Ambitions/Core/Domain/LifeShapeProjection.swift",
            "Native/Ambitions/Core/Domain/LifeShapeBucket.swift",
            "Native/Ambitions/Core/Domain/LifeShapeReading.swift",
            "Native/Ambitions/Core/Domain/LifeShapeLayer.swift",
            "Native/Ambitions/Core/Domain/LifeShapeHorizon.swift",
            "Native/Ambitions/Core/Domain/LifeShapeDerivation.swift",
            "Native/Ambitions/Core/Domain/LifeShapeConfidence.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/LifeShapeBucketBuilder.swift"
        ].map(sourceFile)

        XCTAssertTrue(LifeShapeDerivationAudit.auditModelContract(files).passed)
    }

    private func makeValidBucket(id: String) throws -> LifeShapeBucket {
        let start = Date(timeIntervalSince1970: 3_600)
        return try LifeShapeBucketBuilder.makeBucket(
            id: id,
            start: start,
            end: start.addingTimeInterval(1_800),
            horizon: .day,
            layer: .open,
            reading: LifeShapeReading(
                horizon: .day,
                kind: .open,
                title: "Open pocket",
                summary: "This pocket can hold a light Step.",
                capacityStatement: "Open capacity is available.",
                sourceDetail: "Built from local Time context."
            ),
            derivation: derivation(),
            confidence: LifeShapeConfidence(level: .grounded, explanation: "Local inputs agree."),
            accessibilitySummary: "Open pocket. Open capacity is available."
        )
    }

    private func derivation() -> LifeShapeDerivation {
        LifeShapeDerivation(
            inputRefs: [
                LifeShapeInputRef(id: "clock", kind: .clock, label: "Injected clock"),
                LifeShapeInputRef(id: "local-default", kind: .localDefault, label: "Local Time default")
            ],
            ruleIDs: ["lifeshape.test.open"],
            clockDerivation: "Preview-safe injected clock."
        )
    }

    private func sourceFile(_ relativePath: String) throws -> LifeShapeSourceFile {
        let url = repoRoot().appendingPathComponent(relativePath)
        return LifeShapeSourceFile(path: relativePath, contents: try String(contentsOf: url, encoding: .utf8))
    }

    private func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}

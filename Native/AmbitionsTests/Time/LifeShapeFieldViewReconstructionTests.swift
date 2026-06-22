import XCTest
@testable import Ambitions

final class LifeShapeFieldViewReconstructionTests: XCTestCase {
    func testTimeObjectStageContractOwnsLifeShapeField() {
        let contract = TimeObjectStagePrimitiveContract.current
        XCTAssertEqual(contract.ownerSurface, "Time")
        XCTAssertEqual(contract.productObject, "LifeShape Field")
        XCTAssertTrue(contract.firstViewportAvoidsCalendarCardStackGeometry)
    }

    func testTimeObjectStageContractNamesCapacityPressureAndProtectedReality() {
        let structure = TimeObjectStagePrimitiveContract.current.firstViewportStructure
        XCTAssertTrue(structure.contains("capacity contours"))
        XCTAssertTrue(structure.contains("pressure texture"))
        XCTAssertTrue(structure.contains("protected windows"))
        XCTAssertTrue(structure.contains("fixed points"))
        XCTAssertTrue(structure.contains("horizons"))
        XCTAssertTrue(structure.contains("confirmation-first shaping actions"))
    }

    func testTimeObjectStageContractRejectsCalendarCloneGeometry() {
        let replaced = Set(TimeObjectStagePrimitiveContract.current.replacesFirstViewportStructures)
        XCTAssertTrue(replaced.contains("calendar clone"))
        XCTAssertTrue(replaced.contains("agenda clone"))
        XCTAssertTrue(replaced.contains("free/busy grid"))
        XCTAssertTrue(replaced.contains("metric-row stack"))
    }

    func testSwiftUIFirstLifeShapeRootUsesFirstClassComponents() throws {
        let root = repoRoot()
        let requiredPaths = [
            "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeLayerSelector.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeNowInstrument.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeHorizonRow.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeBucketDetail.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeWhyThisInspection.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeCorrectionMenu.swift"
        ]

        for path in requiredPaths {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }

        let rootView = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift", root: root)
        let bucketDetail = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeBucketDetail.swift", root: root)
        XCTAssertTrue(rootView.contains("LifeShapeLayerSelector"))
        XCTAssertTrue(rootView.contains("LifeShapeNowInstrument"))
        XCTAssertTrue(rootView.contains("LifeShapeHorizonRowView"))
        XCTAssertTrue(rootView.contains("LifeShapeBucketDetail"))
        XCTAssertTrue(bucketDetail.contains("LifeShapeWhyThisInspection"))
        XCTAssertTrue(rootView.contains("LifeShapeCorrectionMenu"))
        XCTAssertTrue(rootView.contains("LifeShapeMutationProofBanner"))
        XCTAssertTrue(rootView.contains("onMutationAction?(.placeStep"))
        XCTAssertTrue(rootView.contains("onMutationAction?(.protectWindow"))
        XCTAssertTrue(rootView.contains("onMutationAction?(.makeTodayLighter"))
        XCTAssertTrue(rootView.contains("onMutationAction?(.addBuffer"))
        XCTAssertTrue(rootView.contains("onMutationAction?(.notUsable"))
        XCTAssertTrue(rootView.contains("onMutationAction?(.keepClear"))
        XCTAssertFalse(rootView.contains("sourceReceiptRow"))
        XCTAssertFalse(rootView.contains("LifeShape zoom"))
        XCTAssertFalse(rootView.contains("horizonControl"))
    }

    func testLifeShapeFieldDoesNotPerformLocalOnlyVisualMutation() throws {
        let root = repoRoot()
        let rootView = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift", root: root)
        let viewModel = try source("Native/Ambitions/Surfaces/Time/TimeViewModel.swift", root: root)
        let coordinator = try source("Native/Ambitions/Projection/Mutations/TimeFieldMutationCoordinator.swift", root: root)
        let stateProjection = try source("Native/Ambitions/Projection/Mutations/TimeFieldMutationStateProjection.swift", root: root)
        let visibleProjection = try source("Native/Ambitions/Projection/Mutations/TimeFieldVisibleProjectionAdapter.swift", root: root)
        let mutationChain = [coordinator, stateProjection, visibleProjection].joined(separator: "\n")

        XCTAssertTrue(rootView.contains("onMutationAction?"))
        XCTAssertFalse(rootView.contains("selectedMarkID = selectedLayerMarks.first?.id"))
        XCTAssertTrue(rootView.contains("LifeShapeMutationHapticModifier"))
        XCTAssertTrue(rootView.contains(".ambitionHaptic"))
        XCTAssertTrue(rootView.contains("case \"confirmation\":"))
        XCTAssertTrue(viewModel.contains("TimeFieldMutationCoordinator().perform"))
        XCTAssertTrue(viewModel.contains("undoLastLifeShapeMutation"))
        XCTAssertTrue(mutationChain.contains("TimeMutation.make"))
        XCTAssertTrue(mutationChain.contains("runtime.mutation"))
        XCTAssertTrue(mutationChain.contains("Today recomputed"))
        XCTAssertTrue(mutationChain.contains("MutationProof"))
        XCTAssertTrue(mutationChain.contains("MutationAccessibilityAnnouncement"))
    }

    func testAMB1171ExposesPressureLayerWithMinimumHitTargetsAndOrdinalCopy() throws {
        let root = repoRoot()
        let selector = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeLayerSelector.swift", root: root)
        let now = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeNowInstrument.swift", root: root)
        let correction = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeCorrectionMenu.swift", root: root)
        let rootView = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift", root: root)
        let pressurePresentation = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView+PressurePresentation.swift", root: root)

        let layerPresentation = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView+LayerPresentation.swift", root: root)
        let bufferPresentation = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView+BufferPresentation.swift", root: root)

        XCTAssertTrue(selector.contains("private let layers: [LifeShapeLayer] = [.open, .protected, .pressure, .buffer]"))
        XCTAssertTrue(layerPresentation.contains("Add buffer"))
        XCTAssertTrue(pressurePresentation.contains("Light"))
        XCTAssertTrue(layerPresentation.contains("Make today lighter"))
        XCTAssertTrue(pressurePresentation.contains("\"Light\", \"Crowded\", \"Tight\", \"Needs buffer\""))
        XCTAssertTrue(bufferPresentation.contains("\"Room available\", \"Keep light\", \"Add room\", \"Needs buffer\""))
        XCTAssertTrue(bufferPresentation.contains("Schedule room only"))
        XCTAssertFalse(rootView.localizedCaseInsensitiveContains("82% pressure"))
        XCTAssertFalse(rootView.localizedCaseInsensitiveContains("poor productivity"))
        XCTAssertFalse(rootView.localizedCaseInsensitiveContains("depleted"))
        XCTAssertFalse(bufferPresentation.localizedCaseInsensitiveContains("wellness"))
        XCTAssertFalse(bufferPresentation.localizedCaseInsensitiveContains("diagnosis"))
        XCTAssertFalse(pressurePresentation.localizedCaseInsensitiveContains("82% pressure"))
        XCTAssertFalse(pressurePresentation.localizedCaseInsensitiveContains("poor productivity"))
        XCTAssertTrue(selector.contains("minHeight: 44"))
        XCTAssertTrue(now.contains("minHeight: 44"))
        XCTAssertTrue(correction.contains("minHeight: 44"))
    }

    func testLifeShapeSemanticMirrorRootOrderDoesNotExposeSourceReceiptAsFirstViewport() {
        let mirror = LifeShapeSemanticModel(
            stageName: UserFacingLanguage.Object.lifeShapeField,
            currentDateSummary: "Today",
            capacitySummary: "Open capacity is visible.",
            protectedWindowSummary: "Protected windows are visible.",
            pressureSummary: "Pressure is reviewable.",
            horizonSummary: "This week stays inside Time.",
            accessibilityFallbacks: []
        )

        XCTAssertTrue(mirror.accessibilityOrder.contains("now instrument"))
        XCTAssertTrue(mirror.accessibilityOrder.contains("Open layer"))
        XCTAssertTrue(mirror.accessibilityOrder.contains("Protected layer"))
        XCTAssertFalse(mirror.accessibilityOrder.contains("source"))
        XCTAssertFalse(mirror.accessibilityOrder.contains("receipt"))
    }

    func testAMB1169WhyThisInspectionStaysBehindDetailIntentAndAvoidsAuditConsoleCopy() throws {
        let root = repoRoot()
        let rootView = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift", root: root)
        let detail = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeBucketDetail.swift", root: root)
        let inspection = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeWhyThisInspection.swift", root: root)
        let scanned = [rootView, detail, inspection].joined(separator: "\n")
        let forbidden = [
            "Source: Calendar",
            "Receipt: Current",
            "Privacy posture: Local",
            "Runtime-backed projection",
            "Based on local goals, captures, protected time, pressure, and user choice"
        ]

        XCTAssertTrue(detail.contains("LifeShapeWhyThisInspection"))
        XCTAssertTrue(inspection.contains("Why this?"))
        XCTAssertTrue(inspection.contains("Inspect proof"))
        XCTAssertTrue(inspection.contains("This block is not protected."))
        XCTAssertTrue(inspection.contains("Receipt is saved with this Time shape."))
        XCTAssertTrue(inspection.contains("time.life-shape-field.why-this.button"))
        XCTAssertTrue(inspection.contains("time.life-shape-field.proof-inspection"))
        for phrase in forbidden {
            XCTAssertFalse(scanned.contains(phrase), phrase)
        }
    }

    private func source(_ relativePath: String, root: URL) throws -> String {
        try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
    }

    private func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}

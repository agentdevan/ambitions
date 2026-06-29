@testable import Ambitions
import SwiftUI
import UIKit
import XCTest

final class SourceInspectionPresentationTests: XCTestCase {
    func testSourceInspectionCoversRequiredStates() {
        XCTAssertEqual(
            Set(SourceInspectionState.allCases),
            [
                .current,
                .stale,
                .staleCritical,
                .unavailable,
                .conflicted,
                .revoked,
                .unsupported,
                .reviewRequired,
            ]
        )

        let fixtures = SourceInspectionPresentationFixtures.all
        XCTAssertEqual(fixtures.map(\.state), SourceInspectionState.allCases)
        XCTAssertTrue(fixtures.allSatisfy { $0.hiddenByDefaultSummary.contains("only when requested") })
        XCTAssertTrue(fixtures.allSatisfy { $0.privacySummary.contains("Personal goals") })
        XCTAssertTrue(fixtures.allSatisfy { $0.privacySummary.contains("account secrets") })
    }

    func testBlockedStatesAreHonestAboutCurrentUse() {
        let blockedStates: Set<SourceInspectionState> = [
            .staleCritical,
            .unavailable,
            .conflicted,
            .revoked,
            .unsupported,
            .reviewRequired,
        ]

        for presentation in SourceInspectionPresentationFixtures.all where blockedStates.contains(presentation.state) {
            XCTAssertTrue(presentation.state.blocksCurrentUse, presentation.state.rawValue)
            XCTAssertTrue(
                presentation.contextRows.contains {
                    $0.title == "Use" &&
                        ($0.detail.localizedCaseInsensitiveContains("cannot") ||
                            $0.detail.localizedCaseInsensitiveContains("blocked"))
                },
                presentation.state.rawValue
            )
        }
    }

    func testCopyAuditRejectsArchitectureAndDebugTerms() {
        XCTAssertEqual(SourceInspectionCopyAudit.validate(SourceInspectionPresentationFixtures.all), [])

        let invalid = SourceInspectionPresentation.make(
            id: "invalid",
            state: .current,
            publicDetail: SourceInspectionPublicDetail(
                sourceName: "R2 object debug shard",
                sourceKind: "Adapter",
                referenceTitle: "Private graph manifest internals",
                retrievedLabel: "Current",
                freshnessLabel: "Current",
                useLabel: "Available"
            ),
            useContext: "Compiler lattice context",
            reviewAction: "No review needed."
        )

        let failures = SourceInspectionCopyAudit.validate(invalid)
        XCTAssertTrue(failures.contains { $0.contains("r2 object") })
        XCTAssertTrue(failures.contains { $0.contains("private graph") })
        XCTAssertTrue(failures.contains { $0.contains("adapter") })
        XCTAssertTrue(failures.contains { $0.contains("compiler") })
    }

    func testSourceInspectionViewIsTrustDetailRendererNotRootSurface() throws {
        let source = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/Trust/SourceInspectionView.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(source.contains("SourceInspectionPresentation"))
        XCTAssertTrue(source.contains("SourceInspectionPresentationFixtures.defaultDetail"))
        XCTAssertTrue(source.contains("trust.source.inspection-detail"))
        XCTAssertFalse(source.localizedCaseInsensitiveContains("tabview"))
        XCTAssertFalse(source.localizedCaseInsensitiveContains("root destination"))
        XCTAssertFalse(source.localizedCaseInsensitiveContains("dashboard"))
    }

    @MainActor
    func testProductionSourceInspectionViewRendersAccessiblePublicReferenceDetail() throws {
        let proof = SourceAtlasLocalReferenceCompositionProof(
            id: "source-atlas-production-r2-train-29-occupation-foundation-source-inspection",
            state: .current,
            packID: "source-atlas/v1/domain/occupation_foundation/20260628T000000Z",
            domainID: "occupation_foundation",
            sourceID: "source-lane-onet",
            sourceName: "O*NET public reference",
            sourceKind: "Official public reference",
            referenceTitle: "Occupation foundation public reference",
            retrievedLabel: "Retrieved from the production R2 pack manifest",
            freshnessLabel: "Current public reference.",
            useLabel: "Use as public context only; Ambitions keeps fit, timing, and priority local.",
            localMatchLabel: "Matched occupation foundation locally",
            publicEntityLabel: "Occupation foundation public reference",
            localOnlyMatchingStatement: "Matched locally on this device.",
            nonClaim: "Public reference only. This is not a guarantee, professional advice, or a completed plan.",
            caveats: [],
            issues: [],
            publicReferencePackIDs: ["source-atlas/v1/domain/occupation_foundation/20260628T000000Z"],
            runtimeOwnsFitTimingPriorityProof: true,
            sourceAtlasOwnsFinalUserSteps: false,
            createsFinalSchedule: false,
            blocksCoreLocalPlanning: false
        )
        let presentation = SourceInspectionPresentation.make(localReferenceProof: proof)
        let visibleContract = presentationText(presentation)

        XCTAssertEqual(presentation.state, .current)
        XCTAssertEqual(presentation.accessibilityLabel, "Source detail, Current")
        XCTAssertTrue(presentation.accessibilityValue.contains("O*NET public reference"))
        XCTAssertTrue(presentation.accessibilityHint.contains("public source context"))
        XCTAssertTrue(presentation.privacySummary.contains("Personal goals"))
        XCTAssertTrue(presentation.privacySummary.contains("account secrets"))
        XCTAssertEqual(presentation.contextRows.map(\.title), ["Reference", "Freshness", "Use", "Review"])
        XCTAssertEqual(SourceInspectionCopyAudit.validate(presentation), [])
        XCTAssertTrue(proof.runtimeOwnsFitTimingPriorityProof)
        XCTAssertFalse(proof.sourceAtlasOwnsFinalUserSteps)
        XCTAssertFalse(proof.createsFinalSchedule)
        XCTAssertFalse(proof.blocksCoreLocalPlanning)
        XCTAssertFalse(visibleContract.localizedCaseInsensitiveContains("final user plan"))
        XCTAssertFalse(visibleContract.localizedCaseInsensitiveContains("final schedule"))
        XCTAssertFalse(visibleContract.localizedCaseInsensitiveContains("step generator"))
        XCTAssertFalse(visibleContract.localizedCaseInsensitiveContains("private_graph"))
        XCTAssertFalse(visibleContract.localizedCaseInsensitiveContains("goal_text"))

        let regularRender = try renderStats(
            presentation: presentation,
            dynamicTypeSize: .large
        )
        let accessibilityRender = try renderStats(
            presentation: presentation,
            dynamicTypeSize: .accessibility3
        )

        XCTAssertEqual(regularRender.size, CGSize(width: 390, height: 844))
        XCTAssertEqual(accessibilityRender.size, CGSize(width: 390, height: 844))
        XCTAssertGreaterThan(regularRender.nonTransparentPixels, 24_000)
        XCTAssertGreaterThan(accessibilityRender.nonTransparentPixels, 24_000)
        XCTAssertGreaterThan(regularRender.colorBuckets, 8)
        XCTAssertGreaterThan(accessibilityRender.colorBuckets, 8)
    }

    private func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Trust")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }

    private func presentationText(_ presentation: SourceInspectionPresentation) -> String {
        (
            [
                presentation.title,
                presentation.subtitle,
                presentation.publicDetail.sourceName,
                presentation.publicDetail.sourceKind,
                presentation.publicDetail.referenceTitle,
                presentation.publicDetail.retrievedLabel,
                presentation.publicDetail.freshnessLabel,
                presentation.publicDetail.useLabel,
                presentation.privacySummary,
                presentation.hiddenByDefaultSummary,
                presentation.accessibilityLabel,
                presentation.accessibilityValue,
                presentation.accessibilityHint,
                presentation.semanticAnnouncement,
                presentation.redactionSummary,
                presentation.reduceMotionSummary,
            ] +
                presentation.contextRows.flatMap { [$0.title, $0.detail] }
        )
        .joined(separator: " ")
    }

    @MainActor
    private func renderStats(
        presentation: SourceInspectionPresentation,
        dynamicTypeSize: DynamicTypeSize
    ) throws -> RenderStats {
        let size = CGSize(width: 390, height: 844)
        let width = Int(size.width)
        let height = Int(size.height)
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw RenderError.contextUnavailable
        }

        let host = UIHostingController(
            rootView: SourceInspectionView(presentation: presentation)
                .dynamicTypeSize(dynamicTypeSize)
                .frame(width: size.width, height: size.height)
        )
        guard let windowScene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first else {
            throw RenderError.windowSceneUnavailable
        }
        let window = UIWindow(windowScene: windowScene)
        window.frame = CGRect(origin: .zero, size: size)
        window.rootViewController = host
        window.isHidden = false
        host.view.frame = window.bounds
        host.view.backgroundColor = .clear
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()
        window.layoutIfNeeded()
        host.view.layer.render(in: context)
        window.isHidden = true

        return RenderStats(size: size, pixels: pixels)
    }
}

private struct RenderStats: Equatable {
    let size: CGSize
    let nonTransparentPixels: Int
    let colorBuckets: Int

    init(size: CGSize, pixels: [UInt8]) {
        self.size = size
        var nonTransparentPixels = 0
        var buckets: Set<Int> = []
        stride(from: 0, to: pixels.count, by: 4).forEach { index in
            let alpha = pixels[index + 3]
            guard alpha > 0 else {
                return
            }
            nonTransparentPixels += 1
            let redBucket = Int(pixels[index] / 32)
            let greenBucket = Int(pixels[index + 1] / 32)
            let blueBucket = Int(pixels[index + 2] / 32)
            let alphaBucket = Int(alpha / 32)
            buckets.insert(redBucket << 12 | greenBucket << 8 | blueBucket << 4 | alphaBucket)
        }
        self.nonTransparentPixels = nonTransparentPixels
        self.colorBuckets = buckets.count
    }
}

private enum RenderError: Error {
    case contextUnavailable
    case windowSceneUnavailable
}

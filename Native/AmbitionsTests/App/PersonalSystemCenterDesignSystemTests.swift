import Foundation
import XCTest
import AmbitionsDesignSystem
@testable import Ambitions

final class PersonalSystemCenterDesignSystemTests: XCTestCase {
    func testSI11PersonalSystemCenterSignalsStayTrustAndPrivacyBound() {
        let signals = [
            PersonalSystemCenterSignal(
                id: "trust",
                title: "Trust Center",
                detail: "Reviewable",
                source: "No silent changes",
                state: .proof,
                context: .trust
            ),
            PersonalSystemCenterSignal(
                id: "memory",
                title: "Memory",
                detail: "Inspectable",
                source: "Local records",
                state: .calm,
                context: .memory
            ),
            PersonalSystemCenterSignal(
                id: "accessibility",
                title: "Accessibility",
                detail: "Claims locked",
                source: "Human proof pending",
                state: .stale,
                context: .you
            )
        ]

        XCTAssertEqual(signals.map(\.id), ["trust", "memory", "accessibility"])
        XCTAssertTrue(signals.contains(where: { $0.source == "No silent changes" }))
        XCTAssertFalse(signals.map(\.source).joined(separator: " ").localizedCaseInsensitiveContains("synced everywhere"))
        XCTAssertFalse(signals.map(\.detail).joined(separator: " ").localizedCaseInsensitiveContains("verified accessible"))
    }

    func testSI11SetupCompletenessNamesFutureEdgesWithoutRuntimeClaims() {
        let items = [
            PersonalSystemCenterSetupItem(id: "trust", title: "Trust Center", statusLabel: "Review", state: .proof),
            PersonalSystemCenterSetupItem(id: "memory", title: "Memory", statusLabel: "Local", state: .calm),
            PersonalSystemCenterSetupItem(id: "schedule", title: "Schedule", statusLabel: "Denied", state: .stale),
            PersonalSystemCenterSetupItem(id: "sync", title: "Sync / Archive", statusLabel: "Future", state: .stale)
        ]

        XCTAssertEqual(items.count, 4)
        XCTAssertTrue(items.contains(where: { $0.title == "Sync / Archive" && $0.statusLabel == "Future" }))
        XCTAssertFalse(items.map(\.statusLabel).contains("Connected"))
        XCTAssertFalse(items.map(\.title).joined(separator: " ").localizedCaseInsensitiveContains("account"))
    }

    func testSI11GroupedNavigationSectionsPreserveYouAsOwnedSurface() {
        let sections = [
            GroupedNavigationSystemSection(
                id: "trust-memory",
                title: "Trust, Memory & Receipts",
                subtitle: "Inspectable controls without a settings dump.",
                items: [
                    GroupedNavigationSystemItem(
                        id: "trust-center",
                        title: "Trust Center",
                        subtitle: "Permissions, privacy, and boundaries.",
                        symbolName: "checkmark.shield",
                        state: .proof,
                        statusLabel: "Review"
                    )
                ]
            )
        ]

        XCTAssertEqual(sections.map(\.id), ["trust-memory"])
        XCTAssertEqual(sections.flatMap(\.items).map(\.title), ["Trust Center"])
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Profile"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Insights"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Habits"))
    }

    func testFE04PrimitiveRolesBindYouAsThePersonalSystemCenter() {
        let header = PersonalSystemCenterHeader(
            title: "Your system",
            summary: "Local-first controls are visible before any deeper setup.",
            signals: []
        )
        let setup = PersonalSystemCenterSetupCompleteness(
            title: "Setup completeness",
            summary: "Setup-needed states stay visible.",
            completedCount: 1,
            totalCount: 2,
            items: []
        )

        XCTAssertEqual(header.fe04Role, .userSystemProfile)
        XCTAssertEqual(setup.fe04Role, .userSystemProfile)
        XCTAssertEqual(FE04PrimitiveRole.userSystemProfile.ownerSurface, "You")
        XCTAssertTrue(FE04PrimitiveSystemContract.validationFailures(for: .userSystemProfile).isEmpty)
        XCTAssertFalse(FE04PrimitiveRole.userSystemProfile.accessibilitySummary.localizedCaseInsensitiveContains(["dash", "board"].joined()))
        XCTAssertFalse(FE04PrimitiveRole.userSystemProfile.accessibilitySummary.localizedCaseInsensitiveContains(["profile", "tab"].joined(separator: " ")))
    }

    func testAMB576YouObjectStageControlPrimitiveReplacesGenericProfileSettingsContainers() throws {
        let contract = YouObjectStageControlPrimitiveContract.current
        let rootSource = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/Surfaces/You/YouRootSurface.swift"),
            encoding: .utf8
        )
        let screenSource = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/Surfaces/You/YouScreen.swift"),
            encoding: .utf8
        )

        XCTAssertEqual(contract.primitiveID, "personal-runtime-group")
        XCTAssertEqual(contract.ownerSurface, "You")
        XCTAssertEqual(contract.productObject, "Personal system / User System Profile")
        XCTAssertEqual(contract.stageName, "You Object Stage Control")
        XCTAssertEqual(contract.screenshotIdentifier, "YouObjectStageControl")
        XCTAssertTrue(contract.avoidsGenericProfileSettingsWall)
        XCTAssertTrue(contract.reservesTabBarClearance)
        XCTAssertEqual(contract.sourceControlOrder, [
            "planning setup",
            "runtime preferences",
            "history and trust",
            "support system"
        ])
        XCTAssertTrue(contract.replacesFirstViewportStructures.contains("generic settings wall"))
        XCTAssertTrue(contract.exemptedSemanticControls.contains("native grouped navigation rows"))
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Dynamic Type") })
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Differentiate Without Color") })
        XCTAssertTrue(rootSource.contains("YouObjectStageControlPrimitiveContract.current"))
        XCTAssertTrue(rootSource.contains("YouPersonalRuntimeGovernanceControls"))
        XCTAssertTrue(rootSource.contains("priorityGovernanceRows"))
        XCTAssertTrue(rootSource.contains("How Ambitions works for me"))
        XCTAssertTrue(rootSource.contains("\"trust-automation\""))
        XCTAssertTrue(rootSource.contains("\"personal-runtime\""))
        XCTAssertTrue(rootSource.contains("\"receipts-history\""))
        XCTAssertTrue(rootSource.contains("you.priority-node.\\(item.id)"))
        XCTAssertFalse(rootSource.contains("Array(items.prefix(1))"))
        XCTAssertFalse(rootSource.contains("Runtime Governance"))
        XCTAssertTrue(rootSource.contains("YouPersonalSystemNavigationRow"))
        XCTAssertTrue(rootSource.contains("Runtime Preferences"))
        XCTAssertFalse(rootSource.contains("Account & Preferences"))
        XCTAssertFalse(rootSource.contains("Capsule(style: .continuous)"))
        XCTAssertFalse(rootSource.contains("RoundedRectangle("))
        XCTAssertFalse(rootSource.contains("HeroCard("))
        XCTAssertFalse(rootSource.contains("AppCard("))
        XCTAssertFalse(rootSource.contains("StateDrivenMaterialPanel("))
        XCTAssertTrue(screenSource.contains(".accessibilityIdentifier(\"you.scroll\")"))
        XCTAssertTrue(screenSource.contains(".safeAreaInset(edge: .bottom"))
        XCTAssertTrue(screenSource.contains("theme.spacing.xxxl + theme.spacing.xxl"))
        XCTAssertTrue(screenSource.contains("YouConstitutionSurface("))
        XCTAssertTrue(screenSource.contains("YouPersonalVaultSurface("))
        XCTAssertTrue(screenSource.contains("YouTrustHistoryCenterSurface("))
        XCTAssertTrue(screenSource.contains("YouCrossSurfaceProofReviewSurface("))
    }

    func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}

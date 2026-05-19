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
        XCTAssertFalse(FE04PrimitiveRole.userSystemProfile.accessibilitySummary.localizedCaseInsensitiveContains("dashboard"))
        XCTAssertFalse(FE04PrimitiveRole.userSystemProfile.accessibilitySummary.localizedCaseInsensitiveContains("profile tab"))
    }
}

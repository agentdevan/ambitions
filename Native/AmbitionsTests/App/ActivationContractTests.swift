import XCTest
@testable import Ambitions

final class ActivationContractTests: XCTestCase {
    func testActivationContractDefinesEveryFirstRunMoment() {
        let promises = ActivationMomentKind.allCases.map { ActivationContract.promise(for: $0) }

        XCTAssertEqual(promises.count, 7)
        XCTAssertEqual(Set(promises.map(\.kind)), Set(ActivationMomentKind.allCases))
        XCTAssertTrue(promises.allSatisfy { $0.title.isEmpty == false })
        XCTAssertTrue(promises.allSatisfy { $0.explanation.isEmpty == false })
    }

    func testActivationContractKeepsFirstTenMinutesLocalManualAndTruthful() {
        let copy = allActivationCopy().joined(separator: " ")

        XCTAssertTrue(copy.contains("one real thing"))
        XCTAssertTrue(copy.localizedCaseInsensitiveContains("locally"))
        XCTAssertTrue(copy.localizedCaseInsensitiveContains("manual"))
        XCTAssertTrue(copy.contains("Export and sync are not required to begin"))
        XCTAssertFalse(copy.contains("Apple-account-based sync"))
        XCTAssertFalse(copy.contains("fully synced"))
        XCTAssertFalse(copy.contains("Life Graph"))
        XCTAssertFalse(copy.contains("Action Closure"))
        XCTAssertFalse(copy.contains("Believability Kernel"))
        XCTAssertFalse(copy.contains("Trust Ledger"))
        XCTAssertFalse(copy.contains("RC maturity"))
    }

    func testPrimarySurfaceEmptyStateRulesAreDefinedForCanonicalTabs() {
        let rules = ActivationSurface.allCases.map { ActivationContract.emptyStateRule(for: $0) }

        XCTAssertEqual(rules.map(\.surface), [.today, .goals, .capture, .plan, .you])
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Today", "Goals", "Capture", "Time", "You"])
        XCTAssertEqual(ActivationContract.emptyStateRule(for: .capture).surface.title, "Capture")
        XCTAssertEqual(ActivationContract.emptyStateRule(for: .you).primaryAction.routingHint, .profileTrust)
    }

    func testEmptyStateRulesDoNotClaimUnbuiltExportSyncOrPlanningEngines() {
        let copy = ActivationSurface.allCases
            .map { ActivationContract.emptyStateRule(for: $0) }
            .flatMap { [$0.title, $0.explanation, $0.primaryAction.title, $0.secondaryAction?.title ?? ""] }
            .joined(separator: " ")

        XCTAssertTrue(copy.contains("without connecting anything"))
        XCTAssertTrue(copy.contains("without claiming sync or export is ready"))
        XCTAssertFalse(copy.contains("Apple-first sync"))
        XCTAssertFalse(copy.contains("export/import is ready"))
        XCTAssertFalse(copy.contains("Path Builder"))
        XCTAssertFalse(copy.contains("automatic recovery"))
    }

    private func allActivationCopy() -> [String] {
        var copy = [
            ActivationContract.firstTenMinutesPromise,
            ActivationContract.orientationTitle,
            ActivationContract.orientationSubtitle,
            ActivationContract.startTitle,
            ActivationContract.startSubtitle,
            ActivationContract.trustMessage.title,
            ActivationContract.trustMessage.explanation
        ]

        copy.append(contentsOf: ActivationContract.trustMessage.rows.flatMap { [$0.title, $0.detail] })
        copy.append(contentsOf: ActivationContract.onboardingSurfaceRows.flatMap { [$0.title, $0.detail] })
        copy.append(contentsOf: ActivationMomentKind.allCases.flatMap {
            let promise = ActivationContract.promise(for: $0)
            return [promise.title, promise.explanation, promise.primaryActionTitle ?? ""]
        })
        return copy
    }
}

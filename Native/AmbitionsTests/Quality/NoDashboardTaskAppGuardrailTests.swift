@testable import Ambitions
import XCTest

final class NoDashboardTaskAppGuardrailTests: XCTestCase {
    func testSurfaceLawBlocksGenericProductArchetypesAsRoots() {
        let forbiddenRootValues = [
            "activity",
            "activity-feed",
            "ai",
            "analytics",
            "assistant",
            "chatbot",
            "dashboard",
            "dashboards",
            "feed",
            "habit",
            "habits",
            "insights",
            "kpi",
            "productivity",
            "score",
            "streak",
            "task",
            "task-board",
            "taskboard",
            "tasks",
        ]

        for rawValue in forbiddenRootValues {
            XCTAssertNil(AmbitionsSurface(rawValue: rawValue), "\(rawValue) must not become a persistent root surface.")
            XCTAssertTrue(
                SurfaceLaw.blockedRootRawValues.contains(rawValue),
                "\(rawValue) must stay blocked by SurfaceLaw."
            )
        }
    }

    func testSurfaceContractValidationRejectsDashboardTaskHabitChatbotRootGrammar() {
        let rootDriftContracts: [(AmbitionsSurfaceContract, String)] = [
            (
                AmbitionsSurfaceContract(tab: .today, title: "Today dashboard", primaryObject: .realityMeridian),
                "dashboard"
            ),
            (
                AmbitionsSurfaceContract(tab: .goals, title: "Task manager", primaryObject: .lifeAreaAtlas),
                "task manager"
            ),
            (
                AmbitionsSurfaceContract(tab: .time, title: "Habit tracker", primaryObject: .lifeShapeField),
                "habit tracker"
            ),
            (
                AmbitionsSurfaceContract(tab: .you, title: "AI assistant", primaryObject: .userSystemProfile),
                "AI assistant"
            ),
        ]

        for (contract, forbiddenTerm) in rootDriftContracts {
            let contracts = AmbitionsSurfaceContractRegistry.canonicalContracts.map {
                $0.tab == contract.tab ? contract : $0
            }
            let issues = AmbitionsSurfaceContractRegistry.validate(contracts)

            XCTAssertTrue(
                issues.contains { $0.localizedCaseInsensitiveContains(forbiddenTerm) },
                "\(forbiddenTerm) must be rejected as root product grammar. Issues: \(issues)"
            )
        }
    }

    func testForbiddenPrimaryLanguageRejectsDashboardTaskHabitChatbotProductivityDrift() {
        let forbiddenCopy: [(String, String)] = [
            ("Show the analytics dashboard.", "analytics dashboard"),
            ("Open the task dashboard.", "task dashboard"),
            ("Turn Goals into a task board.", "task board"),
            ("Use this as a habit tracker.", "habit tracker"),
            ("The AI assistant recommends this.", "AI assistant"),
            ("Open the activity feed.", "activity feed"),
            ("Your productivity score improved.", "productivity score"),
            ("This is a life score.", "life score"),
            ("Show KPI rows.", "KPI"),
            ("Your streak is intact.", "streak"),
            ("Start a chatbot.", "chatbot"),
            ("Open the dashboard.", "dashboard"),
        ]

        for (copy, expectedTerm) in forbiddenCopy {
            XCTAssertEqual(
                ForbiddenLanguageAudit.violation(in: copy),
                expectedTerm,
                "\(expectedTerm) must stay forbidden in primary product copy."
            )
        }

        XCTAssertNil(ForbiddenLanguageAudit.violation(in: "Open step."))
        XCTAssertNil(ForbiddenLanguageAudit.violation(in: "Start now."))
        XCTAssertNil(ForbiddenLanguageAudit.violation(in: "Source", exposure: .inspectionOnly))
    }

    func testDashboardNamedProductionDebtDoesNotGrowSilently() throws {
        let productionDashboardPaths = try swiftSourcePaths(under: "Native/Ambitions")
            .filter { path in
                path.contains("Dashboard") &&
                    path.contains("/PreviewSupport/") == false &&
                    path.contains("/Support/") == false
            }

        let mappedDebt = Set([
            "Native/Ambitions/Surfaces/Goals/Projection/GoalsDashboardState.swift",
            "Native/Ambitions/Surfaces/Time/Projection/TimeRitualsDashboardBuilder.swift",
            "Native/Ambitions/Surfaces/Time/Projection/TimeRitualsDashboardState.swift",
            "Native/Ambitions/Surfaces/Today/Projection/TodayDashboardState.swift",
            "Native/Ambitions/Surfaces/You/Projection/InsightsDashboardState.swift",
            "Native/Ambitions/Surfaces/You/Projection/YouDashboardModels.swift",
            "Native/Ambitions/Surfaces/You/Projection/YouFeatureServiceDashboardProjection.swift",
            "Native/Ambitions/Surfaces/You/Projection/YouHistoryDashboardBuilder.swift",
        ])

        XCTAssertEqual(
            Set(productionDashboardPaths),
            mappedDebt,
            "Dashboard-named production compatibility debt must be mapped before it can change."
        )
    }

    private func swiftSourcePaths(under relativeDirectory: String) throws -> [String] {
        let root = repoRoot()
        let directory = root.appendingPathComponent(relativeDirectory)
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }

        var paths: [String] = []
        for case let url as URL in enumerator where url.pathExtension == "swift" {
            let path = url.path.replacingOccurrences(of: root.path + "/", with: "")
            paths.append(path)
        }
        return paths.sorted()
    }

    private func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            if FileManager.default.fileExists(atPath: url.appendingPathComponent("project.yml").path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}

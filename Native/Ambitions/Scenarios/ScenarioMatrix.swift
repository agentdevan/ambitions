import Foundation

struct ScenarioMatrixValidationIssue: Sendable, Hashable {
    let message: String
}

enum ScenarioMatrix {
    static func validate(_ scenarios: [RuntimeScenario] = ScenarioCatalog.previewMatrix) -> [ScenarioMatrixValidationIssue] {
        var issues: [ScenarioMatrixValidationIssue] = []
        let scenarioIDs = scenarios.map(\.id)

        if Set(scenarioIDs).count != scenarioIDs.count {
            issues.append(ScenarioMatrixValidationIssue(message: "Scenario IDs must be unique."))
        }

        for surface in ScenarioCatalog.surfaces {
            let surfaceScenarios = scenarios.filter { $0.surface == surface }
            let states = Set(surfaceScenarios.map(\.state))
            let modes = Set(surfaceScenarios.map(\.accessibilityMode))
            let contexts = Set(surfaceScenarios.map(\.deviceContext))

            for state in ScenarioCatalog.requiredSurfaceStates where states.contains(state) == false {
                issues.append(ScenarioMatrixValidationIssue(message: "\(surface.rawValue) is missing \(state.rawValue)."))
            }
            for mode in ScenarioCatalog.requiredAccessibilityModes where modes.contains(mode) == false {
                issues.append(ScenarioMatrixValidationIssue(message: "\(surface.rawValue) is missing \(mode.rawValue)."))
            }
            for context in ScenarioCatalog.requiredDeviceContexts where contexts.contains(context) == false {
                issues.append(ScenarioMatrixValidationIssue(message: "\(surface.rawValue) is missing \(context.rawValue)."))
            }

            let mutationRows = surfaceScenarios.filter { $0.state == .postMutation }
            if mutationRows.isEmpty {
                issues.append(ScenarioMatrixValidationIssue(message: "\(surface.rawValue) is missing post-mutation proof coverage."))
            }
            if mutationRows.contains(where: { Set($0.requiredProof) == Set(ScenarioCatalog.proofStepsForMeaningfulAction) }) == false {
                issues.append(ScenarioMatrixValidationIssue(message: "\(surface.rawValue) post-mutation rows must require mutation, visibility, announcement, and proof."))
            }
        }

        let persistentRoots = ScenarioCatalog.surfaces.filter(\.isPersistentRoot)
        if persistentRoots != [.today, .goals, .time, .you] {
            issues.append(ScenarioMatrixValidationIssue(message: "Persistent roots must be exactly Today, Goals, Time, You."))
        }

        return issues
    }
}


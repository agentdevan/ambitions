import Foundation

enum AccessibilityScenarios {
    static let all: [RuntimeScenario] = ScenarioCatalog.surfaces.flatMap { surface in
        ScenarioCatalog.accessibilityCoverage(
            for: surface,
            owner: "accessibility-stress"
        )
    }
}

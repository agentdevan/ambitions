import Foundation

struct StageObject: Equatable, Identifiable {
    let surface: AmbitionsSurface
    let title: String
    let primaryActionTitle: String
    let accessibilitySummary: String

    var id: AmbitionsSurface { surface }

    static func primary(for surface: AmbitionsSurface) -> StageObject {
        switch surface.canonicalTopLevelTab {
        case .today:
            StageObject(
                surface: .today,
                title: "Reality Meridian",
                primaryActionTitle: "Start here",
                accessibilitySummary: "Today shows one Reality Meridian object and one Start here action."
            )
        case .goals:
            StageObject(
                surface: .goals,
                title: "Constellation Atlas",
                primaryActionTitle: "Open step",
                accessibilitySummary: "Goals shows the Constellation Atlas and keeps the next Step reachable."
            )
        case .time:
            StageObject(
                surface: .time,
                title: "LifeShape Field",
                primaryActionTitle: "Review",
                accessibilitySummary: "Time shows the LifeShape Field and lets the user review capacity."
            )
        case .you:
            StageObject(
                surface: .you,
                title: "User System Profile",
                primaryActionTitle: "Review",
                accessibilitySummary: "You shows the User System Profile and inspectable personal controls."
            )
        }
    }
}

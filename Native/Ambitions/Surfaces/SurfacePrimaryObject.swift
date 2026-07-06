import Foundation

enum SurfacePrimaryObject: String, CaseIterable, Sendable {
    case realityMeridian = "Reality Meridian"
    case lifeAreaAtlas = "Life Area Atlas"
    case lifeShapeField = "Life Calendar"
    case userSystemProfile = "User System Profile"

    static func primary(for surface: AmbitionsSurface) -> SurfacePrimaryObject {
        switch surface {
        case .today:
            .realityMeridian
        case .goals:
            .lifeAreaAtlas
        case .time:
            .lifeShapeField
        case .you:
            .userSystemProfile
        }
    }
}

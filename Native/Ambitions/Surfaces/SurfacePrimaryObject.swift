import Foundation

enum SurfacePrimaryObject: String, CaseIterable, Sendable {
    case realityMeridian = "Reality Meridian"
    case constellationAtlas = "Constellation Atlas"
    case lifeShapeField = "LifeShape Field"
    case userSystemProfile = "User System Profile"

    static func primary(for surface: AmbitionsSurface) -> SurfacePrimaryObject {
        switch surface {
        case .today:
            .realityMeridian
        case .goals:
            .constellationAtlas
        case .time:
            .lifeShapeField
        case .you:
            .userSystemProfile
        }
    }
}

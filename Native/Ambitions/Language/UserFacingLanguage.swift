import Foundation

enum UserFacingLanguage {
    enum Surface {
        static let today = "Today"
        static let goals = "Goals"
        static let time = "Time"
        static let you = "You"
    }

    enum Object {
        static let realityMeridian = "Reality Meridian"
        static let constellationAtlas = "Constellation Atlas"
        static let lifeShapeField = "LifeShape Field"
        static let userSystemProfile = "User System Profile"
        static let atmosphereComposer = "Atmosphere Composer"
        static let stageMotion = "Stage Motion"
    }

    enum Action {
        static let startHere = "Start here"
        static let recommendedStep = "Recommended step"
        static let startNow = "Start now"
        static let openStep = "Open step"
        static let review = "Review"
        static let undo = "Undo"
    }

    static let persistentSurfaces: [String] = [
        Surface.today,
        Surface.goals,
        Surface.time,
        Surface.you,
    ]
}

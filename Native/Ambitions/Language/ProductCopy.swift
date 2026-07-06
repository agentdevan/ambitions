import Foundation

/// Centralized product-facing language for Ambitions surfaces, overlays, and inspection.
///
/// Keep first-viewport copy plain, calm, and user-facing. Runtime governance terms belong
/// in inspection, validation, and proof tooling, not in primary product UI.
enum ProductCopy {
    enum Today {
        static let surfaceTitle = UserFacingLanguage.Surface.today
        static let objectTitle = UserFacingLanguage.Object.realityMeridian
        static let startHere = UserFacingLanguage.Action.startHere
        static let recommendedStep = UserFacingLanguage.Action.recommendedStep
        static let startNow = UserFacingLanguage.Action.startNow
        static let openStep = UserFacingLanguage.Action.openStep
        static let openWindow = "Open window"
        static let nothingFitsHeadline = "This window is open"
        static let nothingFitsDetail = "Ambitions can hold the space until a step fits."
        static let shapeThisWindow = "Shape this window"
        static let protectThisWindow = "Protect this window"
        static let whatHappened = "What happened?"
        static let done = "Done"
        static let madeProgress = "Made progress"
        static let blocked = "Blocked"
        static let move = "Move"
        static let notNeeded = "Not needed"
    }

    enum Capture {
        static let surfaceTitle = "Capture"
        static let objectTitle = UserFacingLanguage.Object.atmosphereComposer
        static let prompt = "What should Ambitions hold?"
        static let placeholder = "Type one real thing…"
        static let save = "Save"
        static let hold = "Hold"
        static let startToday = "Start Today"
        static let addToGoal = "Add to Goal"
        static let shapeTime = "Shape Time"
        static let useKeyboardMic = "Use keyboard mic"
        static let saved = "Saved"
    }

    enum Goals {
        static let surfaceTitle = UserFacingLanguage.Surface.goals
        static let objectTitle = UserFacingLanguage.Object.lifeAreaAtlas
        static let whatYouAreBuilding = "What you’re building"
        static let lifeAreas = "Life areas"
        static let activeThread = "Active thread"
        static let openGoal = "Open goal"
        static let feedsToday = "Feeds Today"
        static let whyHere = "Why this is here"
    }

    enum Time {
        static let surfaceTitle = UserFacingLanguage.Surface.time
        static let objectTitle = UserFacingLanguage.Object.lifeShapeField
        static let shapeWeek = "Shape week"
        static let protectTime = "Protect time"
        static let reviewPressure = "Review pressure"
        static let whyThisShape = "Why this shape"
        static let currentShapeKept = "Current shape kept"
    }

    enum Motion {
        static let behaviorTitle = "Motion"
        static let objectTitle = UserFacingLanguage.Object.stageMotion
        static let whatMoved = "What moved"
        static let hasProof = "Has proof"
        static let recovered = "Recovered"
        static let readyToReenter = "Ready to re-enter"
        static let inspect = "Inspect"
        static let reenter = "Re-enter"
    }

    enum You {
        static let surfaceTitle = UserFacingLanguage.Surface.you
        static let objectTitle = UserFacingLanguage.Object.userSystemProfile
        static let profile = UserFacingLanguage.Object.userSystemProfile
        static let personalization = "Personalization"
        static let planning = "Planning"
        static let capture = "Capture"
        static let privacyAndTrust = "Privacy & Trust"
        static let data = "Data"
        static let appearance = "Appearance"
        static let help = "Help"
        static let about = "About Ambitions"
    }

    enum Inspection {
        static let whyThis = "Why this"
        static let source = "Source"
        static let proof = "Proof"
        static let receipt = "Receipt"
        static let privacy = "Privacy"
        static let local = "Local"
    }
}

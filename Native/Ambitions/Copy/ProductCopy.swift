import Foundation

/// Centralized product-facing language for the release recovery train.
///
/// Keep first-viewport copy plain, calm, and user-facing. Runtime governance terms such as
/// SourceRecord, ReplayTrace, receipt seam, placement review, and preview belong in inspection
/// or test/proof surfaces, not in the primary product UI.
enum ProductCopy {
    enum Today {
        static let surfaceTitle = "Today"
        static let objectTitle = "Reality Meridian"
        static let startHere = "Start here"
        static let recommendedStep = "Recommended step"
        static let startNow = "Start now"
        static let openStep = "Open step"
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
        static let objectTitle = "Atmosphere Composer"
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
        static let surfaceTitle = "Goals"
        static let objectTitle = "Constellation Atlas"
        static let whatYouAreBuilding = "What you’re building"
        static let lifeAreas = "Life areas"
        static let activeThread = "Active thread"
        static let openGoal = "Open goal"
        static let feedsToday = "Feeds Today"
        static let whyHere = "Why this is here"
    }

    enum Time {
        static let surfaceTitle = "Time"
        static let objectTitle = "LifeShape Field"
        static let shapeWeek = "Shape week"
        static let protectTime = "Protect time"
        static let reviewPressure = "Review pressure"
        static let whyThisShape = "Why this shape"
        static let currentShapeKept = "Current shape kept"
    }

    enum Motion {
        static let surfaceTitle = "Motion"
        static let objectTitle = "Motion Current"
        static let whatMoved = "What moved"
        static let hasProof = "Has proof"
        static let recovered = "Recovered"
        static let readyToReenter = "Ready to re-enter"
        static let inspect = "Inspect"
        static let reenter = "Re-enter"
    }

    enum You {
        static let surfaceTitle = "You"
        static let objectTitle = "User System Profile"
        static let profile = "Profile"
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

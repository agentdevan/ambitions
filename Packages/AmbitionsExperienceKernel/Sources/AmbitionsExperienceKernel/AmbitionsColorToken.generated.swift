import SwiftUI

public enum AmbitionsColorToken: String, CaseIterable, Sendable {
    case graphiteRecess0 = "GraphiteRecess.0"
    case graphiteRecess1 = "GraphiteRecess.1"
    case graphiteRecess2 = "GraphiteRecess.2"
    case graphiteRecess3 = "GraphiteRecess.3"
    case graphiteRecess4 = "GraphiteRecess.4"
    case graphiteRecess5 = "GraphiteRecess.5"
    case quietGlass0 = "QuietGlass.0"
    case quietGlass1 = "QuietGlass.1"
    case quietGlass2 = "QuietGlass.2"
    case quietGlass3 = "QuietGlass.3"
    case textPrimary = "Text.primary"
    case textSecondary = "Text.secondary"
    case textTertiary = "Text.tertiary"
    case textQuaternary = "Text.quaternary"
    case textInverse = "Text.inverse"
    case accentBrand = "Accent.brand"
    case accentSuccess = "Accent.success"
    case accentCaution = "Accent.caution"
    case accentDanger = "Accent.danger"
    case accentInfo = "Accent.info"
    case accentExecutive = "Accent.executive"
    case accentCelestial = "Accent.celestial"
    case accentRecovery = "Accent.recovery"
    case strokeHairline = "Stroke.hairline"
    case strokeSubtle = "Stroke.subtle"
    case strokeStrong = "Stroke.strong"
    case strokeProof = "Stroke.proof"
    case strokePrivacy = "Stroke.privacy"
    case commandPrimary = "Command.primary"
    case commandSecondary = "Command.secondary"
    case surfaceTodayBase = "Surface.Today.base"
    case surfaceTodayField = "Surface.Today.field"
    case surfaceTodayCurrent = "Surface.Today.current"
    case surfaceGoalsBase = "Surface.Goals.base"
    case surfaceGoalsStar = "Surface.Goals.star"
    case surfaceGoalsThread = "Surface.Goals.thread"
    case surfaceCaptureBase = "Surface.Capture.base"
    case surfaceCaptureAtmosphere = "Surface.Capture.atmosphere"
    case surfaceCaptureRoute = "Surface.Capture.route"
    case surfaceTimeBase = "Surface.Time.base"
    case surfaceTimeShape = "Surface.Time.shape"
    case surfaceTimePressure = "Surface.Time.pressure"
    case surfaceYouBase = "Surface.You.base"
    case surfaceYouIdentity = "Surface.You.identity"
    case surfaceYouTrust = "Surface.You.trust"
    case objectRealityMeridianCore = "Object.RealityMeridian.core"
    case objectRealityMeridianTrace = "Object.RealityMeridian.trace"
    case objectRealityMeridianNow = "Object.RealityMeridian.now"
    case objectRealityMeridianClosed = "Object.RealityMeridian.closed"
    case objectRealityMeridianStillCounts = "Object.RealityMeridian.stillCounts"
    case objectRealityMeridianProtected = "Object.RealityMeridian.protected"
    case objectRealityMeridianWaiting = "Object.RealityMeridian.waiting"
    case objectRealityMeridianRecovery = "Object.RealityMeridian.recovery"
    case objectRealityMeridianBlocked = "Object.RealityMeridian.blocked"
    case objectRealityMeridianProof = "Object.RealityMeridian.proof"
    case objectStartHereBody = "Object.StartHere.body"
    case objectStartHereRim = "Object.StartHere.rim"
    case objectStartHereSeam = "Object.StartHere.seam"
    case objectStartHereCommand = "Object.StartHere.command"
    case objectConstellationNode = "Object.Constellation.node"
    case objectConstellationOrbit = "Object.Constellation.orbit"
    case objectAtmosphereComposer = "Object.Atmosphere.composer"
    case objectAtmosphereRoute = "Object.Atmosphere.route"
    case objectLifeShapeBody = "Object.LifeShape.body"
    case objectLifeShapeProtected = "Object.LifeShape.protected"
    case objectUserSystemIdentity = "Object.UserSystem.identity"
    case objectUserSystemBoundary = "Object.UserSystem.boundary"
    case fieldCapacityLow = "Field.capacity.low"
    case fieldCapacityMedium = "Field.capacity.medium"
    case fieldCapacityHigh = "Field.capacity.high"
    case fieldPressureProtected = "Field.pressure.protected"
    case fieldClosureResidue = "Field.closure.residue"
    case fieldSourceLive = "Field.source.live"
    case fieldSourceAging = "Field.source.aging"
    case fieldSourceStale = "Field.source.stale"
    case fieldGoalPull = "Field.goal.pull"
    case fieldPrivacyLocal = "Field.privacy.local"
    case fieldPrivacyExternal = "Field.privacy.external"
    case fieldRecoveryWarmth = "Field.recovery.warmth"
    case fieldUncertaintyGlass = "Field.uncertainty.glass"
    case stateFitNow = "State.fit.now"
    case stateFitTight = "State.fit.tight"
    case stateFitBuffer = "State.fit.buffer"
    case stateFitProtected = "State.fit.protected"
    case stateFitRecovery = "State.fit.recovery"
    case stateProofStrong = "State.proof.strong"
    case stateProofWeak = "State.proof.weak"
    case stateAutomationGuided = "State.automation.guided"
    case stateAutomationManual = "State.automation.manual"
    case stateAutomationPaused = "State.automation.paused"
}

public enum AmbitionsTokenTier: String, CaseIterable, Sendable {
    case core
    case surface
    case object
    case field
    case state
}

public enum AmbitionsTokenPolicy {
    public static let colorCount = 90

    public static let allowedTierRange = 60...130

    public static func isControlledCount(_ count: Int = colorCount) -> Bool {
        allowedTierRange.contains(count)
    }
}

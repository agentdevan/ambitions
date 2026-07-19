import Foundation

enum RuntimeVocabulary {
    static let rootSurfaceNames = UserFacingLanguage.persistentSurfaces

    static let globalComposerNames = [
        UserFacingLanguage.Object.atmosphereComposer,
        ProductCopy.Capture.surfaceTitle,
    ]

    static let behaviorLayerNames = [
        ProductCopy.Motion.behaviorTitle,
        UserFacingLanguage.Object.stageMotion,
    ]

    static let inspectionNames = [
        ProductCopy.Inspection.whyThis,
        ProductCopy.Inspection.source,
        ProductCopy.Inspection.proof,
        ProductCopy.Inspection.receipt,
        ProductCopy.Inspection.privacy,
        ProductCopy.Inspection.local,
    ]

    static var canonicalRootSurfaceSet: Set<String> {
        Set(rootSurfaceNames)
    }
}

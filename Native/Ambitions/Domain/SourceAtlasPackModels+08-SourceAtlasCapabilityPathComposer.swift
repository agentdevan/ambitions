import Foundation

struct SourceAtlasCapabilityPathComposer: Sendable, Equatable {
    let goalID: String

    let userContextVersion: String

    let sourceAtlasProjectionID: String

    let packs: [SourceAtlasPack]

    let match: SourceAtlasIntentMatch

    let selection: SourceAtlasPackSelection

    let lifeContextProjection: LifeContextRuntimeProjection

    let factorLedger: PersonalizationFactorLedger?


    init(
        goalID: String,
        userContextVersion: String,
        sourceAtlasProjectionID: String,
        packs: [SourceAtlasPack],
        match: SourceAtlasIntentMatch,
        selection: SourceAtlasPackSelection,
        lifeContextProjection: LifeContextRuntimeProjection,
        factorLedger: PersonalizationFactorLedger? = nil
    ) {
        self.goalID = goalID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.userContextVersion = userContextVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceAtlasProjectionID = sourceAtlasProjectionID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.packs = packs
        self.match = match
        self.selection = selection
        self.lifeContextProjection = lifeContextProjection
        self.factorLedger = factorLedger
    }
}

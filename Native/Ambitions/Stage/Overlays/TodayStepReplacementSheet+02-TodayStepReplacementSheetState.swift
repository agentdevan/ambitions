import AmbitionsDesignSystem
import SwiftUI

struct TodayStepReplacementSheetState: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let contextLabel: String
    let originalRecommendation: DayRailStepDetailState
    let originalHero: DayRailHeroStepState
    let alternatives: [TodayStepReplacementOptionState]
    let defaultAlternativeID: String
    let receiptPreviewTitle: String
    let impactSectionTitle: String
    let impactSectionSubtitle: String
    let approvalTitle: String
    let whyNotThisTitle: String
    let confirmTitle: String
    let sourceStepID: String
    let sourceCandidateID: String?
    let contextFingerprint: String
    let recordedAt: String
    let noSilentChangesLabel: String

    init(
        title: String,
        subtitle: String,
        contextLabel: String,
        originalRecommendation: DayRailStepDetailState,
        originalHero: DayRailHeroStepState,
        alternatives: [TodayStepReplacementOptionState],
        defaultAlternativeID: String,
        receiptPreviewTitle: String = "Review preview",
        impactSectionTitle: String = "Show impact",
        impactSectionSubtitle: String = "Ride momentum without moving silently. Move original Step only after you approve the receipt.",
        approvalTitle: String = "Approve replacement",
        whyNotThisTitle: String = "Why not this?",
        confirmTitle: String = "Approve",
        sourceStepID: String,
        sourceCandidateID: String?,
        contextFingerprint: String,
        recordedAt: String,
        noSilentChangesLabel: String = "Changes stay reviewable"
    ) {
        self.id = "today.step-replacement.\(sourceStepID)"
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Show another" : title
        self.subtitle = subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Pick a calm local replacement, then approve it explicitly." : subtitle
        self.contextLabel = contextLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Today" : contextLabel
        self.originalRecommendation = originalRecommendation
        self.originalHero = originalHero
        self.alternatives = Array(alternatives.prefix(5))
        self.defaultAlternativeID = defaultAlternativeID
        self.receiptPreviewTitle = receiptPreviewTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Review preview" : receiptPreviewTitle
        self.impactSectionTitle = impactSectionTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Show impact" : impactSectionTitle
        self.impactSectionSubtitle = impactSectionSubtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Ride momentum without moving silently. Move original Step only after you approve the receipt." : impactSectionSubtitle
        self.approvalTitle = approvalTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Approve replacement" : approvalTitle
        self.whyNotThisTitle = whyNotThisTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Why not this?" : whyNotThisTitle
        self.confirmTitle = confirmTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Approve" : confirmTitle
        self.sourceStepID = sourceStepID.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCandidateID = sourceCandidateID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceCandidateID = trimmedCandidateID?.isEmpty == true ? nil : trimmedCandidateID
        self.contextFingerprint = contextFingerprint.trimmingCharacters(in: .whitespacesAndNewlines)
        self.recordedAt = recordedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.noSilentChangesLabel = noSilentChangesLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Changes stay reviewable" : noSilentChangesLabel
    }
}

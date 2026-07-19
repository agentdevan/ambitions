import Foundation

struct StubTodayService: TodayServicing {
    let experience: TodayExperience
    let actionResponse: TodayActionResponse?

    init(experience: TodayExperience, actionResponse: TodayActionResponse? = nil) {
        self.experience = experience
        self.actionResponse = actionResponse
    }

    func loadTodayExperience(userDisplayName: String, now: Date, entryContext: TodayEntryContext) async throws -> TodayExperience {
        _ = userDisplayName
        _ = now
        _ = entryContext
        return experience
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        _ = action
        _ = now
        return actionResponse ?? TodayActionResponse(message: nil)
    }

    func recordActionClosure(_ closure: TodayActionClosureSheetState, outcome: TodayActionClosureOutcomeState, now: Date) async throws -> TodayActionResponse {
        _ = closure
        _ = outcome
        _ = now
        return actionResponse ?? TodayActionResponse(message: nil)
    }
}

import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedYouService {
    func profileLocationSummary(for profile: LifeContextProfile?) -> String {
        guard let profile else { return "Not captured" }
        var parts: [String] = []
        if let timezone = profile.timezone {
            parts.append(timezone)
        }
        if let location = profile.generalLocationLabel {
            parts.append(location)
        }
        if parts.isEmpty {
            return "Not captured"
        }
        return parts.joined(separator: " · ")
    }

    func travelRadiusSummary(for profile: LifeContextProfile?) -> String {
        guard let profile else { return "Not captured" }
        var parts: [String] = []
        if let minutes = profile.travelRadiusMinutes {
            parts.append("\(minutes) minutes")
        }
        if let miles = profile.travelRadiusMiles {
            parts.append(String(format: "%.1f miles", miles))
        }
        if parts.isEmpty {
            return "Not captured"
        }
        return parts.joined(separator: " · ")
    }

    func lifeContextDisplayTitle(for profile: LifeContextProfile?) -> String {
        guard let profile else { return "Life Context Profile" }
        if let schoolOrWorkContext = profile.schoolOrWorkContext, schoolOrWorkContext.isEmpty == false {
            return schoolOrWorkContext
        }
        if let location = profile.generalLocationLabel, location.isEmpty == false {
            return location
        }
        if let timezone = profile.timezone, timezone.isEmpty == false {
            return "Life context (\(timezone))"
        }
        return "Life context bundle"
    }

    func lifeContextDisplaySummary(for profile: LifeContextProfile?) -> String {
        guard let profile else { return "Life context bundle" }
        var parts: [String] = []
        let locationSummary = profileLocationSummary(for: profile)
        if locationSummary != "Not captured" {
            parts.append(locationSummary)
        }
        let transport = profile.transportationAccess == .unknown ? "Not captured" : displayLabel(for: profile.transportationAccess)
        if transport != "Not captured" {
            parts.append(transport)
        }
        let travel = travelRadiusSummary(for: profile)
        if travel != "Not captured" {
            parts.append(travel)
        }
        return parts.isEmpty ? "Life context bundle" : parts.joined(separator: " · ")
    }

    func facilitiesSummary(for bundle: LifeContextBundle?) -> String {
        guard let bundle, bundle.opportunityContexts.isEmpty == false else {
            return "Not captured"
        }
        let labels = bundle.opportunityContexts.flatMap(\.facilities).map { $0.rawValue.replacingOccurrences(of: "_", with: " ") }
        return labels.isEmpty ? "Not captured" : Array(Set(labels)).sorted().joined(separator: ", ")
    }

    func equipmentSummary(for bundle: LifeContextBundle?) -> String {
        guard let bundle else { return "Not captured" }
        let labels = bundle.opportunityContexts.flatMap(\.equipmentAccess)
        return labels.isEmpty ? "Not captured" : Array(Set(labels)).sorted().joined(separator: ", ")
    }

    func localOrganizationsSummary(for bundle: LifeContextBundle?) -> String {
        guard let bundle else { return "Not captured" }
        let labels = bundle.opportunityContexts.flatMap(\.localOrganizations)
        return labels.isEmpty ? "Not captured" : Array(Set(labels)).sorted().joined(separator: ", ")
    }

    func factSummary(for bundle: LifeContextBundle?, matching categories: [HistoricalContextFactCategory]) -> String {
        guard let bundle else { return "Not captured" }
        let facts = bundle.historicalFacts.filter { $0.isDeletedOrPaused == false && categories.contains($0.category) }
        guard facts.isEmpty == false else {
            return "Not captured"
        }
        return facts.prefix(2).map { $0.title }.joined(separator: ", ")
    }

    func factFreshness(for bundle: LifeContextBundle?, matching categories: [HistoricalContextFactCategory]) -> YouMemoryFreshness {
        guard let bundle else { return .basedOnOlderContext }
        let facts = bundle.historicalFacts.filter { $0.isDeletedOrPaused == false && categories.contains($0.category) }
        guard facts.isEmpty == false else {
            return .basedOnOlderContext
        }
        if facts.contains(where: { $0.freshness == .current }) {
            return .current
        }
        if facts.contains(where: { $0.freshness == .mayNeedReview }) {
            return .mayNeedReview
        }
        return .basedOnOlderContext
    }

    func factState(for bundle: LifeContextBundle?, matching categories: [HistoricalContextFactCategory]) -> AmbitionVisualState {
        switch factFreshness(for: bundle, matching: categories) {
        case .current:
            return .success
        case .mayNeedReview:
            return .warning
        case .basedOnOlderContext:
            return .default
        }
    }

    func deadlineSummary(for bundle: LifeContextBundle?, projection: LifeContextRuntimeProjection?) -> String {
        let anchors = bundle?.profile.scheduleAnchors ?? []
        let factWindows = bundle?.historicalFacts
            .filter { $0.isDeletedOrPaused == false && $0.usedFor.contains(.sequencing) }
            .prefix(2)
            .map { $0.title } ?? []
        let items = anchors + factWindows
        if items.isEmpty {
            return projection?.missingContextQuestions.isEmpty == false ? "Open questions still need review" : "Not captured"
        }
        return items.prefix(3).joined(separator: ", ")
    }

    func deadlineFreshness(for bundle: LifeContextBundle?, projection: LifeContextRuntimeProjection?) -> YouMemoryFreshness {
        guard let bundle else {
            return .basedOnOlderContext
        }
        if bundle.profile.scheduleAnchors.isEmpty == false {
            return .current
        }
        if projection?.missingContextQuestions.isEmpty == false {
            return .mayNeedReview
        }
        return .basedOnOlderContext
    }

    func deadlineState(for bundle: LifeContextBundle?, projection: LifeContextRuntimeProjection?) -> AmbitionVisualState {
        switch deadlineFreshness(for: bundle, projection: projection) {
        case .current:
            return .success
        case .mayNeedReview:
            return .warning
        case .basedOnOlderContext:
            return .default
        }
    }

    func olderContextSummary(for bundle: LifeContextBundle?, projection: LifeContextRuntimeProjection?) -> String {
        let staleSources = projection?.sourceFreshnessSummary
            .filter { $0.freshness != .current }
            .prefix(3)
            .map { $0.label } ?? []
        let staleFacts = bundle?.historicalFacts
            .filter { $0.isDeletedOrPaused == false && $0.freshness != .current }
            .prefix(2)
            .map { $0.title } ?? []
        let items = staleSources + staleFacts
        if items.isEmpty {
            return "Current"
        }
        return items.joined(separator: ", ")
    }

    func olderContextFreshness(for bundle: LifeContextBundle?, projection: LifeContextRuntimeProjection?) -> YouMemoryFreshness {
        let staleSources = projection?.sourceFreshnessSummary.contains(where: { $0.freshness != .current }) ?? false
        let staleFacts = bundle?.historicalFacts.contains(where: { $0.isDeletedOrPaused == false && $0.freshness != .current }) ?? false
        if staleSources || staleFacts {
            return .mayNeedReview
        }
        return .current
    }

    func olderContextState(for bundle: LifeContextBundle?, projection: LifeContextRuntimeProjection?) -> AmbitionVisualState {
        switch olderContextFreshness(for: bundle, projection: projection) {
        case .current:
            return .success
        case .mayNeedReview:
            return .warning
        case .basedOnOlderContext:
            return .default
        }
    }

    func lifeContextFreshnessLabel(bundle: LifeContextBundle?, projection: LifeContextRuntimeProjection?) -> String {
        switch olderContextFreshness(for: bundle, projection: projection) {
        case .current:
            return "Current"
        case .mayNeedReview:
            return "May Need Review"
        case .basedOnOlderContext:
            return "Based on Older Context"
        }
    }

    func memoryFreshness(for freshness: LifeContextFreshness) -> YouMemoryFreshness {
        switch freshness {
        case .current:
            return .current
        case .mayNeedReview:
            return .mayNeedReview
        case .basedOnOlderContext, .stale:
            return .basedOnOlderContext
        }
    }

    func memoryFreshness(for freshness: HistoricalContextFactFreshness) -> YouMemoryFreshness {
        switch freshness {
        case .current:
            return .current
        case .mayNeedReview:
            return .mayNeedReview
        case .basedOnOlderContext, .stale:
            return .basedOnOlderContext
        }
    }

    func displayLabel(for lifeStage: LifeContextLifeStage) -> String {
        switch lifeStage {
        case .middleSchool:
            return "Middle school"
        case .highSchool:
            return "High school"
        case .college:
            return "College"
        case .earlyCareer:
            return "Early career"
        case .adult:
            return "Adult"
        case .parent:
            return "Parent"
        case .caregiver:
            return "Caregiver"
        case .custom:
            return "Custom"
        case .unknown:
            return "Not captured"
        }
    }

    func displayLabel(for transportationAccess: LifeContextTransportationAccess) -> String {
        switch transportationAccess {
        case .walk:
            return "Walk"
        case .bike:
            return "Bike"
        case .transit:
            return "Transit"
        case .rideshare:
            return "Rideshare"
        case .car:
            return "Car"
        case .parentGuardian:
            return "Parent or guardian"
        case .limited:
            return "Limited"
        case .custom:
            return "Custom"
        case .unknown:
            return "Not captured"
        }
    }

}

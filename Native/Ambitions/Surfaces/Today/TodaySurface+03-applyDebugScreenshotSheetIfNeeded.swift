import AmbitionsDesignSystem
import Foundation
import SwiftUI

// Accessibility contract: screenshot-state helper preserves TodaySurface root semantics and does not render standalone controls.
extension TodaySurface {
    #if DEBUG
    @MainActor
    func applyDebugScreenshotSheetIfNeeded() {
        guard debugScreenshotSheetApplied == false else { return }
        guard case .loaded = viewModel.state else { return }
        guard let sheet = debugScreenshotSheet else { return }
        guard let rail = currentDisplayRail(), let heroStep = rail.heroStep else { return }

        switch sheet {
        case "trust":
            selectedStepDetail = heroStep.stepDetail(
                privacy: rail.privacyProjection,
                contextLabel: rail.contextSummary
            )
        case "receipt":
            selectedActionClosure = actionClosureState(for: heroStep.primaryAction)
        default:
            return
        }

        debugScreenshotSheetApplied = true
    }


    var debugScreenshotEntryContext: TodayEntryContext? {
        debugLaunchArgumentValue(for: "AmbitionsTodayEntryContext")
            .flatMap(TodayEntryContext.init(rawValue:))
    }


    var debugScreenshotSheet: String? {
        debugLaunchArgumentValue(for: "AmbitionsTodaySheet")?.lowercased()
    }


    func debugLaunchArgumentValue(for key: String) -> String? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-\(key)"),
              arguments.indices.contains(index + 1) else {
            return nil
        }
        let value = arguments[index + 1].trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
    #endif


    var shell: AppShellCapability {
        guard let appShellCapability else {
            preconditionFailure("App shell capability must be injected.")
        }
        return appShellCapability
    }


    var featureFactory: AppFeatureFactoryCapability {
        guard let appFeatureFactoryCapability else {
            preconditionFailure("App feature factory capability must be injected.")
        }
        return appFeatureFactoryCapability
    }


    var clock: any AmbitionsClock {
        featureFactory.clock
    }


    var userSystem: AppUserSystemCapability {
        guard let appUserSystemCapability else {
            preconditionFailure("App user system capability must be injected.")
        }
        return appUserSystemCapability
    }
}
import AmbitionsTimeFoundation

import AmbitionsExperienceKernel
import Foundation

enum AmbitionsExperienceKernelIntegration {
    static let packageProductName = "AmbitionsExperienceKernel"

    static var canonicalSurfaceCount: Int {
        AmbitionsSurfaceContracts.canonical.count
    }

    static var todayPrimaryObjectName: String {
        AmbitionsSurfaceContracts.contract(for: .today).primaryObject.rawValue
    }
}

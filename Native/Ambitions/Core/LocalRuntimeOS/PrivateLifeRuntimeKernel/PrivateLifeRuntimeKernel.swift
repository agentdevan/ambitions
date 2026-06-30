import Foundation

struct PrivateLifeRuntimeKernel: PrivateLifeRuntimeKernelContracting, Sendable, Equatable {
    let boundary: PrivateLifeRuntimeBoundary

    init(boundary: PrivateLifeRuntimeBoundary = .localOnly) {
        self.boundary = boundary
    }
}

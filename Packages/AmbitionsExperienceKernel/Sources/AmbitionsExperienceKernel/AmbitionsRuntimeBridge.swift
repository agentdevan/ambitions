import Foundation

public protocol AmbitionsPrivateRuntimeReadable: Sendable {
    func currentExperienceInput(for surface: AmbitionsSurface) async throws -> AmbitionsRuntimeSnapshotInput
    func proofReceipts(for surface: AmbitionsSurface) async throws -> [AmbitionsProofReceipt]
    func replayTrace(for surface: AmbitionsSurface) async throws -> AmbitionsReplayTrace
}

public struct AmbitionsRuntimeBridge<Runtime: AmbitionsPrivateRuntimeReadable>: Sendable {
    public let runtime: Runtime
    public let calibration: AmbitionsCompilerCalibration

    public init(runtime: Runtime, calibration: AmbitionsCompilerCalibration = .init()) {
        self.runtime = runtime
        self.calibration = calibration
    }

    public func visualState(for surface: AmbitionsSurface) async throws -> AmbitionsVisualFieldState {
        let input = try await runtime.currentExperienceInput(for: surface)
        return AmbitionsExperienceCompiler.compile(input, calibration: calibration)
    }
}

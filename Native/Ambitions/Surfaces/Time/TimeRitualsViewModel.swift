import Foundation
import Observation

@MainActor
@Observable
final class TimeRitualsViewModel {
    var state: AsyncViewState<TimeRitualsDashboard>
    var inlineMessage: TimeRitualInlineMessage?
    var mutationProof: TimeRitualsMutationProof?

    private var hasLoaded = false

    var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case let .loaded(dashboard):
            return "loaded:\(dashboard.mode):\(dashboard.rituals.count):\(dashboard.recoveryRituals.count)"
        case let .failed(message):
            return "failed:\(message)"
        }
    }

    var accessibilitySummary: String {
        TimeRitualsAccessibility.summary(for: state, inlineMessage: inlineMessage)
    }

    init(
        state: AsyncViewState<TimeRitualsDashboard> = .loading,
        inlineMessage: TimeRitualInlineMessage? = nil
    ) {
        self.state = state
        self.inlineMessage = inlineMessage
    }

    func load(using service: any TimeRitualsServicing, now: Date) async {
        guard hasLoaded == false else { return }
        hasLoaded = true
        await refresh(using: service, now: now)
    }

    func refresh(using service: any TimeRitualsServicing, now: Date) async {
        do {
            state = .loaded(try await service.loadDashboard(now: now))
        } catch {
            state = .failed("Unable to load Rituals: \(error.localizedDescription)")
        }
    }

    func perform(
        _ action: TimeRitualActionState,
        using service: any TimeRitualsServicing,
        runtimeClient: RuntimeCommandClient,
        now: Date
    ) async {
        do {
            guard action.kind != .openDetail,
                  let preparer = service as? any TimeRitualDurableActionPreparing else {
                throw TimeRitualDurableActionError.unavailable
            }
            let request = TimeRitualActionRequest(
                kind: action.kind,
                target: action.target,
                operationID: UUID().uuidString
            )
            let prepared = try await preparer.prepareDurableAction(
                request,
                now: now
            )
            let result = await runtimeClient.execute(prepared.command, prepared.context)
            guard result.status == .succeeded,
                  result.metadata["runtimeReceiptID"] != nil,
                  result.metadata["runtimeProjectionStoreStatus"] == "saved",
                  result.metadata["timeRitualActionMaterialization"] == "saved_post_authority",
                  await Self.hasMatchingTimeProjection(result, client: runtimeClient) else {
                throw TimeRitualDurableActionError.needsRecovery
            }
            let response = prepared.response
            inlineMessage = response.message
            await refresh(using: service, now: now)
            mutationProof = TimeRitualsMutationProof(action: action, response: response)
        } catch {
            inlineMessage = TimeRitualInlineMessage(
                title: "Ritual action could not finish",
                body: error.localizedDescription,
                state: .warning
            )
            mutationProof = TimeRitualsMutationProof.failed(action: action, message: error.localizedDescription)
        }
    }

    private static func hasMatchingTimeProjection(
        _ result: AmbitionsCommandExecutionResult,
        client: RuntimeCommandClient
    ) async -> Bool {
        guard let projection = try? await client.projection(.time) else { return false }
        let usesMaterializedCursor = result.metadata["runtimeMaterializedProjectionCursorIDs"]?.isEmpty == false
        let cursorPrefix = usesMaterializedCursor
            ? "runtimeMaterializedProjectionCursor"
            : "runtimeProjectionCursor"
        let ids = result.metadata["\(cursorPrefix)IDs"]?.split(separator: ",").map(String.init) ?? []
        let sequences = result.metadata["\(cursorPrefix)Sequences"]?.split(separator: ",").compactMap { Int64($0) } ?? []
        let checksums = result.metadata["\(cursorPrefix)Checksums"]?.split(separator: ",").map(String.init) ?? []
        guard ids.count == sequences.count, ids.count == checksums.count,
              let index = ids.firstIndex(of: ProjectionID.time.rawValue) else { return false }
        return projection.projectionID == ProjectionID.time.rawValue
            && projection.eventSequence == sequences[index]
            && projection.cursorChecksum == checksums[index]
    }

    func recordStageRouteMutation(action: TimeRitualActionState) {
        mutationProof = TimeRitualsMutationProof.route(action: action)
    }

    func recordStageRouteMutation(label: String, routeID: String) {
        mutationProof = TimeRitualsMutationProof.route(label: label, routeID: routeID)
    }
}

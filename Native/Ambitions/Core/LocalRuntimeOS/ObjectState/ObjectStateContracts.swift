import Foundation

protocol ObjectStateReadableStore: Sendable {
    associatedtype StoredObject: Sendable
    var family: ObjectStateFamily { get }
}

protocol ObjectStateWritableStore: ObjectStateReadableStore {
    func save(_ object: StoredObject, context: RuntimeObjectStateMutationContext) async throws -> ObjectStateWriteReceipt
}

protocol GoalThreadStore: ObjectStateWritableStore where StoredObject == GoalThread {
    func fetchThread(id: String) async throws -> GoalThread?
}

protocol LifeAreaStore: ObjectStateReadableStore where StoredObject == LifeAreaDefinition {
    func listLifeAreas() async throws -> [LifeAreaDefinition]
}

protocol StepStore: ObjectStateWritableStore where StoredObject == Step {
    func fetchStep(id: String) async throws -> Step?
}

protocol CaptureStore: ObjectStateWritableStore where StoredObject == Capture {
    func fetchCapture(id: String) async throws -> Capture?
}

protocol TimeBlockStore: ObjectStateWritableStore where StoredObject == TimeBlockObjectState {
    func fetchTimeBlock(id: String) async throws -> TimeBlockObjectState?
}

protocol ClosureStore: ObjectStateWritableStore where StoredObject == ClosureObjectState {
    func fetchClosure(id: String) async throws -> ClosureObjectState?
}

protocol ProofStore: ObjectStateWritableStore where StoredObject == ProofEvent {
    func fetchProof(id: String) async throws -> ProofEvent?
}

protocol ReceiptStore: ObjectStateWritableStore where StoredObject == ActionReceiptHistoryRecord {
    func fetchReceipt(id: String) async throws -> ActionReceiptHistoryRecord?
}

protocol UserSystemStore: ObjectStateWritableStore where StoredObject == UserSystemObjectState {
    func fetchUserSystem(id: String) async throws -> UserSystemObjectState?
}

protocol AppStateStore: ObjectStateWritableStore where StoredObject == AppStateSnapshot {
    func loadState() async throws -> AppStateSnapshot
}

struct TimeBlockObjectState: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let startsAt: String?
    let endsAt: String?
    let privacyClass: AmbitionPrivacyClass
}

struct ClosureObjectState: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let objectID: String
    let state: String
    let receiptIDs: [String]
    let privacyClass: AmbitionPrivacyClass
}

struct UserSystemObjectState: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sourceAppStateID: String
    let visiblePreferenceKeys: [String]
    let privacyClass: AmbitionPrivacyClass
}

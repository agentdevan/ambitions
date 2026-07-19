import Foundation

extension StepElasticityEngineInput {
    var goalReferenceID: String {
        graphRecord.goalReferenceID
    }
}

extension StepElasticityRecord {
    func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

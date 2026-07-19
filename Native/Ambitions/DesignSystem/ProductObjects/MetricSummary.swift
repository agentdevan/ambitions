import Foundation

struct MetricSummary: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let value: String
    let detail: String?
    let icon: String
}

import Foundation

// Compatibility aliases for older LifeKnowledgeOperationModels test and caller surfaces.
//
// These are intentionally source-only shims:
// - `Store.exportSnapshot` is the canonical property, but older call sites may still
//   use `store.exportSnapshot()`; `callAsFunction` preserves that compatibility
//   without changing the canonical property.
// - `Reflection` remains the app-wide model type. The nested typealias allows older
//   `LifeKnowledgeOperationModels.Reflection(...)` call sites to resolve to the
//   canonical model without duplicating a second nested Reflection structure.

typealias AmbitionsLifeKnowledgeReflection = Reflection

extension LifeKnowledgeOperationModels {
    typealias Reflection = AmbitionsLifeKnowledgeReflection
}

extension LifeKnowledgeOperationModels.ExportSnapshot {
    func callAsFunction() -> LifeKnowledgeOperationModels.ExportSnapshot {
        self
    }
}

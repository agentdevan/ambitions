import Foundation

let persistedValueDegradationSchemaVersion = "persisted_value_degradation.native.v1"

enum PersistedValueDegradationReason: String, Sendable, Equatable, Hashable {
    case unknownRawValue = "unknown_raw_value"
    case legacyAlias = "legacy_alias"
    case missingOptionalRawValue = "missing_optional_raw_value"
}

enum PersistedValueDegradationDisposition: String, Sendable, Equatable, Hashable {
    case deterministicFallback = "deterministic_fallback"
    case optionalNilFallback = "optional_nil_fallback"
}

struct PersistedValueDegradationEntry: Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let schemaVersion: String
    let storedTypeName: String
    let fieldName: String
    let rawValue: String?
    let fallbackRawValue: String?
    let reason: PersistedValueDegradationReason
    let disposition: PersistedValueDegradationDisposition
    let requiresReview: Bool
    let blocksMigrationClaim: Bool

    init(
        storedTypeName: String,
        fieldName: String,
        rawValue: String?,
        fallbackRawValue: String?,
        reason: PersistedValueDegradationReason,
        disposition: PersistedValueDegradationDisposition,
        requiresReview: Bool = true,
        blocksMigrationClaim: Bool = true,
        schemaVersion: String = persistedValueDegradationSchemaVersion
    ) {
        self.id = [
            storedTypeName,
            fieldName,
            reason.rawValue,
            rawValue ?? "nil",
            fallbackRawValue ?? "nil",
        ].joined(separator: ".")
        self.schemaVersion = schemaVersion
        self.storedTypeName = storedTypeName
        self.fieldName = fieldName
        self.rawValue = rawValue
        self.fallbackRawValue = fallbackRawValue
        self.reason = reason
        self.disposition = disposition
        self.requiresReview = requiresReview
        self.blocksMigrationClaim = blocksMigrationClaim
    }
}

struct PersistedValueResolution<Value: Sendable & Equatable>: Sendable, Equatable {
    let value: Value
    let degradation: PersistedValueDegradationEntry?
}

struct OptionalPersistedValueResolution<Value: Sendable & Equatable>: Sendable, Equatable {
    let value: Value?
    let degradation: PersistedValueDegradationEntry?
}

enum PersistedValueDegradation {
    static func resolve<Value>(
        _ type: Value.Type,
        rawValue: String,
        fallback: Value,
        storedTypeName: String,
        fieldName: String,
        legacyAliases: [String: Value] = [:]
    ) -> PersistedValueResolution<Value> where Value: RawRepresentable & Sendable & Equatable, Value.RawValue == String {
        if let value = Value(rawValue: rawValue) {
            return PersistedValueResolution(value: value, degradation: nil)
        }

        if let value = legacyAliases[rawValue] {
            return PersistedValueResolution(
                value: value,
                degradation: PersistedValueDegradationEntry(
                    storedTypeName: storedTypeName,
                    fieldName: fieldName,
                    rawValue: rawValue,
                    fallbackRawValue: value.rawValue,
                    reason: .legacyAlias,
                    disposition: .deterministicFallback,
                    requiresReview: false
                )
            )
        }

        return PersistedValueResolution(
            value: fallback,
            degradation: PersistedValueDegradationEntry(
                storedTypeName: storedTypeName,
                fieldName: fieldName,
                rawValue: rawValue,
                fallbackRawValue: fallback.rawValue,
                reason: .unknownRawValue,
                disposition: .deterministicFallback
            )
        )
    }

    static func resolveOptional<Value>(
        _ type: Value.Type,
        rawValue: String?,
        storedTypeName: String,
        fieldName: String,
        legacyAliases: [String: Value] = [:]
    ) -> OptionalPersistedValueResolution<Value> where Value: RawRepresentable & Sendable & Equatable, Value.RawValue == String {
        guard let rawValue else {
            return OptionalPersistedValueResolution(value: nil, degradation: nil)
        }

        if let value = Value(rawValue: rawValue) {
            return OptionalPersistedValueResolution(value: value, degradation: nil)
        }

        if let value = legacyAliases[rawValue] {
            return OptionalPersistedValueResolution(
                value: value,
                degradation: PersistedValueDegradationEntry(
                    storedTypeName: storedTypeName,
                    fieldName: fieldName,
                    rawValue: rawValue,
                    fallbackRawValue: value.rawValue,
                    reason: .legacyAlias,
                    disposition: .deterministicFallback,
                    requiresReview: false
                )
            )
        }

        return OptionalPersistedValueResolution(
            value: nil,
            degradation: PersistedValueDegradationEntry(
                storedTypeName: storedTypeName,
                fieldName: fieldName,
                rawValue: rawValue,
                fallbackRawValue: nil,
                reason: .unknownRawValue,
                disposition: .optionalNilFallback
            )
        )
    }
}

enum PersistedTemporalValue {
    private static func internetDateTimeFormatter() -> ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }

    private static func fractionalInternetDateTimeFormatter() -> ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }

    static func date(from rawValue: String?, fallback: Date = .distantPast) -> Date {
        guard let rawValue else { return fallback }
        return fractionalInternetDateTimeFormatter().date(from: rawValue)
            ?? internetDateTimeFormatter().date(from: rawValue)
            ?? fallback
    }

    static func dateKey(primary date: Date?, rawValue: String?) -> Date {
        date ?? self.date(from: rawValue)
    }

    static func rawString(from date: Date) -> String {
        internetDateTimeFormatter().string(from: date)
    }
}

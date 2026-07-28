import Foundation

struct RuntimeRevisionedOrderKey: Codable, Sendable, Equatable, Hashable, Comparable {
    let objectID: RuntimeDomainObjectID
    let revision: UInt64
    let eventID: RuntimeEventID

    static func < (lhs: RuntimeRevisionedOrderKey, rhs: RuntimeRevisionedOrderKey) -> Bool {
        if lhs.objectID != rhs.objectID {
            return lhs.objectID < rhs.objectID
        }
        if lhs.revision != rhs.revision {
            return lhs.revision < rhs.revision
        }
        return lhs.eventID < rhs.eventID
    }
}

enum RuntimeStableOrdering {
    /// Identity values are ordered by their normalized UTF-8 bytes.
    static func identities<Identities: Sequence>(_ identities: Identities) -> [Identities.Element]
    where Identities.Element: RuntimeIdentityValue {
        identities.sorted()
    }

    /// Records are ordered by object, revision, and event identity; equal keys retain their original input order.
    static func revisioned<Records: Sequence>(
        _ records: Records,
        key: (Records.Element) -> RuntimeRevisionedOrderKey
    ) -> [Records.Element] {
        records.enumerated().sorted { lhs, rhs in
            let lhsKey = key(lhs.element)
            let rhsKey = key(rhs.element)
            return lhsKey == rhsKey ? lhs.offset < rhs.offset : lhsKey < rhsKey
        }.map { $0.element }
    }
}

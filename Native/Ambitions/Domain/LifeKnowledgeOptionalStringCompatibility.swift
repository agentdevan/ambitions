import Foundation

extension Optional where Wrapped == String {
    func compactMap(_ transform: (String) throws -> String?) rethrows -> [String] {
        guard let wrapped = self else { return [] }
        guard let transformed = try transform(wrapped) else { return [] }
        return [transformed]
    }
}

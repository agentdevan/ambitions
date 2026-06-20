import Foundation

extension SourceAtlasClaimCandidateExtractor {

    static func locatorHint(for sourceLocator: String?) -> SourceAtlasClaimCandidateLocatorHint {
        guard let sourceLocator else {
            return SourceAtlasClaimCandidateLocatorHint(
                sourceLocator: nil,
                pageNumber: nil,
                lineNumber: nil,
                pageLocator: nil,
                lineLocator: nil
            )
        }

        let lowercased = sourceLocator.lowercased()
        let pageNumber = Self.firstCapturedInteger(
            in: lowercased,
            pattern: #"page\s*[:.]?\s*(\d+)"#
        ) ?? Self.firstCapturedInteger(
            in: lowercased,
            pattern: #"\bp\.\s*(\d+)"#
        )
        let lineNumber = Self.firstCapturedInteger(
            in: lowercased,
            pattern: #"lines?\s*[:.]?\s*(\d+)"#
        )

        return SourceAtlasClaimCandidateLocatorHint(
            sourceLocator: sourceLocator,
            pageNumber: pageNumber,
            lineNumber: lineNumber,
            pageLocator: pageNumber.map { "page:\($0)" },
            lineLocator: lineNumber.map { "line:\($0)" }
        )
    }


    static func firstCapturedInteger(in text: String, pattern: String) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: range), match.numberOfRanges > 1 else {
            return nil
        }
        let capturedRange = match.range(at: 1)
        guard let swiftRange = Range(capturedRange, in: text) else {
            return nil
        }
        return Int(text[swiftRange])
    }


    static func deterministicID(seed: String) -> String {
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in seed.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 1_099_511_628_211
        }
        return String(format: "fnv1a64:%016llx", hash)
    }
}

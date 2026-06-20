import Foundation

let sourceAtlasPackFactoryLiteSchemaVersion = "source_atlas_pack_factory_lite.native.v1"

enum SourceAtlasPackFactoryLiteInputFormat: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case json
    case yaml
}

enum SourceAtlasPackFactoryLiteError: Error, Equatable, Sendable, Hashable {
    case malformedJSON
    case malformedYAML(String)
    case unsupportedYAMLFeature(String)
    case validationFailed([SourceAtlasValidationIssue])
}

struct SourceAtlasPackFactoryLite: Sendable, Equatable, Hashable {
    private let validator: SourceAtlasPackValidator

    init(validator: SourceAtlasPackValidator = SourceAtlasPackValidator()) {
        self.validator = validator
    }

    func decodePack(
        from data: Data,
        format: SourceAtlasPackFactoryLiteInputFormat
    ) throws -> SourceAtlasPack {
        switch format {
        case .json:
            return try decodeJSONPack(from: data)
        case .yaml:
            if let pack = try? decodeJSONPack(from: data) {
                return pack
            }
            let jsonData = try Self.yamlToJSONData(data)
            return try decodeJSONPack(from: jsonData)
        }
    }

    func makePack(
        from data: Data,
        format: SourceAtlasPackFactoryLiteInputFormat
    ) throws -> SourceAtlasPack {
        let pack = try decodePack(from: data, format: format)
        let issues = validator.validate(pack)
        guard issues.isEmpty else {
            throw SourceAtlasPackFactoryLiteError.validationFailed(issues)
        }
        return pack
    }

    func validate(_ pack: SourceAtlasPack) -> [SourceAtlasValidationIssue] {
        validator.validate(pack)
    }

    private func decodeJSONPack(from data: Data) throws -> SourceAtlasPack {
        do {
            return try JSONDecoder().decode(SourceAtlasPack.self, from: data)
        } catch {
            throw SourceAtlasPackFactoryLiteError.malformedJSON
        }
    }

    private static func yamlToJSONData(_ data: Data) throws -> Data {
        guard let text = String(data: data, encoding: .utf8) else {
            throw SourceAtlasPackFactoryLiteError.malformedYAML("utf8")
        }

        var parser = YAMLParser(text: text)
        let value: SourceAtlasPackFactoryLiteYAMLValue
        do {
            value = try parser.parse()
        } catch let error as YAMLParser.ParserError {
            switch error {
            case .malformedLine(let line), .trailingContent(let line):
                throw SourceAtlasPackFactoryLiteError.malformedYAML(line)
            case .unsupportedFeature(let feature):
                throw SourceAtlasPackFactoryLiteError.unsupportedYAMLFeature(feature)
            }
        }
        guard JSONSerialization.isValidJSONObject(value.jsonObject) else {
            throw SourceAtlasPackFactoryLiteError.malformedYAML("json-bridge")
        }
        return try JSONSerialization.data(withJSONObject: value.jsonObject, options: [])
    }
}

private enum SourceAtlasPackFactoryLiteYAMLValue {
    case object([String: SourceAtlasPackFactoryLiteYAMLValue])
    case array([SourceAtlasPackFactoryLiteYAMLValue])
    case string(String)
    case number(Double)
    case bool(Bool)
    case null

    var jsonObject: Any {
        switch self {
        case .object(let dictionary):
            return dictionary.mapValues(\.jsonObject)
        case .array(let values):
            return values.map(\.jsonObject)
        case .string(let value):
            return value
        case .number(let value):
            return value
        case .bool(let value):
            return value
        case .null:
            return NSNull()
        }
    }
}

private struct YAMLParser {
    struct Line: Equatable {
        let indent: Int
        let content: String
    }

    enum ParserError: Error, Equatable {
        case malformedLine(String)
        case unsupportedFeature(String)
        case trailingContent(String)
    }

    let lines: [Line]
    var index: Int = 0

    init(text: String) {
        self.lines = text
            .components(separatedBy: .newlines)
            .compactMap { rawLine in
                let trimmed = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
                guard trimmed.isEmpty == false, trimmed.hasPrefix("#") == false else {
                    return nil
                }
                let leadingSpaces = rawLine.prefix { $0 == " " }.count
                return Line(
                    indent: leadingSpaces,
                    content: rawLine.trimmingCharacters(in: .whitespaces)
                )
            }
    }

    mutating func parse() throws -> SourceAtlasPackFactoryLiteYAMLValue {
        skipIgnorable()
        guard index < lines.count else {
            throw ParserError.malformedLine("empty-document")
        }
        let value = try parseNode(expectedIndent: lines[index].indent)
        skipIgnorable()
        guard index == lines.count else {
            throw ParserError.trailingContent(lines[index].content)
        }
        return value
    }

    private mutating func parseNode(expectedIndent: Int) throws -> SourceAtlasPackFactoryLiteYAMLValue {
        skipIgnorable()
        guard index < lines.count else {
            throw ParserError.malformedLine("unexpected-end-of-document")
        }

        let line = lines[index]
        guard line.indent >= expectedIndent else {
            throw ParserError.malformedLine(line.content)
        }

        if line.content.hasPrefix("-") {
            return try parseSequence(indent: line.indent)
        }
        return try parseMapping(indent: line.indent)
    }

    private mutating func parseSequence(indent: Int) throws -> SourceAtlasPackFactoryLiteYAMLValue {
        var items: [SourceAtlasPackFactoryLiteYAMLValue] = []

        while true {
            skipIgnorable()
            guard index < lines.count else {
                break
            }

            let line = lines[index]
            guard line.indent == indent, line.content.hasPrefix("-") else {
                break
            }

            let itemContent = Self.trimmedSequenceItem(line.content)
            index += 1

            if itemContent.isEmpty {
                skipIgnorable()
                guard index < lines.count, lines[index].indent > indent else {
                    throw ParserError.malformedLine(line.content)
                }
                items.append(try parseNode(expectedIndent: lines[index].indent))
                continue
            }

            if let keyValue = Self.parseKeyValue(itemContent) {
                var dictionary: [String: SourceAtlasPackFactoryLiteYAMLValue] = [
                    keyValue.key: try parseScalar(keyValue.value)
                ]

                if let next = peekNonIgnorable(), next.indent > indent {
                    let nested = try parseNode(expectedIndent: next.indent)
                    guard case .object(let nestedDictionary) = nested else {
                        throw ParserError.unsupportedFeature("sequence-scalar-child")
                    }
                    dictionary.merge(nestedDictionary) { _, new in new }
                }

                items.append(.object(dictionary))
                continue
            }

            if let next = peekNonIgnorable(), next.indent > indent {
                throw ParserError.unsupportedFeature("nested-scalar-sequence")
            }
            items.append(try parseScalar(itemContent))
        }

        return .array(items)
    }

    private mutating func parseMapping(indent: Int) throws -> SourceAtlasPackFactoryLiteYAMLValue {
        var dictionary: [String: SourceAtlasPackFactoryLiteYAMLValue] = [:]

        while true {
            skipIgnorable()
            guard index < lines.count else {
                break
            }

            let line = lines[index]
            guard line.indent == indent, line.content.hasPrefix("-") == false else {
                break
            }

            guard let pair = Self.parseKeyValue(line.content) else {
                throw ParserError.malformedLine(line.content)
            }
            index += 1

            if dictionary[pair.key] != nil {
                throw ParserError.malformedLine(pair.key)
            }

            if pair.value.isEmpty {
                skipIgnorable()
                guard index < lines.count, lines[index].indent > indent else {
                    dictionary[pair.key] = .array([])
                    continue
                }
                dictionary[pair.key] = try parseNode(expectedIndent: lines[index].indent)
            } else {
                dictionary[pair.key] = try parseScalar(pair.value)
            }
        }

        return .object(dictionary)
    }

    private mutating func parseScalar(_ rawValue: String) throws -> SourceAtlasPackFactoryLiteYAMLValue {
        let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard value.isEmpty == false else {
            return .null
        }

        if value.hasPrefix("[") || value.hasPrefix("{") {
            throw ParserError.unsupportedFeature("flow-style")
        }

        if value.hasPrefix("&") || value.hasPrefix("*") || value.hasPrefix("!") ||
            value.contains("\t") || value == "---" || value == "..." {
            throw ParserError.unsupportedFeature(value)
        }

        if value.hasPrefix("\""), value.hasSuffix("\""), value.count >= 2 {
            return .string(Self.unescapeDoubleQuoted(String(value.dropFirst().dropLast())))
        }

        if value.hasPrefix("'"), value.hasSuffix("'"), value.count >= 2 {
            return .string(String(value.dropFirst().dropLast()).replacingOccurrences(of: "''", with: "'"))
        }

        let lowercased = value.lowercased()
        if lowercased == "null" || value == "~" {
            return .null
        }
        if lowercased == "true" {
            return .bool(true)
        }
        if lowercased == "false" {
            return .bool(false)
        }
        if let intValue = Int(value) {
            return .number(Double(intValue))
        }
        if let doubleValue = Double(value) {
            return .number(doubleValue)
        }
        return .string(value)
    }

    private mutating func skipIgnorable() {
        while index < lines.count {
            let content = lines[index].content.trimmingCharacters(in: .whitespacesAndNewlines)
            if content.isEmpty || content.hasPrefix("#") {
                index += 1
                continue
            }
            break
        }
    }

    private func peekNonIgnorable() -> Line? {
        var probe = index
        while probe < lines.count {
            let content = lines[probe].content.trimmingCharacters(in: .whitespacesAndNewlines)
            if content.isEmpty || content.hasPrefix("#") {
                probe += 1
                continue
            }
            return lines[probe]
        }
        return nil
    }

    private static func parseKeyValue(_ line: String) -> (key: String, value: String)? {
        guard let separatorIndex = line.firstIndex(of: ":") else {
            return nil
        }

        let suffixStart = line.index(after: separatorIndex)
        let suffix = line[suffixStart...]
        if suffix.isEmpty == false, suffix.first?.isWhitespace == false {
            return nil
        }

        let key = line[..<separatorIndex].trimmingCharacters(in: .whitespaces)
        let value = String(suffix).trimmingCharacters(in: .whitespaces)
        guard key.isEmpty == false else {
            return nil
        }
        return (String(key), value)
    }

    private static func trimmedSequenceItem(_ line: String) -> String {
        let withoutDash = line.dropFirst()
        return withoutDash.trimmingCharacters(in: .whitespaces)
    }

    private static func unescapeDoubleQuoted(_ value: String) -> String {
        var result = ""
        var isEscaping = false

        for character in value {
            if isEscaping {
                switch character {
                case "\"":
                    result.append("\"")
                case "\\":
                    result.append("\\")
                case "n":
                    result.append("\n")
                case "t":
                    result.append("\t")
                default:
                    result.append(character)
                }
                isEscaping = false
                continue
            }

            if character == "\\" {
                isEscaping = true
                continue
            }
            result.append(character)
        }

        if isEscaping {
            result.append("\\")
        }

        return result
    }
}

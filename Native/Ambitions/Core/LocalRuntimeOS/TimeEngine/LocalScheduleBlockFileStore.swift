import Foundation

func localScheduleBlocks(from data: Data, decoder: JSONDecoder = JSONDecoder()) throws -> [ScheduledAmbitionsBlock] {
    try decoder.decode([ScheduledAmbitionsBlock].self, from: data)
}

func localScheduleExportData(
    for blocks: [ScheduledAmbitionsBlock],
    encoder: JSONEncoder = JSONEncoder()
) throws -> Data {
    try encoder.encode(blocks)
}

func loadLocalScheduleBlocks(from fileURL: URL, decoder: JSONDecoder = JSONDecoder()) throws -> [ScheduledAmbitionsBlock] {
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
        return []
    }
    return try localScheduleBlocks(from: Data(contentsOf: fileURL), decoder: decoder)
}

@discardableResult
func saveLocalScheduleBlocks(
    _ blocks: [ScheduledAmbitionsBlock],
    to fileURL: URL,
    encoder: JSONEncoder = JSONEncoder()
) throws -> [String] {
    try FileManager.default.createDirectory(
        at: fileURL.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )
    let sortedBlocks = blocks.sorted {
        if $0.start != $1.start {
            return $0.start < $1.start
        }
        return $0.id < $1.id
    }
    try localScheduleExportData(for: sortedBlocks, encoder: encoder)
        .write(to: fileURL, options: [.atomic])
    return sortedBlocks.map { $0.localScheduleReceiptID(action: "save") }
}

@discardableResult
func upsertLocalScheduleBlock(
    _ block: ScheduledAmbitionsBlock,
    in fileURL: URL,
    decoder: JSONDecoder = JSONDecoder(),
    encoder: JSONEncoder = JSONEncoder()
) throws -> [String] {
    let existing = try loadLocalScheduleBlocks(from: fileURL, decoder: decoder)
    let retained = existing.filter { $0.id != block.id }
    return try saveLocalScheduleBlocks(retained + [block], to: fileURL, encoder: encoder)
}

@discardableResult
func deleteLocalScheduleBlock(
    id: String,
    from fileURL: URL,
    decoder: JSONDecoder = JSONDecoder(),
    encoder: JSONEncoder = JSONEncoder()
) throws -> String? {
    let existing = try loadLocalScheduleBlocks(from: fileURL, decoder: decoder)
    guard existing.contains(where: { $0.id == id }) else {
        return nil
    }
    let retained = existing.filter { $0.id != id }
    _ = try saveLocalScheduleBlocks(retained, to: fileURL, encoder: encoder)
    return "Receipt.local-schedule.\(id).delete"
}

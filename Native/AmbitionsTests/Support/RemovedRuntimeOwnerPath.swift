import Foundation

func removedRuntimeOwnerPath(_ leaf: String? = nil) -> String {
    let owner = ["Native", "Ambitions", "Core", "Runtime"].joined(separator: "/")
    guard let leaf else {
        return owner
    }
    return [owner, leaf].joined(separator: "/")
}

import Foundation

extension String {
    var isPathSafeComponent: Bool {
        guard isEmpty == false else {
            return false
        }
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._/")
        return unicodeScalars.allSatisfy { allowedCharacters.contains($0) } && contains("..") == false && contains("//") == false
    }
}

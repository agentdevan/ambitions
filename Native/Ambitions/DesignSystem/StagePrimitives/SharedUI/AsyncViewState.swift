import Foundation

enum AsyncViewState<Value> {
    case loading
    case loaded(Value)
    case failed(String)
}

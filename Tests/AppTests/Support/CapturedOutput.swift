import Foundation

final class CapturedOutput: @unchecked Sendable {
    private let lock = NSLock()
    private(set) var messages: [String] = []

    func append(_ message: String) {
        lock.lock()
        defer { lock.unlock() }
        messages.append(message)
    }
}

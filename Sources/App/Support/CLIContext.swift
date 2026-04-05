import AppleCalendar
import Core
import Foundation

enum CLIContext {
    private static let store = ProviderStore()

    static var provider: CalendarProvider {
        get { store.get() }
        set { store.set(newValue) }
    }

    static func reset() {
        store.set(AppleCalendarProvider())
    }
}

private final class ProviderStore: @unchecked Sendable {
    private let lock = NSLock()
    private var provider: CalendarProvider = AppleCalendarProvider()

    func get() -> CalendarProvider {
        lock.lock()
        defer { lock.unlock() }
        return provider
    }

    func set(_ provider: CalendarProvider) {
        lock.lock()
        defer { lock.unlock() }
        self.provider = provider
    }
}

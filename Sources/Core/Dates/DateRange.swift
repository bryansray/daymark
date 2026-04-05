import Foundation

public struct DateRange: Sendable, Equatable {
    public let start: Date
    public let end: Date

    public init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }

    public static func today(
        now: Date = Date(),
        calendar: Calendar = .current
    ) throws -> DateRange {
        let start = calendar.startOfDay(for: now)

        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else {
            throw DaymarkError.providerFailure(message: "Could not compute the end of the current day.")
        }

        return DateRange(start: start, end: end)
    }
}

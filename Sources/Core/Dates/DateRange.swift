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

    public static func tomorrow(
        now: Date = Date(),
        calendar: Calendar = .current
    ) throws -> DateRange {
        let today = try DateRange.today(now: now, calendar: calendar)

        guard let start = calendar.date(byAdding: .day, value: 1, to: today.start),
              let end = calendar.date(byAdding: .day, value: 1, to: today.end)
        else {
            throw DaymarkError.providerFailure(message: "Could not compute the bounds for tomorrow.")
        }

        return DateRange(start: start, end: end)
    }

    public static func upcoming(
        now: Date = Date(),
        daysAhead: Int = 30,
        calendar: Calendar = .current
    ) throws -> DateRange {
        guard daysAhead > 0 else {
            throw DaymarkError.validation(message: "Upcoming range must be at least one day.")
        }

        guard let end = calendar.date(byAdding: .day, value: daysAhead, to: now) else {
            throw DaymarkError.providerFailure(message: "Could not compute the end of the upcoming range.")
        }

        return DateRange(start: now, end: end)
    }
}

import Core
import Foundation

enum OutputPrinter {
    static func printCalendars(_ calendars: [CalendarSummary]) {
        for calendar in calendars {
            Swift.print("\(calendar.title)\t\(calendar.source)\t\(calendar.id)")
        }
    }

    static func printEvents(_ events: [CalendarEvent]) {
        for event in events {
            Swift.print("\(timestamp(event.startDate))\t\(event.title)\t\(event.calendarID)")
        }
    }

    static func printAuthorization(_ state: AuthorizationState) {
        Swift.print(state.rawValue)
    }

    static func printJSON<T: Encodable>(_ value: T) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(value)
        if let string = String(data: data, encoding: .utf8) {
            Swift.print(string)
        }
    }

    private static func timestamp(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: date)
    }
}

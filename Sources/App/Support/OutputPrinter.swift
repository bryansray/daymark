import Core
import Foundation

enum OutputPrinter {
    static func printCalendars(_ calendars: [CalendarSummary]) {
        for calendar in calendars {
            Swift.print("\(calendar.title)\t\(calendar.source)\t\(calendar.id)")
        }
    }

    static func printEvents(_ events: [CalendarEvent], calendarTitles: [String: String]) {
        for line in renderEvents(events, calendarTitles: calendarTitles) {
            Swift.print(line)
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

    static func renderEvents(_ events: [CalendarEvent], calendarTitles: [String: String]) -> [String] {
        guard events.isEmpty == false else {
            return ["No events found."]
        }

        var lines: [String] = []

        for (index, event) in events.enumerated() {
            if index > 0 {
                lines.append("")
            }

            lines.append(eventHeadline(event))
            lines.append(eventDetails(event, calendarTitles: calendarTitles))
        }

        return lines
    }

    private static func eventHeadline(_ event: CalendarEvent) -> String {
        let date = dayFormatter.string(from: event.startDate)
        let timeDescription = event.isAllDay ? "All day" : "\(timeFormatter.string(from: event.startDate))-\(timeFormatter.string(from: event.endDate))"
        return "\(date)  \(timeDescription)  \(event.title)"
    }

    private static func eventDetails(_ event: CalendarEvent, calendarTitles: [String: String]) -> String {
        var parts = ["calendar: \(calendarTitles[event.calendarID] ?? event.calendarID)"]

        if let location = trimmed(event.location) {
            parts.append("location: \(location)")
        }

        return "  " + parts.joined(separator: "  |  ")
    }

    private static func trimmed(_ value: String?) -> String? {
        guard let value else {
            return nil
        }

        let result = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return result.isEmpty ? nil : result
    }

    private static var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "EEE, MMM d"
        return formatter
    }

    private static var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }
}

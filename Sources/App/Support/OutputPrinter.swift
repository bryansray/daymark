import Core
import Foundation
import Rainbow

enum OutputPrinter {
    static func printCalendars(_ calendars: [CalendarSummary]) {
        let rows = calendars.map { calendar in
            [
                calendar.title,
                calendar.source,
                calendar.isWritable ? "yes" : "no",
                calendar.id
            ]
        }

        for line in renderTable(
            headers: ["Title", "Source", "Writable", "ID"],
            rows: rows
        ) {
            Swift.print(line)
        }
    }

    static func printEvents(_ events: [CalendarEvent], calendarTitles: [String: String]) {
        for line in renderEvents(events, calendarTitles: calendarTitles) {
            Swift.print(line)
        }
    }

    static func printCalendar(_ calendar: CalendarSummary) {
        for line in renderCalendar(calendar) {
            Swift.print(line)
        }
    }

    static func printAuthorization(_ state: AuthorizationState) {
        Swift.print(renderAuthorization(state))
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
            return [emptyState("No events found.")]
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

    static func renderAuthorization(_ state: AuthorizationState) -> String {
        switch state {
        case .fullAccess:
            return state.rawValue.green.bold
        case .writeOnly:
            return state.rawValue.yellow.bold
        case .notDetermined:
            return state.rawValue.lightYellow
        case .denied, .restricted:
            return state.rawValue.red.bold
        }
    }

    static func renderCalendar(_ calendar: CalendarSummary) -> [String] {
        [
            calendar.title.bold,
            "  " + "source: \(calendar.source)  |  writable: \(calendar.isWritable ? "yes" : "no")".lightBlack,
            "  " + "id: \(calendar.id)".lightBlack
        ]
    }

    static func renderTable(headers: [String], rows: [[String]]) -> [String] {
        guard headers.isEmpty == false else {
            return rows.map { $0.joined(separator: "  ") }
        }

        let normalizedRows = rows.map { row in
            row + Array(repeating: "", count: max(0, headers.count - row.count))
        }

        let widths = (0..<headers.count).map { index in
            let values = normalizedRows.map { row in row[index] }
            return max(headers[index].count, values.map(\.count).max() ?? 0)
        }

        let headerLine = formatRow(headers, widths: widths).cyan.bold
        let separatorLine = widths
            .map { String(repeating: "-", count: $0) }
            .joined(separator: "  ")
            .lightBlack

        if normalizedRows.isEmpty {
            return [headerLine, separatorLine, emptyState("No rows found.")]
        }

        let renderedRows = normalizedRows.map { row in
            formatRow(row, widths: widths)
        }

        return [headerLine, separatorLine] + renderedRows
    }

    private static func eventHeadline(_ event: CalendarEvent) -> String {
        let date = dayFormatter.string(from: event.startDate)
        let timeDescription = event.isAllDay ? "All day" : "\(timeFormatter.string(from: event.startDate))-\(timeFormatter.string(from: event.endDate))"
        return "\(date)  ".lightBlack + "\(timeDescription)  ".blue.bold + event.title.bold
    }

    private static func eventDetails(_ event: CalendarEvent, calendarTitles: [String: String]) -> String {
        var parts = ["calendar: \(calendarTitles[event.calendarID] ?? event.calendarID)"]

        if let location = trimmed(event.location) {
            parts.append("location: \(location)")
        }

        return "  " + parts.joined(separator: "  |  ").lightBlack
    }

    private static func trimmed(_ value: String?) -> String? {
        guard let value else {
            return nil
        }

        let result = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return result.isEmpty ? nil : result
    }

    private static func formatRow(_ values: [String], widths: [Int]) -> String {
        zip(values, widths)
            .map { value, width in
                value.padding(toLength: width, withPad: " ", startingAt: 0)
            }
            .joined(separator: "  ")
    }

    private static func emptyState(_ text: String) -> String {
        text.lightBlack.italic
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

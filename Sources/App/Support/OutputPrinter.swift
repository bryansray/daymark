import Core
import Foundation
import Rainbow

enum OutputPrinter {
    private static let writerStore = OutputWriterStore()

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
            write(line)
        }
    }

    static func printEvents(_ events: [CalendarEvent], calendarTitles: [String: String]) {
        for line in renderEvents(events, calendarTitles: calendarTitles) {
            write(line)
        }
    }

    static func printEvent(_ event: CalendarEvent, calendarTitles: [String: String]) {
        for line in renderEvent(event, calendarTitles: calendarTitles) {
            write(line)
        }
    }

    static func printCalendar(_ calendar: CalendarSummary) {
        for line in renderCalendar(calendar) {
            write(line)
        }
    }

    static func printAuthorization(_ state: AuthorizationState) {
        write(renderAuthorization(state))
    }

    static func printJSON<T: Encodable>(_ value: T) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(value)
        if let string = String(data: data, encoding: .utf8) {
            write(string)
        }
    }

    static func setWriter(_ writer: @escaping @Sendable (String) -> Void) {
        writerStore.setWriter(writer)
    }

    static func resetWriter() {
        writerStore.reset()
    }

    static func renderEvents(_ events: [CalendarEvent], calendarTitles: [String: String]) -> [String] {
        guard events.isEmpty == false else {
            return [emptyState("No events found.")]
        }

        if distinctEventDays(in: events) > 1 {
            return renderGroupedEvents(events, calendarTitles: calendarTitles)
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

    static func renderEvent(_ event: CalendarEvent, calendarTitles: [String: String]) -> [String] {
        var lines = [
            event.title.bold,
            "  " + eventDateSummary(event).lightBlack,
            "  " + "calendar: \(calendarTitles[event.calendarID] ?? event.calendarID)".lightBlack
        ]

        if let location = trimmed(event.location) {
            lines.append("  " + "location: \(location)".lightBlack)
        }

        if let notes = trimmed(event.notes) {
            lines.append("  " + "notes: \(notes)".lightBlack)
        }

        if let recurrence = event.recurrence {
            lines.append("  " + recurrenceSummary(recurrence).lightBlack)

            if let occurrenceDate = recurrence.occurrenceDate {
                lines.append("  " + "occurrence-date: \(isoTimestamp(occurrenceDate))".lightBlack)
            }

            if let seriesIdentifier = recurrence.seriesIdentifier {
                lines.append("  " + "series-id: \(seriesIdentifier)".lightBlack)
            }
        }

        lines.append("  " + "id: \(event.id)".lightBlack)
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
        return "\(date)  ".lightBlack + "\(timeDescription)  ".blue.bold + event.title.bold + recurrenceBadge(for: event.recurrence)
    }

    private static func groupedEventHeadline(_ event: CalendarEvent) -> String {
        let timeDescription = event.isAllDay ? "All day" : "\(timeFormatter.string(from: event.startDate))-\(timeFormatter.string(from: event.endDate))"
        return "  " + "\(timeDescription)  ".blue.bold + event.title.bold + recurrenceBadge(for: event.recurrence)
    }

    private static func eventDateSummary(_ event: CalendarEvent) -> String {
        let date = dayFormatter.string(from: event.startDate)
        let timeDescription = event.isAllDay ? "All day" : "\(timeFormatter.string(from: event.startDate))-\(timeFormatter.string(from: event.endDate))"
        return "\(date)  \(timeDescription)"
    }

    private static func eventDetails(_ event: CalendarEvent, calendarTitles: [String: String]) -> String {
        var parts = [
            "calendar: \(calendarTitles[event.calendarID] ?? event.calendarID)",
            "id: \(event.id)"
        ]

        if let recurrence = event.recurrence {
            parts.append(recurrenceSummary(recurrence))
        }

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

    private static func write(_ message: String) {
        writerStore.write(message)
    }

    private static func renderGroupedEvents(_ events: [CalendarEvent], calendarTitles: [String: String]) -> [String] {
        let groupedEvents = Dictionary(grouping: events, by: eventDay)
        let orderedDays = groupedEvents.keys.sorted()
        var lines: [String] = []

        for (dayIndex, day) in orderedDays.enumerated() {
            if dayIndex > 0 {
                lines.append("")
            }

            lines.append(dayHeaderFormatter.string(from: day).cyan.bold)

            let dayEvents = groupedEvents[day] ?? []
            for event in dayEvents {
                lines.append(groupedEventHeadline(event))
                lines.append(eventDetails(event, calendarTitles: calendarTitles))
            }
        }

        return lines
    }

    private static func distinctEventDays(in events: [CalendarEvent]) -> Int {
        Set(events.map(eventDay)).count
    }

    private static func eventDay(for event: CalendarEvent) -> Date {
        Calendar.autoupdatingCurrent.startOfDay(for: event.startDate)
    }

    private static func recurrenceBadge(for recurrence: EventRecurrence?) -> String {
        guard let recurrence else {
            return ""
        }

        let label: String
        switch recurrence.kind {
        case .series:
            label = "repeating"
        case .occurrence:
            label = "occurrence"
        case .detachedOccurrence:
            label = "detached"
        }

        return " [" + label.magenta + "]"
    }

    private static func recurrenceSummary(_ recurrence: EventRecurrence) -> String {
        let kind: String
        switch recurrence.kind {
        case .series:
            kind = "recurrence: series"
        case .occurrence:
            kind = "recurrence: occurrence"
        case .detachedOccurrence:
            kind = "recurrence: detached occurrence"
        }

        if let summary = recurrence.summary {
            return "\(kind) (\(summary))"
        }

        return kind
    }

    private static func isoTimestamp(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: date)
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

    private static var dayHeaderFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }
}

private final class OutputWriterStore: @unchecked Sendable {
    private let lock = NSLock()
    private var writer: @Sendable (String) -> Void = { Swift.print($0) }

    func write(_ message: String) {
        let writer = currentWriter()
        writer(message)
    }

    func setWriter(_ writer: @escaping @Sendable (String) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        self.writer = writer
    }

    func reset() {
        setWriter { Swift.print($0) }
    }

    private func currentWriter() -> @Sendable (String) -> Void {
        lock.lock()
        defer { lock.unlock() }
        return writer
    }
}

import ArgumentParser
import Core
import Foundation

@available(macOS 10.15, *)
struct EventsCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "events",
        abstract: "List or search calendar events.",
        subcommands: [
            EventsGetCommand.self,
            EventsListCommand.self,
            EventsTodayCommand.self,
            EventsTomorrowCommand.self,
            EventsUpcomingCommand.self,
            EventsSearchCommand.self
        ]
    )

    mutating func run() async throws {
        throw CleanExit.helpRequest(self)
    }
}

@available(macOS 10.15, *)
struct EventsGetCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "get",
        abstract: "Get a single event by identifier."
    )

    @Option(name: .long, help: "Event identifier.")
    var id: String

    @Flag(name: .long, help: "Emit JSON output.")
    var json = false

    mutating func run() async throws {
        let event = try await CLIContext.provider.getEvent(id: id)

        if json {
            try OutputPrinter.printJSON(event)
        } else {
            let calendars = try await CLIContext.provider.listCalendars()
            let calendarTitles = Dictionary(uniqueKeysWithValues: calendars.map { ($0.id, $0.title) })
            OutputPrinter.printEvent(event, calendarTitles: calendarTitles)
        }
    }
}

@available(macOS 10.15, *)
struct EventsListCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List events in a date range."
    )

    @Option(name: .long, help: "Range start in ISO-8601 or YYYY-MM-DD.")
    var from: String

    @Option(name: .long, help: "Range end in ISO-8601 or YYYY-MM-DD.")
    var to: String

    @Option(name: .long, parsing: .upToNextOption, help: "Calendar ids or exact titles.")
    var calendar: [String] = []

    @Option(name: .long, help: "Maximum number of events to return.")
    var limit: Int?

    @Flag(name: .long, help: "Emit JSON output.")
    var json = false

    mutating func run() async throws {
        try validateLimit(limit)

        let start = try DateParser.parse(from)
        let end = try DateParser.parse(to)
        try await printEvents(from: start, to: end, calendars: calendar, limit: limit, json: json)
    }
}

@available(macOS 10.15, *)
struct EventsTodayCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "today",
        abstract: "List events happening today in the current time zone."
    )

    @Option(name: .long, parsing: .upToNextOption, help: "Calendar ids or exact titles.")
    var calendar: [String] = []

    @Flag(name: .long, help: "Emit JSON output.")
    var json = false

    mutating func run() async throws {
        let today = try DateRange.today()
        try await printEvents(from: today.start, to: today.end, calendars: calendar, json: json)
    }
}

@available(macOS 10.15, *)
struct EventsTomorrowCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "tomorrow",
        abstract: "List events happening tomorrow in the current time zone."
    )

    @Option(name: .long, parsing: .upToNextOption, help: "Calendar ids or exact titles.")
    var calendar: [String] = []

    @Flag(name: .long, help: "Emit JSON output.")
    var json = false

    mutating func run() async throws {
        let tomorrow = try DateRange.tomorrow()
        try await printEvents(from: tomorrow.start, to: tomorrow.end, calendars: calendar, json: json)
    }
}

@available(macOS 10.15, *)
struct EventsUpcomingCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "upcoming",
        abstract: "List the next upcoming events from now."
    )

    @Option(name: .long, help: "Maximum number of events to return.")
    var limit: Int = 10

    @Option(name: .long, help: "How many days ahead to search.")
    var days: Int = 30

    @Option(name: .long, parsing: .upToNextOption, help: "Calendar ids or exact titles.")
    var calendar: [String] = []

    @Flag(name: .long, help: "Emit JSON output.")
    var json = false

    mutating func run() async throws {
        try validateLimit(limit)

        let upcoming = try DateRange.upcoming(daysAhead: days)
        let events = try await CLIContext.provider.listEvents(
            from: upcoming.start,
            to: upcoming.end,
            calendars: calendar
        )
        let limitedEvents = applyLimit(limit, to: events)

        if json {
            try OutputPrinter.printJSON(limitedEvents)
        } else {
            try await printEvents(limitedEvents)
        }
    }
}

@available(macOS 10.15, *)
struct EventsSearchCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "search",
        abstract: "Search events by text or partial identifier in a date range."
    )

    @Option(name: .long, help: "Search text for event title, location, and notes.")
    var query: String?

    @Option(name: .long, help: "Partial event identifier.")
    var id: String?

    @Option(name: .long, help: "Range start in ISO-8601 or YYYY-MM-DD.")
    var from: String

    @Option(name: .long, help: "Range end in ISO-8601 or YYYY-MM-DD.")
    var to: String

    @Option(name: .long, parsing: .upToNextOption, help: "Calendar ids or exact titles.")
    var calendar: [String] = []

    @Option(name: .long, help: "Maximum number of events to return.")
    var limit: Int?

    @Flag(name: .long, help: "Emit JSON output.")
    var json = false

    mutating func run() async throws {
        guard query?.isEmpty == false || id?.isEmpty == false else {
            throw DaymarkError.validation(message: "Provide at least one of --query or --id.")
        }
        try validateLimit(limit)

        let start = try DateParser.parse(from)
        let end = try DateParser.parse(to)
        let events = try await searchEvents(from: start, to: end, calendars: calendar)
        let limitedEvents = applyLimit(limit, to: events)

        if json {
            try OutputPrinter.printJSON(limitedEvents)
        } else {
            try await printEvents(limitedEvents)
        }
    }

    private func searchEvents(
        from start: Date,
        to end: Date,
        calendars: [String]
    ) async throws -> [CalendarEvent] {
        var events: [CalendarEvent]

        if let query, query.isEmpty == false {
            events = try await CLIContext.provider.searchEvents(
                query: query,
                from: start,
                to: end,
                calendars: calendars
            )
        } else {
            events = try await CLIContext.provider.listEvents(from: start, to: end, calendars: calendars)
        }

        if let id, id.isEmpty == false {
            events = events.filter { $0.matchesPartialID(id) }
        }

        return events
    }
}

@available(macOS 10.15, *)
private func printEvents(
    from start: Date,
    to end: Date,
    calendars: [String],
    limit: Int? = nil,
    json: Bool
) async throws {
    let events = try await CLIContext.provider.listEvents(from: start, to: end, calendars: calendars)
    let limitedEvents = applyLimit(limit, to: events)

    if json {
        try OutputPrinter.printJSON(limitedEvents)
    } else {
        try await printEvents(limitedEvents)
    }
}

@available(macOS 10.15, *)
private func printEvents(_ events: [CalendarEvent]) async throws {
    let calendars = try await CLIContext.provider.listCalendars()
    let calendarTitles = Dictionary(uniqueKeysWithValues: calendars.map { ($0.id, $0.title) })
    OutputPrinter.printEvents(events, calendarTitles: calendarTitles)
}

@available(macOS 10.15, *)
private func applyLimit(_ limit: Int?, to events: [CalendarEvent]) -> [CalendarEvent] {
    guard let limit else {
        return events
    }

    return Array(events.prefix(limit))
}

@available(macOS 10.15, *)
private func validateLimit(_ limit: Int?) throws {
    guard let limit else {
        return
    }

    guard limit > 0 else {
        throw DaymarkError.validation(message: "Limit must be greater than zero.")
    }
}

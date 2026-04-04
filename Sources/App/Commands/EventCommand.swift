import ArgumentParser
import Core
import Foundation

@available(macOS 10.15, *)
struct EventsCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "events",
        abstract: "List or search calendar events.",
        subcommands: [
            EventsListCommand.self,
            EventsSearchCommand.self
        ]
    )

    mutating func run() async throws {
        throw CleanExit.helpRequest(self)
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

    @Flag(name: .long, help: "Emit JSON output.")
    var json = false

    mutating func run() async throws {
        let start = try DateParser.parse(from)
        let end = try DateParser.parse(to)
        let events = try await CLIContext.provider.listEvents(from: start, to: end, calendars: calendar)

        if json {
            try OutputPrinter.printJSON(events)
        } else {
            OutputPrinter.printEvents(events)
        }
    }
}

@available(macOS 10.15, *)
struct EventsSearchCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "search",
        abstract: "Search events by text in a date range."
    )

    @Option(name: .long, help: "Search text for event title, location, and notes.")
    var query: String

    @Option(name: .long, help: "Range start in ISO-8601 or YYYY-MM-DD.")
    var from: String

    @Option(name: .long, help: "Range end in ISO-8601 or YYYY-MM-DD.")
    var to: String

    @Option(name: .long, parsing: .upToNextOption, help: "Calendar ids or exact titles.")
    var calendar: [String] = []

    @Flag(name: .long, help: "Emit JSON output.")
    var json = false

    mutating func run() async throws {
        let start = try DateParser.parse(from)
        let end = try DateParser.parse(to)
        let events = try await CLIContext.provider.searchEvents(
            query: query,
            from: start,
            to: end,
            calendars: calendar
        )

        if json {
            try OutputPrinter.printJSON(events)
        } else {
            OutputPrinter.printEvents(events)
        }
    }
}

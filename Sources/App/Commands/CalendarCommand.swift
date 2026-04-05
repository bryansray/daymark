import ArgumentParser

@available(macOS 10.15, *)
struct CalendarsCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "calendars",
        abstract: "List the calendars available in Apple Calendar.",
        subcommands: [
            CalendarsListCommand.self,
            CalendarsGetCommand.self
        ]
    )

    mutating func run() async throws {
        throw CleanExit.helpRequest(self)
    }
}

@available(macOS 10.15, *)
struct CalendarsListCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List the calendars available in Apple Calendar."
    )

    @Flag(name: .long, help: "Emit JSON output.")
    var json = false

    mutating func run() async throws {
        let calendars = try await CLIContext.provider.listCalendars()

        if json {
            try OutputPrinter.printJSON(calendars)
        } else {
            OutputPrinter.printCalendars(calendars)
        }
    }
}

@available(macOS 10.15, *)
struct CalendarsGetCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "get",
        abstract: "Get a single calendar by identifier or exact title."
    )

    @Option(name: .long, help: "Calendar identifier.")
    var id: String?

    @Option(name: .long, help: "Calendar exact title.")
    var name: String?

    @Flag(name: .long, help: "Emit JSON output.")
    var json = false

    mutating func run() async throws {
        guard id != nil || name != nil else {
            throw ValidationError("Provide --id or --name.")
        }

        let calendar = try await CLIContext.provider.getCalendar(id: id, name: name)

        if json {
            try OutputPrinter.printJSON(calendar)
        } else {
            OutputPrinter.printCalendar(calendar)
        }
    }
}

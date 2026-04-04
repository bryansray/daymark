import ArgumentParser

@available(macOS 10.15, *)
struct CalendarsCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "calendars",
        abstract: "List the calendars available in Apple Calendar.",
        subcommands: [
            CalendarsListCommand.self
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

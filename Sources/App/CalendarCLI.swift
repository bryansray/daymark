import ArgumentParser

@available(macOS 10.15, *)
struct CalendarCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "daymark",
        abstract: "A small Apple Calendar CLI for learning Swift.",
        version: AppMetadata.version,
        subcommands: [
            AuthCommand.self,
            CalendarsCommand.self,
            EventsCommand.self
        ]
    )
}

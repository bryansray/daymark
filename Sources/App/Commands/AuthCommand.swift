import ArgumentParser
import Core

@available(macOS 10.15, *)
struct AuthCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "auth",
        abstract: "Inspect or request Apple Calendar permissions.",
        subcommands: [
            AuthStatusCommand.self,
            AuthGrantCommand.self
        ]
    )

    mutating func run() async throws {
        throw CleanExit.helpRequest(self)
    }
}

@available(macOS 10.15, *)
struct AuthStatusCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "status",
        abstract: "Show the current Apple Calendar authorization status."
    )

    @Flag(name: .long, help: "Emit JSON output.")
    var json = false

    mutating func run() async throws {
        let state = CLIContext.provider.authorizationStatus()

        if json {
            try OutputPrinter.printJSON(["status": state.rawValue])
        } else {
            OutputPrinter.printAuthorization(state)
        }
    }
}

@available(macOS 10.15, *)
struct AuthGrantCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "grant",
        abstract: "Request Apple Calendar access."
    )

    @Flag(name: .long, help: "Emit JSON output.")
    var json = false

    mutating func run() async throws {
        let state = try await CLIContext.provider.requestAccess()

        if json {
            try OutputPrinter.printJSON(["status": state.rawValue])
        } else {
            OutputPrinter.printAuthorization(state)
        }
    }
}

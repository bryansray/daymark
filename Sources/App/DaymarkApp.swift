import ArgumentParser
import Core
import Foundation

@main
struct DaymarkApp {
    static func main() async {
        do {
            var command = try CalendarCLI.parseAsRoot()
            if var asyncCommand = command as? AsyncParsableCommand {
                try await asyncCommand.run()
            } else {
                try command.run()
            }
        } catch let error as DaymarkError {
            CLIErrorRenderer.exit(error)
        } catch {
            CalendarCLI.exit(withError: error)
        }
    }
}

import ArgumentParser
import Core
import Foundation
import Rainbow

enum CLIErrorRenderer {
    static func exit(_ error: DaymarkError) -> Never {
        let prefix = "Error".red.bold
        let message = error.errorDescription ?? "Unknown error."
        write("\(prefix): \(message)\n")
        Foundation.exit(exitCode(for: error))
    }

    private static func exitCode(for error: DaymarkError) -> Int32 {
        switch error {
        case .validation, .notFound, .authorizationRequired:
            return ExitCode.validationFailure.rawValue
        case .permissionDenied, .providerFailure:
            return ExitCode.failure.rawValue
        }
    }

    private static func write(_ message: String) {
        guard let data = message.data(using: .utf8) else {
            return
        }

        FileHandle.standardError.write(data)
    }
}

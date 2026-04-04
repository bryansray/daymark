import Foundation

public enum DateParser {
    public static func parse(_ input: String) throws -> Date {
        let fractionalFormatter = ISO8601DateFormatter()
        fractionalFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = fractionalFormatter.date(from: input) {
            return date
        }

        let internetFormatter = ISO8601DateFormatter()
        internetFormatter.formatOptions = [.withInternetDateTime]
        if let date = internetFormatter.date(from: input) {
            return date
        }

        let localFormatter = DateFormatter()
        localFormatter.calendar = Calendar(identifier: .gregorian)
        localFormatter.locale = Locale(identifier: "en_US_POSIX")
        localFormatter.timeZone = .current
        localFormatter.dateFormat = "yyyy-MM-dd"
        if let date = localFormatter.date(from: input) {
            return date
        }

        throw DateParserError.invalidDate(input)
    }
}

public enum DateParserError: LocalizedError, Equatable {
    case invalidDate(String)

    public var errorDescription: String? {
        switch self {
        case let .invalidDate(input):
            "Invalid date '\(input)'. Use ISO-8601 or YYYY-MM-DD."
        }
    }
}

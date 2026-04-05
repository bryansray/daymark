import Foundation

public enum DaymarkError: LocalizedError, Equatable, Sendable {
    case validation(message: String)
    case notFound(resource: String, details: [String: String] = [:])
    case authorizationRequired
    case permissionDenied
    case providerFailure(message: String)

    public var errorDescription: String? {
        switch self {
        case let .validation(message):
            return message
        case let .notFound(resource, details):
            let subject = resource.isEmpty ? "Requested resource" : "\(resource.capitalized) not found"
            guard details.isEmpty == false else {
                return subject + "."
            }

            let renderedDetails = details
                .sorted(by: { $0.key < $1.key })
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: ", ")
            return "\(subject). \(renderedDetails)"
        case .authorizationRequired:
            return "Calendar access has not been granted yet. Run `daymark auth grant` first."
        case .permissionDenied:
            return "Calendar access is denied or restricted for this process."
        case let .providerFailure(message):
            return message
        }
    }

    public static func invalidDate(_ input: String) -> DaymarkError {
        .validation(message: "Invalid date '\(input)'. Use ISO-8601 or YYYY-MM-DD.")
    }
}

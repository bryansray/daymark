import Foundation

public enum AuthorizationState: String, Codable, Sendable {
    case notDetermined
    case denied
    case restricted
    case writeOnly
    case fullAccess

    public var canReadEvents: Bool {
        self == .fullAccess || self == .writeOnly
    }
}

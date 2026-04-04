import Core
import EventKit
import Foundation

enum EventKitAuthorization {
    static func map(_ status: EKAuthorizationStatus) -> AuthorizationState {
        switch status {
        case .notDetermined:
            .notDetermined
        case .denied:
            .denied
        case .restricted:
            .restricted
        case .writeOnly:
            .writeOnly
        case .fullAccess:
            .fullAccess
        @unknown default:
            .restricted
        }
    }
}

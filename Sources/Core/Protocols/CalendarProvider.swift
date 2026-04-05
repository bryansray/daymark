import Foundation

public protocol CalendarProvider: Sendable {
    func authorizationStatus() -> AuthorizationState
    func requestAccess() async throws -> AuthorizationState
    func listCalendars() async throws -> [CalendarSummary]
    func getCalendar(id: String?, name: String?) async throws -> CalendarSummary
    func getEvent(id: String) async throws -> CalendarEvent
    func listEvents(from start: Date, to end: Date, calendars: [String]) async throws -> [CalendarEvent]
    func searchEvents(query: String, from start: Date, to end: Date, calendars: [String]) async throws -> [CalendarEvent]
}

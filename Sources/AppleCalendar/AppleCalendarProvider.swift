import Core
import EventKit
import Foundation

public final class AppleCalendarProvider: CalendarProvider, @unchecked Sendable {
    private let store: EKEventStore

    public init(store: EKEventStore = EKEventStore()) {
        self.store = store
    }

    public func authorizationStatus() -> AuthorizationState {
        EventKitAuthorization.map(EKEventStore.authorizationStatus(for: .event))
    }

    public func requestAccess() async throws -> AuthorizationState {
        if #available(macOS 14.0, *) {
            let granted = try await store.requestFullAccessToEvents()
            return granted ? .fullAccess : .denied
        } else {
            let granted = try await store.requestAccess(to: .event)
            return granted ? .fullAccess : .denied
        }
    }

    public func listCalendars() async throws -> [CalendarSummary] {
        store.calendars(for: .event)
            .map(EventKitMappers.calendarSummary)
            .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    public func getCalendar(id: String?, name: String?) async throws -> CalendarSummary {
        let calendars = try await listCalendars()

        if let id,
           let calendar = calendars.first(where: { $0.id == id })
        {
            return calendar
        }

        if let name,
           let calendar = calendars.first(where: { $0.title == name })
        {
            return calendar
        }

        struct CalendarLookupError: LocalizedError {
            let id: String?
            let name: String?

            var errorDescription: String? {
                "No calendar matched the provided lookup."
            }

            var failureReason: String? {
                let fields = [
                    id.map { "id=\($0)" },
                    name.map { "name=\($0)" }
                ].compactMap { $0 }

                return fields.isEmpty ? nil : fields.joined(separator: ", ")
            }
        }

        throw CalendarLookupError(id: id, name: name)
    }

    public func getEvent(id: String) async throws -> CalendarEvent {
        guard let event = store.event(withIdentifier: id) else {
            struct EventLookupError: LocalizedError {
                let id: String

                var errorDescription: String? {
                    "No event matched the provided identifier."
                }

                var failureReason: String? {
                    "id=\(id)"
                }
            }

            throw EventLookupError(id: id)
        }

        return EventKitMappers.calendarEvent(from: event)
    }

    public func listEvents(from start: Date, to end: Date, calendars: [String]) async throws -> [CalendarEvent] {
        let selectedCalendars = matchingCalendars(calendars)
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: selectedCalendars)

        return store.events(matching: predicate)
            .map(EventKitMappers.calendarEvent)
            .sorted { $0.startDate < $1.startDate }
    }

    public func searchEvents(
        query: String,
        from start: Date,
        to end: Date,
        calendars: [String]
    ) async throws -> [CalendarEvent] {
        let needle = query.lowercased()

        return try await listEvents(from: start, to: end, calendars: calendars).filter { event in
            event.title.lowercased().contains(needle)
                || (event.location?.lowercased().contains(needle) ?? false)
                || (event.notes?.lowercased().contains(needle) ?? false)
        }
    }

    private func matchingCalendars(_ filters: [String]) -> [EKCalendar]? {
        guard filters.isEmpty == false else {
            return nil
        }

        let allCalendars = store.calendars(for: .event)
        return allCalendars.filter { calendar in
            filters.contains(calendar.calendarIdentifier) || filters.contains(calendar.title)
        }
    }
}

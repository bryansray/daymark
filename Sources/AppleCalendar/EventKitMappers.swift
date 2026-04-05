import Core
import EventKit
import Foundation

enum EventKitMappers {
    static func calendarSummary(from calendar: EKCalendar) -> CalendarSummary {
        CalendarSummary(
            id: calendar.calendarIdentifier,
            title: calendar.title,
            source: calendar.source.title,
            isWritable: calendar.allowsContentModifications
        )
    }

    static func calendarEvent(from event: EKEvent) -> CalendarEvent {
        CalendarEvent(
            id: event.eventIdentifier,
            calendarID: event.calendar.calendarIdentifier,
            title: event.title,
            startDate: event.startDate,
            endDate: event.endDate,
            isAllDay: event.isAllDay,
            location: event.location,
            notes: event.notes,
            recurrence: recurrence(from: event)
        )
    }

    private static func recurrence(from event: EKEvent) -> EventRecurrence? {
        let kind: EventRecurrenceKind?
        if event.occurrenceDate != nil {
            kind = event.isDetached ? .detachedOccurrence : .occurrence
        } else if event.hasRecurrenceRules {
            kind = .series
        } else {
            kind = nil
        }

        guard let kind else {
            return nil
        }

        return EventRecurrence(
            kind: kind,
            summary: recurrenceSummary(from: event.recurrenceRules?.first),
            occurrenceDate: event.occurrenceDate,
            seriesIdentifier: event.calendarItemExternalIdentifier
        )
    }

    private static func recurrenceSummary(from rule: EKRecurrenceRule?) -> String? {
        guard let rule else {
            return nil
        }

        let frequency: String
        switch rule.frequency {
        case .daily:
            frequency = "day"
        case .weekly:
            frequency = "week"
        case .monthly:
            frequency = "month"
        case .yearly:
            frequency = "year"
        @unknown default:
            frequency = "period"
        }

        let base = rule.interval == 1 ? "Every \(frequency)" : "Every \(rule.interval) \(frequency)s"

        guard let end = rule.recurrenceEnd else {
            return base
        }

        if end.occurrenceCount > 0 {
            return "\(base), \(end.occurrenceCount) times"
        }

        if let endDate = end.endDate {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate]
            return "\(base), until \(formatter.string(from: endDate))"
        }

        return base
    }
}

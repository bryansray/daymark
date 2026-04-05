import Foundation

public enum EventRecurrenceKind: String, Codable, Sendable, Equatable {
    case series
    case occurrence
    case detachedOccurrence = "detached_occurrence"
}

public struct EventRecurrence: Codable, Sendable, Equatable {
    public let kind: EventRecurrenceKind
    public let summary: String?
    public let occurrenceDate: Date?
    public let seriesIdentifier: String?

    public init(
        kind: EventRecurrenceKind,
        summary: String? = nil,
        occurrenceDate: Date? = nil,
        seriesIdentifier: String? = nil
    ) {
        self.kind = kind
        self.summary = summary
        self.occurrenceDate = occurrenceDate
        self.seriesIdentifier = seriesIdentifier
    }
}

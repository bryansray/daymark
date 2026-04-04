import Foundation

public struct CalendarSummary: Codable, Identifiable, Sendable, Equatable {
    public let id: String
    public let title: String
    public let source: String
    public let isWritable: Bool

    public init(id: String, title: String, source: String, isWritable: Bool) {
        self.id = id
        self.title = title
        self.source = source
        self.isWritable = isWritable
    }
}

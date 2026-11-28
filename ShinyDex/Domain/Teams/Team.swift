import Foundation

struct Team: Equatable {
    static let maximumSize = 6

    let id: UUID
    var name: String
    var memberIds: [UUID]
    let createdDate: Date

    init(id: UUID = UUID(), name: String, memberIds: [UUID] = [], createdDate: Date = Date()) {
        self.id = id
        self.name = name
        self.memberIds = Team.normalizeMembers(memberIds)
        self.createdDate = createdDate
    }

    var isFull: Bool {
        return memberIds.count >= Team.maximumSize
    }

    static func normalizeMembers(_ memberIds: [UUID]) -> [UUID] {
        var unique = [UUID]()
        for id in memberIds where !unique.contains(id) {
            unique.append(id)
        }
        return Array(unique.prefix(maximumSize))
    }

    static func encodeMembers(_ memberIds: [UUID]) -> String {
        return memberIds.map { $0.uuidString }.joined(separator: ",")
    }

    static func decodeMembers(_ text: String?) -> [UUID] {
        return (text ?? "").split(separator: ",").compactMap { UUID(uuidString: String($0)) }
    }
}

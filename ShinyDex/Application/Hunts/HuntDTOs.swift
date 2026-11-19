import Foundation

struct HuntMember: Equatable {
    let number: Int
    let name: String
    let encounters: Int
    let increment: Int
}

struct HuntSummary: Equatable {
    let id: HuntID
    let name: String
    let priority: Int
    let isCollapsed: Bool
    let members: [HuntMember]

    var totalEncounters: Int {
        return members.reduce(0) { $0 + $1.encounters }
    }
}

import Foundation

struct HuntPhase: Equatable {
    let catchId: UUID
    let encounters: Int

    static func encode(_ phases: [HuntPhase]) -> String? {
        guard !phases.isEmpty else { return nil }
        return phases.map { "\($0.catchId.uuidString):\($0.encounters)" }.joined(separator: ",")
    }

    static func decode(_ encoded: String?) -> [HuntPhase] {
        return (encoded ?? "").split(separator: ",").compactMap { part in
            let fields = part.split(separator: ":")
            guard fields.count == 2, let catchId = UUID(uuidString: String(fields[0])), let encounters = Int(fields[1]) else { return nil }
            return HuntPhase(catchId: catchId, encounters: encounters)
        }
    }

    static func encodeIds(_ ids: [UUID]) -> String? {
        return ids.isEmpty ? nil : ids.map { $0.uuidString }.joined(separator: ",")
    }

    static func decodeIds(_ encoded: String?) -> [UUID] {
        return (encoded ?? "").split(separator: ",").compactMap { UUID(uuidString: String($0)) }
    }
}

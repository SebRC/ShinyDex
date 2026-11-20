import Foundation

extension CatchSummary {
    fileprivate static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    var ballName: String {
        return "\(caughtBall.capitalizingFirstLetter()) Ball"
    }

    var formattedCaughtDate: String? {
        return caughtDate.map { CatchSummary.dateFormatter.string(from: $0) }
    }
}

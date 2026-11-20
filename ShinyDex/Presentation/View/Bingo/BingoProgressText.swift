import Foundation

enum BingoProgressText {
    static func make(obtained: Int, total: Int, filled: Int, lines: Int) -> String {
        if (obtained == total) {
            return "Blackout · all \(total) obtained"
        }
        let progress = filled < total ? "\(obtained) of \(total) obtained · \(total - filled) empty" : "\(obtained) of \(total) obtained"
        switch lines {
        case 0: return progress
        case 1: return "\(progress) · Bingo!"
        default: return "\(progress) · \(lines) bingos"
        }
    }
}

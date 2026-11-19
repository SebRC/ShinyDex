import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}

extension Double {
    // The chance, as a percentage, of finding at least one shiny in this many encounters at 1/odds.
    static func getProbability(encounters: Int, odds: Int) -> Double {
        let cumulativeProbability = pow(Double(odds - 1) / Double(odds), Double(encounters))
        let decimalProbability = 1 - cumulativeProbability
        return Double(truncating: decimalProbability * 100 as NSNumber)
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

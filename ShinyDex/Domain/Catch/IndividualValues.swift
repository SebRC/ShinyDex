import Foundation

struct IndividualValues: Equatable {
	static let range = 0...31

	fileprivate(set) var values: [Int?]

	init() {
		values = Array(repeating: nil, count: Stat.allCases.count)
	}

	init(encoded: String?) {
		self.init()
		guard let parts = encoded?.split(separator: ",", omittingEmptySubsequences: false), parts.count == values.count else { return }
		var decoded = [Int?]()
		for part in parts {
			if part.isEmpty {
				decoded.append(nil)
			}
			else if let value = Int(part) {
				decoded.append(IndividualValues.clamped(value))
			}
			else {
				return
			}
		}
		values = decoded
	}

	var encoded: String {
		return values.map { $0.map(String.init) ?? "" }.joined(separator: ",")
	}

	var isEmpty: Bool {
		return values.allSatisfy { $0 == nil }
	}

	var perfectCount: Int {
		return values.filter { $0 == IndividualValues.range.upperBound }.count
	}

	subscript(stat: Stat) -> Int? {
		return values[stat.rawValue]
	}

	func setting(_ value: Int?, for stat: Stat) -> IndividualValues {
		var copy = self
		copy.values[stat.rawValue] = value.map(IndividualValues.clamped)
		return copy
	}

	var summary: String {
		return isEmpty ? "Unknown" : values.map { $0.map(String.init) ?? "?" }.joined(separator: " / ")
	}

	fileprivate static func clamped(_ value: Int) -> Int {
		return min(max(value, range.lowerBound), range.upperBound)
	}
}

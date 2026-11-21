import Foundation

class ActiveMove: Encodable, Decodable {
	var name: String
	var maxPP: Int
	var remainingPP: Int
	var type: String

	static let placeholderName = "None"

	var isPlaceholder: Bool {
		return name == ActiveMove.placeholderName
	}

	init(name: String, maxPP: Int, remainingPP: Int, type: String) {
		self.name = name
		self.maxPP = maxPP
		self.remainingPP = remainingPP
		self.type = type
	}
}

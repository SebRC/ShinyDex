import Foundation

class ProbabilityService {
	func getProbability(encounters: Int, shinyOdds: Int) -> Double {
		return Double.getProbability(encounters: encounters, odds: shinyOdds)
	}
}

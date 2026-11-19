import Foundation

class FriendSafariOddsService {
	func getOdds(isShinyCharmActive: Bool) -> Int {
		return isShinyCharmActive ? 585 : 819
	}
}

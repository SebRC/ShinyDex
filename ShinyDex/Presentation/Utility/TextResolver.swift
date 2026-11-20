import Foundation

class TextResolver {

	fileprivate var titles = [0: "Kanto", 1: "Johto", 2: "Hoenn", 3: "Sinnoh", 4: "Unova", 5: "Kalos", 6: "Alola", 7: "Galar", 8: "Hisui",9: "Paldea", 10: "Hunts", 11: "Collection", 12: "PP Counter", 13: "Stats", 14: "Journeys", 15: "Shiny Bingo", 16: "Odds Simulator"]

	func getGenTitle(gen: Int) -> String {
		return titles[gen] ?? "Not found"
	}
}

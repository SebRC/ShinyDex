import Foundation

class TextResolver {

	fileprivate var titles = [0: "Kanto", 1: "Johto", 2: "Hoenn", 3: "Sinnoh", 4: "Unova", 5: "Kalos", 6: "Alola", 7: "Galar", 8: "Hunts", 9: "Collection", 10: "PP Counter"]

	func getGenTitle(gen: Int) -> String {
		return titles[gen] ?? "Not found"
	}

	func getEncountersLabelText(pokemon: Pokemon, methodDecrement: Int = 0) -> String {
		return getEncountersText(pokemon: pokemon, methodDecrement: methodDecrement, encounters: pokemon.encounters)
	}

	fileprivate func getEncountersText(pokemon: Pokemon, methodDecrement: Int, encounters: Int) -> String {
		let maxChainReached = getMaxChainReached(pokemon: pokemon, encounters: encounters)
		let encountersDecremented = encounters - methodDecrement
		var methodVerb = "Chain"

        if (pokemon.game == .LetsGoPikachu || pokemon.game == .LetsGoEevee) {
			return maxChainReached
				? " Catch Combo: \(methodDecrement) + \(encountersDecremented) seen"
				: " Catch Combo: \(encounters)"
		}
		if (pokemon.huntMethod == .Masuda || pokemon.huntMethod == .Gen2Breeding) {
			return " Eggs: \(encounters)"
		}
		if (pokemon.huntMethod == .SosChaining || pokemon.huntMethod == .ChainFishing || pokemon.huntMethod == .Pokeradar) {
			return maxChainReached
				? " \(methodVerb): \(methodDecrement) + \(encountersDecremented) \(pokemon.huntMethod == .Pokeradar ? "patches" : "seen")"
				: " \(methodVerb): \(encounters)"
		}
		if (pokemon.huntMethod == .DexNav) {
			methodVerb = "Search level"
			return maxChainReached
				? " \(methodVerb): \(methodDecrement) + \(encountersDecremented) seen"
				: " \(methodVerb): \(encounters)"
		}
		return " Encounters: \(encounters)"
	}

	fileprivate func getMaxChainReached(pokemon: Pokemon, encounters: Int) -> Bool {
		var maxChainReached = false
		if (pokemon.huntMethod == .Lure || pokemon.huntMethod == .SosChaining) {
			maxChainReached = encounters > 30
		}
		if (pokemon.huntMethod == .ChainFishing) {
			maxChainReached = encounters > 20
		}
		if (pokemon.huntMethod == .Pokeradar) {
			maxChainReached = encounters > 40
		}
		if (pokemon.huntMethod == .DexNav) {
			maxChainReached = encounters > 999
		}
		return maxChainReached
	}
}

import Foundation

class TextResolver {

	fileprivate var titles = [0: "Kanto", 1: "Johto", 2: "Hoenn", 3: "Sinnoh", 4: "Unova", 5: "Kalos", 6: "Alola", 7: "Galar", 8: "Hisui",9: "Paldea", 10: "Hunts", 11: "Collection", 12: "PP Counter"]

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
				? "Catch Combo: \(methodDecrement)\nEncounters: \(encountersDecremented)"
				: "Catch Combo: \(encounters)"
		}
        if (isBreedingMethod(huntMethod: pokemon.huntMethod)) {
			return "Eggs: \(encounters)"
		}
        if (isChainingMethod(huntMethod: pokemon.huntMethod)) {
			return maxChainReached
				? "\(methodVerb): \(methodDecrement)\n\(pokemon.huntMethod == .Pokeradar ? "Patches:" : "Encounters:") \(encountersDecremented)"
				: "\(methodVerb): \(encounters)"
		}
		if (pokemon.huntMethod == .DexNav) {
			methodVerb = "Search level"
			return maxChainReached
				? "\(methodVerb): \(methodDecrement)\nEncounters: \(encountersDecremented)"
				: "\(methodVerb): \(encounters)"
		}
		return "Encounters: \(encounters)"
	}
    
    fileprivate func isChainingMethod(huntMethod: HuntMethod) -> Bool {
        return huntMethod == .SosChaining || huntMethod == .ChainFishing || huntMethod == .Pokeradar
    }
    
    fileprivate func isBreedingMethod(huntMethod: HuntMethod) -> Bool {
        return huntMethod == .Masuda || huntMethod == .Gen2Breeding
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

import Foundation

class TextResolver {

	fileprivate var titles = [0: "Kanto", 1: "Johto", 2: "Hoenn", 3: "Sinnoh", 4: "Unova", 5: "Kalos", 6: "Alola", 7: "Galar", 8: "Hisui",9: "Paldea", 10: "Hunts", 11: "Collection", 12: "PP Counter", 13: "Stats", 14: "Journeys"]

	func getGenTitle(gen: Int) -> String {
		return titles[gen] ?? "Not found"
	}

	func getEncountersLabelText(pokemon: PokemonDetails) -> String {
		return getEncountersText(settings: pokemon.settings, methodDecrement: pokemon.chainThreshold, encounters: pokemon.encounters)
	}

	func getProbabilityText(pokemon: PokemonDetails) -> String {
		let huntMethod = pokemon.settings.huntMethod
		let methodDecrement = pokemon.chainThreshold
		let maxChainNotReached = pokemon.encounters <= methodDecrement
		if (huntMethod == .Lure && maxChainNotReached
			|| pokemon.settings.generation == 0 && maxChainNotReached
			|| huntMethod == .Pokeradar && maxChainNotReached
			|| huntMethod == .ChainFishing && maxChainNotReached
			|| huntMethod == .SosChaining && maxChainNotReached) {
			return "Chain \(methodDecrement) to see probability"
		}
		if (huntMethod == .DexNav && maxChainNotReached) {
			return "Reach Search level \(methodDecrement) to see probability"
		}
		return "Probability: \(String(format: "%.2f", pokemon.probability))"
	}

	fileprivate func getEncountersText(settings: HuntSettings, methodDecrement: Int, encounters: Int) -> String {
		let maxChainReached = getMaxChainReached(huntMethod: settings.huntMethod, encounters: encounters)
		let encountersDecremented = encounters - methodDecrement
		var methodVerb = "Chain"

        if (settings.game == .LetsGoPikachu || settings.game == .LetsGoEevee) {
			return maxChainReached
				? "Catch Combo: \(methodDecrement)\nEncounters: \(encountersDecremented)"
				: "Catch Combo: \(encounters)"
		}
        if (isBreedingMethod(huntMethod: settings.huntMethod)) {
			return "Eggs: \(encounters)"
		}
        if (isChainingMethod(huntMethod: settings.huntMethod)) {
			return maxChainReached
				? "\(methodVerb): \(methodDecrement)\n\(settings.huntMethod == .Pokeradar ? "Patches:" : "Encounters:") \(encountersDecremented)"
				: "\(methodVerb): \(encounters)"
		}
		if (settings.huntMethod == .DexNav) {
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

	fileprivate func getMaxChainReached(huntMethod: HuntMethod, encounters: Int) -> Bool {
		var maxChainReached = false
		if (huntMethod == .Lure || huntMethod == .SosChaining) {
			maxChainReached = encounters > 30
		}
		if (huntMethod == .ChainFishing) {
			maxChainReached = encounters > 20
		}
		if (huntMethod == .Pokeradar) {
			maxChainReached = encounters > 40
		}
		if (huntMethod == .DexNav) {
			maxChainReached = encounters > 999
		}
		return maxChainReached
	}
}

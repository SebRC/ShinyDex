import Foundation

public class LocationUrlService {
    fileprivate let generationPrefixes = [1: "", 2: "-gs", 3: "-rs", 4: "-dp", 5: "-bw", 6: "-xy", 7: "-sm", 8: "-swsh", 9: "-sv"]
    fileprivate let generationRanges = [1: 0..<151, 2: 151..<251, 3: 251..<386, 4: 386..<493, 5: 493..<649, 6: 649..<721, 7: 721..<807, 8: 807..<905, 9: 905..<1010]

	func getUrl(pokemon: Pokemon) -> String {
		let generation = pokemon.generation
		let minimumGeneration = getMinimumGeneration(dexNumber: pokemon.number)
		let isPostGen7 = generation > 7
		let numberPrefix = getNumberPrefix(dexNumber: pokemon.number)
		let generationIdentifier = generation < minimumGeneration
			? generationPrefixes[minimumGeneration]!
			: generationPrefixes[generation]!

        return "https://serebii.net/pokedex\(generationIdentifier)/\(isPostGen7 ? pokemon.name.lowercased() : numberPrefix)\(isPostGen7 ? "" : ".shtml")"
	}

	fileprivate func getMinimumGeneration(dexNumber: Int) -> Int {
		for entry in generationRanges {
			if (entry.value ~= dexNumber) {
				return entry.key
			}
		}
		return 7
	}

	fileprivate func getNumberPrefix(dexNumber: Int) -> String {
		var numberPrefix = ""
		if (dexNumber < 9) {
			numberPrefix = "00"
		}
		else if (dexNumber >= 9  && dexNumber < 99) {
			numberPrefix = "0"
		}
		numberPrefix += String(dexNumber + 1)
		return numberPrefix
	}
}

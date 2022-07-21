import Foundation

class OddsService {
	fileprivate let lgpeOddsService = LGPEOddsService()
	fileprivate let masudaOddsService = MasudaOddsService()
	fileprivate let gen2BreedingOddsService = Gen2BreedingOddsService()
	fileprivate let friendSafariOddsService = FriendSafariOddsService()
	fileprivate let chainFishingOddsService = ChainFishingOddsService()
	fileprivate let sosChainingOddsService = SosChainingOddsService()
	fileprivate let pokeradarOddsService = PokeradarOddsService()
	fileprivate let dexNavOddsService = DexNavOddsService()

	func getShinyOdds(pokemon: Pokemon) -> Int {
		let generation = pokemon.generation
		let encounters = pokemon.encounters
		let isCharmActive = pokemon.isShinyCharmActive
		let huntMethod = pokemon.huntMethod
		switch huntMethod {
		case .Gen2Breeding:
			return gen2BreedingOddsService.getOdds()
		case .Masuda:
			return masudaOddsService.getOdds(generation: generation, isCharmActive: isCharmActive)
		case .Pokeradar:
			return pokeradarOddsService.getOdds(chain: encounters)
		case .FriendSafari:
			return friendSafariOddsService.getOdds(isShinyCharmActive: isCharmActive)
		case .ChainFishing:
			return chainFishingOddsService.getOdds(isShinyCharmActive: isCharmActive, chain: encounters)
		case .DexNav:
			return dexNavOddsService.getOdds(searchLevel: encounters, isShinyCharmActive: isCharmActive)
		case .SosChaining:
			return sosChainingOddsService.getOdds(isShinyCharmActive: isCharmActive, chain: encounters)
        case .Lure:
            return lgpeOddsService.getOdds(pokemon: pokemon)
		default:
            if(pokemon.game == .LetsGoPikachu || pokemon.game == .LetsGoEevee) {
                return lgpeOddsService.getOdds(pokemon: pokemon)
            }
			if (generation < 5) {
				return 8192
			}
			else if (generation == 5) {
                return isCharmActive ? 2731 : 8192
			}
            return isCharmActive ? 1365 : 4096
		}
	}
}

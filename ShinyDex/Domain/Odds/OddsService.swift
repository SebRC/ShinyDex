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
		return getShinyOdds(configuration: pokemon.huntConfiguration, chain: pokemon.chain)
	}

	func getShinyOdds(configuration: HuntConfiguration, chain: Int) -> Int {
		let generation = configuration.generation
		let isCharmActive = configuration.isShinyCharmActive
		let huntMethod = configuration.huntMethod
		switch huntMethod {
		case .Gen2Breeding:
			return gen2BreedingOddsService.getOdds()
		case .Masuda:
			return masudaOddsService.getOdds(generation: generation, isCharmActive: isCharmActive)
		case .Pokeradar:
			return pokeradarOddsService.getOdds(chain: chain, generation: generation)
		case .FriendSafari:
			return friendSafariOddsService.getOdds(isShinyCharmActive: isCharmActive)
		case .ChainFishing:
			return chainFishingOddsService.getOdds(isShinyCharmActive: isCharmActive, chain: chain)
		case .DexNav:
			return dexNavOddsService.getOdds(searchLevel: min(chain, configuration.chainForBestOdds), isShinyCharmActive: isCharmActive)
		case .SosChaining:
			return sosChainingOddsService.getOdds(isShinyCharmActive: isCharmActive, chain: chain)
        case .Lure:
            return lgpeOddsService.getOdds(huntMethod: huntMethod, isShinyCharmActive: isCharmActive, catchCombo: chain)
		default:
            if(configuration.game == .LetsGoPikachu || configuration.game == .LetsGoEevee) {
                return lgpeOddsService.getOdds(huntMethod: huntMethod, isShinyCharmActive: isCharmActive, catchCombo: chain)
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

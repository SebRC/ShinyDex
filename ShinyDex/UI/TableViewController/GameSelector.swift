import UIKit

/// Choosing the game to hunt in, pushed from the game settings. Uses the same icon grid as every other picker.
/// Picking a game updates the Pokémon (dropping a method or charm the game doesn't have) and goes back.
enum GameSelector {
	fileprivate static let games = [GamesList.games[Games.Red],
		GamesList.games[Games.Blue],
		GamesList.games[Games.Yellow],
		GamesList.games[Games.Gold],
		GamesList.games[Games.Silver],
		GamesList.games[Games.Crystal],
		GamesList.games[Games.Ruby],
		GamesList.games[Games.Sapphire],
		GamesList.games[Games.Emerald],
		GamesList.games[Games.FireRed],
		GamesList.games[Games.LeafGreen],
		GamesList.games[Games.Diamond],
		GamesList.games[Games.Pearl],
		GamesList.games[Games.Platinum],
		GamesList.games[Games.Heartgold],
		GamesList.games[Games.SoulSilver],
		GamesList.games[Games.Black],
		GamesList.games[Games.White],
		GamesList.games[Games.Black2],
		GamesList.games[Games.White2],
		GamesList.games[Games.X],
		GamesList.games[Games.Y],
		GamesList.games[Games.OmegaRuby],
		GamesList.games[Games.AlphaSapphire],
		GamesList.games[Games.Sun],
		GamesList.games[Games.Moon],
		GamesList.games[Games.UltraSun],
		GamesList.games[Games.UltraMoon],
		GamesList.games[Games.LetsGoPikachu],
		GamesList.games[Games.LetsGoEevee],
		GamesList.games[Games.Sword],
		GamesList.games[Games.Shield],
		GamesList.games[Games.LegendsArceus],
		GamesList.games[Games.BrilliantDiamond],
		GamesList.games[Games.ShiningPearl],
		GamesList.games[Games.Scarlet],
		GamesList.games[Games.Violet]].compactMap { $0 }

	static func make(pokemon: Pokemon, selectedGame: Game?, onSelect: @escaping (Game) -> Void) -> GridPickerVC {
		let items = games.map { IconGridItem(title: $0.displayTitle, image: UIImage(named: $0.coverPokemon)) }
		let currentIndex = games.firstIndex { $0.title == selectedGame?.title }
		return GridPickerVC(title: "Game", caption: "Hunting in", items: items, columns: 3, currentIndex: currentIndex) { index in
			let game = games[index]
			pokemon.game = Games(rawValue: game.title) ?? Games.Red
			pokemon.generation = game.generation
			if (!game.availableMethods.contains(pokemon.huntMethod)) {
				pokemon.huntMethod = .Encounters
			}
			if (!game.isShinyCharmAvailable) {
				pokemon.isShinyCharmActive = false
			}
			if (pokemon.name != "Placeholder") {
				PokemonService().save(pokemon: pokemon)
			}
			onSelect(game)
		}
	}
}

import UIKit

class GameSelectorTVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var gameTableView: UITableView!
    
    var pokemonService = PokemonService()
    var pokemon: Pokemon!
    var selectedGame: Game!
    
    var games = [GamesList.games[Games.Red],
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
                 GamesList.games[Games.SoulSilver]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameTableView.delegate = self
        gameTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GamesList.games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameSelectorCell", for: indexPath) as! GameSelectorCell
        let game = games[indexPath.row]!
        cell.gameImage.image = UIImage(named: game.coverPokemon)
        cell.gameTitle.text = game.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game = games[indexPath.row]!
        pokemon.game = Games(rawValue: game.title) ?? Games.Red
        pokemon.generation = game.generation
        selectedGame = game
        
        if(pokemon.name != "Placeholder") {
            pokemonService.save(pokemon: pokemon)
            performSegue(withIdentifier: "unwindFromGameSelectorToGameSettings", sender: self)
        } else {
            performSegue(withIdentifier: "unwindFromGameSelector", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 101
    }
}

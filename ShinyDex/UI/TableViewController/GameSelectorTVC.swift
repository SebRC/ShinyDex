import UIKit

class GameSelectorTVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var gameTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
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
                 GamesList.games[Games.Violet]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameTableView.delegate = self
        gameTableView.dataSource = self
        
        view.backgroundColor = Color.Grey900
        gameTableView.separatorColor = Color.Grey900
        gameTableView.backgroundColor = Color.Grey900
        titleLabel.textColor = Color.Orange500
        cancelButton.backgroundColor = Color.Danger500
        cancelButton.setTitleColor(Color.Danger100, for: .normal)
        cancelButton.layer.cornerRadius = CornerRadius.standard
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GamesList.games.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Color.Grey800
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameSelectorCell", for: indexPath) as! GameSelectorCell
        let game = games[indexPath.row]!
        cell.gameImage.image = UIImage(named: game.coverPokemon)
        cell.gameTitle.text = game.title
        cell.gameTitle.textColor = Color.Grey200
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game = games[indexPath.row]!
        pokemon.game = Games(rawValue: game.title) ?? Games.Red
        pokemon.generation = game.generation
        let shouldMethodBeReset = !game.availableMethods.contains(pokemon.huntMethod)
        pokemon.huntMethod = shouldMethodBeReset ? .Encounters : pokemon.huntMethod
        if(!game.isShinyCharmAvailable) {
            pokemon.isShinyCharmActive = false
        }
        selectedGame = game
        
        if(pokemon.name != "Placeholder") {
            pokemonService.save(pokemon: pokemon)
            performSegue(withIdentifier: "unwindFromGameSelectorToGameSettings", sender: self)
        } else {
            performSegue(withIdentifier: "unwindFromGameSelector", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}

import UIKit

class PokeballModalVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var indicatorView: IndicatorView!
	@IBOutlet weak var pokeballTableView: UITableView!
	
	@IBOutlet weak var cancelButton: UIButton!
	var pokeballs = [Pokeball]()
	let txtReader = TxtReader()
	var pokemon: Pokemon!
	var pokemonService = PokemonService()
	var colorService = ColorService()
	var modalPosition: CGRect!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		self.pokeballTableView.delegate = self
		
		self.pokeballTableView.dataSource = self
		
		populatePokeballList()
		
		cancelButton.layer.cornerRadius = CornerRadius.standard
		pokeballTableView.layer.cornerRadius = CornerRadius.standard
		pokeballTableView.separatorColor = colorService.getPrimaryColor()
        view.backgroundColor = colorService.getPrimaryColor()
		pokeballTableView.backgroundColor = .clear
		indicatorView.titleLabel.text = "Select a new ball for \(pokemon.name)"
		indicatorView.pokemonImageView.image = UIImage(named: pokemon.name.lowercased())
    }
	
	fileprivate func populatePokeballList() {
		let pokeballList = txtReader.readFile(textFile: "pokeballs")
		for pokeball in pokeballList {
			pokeballs.append(Pokeball(ballName: pokeball))
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100.0
	}
    
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let pokeball = pokeballs[indexPath.row]
		pokemon.caughtBall = pokeball.name.lowercased()
		pokemon.caughtDescription = pokeball.name == "None" ? "Not Caught" : "Caught"
		pokemonService.save(pokemon: pokemon)
		performSegue(withIdentifier: "unwindFromPokeball", sender: self)
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.backgroundColor = colorService.getSecondaryColor()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return pokeballs.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "pokeballCell", for: indexPath) as! PokeballCell
		
		let pokeball = pokeballs[indexPath.row]

		setCellProperties(pokeballCell: cell, pokeball: pokeball)
		
        return cell
	}
	
	fileprivate func setCellProperties(pokeballCell: PokeballCell, pokeball: Pokeball) {
		pokeballCell.pokeballImageView.image = pokeball.image
        pokeballCell.nameLabel.text = pokeball.name
        pokeballCell.nameLabel.textColor = colorService.getTertiaryColor()
        
        if(pokeball.name.lowercased() == pokemon.caughtBall && pokeball.name.lowercased() != "none") {
            print(pokeball.name)
            print("caught ball \(pokemon.caughtBall)")
            pokeballCell.pokeballImageView.makeCircle()
            pokeballCell.pokeballImageView.backgroundColor = colorService.getPrimaryColor()
            pokeballCell.pokeballImageView.layer.borderWidth = 2
            pokeballCell.pokeballImageView.layer.borderColor = UIColor.systemOrange.cgColor
        } else {
            pokeballCell.pokeballImageView.backgroundColor = .none
            pokeballCell.pokeballImageView.layer.borderWidth = 0
            pokeballCell.pokeballImageView.layer.borderColor = UIColor.clear.cgColor
        }
	}
	
	@IBAction func cancelPressed(_ sender: Any) {
		dismiss(animated: true)
	}
}

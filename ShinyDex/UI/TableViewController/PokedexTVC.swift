import UIKit

class PokedexTVC: UITableViewController, PokemonCellDelegate {
	let searchController = UISearchController(searchResultsController: nil)
	
	var filteredPokemon = [Pokemon]()
	var allPokemon = [Pokemon]()
	var slicedPokemon = [Pokemon]()
	var hunts = [Hunt]()
	let textResolver = TextResolver()
	var selectedIndex = 0
	var generation = 0
	var selectedPokemon: Pokemon?
	var popupHandler = PopupHandler()
	let tableViewHelper = TableViewHelper()
	var pokemonService = PokemonService()
	var huntService = HuntService()
	var catchService = CatchService()
	var catchCounts = [Int: Int]()
	fileprivate let catchCountBadgeTag = 7161
	
	override func viewDidLoad() {
        super.viewDidLoad()

		setUIColors()

        searchController.searchBar.delegate = self
		
		setUpSearchController()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        
        setTitle()
		
        allPokemon = pokemonService.getAll()
        hunts = huntService.getAll()
        catchCounts = catchService.getCountsByNumber()
        slicedPokemon = slicePokemonList()

		tableView.reloadData()
	}
	
	fileprivate func setUIColors() {
        navigationController?.navigationBar.backgroundColor = Color.Grey900

        tableView.separatorColor = Color.Grey900
        tableView.backgroundColor = Color.Grey900
		
        searchController.searchBar.backgroundColor = Color.Grey900
		searchController.searchBar.barTintColor = Color.Grey800
	}
	
	fileprivate func setUpSearchController() {
		searchController.searchResultsUpdater = self
		
		searchController.obscuresBackgroundDuringPresentation = false
		
		searchController.searchBar.placeholder = "Search"
		
		navigationItem.searchController = searchController
		
		definesPresentationContext = true
	}
	
	fileprivate func setTitle() {
		navigationItem.title = textResolver.getGenTitle(gen: generation)
	}
	
	fileprivate func slicePokemonList() -> [Pokemon] {
		switch generation {
		case 0:
			return Array(allPokemon[0..<151])
		case 1:
			return Array(allPokemon[151..<251])
		case 2:
			return Array(allPokemon[251..<386])
		case 3:
			return Array(allPokemon[386..<493])
		case 4:
			return Array(allPokemon[493..<649])
		case 5:
			return Array(allPokemon[649..<721])
		case 6:
			return Array(allPokemon[721..<807])
		case 7:
			return Array(allPokemon[807..<898])
        case 8:
            return Array(allPokemon[898..<905])
        case 9:
            return Array(allPokemon[905..<1010])
		default:
			return allPokemon.filter({$0.caughtBall != "none"})
		}
	}

	override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		searchController.searchBar.resignFirstResponder()
	}
	
	func changeCaughtButtonPressed(_ sender: UIButton) {
		guard let indexPath = tableViewHelper.getPressedButtonIndexPath(sender, tableView) else {
			return
		}
		let pokemon = getSelectedPokemon(index: indexPath.row)
		selectedPokemon = pokemon
		tableView.reloadRows(at: [indexPath], with: .automatic)
		presentPokeballPicker(pokemon: pokemon)
	}

	fileprivate func presentPokeballPicker(pokemon: Pokemon) {
		let picker = PokeballModalVC(pokemon: pokemon) { [weak self] result in
			self?.pokeballPicked(pokemon: pokemon, result: result)
		}
		present(picker, animated: true)
	}

	fileprivate func pokeballPicked(pokemon: Pokemon, result: PokeballPickerResult) {
		catchCounts = catchService.getCountsByNumber()
		showCatchPopup(pokemon: pokemon, result: result)
		if (pokemon.caughtBall == CatchRules.noBall && generation == 11) {
			slicedPokemon.removeAll(where: { $0.name == pokemon.name })
		}
		tableView.reloadData()
	}

	fileprivate func showCatchPopup(pokemon: Pokemon, result: PokeballPickerResult) {
		switch result {
		case .loggedCatch:
			popupHandler.showPopup(text: "Logged a shiny \(pokemon.name). Caught: \(catchCounts[pokemon.number] ?? 0).")
		case .removedLatestCatch:
			popupHandler.showPopup(text: "Removed the latest \(pokemon.name) catch.")
		case .nothingToRemove:
			break
		}
	}
	
	func addToHuntPressed(_ sender: UIButton) {
		if let indexPath = tableViewHelper.getPressedButtonIndexPath(sender, tableView) {
			selectedPokemon = getSelectedPokemon(index: indexPath.row)
			if (hunts.isEmpty) {
				huntService.createNewHuntWithPokemon(hunts: &hunts, pokemon: selectedPokemon!)
				popupHandler.showPopup(text: "\(selectedPokemon!.name) was added to New Hunt")
				tableView.reloadData()
			}
			else if (hunts.count == 1) {
				huntService.addToOnlyExistingHunt(hunts: &hunts, pokemon: selectedPokemon!)
				popupHandler.showPopup(text: "\(selectedPokemon!.name) was added to \(hunts[0].name)")
				tableView.reloadData()
			}
			else {
				performSegue(withIdentifier: "pickHunt", sender: self)
			}
		}
	}
	
	fileprivate func getSelectedPokemon(index: Int) -> Pokemon {
		if (isFiltering()) {
			return filteredPokemon[index]
		}
		else {
			return slicedPokemon[index]
		}
	}
	
	func searchBarIsEmpty() -> Bool {
		return searchController.searchBar.text?.isEmpty ?? true
	}
	
	func filterContentForSearchText(_ searchText: String) {
		filteredPokemon = slicedPokemon.filter( {(pokemon : Pokemon) -> Bool in
			return pokemon.name.lowercased().contains(searchText.lowercased())
		})
		tableView.reloadData()
	}
	
	func isFiltering() -> Bool {
		return searchController.isActive && !searchBarIsEmpty()
	}
	
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return isFiltering() ? filteredPokemon.count : slicedPokemon.count
    }
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 65.0;
	}
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pokemonCell", for: indexPath) as! PokemonCell
		cell.cellDelegate = self
		selectedPokemon = getSelectedPokemon(index: indexPath.row)
		setCellImage(pokemonCell: cell, pokemon: selectedPokemon!)
		setPokemonCellProperties(pokemonCell: cell, pokemon: selectedPokemon!)
        return cell
    }
	
	fileprivate func setCellImage(pokemonCell: PokemonCell, pokemon: Pokemon) {
		pokemonCell.sprite.image = UIImage(named: pokemon.name.lowercased())
	}
	
	fileprivate func setPokemonCellProperties(pokemonCell: PokemonCell, pokemon: Pokemon) {
		pokemonCell.pokemonName?.text = pokemon.name
		pokemonCell.pokemonNumber.text = "No. \(String(pokemon.number + 1))"
		pokemonCell.caughtButton.setBackgroundImage(UIImage(named: pokemon.caughtBall), for: .normal)
		setCatchCountBadge(pokemonCell: pokemonCell, count: catchCounts[pokemon.number] ?? 0)
        pokemonCell.pokemonName.textColor = Color.Grey200
		pokemonCell.pokemonNumber.textColor = Color.Grey200
		pokemonCell.addToCurrentHuntButton.tintColor = Color.Grey200
		setAddToHuntButtonState(pokemonCell: pokemonCell, isBeingHunted: pokemon.isBeingHunted)
	}
	
	fileprivate func setCatchCountBadge(pokemonCell: PokemonCell, count: Int) {
		let caughtButton = pokemonCell.caughtButton!
		var badge = caughtButton.viewWithTag(catchCountBadgeTag) as? UILabel
		if (badge == nil) {
			let newBadge = UILabel()
			newBadge.tag = catchCountBadgeTag
			newBadge.font = UIFont.boldSystemFont(ofSize: 11)
			newBadge.textAlignment = .center
			newBadge.textColor = Color.Grey900
			newBadge.backgroundColor = Color.Orange500
			newBadge.layer.cornerRadius = 8
			newBadge.clipsToBounds = true
			newBadge.isUserInteractionEnabled = false
			newBadge.translatesAutoresizingMaskIntoConstraints = false
			caughtButton.clipsToBounds = false
			caughtButton.addSubview(newBadge)
			NSLayoutConstraint.activate([
				newBadge.heightAnchor.constraint(equalToConstant: 16),
				newBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 16),
				newBadge.topAnchor.constraint(equalTo: caughtButton.topAnchor, constant: -4),
				newBadge.trailingAnchor.constraint(equalTo: caughtButton.trailingAnchor, constant: 6)
			])
			badge = newBadge
		}
		badge?.text = " ×\(count) "
		badge?.isHidden = count < 2
	}

	fileprivate func setAddToHuntButtonState(pokemonCell: PokemonCell, isBeingHunted: Bool) {
		pokemonCell.addToCurrentHuntButton.isEnabled = !isBeingHunted
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedIndex = indexPath.row
		performSegue(withIdentifier: "trackShiny", sender: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let identifier = segue.identifier
		if (identifier == "pickHunt") {
			let destVC = segue.destination as? HuntPickerModalVC
			destVC?.pokemon = selectedPokemon
		}
		else {
			let destVC = segue.destination as? ShinyTrackerVC
			destVC?.pokemon = isFiltering() ? filteredPokemon[selectedIndex] : slicedPokemon[selectedIndex]
		}
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Color.Grey800
	}

	@IBAction func finish(_ unwindSegue: UIStoryboardSegue) {
		tableView.reloadData()
		let source = unwindSegue.source as! HuntPickerModalVC
		let name = source.pickedHuntName!
		popupHandler.showPopup(text: "\(selectedPokemon!.name) was added to \(name).")
	}
}

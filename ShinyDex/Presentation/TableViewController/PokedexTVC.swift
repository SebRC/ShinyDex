import UIKit

class PokedexTVC: UITableViewController {
	let searchController = UISearchController(searchResultsController: nil)
	
	fileprivate let container: AppContainer
	fileprivate var filteredPokemon = [PokedexEntry]()
	fileprivate var slicedPokemon = [PokedexEntry]()
	fileprivate var isRegion = false
	let textResolver = TextResolver()
	var generation = 0
	var popupHandler = PopupHandler()

	init(container: AppContainer, generation: Int) {
		self.container = container
		self.generation = generation
		super.init(style: .insetGrouped)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		tableView.register(PokemonCell.self, forCellReuseIdentifier: PokemonCell.reuseIdentifier)
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 68

		setUIColors()

        searchController.searchBar.delegate = self
		
		setUpSearchController()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        
        setTitle()
		
		reloadPokedex()
		tableView.reloadData()
		updateEmptyState()
		updateProgressHeader()
	}
	
	fileprivate func setUIColors() {
        tableView.separatorColor = Color.Grey700
        tableView.backgroundColor = Color.Grey900
		
        searchController.searchBar.backgroundColor = Color.Grey900
		searchController.searchBar.barTintColor = Color.Grey800
	}
	
	fileprivate func setUpSearchController() {
		searchController.searchResultsUpdater = self
		
		searchController.obscuresBackgroundDuringPresentation = false
		
		searchController.searchBar.placeholder = "Search by name or number"
		
		navigationItem.searchController = searchController
		
		definesPresentationContext = true
	}
	
	fileprivate func setTitle() {
		navigationItem.title = textResolver.getGenTitle(gen: generation)
	}
	
	fileprivate func reloadPokedex() {
		let pokedex = container.getPokedex.handle(GetPokedexQuery(region: generation))
		slicedPokemon = pokedex.entries
		isRegion = pokedex.isRegion
		if (isFiltering()) {
			filterContentForSearchText(searchController.searchBar.text ?? "")
		}
	}

	fileprivate func countCatches(of number: Int) -> Int {
		return slicedPokemon.first { $0.number == number }?.catchCount ?? 0
	}

	fileprivate func updateProgressHeader() {
		guard isRegion, !slicedPokemon.isEmpty else {
			tableView.tableHeaderView = nil
			return
		}
		let caught = slicedPokemon.filter { $0.catchCount > 0 }.count
		let header = (tableView.tableHeaderView as? DexProgressView) ?? DexProgressView()
		header.set(caught: caught, total: slicedPokemon.count)
		header.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 64)
		tableView.tableHeaderView = header
	}

	override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		searchController.searchBar.resignFirstResponder()
	}
	
	fileprivate func changeCaughtButtonPressed(pokemon: PokedexEntry) {
		presentPokeballPicker(pokemon: pokemon)
	}

	fileprivate func presentPokeballPicker(pokemon: PokedexEntry) {
		let picker = PokeballModalVC(container: container, number: pokemon.number, pokemonName: pokemon.name) { [weak self] result in
			self?.pokeballPicked(pokemon: pokemon, result: result)
		}
		present(picker.wrapInSheet(), animated: true)
	}

	fileprivate func pokeballPicked(pokemon: PokedexEntry, result: PokeballPickerResult) {
		reloadPokedex()
		showCatchPopup(pokemon: pokemon, result: result)
		tableView.reloadData()
		updateProgressHeader()
	}

	fileprivate func showCatchPopup(pokemon: PokedexEntry, result: PokeballPickerResult) {
		switch result {
		case .loggedCatch:
			popupHandler.showPopup(text: "Logged a shiny \(pokemon.name). Caught: \(countCatches(of: pokemon.number)).")
		case .loggedFailed:
			popupHandler.showPopup(text: "Logged a shiny \(pokemon.name) that got away.")
		case .removedLatestCatch:
			popupHandler.showPopup(text: "Removed the latest \(pokemon.name) catch.")
		case .nothingToRemove:
			break
		}
	}
	
	fileprivate func addToHuntPressed(pokemon: PokedexEntry) {
		let picker = HuntPickerModalVC(container: container, number: pokemon.number, pokemonName: pokemon.name) { [weak self] huntName in
			guard let self = self else { return }
			self.reloadPokedex()
			self.tableView.reloadData()
			self.popupHandler.showPopup(text: "\(pokemon.name) was added to \(huntName).")
		}
		present(picker.wrapInSheet(), animated: true)
	}

	fileprivate func getSelectedPokemon(index: Int) -> PokedexEntry {
		if (isFiltering()) {
			return filteredPokemon[index]
		}
		else {
			return slicedPokemon[index]
		}
	}
	
	func isSearchBarEmpty() -> Bool {
		return searchController.searchBar.text?.isEmpty ?? true
	}
	
	func filterContentForSearchText(_ searchText: String) {
		let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
		let number = Int(query.trimmingCharacters(in: CharacterSet(charactersIn: "#")))
		filteredPokemon = slicedPokemon.filter { pokemon in
			if let number = number {
				return pokemon.number + 1 == number
			}
			return pokemon.name.lowercased().contains(query)
		}
		tableView.reloadData()
		updateEmptyState()
	}

	fileprivate func updateEmptyState() {
		let showsNoResults = isFiltering() && filteredPokemon.isEmpty
		let showsNoCaught = !isFiltering() && slicedPokemon.isEmpty
		if (showsNoResults) {
			tableView.backgroundView = EmptyStateView(symbolName: "magnifyingglass",
													  title: "No results",
													  message: "No Pokémon match \u{201C}\(searchController.searchBar.text ?? "")\u{201D}.")
		}
		else if (showsNoCaught) {
			tableView.backgroundView = EmptyStateView(symbolName: "sparkles",
													  title: "No shinies yet",
													  message: "Tap the Poké Ball next to a Pokémon to log that you caught it.")
		}
		else {
			tableView.backgroundView = nil
		}
	}
	
	func isFiltering() -> Bool {
		return searchController.isActive && !isSearchBarEmpty()
	}
	
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return isFiltering() ? filteredPokemon.count : slicedPokemon.count
    }
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PokemonCell.reuseIdentifier, for: indexPath) as! PokemonCell
		let pokemon = getSelectedPokemon(index: indexPath.row)
		cell.onCaughtPressed = { [weak self] in self?.changeCaughtButtonPressed(pokemon: pokemon) }
		cell.onAddToHuntPressed = { [weak self] in self?.addToHuntPressed(pokemon: pokemon) }
		setCellImage(pokemonCell: cell, pokemon: pokemon)
		setPokemonCellProperties(pokemonCell: cell, pokemon: pokemon)
        return cell
    }
	
	fileprivate func setCellImage(pokemonCell: PokemonCell, pokemon: PokedexEntry) {
		pokemonCell.sprite.image = UIImage(named: pokemon.name.lowercased())
	}
	
	fileprivate func setPokemonCellProperties(pokemonCell: PokemonCell, pokemon: PokedexEntry) {
		let catchCount = pokemon.catchCount
		pokemonCell.pokemonName.text = pokemon.name
		pokemonCell.pokemonNumber.text = String(format: "#%03d", pokemon.number + 1)
		pokemonCell.setStatus(catchCount: catchCount, caughtBall: pokemon.caughtBall, isBeingHunted: pokemon.isBeingHunted)

		pokemonCell.caughtButton.accessibilityLabel = "Log a catch of \(pokemon.name)"
		pokemonCell.caughtButton.accessibilityValue = catchCount == 0 ? "Not caught" : (catchCount == 1 ? "Caught once" : "Caught \(catchCount) times")
		pokemonCell.addToCurrentHuntButton.accessibilityLabel = pokemon.isBeingHunted ? "Already in a hunt" : "Add \(pokemon.name) to a hunt"
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		openTracker(for: getSelectedPokemon(index: indexPath.row))
	}

	fileprivate func openTracker(for pokemon: PokedexEntry) {
		guard let tracker = ShinyTrackerVC(container: container, number: pokemon.number) else { return }
		navigationController?.pushViewController(tracker, animated: true)
	}
	

	override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let pokemon = getSelectedPokemon(index: indexPath.row)
		let logCatch = UIContextualAction(style: .normal, title: "Log catch") { [weak self] _, _, completion in
			self?.changeCaughtButtonPressed(pokemon: pokemon)
			completion(true)
		}
		logCatch.image = UIImage(systemName: PokemonCell.logCatchSymbol)
		logCatch.backgroundColor = Color.Orange600
		return UISwipeActionsConfiguration(actions: [logCatch])
	}

	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let pokemon = getSelectedPokemon(index: indexPath.row)
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
			let logCatch = UIAction(title: "Log a catch", image: UIImage(systemName: PokemonCell.logCatchSymbol)) { _ in
				self?.changeCaughtButtonPressed(pokemon: pokemon)
			}
			let addToHunt = UIAction(title: pokemon.isBeingHunted ? "Already in a hunt" : "Add to hunt",
									 image: UIImage(systemName: "plus.circle"),
									 attributes: pokemon.isBeingHunted ? .disabled : []) { _ in
				self?.addToHuntPressed(pokemon: pokemon)
			}
			let openTracker = UIAction(title: "Open tracker", image: UIImage(systemName: "chevron.right.circle")) { _ in
				self?.openTracker(for: pokemon)
			}
			return UIMenu(title: pokemon.name, children: [logCatch, addToHunt, openTracker])
		}
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Color.Grey800
	}
}

class DexProgressView: UIView {
	fileprivate let titleLabel = UILabel(fontSize: 15, weight: .semibold)
	fileprivate let percentLabel = UILabel(fontSize: 15, weight: .semibold, color: Color.Orange500)
	fileprivate let bar = UIProgressView(progressViewStyle: .default)

	override init(frame: CGRect) {
		super.init(frame: frame)
		percentLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .semibold)
		bar.progressTintColor = Color.Orange500
		bar.trackTintColor = Color.Grey800
		bar.layer.cornerRadius = 3
		bar.clipsToBounds = true
		let labels = UIStackView(arrangedSubviews: [titleLabel, UIView(), percentLabel])
		let stack = UIStackView(arrangedSubviews: [labels, bar])
		stack.axis = .vertical
		stack.spacing = 8
		addAutoLayoutSubviews(stack)
		NSLayoutConstraint.activate([
			stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
			stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
			stack.centerYAnchor.constraint(equalTo: centerYAnchor),
			bar.heightAnchor.constraint(equalToConstant: 6)
		])
		isAccessibilityElement = true
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func set(caught: Int, total: Int) {
		let fraction = total > 0 ? Float(caught) / Float(total) : 0
		titleLabel.text = "\(caught) of \(total) caught"
		percentLabel.text = "\(Int((fraction * 100).rounded()))%"
		bar.progress = fraction
		accessibilityLabel = "\(caught) of \(total) caught"
	}
}

import UIKit

class PokedexTVC: UITableViewController {
    let searchController = UISearchController(searchResultsController: nil)
    
    fileprivate let container: AppContainer
    fileprivate var filteredPokemon = [PokedexEntry]()
    fileprivate var slicedPokemon = [PokedexEntry]()
    fileprivate var pokedex = Pokedex.empty
    fileprivate static var selectedFilter = PokedexFilter.all
    fileprivate let filterControl = UISegmentedControl(items: ["All", "Not caught", "Caught", "In a hunt"])
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
        setUpFilterControl()
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
        tableView.separatorColor = Color.separator
        tableView.backgroundColor = Color.background
        
        searchController.searchBar.backgroundColor = Color.background
        searchController.searchBar.barTintColor = Color.surface
    }
    
    fileprivate func setUpSearchController() {
        searchController.searchResultsUpdater = self
        
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.placeholder = "Search by name or number"
        
        navigationItem.searchController = searchController
        
        definesPresentationContext = true
    }
    
    fileprivate func setUpFilterControl() {
        filterControl.selectedSegmentIndex = PokedexFilter.allCases.firstIndex(of: PokedexTVC.selectedFilter) ?? 0
        filterControl.selectedSegmentTintColor = Color.accent
        filterControl.setTitleTextAttributes([.foregroundColor: Color.textPrimary, .font: UIFont.make(.footnote, weight: .semibold)], for: .normal)
        filterControl.setTitleTextAttributes([.foregroundColor: Color.background, .font: UIFont.make(.footnote, weight: .bold)], for: .selected)
        filterControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        filterControl.accessibilityLabel = "Filter"
    }

    @objc fileprivate func filterChanged() {
        PokedexTVC.selectedFilter = PokedexFilter.allCases[filterControl.selectedSegmentIndex]
        Haptics.tap()
        reloadPokedex()
        tableView.reloadData()
        updateEmptyState()
    }

    fileprivate func setTitle() {
        navigationItem.title = textResolver.getGenTitle(gen: generation)
    }
    
    fileprivate func reloadPokedex() {
        pokedex = container.getPokedex.handle(GetPokedexQuery(region: generation, filter: PokedexTVC.selectedFilter))
        slicedPokemon = pokedex.entries
        if (isFiltering()) {
            filterContentForSearchText(searchController.searchBar.text ?? "")
        }
    }

    fileprivate func countCatches(of number: Int) -> Int {
        return slicedPokemon.first { $0.number == number }?.catchCount ?? 0
    }

    fileprivate func updateProgressHeader() {
        guard pokedex.totalCount > 0 else {
            tableView.tableHeaderView = nil
            return
        }
        let header = (tableView.tableHeaderView as? PokedexHeaderView) ?? PokedexHeaderView(filterControl: filterControl)
        header.progressView.set(caught: pokedex.caughtCount, total: pokedex.totalCount)
        header.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 112)
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
        guard let game = pokemon.shinyLockedGame else {
            showHuntPicker(for: pokemon)
            return
        }
        presentShinyLockWarning(pokemonName: pokemon.name, game: game) { [weak self] in
            self?.showHuntPicker(for: pokemon)
        }
    }

    fileprivate func showHuntPicker(for pokemon: PokedexEntry) {
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
        if (isFiltering() && filteredPokemon.isEmpty) {
            tableView.backgroundView = EmptyStateView(symbolName: "magnifyingglass",
                                                      title: "No results",
                                                      message: "No Pokémon match \u{201C}\(searchController.searchBar.text ?? "")\u{201D}.")
        }
        else if (!isFiltering() && slicedPokemon.isEmpty && pokedex.totalCount > 0) {
            tableView.backgroundView = makeEmptyFilterView()
        }
        else {
            tableView.backgroundView = nil
        }
    }
    
    fileprivate func makeEmptyFilterView() -> UIView {
        switch PokedexTVC.selectedFilter {
        case .notCaught:
            return EmptyStateView(symbolName: "trophy.fill", title: "All caught!", message: "Every Pokémon in this Pokédex has been caught as a shiny.")
        case .caught:
            return EmptyStateView(symbolName: "sparkles", title: "None caught yet", message: "Shinies you catch from this Pokédex will show up here.")
        case .inHunt:
            return EmptyStateView(symbolName: "scope", title: "No hunts here", message: "None of these Pokémon are in a hunt. Add one with the + button next to it.")
        case .all:
            return EmptyStateView(symbolName: "magnifyingglass", title: "No Pokémon", message: "This Pokédex is empty.")
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
        pokemonCell.sprite.image = PokemonSprites.makeImage(pokemonName: pokemon.name)
    }
    
    fileprivate func setPokemonCellProperties(pokemonCell: PokemonCell, pokemon: PokedexEntry) {
        let catchCount = pokemon.catchCount
        pokemonCell.pokemonName.text = pokemon.name
        pokemonCell.pokemonNumber.text = String(format: "#%03d", pokemon.number + 1)
        pokemonCell.setStatus(catchCount: catchCount, caughtBall: pokemon.caughtBall, isBeingHunted: pokemon.isBeingHunted, shinyLockedGame: pokemon.shinyLockedGame)

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
        cell.backgroundColor = Color.surface
    }
}

class PokedexHeaderView: UIView {
    let progressView = DexProgressView()

    init(filterControl: UISegmentedControl) {
        super.init(frame: .zero)
        addAutoLayoutSubviews(progressView, filterControl)
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: topAnchor),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 64),
            filterControl.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 4),
            filterControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            filterControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            filterControl.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DexProgressView: UIView {
    fileprivate let titleLabel = UILabel(style: .subheadline, weight: .semibold)
    fileprivate let percentLabel = UILabel(style: .subheadline, weight: .semibold, color: Color.accent)
    fileprivate let bar = UIProgressView(progressViewStyle: .default)

    override init(frame: CGRect) {
        super.init(frame: frame)
        percentLabel.font = UIFont.make(.subheadline, weight: .semibold, monospacedDigits: true)
        bar.progressTintColor = Color.accent
        bar.trackTintColor = Color.surface
        bar.layer.cornerRadius = CornerRadius.tiny
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

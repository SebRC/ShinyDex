import UIKit

class CollectionTVC: UITableViewController, UISearchResultsUpdating {
	fileprivate struct Entry {
		let caught: Catch
		let pokemon: Pokemon
	}

	fileprivate let catchService = CatchService()
	fileprivate let pokemonService = PokemonService()
	fileprivate let searchController = UISearchController(searchResultsController: nil)
	fileprivate var entries = [Entry]()
	fileprivate var visibleEntries = [Entry]()

	init() {
		super.init(style: .insetGrouped)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Collection"
		tableView.backgroundColor = Color.Grey900
		tableView.separatorColor = Color.Grey900
		tableView.register(CatchCell.self, forCellReuseIdentifier: CatchCell.reuseIdentifier)
		setUpSearchController()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		reloadEntries()
	}

	fileprivate func setUpSearchController() {
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search"
		searchController.searchBar.barTintColor = Color.Grey800
		navigationItem.searchController = searchController
		definesPresentationContext = true
	}

	fileprivate func reloadEntries() {
		let pokemonByNumber = Dictionary(pokemonService.getAll().map { ($0.number, $0) }, uniquingKeysWith: { first, _ in first })
		entries = CatchRules.sortedForCollection(catchService.getAll()).compactMap { caught in
			pokemonByNumber[caught.number].map { Entry(caught: caught, pokemon: $0) }
		}
		applySearch()
	}

	fileprivate func applySearch() {
		let searchText = searchController.searchBar.text?.lowercased() ?? ""
		visibleEntries = searchText.isEmpty ? entries : entries.filter { $0.pokemon.name.lowercased().contains(searchText) }
		tableView.reloadData()
		updateEmptyState()
	}

	fileprivate func updateEmptyState() {
		guard visibleEntries.isEmpty else {
			tableView.backgroundView = nil
			return
		}
		let label = UILabel()
		label.text = entries.isEmpty ? "No catches logged yet." : "No catches match your search."
		label.numberOfLines = 0
		label.textAlignment = .center
		label.textColor = Color.Grey400
		tableView.backgroundView = label
	}

	func updateSearchResults(for searchController: UISearchController) {
		applySearch()
	}

	override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		searchController.searchBar.resignFirstResponder()
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return visibleEntries.count
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return CatchCell.height
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: CatchCell.reuseIdentifier, for: indexPath) as! CatchCell
		let entry = visibleEntries[indexPath.row]
		cell.configure(pokemon: entry.pokemon,
					   title: entry.pokemon.name,
					   subtitle: ["No. \(entry.pokemon.number + 1)", entry.caught.formattedCaughtDate].compactMap { $0 }.joined(separator: " · "),
					   ball: entry.caught.caughtBall)
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let entry = visibleEntries[indexPath.row]
		navigationController?.pushViewController(CatchDetailTVC(caught: entry.caught, pokemon: entry.pokemon), animated: true)
	}
}

import UIKit

class CollectionTVC: UITableViewController, UISearchResultsUpdating {
	fileprivate struct Entry {
		let caught: Catch
		let pokemon: Pokemon
	}

	fileprivate let catchService = CatchService()
	fileprivate let pokemonService = PokemonService()
	fileprivate let searchController = UISearchController(searchResultsController: nil)
	fileprivate let cellIdentifier = "collectionCell"
	fileprivate var entries = [Entry]()
	fileprivate var visibleEntries = [Entry]()

	init() {
		super.init(style: .plain)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Collection"
		tableView.backgroundColor = Color.Grey900
		tableView.separatorColor = Color.Grey900
		tableView.tableFooterView = UIView()
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
		return 65.0
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
		let entry = visibleEntries[indexPath.row]
		cell.imageView?.image = UIImage(named: entry.pokemon.name.lowercased())
		cell.textLabel?.text = "\(entry.pokemon.name) · No. \(entry.pokemon.number + 1)"
		cell.textLabel?.textColor = Color.Grey200
		cell.detailTextLabel?.text = "\(entry.caught.ballName) · \(entry.caught.game.rawValue) · \(entry.caught.caughtDateText)"
		cell.detailTextLabel?.textColor = Color.Grey400
		cell.accessoryView = makeBallImageView(ball: entry.caught.caughtBall)
		cell.backgroundColor = Color.Grey800
		return cell
	}

	fileprivate func makeBallImageView(ball: String) -> UIImageView {
		let imageView = UIImageView(image: UIImage(named: ball))
		imageView.contentMode = .scaleAspectFit
		imageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
		return imageView
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let entry = visibleEntries[indexPath.row]
		navigationController?.pushViewController(CatchDetailTVC(caught: entry.caught, pokemon: entry.pokemon), animated: true)
	}
}

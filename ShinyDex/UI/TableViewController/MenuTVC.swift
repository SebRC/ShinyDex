import UIKit

class MenuTVC: UITableViewController {
	fileprivate enum Destination {
		case pokedex(generation: Int)
		case hunts
		case collection
		case ppCounter
		case stats
	}

	/// Rows are grouped so the tools people use every session (hunts, collection, PP counter) sit at the top,
	/// with the generation Pokédexes below. Row numbers are the menu indexes `TextResolver` uses for titles.
	fileprivate let sections: [(title: String, rows: [Int])] = [
		("Tracking", [10, 11, 13, 12]),
		("Pokédex", Array(0...9))
	]

	var hunts = [Hunt]()
	let textResolver = TextResolver()
	var huntService = HuntService()
	fileprivate let catchService = CatchService()
	fileprivate var catchCounts = [Int: Int]()
	fileprivate var totalCatches = 0
	fileprivate var menuStats: CatchStats?

	init() {
		super.init(style: .insetGrouped)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Menu"
		navigationItem.largeTitleDisplayMode = .always
		navigationItem.hidesBackButton = true
		let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(settingsPressed))
		settingsButton.accessibilityLabel = "Settings"
		navigationItem.rightBarButtonItem = settingsButton

		tableView.backgroundColor = Color.Grey900
		tableView.separatorColor = Color.Grey700
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 80
		tableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.reuseIdentifier)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		hunts = huntService.getAll()
		let catches = catchService.getAll()
		totalCatches = catches.count
		catchCounts = CatchRules.countsByNumber(catches)
		menuStats = CatchStats(catches: catchService.getAllIncludingFailed())
		tableView.reloadData()
	}

	fileprivate func menuIndex(for indexPath: IndexPath) -> Int {
		return sections[indexPath.section].rows[indexPath.row]
	}

	fileprivate func destination(for index: Int) -> Destination {
		switch index {
		case 10: return .hunts
		case 11: return .collection
		case 12: return .ppCounter
		case 13: return .stats
		default: return .pokedex(generation: index)
		}
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].rows.count
	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let label = UILabel()
		label.text = sections[section].title
		label.font = UIFont.preferredFont(forTextStyle: .title3).withWeight(.bold)
		label.adjustsFontForContentSizeCategory = true
		label.textColor = Color.Grey200
		label.accessibilityTraits = .header
		let container = UIView()
		container.addAutoLayoutSubviews(label)
		NSLayoutConstraint.activate([
			label.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
			label.trailingAnchor.constraint(equalTo: container.layoutMarginsGuide.trailingAnchor),
			label.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
			label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
		])
		return container
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return UITableView.automaticDimension
	}

	override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
		return 52
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.reuseIdentifier, for: indexPath) as! MenuCell
		let index = menuIndex(for: indexPath)
		var image = resolveGenImage(gen: index)
		if (index == 10), let firstHuntPokemon = hunts.first?.pokemon.first {
			image = UIImage(named: firstHuntPokemon.name.lowercased())
		}
		cell.configure(title: textResolver.getGenTitle(gen: index), subtitle: subtitle(for: index), image: image, progress: progress(for: index))
		return cell
	}

	fileprivate func subtitle(for index: Int) -> String {
		switch index {
		case 10:
			guard !hunts.isEmpty else { return "No hunts yet" }
			let encounters = hunts.reduce(0) { $0 + $1.pokemon.reduce(0) { $0 + $1.encounters } }
			let huntText = hunts.count == 1 ? "1 hunt" : "\(hunts.count) hunts"
			return "\(huntText) · \(encounters.grouped) encounters"
		case 11:
			return totalCatches == 1 ? "1 shiny caught" : "\(totalCatches.grouped) shinies caught"
		case 12:
			return "Track PP during battles"
		case 13:
			guard let average = menuStats?.averageEncounters else { return "Averages, balls, records and more" }
			return "\(average.grouped) encounters per shiny on average"
		default:
			guard let range = PokedexTVC.pokemonRange(for: index) else { return "" }
			let caught = range.filter { (catchCounts[$0] ?? 0) > 0 }.count
			// Hisui sits between Galar (gen 8) and Paldea (gen 9) in the menu, so it shifts the numbering after it.
			let region = index == 8 ? "Legends: Arceus" : "Generation \(index < 8 ? index + 1 : index)"
			return "\(region) · \(caught)/\(range.count) caught"
		}
	}

	fileprivate func progress(for index: Int) -> Float? {
		guard let range = PokedexTVC.pokemonRange(for: index) else { return nil }
		let caught = range.filter { (catchCounts[$0] ?? 0) > 0 }.count
		return Float(caught) / Float(range.count)
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let viewController: UIViewController
		switch destination(for: menuIndex(for: indexPath)) {
		case .pokedex(let generation):
			viewController = PokedexTVC(generation: generation)
		case .hunts:
			viewController = HuntsTVC()
		case .collection:
			viewController = CollectionTVC()
		case .ppCounter:
			viewController = PPCounterTVC()
		case .stats:
			viewController = StatsVC()
		}
		navigationController?.pushViewController(viewController, animated: true)
	}

	fileprivate func resolveGenImage(gen: Int) -> UIImage? {
		switch gen {
		case 0...7:
			return UIImage(named: "gen\(gen + 1)")
		case 8:
			return UIImage(named: "hisui")
		case 9:
			return UIImage(named: "gen9")
		case 10:
			return UIImage(named: HuntMethod.Encounters.rawValue)
		case 11:
			return UIImage(named: "collection")
		case 12:
			return UIImage(named: "journal")
		case 13:
			// Drawn at a fixed size inside the icon frame so it sits at the same weight as the pixel art beside it.
			return UIImage.symbol("chart.bar.fill", pointSize: 20, weight: .medium)?.padded(to: CGSize(width: 56, height: 56))
		default:
			return UIImage(named: "gen1")
		}
	}

	@objc fileprivate func settingsPressed() {
		navigationController?.pushViewController(SettingsVC(pokemon: Pokemon()), animated: true)
	}
}

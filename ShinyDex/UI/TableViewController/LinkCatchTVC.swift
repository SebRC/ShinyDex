import UIKit

class LinkCatchTVC: UITableViewController {
	fileprivate let entry: JourneyEntry
	fileprivate let journey: Journey
	fileprivate let allPokemon: [Pokemon]
	fileprivate let onLink: (Catch) -> Void
	fileprivate var catches = [Catch]()

	init(entry: JourneyEntry, journey: Journey, allPokemon: [Pokemon], onLink: @escaping (Catch) -> Void) {
		self.entry = entry
		self.journey = journey
		self.allPokemon = allPokemon
		self.onLink = onLink
		super.init(style: .insetGrouped)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	fileprivate var entryName: String {
		return allPokemon[safe: entry.number]?.name ?? "this Pokémon"
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Link a catch"
		navigationItem.largeTitleDisplayMode = .never
		tableView.backgroundColor = Color.Grey900
		tableView.separatorColor = Color.Grey700
		tableView.register(CatchCell.self, forCellReuseIdentifier: CatchCell.reuseIdentifier)
		catches = JourneyService().linkableCatches(for: entry, in: journey)
		if (catches.isEmpty) {
			tableView.backgroundView = EmptyStateView(symbolName: "sparkles",
													  title: "Nothing to link",
													  message: "You haven't caught a shiny \(entryName) yet. Log one from its tracker, then link it here.")
		}
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return catches.count
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return catches.isEmpty ? nil : "Your \(entryName) catches"
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return catches.isEmpty ? nil : "Includes catches from \(entryName)'s evolution line. Each catch can be linked once per journey."
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return CatchCell.height
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: CatchCell.reuseIdentifier, for: indexPath) as! CatchCell
		let caught = catches[indexPath.row]
		guard let pokemon = allPokemon[safe: caught.number] else { return cell }
		let title = pokemon.number == entry.number ? "\(caught.ballName) · \(caught.game.displayName)" : "\(pokemon.name) · \(caught.ballName)"
		cell.configure(pokemon: pokemon,
					   title: title,
					   subtitle: ["\(caught.encounters.grouped) encounters", caught.formattedCaughtDate].compactMap { $0 }.joined(separator: " · "),
					   ball: caught.caughtBall)
		cell.accessoryType = caught.id == entry.catchId ? .checkmark : .none
		cell.tintColor = Color.Orange500
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		onLink(catches[indexPath.row])
		navigationController?.popViewController(animated: true)
	}
}

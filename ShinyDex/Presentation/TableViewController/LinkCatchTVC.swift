import UIKit

class LinkCatchTVC: UITableViewController {
	fileprivate let container: AppContainer
	fileprivate let journeyId: JourneyID
	fileprivate let entry: JourneyEntryDetails
	fileprivate let role: JourneyCatchRole
	fileprivate let onLink: (CatchSummary) -> Void
	fileprivate var catches = [CatchSummary]()

	init(container: AppContainer, journeyId: JourneyID, entry: JourneyEntryDetails, role: JourneyCatchRole = .target, onLink: @escaping (CatchSummary) -> Void) {
		self.container = container
		self.journeyId = journeyId
		self.entry = entry
		self.role = role
		self.onLink = onLink
		super.init(style: .insetGrouped)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	fileprivate var entryName: String {
		return entry.pokemonName ?? "this Pokémon"
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = role == .target ? "Link a catch" : "Log a phase"
		navigationItem.largeTitleDisplayMode = .never
		tableView.backgroundColor = Color.Grey900
		tableView.separatorColor = Color.Grey700
		tableView.register(CatchCell.self, forCellReuseIdentifier: CatchCell.reuseIdentifier)
		catches = container.getLinkableCatches.handle(GetLinkableCatchesQuery(journeyId: journeyId, entryId: entry.id, role: role))
		if (catches.isEmpty) {
			let message = role == .target
				? "You haven't caught a shiny \(entryName) yet. Log one from its tracker, then link it here."
				: "Add the shiny you found to your collection first, marking it as got away if it fled. Then link it here."
			tableView.backgroundView = EmptyStateView(symbolName: "sparkles", title: "Nothing to link", message: message)
		}
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return catches.count
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard !catches.isEmpty else { return nil }
		return role == .target ? "Your \(entryName) catches" : "Shinies found while hunting \(entryName)"
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		guard !catches.isEmpty else { return nil }
		return role == .target
			? "Includes catches from \(entryName)'s evolution line. Each catch can be linked once per journey."
			: "A phase is a shiny of another species, including ones that got away. Each catch can be linked once per journey."
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return CatchCell.height
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: CatchCell.reuseIdentifier, for: indexPath) as! CatchCell
		let caught = catches[indexPath.row]
		let outcome = caught.isFailed ? "Got away" : caught.ballName
		let title = [caught.nickname] + (caught.number == entry.number ? [outcome, caught.game.displayName] : [caught.pokemonName, outcome])
		cell.configure(pokemonName: caught.pokemonName,
					   title: title.compactMap { $0 }.joined(separator: " · "),
					   subtitle: ["\(caught.encounters.grouped) encounters", caught.formattedCaughtDate].compactMap { $0 }.joined(separator: " · "),
					   ball: caught.caughtBall,
					   isFailed: caught.isFailed)
		cell.accessoryType = caught.id == entry.linkedCatch?.id ? .checkmark : .none
		cell.tintColor = Color.Orange500
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		onLink(catches[indexPath.row])
		navigationController?.popViewController(animated: true)
	}
}

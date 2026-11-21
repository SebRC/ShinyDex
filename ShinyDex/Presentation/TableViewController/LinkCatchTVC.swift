import UIKit

struct LinkCatchTarget {
	let number: Int
	let pokemonName: String?
	let linkedCatchId: CatchID?
	let collectionName: String
}

class LinkCatchTVC: UITableViewController {
	fileprivate let target: LinkCatchTarget
	fileprivate let role: JourneyCatchRole
	fileprivate let catches: [CatchSummary]
	fileprivate let onLink: (CatchSummary) -> Void

	init(target: LinkCatchTarget, role: JourneyCatchRole = .target, catches: [CatchSummary], onLink: @escaping (CatchSummary) -> Void) {
		self.target = target
		self.role = role
		self.catches = catches
		self.onLink = onLink
		super.init(style: .insetGrouped)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	fileprivate var entryName: String {
		return target.pokemonName ?? "this Pokémon"
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = role == .target ? "Link a catch" : "Log a phase"
		navigationItem.largeTitleDisplayMode = .never
		tableView.backgroundColor = Color.background
		tableView.separatorColor = Color.separator
		tableView.register(CatchCell.self, forCellReuseIdentifier: CatchCell.reuseIdentifier)
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


	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return SectionHeaderView.make(for: tableView, title: self.tableView(tableView, titleForHeaderInSection: section))
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard !catches.isEmpty else { return nil }
		return role == .target ? "Your \(entryName) catches" : "Shinies found while hunting \(entryName)"
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		guard !catches.isEmpty else { return nil }
		return role == .target
			? "Includes catches from \(entryName)'s evolution line. Each catch can be linked once per \(target.collectionName)."
			: "A phase is a shiny of another species, including ones that got away. Each catch can be linked once per \(target.collectionName)."
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return CatchCell.height
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: CatchCell.reuseIdentifier, for: indexPath) as! CatchCell
		let caught = catches[indexPath.row]
		let outcome = caught.isFailed ? "Got away" : caught.ballName
		let title = [caught.nickname] + (caught.number == target.number ? [caught.formName, outcome, caught.game.displayName] : [caught.speciesTitle, outcome])
		cell.configure(pokemonName: caught.pokemonName,
					   formId: caught.formId,
					   title: title.compactMap { $0 }.joined(separator: " · "),
					   subtitle: ["\(caught.encounters.grouped) encounters", caught.formattedCaughtDate].compactMap { $0 }.joined(separator: " · "),
					   ball: caught.caughtBall,
					   isFailed: caught.isFailed)
		cell.accessoryType = caught.id == target.linkedCatchId ? .checkmark : .none
		cell.tintColor = Color.accent
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		onLink(catches[indexPath.row])
		navigationController?.popViewController(animated: true)
	}
}

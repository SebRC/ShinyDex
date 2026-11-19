import UIKit

class CatchesTVC: UITableViewController {
	fileprivate let container: AppContainer
	fileprivate let number: Int
	fileprivate let pokemonName: String
	fileprivate var catches = [CatchSummary]()

	init(container: AppContainer, number: Int, pokemonName: String) {
		self.container = container
		self.number = number
		self.pokemonName = pokemonName
		super.init(style: .insetGrouped)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "\(pokemonName) catches"
		tableView.backgroundColor = Color.Grey900
		tableView.separatorColor = Color.Grey700
		tableView.register(CatchCell.self, forCellReuseIdentifier: CatchCell.reuseIdentifier)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		reloadCatches()
	}

	fileprivate func reloadCatches() {
		catches = container.getCatches.handle(GetCatchesQuery(scope: .species(number), includingFailed: true)).reversed()
		tableView.reloadData()
		updateEmptyState()
	}

	fileprivate func updateEmptyState() {
		if (catches.isEmpty) {
			tableView.backgroundView = EmptyStateView(symbolName: "sparkles",
													  title: "No catches yet",
													  message: "Tap Log catch on the tracker to log a shiny \(pokemonName).")
		}
		else {
			tableView.backgroundView = nil
		}
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return catches.count
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return CatchCell.height
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: CatchCell.reuseIdentifier, for: indexPath) as! CatchCell
		let caught = catches[indexPath.row]
		cell.configure(pokemonName: pokemonName,
					   title: [caught.nickname, caught.isFailed ? "Got away" : caught.ballName, caught.game.displayName].compactMap { $0 }.joined(separator: " · "),
					   subtitle: ["\(caught.encounters.grouped) encounters", caught.formattedCaughtDate].compactMap { $0 }.joined(separator: " · "),
					   ball: caught.caughtBall,
					   isFailed: caught.isFailed)
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		guard let detail = CatchDetailTVC(container: container, catchId: catches[indexPath.row].id) else { return }
		navigationController?.pushViewController(detail, animated: true)
	}

	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
			guard let self = self else { return completion(false) }
			let caught = self.catches[indexPath.row]
			let description = caught.isFailed ? "The \(self.pokemonName) that got away in" : "The \(caught.ballName) \(self.pokemonName) from"
			self.presentDestructiveConfirmation(title: caught.isFailed ? "Delete this entry?" : "Delete this catch?",
												message: "\(description) \(caught.game.displayName) will be removed. This can't be undone.",
												destructiveTitle: "Delete") { [weak self] in
				guard let self = self, let index = self.catches.firstIndex(where: { $0.id == caught.id }) else { return }
				self.container.deleteCatch.handle(DeleteCatchCommand(catchId: caught.id))
				self.catches.remove(at: index)
				self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
				self.updateEmptyState()
			}
			completion(false)
		}
		deleteAction.image = UIImage(systemName: "trash")
		let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
		configuration.performsFirstActionWithFullSwipe = false
		return configuration
	}
}

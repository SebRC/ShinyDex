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
					   formId: caught.formId,
					   title: [caught.nickname, caught.formName, caught.isFailed ? "Got away" : caught.ballName, caught.game.displayName].compactMap { $0 }.joined(separator: " · "),
					   subtitle: ["\(caught.encounters.grouped) encounters", caught.formattedCaughtDate].compactMap { $0 }.joined(separator: " · "),
					   ball: caught.caughtBall,
					   isFailed: caught.isFailed)
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		showDetails(of: catches[indexPath.row])
	}

	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
			guard let self = self else { return completion(false) }
			self.confirmDelete(self.catches[indexPath.row])
			completion(false)
		}
		deleteAction.image = UIImage(systemName: "trash")
		let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
		configuration.performsFirstActionWithFullSwipe = false
		return configuration
	}

	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let caught = catches[indexPath.row]
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
			UIMenu(children: [
				UIAction(title: "View Details", image: UIImage(systemName: "info.circle")) { _ in self?.showDetails(of: caught) },
				UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in self?.confirmDelete(caught) }
			])
		}
	}

	fileprivate func showDetails(of caught: CatchSummary) {
		guard let detail = CatchDetailTVC(container: container, catchId: caught.id) else { return }
		navigationController?.pushViewController(detail, animated: true)
	}

	fileprivate func confirmDelete(_ caught: CatchSummary) {
		presentDeleteCatchConfirmation(for: caught) { [weak self] in
			guard let self = self, let index = self.catches.firstIndex(where: { $0.id == caught.id }) else { return }
			self.container.deleteCatch.handle(DeleteCatchCommand(catchId: caught.id))
			self.catches.remove(at: index)
			self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
			self.updateEmptyState()
		}
	}
}

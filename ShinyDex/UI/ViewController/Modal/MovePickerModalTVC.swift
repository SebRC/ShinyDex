import UIKit

class MovePickerModalTVC: UITableViewController, UISearchResultsUpdating {
	fileprivate let container: AppContainer
	fileprivate let searchController = UISearchController(searchResultsController: nil)
	fileprivate let selectedActiveMoveIndex: Int
	fileprivate var moves: ActiveMoveSet
	fileprivate var activeMoves: [MoveSlot] {
		return moves.slots
	}
	fileprivate let onPick: () -> Void
	fileprivate var allMoves = [MoveOption]()
	fileprivate var filteredMoves = [MoveOption]()

	init(container: AppContainer, moves: ActiveMoveSet, selectedActiveMoveIndex: Int, onPick: @escaping () -> Void) {
		self.container = container
		self.moves = moves
		self.selectedActiveMoveIndex = selectedActiveMoveIndex
		self.onPick = onPick
		super.init(style: .insetGrouped)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Replace \(activeMoves[selectedActiveMoveIndex].name)"
		allMoves = container.getMoveOptions.handle(GetMoveOptionsQuery())
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))

		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search by name or type"
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		definesPresentationContext = true

		tableView.backgroundColor = Color.Grey900
		tableView.separatorColor = Color.Grey700
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 60
		tableView.keyboardDismissMode = .onDrag
		if #available(iOS 15.0, *) {
			tableView.sectionHeaderTopPadding = 0
		}
		tableView.register(MovePickerCell.self, forCellReuseIdentifier: MovePickerCell.reuseIdentifier)
	}

	func updateSearchResults(for searchController: UISearchController) {
		let searchText = searchController.searchBar.text?.lowercased() ?? ""
		let query = searchText.replacingOccurrences(of: " ", with: "-")
		filteredMoves = allMoves.filter {
			$0.identifier.lowercased().contains(query) || $0.type.lowercased() == searchText
		}
		tableView.reloadData()
	}

	fileprivate func isFiltering() -> Bool {
		return !(searchController.searchBar.text?.isEmpty ?? true)
	}

	fileprivate func move(at indexPath: IndexPath) -> MoveOption {
		return isFiltering() ? filteredMoves[indexPath.row] : allMoves[indexPath.row]
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 8
	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return UIView()
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return isFiltering() ? filteredMoves.count : allMoves.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: MovePickerCell.reuseIdentifier, for: indexPath) as! MovePickerCell
		let move = move(at: indexPath)
		cell.configure(name: move.name, maxPP: move.pp, type: move.type, isInUse: activeMoveNames.contains(move.name))
		return cell
	}

	fileprivate lazy var activeMoveNames = Set(activeMoves.map { $0.name })

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedMove = move(at: indexPath)
		moves.slots[selectedActiveMoveIndex] = MoveSlot(name: selectedMove.name, maxPP: selectedMove.pp, remainingPP: selectedMove.pp, type: selectedMove.type)
		moves.pressureActive = container.getActiveMoves.handle(GetActiveMovesQuery()).pressureActive
		container.saveActiveMoves.handle(SaveActiveMovesCommand(moves: moves))
		dismissSheet { [onPick] in
			onPick()
		}
	}

	@objc fileprivate func cancelPressed() {
		dismissSheet()
	}
}

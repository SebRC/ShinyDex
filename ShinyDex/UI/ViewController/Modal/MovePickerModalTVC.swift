import UIKit

class MovePickerModalTVC: UITableViewController, UISearchResultsUpdating {
	fileprivate let moveService = MoveService()
	fileprivate let searchController = UISearchController(searchResultsController: nil)
	fileprivate let selectedActiveMoveIndex: Int
	fileprivate var activeMoves: [ActiveMove]
	fileprivate let onPick: () -> Void
	fileprivate var allMoves = [Move]()
	fileprivate var filteredMoves = [Move]()

	init(activeMoves: [ActiveMove], selectedActiveMoveIndex: Int, onPick: @escaping () -> Void) {
		self.activeMoves = activeMoves
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
		allMoves = moveService.getMoves()
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
		// Move identifiers use dashes ("thunder-punch"), so match what people type with spaces too.
		let query = searchText.replacingOccurrences(of: " ", with: "-")
		filteredMoves = allMoves.filter {
			$0.identifier.lowercased().contains(query) || (MoveTypes.types[$0.type_id]?.lowercased() == searchText)
		}
		tableView.reloadData()
	}

	fileprivate func isFiltering() -> Bool {
		return !(searchController.searchBar.text?.isEmpty ?? true)
	}

	fileprivate func move(at indexPath: IndexPath) -> Move {
		return isFiltering() ? filteredMoves[indexPath.row] : allMoves[indexPath.row]
	}

	/// The list has no section title, so drop the grouped style's empty header gap under the search bar.
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
		let name = cleanName(name: move.identifier)
		cell.configure(name: name, maxPP: move.pp ?? 0, type: MoveTypes.types[move.type_id] ?? "", isInUse: activeMoveNames.contains(name))
		return cell
	}

	fileprivate lazy var activeMoveNames = Set(activeMoves.map { $0.name })

	fileprivate func cleanName(name: String) -> String {
		return name.replacingOccurrences(of: "-", with: " ").capitalizingFirstLetter()
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedMove = move(at: indexPath)
		let newActiveMove = ActiveMove(name: cleanName(name: selectedMove.identifier), maxPP: selectedMove.pp ?? 0, remainingPP: selectedMove.pp ?? 0, type: MoveTypes.types[selectedMove.type_id]!)
		activeMoves[selectedActiveMoveIndex] = newActiveMove
		moveService.save(activeMoves: activeMoves, pressureActive: moveService.getIsPressureActive())
		dismissSheet { [onPick] in
			onPick()
		}
	}

	@objc fileprivate func cancelPressed() {
		dismissSheet()
	}
}

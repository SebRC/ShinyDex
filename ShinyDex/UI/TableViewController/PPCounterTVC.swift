import UIKit

class PPCounterTVC: UITableViewController {
	fileprivate enum Section: Int, CaseIterable {
		case pressure
		case moves
	}

	fileprivate let moveService = MoveService()
	fileprivate let pressureSwitch = UISwitch()
	fileprivate let pressureCell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
	fileprivate var activeMoves = [ActiveMove]()
	fileprivate var restoreAllButton: UIBarButtonItem!

	init() {
		super.init(style: .insetGrouped)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "PP Counter"
		activeMoves = moveService.getAll()
		// Older saves could hold more PP than the move's maximum.
		for move in activeMoves where move.remainingPP > move.maxPP {
			move.remainingPP = move.maxPP
		}
		tableView.backgroundColor = Color.Grey900
		tableView.separatorColor = Color.Grey700
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 100
		tableView.register(MoveCell.self, forCellReuseIdentifier: MoveCell.moveReuseIdentifier)
		restoreAllButton = UIBarButtonItem(title: "Restore All", style: .plain, target: self, action: #selector(restoreAllPressed))
		navigationItem.rightBarButtonItem = restoreAllButton
		setUpPressureCell()
		updateRestoreAllButton()
	}

	/// The Pressure ability makes every move cost 2 PP, so it's a toggle in its own section above the moves.
	fileprivate func setUpPressureCell() {
		pressureCell.backgroundColor = Color.Grey800
		pressureCell.selectionStyle = .none
		pressureCell.textLabel?.text = "Pressure"
		pressureCell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
		pressureCell.textLabel?.textColor = Color.Grey200
		pressureCell.detailTextLabel?.text = "Each use of a move costs 2 PP"
		pressureCell.detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
		pressureCell.detailTextLabel?.textColor = Color.Grey400
		pressureCell.imageView?.image = UIImage.symbol("bolt.fill", pointSize: 20)
		pressureCell.imageView?.tintColor = Color.Orange500
		pressureSwitch.onTintColor = Color.Orange500
		pressureSwitch.isOn = moveService.getIsPressureActive()
		pressureSwitch.addTarget(self, action: #selector(switchPressed), for: .valueChanged)
		pressureCell.accessoryView = pressureSwitch
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Section(rawValue: section) == .pressure ? 1 : activeMoves.count
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return Section(rawValue: section) == .moves ? "Moves" : nil
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return Section(rawValue: section) == .moves ? "Tap a move to replace it." : nil
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if (Section(rawValue: indexPath.section) == .pressure) {
			return pressureCell
		}
		let cell = tableView.dequeueReusableCell(withIdentifier: MoveCell.moveReuseIdentifier, for: indexPath) as! MoveCell
		cell.configure(move: activeMoves[indexPath.row])
		cell.accessibilityHint = "Double tap to replace this move."
		cell.onIncrement = { [weak self, weak cell] in
			guard let self = self, let cell = cell, let indexPath = self.tableView.indexPath(for: cell) else { return }
			self.changePP(at: indexPath.row, by: 1)
		}
		cell.onDecrement = { [weak self, weak cell] in
			guard let self = self, let cell = cell, let indexPath = self.tableView.indexPath(for: cell) else { return }
			self.changePP(at: indexPath.row, by: self.pressureSwitch.isOn ? -2 : -1)
		}
		return cell
	}

	override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		return Section(rawValue: indexPath.section) == .moves ? indexPath : nil
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let picker = MovePickerModalTVC(activeMoves: activeMoves, selectedActiveMoveIndex: indexPath.row) { [weak self] in
			guard let self = self else { return }
			self.activeMoves = self.moveService.getAll()
			self.tableView.reloadSections(IndexSet(integer: Section.moves.rawValue), with: .automatic)
			self.updateRestoreAllButton()
		}
		present(picker.inSheet(), animated: true)
	}

	/// Updates the one cell in place rather than reloading the table, so rapid taps stay smooth.
	fileprivate func changePP(at index: Int, by amount: Int) {
		Haptics.tap()
		let move = activeMoves[index]
		move.remainingPP = min(move.maxPP, max(0, move.remainingPP + amount))
		save()
		let indexPath = IndexPath(row: index, section: Section.moves.rawValue)
		(tableView.cellForRow(at: indexPath) as? MoveCell)?.configure(move: move)
		updateRestoreAllButton()
	}

	fileprivate func updateRestoreAllButton() {
		restoreAllButton.isEnabled = activeMoves.contains { $0.remainingPP < $0.maxPP }
	}

	@objc fileprivate func restoreAllPressed() {
		presentDestructiveConfirmation(title: "Restore all PP?",
									   message: "Every move goes back to full PP.",
									   destructiveTitle: "Restore") { [weak self] in
			guard let self = self else { return }
			for move in self.activeMoves {
				move.remainingPP = move.maxPP
			}
			self.save()
			self.tableView.reloadSections(IndexSet(integer: Section.moves.rawValue), with: .none)
			self.updateRestoreAllButton()
		}
	}

	fileprivate func save() {
		moveService.save(activeMoves: activeMoves, pressureActive: pressureSwitch.isOn)
	}

	@objc fileprivate func switchPressed() {
		save()
	}
}

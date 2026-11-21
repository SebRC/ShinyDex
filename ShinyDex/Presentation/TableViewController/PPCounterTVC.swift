import UIKit

class PPCounterTVC: UITableViewController {
    fileprivate enum Section: Int, CaseIterable {
        case pressure
        case moves
    }

    fileprivate let container: AppContainer
    fileprivate let pressureSwitch = UISwitch()
    fileprivate let pressureCell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
    fileprivate var activeMoves = [MoveSlot]()
    fileprivate var restoreAllButton: UIBarButtonItem!

    init(container: AppContainer) {
        self.container = container
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PP Counter"
        let moveSet = container.getActiveMoves.handle(GetActiveMovesQuery())
        activeMoves = moveSet.slots.map { slot in
            var clamped = slot
            clamped.remainingPP = min(slot.remainingPP, slot.maxPP)
            return clamped
        }
        pressureSwitch.isOn = moveSet.pressureActive
        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(MoveCell.self, forCellReuseIdentifier: MoveCell.moveReuseIdentifier)
        restoreAllButton = UIBarButtonItem(title: "Restore All", style: .plain, target: self, action: #selector(restoreAllPressed))
        let presetsButton = UIBarButtonItem(title: "Presets", style: .plain, target: self, action: #selector(presetsPressed))
        navigationItem.rightBarButtonItems = [restoreAllButton, presetsButton]
        setUpPressureCell()
        updateRestoreAllButton()
    }

    fileprivate func setUpPressureCell() {
        pressureCell.backgroundColor = Color.surface
        pressureCell.selectionStyle = .none
        pressureCell.textLabel?.text = "Pressure"
        pressureCell.textLabel?.font = UIFont.make(.body, weight: .semibold)
        pressureCell.textLabel?.textColor = Color.textPrimary
        pressureCell.detailTextLabel?.text = "Each use of a move costs 2 PP"
        pressureCell.detailTextLabel?.font = UIFont.make(.subheadline)
        pressureCell.detailTextLabel?.textColor = Color.textTertiary
        pressureCell.imageView?.image = UIImage.makeSymbol("bolt.fill", pointSize: 20)
        pressureCell.imageView?.tintColor = Color.accent
        pressureSwitch.onTintColor = Color.accent
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
        let picker = MovePickerModalTVC(container: container, moves: ActiveMoveSet(slots: activeMoves, pressureActive: pressureSwitch.isOn), selectedActiveMoveIndex: indexPath.row) { [weak self] in
            guard let self = self else { return }
            self.activeMoves = self.container.getActiveMoves.handle(GetActiveMovesQuery()).slots
            self.tableView.reloadSections(IndexSet(integer: Section.moves.rawValue), with: .automatic)
            self.updateRestoreAllButton()
        }
        present(picker.wrapInSheet(), animated: true)
    }

    fileprivate func changePP(at index: Int, by amount: Int) {
        Haptics.tap()
        activeMoves[index].remainingPP = min(activeMoves[index].maxPP, max(0, activeMoves[index].remainingPP + amount))
        let move = activeMoves[index]
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
            for index in self.activeMoves.indices {
                self.activeMoves[index].remainingPP = self.activeMoves[index].maxPP
            }
            self.save()
            self.tableView.reloadSections(IndexSet(integer: Section.moves.rawValue), with: .none)
            self.updateRestoreAllButton()
        }
    }

    fileprivate func save() {
        container.saveActiveMoves.handle(SaveActiveMovesCommand(moves: ActiveMoveSet(slots: activeMoves, pressureActive: pressureSwitch.isOn)))
    }

    @objc fileprivate func presetsPressed() {
        let picker = PPPresetPickerTVC(presets: container.getPPPresets.handle(GetPPPresetsQuery()))
        picker.onPick = { [weak self, weak picker] preset in
            guard let picker = picker else { return }
            self?.confirmApplying(preset, from: picker)
        }
        navigationController?.pushViewController(picker, animated: true)
    }

    fileprivate func confirmApplying(_ preset: PPPresetSummary, from picker: UIViewController) {
        let presenter = picker.presentedViewController ?? picker
        presenter.presentDestructiveConfirmation(title: "Track \(preset.pokemonName)'s moves?",
                                                 message: "Your tracked moves and their PP are replaced with the moves of the Lv. \(preset.level) \(preset.pokemonName) in \(preset.onlyIn ?? preset.game).",
                                                 destructiveTitle: "Replace") { [weak self] in
            guard let self = self, self.container.applyPPPreset.handle(ApplyPPPresetCommand(presetId: preset.id)) else { return }
            self.reloadMoves()
            self.navigationController?.popToViewController(self, animated: true)
        }
    }

    fileprivate func reloadMoves() {
        let moveSet = container.getActiveMoves.handle(GetActiveMovesQuery())
        activeMoves = moveSet.slots
        pressureSwitch.isOn = moveSet.pressureActive
        tableView.reloadData()
        updateRestoreAllButton()
    }

    @objc fileprivate func switchPressed() {
        save()
    }
}

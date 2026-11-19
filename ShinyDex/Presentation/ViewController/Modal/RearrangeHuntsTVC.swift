import UIKit

class RearrangeHuntsTVC: UITableViewController {
	fileprivate let container: AppContainer
	fileprivate let onSave: () -> Void
	fileprivate var hunts = [HuntSummary]()
	fileprivate var saveButton: UIBarButtonItem!

	init(container: AppContainer, onSave: @escaping () -> Void) {
		self.container = container
		self.onSave = onSave
		super.init(style: .insetGrouped)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Rearrange hunts"
		hunts = container.getHunts.handle(GetHuntsQuery())
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
		saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savePressed))
		saveButton.isEnabled = false
		navigationItem.rightBarButtonItem = saveButton

		tableView.backgroundColor = Color.Grey900
		tableView.separatorColor = Color.Grey700
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 68
		tableView.register(HuntPickerCell.self, forCellReuseIdentifier: HuntPickerCell.reuseIdentifier)
		tableView.isEditing = true
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return "Drag the handles to change the order hunts appear in."
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return hunts.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: HuntPickerCell.reuseIdentifier, for: indexPath) as! HuntPickerCell
		let hunt = hunts[indexPath.row]
		cell.configure(hunt: hunt)
		return cell
	}

	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		return .none
	}

	override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		return false
	}

	override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let hunt = hunts.remove(at: sourceIndexPath.row)
		hunts.insert(hunt, at: destinationIndexPath.row)
		saveButton.isEnabled = true
		isModalInPresentation = true
	}

	@objc fileprivate func savePressed() {
		container.reorderHunts.handle(ReorderHuntsCommand(orderedIds: hunts.map { $0.id }))
		dismissSheet { [onSave] in
			onSave()
		}
	}

	@objc fileprivate func cancelPressed() {
		dismissSheet()
	}
}

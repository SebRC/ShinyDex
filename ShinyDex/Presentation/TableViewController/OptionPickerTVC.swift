import UIKit

struct PickerOption {
	let title: String
	var subtitle: String? = nil
	var image: UIImage? = nil
}

class OptionPickerTVC: UITableViewController {
	fileprivate static let imageSize = CGSize(width: 68, height: 56)

	fileprivate let options: [PickerOption]
	fileprivate let selectedIndex: Int?
	fileprivate let clearOption: PickerOption
	fileprivate let isClearOptionMuted: Bool
	fileprivate let onPick: (Int?) -> Void

	init(title: String, options: [PickerOption], selectedIndex: Int?, clearTitle: String = "Unknown", onPick: @escaping (Int?) -> Void) {
		self.options = options
		self.selectedIndex = selectedIndex
		clearOption = PickerOption(title: clearTitle)
		isClearOptionMuted = true
		self.onPick = onPick
		super.init(style: .insetGrouped)
		self.title = title
	}

	init(title: String, options: [PickerOption], selectedIndex: Int?, defaultOption: PickerOption, onPick: @escaping (Int?) -> Void) {
		self.options = options
		self.selectedIndex = selectedIndex
		clearOption = defaultOption
		isClearOptionMuted = false
		self.onPick = onPick
		super.init(style: .insetGrouped)
		self.title = title
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.largeTitleDisplayMode = .never
		tableView.backgroundColor = Color.Grey900
		tableView.separatorColor = Color.Grey700
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if let selectedIndex = selectedIndex {
			tableView.scrollToRow(at: IndexPath(row: selectedIndex + 1, section: 0), at: .middle, animated: false)
		}
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return options.count + 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
		let optionIndex = indexPath.row - 1
		let option = optionIndex >= 0 ? options[optionIndex] : clearOption
		cell.textLabel?.text = option.title
		cell.textLabel?.textColor = optionIndex < 0 && isClearOptionMuted ? Color.Grey400 : Color.Grey200
		cell.imageView?.image = option.image?.resized(to: OptionPickerTVC.imageSize)
		cell.imageView?.layer.magnificationFilter = .nearest
		cell.detailTextLabel?.text = option.subtitle
		cell.detailTextLabel?.textColor = Color.Grey400
		cell.backgroundColor = Color.Grey800
		let selectedBackground = UIView()
		selectedBackground.backgroundColor = Color.Grey700
		cell.selectedBackgroundView = selectedBackground
		cell.tintColor = Color.Orange500
		cell.accessoryType = (optionIndex >= 0 ? optionIndex : nil) == selectedIndex ? .checkmark : .none
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		Haptics.tap()
		onPick(indexPath.row > 0 ? indexPath.row - 1 : nil)
		navigationController?.popViewController(animated: true)
	}
}

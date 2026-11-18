import UIKit

struct PickerOption {
	let title: String
	var image: UIImage? = nil
}

class OptionPickerTVC: UITableViewController {
	fileprivate let options: [PickerOption]
	fileprivate let selectedIndex: Int?
	fileprivate let onPick: (Int) -> Void
	fileprivate let cellIdentifier = "optionCell"

	init(title: String, options: [PickerOption], selectedIndex: Int?, onPick: @escaping (Int) -> Void) {
		self.options = options
		self.selectedIndex = selectedIndex
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
		tableView.separatorColor = Color.Grey900
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if let selectedIndex = selectedIndex {
			tableView.scrollToRow(at: IndexPath(row: selectedIndex, section: 0), at: .middle, animated: false)
		}
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return options.count
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 56
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
		let option = options[indexPath.row]
		cell.textLabel?.text = option.title
		cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
		cell.textLabel?.textColor = Color.Grey200
		cell.imageView?.image = option.image.map { scaled($0, to: 40) }
		cell.accessoryType = indexPath.row == selectedIndex ? .checkmark : .none
		cell.tintColor = Color.Orange500
		cell.backgroundColor = Color.Grey800
		return cell
	}

	fileprivate func scaled(_ image: UIImage, to side: CGFloat) -> UIImage {
		let size = CGSize(width: side, height: side)
		return UIGraphicsImageRenderer(size: size).image { _ in
			let aspect = min(side / image.size.width, side / image.size.height)
			let drawSize = CGSize(width: image.size.width * aspect, height: image.size.height * aspect)
			image.draw(in: CGRect(x: (side - drawSize.width) / 2, y: (side - drawSize.height) / 2, width: drawSize.width, height: drawSize.height))
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		onPick(indexPath.row)
		navigationController?.popViewController(animated: true)
	}
}

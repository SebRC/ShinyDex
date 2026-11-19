import UIKit

class HuntPickerModalVC: UITableViewController {
	fileprivate enum Section: Int, CaseIterable {
		case newHunt
		case hunts
	}

	fileprivate let pokemon: Pokemon
	fileprivate let onPick: (String) -> Void
	fileprivate var hunts = [Hunt]()
	fileprivate let huntService = HuntService()
	fileprivate let newHuntCell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

	init(pokemon: Pokemon, onPick: @escaping (_ huntName: String) -> Void) {
		self.pokemon = pokemon
		self.onPick = onPick
		super.init(style: .insetGrouped)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Add to hunt"
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
		hunts = huntService.getAll()

		tableView.backgroundColor = Color.Grey900
		tableView.separatorColor = Color.Grey700
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 68
		tableView.register(HuntPickerCell.self, forCellReuseIdentifier: HuntPickerCell.reuseIdentifier)
		setUpNewHuntCell()
	}

	fileprivate func setUpNewHuntCell() {
		newHuntCell.backgroundColor = Color.Grey800
		let selectedBackground = UIView()
		selectedBackground.backgroundColor = Color.Grey700
		newHuntCell.selectedBackgroundView = selectedBackground
		newHuntCell.imageView?.image = UIImage.symbol("plus.circle.fill", pointSize: 28)
		newHuntCell.imageView?.tintColor = Color.Orange500
		newHuntCell.textLabel?.text = "New hunt"
		newHuntCell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
		newHuntCell.textLabel?.textColor = Color.Orange500
		newHuntCell.detailTextLabel?.text = "Start a new hunt with \(pokemon.name)"
		newHuntCell.detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
		newHuntCell.detailTextLabel?.textColor = Color.Grey400
		newHuntCell.accessibilityTraits = .button
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return hunts.isEmpty ? 1 : Section.allCases.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Section(rawValue: section) == .newHunt ? 1 : hunts.count
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return Section(rawValue: section) == .hunts ? "Your hunts" : nil
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return Section(rawValue: section) == .newHunt && hunts.isEmpty ? "You don't have any hunts yet." : nil
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return Section(rawValue: indexPath.section) == .newHunt ? 64 : UITableView.automaticDimension
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if (Section(rawValue: indexPath.section) == .newHunt) {
			return newHuntCell
		}
		let cell = tableView.dequeueReusableCell(withIdentifier: HuntPickerCell.reuseIdentifier, for: indexPath) as! HuntPickerCell
		cell.configure(hunt: hunts[indexPath.row])
		cell.accessibilityTraits = .button
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if (Section(rawValue: indexPath.section) == .newHunt) {
			presentNewHuntNaming()
			return
		}
		let hunt = hunts[indexPath.row]
		huntService.add(pokemon: pokemon, to: hunt)
		finish(huntName: hunt.name)
	}

	fileprivate func presentNewHuntNaming() {
		presentTextInput(title: "New hunt",
						 message: "\(pokemon.name) will be added to it.",
						 text: "\(pokemon.name) hunt",
						 placeholder: "Hunt name",
						 saveTitle: "Create") { [weak self] name in
			guard let self = self else { return }
			self.huntService.createHunt(named: name, with: self.pokemon)
			self.finish(huntName: name)
		}
	}

	fileprivate func finish(huntName: String) {
		Haptics.success()
		dismissSheet { [onPick] in
			onPick(huntName)
		}
	}

	@objc fileprivate func cancelPressed() {
		dismissSheet()
	}
}

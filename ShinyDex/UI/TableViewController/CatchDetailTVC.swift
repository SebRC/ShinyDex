import UIKit

class CatchDetailTVC: UITableViewController {
	fileprivate enum EditableField {
		case encounters
		case caughtDate
	}

	fileprivate struct Row {
		let title: String
		let value: String
		var image: UIImage? = nil
		var editableField: EditableField? = nil
	}

	fileprivate let caught: Catch
	fileprivate let pokemon: Pokemon
	fileprivate let catchService = CatchService()
	fileprivate let cellIdentifier = "catchDetailCell"
	fileprivate var rows = [Row]()

	init(caught: Catch, pokemon: Pokemon) {
		self.caught = caught
		self.pokemon = pokemon
		super.init(style: .insetGrouped)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = pokemon.name
		navigationItem.largeTitleDisplayMode = .never
		tableView.backgroundColor = Color.Grey900
		tableView.separatorColor = Color.Grey900
		tableView.tableHeaderView = makeHeaderView()
		rows = makeRows()
	}

	fileprivate func makeHeaderView() -> UIView {
		let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 190))

		let sprite = UIImageView(image: UIImage(named: pokemon.name.lowercased()))
		sprite.contentMode = .scaleAspectFit
		sprite.layer.magnificationFilter = .nearest

		let nameLabel = UILabel()
		nameLabel.text = pokemon.name
		nameLabel.font = UIFont.boldSystemFont(ofSize: 26)
		nameLabel.textColor = Color.Grey200
		nameLabel.textAlignment = .center

		let numberLabel = UILabel()
		numberLabel.text = "No. \(pokemon.number + 1)"
		numberLabel.font = UIFont.systemFont(ofSize: 15)
		numberLabel.textColor = Color.Grey400
		numberLabel.textAlignment = .center

		let stack = UIStackView(arrangedSubviews: [sprite, nameLabel, numberLabel])
		stack.axis = .vertical
		stack.spacing = 4
		stack.translatesAutoresizingMaskIntoConstraints = false
		header.addSubview(stack)
		NSLayoutConstraint.activate([
			sprite.heightAnchor.constraint(equalToConstant: 110),
			stack.centerXAnchor.constraint(equalTo: header.centerXAnchor),
			stack.centerYAnchor.constraint(equalTo: header.centerYAnchor),
			stack.leadingAnchor.constraint(greaterThanOrEqualTo: header.leadingAnchor, constant: 16)
		])
		return header
	}

	fileprivate func makeRows() -> [Row] {
		var rows = [
			Row(title: "Ball", value: caught.ballName, image: UIImage(named: caught.caughtBall)),
			Row(title: "Game", value: caught.game.rawValue),
			Row(title: "Method", value: caught.huntMethod.rawValue),
			Row(title: "Encounters", value: "\(caught.encounters)", editableField: .encounters),
			Row(title: "Shiny Charm", value: caught.isShinyCharmActive ? "Yes" : "No"),
			Row(title: "Caught", value: caught.caughtDateText, editableField: .caughtDate)
		]
		let speciesCatches = catchService.getCatches(for: pokemon)
		if speciesCatches.count > 1, let position = speciesCatches.firstIndex(where: { $0.id == caught.id }) {
			rows.append(Row(title: "Catch", value: "\(position + 1) of \(speciesCatches.count)"))
		}
		return rows
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return rows.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
		let row = rows[indexPath.row]
		cell.textLabel?.text = row.title
		cell.textLabel?.textColor = Color.Grey400
		cell.detailTextLabel?.text = row.value
		cell.detailTextLabel?.textColor = Color.Grey200
		cell.accessoryView = row.image.map { makeAccessoryImageView(image: $0) }
		cell.accessoryType = row.editableField == nil ? .none : .disclosureIndicator
		cell.selectionStyle = row.editableField == nil ? .none : .default
		cell.backgroundColor = Color.Grey800
		return cell
	}

	override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return rows[indexPath.row].editableField != nil
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		switch rows[indexPath.row].editableField {
		case .encounters:
			presentEncountersEditor()
		case .caughtDate:
			present(CatchDatePickerVC.inNavigationController(initialDate: caught.caughtDate) { [weak self] date in
				self?.save(encounters: nil, caughtDate: date)
			}, animated: true)
		case nil:
			break
		}
	}

	fileprivate func presentEncountersEditor() {
		let alert = UIAlertController(title: "Encounters", message: "How many encounters did it take?", preferredStyle: .alert)
		alert.addTextField { [caught] textField in
			textField.text = "\(caught.encounters)"
			textField.keyboardType = .numberPad
		}
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
			guard let text = alert?.textFields?.first?.text, let encounters = CatchRules.encounters(from: text) else {
				return
			}
			self?.save(encounters: encounters, caughtDate: nil)
		})
		present(alert, animated: true)
	}

	fileprivate func save(encounters: Int?, caughtDate: Date?) {
		catchService.update(caught: caught,
							pokemon: pokemon,
							encounters: encounters ?? caught.encounters,
							caughtDate: caughtDate ?? caught.caughtDate)
		rows = makeRows()
		tableView.reloadData()
	}

	fileprivate func makeAccessoryImageView(image: UIImage) -> UIImageView {
		let imageView = UIImageView(image: image)
		imageView.contentMode = .scaleAspectFit
		imageView.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
		return imageView
	}
}

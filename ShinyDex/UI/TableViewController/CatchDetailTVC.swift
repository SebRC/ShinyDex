import UIKit

class CatchDetailTVC: UITableViewController {
	fileprivate enum Field {
		case ball
		case game
		case method
		case encounters
		case caughtDate
		case position
	}

	fileprivate struct Row {
		let field: Field
		let title: String
		let value: String
		var image: UIImage? = nil

		var isEditable: Bool {
			return field != .position
		}
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
		reloadRows()
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

	fileprivate func reloadRows() {
		rows = [
			Row(field: .ball, title: "Ball", value: caught.ballName, image: UIImage(named: caught.caughtBall)),
			Row(field: .game, title: "Game", value: caught.game.displayName),
			Row(field: .method, title: "Method", value: caught.huntMethod.rawValue),
			Row(field: .encounters, title: "Encounters", value: "\(caught.encounters)"),
			Row(field: .caughtDate, title: "Caught", value: caught.caughtDateText)
		]
		let speciesCatches = catchService.getCatches(for: pokemon)
		if speciesCatches.count > 1, let position = speciesCatches.firstIndex(where: { $0.id == caught.id }) {
			rows.append(Row(field: .position, title: "Catch", value: "\(position + 1) of \(speciesCatches.count)"))
		}
		tableView.reloadData()
	}

	fileprivate func save(_ changes: (Catch) -> Void) {
		catchService.update(caught: caught, pokemon: pokemon, applying: changes)
		reloadRows()
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
		cell.backgroundColor = Color.Grey800
		cell.selectionStyle = row.isEditable ? .default : .none
		cell.accessoryView = makeAccessory(image: row.image, showsChevron: row.isEditable)
		return cell
	}

	fileprivate func makeAccessory(image: UIImage?, showsChevron: Bool) -> UIView? {
		var views = [UIView]()
		if let image = image {
			let imageView = UIImageView(image: image)
			imageView.contentMode = .scaleAspectFit
			imageView.widthAnchor.constraint(equalToConstant: 28).isActive = true
			imageView.heightAnchor.constraint(equalToConstant: 28).isActive = true
			views.append(imageView)
		}
		if showsChevron {
			let chevron = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)))
			chevron.tintColor = Color.Grey400
			chevron.contentMode = .center
			views.append(chevron)
		}
		guard !views.isEmpty else {
			return nil
		}
		let stack = UIStackView(arrangedSubviews: views)
		stack.spacing = 8
		stack.alignment = .center
		stack.frame.size = stack.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
		return stack
	}

	override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return rows[indexPath.row].isEditable
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		switch rows[indexPath.row].field {
		case .ball:
			showBallPicker()
		case .game:
			showGamePicker()
		case .method:
			showMethodPicker()
		case .encounters:
			showEncountersEditor()
		case .caughtDate:
			present(CatchDatePickerVC.inNavigationController(initialDate: caught.caughtDate) { [weak self] date in
				self?.save { $0.caughtDate = date }
			}, animated: true)
		case .position:
			break
		}
	}

	fileprivate func showBallPicker() {
		let balls = TxtReader().readFile(textFile: "pokeballs").map { Pokeball(ballName: $0) }.filter { $0.name.lowercased() != CatchRules.noBall }
		let options = balls.map { PickerOption(title: "\($0.name) Ball", image: $0.image) }
		let selectedIndex = balls.firstIndex { $0.name.lowercased() == caught.caughtBall }
		showPicker(title: "Ball", options: options, selectedIndex: selectedIndex) { [weak self] index in
			self?.save { $0.caughtBall = balls[index].name.lowercased() }
		}
	}

	fileprivate func showGamePicker() {
		let games = Games.allCases
		let options = games.map { PickerOption(title: $0.displayName, image: GamesList.games[$0].flatMap { UIImage(named: $0.coverPokemon) }) }
		showPicker(title: "Game", options: options, selectedIndex: games.firstIndex(of: caught.game)) { [weak self] index in
			self?.save { $0.game = games[index] }
		}
	}

	fileprivate func showMethodPicker() {
		var methods = GamesList.games[caught.game]?.availableMethods ?? [.Encounters]
		if !methods.contains(caught.huntMethod) {
			methods.append(caught.huntMethod)
		}
		let options = methods.map { PickerOption(title: $0.rawValue, image: UIImage(named: $0.rawValue)) }
		showPicker(title: "Method", options: options, selectedIndex: methods.firstIndex(of: caught.huntMethod)) { [weak self] index in
			self?.save { $0.huntMethod = methods[index] }
		}
	}

	fileprivate func showPicker(title: String, options: [PickerOption], selectedIndex: Int?, onPick: @escaping (Int) -> Void) {
		navigationController?.pushViewController(OptionPickerTVC(title: title, options: options, selectedIndex: selectedIndex, onPick: onPick), animated: true)
	}

	fileprivate func showEncountersEditor() {
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
			self?.save { $0.encounters = encounters }
		})
		present(alert, animated: true)
	}
}

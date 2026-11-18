import UIKit

class CatchDetailTVC: UITableViewController {
	fileprivate struct Row {
		let title: String
		let value: String
		var image: UIImage? = nil
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
		tableView.allowsSelection = false
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
			Row(title: "Encounters", value: "\(caught.encounters)"),
			Row(title: "Shiny Charm", value: caught.isShinyCharmActive ? "Yes" : "No"),
			Row(title: "Caught", value: caught.caughtDateText)
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
		cell.backgroundColor = Color.Grey800
		return cell
	}

	fileprivate func makeAccessoryImageView(image: UIImage) -> UIImageView {
		let imageView = UIImageView(image: image)
		imageView.contentMode = .scaleAspectFit
		imageView.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
		return imageView
	}
}

import UIKit

class CatchesTVC: UITableViewController {
	fileprivate let pokemon: Pokemon
	fileprivate let catchService = CatchService()
	fileprivate var catches = [Catch]()
	fileprivate let cellIdentifier = "catchCell"
	fileprivate let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		return formatter
	}()

	init(pokemon: Pokemon) {
		self.pokemon = pokemon
		super.init(style: .plain)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "\(pokemon.name) catches"
		tableView.backgroundColor = Color.Grey900
		tableView.separatorColor = Color.Grey900
		tableView.tableFooterView = UIView()
		reloadCatches()
	}

	fileprivate func reloadCatches() {
		catches = catchService.getCatches(for: pokemon).reversed()
		tableView.reloadData()
		updateEmptyState()
	}

	fileprivate func updateEmptyState() {
		if (catches.isEmpty) {
			let label = UILabel()
			label.text = "No catches logged yet.\nTap the Poké Ball on the tracker to log one."
			label.numberOfLines = 0
			label.textAlignment = .center
			label.textColor = Color.Grey400
			tableView.backgroundView = label
		}
		else {
			tableView.backgroundView = nil
		}
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return catches.count
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 65.0
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
		let caught = catches[indexPath.row]
		cell.imageView?.image = UIImage(named: caught.caughtBall)
		cell.textLabel?.text = "\(caught.caughtBall.capitalizingFirstLetter()) Ball · \(caught.game.rawValue)"
		cell.textLabel?.textColor = Color.Grey200
		cell.detailTextLabel?.text = detailText(caught: caught)
		cell.detailTextLabel?.textColor = Color.Grey400
		cell.selectionStyle = .none
		return cell
	}

	fileprivate func detailText(caught: Catch) -> String {
		let date = caught.caughtDate.map { dateFormatter.string(from: $0) } ?? "Logged before catch history"
		return "\(caught.encounters) encounters · \(caught.huntMethod.rawValue) · \(date)"
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.backgroundColor = Color.Grey800
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if (editingStyle == .delete) {
			catchService.delete(catchToDelete: catches[indexPath.row], pokemon: pokemon)
			catches.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .automatic)
			updateEmptyState()
		}
	}
}

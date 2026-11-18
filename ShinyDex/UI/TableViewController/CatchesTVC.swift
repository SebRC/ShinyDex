import UIKit

class CatchesTVC: UITableViewController {
	fileprivate let pokemon: Pokemon
	fileprivate let catchService = CatchService()
	fileprivate var catches = [Catch]()

	init(pokemon: Pokemon) {
		self.pokemon = pokemon
		super.init(style: .insetGrouped)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "\(pokemon.name) catches"
		tableView.backgroundColor = Color.Grey900
		tableView.separatorColor = Color.Grey900
		tableView.register(CatchCell.self, forCellReuseIdentifier: CatchCell.reuseIdentifier)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
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
		return CatchCell.height
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: CatchCell.reuseIdentifier, for: indexPath) as! CatchCell
		let caught = catches[indexPath.row]
		cell.configure(pokemon: pokemon,
					   title: "\(caught.ballName) · \(caught.game.rawValue)",
					   subtitle: ["\(caught.encounters) encounters", caught.formattedCaughtDate].compactMap { $0 }.joined(separator: " · "),
					   ball: caught.caughtBall)
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		navigationController?.pushViewController(CatchDetailTVC(caught: catches[indexPath.row], pokemon: pokemon), animated: true)
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

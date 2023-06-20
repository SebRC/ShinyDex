import UIKit

class RearrangeHuntsTVC: UIViewController, UITableViewDelegate, UITableViewDataSource, RearrangeCellDelegate {
	let huntService = HuntService()
	let tableViewHelper = TableViewHelper()
	var hunts = [Hunt]()

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var titleLabel: UILabel!
    
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
        view.backgroundColor = Color.Grey900
		tableView.backgroundColor = .clear
        tableView.separatorColor = Color.Grey900
        cancelButton.setTitleColor(Color.Danger100, for: .normal)
        cancelButton.backgroundColor = Color.Danger500
		cancelButton.layer.cornerRadius = CornerRadius.standard
		confirmButton.isEnabled = false
        confirmButton.setTitleColor(Color.Grey200, for: .normal)
        confirmButton.backgroundColor = Color.Grey800
		confirmButton.layer.cornerRadius = CornerRadius.standard
        titleLabel.textColor = Color.Orange500
		titleLabel.backgroundColor = .clear
		hunts = huntService.getAll()
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 165.0
	}
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return hunts.count
    }

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rearrangeCell", for: indexPath) as! RearrangeCell
		let hunt = hunts[indexPath.section]
		cell.moveUpButton.isEnabled = hunt.priority != 0
		cell.moveDownButton.isEnabled = hunt.priority != hunts.count - 1
		cell.cellDelegate = self
		cell.nameLabel.text = hunt.name
		cell.iconImageView.image = UIImage(named: hunt.pokemon.first!.name.lowercased())

        cell.nameLabel.textColor = Color.Grey200

        cell.backgroundColor = Color.Grey800
		cell.moveUpButton.tintColor = Color.Grey200
        cell.moveUpButton.backgroundColor = .clear
		cell.moveUpButton.layer.cornerRadius = CornerRadius.standard
		cell.moveDownButton.tintColor = Color.Grey200
        cell.moveDownButton.backgroundColor = .clear
		cell.moveDownButton.layer.cornerRadius = CornerRadius.standard
        cell.separator.backgroundColor = Color.Grey900
        cell.separator.layer.cornerRadius = CornerRadius.soft

        return cell
    }

	func moveUp(_ sender: UIButton) {
		confirmButton.isEnabled = true
		if let indexPath = tableViewHelper.getPressedButtonIndexPath(sender, tableView) {
			moveHunt(row: indexPath.section, firstIncrement: -1, secondIncrement: 1)
		}
	}

	func moveDown(_ sender: UIButton) {
		confirmButton.isEnabled = true
		if let indexPath = tableViewHelper.getPressedButtonIndexPath(sender, tableView) {
			moveHunt(row: indexPath.section, firstIncrement: 1, secondIncrement: -1)
		}
	}

	fileprivate func moveHunt(row: Int, firstIncrement: Int, secondIncrement: Int) {
		let pressedIndex = row
		let adjacentIndex = row + firstIncrement
		let movedHunt = hunts[pressedIndex]
		let adjacentHunt = hunts[adjacentIndex]
		adjacentHunt.priority += secondIncrement
		movedHunt.priority += firstIncrement
		reloadData()
	}

	fileprivate func reloadData() {
		hunts = hunts.sorted(by: { $0.priority < $1.priority})
		UIView.transition(with: tableView, duration: 0.2, options: .transitionCrossDissolve, animations: {
			self.tableView.reloadData()
		}, completion: nil)
	}

	@IBAction func confirmPressed(_ sender: Any) {
		for hunt in hunts {
			huntService.save(hunt: hunt)
		}
		performSegue(withIdentifier: "unwindFromRearrange", sender: self)
	}

	@IBAction func cancelPressed(_ sender: Any) {
		dismiss(animated: true)
	}
}

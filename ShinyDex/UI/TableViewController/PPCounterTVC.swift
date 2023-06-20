import UIKit

class PPCounterTVC: UIViewController, UITableViewDataSource, UITableViewDelegate, MoveCellDelegate {
	var moveService = MoveService()
	let tableViewHelper = TableViewHelper()
	var activeMoves = [ActiveMove]()
	var selectedActiveMoveIndex = 0
    
    @IBOutlet weak var pressureSwitch: UISwitch!
	@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var pressureView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		activeMoves = moveService.getAll()
        view.backgroundColor = Color.Grey900
        tableView.separatorColor = Color.Grey900
        tableView.backgroundColor = Color.Grey900
        pressureView.backgroundColor = Color.Grey800
        pressureSwitch.onTintColor = Color.Orange500
        pressureSwitch.thumbTintColor = Color.Grey900
        pressureView.layer.cornerRadius = CornerRadius.standard
        pressureSwitch.isOn = moveService.getIsPressureActive()
        
		title = "PP Counter"
    }

	func numberOfSections(in tableView: UITableView) -> Int	{
		return 4
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 165.0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "moveCell", for: indexPath) as! MoveCell
		cell.cellDelegate = self
        cell.separator.layer.cornerRadius = CornerRadius.soft

        cell.backgroundColor = Color.Grey800
        cell.nameLabel.textColor = Color.Grey200
		cell.ppLabel.textColor = Color.Grey200
		cell.typeLabel.textColor = Color.Grey200
        cell.incrementButton.tintColor = Color.Grey200
        cell.decrementButton.tintColor = Color.Grey200
        cell.separator.backgroundColor = Color.Grey900

		cell.imageBackgroundView.makeCircle()

		let move = activeMoves[indexPath.section]
		cell.imageBackgroundView.backgroundColor = MoveTypes.colors[move.type]
		cell.nameLabel.text = move.name
		cell.ppLabel.text = "PP: \(move.remainingPP)/\(move.maxPP)"
		cell.typeLabel.text = move.type
		cell.typeImageView.image = UIImage(named: move.type.lowercased())
		cell.incrementButton.isEnabled = move.remainingPP != move.maxPP
		cell.decrementButton.isEnabled = move.remainingPP != 0
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedActiveMoveIndex = indexPath.section
		performSegue(withIdentifier: "toMovePicker", sender: self)
	}

	func incrementPressed(_ sender: UIButton) {
		if let indexPath = tableViewHelper.getPressedButtonIndexPath(sender, tableView) {
			activeMoves[indexPath.section].remainingPP += 1
			tableView.reloadData()
            moveService.save(activeMoves: activeMoves, pressureActive: pressureSwitch.isOn)
		}
	}

	func decrementPressed(_ sender: UIButton) {
		if let indexPath = tableViewHelper.getPressedButtonIndexPath(sender, tableView) {
            let activeMove = activeMoves[indexPath.section]
            let decrement = pressureSwitch.isOn ? 2 : 1
            if (pressureSwitch.isOn && activeMove.remainingPP - decrement < 0) {
                activeMove.remainingPP = 0
            }
            else {
                activeMove.remainingPP -= decrement
            }
            
			tableView.reloadData()
            moveService.save(activeMoves: activeMoves, pressureActive: pressureSwitch.isOn)
		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let destVC = segue.destination as! MovePickerModalTVC
		destVC.selectedActiveMoveIndex = selectedActiveMoveIndex
		destVC.activeMoves = activeMoves
	}

	@IBAction func confirmMove(_ unwindSegue: UIStoryboardSegue) {
		activeMoves = moveService.getAll()
		tableView.reloadData()
	}
    @IBAction func switchPressed(_ sender: Any) {
        moveService.save(activeMoves: activeMoves, pressureActive: pressureSwitch.isOn)
    }
}

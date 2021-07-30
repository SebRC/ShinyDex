//
//  PPCounterVC.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 29/07/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import UIKit

class PPCounterTVC: UIViewController, UITableViewDataSource, UITableViewDelegate, MoveCellDelegate {
	@IBOutlet weak var tableView: UITableView!

	var moveService = MoveService()
	let tableViewHelper = TableViewHelper()
	var moves = [Move]()
	var activeMoves = [ActiveMove]()
	var selectedActiveMoveIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		moves = moveService.getMoves()!
		activeMoves = moveService.getAll()
    }

	func numberOfSections(in tableView: UITableView) -> Int	{
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 4
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 260.0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "moveCell", for: indexPath) as! MoveCell
		cell.cellDelegate = self
		let move = activeMoves[indexPath.row]
		cell.nameLabel.text = move.name
		cell.ppLabel.text = "PP: \(move.remainingPP)/\(move.maxPP)"
		cell.typeLabel.text = move.type
		cell.typeImageView.image = UIImage(named: "dive")
		cell.incrementButton.isEnabled = move.remainingPP != move.maxPP
		cell.decrementButton.isEnabled = move.remainingPP != 0
		return cell
	}

	func incrementPressed(_ sender: UIButton) {
		let indexPath = tableViewHelper.getPressedButtonIndexPath(sender, tableView)
		let move = activeMoves[indexPath!.row]
		move.remainingPP += 1
		tableView.reloadData()
	}

	func decrementPressed(_ sender: UIButton) {
		let indexPath = tableViewHelper.getPressedButtonIndexPath(sender, tableView)
		let move = activeMoves[indexPath!.row]
		move.remainingPP -= 1
		tableView.reloadData()
	}

	func editPressed(_ sender: UIButton) {
		selectedActiveMoveIndex = tableViewHelper.getPressedButtonIndexPath(sender, tableView)!.row
		performSegue(withIdentifier: "toMovePicker", sender: self)
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
}

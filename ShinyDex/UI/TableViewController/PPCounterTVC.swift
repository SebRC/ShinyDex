//
//  PPCounterVC.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 29/07/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import UIKit

class PPCounterTVC: UIViewController, UITableViewDataSource, UITableViewDelegate, MoveCellDelegate {
	var moveService = MoveService()
	var fontSettingsService = FontSettingsService()
	var colorService = ColorService()
	let tableViewHelper = TableViewHelper()
	var moves = [Move]()
	var activeMoves = [ActiveMove]()
	var selectedActiveMoveIndex = 0

	@IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		moves = moveService.getMoves()!
		activeMoves = moveService.getAll()
		view.backgroundColor = colorService.getSecondaryColor()
		tableView.separatorColor = colorService.getSecondaryColor()
		tableView.backgroundColor = colorService.getSecondaryColor()
		title = "PP Counter"
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
		cell.nameLabel.font = fontSettingsService.getSmallFont()
		cell.ppLabel.font = fontSettingsService.getSmallFont()
		cell.typeLabel.font = fontSettingsService.getSmallFont()

		cell.backgroundColor = colorService.getPrimaryColor()
		cell.nameLabel.textColor = colorService.getTertiaryColor()
		cell.ppLabel.textColor = colorService.getTertiaryColor()
		cell.typeLabel.textColor = colorService.getTertiaryColor()
		cell.incrementButton.tintColor = colorService.getTertiaryColor()
		cell.decrementButton.tintColor = colorService.getTertiaryColor()

		cell.imageBackgroundView.makeCircle()

		let move = activeMoves[indexPath.row]
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
		selectedActiveMoveIndex = indexPath.row
		performSegue(withIdentifier: "toMovePicker", sender: self)
	}

	func incrementPressed(_ sender: UIButton) {
		if let indexPath = tableViewHelper.getPressedButtonIndexPath(sender, tableView) {
			activeMoves[indexPath.row].remainingPP += 1
			tableView.reloadData()
			moveService.save(activeMoves: activeMoves)
		}
	}

	func decrementPressed(_ sender: UIButton) {
		if let indexPath = tableViewHelper.getPressedButtonIndexPath(sender, tableView) {
			activeMoves[indexPath.row].remainingPP -= 1
			tableView.reloadData()
			moveService.save(activeMoves: activeMoves)
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
}

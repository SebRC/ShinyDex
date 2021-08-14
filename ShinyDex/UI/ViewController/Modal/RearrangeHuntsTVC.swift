//
//  RearrangeHuntsTVC.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 16/11/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import UIKit

class RearrangeHuntsTVC: UIViewController, UITableViewDelegate, UITableViewDataSource, RearrangeCellDelegate {
	let huntService = HuntService()
	let colorService = ColorService()
	let fontSettingsService = FontSettingsService()
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
		view.backgroundColor = colorService.getSecondaryColor()
		tableView.backgroundColor = .clear
		tableView.separatorColor = colorService.getSecondaryColor()
		cancelButton.titleLabel?.font = fontSettingsService.getMediumFont()
		cancelButton.titleLabel?.textColor = colorService.getTertiaryColor()
		cancelButton.backgroundColor = colorService.getPrimaryColor()
		cancelButton.layer.cornerRadius = CornerRadius.Standard
		confirmButton.isEnabled = false
		confirmButton.titleLabel?.font = fontSettingsService.getMediumFont()
		confirmButton.titleLabel?.textColor = colorService.getTertiaryColor()
		confirmButton.backgroundColor = colorService.getPrimaryColor()
		confirmButton.layer.cornerRadius = CornerRadius.Standard
		titleLabel.font = fontSettingsService.getExtraLargeFont()
		titleLabel.textColor = colorService.getTertiaryColor()
		titleLabel.backgroundColor = .clear
		hunts = huntService.getAll()
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 125.0
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return hunts.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rearrangeCell", for: indexPath) as! RearrangeCell
		let hunt = hunts[indexPath.row]
		cell.moveUpButton.isHidden = hunt.priority == 0
		cell.moveDownButton.isHidden = hunt.priority == hunts.count - 1
		cell.cellDelegate = self
		cell.nameLabel.text = hunt.name
		cell.iconImageView.image = UIImage(named: hunt.pokemon.first!.name.lowercased())

		cell.nameLabel.textColor = colorService.getTertiaryColor()
		cell.nameLabel.font = fontSettingsService.getMediumFont()

		cell.backgroundColor = colorService.getPrimaryColor()
		cell.moveUpButton.tintColor = colorService.getTertiaryColor()
		cell.moveUpButton.backgroundColor = colorService.getSecondaryColor()
		cell.moveUpButton.layer.cornerRadius = CornerRadius.Standard
		cell.moveDownButton.tintColor = colorService.getTertiaryColor()
		cell.moveDownButton.backgroundColor = colorService.getSecondaryColor()
		cell.moveDownButton.layer.cornerRadius = CornerRadius.Standard

        return cell
    }

	func moveUp(_ sender: UIButton) {
		confirmButton.isEnabled = true
		if let indexPath = tableViewHelper.getPressedButtonIndexPath(sender, tableView) {
			moveHunt(row: indexPath.row, firstIncrement: -1, secondIncrement: 1)
		}
	}

	func moveDown(_ sender: UIButton) {
		confirmButton.isEnabled = true
		if let indexPath = tableViewHelper.getPressedButtonIndexPath(sender, tableView) {
			moveHunt(row: indexPath.row, firstIncrement: 1, secondIncrement: -1)
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

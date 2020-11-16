//
//  RearrangeHuntsTVC.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 16/11/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import UIKit

class RearrangeHuntsTVC: UIViewController, UITableViewDelegate, UITableViewDataSource, RearrangeCellDelegate
{
	let huntService = HuntService()
	let colorService = ColorService()
	let fontSettingsService = FontSettingsService()
	let tableViewHelper = TableViewHelper()
	var hunts = [Hunt]()

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var confirmButton: UIButton!

    override func viewDidLoad()
	{
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		view.backgroundColor = colorService.getSecondaryColor()
		tableView.backgroundColor = .clear
		cancelButton.titleLabel?.font = fontSettingsService.getMediumFont()
		cancelButton.titleLabel?.textColor = colorService.getTertiaryColor()
		cancelButton.backgroundColor = colorService.getPrimaryColor()
		cancelButton.layer.cornerRadius = CornerRadius.Standard.rawValue
		confirmButton.isEnabled = false
		confirmButton.titleLabel?.font = fontSettingsService.getMediumFont()
		confirmButton.titleLabel?.textColor = colorService.getTertiaryColor()
		confirmButton.backgroundColor = colorService.getPrimaryColor()
		confirmButton.layer.cornerRadius = CornerRadius.Standard.rawValue
		hunts = huntService.getAll()
    }

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		return 200.0
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return hunts.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rearrangeCell", for: indexPath) as! RearrangeCell
		let hunt = hunts[indexPath.row]
		cell.moveUpButton.isEnabled = hunt.priority != 0
		cell.moveDownButton.isEnabled = hunt.priority != hunts.count - 1
		cell.cellDelegate = self
		cell.nameLabel.text = "\(hunt.name): \(hunt.priority)"
		cell.iconImageView.image = UIImage(named: hunt.pokemon.first!.name.lowercased())

		cell.nameLabel.textColor = colorService.getTertiaryColor()
		cell.nameLabel.font = fontSettingsService.getExtraSmallFont()

		cell.moveUpButton.tintColor = colorService.getTertiaryColor()
		cell.moveUpButton.backgroundColor = colorService.getPrimaryColor()
		cell.moveUpButton.layer.cornerRadius = CornerRadius.Standard.rawValue
		cell.moveDownButton.tintColor = colorService.getTertiaryColor()
		cell.moveDownButton.backgroundColor = colorService.getPrimaryColor()
		cell.moveDownButton.layer.cornerRadius = CornerRadius.Standard.rawValue

        return cell
    }

	func moveUp(_ sender: UIButton)
	{
		if let indexPath = tableViewHelper.getPressedButtonIndexPath(sender, tableView)
		{
			let movedHunt = hunts[indexPath.row]
			let huntInFront = hunts[indexPath.row - 1]
			huntInFront.priority = huntInFront.priority + 1
			movedHunt.priority = movedHunt.priority - 1
		}
		reloadData()
	}

	func moveDown(_ sender: UIButton)
	{
		if let indexPath = tableViewHelper.getPressedButtonIndexPath(sender, tableView)
		{
			let movedHunt = hunts[indexPath.row]
			let huntBehind = hunts[indexPath.row + 1]
			huntBehind.priority = huntBehind.priority - 1
			movedHunt.priority = movedHunt.priority + 1
		}
		reloadData()
	}

	private func reloadData()
	{
		hunts = hunts.sorted(by: { $0.priority < $1.priority})
		UIView.transition(with: tableView, duration: 0.2, options: .transitionCrossDissolve, animations: {
			self.tableView.reloadData()

		}, completion: nil)
	}

	@IBAction func confirmPressed(_ sender: Any)
	{
		dismiss(animated: true)
	}

	@IBAction func cancelPressed(_ sender: Any)
	{
		dismiss(animated: true)
	}
}

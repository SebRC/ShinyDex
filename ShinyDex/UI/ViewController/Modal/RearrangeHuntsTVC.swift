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
	let huntSectionsService = HuntSectionsService()
	let tableViewHelper = TableViewHelper()
	var hunts = [Hunt]()
	var huntSections: HuntSections?
	var firstCopy = [Int]()

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
		huntSections = huntSectionsService.get()
		firstCopy = Array(huntSectionsService.get().collapsedSections)
    }

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		return 125.0
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

		cell.backgroundColor = colorService.getPrimaryColor()
		cell.moveUpButton.tintColor = colorService.getTertiaryColor()
		cell.moveUpButton.backgroundColor = colorService.getSecondaryColor()
		cell.moveUpButton.layer.cornerRadius = CornerRadius.Standard.rawValue
		cell.moveDownButton.tintColor = colorService.getTertiaryColor()
		cell.moveDownButton.backgroundColor = colorService.getSecondaryColor()
		cell.moveDownButton.layer.cornerRadius = CornerRadius.Standard.rawValue

        return cell
    }

	func moveUp(_ sender: UIButton)
	{
		confirmButton.isEnabled = true
		if let indexPath = tableViewHelper.getPressedButtonIndexPath(sender, tableView)
		{
			let pressedIndex = indexPath.row
			let indexInFront = indexPath.row - 1
			let movedHunt = hunts[pressedIndex]
			let huntInFront = hunts[indexInFront]
			let containsPressed = firstCopy.contains(pressedIndex)
			let containsInFront = firstCopy.contains(indexInFront)

			if containsPressed && !containsInFront
			{
				let index = firstCopy.firstIndex(of: pressedIndex)
				firstCopy[index!] -= 1
			}
			else if !containsPressed && containsInFront
			{
				let index = firstCopy.firstIndex(of: indexInFront)
				firstCopy[index!] += 1
			}

			huntSections?.collapsedSections = Set(firstCopy)
			huntInFront.priority += 1
			movedHunt.priority -= 1
		}
		reloadData()
	}

	func moveDown(_ sender: UIButton)
	{
		confirmButton.isEnabled = true
		if let indexPath = tableViewHelper.getPressedButtonIndexPath(sender, tableView)
		{
			let pressedIndex = indexPath.row
			let indexBehind = indexPath.row + 1
			let movedHunt = hunts[pressedIndex]
			let huntBehind = hunts[indexBehind]
			let containsPressed = firstCopy.contains(pressedIndex)
			let containsBehind = firstCopy.contains(indexBehind)

			if containsPressed && !containsBehind
			{
				let index = firstCopy.firstIndex(of: pressedIndex)
				firstCopy[index!] += 1
			}
			else if !containsPressed && containsBehind
			{
				let index = firstCopy.firstIndex(of: indexBehind)
				firstCopy[index!] -= 1
			}

			huntSections?.collapsedSections = Set(firstCopy)
			huntBehind.priority -= 1
			movedHunt.priority += 1
		}
		reloadData()
	}

	fileprivate func reloadData()
	{
		hunts = hunts.sorted(by: { $0.priority < $1.priority})
		UIView.transition(with: tableView, duration: 0.2, options: .transitionCrossDissolve, animations: {
			self.tableView.reloadData()

		}, completion: nil)
	}

	@IBAction func confirmPressed(_ sender: Any)
	{
		for hunt in hunts
		{
			huntService.save(hunt: hunt)
		}
		huntSectionsService.save(huntSections!)
		performSegue(withIdentifier: "unwindFromRearrange", sender: self)
	}

	@IBAction func cancelPressed(_ sender: Any)
	{
		dismiss(animated: true)
	}
}

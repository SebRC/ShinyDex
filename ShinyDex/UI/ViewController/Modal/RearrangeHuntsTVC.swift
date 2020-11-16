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
	let tableViewHelper = TableViewHelper()
	var hunts = [Hunt]()

	@IBOutlet weak var tableView: UITableView!

    override func viewDidLoad()
	{
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
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
		hunts = hunts.sorted(by: { $0.priority < $1.priority})
		tableView.reloadData()
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
		hunts = hunts.sorted(by: { $0.priority < $1.priority})
		tableView.reloadData()
	}
}

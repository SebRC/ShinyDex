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

    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		moves = moveService.getMoves()!
		activeMoves = moveService.getAll()

        // Do any additional setup after loading the view.
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
		cell.ppLabel.text = "PP: \(move.maxPP)"
		cell.typeLabel.text = move.type
		cell.typeImageView.image = UIImage(named: "dive")
		return cell
	}

	func incrementPressed(_ sender: UIButton) {

	}

	func decrementPressed(_ sender: UIButton) {

	}

	func editPressed(_ sender: UIButton) {
		performSegue(withIdentifier: "toMovePicker", sender: self)
	}
}

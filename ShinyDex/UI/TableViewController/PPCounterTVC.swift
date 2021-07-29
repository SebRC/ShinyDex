//
//  PPCounterVC.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 29/07/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import UIKit

class PPCounterTVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
	@IBOutlet weak var tableView: UITableView!

	var moveService = MoveService()
	var moves = [Move]()

    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		moves = moveService.getMoves()!

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
		let move = moves[indexPath.row]
		cell.nameLabel.text = move.identifier
		cell.ppLabel.text = "PP: \(move.pp ?? 0)"
		cell.typeLabel.text = "Water"
		cell.typeImageView.image = UIImage(named: "dive")
		return cell
	}
}

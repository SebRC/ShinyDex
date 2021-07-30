//
//  MovePickerModalTVC.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 30/07/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import UIKit

class MovePickerModalTVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

		tableView.delegate = self
		tableView.dataSource = self

    }

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "movePickerCell", for: indexPath) as! MovePickerCell

		return cell
	}
}

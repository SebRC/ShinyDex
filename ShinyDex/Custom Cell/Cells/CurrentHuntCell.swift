//
//  CurrentHuntCell.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 02/07/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

public class CurrentHuntCell: UITableViewCell
{
	
	var cellDelegate: CurrentHuntCellDelegate?
	
	@IBOutlet weak var sprite: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var numberLabel: UILabel!
	@IBOutlet weak var encountersLabel: UILabel!
	@IBOutlet weak var minusButton: UIButton!
	@IBOutlet weak var plusButton: UIButton!
	
	@IBAction func decrementPressed(_ sender: UIButton)
	{
		cellDelegate?.decrementEncounters(sender)
	}
	
	@IBAction func incrementPressed(_ sender: UIButton)
	{
		cellDelegate?.incrementEncounters(sender)
	}
}

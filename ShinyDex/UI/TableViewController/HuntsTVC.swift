import UIKit

class HuntsTVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, CurrentHuntCellDelegate {

	let tableViewHelper = TableViewHelper()
	var pokemonService = PokemonService()
	var huntService = HuntService()
	var totalEncounters = 0
	var selectedIndex = 0
	var selectedSection = 0
	var popupHandler = PopupHandler()
	var hunts = [Hunt]()

	@IBOutlet weak var rearrangeHuntsButton: UIButton!
	@IBOutlet weak var createHuntButton: UIButton!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var clearCurrentHuntButton: UIBarButtonItem!

	override func viewDidLoad() {
        super.viewDidLoad()

		hunts = huntService.getAll()
		tableView.delegate = self
		tableView.dataSource = self
        view.backgroundColor = Color.Grey900
		createHuntButton.layer.cornerRadius = CornerRadius.standard
		rearrangeHuntsButton.layer.cornerRadius = CornerRadius.standard
		rearrangeHuntsButton.isEnabled = hunts.count > 1
		setRearrangeButtonState()
		setClearHuntButtonState()
		setUpBackButton()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		hunts = huntService.getAll()
		setColors()
		setEncounters()
		reloadData()
	}

	fileprivate func setRearrangeButtonState() {
		rearrangeHuntsButton.isEnabled = hunts.count > 1
	}
	
	fileprivate func setClearHuntButtonState() {
		clearCurrentHuntButton.isEnabled = !hunts.isEmpty
	}
	
	fileprivate func setUpBackButton() {
		let backButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)
		navigationItem.backBarButtonItem = backButton
	}
	
	fileprivate func setColors() {
        tableView.backgroundColor = Color.Grey900
        tableView.separatorColor = Color.Grey900
        createHuntButton.backgroundColor = Color.Grey800
        createHuntButton.setTitleColor(Color.Grey200, for: .normal)
        rearrangeHuntsButton.backgroundColor = Color.Grey800
        rearrangeHuntsButton.tintColor = Color.Grey200
	}
	
	fileprivate func setEncounters() {
		totalEncounters = resolveCurrentEncounters()
		navigationItem.title = String(totalEncounters)
	}
	
	fileprivate func resolveCurrentEncounters() -> Int {
		var encounters = 0
		for hunt in hunts {
			hunt.totalEncounters = 0
			for pokemon in hunt.pokemon {
				encounters += pokemon.encounters
				hunt.totalEncounters += pokemon.encounters
			}
		}
		return encounters
	}

	func numberOfSections(in tableView: UITableView) -> Int	{
		return hunts.count
	}

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (hunts[section].isCollapsed) {
			return 0
		}
		return hunts[section].pokemon.count
    }

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 140.0
	}
	
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currentHuntCell", for: indexPath) as! CurrentHuntCell
		
		cell.cellDelegate = self
		
		let pokemon = hunts[indexPath.section].pokemon[indexPath.row]
		
		let minusButtonIsEnabled = pokemon.encounters <= 0
		
		cell.minusButton.isEnabled = !minusButtonIsEnabled
		
		setCellProperties(currentHuntCell: cell, pokemon: pokemon)

        return cell
    }

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = UIView()
        sectionView.clipsToBounds = true
		let collapseButton = UIButton(frame: CGRect(x: 0, y: 0, width: tableView.frame.width / 1.5, height: 60))
		collapseButton.tag = section
		collapseButton.addTarget(self, action: #selector(collapseSection(sender:)), for: .touchUpInside)
        let longGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(editSectionHeader(sender:)))
        longGestureRecognizer.name = String(section)
        collapseButton.addGestureRecognizer(longGestureRecognizer)
		collapseButton.setTitle("\(hunts[section].name): \(hunts[section].totalEncounters)", for: .normal)
        collapseButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        collapseButton.setTitleColor(Color.Grey200, for: .normal)
		collapseButton.setImage(UIImage(systemName: "line.horizontal.3.decrease.circle.fill"), for: .normal)
        collapseButton.imageView?.tintColor = Color.Grey200
		collapseButton.imageEdgeInsets = UIEdgeInsets(top: 25, left: 10, bottom: 0, right: 0)
		collapseButton.contentHorizontalAlignment = .left
		collapseButton.titleEdgeInsets = UIEdgeInsets(top: 25, left: 15, bottom: 0, right: 0)
        let incrementAllButton = UIButton(frame: CGRect(x: collapseButton.frame.width + 20, y: 0, width: 80, height: 60))
        incrementAllButton.addTarget(self, action: #selector(incrementAllInHunt(sender:)), for: .touchUpInside)
        incrementAllButton.tag = section
        incrementAllButton.setImage(UIImage(systemName: "plus.square.fill.on.square.fill"), for: .normal)
        incrementAllButton.imageEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 20)
        incrementAllButton.imageView?.tintColor = Color.Grey200
        incrementAllButton.contentHorizontalAlignment = .right
		sectionView.addSubview(collapseButton)
        sectionView.addSubview(incrementAllButton)
		return sectionView
	}

	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let footerView = UIView()
		footerView.layer.cornerRadius = CornerRadius.standard
		if (hunts[section].isCollapsed) {
            footerView.backgroundColor = Color.Grey800
		}
		else {
			footerView.backgroundColor = .clear
		}
		return footerView
	}

	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 5
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 60.0
	}

	@objc
	private func collapseSection(sender: UIButton) {
		let section = sender.tag

		func indexPathsForSection() -> [IndexPath] {
			var indexPaths = [IndexPath]()

			for row in 0..<hunts[section].pokemon.count {
				indexPaths.append(IndexPath(row: row, section: section))
			}
			return indexPaths
		}
		if (hunts[section].isCollapsed) {
			hunts[section].isCollapsed = false
            tableView.insertRows(at: indexPathsForSection(), with: .automatic)
		}
		else {
			hunts[section].isCollapsed = true
			tableView.deleteRows(at: indexPathsForSection(), with: .automatic)
		}
		huntService.save(hunt: hunts[section])
		reloadData(duration: 0.2)
	}
    
    @objc
    private func editSectionHeader(sender: UILongPressGestureRecognizer) {
        selectedSection = Int(truncating: NumberFormatter().number(from: sender.name!)!)
        performSegue(withIdentifier: "editName", sender: self)
    }
    
    @objc
    private func incrementAllInHunt(sender: UIButton) {
        let section = sender.tag
        let hunt = hunts[section]
        var totalIncremented = 0
        for pokemon in hunt.pokemon {
            pokemon.encounters += pokemon.increment
            totalIncremented += pokemon.increment
            pokemonService.save(pokemon: pokemon)
        }
        totalEncounters += totalIncremented
        navigationItem.title = String(totalEncounters)
        hunt.totalEncounters += totalIncremented
        reloadData(duration: 0.2)
    }
	
	fileprivate func setCellProperties(currentHuntCell: CurrentHuntCell, pokemon: Pokemon) {
		currentHuntCell.sprite.image = UIImage(named: pokemon.name.lowercased())
		
		currentHuntCell.nameLabel.text = pokemon.name
        currentHuntCell.nameLabel.textColor = Color.Grey200
		
		currentHuntCell.encountersLabel.text = String(pokemon.encounters)
        currentHuntCell.encountersLabel.textColor = Color.Grey200
		
        currentHuntCell.plusButton.tintColor = Color.Grey200
        currentHuntCell.minusButton.tintColor = Color.Grey200
	}

	func decrementEncounters(_ sender: UIButton) {
		if let indexPath = tableViewHelper.getPressedButtonIndexPath(sender, tableView) {
			let pokemon = hunts[indexPath.section].pokemon[indexPath.row]

			hunts[indexPath.section].totalEncounters -= 1
			pokemon.encounters -= 1
			totalEncounters -= 1
			navigationItem.title = String(totalEncounters)
			tableView.reloadData()
			pokemonService.save(pokemon: pokemon)
		}
	}
	
	func incrementEncounters(_ sender: UIButton) {
		if let indexPath = tableViewHelper.getPressedButtonIndexPath(sender, tableView) {
			let pokemon = hunts[indexPath.section].pokemon[indexPath.row]
			let increment = pokemon.increment
			hunts[indexPath.section].totalEncounters += increment
			pokemon.encounters += increment
			totalEncounters += increment
			navigationItem.title = String(totalEncounters)
			tableView.reloadData()
			pokemonService.save(pokemon: pokemon)
		}
	}

	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
			let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
				let currentHunt = self.hunts[indexPath.section]
				let pokemonNumber = currentHunt.pokemon[indexPath.row].number
				self.totalEncounters -= currentHunt.pokemon[indexPath.row].encounters
				currentHunt.totalEncounters -= currentHunt.pokemon[indexPath.row].encounters
				currentHunt.pokemon[indexPath.row].isBeingHunted = false
				self.pokemonService.save(pokemon: currentHunt.pokemon[indexPath.row])
				currentHunt.pokemon.remove(at: indexPath.row)
				currentHunt.indexes.removeAll{$0 == pokemonNumber}
				tableView.deleteRows(at: [indexPath], with: .fade)
				self.navigationItem.title = String(self.totalEncounters)

				if (currentHunt.pokemon.isEmpty) {
					self.removeHunt(currentHunt, indexPath.section)
					self.updateHuntPriorities()
				}
				else {
					self.huntService.save(hunt: self.hunts[indexPath.section])
				}

				self.reloadData()
				completionHandler(true)
			}
			deleteAction.image = UIImage(systemName: "trash.circle.fill")
			deleteAction.backgroundColor = .systemRed
			return UISwipeActionsConfiguration(actions: [deleteAction])
	}

	fileprivate func removeHunt(_ hunt: Hunt, _ section: Int) {
		huntService.delete(hunt: hunt)
		hunts.remove(at: section)
	}

	fileprivate func updateHuntPriorities() {
		var counter = 0
		for hunt in hunts.sorted(by: { $0.priority < $1.priority}) {
			hunt.priority = counter
			huntService.save(hunt: hunt)
			counter += 1
		}
		setClearHuntButtonState()
		setRearrangeButtonState()
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedIndex = indexPath.row
		selectedSection = indexPath.section
		performSegue(withIdentifier: "trackShiny", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "editName") {
			let destVC = segue.destination as! HuntNameEditorModalVC
			destVC.hunt = hunts[selectedSection]
		}
		else {
			let destVC = segue.destination as? ShinyTrackerVC
			destVC?.pokemon = hunts[selectedSection].pokemon[selectedIndex]
		}
	}
	
	@IBAction func clearCurrentHuntPressed(_ sender: Any) {
		performSegue(withIdentifier: "confirmClear", sender: self)
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Color.Grey800
	}
	
	@IBAction func confirm(_ unwindSegue: UIStoryboardSegue) {
		clearCurrentHuntButton.isEnabled = false
		for hunt in hunts {
			for pokemon in hunt.pokemon {
				pokemon.isBeingHunted = false
				pokemonService.save(pokemon: pokemon)
			}
		}
		hunts.removeAll()
		reloadData()
		setEncounters()
	}

	@IBAction func createHuntConfirm(_ unwindSegue: UIStoryboardSegue) {
		hunts = huntService.getAll()
		reloadData()
		setEncounters()
		setClearHuntButtonState()
		setRearrangeButtonState()
	}

	@IBAction func confirmHuntName(_ unwindSegue: UIStoryboardSegue) {
		if let source = unwindSegue.source as? HuntNameEditorModalVC {
			hunts[selectedSection] = source.hunt
			tableView.reloadData()
		}
	}

	@IBAction func confirmRearrange(_ unwindSegue: UIStoryboardSegue) {
		hunts = huntService.getAll()
		reloadData()
	}

	@IBAction func createHuntButtonPressed(_ sender: Any) {
		performSegue(withIdentifier: "createHunt", sender: self)
	}

	fileprivate func reloadData(duration: Double = 0.5) {
		UIView.transition(with: tableView, duration: duration, options: .transitionCrossDissolve, animations: {
			self.tableView.reloadData()
		}, completion: nil)
	}
}

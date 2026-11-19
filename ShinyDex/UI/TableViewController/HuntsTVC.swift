import UIKit

class HuntsTVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
	var pokemonService = PokemonService()
	var huntService = HuntService()
	var totalEncounters = 0
	var popupHandler = PopupHandler()
	var hunts = [Hunt]()

	fileprivate let createHuntButton = UIButton(type: .system)
	fileprivate let rearrangeHuntsButton = UIButton.symbolButton("arrow.up.arrow.down", pointSize: 18)
	fileprivate let tableView = UITableView(frame: .zero, style: .insetGrouped)
	fileprivate var clearCurrentHuntButton: UIBarButtonItem!

	override func viewDidLoad() {
        super.viewDidLoad()

		hunts = huntService.getAll()
		layOutViews()
		tableView.register(CurrentHuntCell.self, forCellReuseIdentifier: CurrentHuntCell.reuseIdentifier)
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 80
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(HuntHeaderView.self, forHeaderFooterViewReuseIdentifier: HuntHeaderView.reuseIdentifier)
		tableView.estimatedSectionHeaderHeight = 64
		tableView.sectionHeaderHeight = UITableView.automaticDimension
        view.backgroundColor = Color.Grey900
		navigationItem.title = "Hunts"
		createHuntButton.accessibilityLabel = "Create hunt"
		rearrangeHuntsButton.accessibilityLabel = "Rearrange hunts"
		clearCurrentHuntButton.accessibilityLabel = "Clear all hunts"
		createHuntButton.layer.cornerRadius = CornerRadius.standard
		rearrangeHuntsButton.layer.cornerRadius = CornerRadius.standard
		rearrangeHuntsButton.isEnabled = hunts.count > 1
		setRearrangeButtonState()
		setClearHuntButtonState()
    }

	fileprivate func layOutViews() {
		clearCurrentHuntButton = UIBarButtonItem(image: UIImage(systemName: "xmark.rectangle.fill"), style: .plain, target: self, action: #selector(clearCurrentHuntPressed))
		navigationItem.rightBarButtonItem = clearCurrentHuntButton

		// Icon leads the title at the text's own weight, so the button reads as one label rather than text plus a big glyph.
		createHuntButton.setTitle("Create Hunt", for: .normal)
		createHuntButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
		createHuntButton.setImage(UIImage.symbol("plus", pointSize: 18, weight: .semibold), for: .normal)
		createHuntButton.tintColor = Color.Grey200
		createHuntButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
		createHuntButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
		rearrangeHuntsButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold), forImageIn: .normal)
		createHuntButton.addTarget(self, action: #selector(createHuntButtonPressed), for: .touchUpInside)
		rearrangeHuntsButton.addTarget(self, action: #selector(rearrangePressed), for: .touchUpInside)

		view.addAutoLayoutSubviews(createHuntButton, rearrangeHuntsButton, tableView)
		let safeArea = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			createHuntButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
			createHuntButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
			createHuntButton.heightAnchor.constraint(equalToConstant: 52),
			createHuntButton.trailingAnchor.constraint(equalTo: rearrangeHuntsButton.leadingAnchor, constant: -20),

			rearrangeHuntsButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
			rearrangeHuntsButton.centerYAnchor.constraint(equalTo: createHuntButton.centerYAnchor),
			rearrangeHuntsButton.widthAnchor.constraint(equalToConstant: 52),
			rearrangeHuntsButton.heightAnchor.constraint(equalToConstant: 52),

			tableView.topAnchor.constraint(equalTo: createHuntButton.bottomAnchor, constant: 8),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
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
	
	fileprivate func setColors() {
        tableView.backgroundColor = Color.Grey900
        tableView.separatorColor = Color.Grey700
        createHuntButton.backgroundColor = Color.Grey800
        createHuntButton.setTitleColor(Color.Grey200, for: .normal)
        rearrangeHuntsButton.backgroundColor = Color.Grey800
        rearrangeHuntsButton.tintColor = Color.Grey200
	}
	
	fileprivate func setEncounters() {
		totalEncounters = resolveCurrentEncounters()
		updateSummary()
	}

	fileprivate func updateSummary() {
		guard !hunts.isEmpty else {
			tableView.tableHeaderView = nil
			return
		}
		let label = (tableView.tableHeaderView as? UILabel) ?? UILabel()
		label.font = UIFont.preferredFont(forTextStyle: .subheadline)
		label.adjustsFontForContentSizeCategory = true
		label.textColor = Color.Grey400
		label.text = totalEncounters == 1 ? "1 encounter across all hunts" : "\(totalEncounters.grouped) encounters across all hunts"
		label.accessibilityTraits = .header
		let height = label.font.lineHeight + 8
		label.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: height)
		label.textAlignment = .center
		tableView.tableHeaderView = label
	}

	fileprivate func updateEmptyState() {
		guard hunts.isEmpty else {
			tableView.backgroundView = nil
			return
		}
		tableView.backgroundView = EmptyStateView(symbolName: "sparkles",
												  title: "No hunts yet",
												  message: "Tap Create Hunt, or add a Pokémon from the Pokédex, to start counting encounters.")
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CurrentHuntCell.reuseIdentifier, for: indexPath) as! CurrentHuntCell
		cell.onIncrement = { [weak self, weak cell] in
			guard let self = self, let cell = cell, let indexPath = self.tableView.indexPath(for: cell) else { return }
			self.incrementEncounters(at: indexPath)
		}
		cell.onDecrement = { [weak self, weak cell] in
			guard let self = self, let cell = cell, let indexPath = self.tableView.indexPath(for: cell) else { return }
			self.decrementEncounters(at: indexPath)
		}
		
		cell.configure(pokemon: hunts[indexPath.section].pokemon[indexPath.row])
        return cell
    }

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HuntHeaderView.reuseIdentifier) as! HuntHeaderView
		let hunt = hunts[section]
		header.configure(hunt: hunt)
		header.onToggleCollapse = { [weak self, weak hunt] in
			guard let self = self, let hunt = hunt, let index = self.hunts.firstIndex(where: { $0 === hunt }) else { return }
			self.collapseSection(index)
		}
		header.onIncrementAll = { [weak self, weak hunt] in
			guard let self = self, let hunt = hunt, let index = self.hunts.firstIndex(where: { $0 === hunt }) else { return }
			self.incrementAllInHunt(index)
		}
		header.onRename = { [weak self, weak hunt] in
			guard let self = self, let hunt = hunt else { return }
			self.presentRename(hunt: hunt)
		}
		return header
	}

	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return UIView()
	}

	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 8
	}

	fileprivate func collapseSection(_ section: Int) {

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
    
	fileprivate func presentRename(hunt: Hunt) {
		presentTextInput(title: "Rename hunt", text: hunt.name, placeholder: "Hunt name") { [weak self] name in
			guard let self = self else { return }
			hunt.name = name
			self.huntService.save(hunt: hunt)
			self.tableView.reloadData()
		}
	}

	fileprivate func incrementAllInHunt(_ section: Int) {
		let hunt = hunts[section]
		var totalIncremented = 0
		for pokemon in hunt.pokemon {
			pokemon.encounters += pokemon.increment
			totalIncremented += pokemon.increment
			pokemonService.save(pokemon: pokemon)
		}
		totalEncounters += totalIncremented
		hunt.totalEncounters += totalIncremented
		updateSummary()
		reloadData(duration: 0.2)
	}

	fileprivate func decrementEncounters(at indexPath: IndexPath) {
		let pokemon = hunts[indexPath.section].pokemon[indexPath.row]
		guard pokemon.encounters > 0 else { return }
		Haptics.tap()
		hunts[indexPath.section].totalEncounters -= 1
		pokemon.encounters -= 1
		totalEncounters -= 1
		updateSummary()
		reloadSectionKeepingHeader(indexPath)
		pokemonService.save(pokemon: pokemon)
	}
	
	fileprivate func incrementEncounters(at indexPath: IndexPath) {
		let pokemon = hunts[indexPath.section].pokemon[indexPath.row]
		let increment = pokemon.increment
		Haptics.tap()
		hunts[indexPath.section].totalEncounters += increment
		pokemon.encounters += increment
		totalEncounters += increment
		updateSummary()
		reloadSectionKeepingHeader(indexPath)
		pokemonService.save(pokemon: pokemon)
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
				self.updateSummary()

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
			deleteAction.title = "Remove"
			deleteAction.image = UIImage(systemName: "minus.circle.fill")
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
		tableView.deselectRow(at: indexPath, animated: true)
		navigationController?.pushViewController(ShinyTrackerVC(pokemon: hunts[indexPath.section].pokemon[indexPath.row]), animated: true)
	}
	
	@objc fileprivate func clearCurrentHuntPressed() {
		presentDestructiveConfirmation(title: "Clear all hunts?",
									   message: "Every hunt will be removed. Encounter counts are kept on each Pokémon.",
									   destructiveTitle: "Clear Hunts") { [weak self] in
			self?.huntService.clear()
			self?.clearAllHunts()
		}
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Color.Grey800
	}
	
	fileprivate func clearAllHunts() {
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
		setRearrangeButtonState()
	}

	fileprivate func huntsChanged() {
		hunts = huntService.getAll()
		reloadData()
		setEncounters()
		setClearHuntButtonState()
		setRearrangeButtonState()
	}

	@objc fileprivate func createHuntButtonPressed() {
		let createHunt = CreateHuntModalVC { [weak self] in
			self?.huntsChanged()
		}
		present(createHunt.inSheet(), animated: true)
	}

	@objc fileprivate func rearrangePressed() {
		let rearrange = RearrangeHuntsTVC { [weak self] in
			self?.huntsChanged()
		}
		present(rearrange.inSheet(), animated: true)
	}

	fileprivate func reloadData(duration: Double = 0.5) {
		updateEmptyState()
		UIView.transition(with: tableView, duration: duration, options: .transitionCrossDissolve, animations: {
			self.tableView.reloadData()
		}, completion: nil)
	}

	/// Avoids reloading (and flashing) the whole list.
	fileprivate func reloadSectionKeepingHeader(_ indexPath: IndexPath) {
		UIView.performWithoutAnimation {
			tableView.reloadRows(at: [indexPath], with: .none)
		}
		if let header = tableView.headerView(forSection: indexPath.section) as? HuntHeaderView {
			header.configure(hunt: hunts[indexPath.section])
		}
	}
}

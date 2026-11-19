import UIKit

/// Sheet for naming a new hunt and picking the Pokémon in it. Present it with `inSheet()`.
class CreateHuntModalVC: UITableViewController, UITextFieldDelegate, UISearchResultsUpdating, UIAdaptivePresentationControllerDelegate {
	fileprivate let huntService = HuntService()
	fileprivate let pokemonService = PokemonService()
	fileprivate let onCreate: () -> Void
	fileprivate let searchController = UISearchController(searchResultsController: nil)
	fileprivate let textField = UITextField()
	fileprivate var filteredPokemon = [Pokemon]()
	fileprivate var allPokemon = [Pokemon]()
	/// Picks in the order they were made. Nothing is saved until Create is pressed.
	fileprivate var selected = [Pokemon]()
	fileprivate var createButton: UIBarButtonItem!
	fileprivate let selectedCell = SelectedPokemonCell()

	init(onCreate: @escaping () -> Void) {
		self.onCreate = onCreate
		super.init(style: .insetGrouped)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Create hunt"
		allPokemon = pokemonService.getAll()
		navigationController?.presentationController?.delegate = self

		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
		createButton = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(confirmPressed))
		createButton.isEnabled = false
		navigationItem.rightBarButtonItem = createButton

		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search Pokémon"
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		definesPresentationContext = true

		tableView.backgroundColor = Color.Grey900
		tableView.separatorColor = Color.Grey700
		tableView.keyboardDismissMode = .onDrag
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 64
		tableView.register(CreateHuntCell.self, forCellReuseIdentifier: CreateHuntCell.reuseIdentifier)
		setUpNameCell()
		selectedCell.onRemove = { [weak self] pokemon in
			self?.toggle(pokemon)
		}
		updateSelection()
	}

	fileprivate enum Section: Int, CaseIterable {
		case name
		case selected
		case pokemon
	}

	fileprivate let nameCell = UITableViewCell(style: .default, reuseIdentifier: nil)

	fileprivate func setUpNameCell() {
		nameCell.backgroundColor = Color.Grey800
		nameCell.selectionStyle = .none
		textField.delegate = self
		textField.font = UIFont.systemFont(ofSize: 17)
		textField.textColor = Color.Grey200
		textField.returnKeyType = .done
		textField.autocapitalizationType = .words
		textField.clearButtonMode = .whileEditing
		textField.accessibilityLabel = "Hunt name"
		textField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
		nameCell.contentView.addAutoLayoutSubviews(textField)
		NSLayoutConstraint.activate([
			textField.leadingAnchor.constraint(equalTo: nameCell.contentView.layoutMarginsGuide.leadingAnchor),
			textField.trailingAnchor.constraint(equalTo: nameCell.contentView.layoutMarginsGuide.trailingAnchor),
			textField.topAnchor.constraint(equalTo: nameCell.contentView.topAnchor),
			textField.bottomAnchor.constraint(equalTo: nameCell.contentView.bottomAnchor)
		])
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch Section(rawValue: section)! {
		case .name: return "Name"
		case .selected: return selected.isEmpty ? "In this hunt" : "In this hunt (\(selected.count))"
		case .pokemon: return "Pokémon"
		}
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch Section(rawValue: indexPath.section)! {
		case .name: return 52
		case .selected: return selected.isEmpty ? 52 : 84
		case .pokemon: return UITableView.automaticDimension
		}
	}

	override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		guard Section(rawValue: indexPath.section) == .pokemon else { return nil }
		return isInOtherHunt(getSelectedPokemon(index: indexPath.row)) ? nil : indexPath
	}

	fileprivate func isSelected(_ pokemon: Pokemon) -> Bool {
		return selected.contains { $0 === pokemon }
	}

	fileprivate func isInOtherHunt(_ pokemon: Pokemon) -> Bool {
		return pokemon.isBeingHunted && !isSelected(pokemon)
	}

	func updateSearchResults(for searchController: UISearchController) {
		let searchText = searchController.searchBar.text?.lowercased() ?? ""
		filteredPokemon = allPokemon.filter { $0.name.lowercased().contains(searchText) }
		tableView.reloadSections(IndexSet(integer: Section.pokemon.rawValue), with: .none)
	}

	fileprivate func isFiltering() -> Bool {
		return !(searchController.searchBar.text?.isEmpty ?? true)
	}

	fileprivate func getSelectedPokemon(index: Int) -> Pokemon {
		return isFiltering() ? filteredPokemon[index] : allPokemon[index]
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (Section(rawValue: section) != .pokemon) {
			return 1
		}
		return isFiltering() ? filteredPokemon.count : allPokemon.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section(rawValue: indexPath.section)! {
		case .name:
			return nameCell
		case .selected:
			return selectedCell
		case .pokemon:
			let cell = tableView.dequeueReusableCell(withIdentifier: CreateHuntCell.reuseIdentifier, for: indexPath) as! CreateHuntCell
			let pokemon = getSelectedPokemon(index: indexPath.row)
			cell.configure(pokemon: pokemon, isSelected: isSelected(pokemon), isInOtherHunt: isInOtherHunt(pokemon))
			return cell
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		toggle(getSelectedPokemon(index: indexPath.row))
	}

	/// Tapping a Pokémon adds it to the hunt, tapping it again (or its sprite in the strip) takes it out.
	fileprivate func toggle(_ pokemon: Pokemon) {
		Haptics.tap()
		if let index = selected.firstIndex(where: { $0 === pokemon }) {
			selected.remove(at: index)
		}
		else {
			selected.append(pokemon)
		}
		updateSelection()
		for case let cell as CreateHuntCell in tableView.visibleCells {
			if let indexPath = tableView.indexPath(for: cell), Section(rawValue: indexPath.section) == .pokemon {
				let shown = getSelectedPokemon(index: indexPath.row)
				cell.configure(pokemon: shown, isSelected: isSelected(shown), isInOtherHunt: isInOtherHunt(shown))
			}
		}
		tableView.beginUpdates()
		tableView.endUpdates()
		if let header = tableView.headerView(forSection: Section.selected.rawValue) {
			header.textLabel?.text = tableView(tableView, titleForHeaderInSection: Section.selected.rawValue)?.uppercased()
			header.setNeedsLayout()
		}
	}

	fileprivate func updateSelection() {
		selectedCell.setPokemon(selected)
		createButton.title = selected.isEmpty ? "Create" : "Create (\(selected.count))"
		createButton.isEnabled = !selected.isEmpty
		// Picks are only kept in memory until Create is pressed, so ask before a swipe would throw them away.
		isModalInPresentation = !selected.isEmpty
		updateNamePlaceholder()
	}

	/// The hunt is named after its first Pokémon unless a name is typed, so the placeholder says what it'll be.
	fileprivate func updateNamePlaceholder() {
		let fallback = selected.first?.name ?? "New Hunt"
		textField.attributedPlaceholder = NSAttributedString(string: fallback, attributes: [.foregroundColor: Color.Grey500])
	}

	@objc fileprivate func nameChanged() {
		updateNamePlaceholder()
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return false
	}

	@objc fileprivate func cancelPressed() {
		dismissSheet()
	}

	func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
		let alert = UIAlertController(title: nil, message: "Discard this hunt?", preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Discard Hunt", style: .destructive) { [weak self] _ in self?.cancelPressed() })
		alert.addAction(UIAlertAction(title: "Keep Editing", style: .cancel))
		alert.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
		present(alert, animated: true)
	}

	@objc fileprivate func confirmPressed() {
		let hunt = Hunt(name: getHuntName(), pokemon: [Pokemon](), priority: getPriority())
		for pokemon in selected.sorted(by: { $0.number < $1.number }) {
			pokemon.isBeingHunted = true
			pokemonService.save(pokemon: pokemon)
			hunt.pokemon.append(pokemon)
			hunt.indexes.append(pokemon.number)
			hunt.totalEncounters += pokemon.encounters
		}
		huntService.save(hunt: hunt)
		Haptics.success()
		dismissSheet { [onCreate] in
			onCreate()
		}
	}

	fileprivate func getPriority() -> Int {
		let hunts = huntService.getAll()
		return (hunts.map { $0.priority }.max() ?? -1) + 1
	}

	fileprivate func getHuntName() -> String {
		let name = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
		return name.isEmpty ? selected.first?.name ?? "New Hunt" : name
	}
}

/// The Pokémon picked so far as a row of sprites. Tapping one takes it back out of the hunt.
fileprivate class SelectedPokemonCell: UITableViewCell {
	var onRemove: ((Pokemon) -> Void)?

	fileprivate let scrollView = UIScrollView()
	fileprivate let stack = UIStackView()
	fileprivate let emptyLabel = UILabel(fontSize: 15, color: Color.Grey500)
	fileprivate var pokemon = [Pokemon]()

	init() {
		super.init(style: .default, reuseIdentifier: nil)
		backgroundColor = Color.Grey800
		selectionStyle = .none
		emptyLabel.text = "Tap Pokémon below to add them."
		scrollView.showsHorizontalScrollIndicator = false
		stack.spacing = 8
		stack.alignment = .center
		scrollView.addAutoLayoutSubviews(stack)
		contentView.addAutoLayoutSubviews(scrollView, emptyLabel)
		scrollView.pinEdges(to: contentView)
		NSLayoutConstraint.activate([
			stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
			stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
			stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 12),
			stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -12),
			stack.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
			emptyLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
			emptyLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setPokemon(_ pokemon: [Pokemon]) {
		let added = pokemon.count > self.pokemon.count
		self.pokemon = pokemon
		for view in stack.arrangedSubviews {
			stack.removeArrangedSubview(view)
			view.removeFromSuperview()
		}
		for (index, entry) in pokemon.enumerated() {
			stack.addArrangedSubview(makeChip(for: entry, tag: index))
		}
		emptyLabel.isHidden = !pokemon.isEmpty
		if (added) {
			layoutIfNeeded()
			let maxOffset = max(0, scrollView.contentSize.width - scrollView.bounds.width)
			scrollView.setContentOffset(CGPoint(x: maxOffset, y: 0), animated: true)
		}
	}

	fileprivate func makeChip(for pokemon: Pokemon, tag: Int) -> UIView {
		let chip = UIButton(type: .custom)
		chip.tag = tag
		chip.backgroundColor = Color.Grey900
		chip.layer.cornerRadius = 12
		chip.setImage(UIImage(named: pokemon.name.lowercased()), for: .normal)
		chip.imageView?.contentMode = .scaleAspectFit
		chip.imageView?.layer.magnificationFilter = .nearest
		chip.contentHorizontalAlignment = .fill
		chip.contentVerticalAlignment = .fill
		chip.accessibilityLabel = "Remove \(pokemon.name)"
		chip.addTarget(self, action: #selector(chipPressed(_:)), for: .touchUpInside)

		let badge = UIImageView(image: UIImage.symbol("xmark.circle.fill", pointSize: 16, weight: .semibold))
		badge.tintColor = Color.Grey400
		badge.isUserInteractionEnabled = false
		chip.addAutoLayoutSubviews(badge)
		NSLayoutConstraint.activate([
			chip.widthAnchor.constraint(equalToConstant: 64),
			chip.heightAnchor.constraint(equalToConstant: 64),
			badge.topAnchor.constraint(equalTo: chip.topAnchor, constant: 2),
			badge.trailingAnchor.constraint(equalTo: chip.trailingAnchor, constant: -2)
		])
		return chip
	}

	@objc fileprivate func chipPressed(_ sender: UIButton) {
		guard sender.tag < pokemon.count else { return }
		onRemove?(pokemon[sender.tag])
	}
}

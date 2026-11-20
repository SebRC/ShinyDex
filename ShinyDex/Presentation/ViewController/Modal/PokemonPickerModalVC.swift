import UIKit

struct PokemonPickerConfiguration {
    let title: String
    let selectionTitle: String
    let confirmTitle: String
    let discardTitle: String
    let nameLabel: String?
    let defaultName: String
    let namesAfterFirstPick: Bool
    let excludesHuntedPokemon: Bool

    static let hunt = PokemonPickerConfiguration(title: "Create hunt", selectionTitle: "In this hunt", confirmTitle: "Create", discardTitle: "Discard Hunt",
                                                 nameLabel: "Hunt name", defaultName: "New Hunt", namesAfterFirstPick: true, excludesHuntedPokemon: true)
    static let newJourney = PokemonPickerConfiguration(title: "New journey", selectionTitle: "In this journey", confirmTitle: "Create", discardTitle: "Discard Journey",
                                                       nameLabel: "Journey name", defaultName: "New Journey", namesAfterFirstPick: false, excludesHuntedPokemon: false)
    static let addToJourney = PokemonPickerConfiguration(title: "Add Pokémon", selectionTitle: "Adding", confirmTitle: "Add", discardTitle: "Discard Picks",
                                                         nameLabel: nil, defaultName: "", namesAfterFirstPick: false, excludesHuntedPokemon: false)
}

class PokemonPickerModalVC: UITableViewController, UITextFieldDelegate, UISearchResultsUpdating, UIAdaptivePresentationControllerDelegate {
    fileprivate let container: AppContainer
    fileprivate let configuration: PokemonPickerConfiguration
    fileprivate let onConfirm: (_ name: String, _ picked: [PokemonSummary]) -> Void
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate let textField = UITextField()
    fileprivate var filteredPokemon = [PokemonSummary]()
    fileprivate var allPokemon = [PokemonSummary]()
    fileprivate var selected = [PokemonSummary]()
    fileprivate var createButton: UIBarButtonItem!
    fileprivate let selectedCell = SelectedPokemonCell()

    init(container: AppContainer, configuration: PokemonPickerConfiguration, onConfirm: @escaping (_ name: String, _ picked: [PokemonSummary]) -> Void) {
        self.container = container
        self.configuration = configuration
        self.onConfirm = onConfirm
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = configuration.title
        allPokemon = container.getAllPokemon.handle(GetAllPokemonQuery())
        navigationController?.presentationController?.delegate = self

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
        createButton = UIBarButtonItem(title: configuration.confirmTitle, style: .done, target: self, action: #selector(confirmPressed))
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
        tableView.register(PokemonPickerCell.self, forCellReuseIdentifier: PokemonPickerCell.reuseIdentifier)
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
        textField.accessibilityLabel = configuration.nameLabel
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

    fileprivate var showsName: Bool {
        return configuration.nameLabel != nil
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .name: return showsName ? "Name" : nil
        case .selected: return selected.isEmpty ? configuration.selectionTitle : "\(configuration.selectionTitle) (\(selected.count))"
        case .pokemon: return "Pokémon"
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch Section(rawValue: indexPath.section)! {
        case .name: return showsName ? 52 : 0
        case .selected: return selected.isEmpty ? 52 : 84
        case .pokemon: return UITableView.automaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard Section(rawValue: indexPath.section) == .pokemon else { return nil }
        return isInOtherHunt(getSelectedPokemon(index: indexPath.row)) ? nil : indexPath
    }

    fileprivate func isSelected(_ pokemon: PokemonSummary) -> Bool {
        return selected.contains { $0.number == pokemon.number }
    }

    fileprivate func isInOtherHunt(_ pokemon: PokemonSummary) -> Bool {
        return configuration.excludesHuntedPokemon && pokemon.isBeingHunted && !isSelected(pokemon)
    }

    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text?.lowercased() ?? ""
        filteredPokemon = allPokemon.filter { $0.name.lowercased().contains(searchText) }
        tableView.reloadSections(IndexSet(integer: Section.pokemon.rawValue), with: .none)
    }

    fileprivate func isFiltering() -> Bool {
        return !(searchController.searchBar.text?.isEmpty ?? true)
    }

    fileprivate func getSelectedPokemon(index: Int) -> PokemonSummary {
        return isFiltering() ? filteredPokemon[index] : allPokemon[index]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .name: return showsName ? 1 : 0
        case .selected: return 1
        case .pokemon: break
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
            let cell = tableView.dequeueReusableCell(withIdentifier: PokemonPickerCell.reuseIdentifier, for: indexPath) as! PokemonPickerCell
            let pokemon = getSelectedPokemon(index: indexPath.row)
            cell.configure(pokemon: pokemon, isSelected: isSelected(pokemon), isInOtherHunt: isInOtherHunt(pokemon))
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        toggle(getSelectedPokemon(index: indexPath.row))
    }

    fileprivate func toggle(_ pokemon: PokemonSummary) {
        Haptics.tap()
        if let index = selected.firstIndex(where: { $0.number == pokemon.number }) {
            selected.remove(at: index)
        }
        else {
            selected.append(pokemon)
        }
        updateSelection()
        for case let cell as PokemonPickerCell in tableView.visibleCells {
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
        createButton.title = selected.isEmpty ? configuration.confirmTitle : "\(configuration.confirmTitle) (\(selected.count))"
        createButton.isEnabled = !selected.isEmpty
        isModalInPresentation = !selected.isEmpty
        updateNamePlaceholder()
    }

    fileprivate func updateNamePlaceholder() {
        let fallback = defaultName
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
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: configuration.discardTitle, style: .destructive) { [weak self] _ in self?.cancelPressed() })
        alert.addAction(UIAlertAction(title: "Keep Editing", style: .cancel))
        alert.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        present(alert, animated: true)
    }

    @objc fileprivate func confirmPressed() {
        let name = enteredName
        let picked = selected
        Haptics.playSuccess()
        dismissSheet { [onConfirm] in
            onConfirm(name, picked)
        }
    }

    fileprivate var defaultName: String {
        return configuration.namesAfterFirstPick ? selected.first?.name ?? configuration.defaultName : configuration.defaultName
    }

    fileprivate var enteredName: String {
        let name = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return name.isEmpty ? defaultName : name
    }
}

fileprivate class SelectedPokemonCell: UITableViewCell {
    var onRemove: ((PokemonSummary) -> Void)?

    fileprivate let scrollView = UIScrollView()
    fileprivate let stack = UIStackView()
    fileprivate let emptyLabel = UILabel(fontSize: 15, color: Color.Grey500)
    fileprivate var pokemon = [PokemonSummary]()

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

    func setPokemon(_ pokemon: [PokemonSummary]) {
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

    fileprivate func makeChip(for pokemon: PokemonSummary, tag: Int) -> UIView {
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

        let badge = UIImageView(image: UIImage.makeSymbol("xmark.circle.fill", pointSize: 16, weight: .semibold))
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

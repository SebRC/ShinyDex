import UIKit

class CatchMovesTVC: UITableViewController, UISearchResultsUpdating, UIAdaptivePresentationControllerDelegate {
    fileprivate let learnableMoves: LearnableMoves
    fileprivate let onSave: ([Int]) -> Void
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate let selectedCell = SelectedMovesCell()
    fileprivate var sections = [LearnableMoves.Section]()
    fileprivate var selected: [MoveChoice]
    fileprivate var saveButton: UIBarButtonItem!
    fileprivate var hasAppeared = false

    fileprivate var hasChanges: Bool {
        return selected.map { $0.id } != learnableMoves.knownMoves.map { $0.id }
    }

    init(learnableMoves: LearnableMoves, onSave: @escaping ([Int]) -> Void) {
        self.learnableMoves = learnableMoves
        self.onSave = onSave
        selected = learnableMoves.knownMoves
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Moves"
        navigationController?.presentationController?.delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
        saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(savePressed))
        navigationItem.rightBarButtonItem = saveButton

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search by name or type"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.keyboardDismissMode = .onDrag
        tableView.register(MovePickerCell.self, forCellReuseIdentifier: MovePickerCell.reuseIdentifier)
        selectedCell.onRemove = { [weak self] move in
            self?.toggle(move)
        }
        sections = learnableMoves.sections
        updateSelection()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasAppeared, !learnableMoves.sections.isEmpty else { return }
        hasAppeared = true
        searchController.isActive = true
        DispatchQueue.main.async { [weak self] in
            self?.searchController.searchBar.becomeFirstResponder()
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces).lowercased() ?? ""
        sections = query.isEmpty ? learnableMoves.sections : learnableMoves.sections.compactMap { section in
            let moves = section.moves.filter { $0.name.lowercased().contains(query) || $0.type.lowercased() == query }
            return moves.isEmpty ? nil : LearnableMoves.Section(method: section.method, moves: moves)
        }
        tableView.reloadData()
    }

    fileprivate func isSelected(_ move: MoveChoice) -> Bool {
        return selected.contains { $0.id == move.id }
    }

    fileprivate func toggle(_ move: MoveChoice) {
        if let index = selected.firstIndex(where: { $0.id == move.id }) {
            selected.remove(at: index)
        }
        else if selected.count >= Catch.maximumMoveCount {
            Haptics.playWarning()
            return
        }
        else {
            selected.append(move)
        }
        Haptics.tap()
        updateSelection()
        for case let cell as MovePickerCell in tableView.visibleCells {
            if let indexPath = tableView.indexPath(for: cell) {
                configure(cell, at: indexPath)
            }
        }
        if let header = tableView.headerView(forSection: 0) as? SectionHeaderView {
            header.configure(title: makeSelectionTitle())
        }
    }

    fileprivate func updateSelection() {
        selectedCell.setMoves(selected)
        saveButton.isEnabled = hasChanges
        isModalInPresentation = hasChanges
    }

    fileprivate func makeSelectionTitle() -> String {
        return "Moves (\(selected.count)/\(Catch.maximumMoveCount))"
    }

    fileprivate func makeOrigin(of move: MoveChoice) -> String? {
        switch (move.learnedAs, move.learnedIn) {
        case let (pokemon?, game?): return "Learned as \(pokemon) in \(game.displayName)"
        case let (pokemon?, nil): return "Learned as \(pokemon)"
        case let (nil, game?): return "Learned in \(game.displayName)"
        case (nil, nil): return nil
        }
    }

    fileprivate static func makeTitle(for method: LearnableMoves.Method) -> String {
        switch method {
        case .levelUp: return "Level up"
        case .machine: return "TM and TR"
        case .egg: return "Egg moves"
        case .tutor: return "Tutor"
        }
    }

    // MARK: Table

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : sections[section - 1].moves.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = section == 0 ? makeSelectionTitle() : CatchMovesTVC.makeTitle(for: sections[section - 1].method)
        return SectionHeaderView.make(for: tableView, title: title)
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard section == 0 else { return nil }
        let game = learnableMoves.game.displayName
        if learnableMoves.sections.isEmpty {
            return "There's no move data for \(learnableMoves.pokemonName) in \(game), so no moves can be picked."
        }
        let generation = learnableMoves.generation.map { "Gen \($0) " } ?? ""
        return "Moves \(learnableMoves.pokemonName) can't learn in \(game) itself, but can in other \(generation)games or as an earlier evolution, are marked."
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? SelectedMovesCell.height : UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section > 0 else { return selectedCell }
        let cell = tableView.dequeueReusableCell(withIdentifier: MovePickerCell.reuseIdentifier, for: indexPath) as! MovePickerCell
        configure(cell, at: indexPath)
        return cell
    }

    fileprivate func configure(_ cell: MovePickerCell, at indexPath: IndexPath) {
        guard indexPath.section > 0 else { return }
        let move = sections[indexPath.section - 1].moves[indexPath.row]
        cell.configure(name: move.name, maxPP: move.pp, type: move.type, isInUse: false, origin: makeOrigin(of: move))
        cell.accessoryType = isSelected(move) ? .checkmark : .none
        cell.accessibilityTraits = isSelected(move) ? [.button, .selected] : .button
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath.section == 0 ? nil : indexPath
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        toggle(sections[indexPath.section - 1].moves[indexPath.row])
    }

    // MARK: Actions

    @objc fileprivate func cancelPressed() {
        dismissSheet()
    }

    @objc fileprivate func savePressed() {
        let moveIds = selected.map { $0.id }
        Haptics.playSuccess()
        dismissSheet { [onSave] in
            onSave(moveIds)
        }
    }

    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Discard Changes", style: .destructive) { [weak self] _ in self?.cancelPressed() })
        alert.addAction(UIAlertAction(title: "Keep Editing", style: .cancel))
        alert.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        present(alert, animated: true)
    }
}

fileprivate class SelectedMovesCell: UITableViewCell {
    static let height: CGFloat = 56

    var onRemove: ((MoveChoice) -> Void)?

    fileprivate let scrollView = UIScrollView()
    fileprivate let stack = UIStackView()
    fileprivate let emptyLabel = UILabel(style: .subheadline, color: Color.textQuaternary)
    fileprivate var moves = [MoveChoice]()

    init() {
        super.init(style: .default, reuseIdentifier: nil)
        backgroundColor = Color.surface
        selectionStyle = .none
        emptyLabel.text = "Tap moves below to add up to \(Catch.maximumMoveCount)."
        scrollView.showsHorizontalScrollIndicator = false
        stack.spacing = Spacing.small
        stack.alignment = .center
        scrollView.addAutoLayoutSubviews(stack)
        contentView.addAutoLayoutSubviews(scrollView, emptyLabel)
        scrollView.pinEdges(to: contentView)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: Spacing.medium),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -Spacing.medium),
            stack.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            emptyLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setMoves(_ moves: [MoveChoice]) {
        let added = moves.count > self.moves.count
        self.moves = moves
        for view in stack.arrangedSubviews {
            stack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        for (index, move) in moves.enumerated() {
            stack.addArrangedSubview(makeChip(for: move, tag: index))
        }
        emptyLabel.isHidden = !moves.isEmpty
        if added {
            layoutIfNeeded()
            let maxOffset = max(0, scrollView.contentSize.width - scrollView.bounds.width)
            scrollView.setContentOffset(CGPoint(x: maxOffset, y: 0), animated: true)
        }
    }

    fileprivate func makeChip(for move: MoveChoice, tag: Int) -> UIView {
        let chip = MoveChip(move: move)
        chip.tag = tag
        chip.addTarget(self, action: #selector(chipPressed(_:)), for: .touchUpInside)
        return chip
    }

    @objc fileprivate func chipPressed(_ sender: UIControl) {
        guard sender.tag < moves.count else { return }
        onRemove?(moves[sender.tag])
    }
}

fileprivate class MoveChip: UIControl {
    fileprivate static let typeIconSize: CGFloat = 18

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.6 : 1
        }
    }

    init(move: MoveChoice) {
        super.init(frame: .zero)
        backgroundColor = MoveTypes.colors[move.type] ?? Color.inactive
        let typeIcon = UIImageView(image: UIImage(named: move.type.lowercased()))
        typeIcon.contentMode = .scaleAspectFit
        let nameLabel = UILabel(style: .subheadline, weight: .semibold, color: Color.textPrimary)
        nameLabel.text = move.name
        let removeIcon = UIImageView(image: UIImage.makeSymbol("xmark", pointSize: 11, weight: .bold))
        removeIcon.tintColor = Color.textPrimary
        let row = UIStackView(arrangedSubviews: [typeIcon, nameLabel, removeIcon])
        row.spacing = Spacing.small
        row.alignment = .center
        row.isUserInteractionEnabled = false
        addAutoLayoutSubviews(row)
        NSLayoutConstraint.activate([
            typeIcon.widthAnchor.constraint(equalToConstant: MoveChip.typeIconSize),
            typeIcon.heightAnchor.constraint(equalToConstant: MoveChip.typeIconSize),
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Spacing.small),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Spacing.medium),
            row.topAnchor.constraint(equalTo: topAnchor, constant: Spacing.small),
            row.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Spacing.small)
        ])
        isAccessibilityElement = true
        accessibilityLabel = "Remove \(move.name)"
        accessibilityTraits = .button
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}

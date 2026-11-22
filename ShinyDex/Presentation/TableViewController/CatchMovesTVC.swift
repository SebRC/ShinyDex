import UIKit

class CatchMovesTVC: UITableViewController {
    fileprivate let container: AppContainer
    fileprivate let catchId: CatchID
    fileprivate var learnableMoves: LearnableMoves?

    init(container: AppContainer, catchId: CatchID) {
        self.container = container
        self.catchId = catchId
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Moves"
        navigationItem.largeTitleDisplayMode = .never
        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.register(MovePickerCell.self, forCellReuseIdentifier: MovePickerCell.reuseIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        learnableMoves = container.getLearnableMoves.handle(GetLearnableMovesQuery(catchId: catchId))
        tableView.reloadData()
    }

    fileprivate var knownMoves: [MoveChoice] {
        return learnableMoves?.knownMoves ?? []
    }

    fileprivate func save(_ moves: [MoveChoice]) {
        try? container.updateCatch.handle(UpdateCatchCommand(catchId: catchId, change: .moves(moves.map { $0.id })))
        learnableMoves = container.getLearnableMoves.handle(GetLearnableMovesQuery(catchId: catchId))
        tableView.reloadData()
    }

    // MARK: Table

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Catch.maximumMoveCount
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let learnableMoves = learnableMoves else { return nil }
        let game = learnableMoves.game.displayName
        if learnableMoves.sections.isEmpty {
            return "There's no move data for \(learnableMoves.pokemonName) in \(game), so no moves can be picked."
        }
        return "Only moves \(learnableMoves.pokemonName) can learn in \(game) are listed. Swipe a move to remove it."
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard knownMoves.indices.contains(indexPath.row) else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.backgroundColor = Color.surface
            let selectedBackground = UIView()
            selectedBackground.backgroundColor = Color.surfaceRaised
            cell.selectedBackgroundView = selectedBackground
            cell.textLabel?.text = "Add a move"
            cell.textLabel?.font = UIFont.make(.body)
            cell.textLabel?.textColor = Color.accent
            cell.imageView?.image = UIImage.makeSymbol("plus.circle", pointSize: 20, weight: .medium)
            cell.imageView?.tintColor = Color.accent
            cell.accessibilityTraits = .button
            cell.isUserInteractionEnabled = indexPath.row == knownMoves.count && !(learnableMoves?.sections.isEmpty ?? true)
            cell.contentView.alpha = cell.isUserInteractionEnabled ? 1 : 0.4
            return cell
        }
        let move = knownMoves[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: MovePickerCell.reuseIdentifier, for: indexPath) as! MovePickerCell
        cell.configure(name: move.name, maxPP: move.pp, type: move.type, isInUse: false)
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard knownMoves.indices.contains(indexPath.row) else { return nil }
        let remove = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, completion in
            guard let self = self else { return completion(false) }
            var moves = self.knownMoves
            moves.remove(at: indexPath.row)
            self.save(moves)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [remove])
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let learnableMoves = learnableMoves, indexPath.row <= knownMoves.count else { return }
        let slot = indexPath.row
        let picker = LearnableMovePickerTVC(learnableMoves: learnableMoves, replacing: knownMoves.indices.contains(slot) ? knownMoves[slot] : nil) { [weak self] move in
            guard let self = self else { return }
            var moves = self.knownMoves
            if moves.indices.contains(slot) {
                moves[slot] = move
            }
            else {
                moves.append(move)
            }
            self.save(moves)
        }
        navigationController?.pushViewController(picker, animated: true)
    }
}

class LearnableMovePickerTVC: UITableViewController, UISearchResultsUpdating {
    fileprivate let learnableMoves: LearnableMoves
    fileprivate let replacedMove: MoveChoice?
    fileprivate let onPick: (MoveChoice) -> Void
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate var sections = [LearnableMoves.Section]()

    init(learnableMoves: LearnableMoves, replacing replacedMove: MoveChoice?, onPick: @escaping (MoveChoice) -> Void) {
        self.learnableMoves = learnableMoves
        self.replacedMove = replacedMove
        self.onPick = onPick
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = replacedMove.map { "Replace \($0.name)" } ?? "Add a move"
        navigationItem.largeTitleDisplayMode = .never
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
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
        sections = learnableMoves.sections
    }

    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces).lowercased() ?? ""
        sections = query.isEmpty ? learnableMoves.sections : learnableMoves.sections.compactMap { section in
            let moves = section.moves.filter { $0.name.lowercased().contains(query) || $0.type.lowercased() == query }
            return moves.isEmpty ? nil : LearnableMoves.Section(method: section.method, moves: moves)
        }
        tableView.reloadData()
    }

    fileprivate func isKnown(_ move: MoveChoice) -> Bool {
        return move.id != replacedMove?.id && learnableMoves.knownMoves.contains { $0.id == move.id }
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
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].moves.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return SectionHeaderView.make(for: tableView, title: LearnableMovePickerTVC.makeTitle(for: sections[section].method))
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let move = sections[indexPath.section].moves[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: MovePickerCell.reuseIdentifier, for: indexPath) as! MovePickerCell
        let isKnown = isKnown(move)
        cell.configure(name: move.name, maxPP: move.pp, type: move.type, isInUse: isKnown)
        cell.selectionStyle = isKnown ? .none : .default
        cell.contentView.alpha = isKnown ? 0.5 : 1
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let move = sections[indexPath.section].moves[indexPath.row]
        guard !isKnown(move) else { return }
        Haptics.tap()
        onPick(move)
        navigationController?.popViewController(animated: true)
    }
}

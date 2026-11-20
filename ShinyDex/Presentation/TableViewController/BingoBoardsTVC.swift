import UIKit

class BingoBoardsTVC: UITableViewController {
    fileprivate let container: AppContainer
    fileprivate var boards = [BingoBoardSummary]()

    init(container: AppContainer) {
        self.container = container
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Shiny Bingo"
        navigationItem.largeTitleDisplayMode = .always
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPressed))
        addButton.accessibilityLabel = "New bingo board"
        navigationItem.rightBarButtonItem = addButton
        tableView.backgroundColor = Color.Grey900
        tableView.separatorColor = Color.Grey700
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.register(BingoBoardCell.self, forCellReuseIdentifier: BingoBoardCell.reuseIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadBoards()
    }

    fileprivate func reloadBoards() {
        boards = container.getBingoBoards.handle(GetBingoBoardsQuery())
        tableView.reloadData()
        tableView.backgroundView = boards.isEmpty
            ? EmptyStateView(symbolName: "square.grid.3x3.fill",
                             title: "No bingo boards yet",
                             message: "Fill a 3×3, 4×4 or 5×5 board with shiny targets and mark each square as you get it.")
            : nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boards.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BingoBoardCell.reuseIdentifier, for: indexPath) as! BingoBoardCell
        cell.configure(board: boards[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openBoard(boards[indexPath.row].id)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let board = boards[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            self?.confirmDelete(board)
            done(false)
        }
        let rename = UIContextualAction(style: .normal, title: "Rename") { [weak self] _, _, done in
            self?.rename(board)
            done(true)
        }
        rename.backgroundColor = Color.Grey600
        return UISwipeActionsConfiguration(actions: [delete, rename])
    }

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let board = boards[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            UIMenu(title: board.name, children: [
                UIAction(title: "Rename", image: UIImage(systemName: "pencil")) { _ in self?.rename(board) },
                UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in self?.confirmDelete(board) }
            ])
        }
    }

    fileprivate func openBoard(_ id: BingoBoardID) {
        guard let board = BingoBoardVC(container: container, boardId: id) else { return }
        navigationController?.pushViewController(board, animated: true)
    }

    fileprivate func rename(_ board: BingoBoardSummary) {
        presentTextInput(title: "Rename board", text: board.name, placeholder: "Board name") { [weak self] name in
            self?.container.updateBingoBoard.handle(UpdateBingoBoardCommand(boardId: board.id, change: .rename(name)))
            self?.reloadBoards()
        }
    }

    fileprivate func confirmDelete(_ board: BingoBoardSummary) {
        presentDestructiveConfirmation(title: "Delete \(board.name)?",
                                       message: "The board is removed. Your catches stay in your collection.",
                                       destructiveTitle: "Delete") { [weak self] in
            self?.container.deleteBingoBoard.handle(DeleteBingoBoardCommand(boardId: board.id))
            self?.reloadBoards()
        }
    }

    @objc fileprivate func addPressed() {
        let sizePicker = UIAlertController(title: "Board size", message: nil, preferredStyle: .actionSheet)
        for size in BingoBoardSize.allCases {
            sizePicker.addAction(UIAlertAction(title: "\(size.title) · \(size.cellCount) Pokémon", style: .default) { [weak self] _ in
                self?.presentPicker(for: size)
            })
        }
        sizePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sizePicker.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        sizePicker.view.tintColor = Color.Orange500
        present(sizePicker, animated: true)
    }

    fileprivate func presentPicker(for size: BingoBoardSize) {
        let picker = PokemonPickerModalVC(container: container, configuration: .newBingoBoard(size: size)) { [weak self] name, picked in
            guard let self = self else { return }
            let id = self.container.createBingoBoard.handle(CreateBingoBoardCommand(name: name, size: size, pokemonNumbers: picked.map { $0.number }))
            self.openBoard(id)
        }
        present(picker.wrapInSheet(), animated: true)
    }
}

fileprivate class BingoBoardCell: UITableViewCell {
    static let reuseIdentifier = "bingoBoardCell"

    fileprivate let sizeBadge = UILabel(fontSize: 15, weight: .bold, color: Color.Orange500)
    fileprivate let nameLabel = UILabel(fontSize: 20, weight: .semibold)
    fileprivate let progressLabel = UILabel(fontSize: 13, color: Color.Grey400)
    fileprivate let progressBar = UIProgressView(progressViewStyle: .default)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Color.Grey800
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.Grey700
        selectedBackgroundView = selectedBackground
        accessoryType = .disclosureIndicator
        sizeBadge.textAlignment = .center
        sizeBadge.backgroundColor = Color.Grey900
        sizeBadge.layer.cornerRadius = CornerRadius.standard
        sizeBadge.clipsToBounds = true
        progressLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        progressBar.progressTintColor = Color.Orange500
        progressBar.trackTintColor = Color.Grey700
        progressBar.layer.cornerRadius = 2
        progressBar.clipsToBounds = true

        let textStack = UIStackView(arrangedSubviews: [nameLabel, progressLabel, progressBar])
        textStack.axis = .vertical
        textStack.spacing = 3
        textStack.setCustomSpacing(8, after: progressLabel)
        contentView.addAutoLayoutSubviews(sizeBadge, textStack)
        NSLayoutConstraint.activate([
            sizeBadge.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            sizeBadge.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            sizeBadge.widthAnchor.constraint(equalToConstant: 52),
            sizeBadge.heightAnchor.constraint(equalToConstant: 52),
            textStack.leadingAnchor.constraint(equalTo: sizeBadge.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            progressBar.heightAnchor.constraint(equalToConstant: 4)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(board: BingoBoardSummary) {
        sizeBadge.text = board.size.title
        nameLabel.text = board.name
        progressLabel.text = BingoProgressText.make(obtained: board.obtainedCount, total: board.size.cellCount, filled: board.filledCount, lines: board.completedLineCount)
        progressLabel.textColor = board.completedLineCount > 0 ? Color.Orange500 : Color.Grey400
        progressBar.progress = Float(board.obtainedCount) / Float(board.size.cellCount)
        accessibilityLabel = "\(board.name), \(board.size.title) board, \(progressLabel.text ?? "")"
        accessibilityTraits = .button
    }
}

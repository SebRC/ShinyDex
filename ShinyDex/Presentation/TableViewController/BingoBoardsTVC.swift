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
        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
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
        rename.backgroundColor = Color.inactive
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
                self?.presentFillOptions(for: size)
            })
        }
        presentSheet(sizePicker)
    }

    fileprivate func presentFillOptions(for size: BingoBoardSize) {
        let sheet = UIAlertController(title: "Fill the board", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Choose Pokémon", style: .default) { [weak self] _ in self?.presentPicker(for: size) })
        sheet.addAction(UIAlertAction(title: "Random", style: .default) { [weak self] _ in self?.presentRegionOptions(for: size) })
        sheet.addAction(UIAlertAction(title: "From a template", style: .default) { [weak self] _ in self?.presentTemplates(for: size) })
        presentSheet(sheet)
    }

    fileprivate func presentRegionOptions(for size: BingoBoardSize) {
        let sheet = UIAlertController(title: "Random from", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Every region", style: .default) { [weak self] _ in self?.presentCaughtOptions(for: size, region: nil) })
        for region in 0...9 {
            sheet.addAction(UIAlertAction(title: TextResolver().getGenTitle(gen: region), style: .default) { [weak self] _ in self?.presentCaughtOptions(for: size, region: region) })
        }
        presentSheet(sheet)
    }

    fileprivate func presentCaughtOptions(for size: BingoBoardSize, region: Int?) {
        let regionName = region.map { TextResolver().getGenTitle(gen: $0) }
        let sheet = UIAlertController(title: "Which Pokémon?", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Only ones I haven't caught", style: .default) { [weak self] _ in
            self?.createGeneratedBoard(name: regionName.map { "\($0) bingo" } ?? "Random bingo", size: size, source: .random(region: region, onlyUncaught: true))
        })
        sheet.addAction(UIAlertAction(title: "Any Pokémon", style: .default) { [weak self] _ in
            self?.createGeneratedBoard(name: regionName.map { "\($0) bingo" } ?? "Random bingo", size: size, source: .random(region: region, onlyUncaught: false))
        })
        presentSheet(sheet)
    }

    fileprivate func presentTemplates(for size: BingoBoardSize) {
        let templates = container.getBingoTemplates.handle(GetBingoTemplatesQuery())
        let picker = BingoTemplatePickerTVC(templates: templates, size: size) { [weak self] template in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: false)
            self.createGeneratedBoard(name: template.name, size: size, source: .template(id: template.id))
        }
        navigationController?.pushViewController(picker, animated: true)
    }

    fileprivate func createGeneratedBoard(name: String, size: BingoBoardSize, source: CreateGeneratedBingoBoardCommand.Source) {
        guard let id = container.createGeneratedBingoBoard.handle(CreateGeneratedBingoBoardCommand(name: name, size: size, source: source)) else {
            PopupHandler().showPopup(text: "There are no Pokémon left to pick from.")
            return
        }
        Haptics.playSuccess()
        openBoard(id)
    }

    fileprivate func presentSheet(_ sheet: UIAlertController) {
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        sheet.view.tintColor = Color.accent
        present(sheet, animated: true)
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

    fileprivate let sizeBadge = UILabel(style: .subheadline, weight: .bold, color: Color.accent)
    fileprivate let nameLabel = UILabel(style: .title3, weight: .semibold)
    fileprivate let progressLabel = UILabel(style: .footnote, color: Color.textTertiary)
    fileprivate let progressBar = UIProgressView(progressViewStyle: .default)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Color.surface
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.surfaceRaised
        selectedBackgroundView = selectedBackground
        accessoryType = .disclosureIndicator
        sizeBadge.textAlignment = .center
        sizeBadge.backgroundColor = Color.background
        sizeBadge.layer.cornerRadius = CornerRadius.standard
        sizeBadge.clipsToBounds = true
        progressLabel.font = UIFont.make(.footnote, weight: .regular, monospacedDigits: true)
        progressBar.progressTintColor = Color.accent
        progressBar.trackTintColor = Color.surfaceRaised
        progressBar.layer.cornerRadius = CornerRadius.tiny
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
        progressLabel.textColor = board.completedLineCount > 0 ? Color.accent : Color.textTertiary
        progressBar.progress = Float(board.obtainedCount) / Float(board.size.cellCount)
        accessibilityLabel = "\(board.name), \(board.size.title) board, \(progressLabel.text ?? "")"
        accessibilityTraits = .button
    }
}

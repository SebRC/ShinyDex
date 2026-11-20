import UIKit

class BingoBoardVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    fileprivate static let squareSpacing: CGFloat = 6

    fileprivate let container: AppContainer
    fileprivate let boardId: BingoBoardID
    fileprivate var board: BingoBoardDetails
    fileprivate let progressLabel = UILabel(fontSize: 15, weight: .semibold, color: Color.Grey400)
    fileprivate let hintLabel = UILabel(fontSize: 13, color: Color.Grey500, lines: 0)
    fileprivate let layout = UICollectionViewFlowLayout()
    fileprivate lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    fileprivate var shuffleButton: UIBarButtonItem!
    fileprivate var fillButton: UIBarButtonItem!

    init?(container: AppContainer, boardId: BingoBoardID) {
        guard let board = container.getBingoBoardDetails.handle(GetBingoBoardDetailsQuery(boardId: boardId)) else { return nil }
        self.container = container
        self.boardId = boardId
        self.board = board
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = Color.Grey900
        shuffleButton = UIBarButtonItem(image: UIImage(systemName: "shuffle"), style: .plain, target: self, action: #selector(shufflePressed))
        shuffleButton.accessibilityLabel = "Shuffle Pokémon into random squares"
        fillButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(fillPressed))
        fillButton.accessibilityLabel = "Add Pokémon to empty squares"
        navigationItem.rightBarButtonItems = [fillButton, shuffleButton]
        setUpLayout()
        render()
    }

    fileprivate func setUpLayout() {
        progressLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .semibold)
        progressLabel.textAlignment = .center
        progressLabel.adjustsFontSizeToFitWidth = true
        hintLabel.textAlignment = .center
        hintLabel.text = "Tap a square to link the catch you made for it. Drag a square onto another to swap them."

        layout.minimumInteritemSpacing = BingoBoardVC.squareSpacing
        layout.minimumLineSpacing = BingoBoardVC.squareSpacing
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dragInteractionEnabled = true
        collectionView.register(BingoSquareCell.self, forCellWithReuseIdentifier: BingoSquareCell.reuseIdentifier)

        view.addAutoLayoutSubviews(progressLabel, collectionView, hintLabel)
        let margins = view.layoutMarginsGuide
        let fullWidth = collectionView.widthAnchor.constraint(equalTo: margins.widthAnchor)
        fullWidth.priority = .defaultHigh
        NSLayoutConstraint.activate([
            progressLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            progressLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            progressLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 16),
            collectionView.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
            collectionView.heightAnchor.constraint(equalTo: collectionView.widthAnchor),
            collectionView.widthAnchor.constraint(lessThanOrEqualTo: margins.widthAnchor),
            collectionView.widthAnchor.constraint(lessThanOrEqualToConstant: 640),
            fullWidth,
            hintLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            hintLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            hintLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            hintLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadBoard()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let side = board.size.rawValue
        let totalSpacing = BingoBoardVC.squareSpacing * CGFloat(side - 1)
        let squareLength = floor((collectionView.bounds.width - totalSpacing) / CGFloat(side))
        guard squareLength > 0, layout.itemSize.width != squareLength else { return }
        layout.itemSize = CGSize(width: squareLength, height: squareLength)
        layout.invalidateLayout()
    }

    fileprivate func reloadBoard() {
        guard let reloaded = container.getBingoBoardDetails.handle(GetBingoBoardDetailsQuery(boardId: boardId)) else {
            navigationController?.popViewController(animated: true)
            return
        }
        board = reloaded
        render()
    }

    fileprivate func render() {
        title = board.name
        progressLabel.text = BingoProgressText.make(obtained: board.obtainedCount, total: board.cells.count, filled: board.filledCount, lines: board.completedLineCount)
        progressLabel.textColor = board.completedLineCount > 0 ? Color.Orange500 : Color.Grey400
        shuffleButton.isEnabled = board.filledCount > 1
        fillButton.isEnabled = board.emptyCount > 0
        collectionView.reloadData()
    }

    fileprivate func update(_ change: UpdateBingoBoardCommand.Change) {
        container.updateBingoBoard.handle(UpdateBingoBoardCommand(boardId: boardId, change: change))
        reloadBoard()
    }

    // MARK: Collection view

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return board.cells.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BingoSquareCell.reuseIdentifier, for: indexPath) as! BingoSquareCell
        cell.configure(cell: board.cells[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        let index = indexPath.item
        guard board.cells[index].isFilled else {
            presentPlacementPicker(at: index)
            return
        }
        showActions(for: board.cells[index], at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let cell = board.cells[indexPath.item]
        let actions = makeActions(for: cell)
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(title: cell.pokemonName ?? "", children: actions.map { action in
                UIAction(title: action.title, image: UIImage(systemName: action.symbolName), attributes: action.isDestructive ? .destructive : []) { _ in action.perform() }
            })
        }
    }

    // MARK: Drag and drop

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard board.cells[indexPath.item].isFilled else { return [] }
        let item = UIDragItem(itemProvider: NSItemProvider(object: String(indexPath.item) as NSString))
        item.localObject = indexPath
        return [item]
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        guard session.localDragSession != nil, destinationIndexPath != nil else { return UICollectionViewDropProposal(operation: .forbidden) }
        return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destination = coordinator.destinationIndexPath,
              let dragItem = coordinator.items.first?.dragItem,
              let source = dragItem.localObject as? IndexPath,
              source != destination else { return }
        Haptics.tap()
        update(.swap(source.item, destination.item))
        coordinator.drop(dragItem, toItemAt: destination)
    }

    // MARK: Square actions

    fileprivate struct SquareAction {
        let title: String
        let symbolName: String
        var isDestructive = false
        let perform: () -> Void
    }

    fileprivate func makeActions(for cell: BingoCellDetails) -> [SquareAction] {
        let index = cell.index
        guard cell.isFilled else {
            return [SquareAction(title: "Add Pokémon", symbolName: "plus") { [weak self] in self?.presentPlacementPicker(at: index) }]
        }
        var actions = [SquareAction]()
        if let linked = cell.linkedCatch {
            actions.append(SquareAction(title: "View catch", symbolName: "sparkles") { [weak self] in self?.showCatch(linked) })
            if (getLinkableCatches(for: cell).count > 1) {
                actions.append(SquareAction(title: "Link a different catch", symbolName: "link") { [weak self] in self?.pickCatch(for: cell) })
            }
            actions.append(SquareAction(title: "Unlink catch", symbolName: "xmark.circle") { [weak self] in self?.link(nil, to: cell) })
        }
        else if (cell.linkableCatchCount > 0) {
            actions.append(SquareAction(title: "Link a catch", symbolName: "link") { [weak self] in self?.pickCatch(for: cell) })
        }
        actions.append(SquareAction(title: "Change Pokémon", symbolName: "arrow.triangle.2.circlepath") { [weak self] in self?.presentPlacementPicker(at: index) })
        actions.append(SquareAction(title: "Remove from board", symbolName: "trash", isDestructive: true) { [weak self] in self?.update(.clear(at: index)) })
        return actions
    }

    fileprivate func showActions(for cell: BingoCellDetails, at indexPath: IndexPath) {
        let name = cell.pokemonName ?? "this Pokémon"
        let message = !cell.isObtained && cell.linkableCatchCount == 0 ? "You haven't caught a shiny \(name) yet. Log one from its tracker, then link it here." : nil
        let sheet = UIAlertController(title: name, message: message, preferredStyle: .actionSheet)
        for action in makeActions(for: cell) {
            sheet.addAction(UIAlertAction(title: action.title, style: action.isDestructive ? .destructive : .default) { _ in action.perform() })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.view.tintColor = Color.Orange500
        if let square = collectionView.cellForItem(at: indexPath) {
            sheet.popoverPresentationController?.sourceView = square
            sheet.popoverPresentationController?.sourceRect = square.bounds
        }
        present(sheet, animated: true)
    }

    fileprivate func getLinkableCatches(for cell: BingoCellDetails) -> [CatchSummary] {
        return container.getLinkableBingoCatches.handle(GetLinkableBingoCatchesQuery(boardId: boardId, cellIndex: cell.index))
    }

    fileprivate func pickCatch(for cell: BingoCellDetails) {
        guard let number = cell.number else { return }
        let target = LinkCatchTarget(number: number, pokemonName: cell.pokemonName, linkedCatchId: cell.linkedCatch?.id, collectionName: "board")
        let picker = LinkCatchTVC(target: target, catches: getLinkableCatches(for: cell)) { [weak self] caught in
            self?.link(caught, to: cell)
        }
        navigationController?.pushViewController(picker, animated: true)
    }

    fileprivate func link(_ caught: CatchSummary?, to cell: BingoCellDetails) {
        update(.link(at: cell.index, catchId: caught?.id))
        if (caught != nil) {
            Haptics.playSuccess()
        }
    }

    fileprivate func showCatch(_ caught: CatchSummary) {
        guard let detail = CatchDetailTVC(container: container, catchId: caught.id) else { return }
        navigationController?.pushViewController(detail, animated: true)
    }

    // MARK: Board actions

    fileprivate func presentPlacementPicker(at index: Int) {
        let picker = PokemonPickerModalVC(container: container, configuration: .placeOnBingoBoard) { [weak self] _, picked in
            guard let number = picked.first?.number else { return }
            self?.update(.place(number: number, at: index))
        }
        present(picker.wrapInSheet(), animated: true)
    }

    @objc fileprivate func fillPressed() {
        let picker = PokemonPickerModalVC(container: container, configuration: .fillBingoBoard(emptyCellCount: board.emptyCount)) { [weak self] _, picked in
            self?.update(.fillEmptyCells(picked.map { $0.number }))
        }
        present(picker.wrapInSheet(), animated: true)
    }

    @objc fileprivate func shufflePressed() {
        Haptics.playBulk()
        container.updateBingoBoard.handle(UpdateBingoBoardCommand(boardId: boardId, change: .shuffle))
        UIView.transition(with: collectionView, duration: 0.3, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.reloadBoard()
        })
    }
}

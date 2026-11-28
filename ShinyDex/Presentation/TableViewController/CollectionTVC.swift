import UIKit

enum CollectionFilter {
    case ball(String)
    case game(Games)
    case method(HuntMethod)
    case nature(Nature)
    case missingNature
    case gender(Gender)
    case missingGender
    case missingIVs
    case gotAway
    case period(CatchPeriod)

    var showsFailed: Bool {
        switch self {
        case .gotAway, .period: return true
        case .ball, .game, .method, .nature, .missingNature, .gender, .missingGender, .missingIVs: return false
        }
    }

    var isGotAway: Bool {
        if case .gotAway = self { return true }
        return false
    }

    var isMissingDetail: Bool {
        switch self {
        case .missingNature, .missingGender, .missingIVs: return true
        default: return false
        }
    }

    var title: String {
        switch self {
        case .ball(let ball): return BallGrid.getFullName(of: ball)
        case .game(let game): return game.displayName
        case .method(let method): return method.rawValue
        case .nature(let nature): return nature.name
        case .missingNature: return "No nature logged"
        case .gender(let gender): return gender.name
        case .missingGender: return "No gender logged"
        case .missingIVs: return "No IVs logged"
        case .gotAway: return "Got away"
        case .period(let period): return CollectionFilter.getTitle(of: period)
        }
    }

    fileprivate static func getTitle(of period: CatchPeriod) -> String {
        let calendar = Calendar.current
        switch period {
        case .year(let year):
            return String(year)
        case .month(let month):
            return calendar.monthSymbols[month - 1]
        case let .monthOfYear(month, year):
            return "\(calendar.monthSymbols[month - 1]) \(year)"
        case .weekday(let weekday):
            return calendar.weekdaySymbols[weekday - 1]
        case let .date(month, day):
            let anyLeapYear = 2024
            guard let date = calendar.date(from: DateComponents(year: anyLeapYear, month: month, day: day)) else { return "\(day)/\(month)" }
            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("MMMMd")
            return formatter.string(from: date)
        }
    }

    var emptyTitle: String {
        switch self {
        case .gotAway: return "None got away"
        case .missingNature: return "All natures logged"
        case .missingGender: return "All genders logged"
        case .missingIVs: return "All IVs logged"
        default: return "Nothing here"
        }
    }

    var emptyMessage: String {
        switch self {
        case .gotAway: return "Shinies you log as got away will show up here."
        case .missingNature: return "Every catch has a nature logged."
        case .missingGender: return "Every catch has a gender logged."
        case .missingIVs: return "Every catch from Gen 3 on has IVs logged."
        default: return "No catches in \(title) any more."
        }
    }

    func matches(_ caught: CatchSummary) -> Bool {
        switch self {
        case .ball(let ball): return caught.caughtBall == ball
        case .game(let game): return caught.game == game
        case .method(let method): return caught.huntMethod == method
        case .nature(let nature): return caught.nature == nature
        case .missingNature: return caught.nature == nil && !caught.isFailed
        case .gender(let gender): return caught.gender == gender
        case .missingGender: return caught.gender == nil && !caught.isFailed
        case .missingIVs: return caught.ivs.isEmpty && !caught.isFailed && IndividualValues.isUsed(in: caught.game)
        case .gotAway: return caught.isFailed
        case .period(let period): return caught.caughtDate.map { period.contains($0, calendar: .current) } ?? false
        }
    }
}

class CollectionTVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchResultsUpdating {
    fileprivate typealias Entry = CatchSummary

    fileprivate enum SortOrder: Int {
        case dex
        case recent
    }

    fileprivate static let headerKind = "collectionHeader"

    fileprivate let container: AppContainer
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate var collectionView: UICollectionView!
    fileprivate var entries = [Entry]()
    fileprivate var visibleEntries = [Entry]()
    fileprivate var sortOrder = SortOrder.dex
    fileprivate let filter: CollectionFilter?

    init(container: AppContainer, filter: CollectionFilter? = nil) {
        self.container = container
        self.filter = filter
        if case .period? = filter {
            sortOrder = .recent
        }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = filter?.title ?? "Collection"
        view.backgroundColor = Color.background
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CollectionCard.self, forCellWithReuseIdentifier: CollectionCard.reuseIdentifier)
        collectionView.register(CollectionHeader.self, forSupplementaryViewOfKind: CollectionTVC.headerKind, withReuseIdentifier: CollectionHeader.reuseIdentifier)
        view.addAutoLayoutSubviews(collectionView)
        collectionView.pinEdges(to: view)
        setUpSearchController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadEntries()
    }

    fileprivate func setUpSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search catches"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    fileprivate func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 3.0), heightDimension: .estimated(170))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(170))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 15, bottom: 24, trailing: 15)
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: CollectionTVC.headerKind, alignment: .top)
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        section.boundarySupplementaryItems = [header]
        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: Data

    fileprivate func reloadEntries() {
        let source = container.getCatches.handle(GetCatchesQuery(scope: .collection, includingFailed: filter?.showsFailed == true))
        entries = source.filter { filter?.matches($0) ?? true }
        applySearch()
    }

    fileprivate func applySearch() {
        let searchText = searchController.searchBar.text?.lowercased() ?? ""
        var shown = searchText.isEmpty ? entries : entries.filter { [$0.pokemonName, $0.nickname, $0.formName].compactMap { $0?.lowercased() }.contains { $0.contains(searchText) } }
        if (sortOrder == .recent) {
            shown = shown.enumerated().sorted { lhs, rhs in
                switch (lhs.element.caughtDate, rhs.element.caughtDate) {
                case let (l?, r?): return l != r ? l > r : lhs.offset < rhs.offset
                case (_?, nil): return true
                case (nil, _?): return false
                case (nil, nil): return lhs.offset < rhs.offset
                }
            }.map { $0.element }
        }
        visibleEntries = shown
        collectionView.reloadData()
        updateEmptyState()
    }

    fileprivate func updateEmptyState() {
        guard visibleEntries.isEmpty else {
            collectionView.backgroundView = nil
            return
        }
        let emptyMessage = filter?.emptyMessage ?? "Log a catch with the sparkles button next to a Pokémon in the Pokédex or on its tracker."
        collectionView.backgroundView = entries.isEmpty
            ? EmptyStateView(symbolName: filter?.isMissingDetail == true ? "checkmark.circle" : "sparkles",
                             title: filter?.emptyTitle ?? "No shinies yet",
                             message: emptyMessage)
            : EmptyStateView(symbolName: "magnifyingglass",
                             title: "No results",
                             message: "No catches match \u{201C}\(searchController.searchBar.text ?? "")\u{201D}.")
    }

    func updateSearchResults(for searchController: UISearchController) {
        applySearch()
    }

    // MARK: Collection view

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleEntries.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionCard.reuseIdentifier, for: indexPath) as! CollectionCard
        let entry = visibleEntries[indexPath.item]
        cell.configure(caught: entry)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionHeader.reuseIdentifier, for: indexPath) as! CollectionHeader
        let catches = entries
        header.configure(shiniesCaption: filter?.isGotAway == true ? "GOT AWAY" : "SHINIES",
                         shinies: catches.count,
                         species: Set(catches.map { $0.number }).count,
                         encounters: catches.reduce(0) { $0 + $1.encounters },
                         sortIndex: sortOrder.rawValue)
        header.isHidden = entries.isEmpty
        header.onSortChanged = { [weak self] index in
            guard let self = self else { return }
            self.sortOrder = SortOrder(rawValue: index) ?? .dex
            Haptics.tap()
            self.applySearch()
        }
        return header
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showDetails(of: visibleEntries[indexPath.item])
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first, indexPaths.count == 1 else { return nil }
        let entry = visibleEntries[indexPath.item]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            UIMenu(children: [
                UIAction(title: "View Details", image: UIImage(systemName: "info.circle")) { _ in self?.showDetails(of: entry) },
                UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in self?.confirmDelete(entry) }
            ])
        }
    }

    fileprivate func showDetails(of entry: Entry) {
        guard let detail = CatchDetailTVC(container: container, catchId: entry.id) else { return }
        navigationController?.pushViewController(detail, animated: true)
    }

    fileprivate func confirmDelete(_ entry: Entry) {
        presentDeleteCatchConfirmation(for: entry) { [weak self] in
            self?.container.deleteCatch.handle(DeleteCatchCommand(catchId: entry.id))
            self?.reloadEntries()
        }
    }
}

fileprivate class CollectionHeader: UICollectionReusableView {
    static let reuseIdentifier = "collectionHeader"

    var onSortChanged: ((Int) -> Void)?

    fileprivate let shiniesTile = StatTile(caption: "Shinies")
    fileprivate let speciesTile = StatTile(caption: "Species")
    fileprivate let encountersTile = StatTile(caption: "Encounters")
    fileprivate let sortControl = UISegmentedControl(items: ["Dex order", "Recent"])

    override init(frame: CGRect) {
        super.init(frame: frame)
        let tiles = UIStackView(arrangedSubviews: [
            shiniesTile,
            speciesTile,
            encountersTile
        ])
        tiles.distribution = .fillEqually
        tiles.spacing = 10

        sortControl.selectedSegmentTintColor = Color.accent
        sortControl.backgroundColor = Color.surface
        sortControl.setTitleTextAttributes([.foregroundColor: Color.background, .font: UIFont.make(.subheadline, weight: .semibold)], for: .selected)
        sortControl.setTitleTextAttributes([.foregroundColor: Color.textSecondary, .font: UIFont.make(.subheadline, weight: .medium)], for: .normal)
        sortControl.addTarget(self, action: #selector(sortChanged), for: .valueChanged)

        let stack = UIStackView(arrangedSubviews: [tiles, sortControl])
        stack.axis = .vertical
        stack.spacing = 12
        addAutoLayoutSubviews(stack)
        stack.pinEdges(to: self, insets: UIEdgeInsets(top: 4, left: 0, bottom: 10, right: 0))
        sortControl.heightAnchor.constraint(equalToConstant: 34).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(shiniesCaption: String, shinies: Int, species: Int, encounters: Int, sortIndex: Int) {
        shiniesTile.setCaption(shiniesCaption.capitalized)
        shiniesTile.setValue(shinies.grouped, isEmphasized: true)
        speciesTile.setValue(species.grouped)
        encountersTile.setValue(encounters.abbreviated(), spokenValue: encounters.grouped)
        sortControl.selectedSegmentIndex = sortIndex
    }

    @objc fileprivate func sortChanged() {
        onSortChanged?(sortControl.selectedSegmentIndex)
    }
}

fileprivate class CollectionCard: UICollectionViewCell {
    static let reuseIdentifier = "collectionCard"

    fileprivate let glowView = GlowView()
    fileprivate let spriteView = UIImageView()
    fileprivate let ballView = UIImageView()
    fileprivate let nameLabel = UILabel(style: .subheadline, weight: .semibold)
    fileprivate let speciesLabel = UILabel(style: .caption2, weight: .medium, color: Color.textSecondary)
    fileprivate let dateLabel = UILabel(style: .caption2, color: Color.textTertiary)

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = Color.surface
        contentView.layer.cornerRadius = CornerRadius.standard
        contentView.clipsToBounds = true
        isAccessibilityElement = true
        accessibilityTraits = .button

        for imageView in [spriteView, ballView] {
            imageView.contentMode = .scaleAspectFit
            imageView.layer.magnificationFilter = .nearest
        }
        nameLabel.textAlignment = .center
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.75
        speciesLabel.textAlignment = .center
        speciesLabel.adjustsFontSizeToFitWidth = true
        speciesLabel.minimumScaleFactor = 0.8
        dateLabel.textAlignment = .center
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.minimumScaleFactor = 0.8

        contentView.addAutoLayoutSubviews(glowView, spriteView, ballView, nameLabel, speciesLabel, dateLabel)
        NSLayoutConstraint.activate([
            spriteView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -4),
            spriteView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spriteView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.0),
            spriteView.heightAnchor.constraint(equalTo: spriteView.widthAnchor),

            glowView.centerXAnchor.constraint(equalTo: spriteView.centerXAnchor),
            glowView.centerYAnchor.constraint(equalTo: spriteView.centerYAnchor, constant: 14),
            glowView.widthAnchor.constraint(equalTo: spriteView.widthAnchor, multiplier: 0.9),
            glowView.heightAnchor.constraint(equalTo: glowView.widthAnchor),

            ballView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            ballView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            ballView.widthAnchor.constraint(equalToConstant: 24),
            ballView.heightAnchor.constraint(equalToConstant: 24),

            nameLabel.topAnchor.constraint(equalTo: spriteView.bottomAnchor, constant: -10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            speciesLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 1),
            speciesLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            speciesLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: speciesLabel.bottomAnchor, constant: 1),
            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.contentView.backgroundColor = self.isHighlighted ? Color.surfaceRaised : Color.surface
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
            }
        }
    }

    func configure(caught: CatchSummary) {
        spriteView.image = caught.spriteImage
        spriteView.alpha = caught.isFailed ? 0.55 : 1
        glowView.isHidden = caught.isFailed
        ballView.image = caught.isFailed ? UIImage.makeSymbol("wind", pointSize: 14, weight: .semibold) : UIImage(named: caught.caughtBall)
        ballView.tintColor = Color.textTertiary
        ballView.contentMode = caught.isFailed ? .center : .scaleAspectFit
        nameLabel.text = caught.nickname ?? caught.speciesTitle
        speciesLabel.text = caught.speciesTitle
        speciesLabel.isHidden = caught.nickname == nil
        dateLabel.text = caught.formattedCaughtDate ?? "Before history"
        let detail = caught.isFailed ? "got away" : caught.ballName
        accessibilityLabel = [caught.nickname, "Shiny \(caught.speciesTitle)", detail, caught.formattedCaughtDate ?? "date unknown"].compactMap { $0 }.joined(separator: ", ")
    }
}

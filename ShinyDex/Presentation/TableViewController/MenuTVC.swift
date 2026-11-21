import UIKit

class MenuTVC: UITableViewController {
    fileprivate static let huntSymbolName = "scope"
    fileprivate static let collectionSymbolName = "sparkles"
    fileprivate static let iconSize = CGSize(width: 56, height: 56)

    fileprivate enum Destination {
        case pokedex(generation: Int)
        case hunts
        case collection
        case ppCounter
        case stats
        case journeys
        case bingo
        case oddsSimulator
    }

    fileprivate let sections: [(title: String, rows: [Int])] = [
        ("Tracking", [10, 11, 14, 13, 16, 15, 12]),
        ("Pokédex", Array(0...9))
    ]

    let textResolver = TextResolver()
    fileprivate let container: AppContainer
    fileprivate var summary: MenuSummary?

    init(container: AppContainer) {
        self.container = container
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ShinyDex"
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.hidesBackButton = true
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(settingsPressed))
        settingsButton.accessibilityLabel = "Settings"
        navigationItem.rightBarButtonItem = settingsButton

        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.reuseIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        summary = container.getMenuSummary.handle(GetMenuSummaryQuery())
        tableView.reloadData()
    }

    fileprivate func getMenuIndex(for indexPath: IndexPath) -> Int {
        return sections[indexPath.section].rows[indexPath.row]
    }

    fileprivate func getDestination(for index: Int) -> Destination {
        switch index {
        case 10: return .hunts
        case 11: return .collection
        case 12: return .ppCounter
        case 13: return .stats
        case 14: return .journeys
        case 15: return .bingo
        case 16: return .oddsSimulator
        default: return .pokedex(generation: index)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return SectionHeaderView.make(for: tableView, title: sections[section].title)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 52
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.reuseIdentifier, for: indexPath) as! MenuCell
        let index = getMenuIndex(for: indexPath)
        let image = makeMenuImage(for: index)
        cell.configure(title: textResolver.getGenTitle(gen: index), subtitle: getSubtitle(for: index), image: image, progress: getProgress(for: index))
        return cell
    }

    fileprivate func getSubtitle(for index: Int) -> String {
        guard let summary = summary else { return "" }
        switch index {
        case 10:
            guard summary.huntCount > 0 else { return "No hunts yet" }
            let huntText = summary.huntCount == 1 ? "1 hunt" : "\(summary.huntCount) hunts"
            return "\(huntText) · \(summary.huntEncounters.grouped) encounters"
        case 11:
            return summary.caughtCount == 1 ? "1 shiny caught" : "\(summary.caughtCount.grouped) shinies caught"
        case 12:
            return "Track PP during battles"
        case 16:
            return "Chances for any game and method"
        case 13:
            guard let average = summary.averageEncounters else { return "Averages, balls, records and more" }
            return "\(average.grouped) encounters per shiny on average"
        case 14:
            guard summary.journeyCount > 0 else { return "Badge quests, dream teams and more" }
            let journeyText = summary.journeyCount == 1 ? "1 journey" : "\(summary.journeyCount) journeys"
            return summary.completeJourneyCount == 0 ? journeyText : "\(journeyText) · \(summary.completeJourneyCount) complete"
        case 15:
            guard summary.bingoBoardCount > 0 else { return "3×3, 4×4 and 5×5 shiny bingo boards" }
            let boardText = summary.bingoBoardCount == 1 ? "1 board" : "\(summary.bingoBoardCount) boards"
            switch summary.bingoLineCount {
            case 0: return boardText
            case 1: return "\(boardText) · 1 bingo"
            default: return "\(boardText) · \(summary.bingoLineCount) bingos"
            }
        default:
            guard let progress = summary.regionProgress[index] else { return "" }
            let region = index == 8 ? "Legends: Arceus" : "Generation \(index < 8 ? index + 1 : index)"
            return "\(region) · \(progress.caught)/\(progress.total) caught"
        }
    }

    fileprivate func getProgress(for index: Int) -> Float? {
        guard let progress = summary?.regionProgress[index] else { return nil }
        return Float(progress.caught) / Float(progress.total)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewController: UIViewController
        switch getDestination(for: getMenuIndex(for: indexPath)) {
        case .pokedex(let generation):
            viewController = PokedexTVC(container: container, generation: generation)
        case .hunts:
            viewController = HuntsTVC(container: container)
        case .collection:
            viewController = CollectionTVC(container: container)
        case .ppCounter:
            viewController = PPCounterTVC(container: container)
        case .stats:
            viewController = StatsVC(container: container)
        case .journeys:
            viewController = JourneysTVC(container: container)
        case .bingo:
            viewController = BingoBoardsTVC(container: container)
        case .oddsSimulator:
            viewController = OddsSimulatorVC(container: container)
        }
        navigationController?.pushViewController(viewController, animated: true)
    }

    fileprivate func makeMenuImage(for index: Int) -> UIImage? {
        switch index {
        case 0...7:
            return makeRegionImage(named: "gen\(index + 1)")
        case 8:
            return PixelArt.makeCenteredImage(named: "hisui")
        case 9:
            return makeRegionImage(named: "gen9")
        case 10:
            return UIImage.makeSymbol(MenuTVC.huntSymbolName, pointSize: 20, weight: .medium)?.padded(to: MenuTVC.iconSize)
        case 11:
            return UIImage.makeSymbol(MenuTVC.collectionSymbolName, pointSize: 20, weight: .medium)?.padded(to: MenuTVC.iconSize)
        case 12:
            return UIImage.makeSymbol("bolt.fill", pointSize: 20, weight: .medium)?.padded(to: MenuTVC.iconSize)
        case 13:
            return UIImage.makeSymbol("chart.bar.fill", pointSize: 20, weight: .medium)?.padded(to: MenuTVC.iconSize)
        case 14:
            return UIImage.makeSymbol("map.fill", pointSize: 20, weight: .medium)?.padded(to: MenuTVC.iconSize)
        case 15:
            return UIImage.makeSymbol("square.grid.3x3.fill", pointSize: 20, weight: .medium)?.padded(to: MenuTVC.iconSize)
        case 16:
            return UIImage.makeSymbol("percent", pointSize: 20, weight: .medium)?.padded(to: MenuTVC.iconSize)
        default:
            return PixelArt.makeCenteredImage(named: "gen1")
        }
    }

    fileprivate static func makeBadgeRect(touching sprite: UIImage, drawnIn spriteRect: CGRect, within canvas: CGRect) -> CGRect {
        let badgeSize: CGFloat = 22
        let overlap: CGFloat = 5
        let scale = spriteRect.width / sprite.size.width
        let visible = sprite.findVisiblePixelRect().map {
            CGRect(x: spriteRect.minX + $0.minX * scale, y: spriteRect.minY + $0.minY * scale, width: $0.width * scale, height: $0.height * scale)
        } ?? spriteRect
        let x = min(visible.maxX - overlap, canvas.maxX - badgeSize)
        let y = min(visible.maxY - overlap, canvas.maxY - badgeSize)
        return CGRect(x: x, y: y, width: badgeSize, height: badgeSize)
    }

    fileprivate func makeRegionImage(named name: String) -> UIImage? {
        return PixelArt.makeFilledImage(named: name, fillingFraction: 0.77, maximumScale: 3, canvasSize: MenuCell.regionImageSize)
    }

    @objc fileprivate func settingsPressed() {
        navigationController?.pushViewController(SettingsVC(container: container), animated: true)
    }
}

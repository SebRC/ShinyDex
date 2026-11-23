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
        case battlers
        case achievements
        case catchRate
    }

    fileprivate enum MenuSection {
        case onThisDay
        case hunting
        case pokedex
        case collection
        case tools
    }

    fileprivate static let huntsIndex = 10
    fileprivate static let huntSpriteCount = 3
    fileprivate static let collectionIndices = [11, 13, 18, 14, 15]
    fileprivate static let toolIndices = [17, 19, 16, 12]

    let textResolver = TextResolver()
    fileprivate let container: AppContainer
    fileprivate var summary: MenuSummary?
    fileprivate var achievements: AchievementsOverview?
    fileprivate var onThisDay = [OnThisDayCatch]()
    fileprivate var currentHunt: HuntSummary?
    fileprivate var sections = [MenuSection]()

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
        tableView.register(CatchCell.self, forCellReuseIdentifier: CatchCell.reuseIdentifier)
        tableView.register(RegionStripCell.self, forCellReuseIdentifier: RegionStripCell.reuseIdentifier)
        tableView.register(MenuToolGridCell.self, forCellReuseIdentifier: MenuToolGridCell.reuseIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        summary = container.getMenuSummary.handle(GetMenuSummaryQuery())
        AchievementAnnouncer.announceNewUnlocks(using: container)
        achievements = container.getAchievements.handle(GetAchievementsQuery())
        onThisDay = container.getOnThisDay.handle(GetOnThisDayQuery())
        currentHunt = container.getHunts.handle(GetHuntsQuery()).first { !$0.members.isEmpty }
        sections = (onThisDay.isEmpty ? [] : [.onThisDay]) + [.hunting, .pokedex, .collection, .tools]
        tableView.reloadData()
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
        case 17: return .battlers
        case 18: return .achievements
        case 19: return .catchRate
        default: return .pokedex(generation: index)
        }
    }

    fileprivate func findMenuIndices(in section: MenuSection) -> [Int] {
        switch section {
        case .hunting: return [MenuTVC.huntsIndex]
        case .collection: return MenuTVC.collectionIndices
        default: return []
        }
    }

    // MARK: Table view

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .pokedex, .tools: return 1
        case .onThisDay: return onThisDay.count
        case .hunting, .collection: return findMenuIndices(in: sections[section]).count
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return SectionHeaderView.make(for: tableView, title: makeHeaderTitle(for: sections[section]))
    }

    fileprivate func makeHeaderTitle(for section: MenuSection) -> String? {
        switch section {
        case .onThisDay: return "On this day"
        case .hunting: return "Hunting"
        case .pokedex:
            guard let progress = summary?.regionProgress.values else { return "Pokédex" }
            let caught = progress.reduce(0) { $0 + $1.caught }
            let total = progress.reduce(0) { $0 + $1.total }
            return "Pokédex · \(caught.grouped)/\(total.grouped)"
        case .collection: return "Collection"
        case .tools: return "Tools"
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return makeHeaderTitle(for: sections[section]) == nil ? Spacing.small : UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 52
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if case .onThisDay = sections[indexPath.section] {
            return CatchCell.height
        }
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .onThisDay:
            return makeOnThisDayCell(for: onThisDay[indexPath.row], at: indexPath)
        case .pokedex:
            let cell = tableView.dequeueReusableCell(withIdentifier: RegionStripCell.reuseIdentifier, for: indexPath) as! RegionStripCell
            cell.configure(regions: makeRegions())
            cell.onSelect = { [weak self] region in self?.open(.pokedex(generation: region)) }
            return cell
        case .tools:
            let cell = tableView.dequeueReusableCell(withIdentifier: MenuToolGridCell.reuseIdentifier, for: indexPath) as! MenuToolGridCell
            cell.configure(tools: MenuTVC.toolIndices.map { MenuToolGridCell.Tool(title: textResolver.getGenTitle(gen: $0), symbolName: MenuTVC.findSymbolName(for: $0)) })
            cell.onSelect = { [weak self] index in
                guard let self = self else { return }
                self.open(self.getDestination(for: MenuTVC.toolIndices[index]))
            }
            return cell
        case .hunting, .collection:
            let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.reuseIdentifier, for: indexPath) as! MenuCell
            let index = findMenuIndices(in: sections[indexPath.section])[indexPath.row]
            if index == MenuTVC.huntsIndex, let hunt = currentHunt {
                cell.configure(title: textResolver.getGenTitle(gen: index), subtitle: makeHuntsSubtitle(for: hunt), image: makeHuntImage(for: hunt), progress: nil, usesWideImage: true)
                return cell
            }
            let image = UIImage.makeSymbol(MenuTVC.findSymbolName(for: index), pointSize: 20, weight: .medium)?.padded(to: MenuTVC.iconSize)
            cell.configure(title: textResolver.getGenTitle(gen: index), subtitle: getSubtitle(for: index), image: image, progress: nil)
            return cell
        }
    }

    fileprivate func makeHuntsSubtitle(for hunt: HuntSummary) -> String {
        let otherHunts = (summary?.huntCount ?? 1) - 1
        let others = otherHunts > 0 ? " · +\(otherHunts) more" : ""
        return "\(hunt.name) · \(hunt.totalEncounters.grouped) encounters\(others)"
    }

    fileprivate func makeHuntImage(for hunt: HuntSummary) -> UIImage? {
        let sprites = hunt.members.prefix(MenuTVC.huntSpriteCount).compactMap { PokemonSprites.makeImage(pokemonName: $0.name) }
        guard !sprites.isEmpty else { return nil }
        let canvas = MenuCell.regionImageSize
        let spriteSide = canvas.height
        let step = sprites.count > 1 ? min(spriteSide * 0.8, (canvas.width - spriteSide) / CGFloat(sprites.count - 1)) : 0
        let totalWidth = spriteSide + step * CGFloat(sprites.count - 1)
        let format = UIGraphicsImageRendererFormat.default()
        return UIGraphicsImageRenderer(size: canvas, format: format).image { context in
            context.cgContext.interpolationQuality = .none
            for (index, sprite) in sprites.enumerated() {
                let origin = CGPoint(x: (canvas.width - totalWidth) / 2 + step * CGFloat(index), y: 0)
                sprite.draw(in: CGRect(origin: origin, size: CGSize(width: spriteSide, height: spriteSide)))
            }
        }
    }

    fileprivate func makeRegions() -> [RegionStripCell.Region] {
        return PokedexRegions.all.map { region in
            let progress = summary?.regionProgress[region]
            return RegionStripCell.Region(index: region, title: textResolver.getGenTitle(gen: region), image: makeRegionImage(for: region),
                                          caught: progress?.caught ?? 0, total: progress?.total ?? 0)
        }
    }

    fileprivate func makeOnThisDayCell(for memory: OnThisDayCatch, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CatchCell.reuseIdentifier, for: indexPath) as! CatchCell
        let caught = memory.caught
        let when = memory.yearsAgo == 1 ? "1 year ago" : "\(memory.yearsAgo) years ago"
        let details = [when, caught.encounters > 0 ? "\(caught.encounters.grouped) encounters" : nil].compactMap { $0 }
        cell.configure(pokemonName: caught.pokemonName, formId: caught.formId, title: caught.nickname ?? caught.speciesTitle,
                       subtitle: details.joined(separator: " · "), ball: caught.caughtBall, isFailed: caught.isFailed)
        cell.accessibilityLabel = [caught.nickname ?? caught.speciesTitle, caught.isFailed ? "got away" : nil, details.joined(separator: ", ")].compactMap { $0 }.joined(separator: ", ")
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
        case 17:
            return "Your best shinies for battle"
        case 19:
            return "Your chances with every ball"
        case 18:
            guard let achievements = achievements else { return "" }
            return "\(achievements.unlockedCount) of \(achievements.achievements.count) unlocked"
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

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch sections[indexPath.section] {
        case .pokedex, .tools: return false
        default: return true
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch sections[indexPath.section] {
        case .onThisDay:
            guard let detail = CatchDetailTVC(container: container, catchId: onThisDay[indexPath.row].caught.id) else { return }
            navigationController?.pushViewController(detail, animated: true)
        case .hunting, .collection:
            open(getDestination(for: findMenuIndices(in: sections[indexPath.section])[indexPath.row]))
        case .pokedex, .tools:
            break
        }
    }

    fileprivate func open(_ destination: Destination) {
        let viewController: UIViewController
        switch destination {
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
        case .battlers:
            viewController = BattlersTVC(container: container)
        case .achievements:
            viewController = AchievementsTVC(container: container)
        case .catchRate:
            viewController = CatchRateVC(container: container)
        }
        navigationController?.pushViewController(viewController, animated: true)
    }

    fileprivate static func findSymbolName(for index: Int) -> String {
        switch index {
        case 10: return huntSymbolName
        case 11: return collectionSymbolName
        case 12: return "bolt.fill"
        case 13: return "chart.bar.fill"
        case 14: return "map.fill"
        case 15: return "square.grid.3x3.fill"
        case 16: return "percent"
        case 17: return "trophy.fill"
        case 18: return "medal.fill"
        case 19: return "circle.circle.fill"
        default: return "questionmark"
        }
    }

    fileprivate func makeRegionImage(for region: Int) -> UIImage? {
        switch region {
        case 8: return makeRegionImage(named: "hisui")
        case 9: return makeRegionImage(named: "gen9")
        default: return makeRegionImage(named: "gen\(region + 1)")
        }
    }

    fileprivate func makeRegionImage(named name: String) -> UIImage? {
        return PixelArt.makeFilledImage(named: name, fillingFraction: 0.77, maximumScale: 3, canvasSize: MenuCell.regionImageSize)
    }

    @objc fileprivate func settingsPressed() {
        navigationController?.pushViewController(SettingsVC(container: container), animated: true)
    }
}

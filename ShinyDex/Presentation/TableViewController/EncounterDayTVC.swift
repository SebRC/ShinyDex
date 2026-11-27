import UIKit

class EncounterDayTVC: UITableViewController {
    fileprivate enum Section {
        case total, shinies, pokemon
    }

    fileprivate enum Row {
        case pokemon(EncounterDayBreakdown.PokemonShare)
        case unsplit(count: Int, sharePercent: Int)
    }

    fileprivate let container: AppContainer
    fileprivate let date: Date
    fileprivate var breakdown: EncounterDayBreakdown?
    fileprivate var rows = [Row]()
    fileprivate var sections = [Section.total]

    init(container: AppContainer, date: Date) {
        self.container = container
        self.date = date
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = EncounterDayTVC.format(date, template: "EEE d MMM yyyy")
        navigationItem.largeTitleDisplayMode = .never
        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
        tableView.register(CatchCell.self, forCellReuseIdentifier: CatchCell.reuseIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    fileprivate func reload() {
        let breakdown = container.getEncounterDay.handle(GetEncounterDayQuery(date: date))
        self.breakdown = breakdown
        rows = breakdown.pokemon.map { .pokemon($0) }
        if !breakdown.pokemon.isEmpty && breakdown.unsplitCount > 0 {
            let sharePercent = Int((Double(breakdown.unsplitCount) / Double(breakdown.total) * 100).rounded())
            rows.append(.unsplit(count: breakdown.unsplitCount, sharePercent: sharePercent))
        }
        sections = [.total] + (breakdown.shinies.isEmpty ? [] : [.shinies]) + (rows.isEmpty ? [] : [.pokemon])
        tableView.reloadData()
    }

    fileprivate func makeFooter(for breakdown: EncounterDayBreakdown) -> String? {
        let splitSince = breakdown.splitSince.map { EncounterDayTVC.format($0, template: "d MMMM yyyy") }
        if breakdown.pokemon.isEmpty && breakdown.total > 0 {
            return splitSince.map { "These encounters aren't split by Pokémon. The split by Pokémon started on \($0)." }
                ?? "These encounters aren't split by Pokémon. Encounters from now on will be."
        }
        if breakdown.unsplitCount > 0 {
            return "Some encounters were counted before the split by Pokémon started, so they aren't assigned to one."
        }
        return nil
    }

    // MARK: Table

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .total: return 1
        case .shinies: return breakdown?.shinies.count ?? 0
        case .pokemon: return rows.count
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch sections[section] {
        case .total: return SectionHeaderView.make(for: tableView, title: nil)
        case .shinies: return SectionHeaderView.make(for: tableView, title: "Shinies")
        case .pokemon: return SectionHeaderView.make(for: tableView, title: "By Pokémon")
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[indexPath.section] == .shinies ? CatchCell.height : UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let breakdown = breakdown, sections[section] == (rows.isEmpty ? .total : .pokemon) else { return nil }
        return makeFooter(for: breakdown)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .shinies:
            return makeShinyCell(for: breakdown!.shinies[indexPath.row], at: indexPath)
        case .total:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.backgroundColor = Color.surface
            cell.selectionStyle = .none
            cell.textLabel?.text = "Encounters"
            cell.textLabel?.font = UIFont.make(.body, weight: .semibold)
            cell.textLabel?.textColor = Color.textPrimary
            cell.detailTextLabel?.text = (breakdown?.total ?? 0).grouped
            cell.detailTextLabel?.font = UIFont.make(.body, weight: .semibold, monospacedDigits: true)
            cell.detailTextLabel?.textColor = Color.accent
            return cell
        case .pokemon:
            return makePokemonShareCell(for: rows[indexPath.row])
        }
    }

    fileprivate func makeShinyCell(for caught: CatchSummary, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CatchCell.reuseIdentifier, for: indexPath) as! CatchCell
        let details = [caught.isFailed ? "Got away" : caught.ballName, caught.encounters > 0 ? "\(caught.encounters.grouped) encounters" : nil].compactMap { $0 }
        let title = caught.nickname ?? caught.speciesTitle
        cell.configure(pokemonName: caught.pokemonName, formId: caught.formId, title: title,
                       subtitle: details.joined(separator: " · "), ball: caught.caughtBall, isFailed: caught.isFailed)
        cell.accessibilityLabel = ([title] + details).joined(separator: ", ")
        return cell
    }

    fileprivate func makePokemonShareCell(for row: Row) -> UITableViewCell {
        let cell = PokemonShareCell()
        switch row {
        case .pokemon(let share):
            cell.configure(image: PokemonSprites.makeImage(pokemonName: share.name), title: share.name, count: share.count, sharePercent: share.sharePercent, isTappable: true)
        case .unsplit(let count, let sharePercent):
            cell.configure(image: UIImage.makeSymbol("questionmark.circle", pointSize: 22, weight: .regular), title: "Not split by Pokémon",
                           count: count, sharePercent: sharePercent, isTappable: false)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch sections[indexPath.section] {
        case .shinies:
            guard let caught = breakdown?.shinies[indexPath.row], let detail = CatchDetailTVC(container: container, catchId: caught.id) else { return }
            navigationController?.pushViewController(detail, animated: true)
        case .pokemon:
            guard case .pokemon(let share) = rows[indexPath.row], let tracker = ShinyTrackerVC(container: container, number: share.number) else { return }
            navigationController?.pushViewController(tracker, animated: true)
        case .total:
            break
        }
    }

    fileprivate static func format(_ date: Date, template: String) -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate(template)
        return formatter.string(from: date)
    }
}

fileprivate class PokemonShareCell: UITableViewCell {
    fileprivate static let iconSize: CGFloat = 44
    fileprivate static let barHeight: CGFloat = 6

    fileprivate let iconImageView = UIImageView()
    fileprivate let titleLabel = UILabel(style: .body, weight: .semibold, color: Color.textPrimary)
    fileprivate let countLabel = UILabel(style: .subheadline, color: Color.textTertiary)
    fileprivate let shareLabel = UILabel(style: .body, weight: .semibold)
    fileprivate let barTrack = UIView()
    fileprivate let barFill = UIView()
    fileprivate var barWidth: NSLayoutConstraint?

    init() {
        super.init(style: .default, reuseIdentifier: nil)
        backgroundColor = Color.surface
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.surfaceRaised
        selectedBackgroundView = selectedBackground

        iconImageView.contentMode = .center
        iconImageView.layer.magnificationFilter = .nearest
        iconImageView.tintColor = Color.textTertiary
        shareLabel.font = UIFont.make(.body, weight: .semibold, monospacedDigits: true)
        shareLabel.setContentHuggingPriority(.required, for: .horizontal)
        shareLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        countLabel.font = UIFont.make(.subheadline, monospacedDigits: true)
        barTrack.backgroundColor = Color.surfaceRaised
        barTrack.layer.cornerRadius = CornerRadius.capsule(height: PokemonShareCell.barHeight)
        barTrack.clipsToBounds = true
        barTrack.addAutoLayoutSubviews(barFill)
        barFill.layer.cornerRadius = CornerRadius.capsule(height: PokemonShareCell.barHeight)

        let titleRow = UIStackView(arrangedSubviews: [titleLabel, shareLabel])
        titleRow.spacing = Spacing.small
        let labels = UIStackView(arrangedSubviews: [titleRow, countLabel, barTrack])
        labels.axis = .vertical
        labels.spacing = Spacing.extraSmall
        labels.setCustomSpacing(Spacing.small, after: countLabel)
        let row = UIStackView(arrangedSubviews: [iconImageView, labels])
        row.spacing = Spacing.medium
        row.alignment = .center
        contentView.addAutoLayoutSubviews(row)
        row.pinEdges(to: contentView, insets: UIEdgeInsets(top: Spacing.medium, left: Spacing.large, bottom: Spacing.medium, right: Spacing.large))
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: PokemonShareCell.iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: PokemonShareCell.iconSize),
            barTrack.heightAnchor.constraint(equalToConstant: PokemonShareCell.barHeight),
            barFill.topAnchor.constraint(equalTo: barTrack.topAnchor),
            barFill.bottomAnchor.constraint(equalTo: barTrack.bottomAnchor),
            barFill.leadingAnchor.constraint(equalTo: barTrack.leadingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(image: UIImage?, title: String, count: Int, sharePercent: Int, isTappable: Bool) {
        iconImageView.image = image
        titleLabel.text = title
        titleLabel.textColor = isTappable ? Color.textPrimary : Color.textSecondary
        countLabel.text = count == 1 ? "1 encounter" : "\(count.grouped) encounters"
        shareLabel.text = "\(sharePercent)%"
        shareLabel.textColor = isTappable ? Color.accent : Color.textTertiary
        barFill.backgroundColor = isTappable ? Color.accent : Color.textQuaternary
        barWidth?.isActive = false
        barWidth = barFill.widthAnchor.constraint(equalTo: barTrack.widthAnchor, multiplier: max(CGFloat(sharePercent), 0.5) / 100)
        barWidth?.isActive = true
        accessoryType = isTappable ? .disclosureIndicator : .none
        selectionStyle = isTappable ? .default : .none
        isAccessibilityElement = true
        accessibilityLabel = "\(title), \(countLabel.text ?? ""), \(sharePercent) percent"
        accessibilityTraits = isTappable ? .button : .staticText
    }
}

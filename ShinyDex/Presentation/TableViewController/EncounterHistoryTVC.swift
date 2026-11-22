import UIKit

class EncounterHistoryTVC: UITableViewController {
    fileprivate enum Section: Int, CaseIterable {
        case recent, calendar, summary, periods
    }

    fileprivate static let labelledDayInterval = 7

    fileprivate let container: AppContainer
    fileprivate let periodControl = UISegmentedControl(items: ["Day", "Month", "Year"])
    fileprivate var period = EncounterPeriod.day
    fileprivate var history: EncounterHistory?

    init(container: AppContainer) {
        self.container = container
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Encounter history"
        navigationItem.largeTitleDisplayMode = .never
        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
        setUpPeriodControl()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadHistory()
    }

    fileprivate func setUpPeriodControl() {
        periodControl.selectedSegmentIndex = EncounterPeriod.allCases.firstIndex(of: period) ?? 0
        periodControl.selectedSegmentTintColor = Color.accent
        periodControl.setTitleTextAttributes([.foregroundColor: Color.textPrimary], for: .normal)
        periodControl.setTitleTextAttributes([.foregroundColor: Color.background], for: .selected)
        periodControl.addTarget(self, action: #selector(periodChanged), for: .valueChanged)
        let header = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 52))
        header.addAutoLayoutSubviews(periodControl)
        NSLayoutConstraint.activate([
            periodControl.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20),
            periodControl.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -20),
            periodControl.bottomAnchor.constraint(equalTo: header.bottomAnchor)
        ])
        tableView.tableHeaderView = header
    }

    @objc fileprivate func periodChanged() {
        period = EncounterPeriod.allCases[periodControl.selectedSegmentIndex]
        reloadHistory()
    }

    fileprivate func reloadHistory() {
        let history = container.getEncounterHistory.handle(GetEncounterHistoryQuery(period: period))
        self.history = history.recorded.isEmpty ? nil : history
        periodControl.isHidden = self.history == nil
        tableView.reloadData()
        tableView.backgroundView = self.history == nil
            ? EmptyStateView(symbolName: "calendar",
                             title: "No encounters yet",
                             message: "Each day's encounters across all your hunts will show up here.")
            : nil
    }

    fileprivate var summaryRows: [(title: String, value: String)] {
        guard let history = history else { return [] }
        var rows = [(title: String, value: String)]()
        if let busiest = history.busiest {
            rows.append(("Busiest \(singularName)", "\(busiest.count.grouped) \(period == .day ? "on" : "in") \(formatPeriod(busiest.start))"))
        }
        if let average = history.averagePerActivePeriod {
            rows.append(("Average per active \(singularName)", average.grouped))
        }
        rows.append(("Active \(pluralName)", history.recorded.count.grouped))
        if period == .day {
            rows.append(("Current streak", EncounterHistoryTVC.formatDays(history.dayStreaks.current)))
            rows.append(("Longest streak", EncounterHistoryTVC.formatDays(history.dayStreaks.longest)))
        }
        return rows
    }

    fileprivate var singularName: String {
        switch period {
        case .day: return "day"
        case .month: return "month"
        case .year: return "year"
        }
    }

    fileprivate var pluralName: String {
        return singularName + "s"
    }

    fileprivate var sections: [Section] {
        guard history != nil else { return [] }
        return Section.allCases.filter { $0 != .calendar || period == .day }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .recent, .calendar: return 1
        case .summary: return summaryRows.count
        case .periods: return history?.recorded.count ?? 0
        }
    }


    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return SectionHeaderView.make(for: tableView, title: makeHeaderTitle(for: section))
    }

    fileprivate func makeHeaderTitle(for section: Int) -> String? {
        switch sections[section] {
        case .recent:
            let count = history?.recent.count ?? 0
            return period == .year ? "By year" : "Last \(count) \(count == 1 ? singularName : pluralName)"
        case .calendar: return "Hunting calendar"
        case .summary: return "Summary"
        case .periods: return pluralName.capitalized
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard sections[section] == .recent, let trackedSince = history?.trackedSince else { return nil }
        return "Tracked since \(DateFormatter.localizedString(from: trackedSince, dateStyle: .medium, timeStyle: .none))."
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let history = history else { return UITableViewCell() }
        switch sections[indexPath.section] {
        case .recent:
            return makeChartCell(entries: history.recent)
        case .calendar:
            return makeCalendarCell(weeks: history.calendarWeeks)
        case .summary:
            let row = summaryRows[indexPath.row]
            return makeValueCell(title: row.title, value: row.value)
        case .periods:
            let entry = history.recorded[indexPath.row]
            let cell = makeValueCell(title: formatPeriod(entry.start, relativeToNow: true), value: entry.count.grouped)
            if period == .day {
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .default
                let selectedBackground = UIView()
                selectedBackground.backgroundColor = Color.surfaceRaised
                cell.selectedBackgroundView = selectedBackground
            }
            return cell
        }
    }

    fileprivate func makeChartCell(entries: [EncounterHistory.Entry]) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.backgroundColor = Color.surface
        let lastIndex = entries.count - 1
        let bars = entries.enumerated().map { index, entry in
            EncounterHistoryChartView.Bar(label: makeChartLabel(for: entry.start, stepsFromCurrent: lastIndex - index),
                                          accessibilityLabel: formatPeriod(entry.start),
                                          count: entry.count,
                                          isCurrent: index == lastIndex)
        }
        let chart = EncounterHistoryChartView(bars: bars)
        cell.contentView.addAutoLayoutSubviews(chart)
        chart.pinEdges(to: cell.contentView)
        return cell
    }

    fileprivate func makeCalendarCell(weeks: [[EncounterHistory.Entry?]]) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.backgroundColor = Color.surface
        let calendarView = HuntingCalendarView(weeks: weeks)
        cell.contentView.addAutoLayoutSubviews(calendarView)
        calendarView.pinEdges(to: cell.contentView)
        return cell
    }

    fileprivate static func formatDays(_ count: Int) -> String {
        return count == 1 ? "1 day" : "\(count.grouped) days"
    }

    fileprivate func makeChartLabel(for start: Date, stepsFromCurrent: Int) -> String? {
        switch period {
        case .day:
            guard stepsFromCurrent % EncounterHistoryTVC.labelledDayInterval == 0 else { return nil }
            return String(Calendar.current.component(.day, from: start))
        case .month:
            return format(start, template: "MMM")
        case .year:
            return format(start, template: "yyyy")
        }
    }

    fileprivate func makeValueCell(title: String, value: String) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.backgroundColor = Color.surface
        cell.textLabel?.textColor = Color.textPrimary
        cell.detailTextLabel?.textColor = Color.textTertiary
        cell.detailTextLabel?.font = UIFont.make(.body, weight: .regular, monospacedDigits: true)
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = value
        cell.selectionStyle = .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard period == .day, sections[indexPath.section] == .periods, let entry = history?.recorded[indexPath.row] else { return }
        navigationController?.pushViewController(EncounterDayTVC(container: container, date: entry.start), animated: true)
    }

    fileprivate func formatPeriod(_ start: Date, relativeToNow: Bool = false) -> String {
        let calendar = Calendar.current
        switch period {
        case .day:
            if relativeToNow && calendar.isDateInToday(start) { return "Today" }
            if relativeToNow && calendar.isDateInYesterday(start) { return "Yesterday" }
            return format(start, template: "EEE d MMM yyyy")
        case .month:
            if relativeToNow && calendar.isDate(start, equalTo: Date(), toGranularity: .month) { return "This month" }
            return format(start, template: "MMMM yyyy")
        case .year:
            if relativeToNow && calendar.isDate(start, equalTo: Date(), toGranularity: .year) { return "This year" }
            return format(start, template: "yyyy")
        }
    }

    fileprivate func format(_ date: Date, template: String) -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate(template)
        return formatter.string(from: date)
    }
}

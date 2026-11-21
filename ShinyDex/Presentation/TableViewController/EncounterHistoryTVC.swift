import UIKit

class EncounterHistoryTVC: UITableViewController {
    fileprivate enum Section: Int, CaseIterable {
        case recent, summary, days
    }

    fileprivate let container: AppContainer
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
        tableView.backgroundColor = Color.Grey900
        tableView.separatorColor = Color.Grey700
        tableView.allowsSelection = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadHistory()
    }

    fileprivate func reloadHistory() {
        let history = container.getEncounterHistory.handle(GetEncounterHistoryQuery())
        self.history = history.recordedDays.isEmpty ? nil : history
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
        if let busiestDay = history.busiestDay {
            rows.append(("Busiest day", "\(busiestDay.count.grouped) on \(EncounterHistoryTVC.formatDay(busiestDay.date))"))
        }
        if let average = history.averagePerActiveDay {
            rows.append(("Average per active day", average.grouped))
        }
        rows.append(("Active days", history.recordedDays.count.grouped))
        return rows
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return history == nil ? 0 : Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .recent: return 1
        case .summary: return summaryRows.count
        case .days: return history?.recordedDays.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .recent: return "Last \(history?.recentDays.count ?? 0) days"
        case .summary: return "Summary"
        case .days: return "Days"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let history = history else { return UITableViewCell() }
        switch Section(rawValue: indexPath.section)! {
        case .recent:
            return makeChartCell(days: history.recentDays)
        case .summary:
            let row = summaryRows[indexPath.row]
            return makeValueCell(title: row.title, value: row.value)
        case .days:
            let day = history.recordedDays[indexPath.row]
            return makeValueCell(title: EncounterHistoryTVC.formatDay(day.date), value: day.count.grouped)
        }
    }

    fileprivate func makeChartCell(days: [EncounterHistory.Day]) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.backgroundColor = Color.Grey800
        let chart = DailyEncountersChartView(days: days)
        cell.contentView.addAutoLayoutSubviews(chart)
        chart.pinEdges(to: cell.contentView)
        return cell
    }

    fileprivate func makeValueCell(title: String, value: String) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.backgroundColor = Color.Grey800
        cell.textLabel?.textColor = Color.Grey200
        cell.detailTextLabel?.textColor = Color.Grey400
        cell.detailTextLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = value
        return cell
    }

    fileprivate static func formatDay(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "Today" }
        if Calendar.current.isDateInYesterday(date) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEE d MMM yyyy")
        return formatter.string(from: date)
    }
}

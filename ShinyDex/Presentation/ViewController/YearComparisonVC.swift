import UIKit

final class YearComparisonVC: UIViewController {
    fileprivate let container: AppContainer
    fileprivate let scrollView = UIScrollView()
    fileprivate let stack = UIStackView()
    fileprivate var year: Int?

    init(container: AppContainer) {
        self.container = container
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = Color.background
        stack.axis = .vertical
        stack.spacing = 6
        view.addAutoLayoutSubviews(scrollView)
        scrollView.pinEdges(to: view)
        scrollView.addAutoLayoutSubviews(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: Spacing.screenMargin),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -Spacing.screenMargin)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    fileprivate func reload() {
        for view in stack.arrangedSubviews {
            stack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        let comparison = container.getYearComparison.handle(GetYearComparisonQuery(year: year))
        title = "\(comparison.year) vs \(comparison.previousYear)"
        updateYearButton(comparison)
        addPace(comparison)
        addShiniesChart(comparison)
        addEncountersChart(comparison)
    }

    fileprivate func updateYearButton(_ comparison: YearOnYear) {
        guard comparison.availableYears.count > 1 else {
            navigationItem.rightBarButtonItem = nil
            return
        }
        let actions = comparison.availableYears.map { choice in
            UIAction(title: "\(choice) vs \(choice - 1)", state: choice == comparison.year ? .on : .off) { [weak self] _ in
                self?.year = choice
                self?.reload()
            }
        }
        let button = UIBarButtonItem(image: UIImage(systemName: "calendar"), menu: UIMenu(children: actions))
        button.accessibilityLabel = "Choose year"
        navigationItem.rightBarButtonItem = button
    }

    // MARK: Sections

    fileprivate func addPace(_ comparison: YearOnYear) {
        let shinies = StatTile(caption: "Shinies", value: comparison.shinies.current.grouped,
                               detail: YearComparisonVC.formatPace(comparison.shinies, previousYear: comparison.previousYear))
        let encounters = StatTile(caption: "Encounters", value: comparison.encounters.current.grouped,
                                  detail: YearComparisonVC.formatPace(comparison.encounters, previousYear: comparison.previousYear))
        let row = UIStackView(arrangedSubviews: [shinies, encounters])
        row.distribution = .fillEqually
        row.spacing = 10
        let title = comparison.isFullYear ? "Full year" : "By \(YearComparisonVC.formatDay(comparison.comparedUntil))"
        let footnote = comparison.isFullYear
            ? "Each total is compared with \(comparison.previousYear) as a whole."
            : "Each total is compared with \(comparison.previousYear) up to the same day."
        addSection(title, row, footnote: footnote)
    }

    fileprivate func addShiniesChart(_ comparison: YearOnYear) {
        let columns = comparison.months.map {
            YearComparisonChartView.Column(month: $0.month, current: $0.shinies, previous: $0.previousShinies, isUpcoming: $0.isUpcoming)
        }
        let chart = YearComparisonChartView(columns: columns, year: comparison.year, previousYear: comparison.previousYear,
                                            noun: YearComparisonVC.formatShinies) { [weak self] column in
            self?.showCatches(in: column, comparison: comparison)
        }
        addSection("Shinies by month", chart, footnote: "Tap a month to see its catches.")
    }

    fileprivate func addEncountersChart(_ comparison: YearOnYear) {
        let columns = comparison.months.map {
            YearComparisonChartView.Column(month: $0.month, current: $0.encounters, previous: $0.previousEncounters, isUpcoming: $0.isUpcoming)
        }
        let chart = YearComparisonChartView(columns: columns, year: comparison.year, previousYear: comparison.previousYear,
                                            noun: { $0 == 1 ? "1 encounter" : "\($0.grouped) encounters" })
        let footnote = comparison.encountersTrackedSince.map { "Encounters are counted from \(YearComparisonVC.formatFullDay($0)), when tracking began." }
        addSection("Encounters by month", chart, footnote: footnote)
    }

    fileprivate func addSection(_ title: String, _ content: UIView, footnote: String? = nil) {
        let header = SectionHeaderLabel(text: title, horizontalInset: 4)
        let headerWrapper = UIView()
        headerWrapper.addAutoLayoutSubviews(header)
        header.pinEdges(to: headerWrapper, insets: UIEdgeInsets(top: 18, left: 0, bottom: 0, right: 0))
        stack.addArrangedSubview(headerWrapper)
        stack.addArrangedSubview(content)
        guard let footnote = footnote else { return }
        let label = UILabel(style: .caption1, color: Color.textQuaternary, lines: 0)
        label.text = footnote
        let wrapper = UIView()
        wrapper.addAutoLayoutSubviews(label)
        label.pinEdges(to: wrapper, insets: UIEdgeInsets(top: 2, left: 4, bottom: 0, right: 4))
        stack.addArrangedSubview(wrapper)
    }

    // MARK: Navigation

    fileprivate func showCatches(in column: YearComparisonChartView.Column, comparison: YearOnYear) {
        let choices = [(comparison.year, column.current), (comparison.previousYear, column.previous)].filter { $0.1 > 0 }
        guard choices.count > 1 else {
            if let choice = choices.first {
                showCollection(month: column.month, year: choice.0)
            }
            return
        }
        let monthName = Calendar.current.monthSymbols[column.month - 1]
        let sheet = UIAlertController(title: monthName, message: nil, preferredStyle: .actionSheet)
        for (choiceYear, count) in choices {
            sheet.addAction(UIAlertAction(title: "\(choiceYear) · \(YearComparisonVC.formatShinies(count))", style: .default) { [weak self] _ in
                self?.showCollection(month: column.month, year: choiceYear)
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.popoverPresentationController?.sourceView = view
        present(sheet, animated: true)
    }

    fileprivate func showCollection(month: Int, year: Int) {
        navigationController?.pushViewController(CollectionTVC(container: container, filter: .period(.monthOfYear(month: month, year: year))), animated: true)
    }

    // MARK: Formatting

    fileprivate static func formatPace(_ pace: YearOnYear.Pace, previousYear: Int) -> String {
        switch pace.difference {
        case 0: return "Level with \(previousYear)"
        case 1...: return "\(pace.difference.grouped) ahead of \(previousYear)'s \(pace.previous.grouped)"
        default: return "\((-pace.difference).grouped) behind \(previousYear)'s \(pace.previous.grouped)"
        }
    }

    fileprivate static func formatShinies(_ count: Int) -> String {
        return count == 1 ? "1 shiny" : "\(count.grouped) shinies"
    }

    fileprivate static func formatDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMMd")
        return formatter.string(from: date)
    }

    fileprivate static func formatFullDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

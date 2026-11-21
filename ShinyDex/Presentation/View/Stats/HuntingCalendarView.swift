import UIKit

final class HuntingCalendarView: UIView {
    fileprivate static let levelColors = [Color.Grey700, Color.Orange800, Color.Orange700, Color.Orange600, Color.Orange500]
    fileprivate static let cellSpacing: CGFloat = 3

    init(weeks: [[EncounterHistory.Entry?]]) {
        super.init(frame: .zero)
        let maxCount = weeks.joined().compactMap { $0?.count }.max() ?? 0
        let columns = weeks.map { week in HuntingCalendarView.makeColumn(week, maxCount: maxCount) }
        let grid = UIStackView(arrangedSubviews: columns)
        grid.distribution = .fillEqually
        grid.spacing = HuntingCalendarView.cellSpacing

        let monthLabels = UIView()
        let legend = HuntingCalendarView.makeLegend()
        addAutoLayoutSubviews(monthLabels, grid, legend)
        NSLayoutConstraint.activate([
            monthLabels.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            monthLabels.leadingAnchor.constraint(equalTo: grid.leadingAnchor),
            monthLabels.trailingAnchor.constraint(equalTo: grid.trailingAnchor),
            monthLabels.heightAnchor.constraint(equalToConstant: 14),
            grid.topAnchor.constraint(equalTo: monthLabels.bottomAnchor, constant: 4),
            grid.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            grid.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            legend.topAnchor.constraint(equalTo: grid.bottomAnchor, constant: 8),
            legend.trailingAnchor.constraint(equalTo: grid.trailingAnchor),
            legend.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
        HuntingCalendarView.addMonthLabels(to: monthLabels, weeks: weeks, columns: columns)

        let huntedDayCount = weeks.joined().filter { ($0?.count ?? 0) > 0 }.count
        isAccessibilityElement = true
        accessibilityLabel = "Hunting calendar"
        accessibilityValue = "\(huntedDayCount) \(huntedDayCount == 1 ? "day" : "days") hunted in the last \(weeks.count) weeks"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate static func makeColumn(_ week: [EncounterHistory.Entry?], maxCount: Int) -> UIView {
        let cells = week.map { entry -> UIView in
            let cell = UIView()
            cell.layer.cornerRadius = 2
            cell.heightAnchor.constraint(equalTo: cell.widthAnchor).isActive = true
            guard let entry = entry else { return cell }
            cell.backgroundColor = levelColors[findLevel(of: entry.count, maxCount: maxCount)]
            if Calendar.current.isDateInToday(entry.start) {
                cell.layer.borderWidth = 1
                cell.layer.borderColor = Color.Grey200.cgColor
            }
            return cell
        }
        let column = UIStackView(arrangedSubviews: cells)
        column.axis = .vertical
        column.spacing = cellSpacing
        return column
    }

    fileprivate static func findLevel(of count: Int, maxCount: Int) -> Int {
        guard count > 0, maxCount > 0 else { return 0 }
        let highestLevel = levelColors.count - 1
        return min(max(Int((Double(count) / Double(maxCount) * Double(highestLevel)).rounded(.up)), 1), highestLevel)
    }

    fileprivate static func addMonthLabels(to container: UIView, weeks: [[EncounterHistory.Entry?]], columns: [UIView]) {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM")
        var previousMonth: Int?
        for (index, week) in weeks.enumerated() {
            guard let firstDay = week.compactMap({ $0 }).first?.start else { continue }
            let month = Calendar.current.component(.month, from: firstDay)
            defer { previousMonth = month }
            guard previousMonth != nil, month != previousMonth else { continue }
            let label = UILabel(fontSize: 10, weight: .semibold, color: Color.Grey500)
            label.text = formatter.string(from: firstDay)
            container.addAutoLayoutSubviews(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: columns[index].leadingAnchor),
                label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
        }
    }

    fileprivate static func makeLegend() -> UIView {
        let less = UILabel(fontSize: 10, weight: .semibold, color: Color.Grey500)
        less.text = "Less"
        let more = UILabel(fontSize: 10, weight: .semibold, color: Color.Grey500)
        more.text = "More"
        let swatches = levelColors.map { color -> UIView in
            let swatch = UIView()
            swatch.backgroundColor = color
            swatch.layer.cornerRadius = 2
            NSLayoutConstraint.activate([
                swatch.widthAnchor.constraint(equalToConstant: 10),
                swatch.heightAnchor.constraint(equalToConstant: 10)
            ])
            return swatch
        }
        let legend = UIStackView(arrangedSubviews: [less] + swatches + [more])
        legend.spacing = 3
        legend.alignment = .center
        legend.setCustomSpacing(5, after: less)
        legend.setCustomSpacing(5, after: swatches.last!)
        return legend
    }
}

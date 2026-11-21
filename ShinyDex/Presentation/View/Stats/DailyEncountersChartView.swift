import UIKit

final class DailyEncountersChartView: UIView {
    fileprivate static let barAreaHeight: CGFloat = 100
    fileprivate static let labelledDayInterval = 7

    init(days: [EncounterHistory.Day]) {
        super.init(frame: .zero)
        let maxCount = max(1, days.map { $0.count }.max() ?? 0)
        let lastIndex = days.count - 1
        let columns = UIStackView(arrangedSubviews: days.enumerated().map { index, day in
            let isLabelled = (lastIndex - index) % DailyEncountersChartView.labelledDayInterval == 0
            return DailyEncountersChartView.makeColumn(day, maxCount: maxCount, isToday: index == lastIndex, isLabelled: isLabelled)
        })
        columns.alignment = .bottom
        columns.distribution = .fillEqually
        columns.spacing = 2
        addAutoLayoutSubviews(columns)
        columns.pinEdges(to: self, insets: UIEdgeInsets(top: 12, left: 4, bottom: 8, right: 4))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate static func makeColumn(_ day: EncounterHistory.Day, maxCount: Int, isToday: Bool, isLabelled: Bool) -> UIView {
        let barView = UIView()
        barView.backgroundColor = day.count == 0 ? Color.Grey700 : isToday ? Color.Orange500 : Color.Orange700
        barView.layer.cornerRadius = 2
        barView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let barArea = UIView()
        barArea.addAutoLayoutSubviews(barView)
        let fraction = CGFloat(day.count) / CGFloat(maxCount)
        NSLayoutConstraint.activate([
            barArea.heightAnchor.constraint(equalToConstant: barAreaHeight),
            barView.bottomAnchor.constraint(equalTo: barArea.bottomAnchor),
            barView.leadingAnchor.constraint(equalTo: barArea.leadingAnchor),
            barView.trailingAnchor.constraint(equalTo: barArea.trailingAnchor),
            barView.heightAnchor.constraint(equalToConstant: max(2, barAreaHeight * fraction))
        ])

        let label = UILabel(fontSize: 10, weight: .semibold, color: isToday ? Color.Orange500 : Color.Grey500)
        label.text = isLabelled ? formatDayOfMonth(day.date) : " "
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5

        let column = UIStackView(arrangedSubviews: [barArea, label])
        column.axis = .vertical
        column.spacing = 4
        column.isAccessibilityElement = true
        column.accessibilityLabel = DateFormatter.localizedString(from: day.date, dateStyle: .medium, timeStyle: .none)
        column.accessibilityValue = day.count == 1 ? "1 encounter" : "\(day.count) encounters"
        return column
    }

    fileprivate static func formatDayOfMonth(_ date: Date) -> String {
        return String(Calendar.current.component(.day, from: date))
    }
}

import UIKit

final class YearComparisonChartView: UIView {
    struct Column {
        let month: Int
        let current: Int
        let previous: Int
        let isUpcoming: Bool
    }

    fileprivate static let barAreaHeight: CGFloat = 110
    fileprivate static let barWidth: CGFloat = 7

    init(columns: [Column], year: Int, previousYear: Int, noun: (Int) -> String, onSelect: ((Column) -> Void)? = nil) {
        super.init(frame: .zero)
        backgroundColor = Color.surface
        layer.cornerRadius = CornerRadius.standard

        let maxCount = max(1, columns.flatMap { [$0.isUpcoming ? 0 : $0.current, $0.previous] }.max() ?? 1)
        let calendar = Calendar.current
        let columnViews = UIStackView(arrangedSubviews: columns.map { column -> UIView in
            let content = YearComparisonChartView.makeColumn(column, maxCount: maxCount, calendar: calendar)
            content.accessibilityLabel = "\(calendar.monthSymbols[column.month - 1]): \(noun(column.current)) in \(year), \(noun(column.previous)) in \(previousYear)"
            guard let onSelect = onSelect, column.current > 0 || column.previous > 0 else { return content }
            return TappableColumn(content: content) { onSelect(column) }
        })
        columnViews.alignment = .bottom
        columnViews.distribution = .fillEqually
        columnViews.spacing = 2

        let legend = UIStackView(arrangedSubviews: [
            YearComparisonChartView.makeLegendItem(String(year), color: Color.accent),
            YearComparisonChartView.makeLegendItem(String(previousYear), color: Color.Grey500)
        ])
        legend.spacing = Spacing.medium

        let legendRow = UIStackView(arrangedSubviews: [legend, UIView()])
        let stack = UIStackView(arrangedSubviews: [legendRow, columnViews])
        stack.axis = .vertical
        stack.spacing = Spacing.medium
        addAutoLayoutSubviews(stack)
        stack.pinEdges(to: self, insets: UIEdgeInsets(top: 12, left: 8, bottom: 10, right: 8))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate static func makeColumn(_ column: Column, maxCount: Int, calendar: Calendar) -> UIView {
        let previousBar = makeBar(count: column.previous, maxCount: maxCount, color: Color.Grey500)
        let currentBar = makeBar(count: column.current, maxCount: maxCount, color: Color.accent)
        currentBar.alpha = column.isUpcoming ? 0 : 1
        let bars = UIStackView(arrangedSubviews: [currentBar, previousBar])
        bars.alignment = .bottom
        bars.spacing = 2
        let barArea = UIView()
        barArea.addAutoLayoutSubviews(bars)
        NSLayoutConstraint.activate([
            barArea.heightAnchor.constraint(equalToConstant: barAreaHeight),
            bars.bottomAnchor.constraint(equalTo: barArea.bottomAnchor),
            bars.topAnchor.constraint(greaterThanOrEqualTo: barArea.topAnchor),
            bars.centerXAnchor.constraint(equalTo: barArea.centerXAnchor)
        ])

        let label = UILabel(style: .caption2, weight: .semibold, color: column.isUpcoming ? Color.textQuaternary : Color.textTertiary)
        label.text = calendar.veryShortMonthSymbols[column.month - 1]
        label.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [barArea, label])
        stack.axis = .vertical
        stack.spacing = 4
        stack.isAccessibilityElement = true
        return stack
    }

    fileprivate static func makeBar(count: Int, maxCount: Int, color: UIColor) -> UIView {
        let bar = UIView()
        bar.backgroundColor = count == 0 ? Color.surfaceRaised : color
        bar.layer.cornerRadius = CornerRadius.tiny
        bar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let fraction = CGFloat(count) / CGFloat(maxCount)
        NSLayoutConstraint.activate([
            bar.widthAnchor.constraint(equalToConstant: barWidth),
            bar.heightAnchor.constraint(equalToConstant: max(2, barAreaHeight * fraction))
        ])
        return bar
    }

    fileprivate static func makeLegendItem(_ title: String, color: UIColor) -> UIView {
        let dot = UIView()
        dot.backgroundColor = color
        dot.layer.cornerRadius = CornerRadius.capsule(height: 8)
        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: 8),
            dot.heightAnchor.constraint(equalToConstant: 8)
        ])
        let label = UILabel(style: .caption1, weight: .semibold, color: Color.textSecondary)
        label.text = title
        let item = UIStackView(arrangedSubviews: [dot, label])
        item.alignment = .center
        item.spacing = 6
        return item
    }
}

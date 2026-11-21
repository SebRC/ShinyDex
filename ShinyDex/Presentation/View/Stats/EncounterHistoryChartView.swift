import UIKit

final class EncounterHistoryChartView: UIView {
    struct Bar {
        let label: String?
        let accessibilityLabel: String
        let count: Int
        let isCurrent: Bool
    }

    fileprivate static let barAreaHeight: CGFloat = 100
    fileprivate static let maxBarWidth: CGFloat = 32

    init(bars: [Bar]) {
        super.init(frame: .zero)
        let maxCount = max(1, bars.map { $0.count }.max() ?? 0)
        let columns = UIStackView(arrangedSubviews: bars.map { EncounterHistoryChartView.makeColumn($0, maxCount: maxCount) })
        columns.alignment = .bottom
        columns.distribution = .fillEqually
        columns.spacing = bars.count > 15 ? 2 : 6
        addAutoLayoutSubviews(columns)
        columns.pinEdges(to: self, insets: UIEdgeInsets(top: 12, left: 4, bottom: 8, right: 4))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate static func makeColumn(_ bar: Bar, maxCount: Int) -> UIView {
        let barView = UIView()
        barView.backgroundColor = bar.count == 0 ? Color.Grey700 : bar.isCurrent ? Color.Orange500 : Color.Orange700
        barView.layer.cornerRadius = 2
        barView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let barArea = UIView()
        barArea.addAutoLayoutSubviews(barView)
        let fraction = CGFloat(bar.count) / CGFloat(maxCount)
        let fillWidth = barView.widthAnchor.constraint(equalTo: barArea.widthAnchor)
        fillWidth.priority = .defaultHigh
        NSLayoutConstraint.activate([
            barArea.heightAnchor.constraint(equalToConstant: barAreaHeight),
            barView.bottomAnchor.constraint(equalTo: barArea.bottomAnchor),
            barView.centerXAnchor.constraint(equalTo: barArea.centerXAnchor),
            barView.widthAnchor.constraint(lessThanOrEqualToConstant: maxBarWidth),
            fillWidth,
            barView.heightAnchor.constraint(equalToConstant: max(2, barAreaHeight * fraction))
        ])

        let label = UILabel(fontSize: 10, weight: .semibold, color: bar.isCurrent ? Color.Orange500 : Color.Grey500)
        label.text = bar.label ?? " "
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5

        let column = UIStackView(arrangedSubviews: [barArea, label])
        column.axis = .vertical
        column.spacing = 4
        column.isAccessibilityElement = true
        column.accessibilityLabel = bar.accessibilityLabel
        column.accessibilityValue = bar.count == 1 ? "1 encounter" : "\(bar.count) encounters"
        return column
    }
}

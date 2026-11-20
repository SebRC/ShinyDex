import UIKit

final class PeriodChartView: UIView {
    struct Bar {
        let period: CatchPeriod
        let label: String
        let name: String
        let foundCount: Int
    }

    fileprivate static let barAreaHeight: CGFloat = 90
    let luckiestBars: [Bar]

    init(bars: [Bar], onSelect: @escaping (Bar) -> Void) {
        let maxCount = bars.map { $0.foundCount }.max() ?? 0
        luckiestBars = maxCount > 0 ? bars.filter { $0.foundCount == maxCount } : []
        super.init(frame: .zero)
        backgroundColor = Color.Grey800
        layer.cornerRadius = CornerRadius.standard

        let columns = UIStackView(arrangedSubviews: bars.map { bar -> UIView in
            let column = PeriodChartView.makeColumn(bar, maxCount: max(1, maxCount))
            guard bar.foundCount > 0 else { return column }
            return TappableColumn(content: column) { onSelect(bar) }
        })
        columns.alignment = .bottom
        columns.distribution = .fillEqually
        columns.spacing = 4
        addAutoLayoutSubviews(columns)
        columns.pinEdges(to: self, insets: UIEdgeInsets(top: 12, left: 10, bottom: 10, right: 10))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate static func makeColumn(_ bar: Bar, maxCount: Int) -> UIView {
        let isLuckiest = bar.foundCount == maxCount
        let countLabel = UILabel(fontSize: 11, weight: .semibold, color: isLuckiest ? Color.Grey100 : Color.Grey400)
        countLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 11, weight: .semibold)
        countLabel.text = bar.foundCount > 0 ? String(bar.foundCount) : " "
        countLabel.textAlignment = .center
        countLabel.adjustsFontSizeToFitWidth = true
        countLabel.minimumScaleFactor = 0.6

        let barView = UIView()
        barView.backgroundColor = bar.foundCount == 0 ? Color.Grey700 : isLuckiest ? Color.Orange500 : Color.Orange800
        barView.layer.cornerRadius = 4
        barView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let barArea = UIView()
        barArea.addAutoLayoutSubviews(barView)
        let fraction = CGFloat(bar.foundCount) / CGFloat(maxCount)
        NSLayoutConstraint.activate([
            barArea.heightAnchor.constraint(equalToConstant: barAreaHeight),
            barView.bottomAnchor.constraint(equalTo: barArea.bottomAnchor),
            barView.centerXAnchor.constraint(equalTo: barArea.centerXAnchor),
            barView.widthAnchor.constraint(equalTo: barArea.widthAnchor, multiplier: 0.7),
            barView.heightAnchor.constraint(equalToConstant: max(3, barAreaHeight * fraction))
        ])

        let label = UILabel(fontSize: 11, weight: .semibold, color: isLuckiest ? Color.Orange500 : Color.Grey400)
        label.text = bar.label
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7

        let column = UIStackView(arrangedSubviews: [countLabel, barArea, label])
        column.axis = .vertical
        column.spacing = 4
        column.isAccessibilityElement = true
        column.accessibilityLabel = "\(bar.name): \(bar.foundCount == 1 ? "1 shiny" : "\(bar.foundCount) shinies")"
        return column
    }
}

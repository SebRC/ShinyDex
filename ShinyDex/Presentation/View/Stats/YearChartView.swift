import UIKit

final class YearChartView: UIView {
    fileprivate static let barAreaHeight: CGFloat = 140

    init(years: [CatchStatistics.Year], onSelectYear: @escaping (Int) -> Void) {
        super.init(frame: .zero)
        backgroundColor = Color.surface
        layer.cornerRadius = CornerRadius.standard

        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        let columns = UIStackView()
        columns.alignment = .bottom
        columns.spacing = 14
        let maxAverage = max(1, years.compactMap { $0.averageEncounters }.max() ?? 1)
        for year in years {
            columns.addArrangedSubview(TappableColumn(content: YearChartView.makeColumn(year, maxAverage: maxAverage)) {
                onSelectYear(year.year)
            })
        }
        addAutoLayoutSubviews(scrollView)
        scrollView.addAutoLayoutSubviews(columns)
        scrollView.pinEdges(to: self, insets: UIEdgeInsets(top: 14, left: 0, bottom: 12, right: 0))
        NSLayoutConstraint.activate([
            columns.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            columns.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            columns.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 14),
            columns.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -14),
            columns.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
            columns.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.widthAnchor, constant: -28)
        ])
        columns.distribution = .fillEqually
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate static func makeColumn(_ year: CatchStatistics.Year, maxAverage: Int) -> UIView {
        let valueLabel = UILabel(style: .caption1, weight: .semibold, color: Color.textPrimary)
        valueLabel.text = year.averageEncounters.map { $0.grouped } ?? "–"
        valueLabel.textAlignment = .center
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.7

        let bar = UIView()
        bar.backgroundColor = year.averageEncounters == nil ? Color.surfaceRaised : Color.accent
        bar.layer.cornerRadius = CornerRadius.tiny
        bar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let barArea = UIView()
        barArea.addAutoLayoutSubviews(bar)
        let fraction = CGFloat(year.averageEncounters ?? 0) / CGFloat(maxAverage)
        NSLayoutConstraint.activate([
            barArea.heightAnchor.constraint(equalToConstant: barAreaHeight),
            bar.bottomAnchor.constraint(equalTo: barArea.bottomAnchor),
            bar.centerXAnchor.constraint(equalTo: barArea.centerXAnchor),
            bar.widthAnchor.constraint(equalToConstant: 28),
            bar.heightAnchor.constraint(equalToConstant: max(4, barAreaHeight * fraction))
        ])

        let yearLabel = UILabel(style: .footnote, weight: .semibold)
        yearLabel.text = String(year.year)
        yearLabel.textAlignment = .center
        let countLabel = UILabel(style: .caption2, color: Color.textTertiary)
        countLabel.text = year.foundCount == 1 ? "1 shiny" : "\(year.foundCount) shinies"
        countLabel.textAlignment = .center

        let column = UIStackView(arrangedSubviews: [valueLabel, barArea, yearLabel, countLabel])
        column.axis = .vertical
        column.spacing = 4
        column.widthAnchor.constraint(greaterThanOrEqualToConstant: 56).isActive = true
        column.isAccessibilityElement = true
        column.accessibilityLabel = "\(year.year): \(countLabel.text ?? ""), " + (year.averageEncounters.map { "average \($0) encounters" } ?? "no encounters logged")
        return column
    }
}

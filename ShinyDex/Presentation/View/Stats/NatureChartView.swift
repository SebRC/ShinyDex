import UIKit

final class NatureChartView: UIView {
    fileprivate static let headerWidth: CGFloat = 36
    fileprivate static let cellHeight: CGFloat = 50
    fileprivate static let spacing: CGFloat = 4

    init(usage: [CatchStatistics.Usage<Nature>], onSelect: @escaping (Nature) -> Void) {
        super.init(frame: .zero)
        backgroundColor = Color.surface
        layer.cornerRadius = CornerRadius.standard

        let countsByNature = Dictionary(uniqueKeysWithValues: usage.map { ($0.key, $0.count) })
        let maxCount = max(1, usage.map { $0.count }.max() ?? 1)
        let columnHeaders = Nature.gridStats.map { NatureChartView.makeHeaderLabel(text: "−\($0.shortName)", color: Color.textTertiary) }
        let rows = Nature.grid.enumerated().map { rowIndex, natures -> UIView in
            let header = NatureChartView.makeHeaderLabel(text: "+\(Nature.gridStats[rowIndex].shortName)", color: Color.accent)
            let cells = natures.map { nature -> UIView in
                let count = countsByNature[nature] ?? 0
                let cell = NatureChartView.makeCell(nature, count: count, maxCount: maxCount)
                guard count > 0 else { return cell }
                return TappableColumn(content: cell) { onSelect(nature) }
            }
            return NatureChartView.makeGridRow(header: header, cells: cells)
        }
        let grid = UIStackView(arrangedSubviews: [NatureChartView.makeGridRow(header: UIView(), cells: columnHeaders)] + rows)
        grid.axis = .vertical
        grid.spacing = NatureChartView.spacing
        addAutoLayoutSubviews(grid)
        grid.pinEdges(to: self, insets: UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 10))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate static func makeGridRow(header: UIView, cells: [UIView]) -> UIView {
        header.widthAnchor.constraint(equalToConstant: headerWidth).isActive = true
        let cellStack = UIStackView(arrangedSubviews: cells)
        cellStack.distribution = .fillEqually
        cellStack.spacing = spacing
        let row = UIStackView(arrangedSubviews: [header, cellStack])
        row.spacing = spacing
        row.alignment = .center
        return row
    }

    fileprivate static func makeHeaderLabel(text: String, color: UIColor) -> UILabel {
        let label = UILabel(style: .caption2, weight: .bold, color: color)
        label.text = text
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.isAccessibilityElement = false
        return label
    }

    fileprivate static func makeCell(_ nature: Nature, count: Int, maxCount: Int) -> UIView {
        let isMostCommon = count == maxCount
        let cell = UIView()
        cell.backgroundColor = selectBackgroundColor(count: count, maxCount: maxCount)
        cell.layer.cornerRadius = CornerRadius.small
        if count == 0 {
            cell.layer.borderWidth = 1
            cell.layer.borderColor = Color.surfaceRaised.cgColor
        }

        let nameLabel = UILabel(style: .caption2, weight: .semibold, color: isMostCommon ? Color.background : count > 0 ? Color.textPrimary : Color.textQuaternary)
        nameLabel.text = nature.name
        nameLabel.textAlignment = .center
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.6
        let countLabel = UILabel(style: .footnote, weight: .bold, color: nameLabel.textColor)
        countLabel.font = UIFont.make(.footnote, weight: .bold, monospacedDigits: true)
        countLabel.text = count > 0 ? String(count) : "–"
        countLabel.textAlignment = .center
        countLabel.adjustsFontSizeToFitWidth = true
        countLabel.minimumScaleFactor = 0.6

        let labels = UIStackView(arrangedSubviews: [nameLabel, countLabel])
        labels.axis = .vertical
        labels.spacing = 1
        cell.addAutoLayoutSubviews(labels)
        NSLayoutConstraint.activate([
            cell.heightAnchor.constraint(equalToConstant: cellHeight),
            labels.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            labels.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 2),
            labels.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -2)
        ])
        cell.isAccessibilityElement = true
        cell.accessibilityLabel = "\(nature.name), \(nature.effectSummary): \(count == 1 ? "1 shiny" : "\(count) shinies")"
        return cell
    }

    fileprivate static func selectBackgroundColor(count: Int, maxCount: Int) -> UIColor {
        guard count > 0 else { return Color.surface }
        guard count < maxCount else { return Color.accent }
        let fraction = Double(count) / Double(maxCount)
        return fraction > 0.5 ? Color.Orange700 : Color.Orange800
    }
}

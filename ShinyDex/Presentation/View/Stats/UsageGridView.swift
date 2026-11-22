import UIKit

struct UsageGridItem {
    let title: String
    let image: UIImage?
    let count: Int
    let filter: CollectionFilter
}

final class UsageGridView: UIView {
    fileprivate static let cellHeight: CGFloat = 86
    fileprivate static let iconSize: CGFloat = 34
    fileprivate static let spacing: CGFloat = 4

    init(items: [UsageGridItem], columns: Int = 4, onSelect: @escaping (CollectionFilter) -> Void) {
        super.init(frame: .zero)
        backgroundColor = Color.surface
        layer.cornerRadius = CornerRadius.standard

        let maxCount = max(1, items.map { $0.count }.max() ?? 1)
        let cells = items.map { item -> UIView in
            let cell = UsageGridView.makeCell(item, maxCount: maxCount)
            guard item.count > 0 else { return cell }
            return TappableColumn(content: cell) { onSelect(item.filter) }
        }
        let rows = stride(from: 0, to: cells.count, by: columns).map { start -> UIView in
            let rowCells = Array(cells[start..<min(start + columns, cells.count)])
            let row = UIStackView(arrangedSubviews: rowCells + (0..<(columns - rowCells.count)).map { _ in UIView() })
            row.distribution = .fillEqually
            row.spacing = UsageGridView.spacing
            return row
        }
        let grid = UIStackView(arrangedSubviews: rows)
        grid.axis = .vertical
        grid.spacing = UsageGridView.spacing
        addAutoLayoutSubviews(grid)
        grid.pinEdges(to: self, insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate static func makeCell(_ item: UsageGridItem, maxCount: Int) -> UIView {
        let isMostUsed = item.count == maxCount
        let cell = UIView()
        cell.backgroundColor = selectBackgroundColor(count: item.count, maxCount: maxCount)
        cell.layer.cornerRadius = CornerRadius.small
        if item.count == 0 {
            cell.layer.borderWidth = 1
            cell.layer.borderColor = Color.surfaceRaised.cgColor
        }

        let icon = UIImageView(image: item.image)
        icon.contentMode = .scaleAspectFit
        icon.layer.magnificationFilter = .nearest
        icon.alpha = item.count > 0 ? 1 : 0.3
        let textColor = isMostUsed ? Color.background : item.count > 0 ? Color.textPrimary : Color.textQuaternary
        let nameLabel = UILabel(style: .caption2, weight: .semibold, color: textColor)
        nameLabel.text = item.title
        nameLabel.textAlignment = .center
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.6
        let countLabel = UILabel(style: .footnote, weight: .bold, color: textColor)
        countLabel.font = UIFont.make(.footnote, weight: .bold, monospacedDigits: true)
        countLabel.text = item.count > 0 ? String(item.count) : "–"
        countLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [icon, nameLabel, countLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 2
        cell.addAutoLayoutSubviews(stack)
        NSLayoutConstraint.activate([
            cell.heightAnchor.constraint(equalToConstant: cellHeight),
            icon.widthAnchor.constraint(equalToConstant: iconSize),
            icon.heightAnchor.constraint(equalToConstant: iconSize),
            stack.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 3),
            stack.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -3),
            nameLabel.widthAnchor.constraint(equalTo: stack.widthAnchor)
        ])
        cell.isAccessibilityElement = true
        cell.accessibilityLabel = "\(item.title): \(item.count == 0 ? "none yet" : item.count == 1 ? "1 shiny" : "\(item.count) shinies")"
        return cell
    }

    fileprivate static func selectBackgroundColor(count: Int, maxCount: Int) -> UIColor {
        guard count > 0 else { return Color.surface }
        guard count < maxCount else { return Color.accent }
        return Double(count) / Double(maxCount) > 0.5 ? Color.Orange700 : Color.Orange800
    }
}

import UIKit

final class TypeCoverageView: UIView {
    static let columns = 3

    fileprivate let rows = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        rows.axis = .vertical
        rows.spacing = Spacing.small
        addAutoLayoutSubviews(rows)
        rows.pinEdges(to: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(coverage: [TypeCoverage]) {
        rows.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for start in stride(from: 0, to: coverage.count, by: TypeCoverageView.columns) {
            let badges = coverage[start..<min(start + TypeCoverageView.columns, coverage.count)].map { item -> UIView in
                let badge = TypeBadge(type: item.type, text: item.hitters > 0 ? "\(item.type.name) ×\(item.hitters)" : item.type.name, isFaded: item.hitters == 0)
                badge.accessibilityLabel = item.hitters == 0 ? "\(item.type.name), not covered" : "\(item.type.name), \(item.hitters) super effective"
                return badge
            }
            let row = UIStackView(arrangedSubviews: badges)
            row.distribution = .fillEqually
            row.spacing = Spacing.small
            rows.addArrangedSubview(row)
        }
    }
}

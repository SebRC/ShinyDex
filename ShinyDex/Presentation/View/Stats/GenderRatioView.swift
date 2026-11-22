import UIKit

final class GenderRatioView: UIView {
    fileprivate static let barHeight: CGFloat = 14
    fileprivate static let segmentGap: CGFloat = 2

    init(counts: [Gender: Int], onSelect: @escaping (Gender) -> Void) {
        super.init(frame: .zero)
        backgroundColor = Color.surface
        layer.cornerRadius = CornerRadius.standard

        let genders = Gender.allCases
        let total = genders.reduce(0) { $0 + (counts[$1] ?? 0) }
        let legendItems = genders.map { gender -> UIView in
            let count = counts[gender] ?? 0
            let item = GenderRatioView.makeLegendItem(gender, count: count, total: total)
            guard count > 0 else { return item }
            return TappableColumn(content: item) { onSelect(gender) }
        }
        let legend = UIStackView(arrangedSubviews: legendItems)
        legend.distribution = .equalSpacing
        legend.alignment = .center
        let stack = UIStackView(arrangedSubviews: [GenderRatioView.makeBar(counts: genders.map { ($0, counts[$0] ?? 0) }), legend])
        stack.axis = .vertical
        stack.spacing = 14
        addAutoLayoutSubviews(stack)
        stack.pinEdges(to: self, insets: UIEdgeInsets(top: Spacing.large, left: 14, bottom: Spacing.medium, right: 14))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate static func makeBar(counts: [(Gender, Int)]) -> UIView {
        let track = UIView()
        track.backgroundColor = Color.surfaceRaised
        track.layer.cornerRadius = CornerRadius.capsule(height: barHeight)
        track.clipsToBounds = true
        track.isAccessibilityElement = false
        let used = counts.filter { $0.1 > 0 }
        let segments = used.map { gender, _ -> UIView in
            let segment = UIView()
            segment.backgroundColor = gender.color
            return segment
        }
        let row = UIStackView(arrangedSubviews: segments)
        row.spacing = segmentGap
        track.addAutoLayoutSubviews(row)
        row.pinEdges(to: track)
        track.heightAnchor.constraint(equalToConstant: barHeight).isActive = true
        for (index, segment) in segments.enumerated().dropFirst() {
            segment.widthAnchor.constraint(equalTo: segments[0].widthAnchor, multiplier: CGFloat(used[index].1) / CGFloat(used[0].1)).isActive = true
        }
        return track
    }

    fileprivate static func makeLegendItem(_ gender: Gender, count: Int, total: Int) -> UIView {
        let icon = UIImageView(image: gender.makeSymbolImage(style: .title3))
        icon.contentMode = .scaleAspectFit
        let nameLabel = UILabel(style: .subheadline, weight: .semibold, color: count > 0 ? Color.textPrimary : Color.textQuaternary)
        nameLabel.text = gender.name
        let percent = total > 0 ? Int((Double(count) / Double(total) * 100).rounded()) : 0
        let valueLabel = UILabel(style: .footnote, color: Color.textTertiary)
        valueLabel.font = UIFont.make(.footnote, monospacedDigits: true)
        valueLabel.text = count > 0 ? "\(count) · \(percent)%" : "–"
        let labels = UIStackView(arrangedSubviews: [nameLabel, valueLabel])
        labels.axis = .vertical
        let item = UIStackView(arrangedSubviews: [icon, labels])
        item.spacing = 6
        item.alignment = .center
        item.alpha = count > 0 ? 1 : 0.5
        icon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        item.isAccessibilityElement = true
        item.accessibilityLabel = count > 0 ? "\(gender.name): \(count == 1 ? "1 shiny" : "\(count) shinies"), \(percent) percent" : "\(gender.name): none yet"
        let wrapper = UIView()
        wrapper.addAutoLayoutSubviews(item)
        item.pinEdges(to: wrapper, insets: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
        wrapper.accessibilityLabel = item.accessibilityLabel
        return wrapper
    }
}

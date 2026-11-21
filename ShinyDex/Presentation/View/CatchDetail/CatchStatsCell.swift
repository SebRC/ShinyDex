import UIKit

final class CatchStatsCell: UITableViewCell {
    static let reuseIdentifier = "catchStatsCell"

    fileprivate let encountersValue = UILabel(style: .title2, weight: .bold, color: Color.textPrimary)
    fileprivate let oddsValue = UILabel(style: .title2, weight: .bold, color: Color.textPrimary)
    fileprivate let luckLabel = UILabel(style: .subheadline, weight: .medium, color: Color.accent, lines: 0)
    fileprivate let luckRow = UIStackView()
    fileprivate let luckBanner = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        let tiles = UIStackView(arrangedSubviews: [
            CatchStatsCell.makeTile(caption: "ENCOUNTERS", value: encountersValue),
            CatchStatsCell.makeTile(caption: "ODDS", value: oddsValue)
        ])
        tiles.distribution = .fillEqually
        tiles.spacing = 12

        let star = UIImageView(image: UIImage.makeSymbol("star.fill", pointSize: 14))
        star.tintColor = Color.accent
        star.contentMode = .center
        star.setContentHuggingPriority(.required, for: .horizontal)
        star.setContentCompressionResistancePriority(.required, for: .horizontal)
        star.widthAnchor.constraint(equalToConstant: 18).isActive = true
        luckLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        luckRow.addArrangedSubview(star)
        luckRow.addArrangedSubview(luckLabel)
        luckRow.spacing = 8
        luckRow.alignment = .center
        luckRow.isLayoutMarginsRelativeArrangement = true
        luckRow.layoutMargins = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
        luckBanner.backgroundColor = Color.accentSubtle
        luckBanner.layer.cornerRadius = CornerRadius.standard
        luckBanner.addAutoLayoutSubviews(luckRow)
        luckRow.pinEdges(to: luckBanner)

        let stack = UIStackView(arrangedSubviews: [tiles, luckBanner])
        stack.axis = .vertical
        stack.spacing = 12
        contentView.addAutoLayoutSubviews(stack)
        stack.pinEdges(to: contentView, insets: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate static func makeTile(caption: String, value: UILabel) -> UIView {
        let tile = UIView()
        tile.backgroundColor = Color.surface
        tile.layer.cornerRadius = CornerRadius.standard
        tile.isAccessibilityElement = true
        let captionLabel = UILabel(style: .caption1, weight: .semibold, color: Color.textTertiary)
        captionLabel.text = caption
        value.font = UIFont.make(.title2, weight: .bold, monospacedDigits: true)
        value.adjustsFontSizeToFitWidth = true
        value.minimumScaleFactor = 0.6
        let stack = UIStackView(arrangedSubviews: [captionLabel, value])
        stack.axis = .vertical
        stack.spacing = 2
        tile.addAutoLayoutSubviews(stack)
        stack.pinEdges(to: tile, insets: UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14))
        return tile
    }

    func configure(encounters: String, odds: String, luck: String?) {
        encountersValue.text = encounters
        oddsValue.text = odds
        encountersValue.superview?.superview?.accessibilityLabel = "Encounters \(encounters)"
        oddsValue.superview?.superview?.accessibilityLabel = "Odds \(odds)"
        luckLabel.text = luck
        luckBanner.isHidden = luck == nil
    }
}

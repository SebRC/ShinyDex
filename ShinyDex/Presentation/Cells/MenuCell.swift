import UIKit

class MenuCell: UITableViewCell {
	static let regionImageSize = CGSize(width: 112, height: 47)

	static let reuseIdentifier = "menuCell"

	let generationImage = UIImageView()
	let generationLabel = UILabel(style: .title3, weight: .semibold)
	fileprivate let subtitleLabel = UILabel(style: .footnote, color: Color.textTertiary)
	fileprivate let progressBar = UIProgressView(progressViewStyle: .default)
	fileprivate var imageWidth: NSLayoutConstraint!
	fileprivate var imageHeight: NSLayoutConstraint!

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = Color.surface
		let selectedBackground = UIView()
		selectedBackground.backgroundColor = Color.surfaceRaised
		selectedBackgroundView = selectedBackground
		accessoryType = .disclosureIndicator
		generationImage.contentMode = .scaleAspectFit
		generationImage.layer.magnificationFilter = .nearest
		generationImage.isAccessibilityElement = false
		generationImage.tintColor = Color.accent
		generationLabel.adjustsFontSizeToFitWidth = true
		generationLabel.minimumScaleFactor = 0.8
		subtitleLabel.adjustsFontSizeToFitWidth = true
		subtitleLabel.minimumScaleFactor = 0.8
		progressBar.progressTintColor = Color.accent
		progressBar.trackTintColor = Color.surfaceRaised
		progressBar.layer.cornerRadius = CornerRadius.tiny
		progressBar.clipsToBounds = true

		let labels = UIStackView(arrangedSubviews: [generationLabel, subtitleLabel, progressBar])
		labels.axis = .vertical
		labels.spacing = 3
		labels.setCustomSpacing(8, after: subtitleLabel)
		let row = UIStackView(arrangedSubviews: [generationImage, labels])
		row.alignment = .center
		row.spacing = 10
		contentView.addAutoLayoutSubviews(row)
		imageWidth = generationImage.widthAnchor.constraint(equalToConstant: MenuCell.regionImageSize.width)
		imageHeight = generationImage.heightAnchor.constraint(equalToConstant: MenuCell.regionImageSize.height)
		NSLayoutConstraint.activate([
			row.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: -4),
			row.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
			row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
			row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
			imageWidth,
			imageHeight,
			progressBar.heightAnchor.constraint(equalToConstant: 4)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(title: String, subtitle: String, image: UIImage?, progress: Float?) {
		generationLabel.text = title
		subtitleLabel.text = subtitle
		generationImage.image = image
		let isRegion = progress != nil
		imageWidth.constant = isRegion ? MenuCell.regionImageSize.width : 56
		imageHeight.constant = isRegion ? MenuCell.regionImageSize.height : 56
		progressBar.isHidden = !isRegion
		progressBar.progress = progress ?? 0
		accessibilityLabel = "\(title), \(subtitle)"
		accessibilityTraits = .button
	}
}

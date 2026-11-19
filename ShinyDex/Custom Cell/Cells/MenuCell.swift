import UIKit

/// A main menu row: artwork on the left, a title with a live subtitle (hunt totals, catches, region progress),
/// an optional progress bar for regions, and a chevron.
class MenuCell: UITableViewCell {
	static let reuseIdentifier = "menuCell"

	let generationImage = UIImageView()
	let generationLabel = UILabel(fontSize: 20, weight: .semibold)
	fileprivate let subtitleLabel = UILabel(fontSize: 13, color: Color.Grey400)
	fileprivate let progressBar = UIProgressView(progressViewStyle: .default)
	fileprivate var imageWidth: NSLayoutConstraint!
	fileprivate var imageHeight: NSLayoutConstraint!

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = Color.Grey800
		let selectedBackground = UIView()
		selectedBackground.backgroundColor = Color.Grey700
		selectedBackgroundView = selectedBackground
		accessoryType = .disclosureIndicator
		generationImage.contentMode = .scaleAspectFit
		generationImage.layer.magnificationFilter = .nearest
		generationImage.isAccessibilityElement = false
		generationImage.tintColor = Color.Orange500
		generationLabel.adjustsFontSizeToFitWidth = true
		generationLabel.minimumScaleFactor = 0.8
		subtitleLabel.adjustsFontSizeToFitWidth = true
		subtitleLabel.minimumScaleFactor = 0.8
		progressBar.progressTintColor = Color.Orange500
		progressBar.trackTintColor = Color.Grey700
		progressBar.layer.cornerRadius = 2
		progressBar.clipsToBounds = true

		let labels = UIStackView(arrangedSubviews: [generationLabel, subtitleLabel, progressBar])
		labels.axis = .vertical
		labels.spacing = 3
		labels.setCustomSpacing(8, after: subtitleLabel)
		let row = UIStackView(arrangedSubviews: [generationImage, labels])
		row.alignment = .center
		row.spacing = 10
		contentView.addAutoLayoutSubviews(row)
		imageWidth = generationImage.widthAnchor.constraint(equalToConstant: 112)
		imageHeight = generationImage.heightAnchor.constraint(equalToConstant: 47)
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

	/// Tracking tools show a square icon; regions show their wide group artwork with a progress bar.
	func configure(title: String, subtitle: String, image: UIImage?, progress: Float?) {
		generationLabel.text = title
		subtitleLabel.text = subtitle
		generationImage.image = image
		let isRegion = progress != nil
		imageWidth.constant = isRegion ? 112 : 56
		imageHeight.constant = isRegion ? 47 : 56
		progressBar.isHidden = !isRegion
		progressBar.progress = progress ?? 0
		accessibilityLabel = "\(title), \(subtitle)"
		accessibilityTraits = .button
	}
}

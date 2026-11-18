import UIKit

class CatchCell: UITableViewCell {
	static let reuseIdentifier = "catchCell"
	static let height: CGFloat = 65

	fileprivate let sprite = UIImageView()
	fileprivate let titleLabel = UILabel()
	fileprivate let subtitleLabel = UILabel()
	fileprivate let ballImageView = UIImageView()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = Color.Grey800
		contentView.clipsToBounds = true
		sprite.contentMode = .scaleAspectFit
		ballImageView.contentMode = .scaleAspectFit
		titleLabel.font = UIFont.systemFont(ofSize: 20)
		titleLabel.textColor = Color.Grey200
		subtitleLabel.font = UIFont.systemFont(ofSize: 15)
		subtitleLabel.textColor = Color.Grey200

		let labels = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
		labels.axis = .vertical
		labels.spacing = 6

		for subview in [sprite, labels, ballImageView] {
			subview.translatesAutoresizingMaskIntoConstraints = false
			contentView.addSubview(subview)
		}
		NSLayoutConstraint.activate([
			sprite.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1),
			sprite.bottomAnchor.constraint(equalTo: ballImageView.bottomAnchor),
			sprite.widthAnchor.constraint(equalToConstant: 79),
			sprite.heightAnchor.constraint(equalToConstant: 79),

			labels.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 85),
			labels.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			labels.trailingAnchor.constraint(lessThanOrEqualTo: ballImageView.leadingAnchor, constant: -8),

			ballImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
			ballImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			ballImageView.widthAnchor.constraint(equalToConstant: 59),
			ballImageView.heightAnchor.constraint(equalToConstant: 59)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(pokemon: Pokemon, title: String, subtitle: String, ball: String) {
		sprite.image = UIImage(named: pokemon.name.lowercased())
		titleLabel.text = title
		subtitleLabel.text = subtitle
		ballImageView.image = UIImage(named: ball)
	}
}

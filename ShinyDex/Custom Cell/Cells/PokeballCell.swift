import UIKit

class PokeballCell: UITableViewCell {
	static let reuseIdentifier = "pokeballCell"
	static let imageSize: CGFloat = 50

	let pokeballImageView = UIImageView()
	let nameLabel = UILabel()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		nameLabel.font = UIFont.systemFont(ofSize: 23)
		nameLabel.textColor = Color.Grey200
		pokeballImageView.contentMode = .scaleAspectFit
		pokeballImageView.clipsToBounds = true
		pokeballImageView.layer.cornerRadius = PokeballCell.imageSize / 2

		for subview in [nameLabel, pokeballImageView] {
			subview.translatesAutoresizingMaskIntoConstraints = false
			contentView.addSubview(subview)
		}
		NSLayoutConstraint.activate([
			nameLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
			nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: pokeballImageView.leadingAnchor, constant: -16),
			pokeballImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			pokeballImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			pokeballImageView.widthAnchor.constraint(equalToConstant: PokeballCell.imageSize),
			pokeballImageView.heightAnchor.constraint(equalToConstant: PokeballCell.imageSize)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(pokeball: Pokeball, title: String, isCurrentBall: Bool) {
		pokeballImageView.image = pokeball.image
		nameLabel.text = title
		pokeballImageView.backgroundColor = isCurrentBall ? Color.Grey900 : .none
		pokeballImageView.layer.borderWidth = isCurrentBall ? 2 : 0
		pokeballImageView.layer.borderColor = isCurrentBall ? Color.Orange500.cgColor : UIColor.clear.cgColor
	}
}

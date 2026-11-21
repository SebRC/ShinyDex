import UIKit

final class YearInReviewCardView: UIView {
    struct Content {
        var eyebrow: String
        var image: UIImage?
        var isPixelArt = true
        var headline: String
        var title: String
        var message: String?
        var rows: [(title: String, value: String)] = []
    }

    fileprivate static let imageSize: CGFloat = 150

    init(content: Content, footer: String) {
        super.init(frame: .zero)
        backgroundColor = Color.Grey800
        layer.cornerRadius = 20
        clipsToBounds = true

        let eyebrowLabel = UILabel(fontSize: 13, weight: .bold, color: Color.Orange500)
        eyebrowLabel.text = content.eyebrow.uppercased()
        eyebrowLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [eyebrowLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8

        if let image = content.image {
            let imageView = UIImageView(image: image)
            imageView.contentMode = content.isPixelArt ? .scaleAspectFit : .center
            imageView.tintColor = Color.Orange500
            if content.isPixelArt {
                imageView.layer.magnificationFilter = .nearest
            }
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: YearInReviewCardView.imageSize),
                imageView.heightAnchor.constraint(equalToConstant: YearInReviewCardView.imageSize)
            ])
            stack.addArrangedSubview(imageView)
        }

        let headlineLabel = UILabel(fontSize: 52, weight: .heavy, color: Color.Grey100)
        headlineLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 52, weight: .heavy)
        headlineLabel.text = content.headline
        headlineLabel.textAlignment = .center
        headlineLabel.adjustsFontSizeToFitWidth = true
        headlineLabel.minimumScaleFactor = 0.4
        stack.addArrangedSubview(headlineLabel)

        let titleLabel = UILabel(fontSize: 20, weight: .semibold, color: Color.Grey200, lines: 0)
        titleLabel.text = content.title
        titleLabel.textAlignment = .center
        stack.addArrangedSubview(titleLabel)

        if let message = content.message {
            let messageLabel = UILabel(fontSize: 15, color: Color.Grey400, lines: 0)
            messageLabel.text = message
            messageLabel.textAlignment = .center
            stack.setCustomSpacing(12, after: titleLabel)
            stack.addArrangedSubview(messageLabel)
        }

        if !content.rows.isEmpty {
            let rows = UIStackView(arrangedSubviews: content.rows.map(YearInReviewCardView.makeRow))
            rows.axis = .vertical
            rows.spacing = 10
            stack.setCustomSpacing(20, after: stack.arrangedSubviews.last!)
            stack.addArrangedSubview(rows)
            rows.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        }

        let footerLabel = UILabel(fontSize: 12, weight: .semibold, color: Color.Grey500)
        footerLabel.text = footer
        footerLabel.textAlignment = .center

        addAutoLayoutSubviews(stack, footerLabel)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -12),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            stack.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 24),
            footerLabel.topAnchor.constraint(greaterThanOrEqualTo: stack.bottomAnchor, constant: 16),
            footerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            footerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18)
        ])

        isAccessibilityElement = true
        accessibilityLabel = ([content.eyebrow, content.headline, content.title, content.message].compactMap { $0 }
            + content.rows.map { "\($0.title): \($0.value)" }).joined(separator: ". ")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func renderImage() -> UIImage {
        return UIGraphicsImageRenderer(bounds: bounds).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }

    fileprivate static func makeRow(_ row: (title: String, value: String)) -> UIView {
        let titleLabel = UILabel(fontSize: 15, weight: .semibold, color: Color.Grey400)
        titleLabel.text = row.title
        let valueLabel = UILabel(fontSize: 17, weight: .semibold, color: Color.Grey100)
        valueLabel.text = row.value
        valueLabel.textAlignment = .right
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.6
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        let row = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        row.spacing = 12
        return row
    }
}

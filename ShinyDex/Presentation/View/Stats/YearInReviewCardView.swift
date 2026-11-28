import UIKit

final class YearInReviewCardView: UIView {
    struct Content {
        var eyebrow: String
        var image: UIImage?
        var follower: OverworldSheet? = nil
        var podiumImages: [UIImage] = []
        var isPixelArt = true
        var headline: String
        var title: String
        var message: String?
        var rows: [Row] = []
    }

    struct Row {
        var image: UIImage?
        let title: String
        let value: String
    }

    fileprivate static let imageSize: CGFloat = 150
    fileprivate static let podiumWinnerSize: CGFloat = 110
    fileprivate static let podiumRunnerUpSize: CGFloat = 76
    fileprivate static let followerPixelScale: CGFloat = 2
    fileprivate static let followerOverlap: CGFloat = 16

    init(content: Content, footer: String) {
        super.init(frame: .zero)
        backgroundColor = Color.surface
        layer.cornerRadius = CornerRadius.large
        clipsToBounds = true

        let eyebrowLabel = UILabel(style: .footnote, weight: .bold, color: Color.accent)
        eyebrowLabel.text = content.eyebrow.uppercased()
        eyebrowLabel.textAlignment = .center

        var followerAnchor: UIView?
        let stack = UIStackView(arrangedSubviews: [eyebrowLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8

        if !content.podiumImages.isEmpty {
            stack.addArrangedSubview(YearInReviewCardView.makePodium(content.podiumImages))
        }
        else if let image = content.image {
            let imageView = UIImageView(image: image)
            imageView.contentMode = content.isPixelArt ? .scaleAspectFit : .center
            imageView.tintColor = Color.accent
            if content.isPixelArt {
                imageView.layer.magnificationFilter = .nearest
            }
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: YearInReviewCardView.imageSize),
                imageView.heightAnchor.constraint(equalToConstant: YearInReviewCardView.imageSize)
            ])
            stack.addArrangedSubview(imageView)
            followerAnchor = imageView
        }

        let headlineLabel = UILabel(style: .hero, weight: .heavy, color: Color.textPrimary)
        headlineLabel.font = UIFont.make(.hero, weight: .heavy, monospacedDigits: true)
        headlineLabel.text = content.headline
        headlineLabel.textAlignment = .center
        headlineLabel.adjustsFontSizeToFitWidth = true
        headlineLabel.minimumScaleFactor = 0.4
        stack.addArrangedSubview(headlineLabel)

        let titleLabel = UILabel(style: .title3, weight: .semibold, color: Color.textPrimary, lines: 0)
        titleLabel.text = content.title
        titleLabel.textAlignment = .center
        stack.addArrangedSubview(titleLabel)

        if let message = content.message {
            let messageLabel = UILabel(style: .subheadline, color: Color.textTertiary, lines: 0)
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

        let footerLabel = UILabel(style: .caption1, weight: .semibold, color: Color.textQuaternary)
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
        if let sheet = content.follower, let imageView = followerAnchor {
            let follower = FollowerView(sheet: sheet, pixelScale: YearInReviewCardView.followerPixelScale)
            addAutoLayoutSubviews(follower)
            NSLayoutConstraint.activate([
                follower.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -YearInReviewCardView.followerOverlap),
                follower.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: YearInReviewCardView.findFeetHeight(of: content.image))
            ])
        }

        isAccessibilityElement = true
        accessibilityLabel = ([content.eyebrow, content.headline, content.title, content.message].compactMap { $0 }
            + content.rows.map { "\($0.title): \($0.value)" }).joined(separator: ". ")
    }

    fileprivate static func findFeetHeight(of image: UIImage?) -> CGFloat {
        guard let image = image, image.size.width > 0, image.size.height > 0 else { return imageSize }
        let fittedHeight = image.size.height * min(imageSize / image.size.width, imageSize / image.size.height)
        return ((imageSize - fittedHeight) / 2 + fittedHeight * (image.findVisibleBottomFraction() ?? 1)).rounded()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func renderImage() -> UIImage {
        return UIGraphicsImageRenderer(bounds: bounds).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }

    fileprivate static func makePodium(_ rankedImages: [UIImage]) -> UIView {
        let imageViews = rankedImages.enumerated().map { rank, image -> UIImageView in
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.layer.magnificationFilter = .nearest
            let size = rank == 0 ? podiumWinnerSize : podiumRunnerUpSize
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: size),
                imageView.heightAnchor.constraint(equalToConstant: size)
            ])
            return imageView
        }
        var podiumOrder = imageViews
        if podiumOrder.count > 1 {
            podiumOrder.swapAt(0, 1)
        }
        let podium = UIStackView(arrangedSubviews: podiumOrder)
        podium.alignment = .bottom
        podium.spacing = 4
        return podium
    }

    fileprivate static func makeRow(_ row: Row) -> UIView {
        let titleLabel = UILabel(style: .subheadline, weight: .semibold, color: Color.textTertiary)
        titleLabel.text = row.title
        let valueLabel = UILabel(style: .body, weight: .semibold, color: Color.textPrimary)
        valueLabel.text = row.value
        valueLabel.textAlignment = .right
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.6
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        let rowView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        rowView.spacing = 12
        rowView.alignment = .center
        if let image = row.image {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.layer.magnificationFilter = .nearest
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 36),
                imageView.heightAnchor.constraint(equalToConstant: 36)
            ])
            rowView.insertArrangedSubview(imageView, at: 0)
            rowView.setCustomSpacing(8, after: imageView)
        }
        return rowView
    }
}

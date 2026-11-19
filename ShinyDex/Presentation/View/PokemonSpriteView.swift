import UIKit
import FLAnimatedImage

class PokemonSpriteView: UIView {
	var pointsPerPixel: CGFloat = 3 {
		didSet { setNeedsLayout() }
	}

	fileprivate let imageView = FLAnimatedImageView()
	fileprivate let tapRecognizer = UITapGestureRecognizer()
	fileprivate var tapToPlaySprite: FLAnimatedImage?

	override init(frame: CGRect) {
		super.init(frame: frame)
		isAccessibilityElement = false
		imageView.contentMode = .scaleToFill
		imageView.layer.magnificationFilter = .nearest
		imageView.loopCompletionBlock = { [weak self] _ in
			self?.showTapToPlayStill()
		}
		addSubview(imageView)
		tapRecognizer.addTarget(self, action: #selector(playOnce))
		addGestureRecognizer(tapRecognizer)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setPokemon(named name: String) {
		tapToPlaySprite = nil
		imageView.animatedImage = nil
		imageView.image = nil
		if let asset = NSDataAsset(name: name) {
			if let sprite = FLAnimatedImage(animatedGIFData: asset.data) {
				// HGSS sprites are encoded to play once, so they wait for a tap; the others loop forever.
				if sprite.loopCount == 0 && !UIAccessibility.isReduceMotionEnabled {
					imageView.animatedImage = sprite
				}
				else {
					tapToPlaySprite = sprite
					showTapToPlayStill()
				}
			}
			else {
				imageView.image = UIImage(data: asset.data)
			}
		}
		else {
			imageView.image = UIImage(named: name.lowercased())
		}
		tapRecognizer.isEnabled = tapToPlaySprite != nil
		setNeedsLayout()
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		let pixelSize = imageView.animatedImage?.size ?? imageView.image?.size ?? .zero
		guard pixelSize.width > 0, pixelSize.height > 0 else { return }
		let fittingScale = min(bounds.width / pixelSize.width, bounds.height / pixelSize.height)
		let scale = min(pointsPerPixel, fittingScale)
		let size = CGSize(width: pixelSize.width * scale, height: pixelSize.height * scale)
		imageView.frame = CGRect(x: (bounds.width - size.width) / 2, y: (bounds.height - size.height) / 2, width: size.width, height: size.height)
	}

	fileprivate func showTapToPlayStill() {
		guard let sprite = tapToPlaySprite else { return }
		imageView.animatedImage = nil
		imageView.image = sprite.posterImage
	}

	@objc fileprivate func playOnce() {
		guard let sprite = tapToPlaySprite, imageView.animatedImage == nil else { return }
		imageView.animatedImage = sprite
	}
}

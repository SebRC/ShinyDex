import UIKit

enum PixelArt {
    fileprivate static let centeredImages = NSCache<NSString, UIImage>()
    fileprivate static let filledImages = NSCache<NSString, UIImage>()

    static func makeCenteredImage(named name: String) -> UIImage? {
        if let cached = centeredImages.object(forKey: name as NSString) {
            return cached
        }
        guard let centered = UIImage(named: name)?.centeringVisiblePixels() else { return nil }
        centeredImages.setObject(centered, forKey: name as NSString)
        return centered
    }

    static func makeFilledImage(named name: String, fillingFraction: CGFloat, maximumScale: CGFloat, canvasSize: CGSize? = nil) -> UIImage? {
        let key = "\(name)|\(fillingFraction)|\(canvasSize.map { "\($0.width)x\($0.height)" } ?? "")" as NSString
        if let cached = filledImages.object(forKey: key) {
            return cached
        }
        guard let filled = UIImage(named: name)?.fillingWithVisiblePixels(fraction: fillingFraction, maximumScale: maximumScale, canvasSize: canvasSize) else { return nil }
        filledImages.setObject(filled, forKey: key)
        return filled
    }
}

enum PokemonSprites {
    static let fillingFraction: CGFloat = 0.63
    static let maximumScale: CGFloat = 3

    static func makeImage(pokemonName: String, formId: String? = nil) -> UIImage? {
        if let formId = formId, let formImage = makeFilledImage(named: "\(pokemonName.lowercased())-\(formId)") {
            return formImage
        }
        return makeFilledImage(named: pokemonName.lowercased())
    }

    fileprivate static func makeFilledImage(named name: String) -> UIImage? {
        return PixelArt.makeFilledImage(named: name, fillingFraction: fillingFraction, maximumScale: maximumScale)
    }

    static func makeAssetName(pokemonName: String, formId: String?) -> String {
        guard let formId = formId else { return pokemonName }
        return "\(pokemonName)-\(formId)"
    }

    static func makeTitle(pokemonName: String, formName: String?) -> String {
        guard let formName = formName else { return pokemonName }
        return "\(pokemonName) (\(formName))"
    }
}

extension UIImage {
    func centeringVisiblePixels() -> UIImage {
        guard let visibleRect = findVisiblePixelRect() else { return self }
        let canvas = CGRect(origin: .zero, size: size)
        let offset = CGPoint(x: canvas.midX - visibleRect.midX, y: canvas.midY - visibleRect.midY)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            context.cgContext.interpolationQuality = .none
            draw(at: CGPoint(x: offset.x.rounded(), y: offset.y.rounded()))
        }
    }

    func fillingWithVisiblePixels(fraction: CGFloat, maximumScale: CGFloat, canvasSize: CGSize? = nil) -> UIImage {
        guard let visibleRect = findVisiblePixelRect() else { return self }
        let canvas = canvasSize ?? size
        let target = CGSize(width: canvas.width * fraction, height: canvas.height * fraction)
        let scale = min(target.width / visibleRect.width, target.height / visibleRect.height, maximumScale)
        let scaledSize = CGSize(width: visibleRect.width * scale, height: visibleRect.height * scale)
        let destination = CGRect(x: (canvas.width - scaledSize.width) / 2, y: (canvas.height - scaledSize.height) / 2, width: scaledSize.width, height: scaledSize.height)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = UIScreen.main.scale
        return UIGraphicsImageRenderer(size: canvas, format: format).image { context in
            context.cgContext.interpolationQuality = .none
            guard let visiblePixels = cgImage?.cropping(to: visibleRect.applying(CGAffineTransform(scaleX: self.scale, y: self.scale))) else { return }
            UIImage(cgImage: visiblePixels).draw(in: destination)
        }
    }

    func findVisibleBottomFraction() -> CGFloat? {
        guard size.height > 0, let visibleRect = findVisiblePixelRect() else { return nil }
        return visibleRect.maxY / size.height
    }

    func findVisiblePixelRect() -> CGRect? {
        guard let cgImage = cgImage else { return nil }
        let width = cgImage.width
        let height = cgImage.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        guard let context = CGContext(data: &pixels, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
                                      space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        var minX = width, minY = height, maxX = -1, maxY = -1
        for y in 0..<height {
            for x in 0..<width where pixels[(y * width + x) * 4 + 3] > 0 {
                minX = min(minX, x)
                maxX = max(maxX, x)
                minY = min(minY, y)
                maxY = max(maxY, y)
            }
        }
        guard maxX >= minX, maxY >= minY else { return nil }
        let pointsPerPixel = 1 / scale
        return CGRect(x: CGFloat(minX) * pointsPerPixel, y: CGFloat(minY) * pointsPerPixel,
                      width: CGFloat(maxX - minX + 1) * pointsPerPixel, height: CGFloat(maxY - minY + 1) * pointsPerPixel)
    }
}

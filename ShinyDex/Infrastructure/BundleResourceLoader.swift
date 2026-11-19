import Foundation

final class BundleResourceLoader: ResourceLoader {
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func lines(ofTextResource name: String) -> [String] {
        guard let path = bundle.path(forResource: name, ofType: "txt"),
              let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return []
        }
        var lines = content.components(separatedBy: "\n")
        lines.removeLast()
        return lines
    }

    func data(ofResource name: String, withExtension fileExtension: String) -> Data? {
        guard let url = bundle.url(forResource: name, withExtension: fileExtension) else { return nil }
        return try? Data(contentsOf: url)
    }
}

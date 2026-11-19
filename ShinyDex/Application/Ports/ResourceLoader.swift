import Foundation

protocol ResourceLoader {
    func lines(ofTextResource name: String) -> [String]
    func data(ofResource name: String, withExtension fileExtension: String) -> Data?
}

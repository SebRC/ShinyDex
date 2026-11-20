import Foundation

protocol ResourceLoader {
    func loadLines(ofTextResource name: String) -> [String]
    func loadData(ofResource name: String, withExtension fileExtension: String) -> Data?
}

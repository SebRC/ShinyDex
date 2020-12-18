import Foundation

public class TxtReader
{
	func linesFromResourceForced(textFile: String) -> [String]
	{
		let path = Bundle.main.path(forResource: textFile, ofType: "txt")!
		let content = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
		var pokemonList = content!.components(separatedBy: "\n")
		pokemonList.removeLast()
		return pokemonList
	}
}

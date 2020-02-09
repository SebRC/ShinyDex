import Foundation

public class TxtReader
{
	init()
	{}
	
	func linesFromResourceForced(textFile: String) -> [String] {
		
		let path = Bundle.main.path(forResource: textFile, ofType: "txt")!
		
		let content = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
		
		var pokemonList = [String]()
		
		pokemonList = content.components(separatedBy: "\n")
		
		pokemonList.removeLast()
		
		return pokemonList
	}
}

import Foundation

public class TxtReader
{
	func linesFromResourceForced(textFile: String) -> [String] {
		
		let path = Bundle.main.path(forResource: textFile, ofType: "txt")!
		
		let content = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
		
		var pokemonList = [String]()
		
		pokemonList = content.components(separatedBy: "\n")
		
		pokemonList.removeLast()
		
		return pokemonList
	}

	func getEncodedImageBase64String() -> String {

		let path = Bundle.main.path(forResource: "encoded", ofType: "txt")!

		let content = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)

		return content
	}

	func write(dict: Dictionary<String, String>)
	{
		let path = Bundle.main.path(forResource: "gifs", ofType: "txt")!
		let start = "{\n"
		let end = "}"
		do {
			try start.write(to: URL(fileURLWithPath: path), atomically: true, encoding: .utf8)
		} catch {
			//print("Write wrong start")

		}


		for pair in dict
		{
			autoreleasepool {
				let jsonString = "\"\(pair.key)\": \"\(pair.value)\",\n"
				do {
					try jsonString.write(toFile: path, atomically: true, encoding: .utf8)
				} catch {
					//print("Write wrong middle")
				}
			}
		}

		do {
			try end.write(to: URL(fileURLWithPath: path), atomically: true, encoding: .utf8)
		} catch {
			//print("Write wrong end")

		}

		var pokemonList = [String]()
	}

	func readJson() -> Data?
	{
		do {
			if let bundlePath = Bundle.main.path(forResource: "gifs",
												 ofType: "json"),
				let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
				return jsonData
			}
		} catch {
			print(error)
		}

		return nil
	}

	func parse(jsonData: Data) {
		do {
			let decodedData = try JSONDecoder().decode(Dictionary<String, String>.self,
													   from: jsonData)

			for pair in decodedData
			{
				print("Name: ", pair.key)
				print("Encoded gif: ", pair.value)
				print("===================================")
			}

		} catch {
			print("decode error")
		}
	}
}

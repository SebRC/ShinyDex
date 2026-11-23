import Foundation

struct PokemonForm: Equatable {
    let id: String
    let name: String
}

struct SpeciesForms: Equatable {
    let defaultName: String?
    let alternates: [PokemonForm]
}

struct PokemonForms {
    private let formsByNumber: [Int: SpeciesForms]

    init(formsByNumber: [Int: SpeciesForms] = [:]) {
        self.formsByNumber = formsByNumber
    }

    var numbersWithForms: [Int] {
        return formsByNumber.keys.sorted()
    }

    func getForms(of number: Int) -> SpeciesForms? {
        return formsByNumber[number]
    }

    func findForm(_ formId: String?, of number: Int) -> PokemonForm? {
        guard let formId = formId else { return nil }
        return formsByNumber[number]?.alternates.first { $0.id == formId }
    }

    func carryOver(_ formId: String?, to number: Int) -> String? {
        return findForm(formId, of: number)?.id
    }
}

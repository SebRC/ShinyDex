import Foundation

struct GetPokemonFormsQuery {
    let number: Int
}

final class GetPokemonFormsHandler {
    private let forms: PokemonForms

    init(forms: PokemonForms) {
        self.forms = forms
    }

    func handle(_ query: GetPokemonFormsQuery) -> FormChoices? {
        return FormChoices(forms.getForms(of: query.number))
    }
}

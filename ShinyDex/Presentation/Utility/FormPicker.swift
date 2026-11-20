import UIKit

enum FormPicker {
    static func make(pokemonName: String?, choices: FormChoices, selectedFormId: String?, onPick: @escaping (String?) -> Void) -> OptionPickerTVC {
        let options = choices.forms.map { form in
            PickerOption(title: form.name, image: makeSprite(pokemonName: pokemonName, formId: form.id))
        }
        let defaultOption = PickerOption(title: choices.defaultName, image: makeSprite(pokemonName: pokemonName, formId: nil))
        return OptionPickerTVC(title: "Form",
                               options: options,
                               selectedIndex: choices.forms.firstIndex { $0.id == selectedFormId },
                               defaultOption: defaultOption) { index in
            onPick(index.map { choices.forms[$0].id })
        }
    }

    fileprivate static func makeSprite(pokemonName: String?, formId: String?) -> UIImage? {
        return pokemonName.flatMap { PokemonSprites.makeImage(pokemonName: $0, formId: formId) }
    }
}

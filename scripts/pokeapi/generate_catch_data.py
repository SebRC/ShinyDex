import csv, json, sys

source, forms_path, output = sys.argv[1], sys.argv[2], sys.argv[3]
FORM_ALIASES = {'ice-rider': 'ice', 'shadow-rider': 'shadow', 'four': 'family-of-four'}
MOON_STONE = 'moon-stone'


def rows(name):
    return list(csv.DictReader(open(f'{source}/{name}.csv', encoding='utf-8')))


species = {int(r['id']): r for r in rows('pokemon_species')}
pokemon = rows('pokemon')
pokemon_by_id = {r['id']: r for r in pokemon}
pokemon_id_by_identifier = {r['identifier']: r['id'] for r in pokemon}
default_id_of_species = {int(r['species_id']): r['id'] for r in pokemon if r['is_default'] == '1'}
type_names = {r['id']: r['identifier'] for r in rows('types')}
types_of = {}
for r in sorted(rows('pokemon_types'), key=lambda r: int(r['slot'])):
    types_of.setdefault(r['pokemon_id'], []).append(type_names[r['type_id']])

moon_stone_id = next(r['id'] for r in rows('items') if r['identifier'] == MOON_STONE)
moon_stone_chains = {species[int(r['evolved_species_id'])]['evolution_chain_id'] for r in rows('pokemon_evolution') if r['trigger_item_id'] == moon_stone_id}
moon_stone_family = {species_id for species_id, row in species.items() if row['evolution_chain_id'] in moon_stone_chains}


def describe(pokemon_id):
    return {'types': types_of.get(pokemon_id, []), 'weight': int(pokemon_by_id[pokemon_id]['weight'])}


def find_form_pokemon_id(species_identifier, form_id):
    form = FORM_ALIASES.get(form_id, form_id)
    exact = pokemon_id_by_identifier.get(f'{species_identifier}-{form}')
    if exact:
        return exact
    prefixed = sorted(identifier for identifier in pokemon_id_by_identifier if identifier.startswith(f'{species_identifier}-{form}-'))
    return pokemon_id_by_identifier[prefixed[0]] if prefixed else None


forms_of = {entry['number']: [form['id'] for form in entry['forms']] for entry in json.load(open(forms_path, encoding='utf-8'))}

entries = []
for species_id, default_id in sorted(default_id_of_species.items()):
    number = species_id - 1
    standard = describe(default_id)
    entry = {'number': number, 'catchRate': int(species[species_id]['capture_rate']), **standard}
    if species_id in moon_stone_family:
        entry['moonStoneFamily'] = True
    differing_forms = {}
    for form_id in forms_of.get(number, []):
        form_pokemon_id = find_form_pokemon_id(species[species_id]['identifier'], form_id)
        if form_pokemon_id is not None and describe(form_pokemon_id) != standard:
            differing_forms[form_id] = describe(form_pokemon_id)
    if differing_forms:
        entry['forms'] = differing_forms
    entries.append(entry)

json.dump(entries, open(output, 'w', encoding='utf-8'), separators=(',', ':'))
print(f'{len(entries)} species, {sum(1 for e in entries if "forms" in e)} with forms that change types or weight, '
      f'{len(moon_stone_family)} in a Moon Stone evolution line')

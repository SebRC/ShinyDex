import csv, json, sys

source, forms_path, output = sys.argv[1], sys.argv[2], sys.argv[3]
STAT_COUNT = 6
FORM_ALIASES = {'ice-rider': 'ice', 'shadow-rider': 'shadow', 'four': 'family-of-four'}


def rows(name):
    return list(csv.DictReader(open(f'{source}/{name}.csv', encoding='utf-8')))


pokemon = rows('pokemon')
pokemon_id_by_identifier = {r['identifier']: r['id'] for r in pokemon}
default_id_of_species = {int(r['species_id']): r['id'] for r in pokemon if r['is_default'] == '1'}
species_identifier_of = {int(r['id']): r['identifier'] for r in rows('pokemon_species')}

base_stats_of = {}
for r in rows('pokemon_stats'):
    stat_index = int(r['stat_id']) - 1
    if stat_index < STAT_COUNT:
        base_stats_of.setdefault(r['pokemon_id'], [0] * STAT_COUNT)[stat_index] = int(r['base_stat'])


def find_form_pokemon_id(species_identifier, form_id):
    form = FORM_ALIASES.get(form_id, form_id)
    exact = pokemon_id_by_identifier.get(f'{species_identifier}-{form}')
    if exact:
        return exact
    prefixed = sorted(identifier for identifier in pokemon_id_by_identifier if identifier.startswith(f'{species_identifier}-{form}-'))
    return pokemon_id_by_identifier[prefixed[0]] if prefixed else None


forms_of = {species['number']: [form['id'] for form in species['forms']] for species in json.load(open(forms_path, encoding='utf-8'))}

entries = []
unmatched = []
for species_id, default_id in sorted(default_id_of_species.items()):
    number = species_id - 1
    stats = base_stats_of[default_id]
    entry = {'number': number, 'stats': stats}
    differing_forms = {}
    for form_id in forms_of.get(number, []):
        form_pokemon_id = find_form_pokemon_id(species_identifier_of[species_id], form_id)
        if form_pokemon_id is None:
            unmatched.append(f'{species_identifier_of[species_id]} {form_id}')
        elif base_stats_of[form_pokemon_id] != stats:
            differing_forms[form_id] = base_stats_of[form_pokemon_id]
    if differing_forms:
        entry['forms'] = differing_forms
    entries.append(entry)

json.dump(entries, open(output, 'w', encoding='utf-8'), separators=(',', ':'))
print(f'{len(entries)} species, {sum(1 for e in entries if "forms" in e)} with forms that change base stats')
if unmatched:
    print(f'{len(unmatched)} forms without their own entry use the species\' base stats: {", ".join(unmatched)}')

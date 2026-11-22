import csv, json, sys
from collections import defaultdict

source, forms_path, output = sys.argv[1], sys.argv[2], sys.argv[3]
ENGLISH = '9'
FIRST_GENERATION_WITH_ABILITIES = 3
LATEST_GENERATION = 9
FORM_ALIASES = {'ice-rider': 'ice', 'shadow-rider': 'shadow', 'four': 'family-of-four'}


def rows(name):
    return list(csv.DictReader(open(f'{source}/{name}.csv', encoding='utf-8')))


main_series = {r['id']: r['identifier'] for r in rows('abilities') if r['is_main_series'] == '1'}
names = {main_series[r['ability_id']]: r['name'] for r in rows('ability_names')
         if r['local_language_id'] == ENGLISH and r['ability_id'] in main_series}

pokemon = rows('pokemon')
pokemon_id_by_identifier = {r['identifier']: r['id'] for r in pokemon}
default_identifier_of_species = {int(r['species_id']): r['identifier'] for r in pokemon if r['is_default'] == '1'}
species_identifier_of = {int(r['id']): r['identifier'] for r in rows('pokemon_species')}

current_slots = defaultdict(dict)
for r in rows('pokemon_abilities'):
    if r['ability_id'] in main_series:
        current_slots[r['pokemon_id']][int(r['slot'])] = main_series[r['ability_id']]

past_slots = defaultdict(list)
for r in rows('pokemon_abilities_past'):
    ability = main_series.get(r['ability_id']) if r['ability_id'] else None
    past_slots[r['pokemon_id']].append((int(r['generation_id']), int(r['slot']), ability))


def find_slots(pokemon_id, generation):
    slots = dict(current_slots[pokemon_id])
    for slot in {slot for _, slot, _ in past_slots[pokemon_id]}:
        later_changes = [(until, ability) for until, changed_slot, ability in past_slots[pokemon_id] if changed_slot == slot and until >= generation]
        if later_changes:
            _, ability = min(later_changes)
            if ability:
                slots[slot] = ability
            else:
                slots.pop(slot, None)
    return slots


def describe(pokemon_id):
    ranges = []
    for generation in range(FIRST_GENERATION_WITH_ABILITIES, LATEST_GENERATION + 1):
        slots = find_slots(pokemon_id, generation)
        entry = {'abilities': [slots[slot] for slot in sorted(slots) if slot != 3], 'hidden': slots.get(3)}
        if not ranges or {k: v for k, v in ranges[-1].items() if k != 'from'} != entry:
            ranges.append({'from': generation, **entry})
    return ranges


def find_form_pokemon_id(species_identifier, form_id):
    form = FORM_ALIASES.get(form_id, form_id)
    exact = pokemon_id_by_identifier.get(f'{species_identifier}-{form}')
    if exact:
        return exact
    prefixed = sorted(identifier for identifier in pokemon_id_by_identifier if identifier.startswith(f'{species_identifier}-{form}-'))
    return pokemon_id_by_identifier[prefixed[0]] if prefixed else None


entries = []
for species_id, identifier in sorted(default_identifier_of_species.items()):
    default_id = pokemon_id_by_identifier[identifier]
    if current_slots[default_id]:
        entries.append({'number': species_id - 1, 'generations': describe(default_id)})

unmatched = []
for species in json.load(open(forms_path, encoding='utf-8')):
    number = species['number']
    species_identifier = species_identifier_of.get(number + 1)
    default_id = pokemon_id_by_identifier.get(default_identifier_of_species.get(number + 1))
    for form in species['forms']:
        form_pokemon_id = find_form_pokemon_id(species_identifier, form['id'])
        if form_pokemon_id is None:
            unmatched.append(f"{species_identifier}-{form['id']}")
            continue
        generations = describe(form_pokemon_id)
        if generations != describe(default_id):
            entries.append({'number': number, 'form': form['id'], 'generations': generations})

json.dump({'names': dict(sorted(names.items())), 'pokemon': entries}, open(output, 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
print(len(entries), 'entries', len(names), 'abilities')
print('Forms without their own PokéAPI entry, using the species abilities:', ', '.join(unmatched))

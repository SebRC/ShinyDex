import csv, json, sys
from collections import defaultdict

source, forms_path, output = sys.argv[1], sys.argv[2], sys.argv[3]
ENGLISH = '9'
FORM_ALIASES = {'ice-rider': 'ice', 'shadow-rider': 'shadow', 'four': 'family-of-four'}
GAMES = {
    'Red': ['red-blue'], 'Blue': ['red-blue'], 'Yellow': ['yellow'], 'Gold': ['gold-silver'], 'Silver': ['gold-silver'], 'Crystal': ['crystal'],
    'Ruby': ['ruby-sapphire'], 'Sapphire': ['ruby-sapphire'], 'Emerald': ['emerald'], 'FireRed': ['firered-leafgreen'], 'LeafGreen': ['firered-leafgreen'],
    'Diamond': ['diamond-pearl'], 'pearl': ['diamond-pearl'], 'Platinum': ['platinum'], 'HeartGold': ['heartgold-soulsilver'],
    'SoulSilver': ['heartgold-soulsilver'], 'Black': ['black-white'], 'White': ['black-white'], 'Black 2': ['black-2-white-2'],
    'White 2': ['black-2-white-2'], 'X': ['x-y'], 'Y': ['x-y'], 'Omega Ruby': ['omega-ruby-alpha-sapphire'], 'Alpha Sapphire': ['omega-ruby-alpha-sapphire'],
    'Sun': ['sun-moon'], 'Moon': ['sun-moon'], 'Ultra Sun': ['ultra-sun-ultra-moon'], 'Ultra Moon': ['ultra-sun-ultra-moon'],
    "Let's Go Pikachu": ['lets-go-pikachu-lets-go-eevee'], "Let's Go Eevee": ['lets-go-pikachu-lets-go-eevee'],
    'Sword': ['sword-shield', 'the-isle-of-armor', 'the-crown-tundra'], 'Shield': ['sword-shield', 'the-isle-of-armor', 'the-crown-tundra'],
    'Legends: Arceus': ['legends-arceus'], 'Brilliant Diamond': ['brilliant-diamond-shining-pearl'], 'Shining Pearl': ['brilliant-diamond-shining-pearl'],
    'Scarlet': ['scarlet-violet', 'the-teal-mask', 'the-indigo-disk'], 'Violet': ['scarlet-violet', 'the-teal-mask', 'the-indigo-disk'],
}
METHOD_GROUPS = {'level-up': 0, 'reminder': 0, 'machine': 1, 'egg': 2, 'light-ball-egg': 2, 'tutor': 3, 'train': 3}


def rows(name):
    return list(csv.DictReader(open(f'{source}/{name}.csv', encoding='utf-8')))


version_group_id = {r['identifier']: r['id'] for r in rows('version_groups')}
method_group = {r['id']: METHOD_GROUPS[r['identifier']] for r in rows('pokemon_move_methods') if r['identifier'] in METHOD_GROUPS}
type_identifier = {r['id']: r['identifier'] for r in rows('types')}
move_names = {r['move_id']: r['name'] for r in rows('move_names') if r['local_language_id'] == ENGLISH}
move_rows = {r['id']: r for r in rows('moves')}

pokemon = rows('pokemon')
pokemon_id_by_identifier = {r['identifier']: r['id'] for r in pokemon}
default_identifier_of_species = {int(r['species_id']): r['identifier'] for r in pokemon if r['is_default'] == '1'}
species_identifier_of = {int(r['id']): r['identifier'] for r in rows('pokemon_species')}

learned = defaultdict(lambda: defaultdict(lambda: [set(), set(), set(), set()]))
for r in rows('pokemon_moves'):
    group = method_group.get(r['pokemon_move_method_id'])
    if group is not None and r['move_id'] in move_names:
        learned[r['pokemon_id']][r['version_group_id']][group].add(int(r['move_id']))

learnsets = []
learnset_index = {}


def index_learnset(groups):
    key = tuple(tuple(sorted(group)) for group in groups)
    if key not in learnset_index:
        learnset_index[key] = len(learnsets)
        learnsets.append([list(group) for group in key])
    return learnset_index[key]


def describe(pokemon_id):
    by_game = {}
    for game, version_groups in GAMES.items():
        groups = [set(), set(), set(), set()]
        for version_group in version_groups:
            for group, moves in enumerate(learned[pokemon_id].get(version_group_id[version_group], [set()] * 4)):
                groups[group] |= moves
        if any(groups):
            by_game[game] = index_learnset(groups)
    return by_game


def find_form_pokemon_id(species_identifier, form_id):
    form = FORM_ALIASES.get(form_id, form_id)
    exact = pokemon_id_by_identifier.get(f'{species_identifier}-{form}')
    if exact:
        return exact
    prefixed = sorted(identifier for identifier in pokemon_id_by_identifier if identifier.startswith(f'{species_identifier}-{form}-'))
    return pokemon_id_by_identifier[prefixed[0]] if prefixed else None


def align(by_game):
    return [by_game.get(game, -1) for game in GAMES]


entries = []
for species_id, identifier in sorted(default_identifier_of_species.items()):
    games = describe(pokemon_id_by_identifier[identifier])
    if games:
        entries.append({'number': species_id - 1, 'learnsets': align(games)})

for species in json.load(open(forms_path, encoding='utf-8')):
    number = species['number']
    default_games = describe(pokemon_id_by_identifier[default_identifier_of_species[number + 1]])
    for form in species['forms']:
        form_pokemon_id = find_form_pokemon_id(species_identifier_of[number + 1], form['id'])
        if form_pokemon_id is None:
            continue
        games = describe(form_pokemon_id)
        if games and games != default_games:
            entries.append({'number': number, 'form': form['id'], 'learnsets': align(games)})

used_moves = sorted({move for learnset in learnsets for group in learnset for move in group})
moves = {str(move): [move_names[str(move)], type_identifier.get(move_rows[str(move)]['type_id'], ''), int(move_rows[str(move)]['pp'] or 0)]
         for move in used_moves}
json.dump({'games': list(GAMES), 'moves': moves, 'learnsets': learnsets, 'pokemon': entries}, open(output, 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
print(len(entries), 'entries', len(learnsets), 'learnsets', len(moves), 'moves')

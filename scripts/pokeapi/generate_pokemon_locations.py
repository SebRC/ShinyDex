import csv, json, os, re, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from shiny_locks import is_shiny_locked
from collections import defaultdict

source, output = sys.argv[1], sys.argv[2]
ENGLISH = '9'


def rows(name):
    return csv.DictReader(open(f'{source}/{name}.csv'))


version_id = {r['identifier']: r['id'] for r in rows('versions')}
species_of_pokemon = {r['id']: int(r['species_id']) for r in rows('pokemon')}
slot_of = {r['id']: (r['encounter_method_id'], int(r['rarity'] or 0)) for r in rows('encounter_slots')}
method_identifier = {r['id']: r['identifier'] for r in rows('encounter_methods')}
method_prose = {r['encounter_method_id']: r['name'] for r in rows('encounter_method_prose') if r['local_language_id'] == ENGLISH}
location_name = {r['location_id']: r['name'] for r in rows('location_names') if r['local_language_id'] == ENGLISH}
area_location = {r['id']: r['location_id'] for r in rows('location_areas')}
areas_per_location = defaultdict(int)
for location in area_location.values():
    areas_per_location[location] += 1
area_prose = {r['location_area_id']: r['name'] for r in rows('location_area_prose') if r['local_language_id'] == ENGLISH}
condition_name = {r['encounter_condition_value_id']: r['name'].replace('Pokemon', 'Pokémon') for r in rows('encounter_condition_value_prose') if r['local_language_id'] == ENGLISH}
condition_name = {value: ('After Mr. Backlot mentions a Pokémon' if name.startswith('Mr. Backlot') else name) for value, name in condition_name.items()}
ambient_prefixes = ('time-', 'season-', 'weekday-', 'weather-', 'headbutt-tree-')


def find_dimension(row):
    ambient = next((prefix for prefix in ambient_prefixes if row['identifier'].startswith(prefix)), None)
    return ambient or row['encounter_condition_id']


condition_rows = list(rows('encounter_condition_values'))
condition_value = {r['id']: (find_dimension(r), r['is_default'] == '1') for r in condition_rows}
default_value_of = {dimension: value for value, (dimension, is_default) in condition_value.items() if is_default and dimension not in ambient_prefixes}
conditions_of = defaultdict(list)
for r in rows('encounter_condition_value_map'):
    conditions_of[r['encounter_id']].append(r['encounter_condition_value_id'])
types_of = defaultdict(set)
for r in rows('pokemon_types'):
    types_of[r['pokemon_id']].add(r['type_id'])
ELECTRIC, STEEL = '13', '9'

short_names = {
    'walk': 'Grass or cave', 'old-rod': 'Old Rod', 'good-rod': 'Good Rod', 'super-rod': 'Super Rod', 'surf': 'Surfing', 'rock-smash': 'Rock Smash',
    'headbutt': 'Headbutt', 'headbutt-low': 'Headbutt (low-rate tree)', 'headbutt-normal': 'Headbutt (normal tree)', 'headbutt-high': 'Headbutt (high-rate tree)',
    'dark-grass': 'Dark grass', 'grass-spots': 'Rustling grass', 'cave-spots': 'Dust cloud', 'bridge-spots': 'Bridge shadow',
    'super-rod-spots': 'Super Rod (rippling water)', 'surf-spots': 'Surfing (rippling water)', 'yellow-flowers': 'Yellow flowers',
    'purple-flowers': 'Purple flowers', 'red-flowers': 'Red flowers', 'rough-terrain': 'Rough terrain', 'gift': 'Gift', 'gift-egg': 'Gift egg',
    'static': 'Static encounter', 'pokeflute': 'Wake with the Poké Flute', 'squirt-bottle': 'Squirt Bottle', 'wailmer-pail': 'Wailmer Pail',
    'seaweed': 'Seaweed', 'roaming-grass': 'Roaming (grass)', 'roaming-water': 'Roaming (water)', 'devon-scope': 'Devon Scope',
    'feebas-tile-fishing': 'Fishing on Feebas tiles', 'island-scan': 'Island Scan', 'sos': 'SOS call', 'bubbling-spots': 'Fishing (bubbling water)',
    'berry-trees': 'Berry tree', 'npc-trade': 'In-game trade', 'sos-from-bubbling-spot': 'SOS call (bubbling water)', 'overworld': 'Overworld',
    'overworld-water': 'Overworld (water)', 'overworld-flying': 'Overworld (flying)', 'overworld-special': 'Overworld (special)',
    'overworld-flying-special': 'Overworld (flying, special)', 'overworld-water-special': 'Overworld (water, special)', 'horde': 'Horde encounter',
    'hidden-grotto': 'Hidden Grotto', 'honey-tree': 'Honey tree', 'overworld-dirt': 'Overworld (dirt)', 'wanderer': 'Wandering',
    'wanderer-water': 'Wandering (water)', 'chase-water': 'Chasing (water)', 'dynamax-adventure': 'Dynamax Adventure', 'max-raid': 'Max Raid Battle',
    'trash-can-ambush': 'Trash can ambush', 'rustling-bush-ambush': 'Rustling bush ambush', 'ceiling-ambush': 'Ceiling ambush',
    'ground-ambush': 'Ground ambush', 'sky-ambush': 'Sky ambush'}
external_methods = {'colosseum-bonus-disc-us', 'colosseum-bonus-disc-jpn', 'pokemon-channel-pal', 'pokemon-ranger', 'pokemon-battle-revolution',
                    'new-york-pokecenter-wish-eggs'}
repel_methods = {'walk', 'surf', 'dark-grass'}
encounter_rate_methods = {'walk', 'surf', 'dark-grass'}
ability_methods = {'walk', 'surf', 'dark-grass', 'old-rod', 'good-rod', 'super-rod', 'rock-smash', 'grass-spots', 'cave-spots', 'surf-spots',
                   'super-rod-spots', 'bubbling-spots', 'headbutt', 'headbutt-low', 'headbutt-normal', 'headbutt-high'}

games = {
    'Red': (1, ['red']), 'Blue': (1, ['blue']), 'Yellow': (1, ['yellow']), 'Gold': (2, ['gold']), 'Silver': (2, ['silver']), 'Crystal': (2, ['crystal']),
    'Ruby': (3, ['ruby']), 'Sapphire': (3, ['sapphire']), 'Emerald': (3, ['emerald']), 'FireRed': (3, ['firered']), 'LeafGreen': (3, ['leafgreen']),
    'Diamond': (4, ['diamond']), 'pearl': (4, ['pearl']), 'Platinum': (4, ['platinum']), 'HeartGold': (4, ['heartgold']), 'SoulSilver': (4, ['soulsilver']),
    'Black': (5, ['black']), 'White': (5, ['white']), 'Black 2': (5, ['black-2']), 'White 2': (5, ['white-2']), 'X': (6, ['x']), 'Y': (6, ['y']),
    'Omega Ruby': (6, ['omega-ruby']), 'Alpha Sapphire': (6, ['alpha-sapphire']), 'Sun': (7, ['sun']), 'Moon': (7, ['moon']),
    'Ultra Sun': (7, ['ultra-sun']), 'Ultra Moon': (7, ['ultra-moon']),
    "Let's Go Pikachu": (7, ['lets-go-pikachu']), "Let's Go Eevee": (7, ['lets-go-eevee']),
    'Sword': (8, ['sword', 'the-isle-of-armor-sword', 'the-crown-tundra-sword']), 'Shield': (8, ['shield', 'the-isle-of-armor-shield', 'the-crown-tundra-shield'])}
lets_go = {"Let's Go Pikachu", "Let's Go Eevee"}
games_without_field_abilities = {'Ruby', 'Sapphire', 'FireRed', 'LeafGreen'}



def find_shiny_lock(game, species, identifier):
    return 1 if is_shiny_locked(game, games[game][0], species, identifier) else 0


game_of_version = {version_id[v]: game for game, (_, versions) in games.items() for v in versions}


def normalize_place(text):
    text = re.sub(r'\bmount\b', 'mt', text.lower())
    text = re.sub(r'\broad\b', 'route', text)
    return re.sub(r'[^a-z0-9]', '', text)


def tidy_place(text):
    return re.sub(r'(?<!Victory )\bRoad (\d+)', r'Route \1', text.replace('Pokemon', 'Pokémon'))


def strip_place_prefix(text, name):
    words = text.split(' ')
    for count in range(len(words), 0, -1):
        if normalize_place(' '.join(words[:count])) == normalize_place(name):
            return ' '.join(words[count:])
    return None


def area_title(area):
    location = area_location.get(area)
    name = tidy_place(location_name.get(location, ''))
    prose = tidy_place(area_prose.get(area, ''))
    if not name:
        return prose
    if not prose or areas_per_location[location] <= 1 or normalize_place(prose) == normalize_place(name):
        return name
    nested = re.fullmatch(r'(.+?) \((.+)\)', prose)
    if nested:
        outer, inner = nested.groups()
        if normalize_place(name).endswith(normalize_place(outer)):
            return f'{name} ({inner})'
        if normalize_place(inner) == normalize_place(name):
            return f'{name} ({outer})'
        return f'{name} ({outer}, {inner})'
    remainder = strip_place_prefix(prose, name)
    if remainder:
        return f'{name} ({remainder})'
    return f'{name} ({prose})'


def is_worthwhile(boosted_rate, rate):
    return boosted_rate >= rate + 5 or boosted_rate >= rate * 1.5


def describe(values):
    names = sorted(condition_name.get(value, '') for value in values if condition_name.get(value))
    all_times = {'In the morning', 'During the day', 'At night'}
    if all_times <= set(names):
        names = [name for name in names if name not in all_times]
    if not names:
        return ''
    return ' or '.join([names[0]] + [name[0].lower() + name[1:] for name in names[1:]])


places = defaultdict(list)
for r in rows('encounters'):
    game = game_of_version.get(r['version_id'])
    if not game:
        continue
    method_id, rarity = slot_of[r['encounter_slot_id']]
    identifier = method_identifier[method_id]
    if identifier in external_methods:
        continue
    values = frozenset(conditions_of.get(r['id'], []))
    places[(game, area_title(r['location_area_id']), identifier)].append(
        (r['encounter_slot_id'], values, species_of_pokemon[r['pokemon_id']], r['pokemon_id'], rarity, int(r['min_level']), int(r['max_level'])))


def share_at_or_above(level, low, high):
    return max(0, high - max(low, level) + 1) / (high - low + 1)


def calculate_repel(table, species):
    lead_level = max(high for s, _, _, _, high in table if s == species)
    totals = [(s, rarity * share_at_or_above(lead_level, low, high)) for s, _, rarity, low, high in table]
    remaining = sum(weight for _, weight in totals)
    target = sum(weight for s, weight in totals if s == species)
    total = sum(rarity for _, _, rarity, _, _ in table)
    return lead_level, (round(100 * target / remaining) if remaining else 0), max(1, round(100 * remaining / total))


def calculate_keen_eye(table, species):
    lead_level = min(low for s, _, _, low, _ in table if s == species) + 4
    threshold = lead_level - 5

    def weight(rarity, low, high):
        share_suppressed = max(0, min(high, threshold) - low + 1) / (high - low + 1)
        return rarity * (1 - 0.5 * share_suppressed)
    total = sum(weight(rarity, low, high) for _, _, rarity, low, high in table)
    target = sum(weight(rarity, low, high) for s, _, rarity, low, high in table if s == species)
    return lead_level, (round(100 * target / total) if total else 0)


def calculate_repel_with_pressure(table, species):
    lead_level = max(high for s, _, _, _, high in table if s == species)

    def passing(rarity, low, high):
        return rarity * (0.5 * (1 if high >= lead_level else 0) + 0.5 * share_at_or_above(lead_level, low, high))
    remaining = sum(passing(rarity, low, high) for _, _, rarity, low, high in table)
    target = sum(passing(rarity, low, high) for s, _, rarity, low, high in table if s == species)
    total = sum(rarity for _, _, rarity, _, _ in table)
    return (round(100 * target / remaining) if remaining else 0), max(1, round(100 * remaining / total))


def calculate_ability_boost(table, species, type_id, base_rate):
    typed = sum(rarity for _, pokemon_id, rarity, _, _ in table if type_id in types_of[pokemon_id])
    target = sum(rarity for s, _, rarity, _, _ in table if s == species)
    if not typed or not target:
        return 0
    return round(0.5 * base_rate + 0.5 * 100 * target / typed)


def find_complete(table):
    return 95 <= sum(slot[2] for slot in table) <= 105


def calculate_extras(table, species, identifier, generation, game, base_rate, pokemon_id):
    repel_level = repel_rate = static_rate = magnet_rate = keen_eye_level = keen_eye_rate = pressure_repel_rate = 0
    repel_encounters = pressure_repel_encounters = 0
    is_sped_up_by_abilities = int(identifier in encounter_rate_methods and 3 <= generation <= 8 and game not in lets_go)

    def extras():
        return (repel_level, repel_rate, static_rate, magnet_rate, keen_eye_level, keen_eye_rate, pressure_repel_rate,
                repel_encounters, pressure_repel_encounters, is_sped_up_by_abilities)
    if not find_complete(table) or game in lets_go or len({slot[0] for slot in table}) < 2:
        return extras()
    if identifier in repel_methods and generation <= 7:
        level, rate, encounters = calculate_repel(table, species)
        has_pressure = generation >= 3 and game not in games_without_field_abilities
        with_pressure, encounters_with_pressure = calculate_repel_with_pressure(table, species) if has_pressure else (0, 0)
        is_pressure_worthwhile = is_worthwhile(with_pressure, rate) and is_worthwhile(with_pressure, base_rate)
        if rate > base_rate and (is_worthwhile(rate, base_rate) or is_pressure_worthwhile):
            repel_level, repel_rate, repel_encounters = level, rate, encounters
            if is_pressure_worthwhile:
                pressure_repel_rate, pressure_repel_encounters = with_pressure, encounters_with_pressure
    if identifier in ability_methods and 3 <= generation <= 8 and game not in games_without_field_abilities:
        for type_id in (ELECTRIC, STEEL):
            if type_id in types_of[pokemon_id]:
                boosted = calculate_ability_boost(table, species, type_id, base_rate)
                if is_worthwhile(boosted, base_rate):
                    if type_id == ELECTRIC:
                        static_rate = boosted
                    else:
                        magnet_rate = boosted
        level, rate = calculate_keen_eye(table, species)
        if is_worthwhile(rate, base_rate):
            keen_eye_level, keen_eye_rate = level, rate
    return extras()


def make_scenarios(entries):
    used = defaultdict(set)
    for _, values, *_ in entries:
        for value in values:
            used[condition_value[value][0]].add(value)
    dimensions = [(condition, sorted(values | ({default_value_of[condition]} if condition in default_value_of else set())), default_value_of.get(condition))
                  for condition, values in sorted(used.items())]
    normal = [(condition, values) for condition, values, default in dimensions if not default]
    special = [(condition, values, default) for condition, values, default in dimensions if default]
    base = [dict()]
    for condition, values in normal:
        base = [dict(scenario, **{condition: value}) for scenario in base for value in values]
    defaults = {condition: default for condition, _, default in special}
    scenarios = [{**scenario, **defaults} for scenario in base]
    for condition, values, default in special:
        for value in values:
            if value != default:
                scenarios += [{**scenario, **defaults, condition: value} for scenario in base]
    return scenarios, dimensions


def build_table(entries, scenario):
    chosen = {}
    active = set(scenario.values())
    for slot_id, values, species, pokemon_id, rarity, low, high in entries:
        if slot_id not in chosen and values <= active:
            chosen[slot_id] = (species, pokemon_id, rarity, low, high)
    return list(chosen.values())


rows_by_key = {}
for (game, area, identifier), entries in places.items():
    generation = games[game][0]
    is_one_time_method = identifier in {'gift', 'gift-egg', 'static', 'npc-trade', 'pokeflute'}
    scenarios, dimensions = make_scenarios(entries)
    special = {condition for condition, _, default in dimensions if default}
    results = defaultdict(list)
    for scenario in scenarios:
        table = build_table(entries, scenario)
        for species in {slot[0] for slot in table}:
            slots = [slot for slot in table if slot[0] == species]
            rarity = sum(slot[2] for slot in slots)
            is_one_time = is_one_time_method or rarity == 0
            base_rate = 0 if is_one_time else min(100, rarity)
            extras = calculate_extras(table, species, identifier, generation, game, base_rate, slots[0][1]) if not is_one_time else (0,) * 10
            low, high = min(slot[3] for slot in slots), max(slot[4] for slot in slots)
            if identifier == 'npc-trade' and high - low > 20:
                low = high = 0
            result = (low, high, base_rate) + extras
            results[species].append((scenario, result))
    for species, outcomes in results.items():
        default_outcomes = [(scenario, result) for scenario, result in outcomes if all(scenario.get(c) == default_value_of[c] for c in special)]
        groups = defaultdict(list)
        for scenario, result in (default_outcomes or outcomes):
            groups[result].append(scenario)
        for scenario, result in outcomes:
            off_default = [scenario[c] for c in special if scenario.get(c) != default_value_of[c]]
            if len(off_default) == 1 and (scenario, result) not in default_outcomes and result not in groups:
                groups[result].append(scenario)
        varying = {c for c, _, _ in dimensions if len({scenario.get(c) for scenario, _ in outcomes}) > 1}
        for result, grouped in groups.items():
            parts = []
            for condition, _, default in dimensions:
                values = {scenario.get(condition) for scenario in grouped}
                if default:
                    off = values - {default}
                    if off and len(values) == len(off):
                        parts.append(describe(off))
                elif condition in varying:
                    all_values = {scenario.get(condition) for scenario, _ in outcomes}
                    if values != all_values:
                        parts.append(describe(values))
            text = ', '.join(part if i == 0 else part[0].lower() + part[1:] for i, part in enumerate(p for p in parts if p))
            key = (game, species, area, short_names.get(identifier, identifier)) + result + (text, find_shiny_lock(game, species, identifier))
            rows_by_key[key] = True

strings = {}


def index(text):
    if text not in strings:
        strings[text] = len(strings)
    return strings[text]


data = defaultdict(lambda: defaultdict(list))
for key in sorted(rows_by_key):
    game, species, area, method, low, high, rate = key[:7]
    extras = list(key[7:17])
    condition, shiny_locked = key[17], key[18]
    row = [index(area), index(method), low, high, rate, index(condition)] + extras[:7] + [shiny_locked] + extras[7:]
    while len(row) > 6 and row[-1] == 0:
        row.pop()
    data[game][str(species)].append(row)

json.dump({'strings': [text for text, _ in sorted(strings.items(), key=lambda item: item[1])], 'games': data}, open(output, 'w'), separators=(',', ':'))
print(sum(len(v) for g in data.values() for v in g.values()), 'rows', len(strings), 'strings')

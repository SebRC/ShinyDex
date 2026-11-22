import csv, json, sys

source, output = sys.argv[1], sys.argv[2]
FIXED_GENDERS = {'-1': 'genderless', '0': 'male', '8': 'female'}

species = list(csv.DictReader(open(f'{source}/pokemon_species.csv', encoding='utf-8')))
genders = {gender: sorted(int(r['id']) - 1 for r in species if FIXED_GENDERS.get(r['gender_rate']) == gender) for gender in FIXED_GENDERS.values()}
json.dump(genders, open(output, 'w', encoding='utf-8'), separators=(',', ':'))
print(', '.join(f'{len(numbers)} {gender}' for gender, numbers in genders.items()))

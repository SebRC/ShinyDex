#!/bin/bash
set -euo pipefail
destination="${1:?Usage: download_csvs.sh <destination folder>}"
mkdir -p "$destination"
for name in versions version_groups pokemon pokemon_species pokemon_evolution encounters encounter_slots encounter_methods encounter_method_prose \
    encounter_condition_value_map encounter_condition_value_prose pokedexes pokedex_version_groups pokemon_dex_numbers locations location_names \
    location_areas location_area_prose pokemon_types encounter_conditions encounter_condition_values pokemon_abilities abilities ability_names pokemon_stats; do
    curl -sfL -o "$destination/$name.csv" "https://raw.githubusercontent.com/PokeAPI/pokeapi/master/data/v2/csv/$name.csv"
done

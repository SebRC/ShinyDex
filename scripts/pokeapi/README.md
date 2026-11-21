# PokéAPI data

Regenerates the bundled game availability and location data from PokéAPI's CSV files.

```bash
scripts/pokeapi/download_csvs.sh /tmp/pokeapi
python3 scripts/pokeapi/generate_game_availability.py /tmp/pokeapi ShinyDex/Resources/gameAvailability.json
python3 scripts/pokeapi/generate_pokemon_locations.py /tmp/pokeapi ShinyDex/Resources/pokemonLocations.json
```

Games without encounter data in PokéAPI use their regional Pokédex and are marked approximate. Update the game tables in both scripts when new games are added to `Games`.

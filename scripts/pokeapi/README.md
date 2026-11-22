# PokéAPI data

Regenerates the bundled game availability, location, ability and learnset data from PokéAPI's CSV files.

```bash
scripts/pokeapi/download_csvs.sh /tmp/pokeapi
python3 scripts/pokeapi/generate_game_availability.py /tmp/pokeapi ShinyDex/Resources/gameAvailability.json
python3 scripts/pokeapi/generate_pokemon_locations.py /tmp/pokeapi ShinyDex/Resources/pokemonLocations.json
python3 scripts/pokeapi/generate_abilities.py /tmp/pokeapi ShinyDex/Resources/forms.json ShinyDex/Resources/abilities.json
python3 scripts/pokeapi/generate_learnsets.py /tmp/pokeapi ShinyDex/Resources/forms.json ShinyDex/Resources/learnsets.json
```

Games without encounter data in PokéAPI use their regional Pokédex and are marked approximate. Update the game tables in both scripts when new games are added to `Games`.

Abilities are listed per generation from Gen 3, using `pokemon_abilities_past` for abilities that changed. Forms from `forms.json` are matched to PokéAPI's Pokémon by name; the script lists forms without their own entry, which use the species' abilities. Add an alias in `FORM_ALIASES` when a form's id differs from PokéAPI's name.

Learnsets are listed per game, combining a game's DLC with the base game, and grouped into level-up, TM/TR, egg and tutor moves. Identical learnsets are stored once and shared. Update `GAMES` in the script when new games are added to `Games`.

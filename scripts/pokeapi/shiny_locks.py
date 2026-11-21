JOHTO = ['Gold', 'Silver', 'Crystal', 'HeartGold', 'SoulSilver']
ALOLA = ['Sun', 'Moon', 'Ultra Sun', 'Ultra Moon']
GALAR = ['Sword', 'Shield']

SHINY_LOCKED_ENCOUNTERS = set(
    [(game, 21, 'gift') for game in JOHTO]
    + [('Black', 494, 'static'), ('White', 494, 'static'), ('Black', 643, 'static'), ('White', 644, 'static'),
       ('Black 2', 644, 'static'), ('White 2', 643, 'static'), ('Black 2', 646, 'static'), ('White 2', 646, 'static'),
       ('X', 716, 'static'), ('Y', 717, 'static'),
       ('Omega Ruby', 383, 'static'), ('Alpha Sapphire', 382, 'static'), ('Omega Ruby', 386, 'static'), ('Alpha Sapphire', 386, 'static')]
    + [(game, species, method) for game in ALOLA
       for species, method in [(791, 'static'), (792, 'static'), (785, 'static'), (786, 'static'), (787, 'static'), (788, 'static'),
                               (772, 'gift'), (789, 'gift'), (800, 'static'), (803, 'gift')]]
    + [(game, species, method) for game in GALAR
       for species, method in [(888, 'static'), (889, 'static'), (890, 'static'), (772, 'gift'), (891, 'gift'), (898, 'static'),
                               (896, 'static'), (897, 'static'), (789, 'gift')]])


def is_shiny_locked(game, generation, species, method_identifier):
    if method_identifier == 'npc-trade' and 2 <= generation <= 7:
        return True
    return (game, species, method_identifier) in SHINY_LOCKED_ENCOUNTERS

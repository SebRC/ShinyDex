import csv, json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from shiny_locks import is_shiny_locked
S=sys.argv[1]; out=sys.argv[2]
def rows(name): return list(csv.DictReader(open(f'{S}/{name}.csv')))
version_id={r['identifier']:r['id'] for r in rows('versions')}
version_group_of_version={r['id']:r['version_group_id'] for r in rows('versions')}
vg_id={r['identifier']:r['id'] for r in rows('version_groups')}
vg_generation={r['id']:int(r['generation_id']) for r in rows('version_groups')}
game_only_vgs={vg_id['legends-arceus'], vg_id['lets-go-pikachu-lets-go-eevee'], vg_id['legends-za']}
species_of_pokemon={r['id']:int(r['species_id']) for r in rows('pokemon')}
method_of_slot={r['id']:r['encounter_method_id'] for r in rows('encounter_slots')}
method_name={r['id']:r['identifier'] for r in rows('encounter_methods')}
species=rows('pokemon_species')
evolves_from={int(r['id']):int(r['evolves_from_species_id']) for r in species if r['evolves_from_species_id']}
generation_of={int(r['id']):int(r['generation_id']) for r in species}
evolutions=rows('pokemon_evolution')
external={'colosseum-bonus-disc-us','colosseum-bonus-disc-jpn','pokemon-channel-pal','pokemon-ranger','pokemon-battle-revolution','new-york-pokecenter-wish-eggs'}
method_identifier={r['id']:r['identifier'] for r in rows('encounter_methods')}
encountered={}
for r in rows('encounters'):
    if method_name[method_of_slot[r['encounter_slot_id']]] in external: continue
    encountered.setdefault(r['version_id'],set()).add((species_of_pokemon[r['pokemon_id']], method_identifier[method_of_slot[r['encounter_slot_id']]]))
dexes_by_vg={}
for r in rows('pokedex_version_groups'): dexes_by_vg.setdefault(r['version_group_id'],set()).add(r['pokedex_id'])
species_by_dex={}
for r in rows('pokemon_dex_numbers'): species_by_dex.setdefault(r['pokedex_id'],set()).add(int(r['species_id']))
def regional(vgs):
    out=set()
    for vg in vgs:
        for d in dexes_by_vg[vg_id[vg]]: out|=species_by_dex.get(d,set())
    return out
MAX=1010
G={  # game: (generation, versions with encounter data, version groups for dex, has breeding, trade source)
 'Red':(1,['red'],['red-blue'],False,'generation'),'Blue':(1,['blue'],['red-blue'],False,'generation'),'Yellow':(1,['yellow'],['yellow'],False,'generation'),
 'Gold':(2,['gold'],['gold-silver'],True,'generation'),'Silver':(2,['silver'],['gold-silver'],True,'generation'),'Crystal':(2,['crystal'],['crystal'],True,'generation'),
 'Ruby':(3,['ruby'],['ruby-sapphire'],True,'generation'),'Sapphire':(3,['sapphire'],['ruby-sapphire'],True,'generation'),'Emerald':(3,['emerald'],['emerald'],True,'generation'),
 'FireRed':(3,['firered'],['firered-leafgreen'],True,'generation'),'LeafGreen':(3,['leafgreen'],['firered-leafgreen'],True,'generation'),
 'Diamond':(4,['diamond'],['diamond-pearl'],True,'generation'),'pearl':(4,['pearl'],['diamond-pearl'],True,'generation'),'Platinum':(4,['platinum'],['platinum'],True,'generation'),
 'HeartGold':(4,['heartgold'],['heartgold-soulsilver'],True,'generation'),'SoulSilver':(4,['soulsilver'],['heartgold-soulsilver'],True,'generation'),
 'Black':(5,['black'],['black-white'],True,'generation'),'White':(5,['white'],['black-white'],True,'generation'),
 'Black 2':(5,['black-2'],['black-2-white-2'],True,'generation'),'White 2':(5,['white-2'],['black-2-white-2'],True,'generation'),
 'X':(6,['x'],['x-y'],True,'generation'),'Y':(6,['y'],['x-y'],True,'generation'),
 'Omega Ruby':(6,['omega-ruby'],['omega-ruby-alpha-sapphire'],True,'generation'),'Alpha Sapphire':(6,['alpha-sapphire'],['omega-ruby-alpha-sapphire'],True,'generation'),
 'Sun':(7,['sun'],['sun-moon'],True,'generation'),'Moon':(7,['moon'],['sun-moon'],True,'generation'),
 'Ultra Sun':(7,['ultra-sun'],['ultra-sun-ultra-moon'],True,'generation'),'Ultra Moon':(7,['ultra-moon'],['ultra-sun-ultra-moon'],True,'generation'),
 "Let's Go Pikachu":(7,['lets-go-pikachu'],['lets-go-pikachu-lets-go-eevee'],False,'pokedex'),"Let's Go Eevee":(7,['lets-go-eevee'],['lets-go-pikachu-lets-go-eevee'],False,'pokedex'),
 'Sword':(8,['sword','the-isle-of-armor-sword','the-crown-tundra-sword'],['sword-shield'],True,'generation'),
 'Shield':(8,['shield','the-isle-of-armor-shield','the-crown-tundra-shield'],['sword-shield'],True,'generation'),
 'Brilliant Diamond':(8,[],['brilliant-diamond-shining-pearl'],True,'generation'),'Shining Pearl':(8,[],['brilliant-diamond-shining-pearl'],True,'generation'),
 'Legends: Arceus':(8,[],['legends-arceus'],False,'generation'),
 'Scarlet':(9,[],['scarlet-violet'],True,'generation'),'Violet':(9,[],['scarlet-violet'],True,'generation')}
def released(n,gen):
    g=generation_of.get(n,99)
    return g<=gen and n<=MAX
def close_over_evolutions(seed, gen, game_vgs, breeding):
    catchable={n for n in seed if released(n,gen)}
    changed=True
    while changed:
        changed=False
        for r in evolutions:
            child=int(r['evolved_species_id'])
            if child in catchable or not released(child,gen): continue
            if r['evolution_trigger_id']=='2': continue
            row_vg=r['version_group_id']
            if row_vg in game_only_vgs and row_vg not in game_vgs: continue
            if row_vg and row_vg not in game_only_vgs and vg_generation[row_vg] > gen: continue
            if evolves_from.get(child) in catchable:
                catchable.add(child); changed=True
        if breeding:
            for n in list(catchable):
                root=n
                while root in evolves_from and released(evolves_from[root],gen): root=evolves_from[root]
                if root not in catchable:
                    catchable.add(root); changed=True
    return catchable


result={}
for game,(gen,versions,vgs,breeding,tradeSource) in G.items():
    game_vgs={vg_id[v] for v in vgs}
    if versions:
        found=set()
        for v in versions: found|=encountered.get(version_id[v],set())
        everything={n for n,method in found if method!='npc-trade' or not is_shiny_locked(game, gen, n, method)}
        huntable={n for n,method in found if not is_shiny_locked(game, gen, n, method)}
        approximate=False
    else:
        everything=huntable=regional(vgs); approximate=True
    catchable=close_over_evolutions(huntable, gen, game_vgs, breeding)
    reachable=close_over_evolutions(everything, gen, game_vgs, breeding)
    locked=reachable-catchable
    obtainable = regional(vgs) if tradeSource=='pokedex' else {n for n in generation_of if released(n,gen)}
    obtainable |= reachable
    approximate = approximate or game in {'Omega Ruby','Alpha Sapphire','Sword','Shield'}
    result[game]={'catchable':sorted(catchable),'shinyLocked':sorted(locked),'tradeOnly':sorted(obtainable-reachable),'approximate':approximate}
lets_go_games={"Let's Go Pikachu","Let's Go Eevee"}


def find_source_games(game):
    generation=G[game][0]
    if game in lets_go_games:
        return [g for g in lets_go_games]
    return [g for g,(gen,*_) in G.items() if gen<=generation and g not in lets_go_games]


for game,data in result.items():
    sources=find_source_games(game)
    locked_everywhere=[n for n in data['tradeOnly']
                       if not any(n in result[source]['catchable'] for source in sources)
                       and any(n in result[source]['shinyLocked'] for source in sources)]
    data['shinyLocked']=sorted(set(data['shinyLocked'])|set(locked_everywhere))
    data['tradeOnly']=sorted(set(data['tradeOnly'])-set(locked_everywhere))
json.dump(result, open(out,'w'), separators=(',',':'), sort_keys=True)
for k,v in result.items(): print(f"{k}: catchable {len(v['catchable'])}, shiny locked {len(v['shinyLocked'])}, trade only {len(v['tradeOnly'])}{' (approx)' if v['approximate'] else ''}")

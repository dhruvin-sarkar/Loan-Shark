from pathlib import Path
import json

ROOT=Path(__file__).resolve().parents[2]
Q=json.dumps
class Raw(str):
    pass

def ER(i):
    return Raw(f'ExtResource("{i}")')

def g(v):
    if isinstance(v,Raw): return str(v)
    if isinstance(v,bool): return 'true' if v else 'false'
    if isinstance(v,int): return str(v)
    if isinstance(v,float):
        s=f'{v:.4f}'.rstrip('0').rstrip('.')
        return s if s else '0'
    if isinstance(v,str): return Q(v)
    if isinstance(v,list): return '['+', '.join(g(x) for x in v)+']'
    if isinstance(v,dict): return '{'+', '.join(f'{Q(str(k))}: {g(val)}' for k,val in v.items())+'}'
    raise TypeError(v)

def w(p,s):
    p.parent.mkdir(parents=True,exist_ok=True)
    p.write_text(s.rstrip()+'\n',encoding='utf-8')

def res(path,cls,script,props):
    lines=[f'[gd_resource type="Resource" script_class="{cls}" load_steps=2 format=3]','','[ext_resource type="Script" path="%s" id="1"]'%script,'','[resource]','script = ExtResource("1")']
    for k,v in props.items(): lines.append(f'{k} = {g(v)}')
    w(ROOT/path,'\n'.join(lines))

FISH=[
('zone1','sardine','Sardine',4,'common','pelagic',0.8,False,1,''),
('zone1','bass','Sea Bass',14,'common','bony',1.0,False,1,''),
('zone1','crab','Shore Crab',18,'common','crustacean',1.2,False,1,''),
('zone1','clownfish','Clownfish',22,'uncommon','reef',0.9,False,1,''),
('zone1','seahorse','Seahorse',28,'uncommon','reef',0.7,False,1,''),
('zone1','pufferfish','Pufferfish',20,'uncommon','bony',1.3,False,1,''),
('zone1','flounder','Flounder',16,'common','bony',1.0,False,1,''),
('zone1','perch','Perch',10,'common','bony',0.9,False,1,''),
('zone1','shrimp','Rock Shrimp',12,'common','crustacean',0.8,False,1,''),
('zone1','jellyfish','Moon Jellyfish',8,'uncommon','pelagic',0.6,False,1,''),
('zone2','snapper','Snapper',32,'uncommon','bony',1.2,False,1,''),
('zone2','moray_small','Moray Eel (Young)',38,'uncommon','eel',1.5,False,1,''),
('zone2','grouper','Grouper',45,'rare','bony',1.4,False,1,''),
('zone2','trumpet_fish','Trumpetfish',35,'uncommon','reef',1.0,False,1,''),
('zone2','spiny_lobster','Spiny Lobster',55,'rare','crustacean',1.6,False,1,''),
('zone2','stonefish','Stonefish',60,'rare','bony',1.3,False,1,''),
('zone2','octopus_small','Young Octopus',40,'uncommon','cephalopod',1.5,False,1,''),
('zone2','needlefish','Needlefish',28,'uncommon','pelagic',1.8,False,1,''),
('zone2','batfish','Batfish',30,'uncommon','reef',1.1,True,1,''),
('zone2','ghost_crab','Ghost Crab',65,'rare','crustacean',1.4,True,1,'ghost_crab_night_bonus'),
('zone3','anglerfish','Anglerfish',90,'rare','deep',1.6,False,1,''),
('zone3','moray_large','Moray Eel (Large)',75,'uncommon','eel',1.8,False,1,''),
('zone3','oarfish','Oarfish',110,'rare','bony',1.3,False,2,''),
('zone3','viperfish','Viperfish',95,'rare','deep',2.0,False,1,''),
('zone3','dragonfish_juv','Dragonfish (Juvenile)',120,'rare','deep',1.7,False,1,''),
('zone3','rugose_crab','Rugose Crab',85,'uncommon','crustacean',1.5,False,1,''),
('zone3','coelacanth','Coelacanth',200,'legendary','bony',1.2,False,1,''),
('zone3','abyssal_shrimp','Abyssal Shrimp',70,'uncommon','crustacean',1.0,False,1,''),
('zone3','stone_crab','Stone Crab',65,'uncommon','crustacean',1.3,False,1,''),
('zone3','phantom_eel','Phantom Eel',130,'rare','eel',2.2,True,1,''),
('zone4','gulper_eel','Gulper Eel',160,'ultra-rare','eel',2.0,False,1,''),
('zone4','dragonfish_adult','Dragonfish (Adult)',180,'ultra-rare','deep',2.2,False,1,''),
('zone4','deep_angler','Deep Anglerfish',150,'ultra-rare','deep',1.8,False,1,''),
('zone4','barreleye','Barreleye Fish',170,'ultra-rare','deep',1.5,False,1,''),
('zone4','fangtooth','Fangtooth Fish',140,'rare','deep',2.1,False,1,''),
('zone4','frilled_shark','Frilled Shark',220,'ultra-rare','deep',2.3,False,1,''),
('zone4','goldfish_modifier','Deepwater Goldfish',300,'ultra-rare','deep',1.0,False,1,'goldfish_next_sale_bonus'),
('zone4','lanternfish','Lanternfish Swarm',40,'common','pelagic',0.8,False,5,''),
('zone4','sea_angel','Sea Angel',250,'ultra-rare','deep',1.3,False,1,'sea_angel_charm_double'),
('zone4','midnight_leviathan','Midnight Leviathan',800,'legendary','deep',3.0,True,1,'leviathan_debt_clear')]
RODS={
'rod_driftwood':('Driftwood Rod','starter',0,1,'',1.0,0.0,0.0,0.0,'Starter rod.'),
'rod_shell':('Shell Rod','amateur',60,1,'crustacean',1.2,0.0,0.0,0.0,'Crustacean farming rod.'),
'rod_coral':('Coral Rod','amateur',60,1,'reef',1.2,0.0,0.0,0.0,'Reef fishing rod.'),
'rod_bone':('Bone Rod','amateur',60,1,'bony',1.25,0.0,0.0,0.0,'Bony fish specialist.'),
'rod_kelp':('Kelp Rod','intermediate',180,2,'all_z2',1.25,0.0,0.0,0.0,'Zone 2 generalist.'),
'rod_deep':('Deep Rod','intermediate',180,2,'rare_z2',1.3,0.0,0.0,0.0,'Zone 2 rare hunter.'),
'rod_fossil':('Fossil Rod','intermediate',180,2,'',1.0,0.2,0.1,0.0,'More profit, harder reels.'),
'rod_abyss':('Abyss Rod','pro',450,3,'ultrarare_z4',1.35,0.0,0.0,0.0,'Ultra-rare deep hunter.'),
'rod_leviathan':('Leviathan Rod','pro',450,3,'trophy',1.4,0.0,0.0,0.0,'Skews size upward.'),
'rod_oracle':('Oracle Rod','pro',450,3,'all',1.15,0.1,0.0,1.3,'More fish, more danger.')}
BAITS={
'earthworm':('Earthworm',8,10,['bony'],1.25,False,'+25% bony fish.'),
'maggot':('Maggot',10,8,['common'],1.3,False,'+30% small/common fish.'),
'insect':('Insect',14,6,['reef','pelagic'],1.2,False,'Reef and pelagic bait.'),
'live_shrimp':('Live Shrimp',20,5,['crustacean'],1.35,False,'+35% crustaceans.'),
'sand_crab':('Sand Crab',20,5,['eel','deep'],1.3,False,'+30% eel and deep fish.'),
'smallfish':('Smallfish',25,4,['predator'],1.4,False,'Predator bait.'),
'soft_plastic':('Soft Plastic',18,6,['bony','reef'],1.2,False,'Artificial lure.'),
'jerkbait':('Jerkbait',24,5,['active_hunter'],1.25,False,'Active hunter lure.'),
'jig':('Jig',24,5,['deep'],1.25,False,'+25% deep fish.'),
'spinner':('Spinner',30,4,['crustacean','cephalopod'],1.3,False,'Flash lure.'),
'deep_sea_lure':('Deep Sea Lure',40,3,['zone3','zone4'],1.25,True,'Unlocks deep access.'),
'luminous_lure':('Luminous Lure',45,3,['zone4_ultra'],1.4,True,'Best Zone 4 lure.')}
KNIVES={'knife_rusty':('Rusty Knife',0,5,0.6,1.2,False),'knife_amateur':('Amateur Knife',55,12,0.9,1.4,False),'knife_pro':('Pro Knife',200,22,1.3,1.5,True)}
MATS={'shell':('Shell','common',False,1,'Shells.'),'coral':('Coral','common',False,1,'Coral.'),'sea_glass':('Sea Glass','common',False,1,'Sea glass.'),'driftwood':('Driftwood','common',False,1,'Driftwood.'),'algae':('Algae','common',False,1,'Algae.'),'night_kelp':('Night Kelp','uncommon',True,1,'Night-only kelp.'),'gold_sand':('Gold Sand','uncommon',False,1,'Gold sand.'),'deep_crystal':('Deep Crystal','rare',False,1,'Deep crystals.'),'echo_coral':('Echo Coral','rare',False,1,'Echo coral.'),'small_bone':('Small Bone','uncommon',False,1,'Small bones.'),'sand_crab':('Sand Crab','uncommon',False,1,'Live sand crab.'),'ghost_fin':('Ghost Fin','rare',False,1,'Ghost fin.'),'shark_tooth':('Shark Tooth','rare',False,3,'Day 3+.'),'ghost_crab_shell':('Ghost Crab Shell','uncommon',True,1,'Night shell.')}
CHARMS={
'charm_shell':('Shell Charm','sell_price','sell_price','crustacean',1.25,False,'',{'shell':3,'sea_glass':1},'+25% crustaceans.'),
'charm_coral':('Coral Charm','sell_price','sell_price','reef',1.3,False,'',{'coral':3,'algae':1},'+30% reef.'),
'charm_deep':('Deep Charm','sell_price','sell_price','deep',1.35,False,'',{'deep_crystal':2,'small_bone':1},'+35% deep.'),
'charm_tide':('Tide Charm','sell_price','sell_price','',1.2,False,'',{'driftwood':2,'coral':1},'+20% all fish.'),
'charm_gold':('Gold Charm','sell_price','sell_price','',1.5,False,'',{'gold_sand':3,'sea_glass':2},'+50% next 3 sales.'),
'charm_night':('Night Charm','sell_price','sell_price','',1.4,False,'',{'night_kelp':2,'ghost_fin':1},'+40% night fish.'),
'charm_blood':('Blood Charm','sell_price','sell_price','',1.6,False,'',{'shark_tooth':2,'small_bone':2},'+60% rare fish.'),
'charm_ink':('Ink Charm','sell_price','sell_price','cephalopod',1.25,False,'',{'ghost_crab_shell':2,'algae':1},'+25% cephalopods.'),
'charm_eel_ward':('Eel Ward','spawn_rate','spawn_rate','eel',0.5,False,'',{'ghost_fin':2,'driftwood':1},'-50% eel spawn.'),
'charm_siren':('Siren Charm','spawn_rate','spawn_rate','pelagic',1.3,False,'',{'sea_glass':3,'algae':1},'+30% pelagic spawn.'),
'charm_crustacean_call':('Crustacean Call','spawn_rate','spawn_rate','crustacean',1.4,False,'',{'shell':2,'sand_crab':2},'+40% crustaceans.'),
'charm_bony_lure':('Bony Lure','spawn_rate','spawn_rate','bony',1.35,False,'',{'small_bone':3,'driftwood':1},'+35% bony fish.'),
'charm_depth_pulse':('Depth Pulse','spawn_rate','spawn_rate','deep',1.4,False,'',{'deep_crystal':3,'echo_coral':1},'+40% deep fish.'),
'charm_fortune_bait':('Fortune Bait','spawn_rate','spawn_rate','',1.2,False,'',{'gold_sand':2,'sea_glass':1},'+20% rare+ spawn.'),
'charm_calm_tide':('Calm Tide','spawn_rate','spawn_rate','',0.7,False,'',{'coral':2,'algae':2},'-30% hazards.'),
'charm_frenzy':('Frenzy Charm','spawn_rate','spawn_rate','',1.5,False,'',{'shark_tooth':1,'ghost_fin':1,'night_kelp':1},'+50% all spawn.'),
'charm_tide_blessing':('Tide Blessing Charm','enchantment','enchantment','',1.2,True,'tide_blessing',{'shell':5,'echo_coral':2,'gold_sand':1},'Enchants Tide Blessing.'),
'charm_deep_lure':('Deep Lure Charm','enchantment','enchantment','',1.4,True,'deep_lure',{'deep_crystal':4,'small_bone':2},'Enchants Deep Lure.'),
'charm_fortune_hook':('Fortune Hook Charm','enchantment','enchantment','',1.0,True,'fortune_hook',{'gold_sand':4,'sea_glass':3},'Enchants Fortune Hook.'),
'charm_ghost_bait':('Ghost Bait Charm','enchantment','enchantment','',1.0,True,'ghost_bait',{'ghost_fin':3,'night_kelp':3},'Enchants Ghost Bait.'),
'charm_calm_waters':('Calm Waters Charm','enchantment','enchantment','',0.7,True,'calm_waters',{'coral':4,'algae':3,'sea_glass':2},'Enchants Calm Waters.'),
'charm_blood_tide':('Blood Tide Charm','enchantment','enchantment','',1.3,True,'blood_tide',{'shark_tooth':4,'small_bone':3},'Enchants Blood Tide.'),
'charm_echo_line':('Echo Line Charm','enchantment','enchantment','',1.15,True,'echo_line',{'echo_coral':3,'sea_glass':2,'driftwood':2},'Enchants Echo Line.'),
'charm_weighted_sink':('Weighted Sink Charm','enchantment','enchantment','',1.0,True,'weighted_sink',{'small_bone':2,'driftwood':3,'deep_crystal':1},'Enchants Weighted Sink.')}
RECIPE_IDS={
'charm_shell':'recipe_shell_charm',
'charm_coral':'recipe_coral_charm',
'charm_deep':'recipe_deep_charm',
'charm_tide':'recipe_tide_charm',
'charm_gold':'recipe_gold_charm',
'charm_night':'recipe_night_charm',
'charm_blood':'recipe_blood_charm',
'charm_ink':'recipe_ink_charm',
'charm_eel_ward':'recipe_eel_ward',
'charm_siren':'recipe_siren_charm',
'charm_crustacean_call':'recipe_crustacean_call',
'charm_bony_lure':'recipe_bony_lure',
'charm_depth_pulse':'recipe_depth_pulse',
'charm_fortune_bait':'recipe_fortune_bait',
'charm_calm_tide':'recipe_calm_tide',
'charm_frenzy':'recipe_frenzy_charm',
'charm_tide_blessing':'recipe_tide_blessing',
'charm_deep_lure':'recipe_deep_lure',
'charm_fortune_hook':'recipe_fortune_hook',
'charm_ghost_bait':'recipe_ghost_bait',
'charm_calm_waters':'recipe_calm_waters',
'charm_blood_tide':'recipe_blood_tide',
'charm_echo_line':'recipe_echo_line',
'charm_weighted_sink':'recipe_weighted_sink'}
SPAWN={1:{'sardine':25,'perch':20,'shrimp':18,'flounder':15,'bass':12,'jellyfish':10,'crab':8,'pufferfish':6,'clownfish':5,'seahorse':4},2:{'needlefish':20,'snapper':18,'trumpet_fish':15,'octopus_small':12,'moray_small':10,'grouper':8,'stonefish':6,'spiny_lobster':5,'abyssal_shrimp':4,'batfish':3,'ghost_crab':2},3:{'stone_crab':18,'abyssal_shrimp':15,'rugose_crab':12,'anglerfish':10,'moray_large':8,'oarfish':6,'viperfish':5,'dragonfish_juv':4,'coelacanth':2,'phantom_eel':3},4:{'lanternfish':25,'fangtooth':18,'deep_angler':14,'barreleye':12,'gulper_eel':8,'dragonfish_adult':6,'frilled_shark':4,'sea_angel':3,'goldfish_modifier':2,'midnight_leviathan':1}}

def gen_res():
    n=0
    for z,i,name,p,r,f,reel,night,slots,mod in FISH:
        res(f'resources/fish_data/{z}/{i}.tres','FishData','res://scripts/resources/fish_data.gd',{'id':i,'name':name,'zone':int(z[-1]),'base_price':float(p),'size_range':Raw('Vector2(0.8, 1.8)'),'rarity':r,'night_only':night,'family':f,'reel_speed':float(reel),'catch_speed':1.0,'modifier_effect':mod,'description':name,'inventory_slots':slots,'sprite_region':Raw('Rect2()')}); n+=1
    for i,(name,tier,price,zone,aff,mult,sell,reel,haz,desc) in RODS.items():
        res(f'resources/rod_data/{i}.tres','RodData','res://scripts/resources/rod_data.gd',{'id':i,'name':name,'tier':tier,'price':float(price),'zone_access':zone,'affinity_family':aff,'affinity_multiplier':float(mult),'sell_price_bonus':float(sell),'reel_speed_modifier':float(reel),'hazard_rate_modifier':float(haz),'description':desc}); n+=1
    for i,(name,price,qty,fams,mult,unlock,desc) in BAITS.items():
        res(f'resources/bait_data/{i}.tres','BaitData','res://scripts/resources/bait_data.gd',{'id':i,'name':name,'price':float(price),'quantity':qty,'target_families':fams,'weight_multiplier':float(mult),'unlocks_zone4':unlock,'description':desc}); n+=1
    for i,(name,price,w,q,m,b) in KNIVES.items():
        res(f'resources/knife_data/{i}.tres','KnifeData','res://scripts/resources/knife_data.gd',{'id':i,'name':name,'price':float(price),'sharpness_zone_px':w,'qte_window_seconds':float(q),'max_filet_mult':float(m),'bonus_material_on_perfect':b}); n+=1
    for i,(name,rar,night,day,desc) in MATS.items():
        res(f'resources/material_data/{i}.tres','MaterialData','res://scripts/resources/material_data.gd',{'id':i,'name':name,'rarity':rar,'night_only':night,'day_unlock':day,'description':desc}); n+=1
    for i,(name,cat,effect,target,mult,ench,ench_id,recipe,desc) in CHARMS.items():
        d='sell_charms' if cat=='sell_price' else 'spawn_charms' if cat=='spawn_rate' else 'enchantment_charms'
        res(f'resources/charm_data/{d}/{i}.tres','CharmData','res://scripts/resources/charm_data.gd',{'id':i,'name':name,'category':cat,'effect_type':effect,'target_family':target,'bonus_multiplier':float(mult),'is_enchantment':ench,'enchantment_id':ench_id,'recipe':recipe,'description':desc}); n+=1
        rid=RECIPE_IDS[i]
        res(f'resources/crafting_recipes/{rid}.tres','CraftingRecipeData','res://scripts/resources/crafting_recipe.gd',{'id':rid,'name':name,'result_id':i,'category':cat,'ingredients':recipe,'description':desc}); n+=1
    for z,t in SPAWN.items():
        res(f'resources/spawn_tables/spawn_table_zone{z}.tres','SpawnTableData','res://scripts/resources/spawn_table_data.gd',{'zone':z,'fish_weights':t}); n+=1
    return n

def scene(path,ext,nodes):
    lines=[f'[gd_scene load_steps={len(ext)+1} format=3]','']
    for t,p,i in ext: lines += [f'[ext_resource type="{t}" path="{p}" id="{i}"]','']
    for node in nodes:
        name,typ,parent,props=node
        head=f'[node name="{name}" type="{typ}"' + (f' parent="{parent}"' if parent is not None else '') + ']'
        lines.append(head)
        for k,v in props.items(): lines.append(f'{k} = {g(v)}')
        lines.append('')
    w(ROOT/path,'\n'.join(lines))

def add_player(nodes,parent='.'):
    nodes.append(('Player','CharacterBody2D',parent,{'script':ER('2'),'position':Raw('Vector2(160, 560)')}))
    nodes.append(('Sprite','Sprite2D','Player',{'texture':ER('3'),'scale':Raw('Vector2(2, 2)')}))

def gen_scenes():
    n=0
    scene('scenes/ui/HUD.tscn',[('Script','res://scripts/ui/hud.gd','1')],[('HUD','CanvasLayer',None,{'script':ER('1')}),('DayLabel','Label','.',{'offset_left':16.0,'offset_top':12.0,'text':'Day 1 / 7'}),('TimerLabel','Label','.',{'offset_left':16.0,'offset_top':40.0,'text':'10:00'}),('CashLabel','Label','.',{'offset_left':1040.0,'offset_top':12.0,'text':'$20.00'}),('DebtLabel','Label','.',{'offset_left':1040.0,'offset_top':40.0,'text':'$500.00'}),('ZoneLabel','Label','.',{'offset_left':620.0,'offset_top':12.0,'text':'Z1','visible':False}),('GreedBar','ProgressBar','.',{'offset_left':440.0,'offset_top':52.0,'offset_right':840.0,'offset_bottom':76.0,'visible':False}),('NotificationLabel','Label','.',{'offset_left':24.0,'offset_top':96.0,'offset_right':360.0,'text':'','visible':False}),('GoldenSaleLabel','Label','.',{'offset_left':520.0,'offset_top':88.0,'text':'GOLDEN SALE','visible':False}),('CharmBox','HBoxContainer','.',{'offset_left':980.0,'offset_top':80.0,'offset_right':1240.0,'offset_bottom':120.0}),('InventoryBar','HBoxContainer','.',{'offset_left':88.0,'offset_top':620.0,'offset_right':1192.0,'offset_bottom':692.0})]+[(f'Slot{i}','TextureButton','InventoryBar',{'custom_minimum_size':Raw('Vector2(64, 64)')}) for i in range(1,13)]); n+=1
    scene('scenes/ui/DialogueBox.tscn',[('Script','res://scripts/ui/dialogue_box.gd','1')],[('DialogueBox','CanvasLayer',None,{'script':ER('1')}),('Panel','Panel','.',{'offset_left':80.0,'offset_top':500.0,'offset_right':1200.0,'offset_bottom':700.0}),('SpeakerLabel','Label','Panel',{'offset_left':24.0,'offset_top':16.0,'text':'Finn'}),('TextLabel','Label','Panel',{'offset_left':24.0,'offset_top':56.0,'offset_right':1080.0,'offset_bottom':160.0,'autowrap_mode':3}),('ContinueLabel','Label','Panel',{'offset_left':940.0,'offset_top':150.0,'text':'Press Enter','visible':False})]); n+=1
    main=[('Main','Node',None,{'script':ER('1')}),('WorldContainer','Node2D','.',{}),('DayNightCycle','Node','.',{'script':ER('2')}),('HUD','CanvasLayer','.',{'script':ER('3')}),('DayLabel','Label','HUD',{'offset_left':16.0,'offset_top':12.0,'text':'Day 1 / 7'}),('TimerLabel','Label','HUD',{'offset_left':16.0,'offset_top':40.0,'text':'10:00'}),('CashLabel','Label','HUD',{'offset_left':1040.0,'offset_top':12.0,'text':'$20.00'}),('DebtLabel','Label','HUD',{'offset_left':1040.0,'offset_top':40.0,'text':'$500.00'}),('ZoneLabel','Label','HUD',{'offset_left':620.0,'offset_top':12.0,'text':'Z1','visible':False}),('GreedBar','ProgressBar','HUD',{'offset_left':440.0,'offset_top':52.0,'offset_right':840.0,'offset_bottom':76.0,'visible':False}),('NotificationLabel','Label','HUD',{'offset_left':24.0,'offset_top':96.0,'offset_right':360.0,'text':'','visible':False}),('GoldenSaleLabel','Label','HUD',{'offset_left':520.0,'offset_top':88.0,'text':'GOLDEN SALE','visible':False}),('CharmBox','HBoxContainer','HUD',{'offset_left':980.0,'offset_top':80.0,'offset_right':1240.0,'offset_bottom':120.0}),('InventoryBar','HBoxContainer','HUD',{'offset_left':88.0,'offset_top':620.0,'offset_right':1192.0,'offset_bottom':692.0})]+[(f'Slot{i}','TextureButton','InventoryBar',{'custom_minimum_size':Raw('Vector2(64, 64)')}) for i in range(1,13)]+[('DialogueBox','CanvasLayer','.',{'script':ER('4')}),('Panel','Panel','DialogueBox',{'offset_left':80.0,'offset_top':500.0,'offset_right':1200.0,'offset_bottom':700.0}),('SpeakerLabel','Label','DialogueBox/Panel',{'offset_left':24.0,'offset_top':16.0,'text':'Finn'}),('TextLabel','Label','DialogueBox/Panel',{'offset_left':24.0,'offset_top':56.0,'offset_right':1080.0,'offset_bottom':160.0,'autowrap_mode':3}),('ContinueLabel','Label','DialogueBox/Panel',{'offset_left':940.0,'offset_top':150.0,'text':'Press Enter','visible':False}),('TransitionLayer','CanvasLayer','.',{}),('FadeRect','ColorRect','TransitionLayer',{'offset_right':1280.0,'offset_bottom':720.0,'color':Raw('Color(0, 0, 0, 0)'),'visible':False})]
    scene('scenes/Main.tscn',[('Script','res://scripts/world/main.gd','1'),('Script','res://scripts/systems/day_night_cycle.gd','2'),('Script','res://scripts/ui/hud.gd','3'),('Script','res://scripts/ui/dialogue_box.gd','4')],main); n+=1
    for file,script,bg,hint,marks in [
        ('Town','res://scripts/world/town.gd','Color(0.26, 0.18, 0.12, 1)','Walk right to the beach',[('ShopMarker','Vector2(320, 560)')]),
        ('Beach','res://scripts/world/beach.gd','Color(0.68, 0.62, 0.42, 1)','Collect materials or walk to the dock',[('CraftMarker','Vector2(400, 560)'),('ForageContainer',None)]),
        ('Dock','res://scripts/world/dock.gd','Color(0.15, 0.22, 0.28, 1)','Walk left to the beach',[('FishermanMarker','Vector2(420, 560)'),('DiveMarker','Vector2(920, 560)'),('FiletMarker','Vector2(660, 560)')])]:
        nodes=[(file,'Node2D',None,{'script':ER('1')}),('Background','ColorRect','.',{'offset_right':1280.0,'offset_bottom':720.0,'color':Raw(bg)}),('Player','CharacterBody2D','.',{'script':ER('2'),'position':Raw('Vector2(160, 560)')}),('Sprite','Sprite2D','Player',{'texture':ER('3'),'scale':Raw('Vector2(2, 2)')}),('HintLabel','Label','.',{'offset_left':24.0,'offset_top':24.0,'text':hint})]
        for name,val in marks:
            nodes.append((name,'Node2D' if val is None else 'Marker2D','.',{} if val is None else {'position':Raw(val)}))
        scene(f'scenes/world/{file}.tscn',[('Script',script,'1'),('Script','res://scripts/world/player.gd','2'),('Texture2D','res://Assets/charfree/global.png','3')],nodes); n+=1
    scene('scenes/world/ocean/Ocean.tscn',[('Script','res://scripts/world/ocean.gd','1'),('Script','res://scripts/world/player.gd','2'),('Texture2D','res://Assets/charfree/global.png','3')],[('Ocean','Node2D',None,{'script':ER('1')}),('Background','ColorRect','.',{'offset_right':1280.0,'offset_bottom':720.0,'color':Raw('Color(0.03, 0.09, 0.18, 1)')}),('Player','CharacterBody2D','.',{'script':ER('2'),'position':Raw('Vector2(640, 360)')}),('Sprite','Sprite2D','Player',{'texture':ER('3'),'scale':Raw('Vector2(2, 2)')}),('Camera2D','Camera2D','.',{'enabled':True,'position_smoothing_enabled':True,'position_smoothing_speed':5.0}),('ZoneHolder','Node2D','.',{}),('HintLabel','Label','.',{'offset_left':24.0,'offset_top':24.0,'text':'Cast with SPACE. Swim up to surface.'})]); n+=1
    for i,s in enumerate(['Shallows','KelpForest','SunkenRuins','BiolumDeep'],1):
        scene(f'scenes/world/ocean/OceanZone{i}_{s}.tscn',[('Script','res://scripts/world/ocean_zone.gd','1')],[(f'OceanZone{i}_{s}','Node2D',None,{'script':ER('1')}),('Tint','ColorRect','.',{'offset_right':1280.0,'offset_bottom':720.0,'color':Raw(f'Color(0.0, 0.12, {0.2+i*0.08:.2f}, 0.4)')})]); n+=1
    def p(path,script,name,body):
        scene(path,[('Script',script,'1')],[(name,'CanvasLayer',None,{'script':ER('1')}),*body])
    p('scenes/ui/MainMenu.tscn','res://scripts/ui/main_menu.gd','MainMenu',[('Panel','Panel','.',{'offset_left':420.0,'offset_top':180.0,'offset_right':860.0,'offset_bottom':540.0}),('NewGameButton','Button','Panel',{'offset_left':120.0,'offset_top':120.0,'offset_right':320.0,'offset_bottom':164.0,'text':'New Game'}),('ContinueButton','Button','Panel',{'offset_left':120.0,'offset_top':186.0,'offset_right':320.0,'offset_bottom':230.0,'text':'Continue'}),('SettingsButton','Button','Panel',{'offset_left':120.0,'offset_top':252.0,'offset_right':320.0,'offset_bottom':296.0,'text':'Settings'})]); n+=1
    p('scenes/ui/Shop.tscn','res://scripts/ui/shop.gd','Shop',[('Panel','Panel','.',{'offset_left':120.0,'offset_top':60.0,'offset_right':1160.0,'offset_bottom':660.0}),('RodsList','ItemList','Panel',{'offset_left':20.0,'offset_top':20.0,'offset_right':300.0,'offset_bottom':260.0}),('BaitsList','ItemList','Panel',{'offset_left':320.0,'offset_top':20.0,'offset_right':600.0,'offset_bottom':260.0}),('KnivesList','ItemList','Panel',{'offset_left':620.0,'offset_top':20.0,'offset_right':900.0,'offset_bottom':260.0}),('InfoLabel','Label','Panel',{'offset_left':20.0,'offset_top':290.0,'offset_right':620.0,'offset_bottom':430.0,'autowrap_mode':3}),('FinnLineLabel','Label','Panel',{'offset_left':640.0,'offset_top':290.0,'offset_right':990.0,'offset_bottom':430.0,'autowrap_mode':3}),('BuyButton','Button','Panel',{'offset_left':20.0,'offset_top':470.0,'offset_right':200.0,'offset_bottom':514.0,'text':'Buy Selected'}),('DebtAmountSpinBox','SpinBox','Panel',{'offset_left':240.0,'offset_top':470.0,'offset_right':440.0,'offset_bottom':514.0}),('PayDebtButton','Button','Panel',{'offset_left':460.0,'offset_top':470.0,'offset_right':660.0,'offset_bottom':514.0,'text':'Pay Debt'}),('CloseButton','Button','Panel',{'offset_left':820.0,'offset_top':540.0,'offset_right':1000.0,'offset_bottom':584.0,'text':'Close'})]); n+=1
    p('scenes/ui/Inventory.tscn','res://scripts/ui/inventory_ui.gd','Inventory',[('Panel','Panel','.',{'offset_left':220.0,'offset_top':80.0,'offset_right':1060.0,'offset_bottom':640.0}),('FishList','ItemList','Panel',{'offset_left':24.0,'offset_top':24.0,'offset_right':560.0,'offset_bottom':420.0}),('SellAllButton','Button','Panel',{'offset_left':24.0,'offset_top':460.0,'offset_right':220.0,'offset_bottom':504.0,'text':'Sell All'}),('FiletButton','Button','Panel',{'offset_left':240.0,'offset_top':460.0,'offset_right':436.0,'offset_bottom':504.0,'text':'Filet Selected'}),('CloseButton','Button','Panel',{'offset_left':620.0,'offset_top':460.0,'offset_right':816.0,'offset_bottom':504.0,'text':'Close'})]); n+=1
    p('scenes/ui/CraftingMenu.tscn','res://scripts/ui/crafting_menu.gd','CraftingMenu',[('Panel','Panel','.',{'offset_left':180.0,'offset_top':60.0,'offset_right':1100.0,'offset_bottom':660.0}),('RecipeList','ItemList','Panel',{'offset_left':24.0,'offset_top':24.0,'offset_right':340.0,'offset_bottom':500.0}),('DetailLabel','Label','Panel',{'offset_left':380.0,'offset_top':24.0,'offset_right':860.0,'offset_bottom':500.0,'autowrap_mode':3}),('CraftButton','Button','Panel',{'offset_left':380.0,'offset_top':530.0,'offset_right':580.0,'offset_bottom':574.0,'text':'Craft'}),('CloseButton','Button','Panel',{'offset_left':620.0,'offset_top':530.0,'offset_right':820.0,'offset_bottom':574.0,'text':'Close'})]); n+=1
    p('scenes/ui/Codex.tscn','res://scripts/ui/codex.gd','Codex',[('Panel','Panel','.',{'offset_left':140.0,'offset_top':40.0,'offset_right':1140.0,'offset_bottom':680.0}),('FishList','ItemList','Panel',{'offset_left':24.0,'offset_top':24.0,'offset_right':320.0,'offset_bottom':560.0}),('FishDetails','Label','Panel',{'offset_left':360.0,'offset_top':24.0,'offset_right':940.0,'offset_bottom':560.0,'autowrap_mode':3}),('CompletionLabel','Label','Panel',{'offset_left':24.0,'offset_top':584.0,'text':'0 / 40 discovered'}),('CloseButton','Button','Panel',{'offset_left':780.0,'offset_top':584.0,'offset_right':940.0,'offset_bottom':628.0,'text':'Close'})]); n+=1
    p('scenes/ui/DayEndSummary.tscn','res://scripts/ui/day_end_summary.gd','DayEndSummary',[('Panel','Panel','.',{'offset_left':180.0,'offset_top':40.0,'offset_right':1100.0,'offset_bottom':680.0}),('DayLabel','Label','Panel',{'offset_left':24.0,'offset_top':20.0,'text':'Day 1 Summary'}),('FishListLabel','Label','Panel',{'offset_left':24.0,'offset_top':70.0,'offset_right':400.0,'offset_bottom':400.0,'autowrap_mode':3}),('EarnedLabel','Label','Panel',{'offset_left':480.0,'offset_top':90.0,'text':'Total Earned Today: $0.00'}),('PaidLabel','Label','Panel',{'offset_left':480.0,'offset_top':140.0,'text':'Debt Paid Today: $0.00'}),('InterestLabel','Label','Panel',{'offset_left':480.0,'offset_top':190.0,'text':'Interest Added: $0.00'}),('DebtLabel','Label','Panel',{'offset_left':480.0,'offset_top':240.0,'text':'New Debt Total: $0.00'}),('DaysRemainingLabel','Label','Panel',{'offset_left':480.0,'offset_top':290.0,'text':'Days Remaining: 6'}),('NextDayButton','Button','Panel',{'offset_left':620.0,'offset_top':520.0,'offset_right':860.0,'offset_bottom':566.0,'text':'Next Day ->'})]); n+=1
    p('scenes/ui/WinScreen.tscn','res://scripts/ui/win_screen.gd','WinScreen',[('Panel','Panel','.',{'offset_left':220.0,'offset_top':120.0,'offset_right':1060.0,'offset_bottom':600.0}),('TitleLabel','Label','Panel',{'offset_left':36.0,'offset_top':28.0,'text':'DEBT CLEARED! You paid off Finn!'}),('StatsLabel','Label','Panel',{'offset_left':36.0,'offset_top':110.0,'offset_right':500.0,'offset_bottom':240.0,'autowrap_mode':3}),('DialogueLabel','Label','Panel',{'offset_left':36.0,'offset_top':270.0,'offset_right':760.0,'offset_bottom':390.0,'autowrap_mode':3}),('PlayAgainButton','Button','Panel',{'offset_left':540.0,'offset_top':400.0,'offset_right':740.0,'offset_bottom':446.0,'text':'Play Again'})]); n+=1
    p('scenes/ui/GameOverScreen.tscn','res://scripts/ui/game_over_screen.gd','GameOverScreen',[('Panel','Panel','.',{'offset_left':260.0,'offset_top':160.0,'offset_right':1020.0,'offset_bottom':560.0}),('ReasonLabel','Label','Panel',{'offset_left':36.0,'offset_top':38.0,'offset_right':700.0,'offset_bottom':120.0,'autowrap_mode':3}),('StatsLabel','Label','Panel',{'offset_left':36.0,'offset_top':150.0,'offset_right':520.0,'offset_bottom':260.0,'autowrap_mode':3}),('TryAgainButton','Button','Panel',{'offset_left':420.0,'offset_top':290.0,'offset_right':620.0,'offset_bottom':336.0,'text':'Try Again'})]); n+=1
    p('scenes/ui/FishCaughtPopup.tscn','res://scripts/ui/fish_caught_popup.gd','FishCaughtPopup',[('Panel','Panel','.',{'offset_left':760.0,'offset_top':120.0,'offset_right':1060.0,'offset_bottom':260.0}),('NameLabel','Label','Panel',{'offset_left':20.0,'offset_top':18.0,'text':'Fish'}),('ValueLabel','Label','Panel',{'offset_left':20.0,'offset_top':62.0,'text':'$0.00'}),('StarsLabel','Label','Panel',{'offset_left':20.0,'offset_top':96.0,'text':''})]); n+=1
    p('scenes/ui/TutorialArrow.tscn','res://scripts/ui/tutorial_arrow.gd','TutorialArrow',[('Arrow','Label','.',{'text':'v'})]); n+=1
    p('scenes/ui/TutorialPrompt.tscn','res://scripts/ui/tutorial_prompt.gd','TutorialPrompt',[('Panel','Panel','.',{'offset_left':420.0,'offset_top':80.0,'offset_right':920.0,'offset_bottom':160.0}),('PromptLabel','Label','Panel',{'offset_left':16.0,'offset_top':14.0,'offset_right':460.0,'offset_bottom':60.0,'autowrap_mode':3})]); n+=1
    scene('scenes/ui/TransitionLayer.tscn',[],[('TransitionLayer','CanvasLayer',None,{}),('FadeRect','ColorRect','.',{'offset_right':1280.0,'offset_bottom':720.0,'color':Raw('Color(0, 0, 0, 0)'),'visible':False})]); n+=1
    for nm,(script,nodes) in {
        'CastMinigame':('res://scripts/minigames/cast_minigame.gd',[('FillBar','ColorRect','.',{'anchor_left':0.47,'anchor_top':1.0,'anchor_right':0.53,'anchor_bottom':1.0,'offset_top':-320.0,'color':Raw('Color(0.2, 0.7, 1.0, 0.8)')}),('SweetSpot','ColorRect','.',{'anchor_left':0.46,'anchor_top':0.8,'anchor_right':0.54,'anchor_bottom':1.0,'offset_top':-320.0,'offset_bottom':-260.0,'color':Raw('Color(0.3, 1.0, 0.4, 0.8)')}),('ResultLabel','Label','.',{'offset_left':560.0,'offset_top':520.0}),('TutorialLabel','Label','.',{'offset_left':360.0,'offset_top':80.0,'offset_right':980.0,'autowrap_mode':3})]),
        'ReelMinigame':('res://scripts/minigames/reel_minigame.gd',[('Marker','ColorRect','.',{'anchor_left':0.82,'anchor_top':0.5,'anchor_right':0.88,'anchor_bottom':0.55,'color':Raw('Color(1, 0.9, 0.2, 1)')}),('TimerLabel','Label','.',{'offset_left':980.0,'offset_top':60.0}),('TutorialLabel','Label','.',{'offset_left':320.0,'offset_top':80.0,'offset_right':940.0,'autowrap_mode':3}),('Blackout','ColorRect','.',{'offset_right':1280.0,'offset_bottom':720.0,'color':Raw('Color(0, 0, 0, 0.65)'),'visible':False})]),
        'CatchMinigame':('res://scripts/minigames/catch_minigame.gd',[('DangerZone','ColorRect','.',{'anchor_left':0.2,'anchor_top':0.82,'anchor_right':0.38,'anchor_bottom':0.88,'color':Raw('Color(0.9, 0.2, 0.2, 0.8)')}),('DangerZone2','ColorRect','.',{'anchor_left':0.6,'anchor_top':0.74,'anchor_right':0.7,'anchor_bottom':0.8,'color':Raw('Color(1.0, 0.4, 0.1, 0.8)')}),('Crosshair','ColorRect','.',{'anchor_left':0.5,'anchor_top':0.8,'anchor_right':0.52,'anchor_bottom':0.9,'color':Raw('Color(1, 1, 1, 1)')}),('TimerLabel','Label','.',{'offset_left':580.0,'offset_top':520.0}),('TutorialLabel','Label','.',{'offset_left':300.0,'offset_top':90.0,'offset_right':960.0,'autowrap_mode':3})]),
        'FiletMinigame':('res://scripts/minigames/filet_minigame.gd',[('ScoreLabel','Label','.',{'offset_left':40.0,'offset_top':36.0,'text':'Filet Score: 0%'}),('QTELabel','Label','.',{'offset_left':580.0,'offset_top':80.0,'text':''})])}.items():
        p(f'scenes/minigames/{nm}.tscn',script,nm,nodes); n+=1
    for nm,life,col in [('Jellyfish',4,'Color(0.5, 0.8, 1.0, 0.8)'),('ElectricEel',3,'Color(1.0, 1.0, 0.3, 0.8)'),('Shark',4,'Color(0.7, 0.7, 0.8, 0.9)'),('Octopus',4,'Color(0.55, 0.2, 0.55, 0.85)'),('Turtle',5,'Color(0.3, 0.8, 0.4, 0.85)'),('LeviathanHazard',3,'Color(0.1, 0.1, 0.1, 0.95)')]:
        scene(f'scenes/hazards/{nm}.tscn',[('Script','res://scripts/effects/auto_free.gd','1')],[(nm,'Node2D',None,{'script':ER('1'),'lifetime':float(life)}),('Body','ColorRect','.',{'offset_right':120.0,'offset_bottom':60.0,'color':Raw(col)})]); n+=1
    for nm,typ,life,col in [('WaterSplash','Node2D',1,'Color(0.5, 0.8, 1.0, 0.6)'),('BubbleTrail','Node2D',1.2,'Color(0.6, 0.9, 1.0, 0.4)'),('CatchFlash','Node2D',0.5,'Color(1.0, 1.0, 1.0, 0.8)'),('CoinParticle','Node2D',1.4,'Color(1.0, 0.8, 0.2, 0.8)'),('BiolumParticle','Node2D',2.0,'Color(0.2, 0.8, 1.0, 0.6)'),('DepthFog','CanvasLayer',0,'Color(0.0, 0.05, 0.12, 0.5)'),('DayNightOverlay','CanvasLayer',0,'Color(0.0, 0.05, 0.2, 0.3)'),('SharkWarningVignette','CanvasLayer',3,'Color(0.7, 0.1, 0.1, 0.35)'),('LeviathanShake','Node2D',2,'Color(0.1, 0.1, 0.1, 0.4)')]:
        ex=[] if life==0 else [('Script','res://scripts/effects/auto_free.gd','1')]
        props={} if life==0 else {'script':ER('1'),'lifetime':float(life)}
        scene(f'scenes/effects/{nm}.tscn',ex,[(nm,typ,None,props),('Visual','ColorRect','.',{'offset_right':1280.0,'offset_bottom':720.0,'color':Raw(col)})]); n+=1
    return n

if __name__=='__main__':
    print(f'generated {gen_res()} resources and {gen_scenes()} scenes')

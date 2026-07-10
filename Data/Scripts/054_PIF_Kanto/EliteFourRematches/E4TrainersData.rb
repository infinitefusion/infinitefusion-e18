#Levels relative to 50 (actual level is adjusted dynamically depending on the type of rematch)


E4_POKEMON_POOL = {
  :ELITEFOUR_Lorelei => [
    #original league team
    {:species => [:MAGMORTAR,:DEWGONG],   :level => 4, :ability => :FLAMEBODY,  :moves => [:BUBBLEBEAM,:FLAMETHROWER,:HAIL,:PROTECT],         :item => :NEVERMELTICE , :tier => 1},
    {:species => [:MAMOSWINE,:SLOWBRO],   :level => 4, :ability => :OBLIVIOUS,  :moves => [:HAIL,:SLACKOFF,:TAKEDOWN,:ICEFANG],               :item => :NEVERMELTICE, :tier => 1},
    {:species => [:TENTACRUEL,:CLOYSTER], :level => 3, :ability => :SHELLARMOR, :moves => [:SPIKES,:STEALTHROCK,:WATERPULSE,:ICICLECRASH],    :item => :NEVERMELTICE, :tier => 1},
    {:species => [:JYNX,:TANGROWTH],      :level => 7, :ability => :OBLIVIOUS,  :moves => [:LEECHSEED,:DRAININGKISS,:SLEEPPOWDER,:ICEPUNCH],  :item => :NEVERMELTICE, :tier => 1},
    {:species => [:WEAVILE,:LAPRAS],      :level => 7, :ability => :PRESSURE,   :moves => [:PERISHSONG,:NIGHTSLASH,:SURF,:EMBARGO],           :item => :NEVERMELTICE, :tier => 1},
    #reserve
    #TIER 2
    {:species => [:GLACEON,:SANDSLASH],      :level => 3, :ability => :ICEBODY,   :moves => [:HAIL,:EARTHPOWER,:ICEBEAM,:BATONPASS],           :item => :QUICKCLAW, :tier => 2},
    {:species => [:FROSLASS,:HYPNO],      :level => 4, :ability => :CURSEDBODY,   :moves => [:CALMMIND,:LIGHTSCREEN,:ICEPUNCH,:SHADOWBALL],           :item => :ICEGEM, :tier => 2},

    #TIER 3
    {:species => [:GLALIE,:ZOROARK],    :level => 3, :item => :NORMALGEM, :ability => :ILLUSION,  :nature => :JOLLY, :moves => [:KNOCKOFF,:SHEERCOLD,:EXPLOSION,:BLIZZARD],    :tier => 3},
    {:species => [:DELIBIRD,:WHIMSICOTT],   :level => 5, :item => :FOCUSSASH, :ability => :SNOWWARNING,  :nature => :HASTY, :moves => [:MOONBLAST,:BLIZZARD,:ENDEAVOR,:MEMENTO],    :tier => 3},
    {:species => [:JYNX,:NINJASK],  :level => 9, :ability => :DRYSKIN,  :nature => :BRAVE,   :moves => [:FAKEOUT,:ICEBEAM,:DIG,:UTURN],     :item => :LIFEORB, :tier => 3},

    #TIER 4
    {:species => [:REUNICLUS,:AURORUS],   :level => 4, :item => :COLBURBERRY, :ability => :SNOWWARNING,  :nature => :MODEST, :moves => [:PSYCHIC,:BLIZZARD,:EARTHPOWER,:STEALTHROCK],    :tier => 4},
    {:species => [:FROSLASS,:NIDOKING],   :level => 3, :item => :LIFEORB, :ability => :SHEERFORCE,  :nature => :MODEST, :moves => [:THUNDERBOLT,:BLIZZARD,:EARTHPOWER,:DESTINYBOND],    :tier => 4},
    {:species => [:GLACEON,:SCIZOR],   :level => 5, :item => :SITRUSBERRY, :ability => :TECHNICIAN,  :nature => :MODEST, :moves => [:QUIVERDANCE,:FROSTBREATH,:HIDDENPOWER,:OMINOUSWIND],    :tier => 4},
    {:species => [:AMPHAROS,:BEWEAR],      :level => 5, :ability => :FLUFFY, :moves => [:THUNDERWAVE,:DISCHARGE,:DRAINPUNCH,:BODYSLAM],   :nature => :RELAXED,     :item => :LEFTOVERS, :tier => 4},

    #TIER 5
    {:species => [:MILOTIC,:AURORUS],   :level => 6, :item => :LEFTOVERS, :ability => :SNOWWARNING,  :nature => :CALM, :moves => [:SCALD,:FREEZEDRY,:RECOVER,:ROAR],    :tier => 5},
    {:species => [:GLACEON,:NIDOKING],   :level => 7, :item => :LIFEORB, :ability => :SHEERFORCE,  :nature => :MODEST, :moves => [:BLIZZARD,:EARTHPOWER,:AURORAVEIL,:FLAMETHROWER],    :tier => 5},
    {:species => [:PILOSWINE,:SLAKING],   :level => 5, :item => :EVIOLITE, :ability => :THICKFAT,  :nature => :ADAMANT, :moves => [:FACADE,:ICEPUNCH,:SLACKOFF,:EARTHQUAKE],    :tier => 5},
    {:species => [:MAMOSWINE,:BRELOOM],      :level => 7, :ability => :TECHNICIAN,   :moves => [:ICESHARD,:MACHPUNCH,:ICICLESPEAR,:BULLETSEED],           :item => :CHOICEBAND, :tier => 5},
    {:species => [:MILOTIC,:SCIZOR],   :level => 5, :item => :SITRUSBERRY, :ability => :TECHNICIAN,  :nature => :MODEST, :moves => [:QUIVERDANCE,:FROSTBREATH,:HIDDENPOWER,:OMINOUSWIND],    :tier => 5},
  ],

  :ELITEFOUR_Bruno => [
    #original league team
    {:species => [:MACHAMP,:ELECTIVIRE],  :level => 3, :ability => :NOGUARD,    :moves => [:THUNDERPUNCH,:CROSSCHOP,:DISCHARGE,:FOCUSENERGY], :item => :BLACKBELT, :tier => 1},
    {:species => [:SCIZOR,:HERACROSS],    :level => 7, :ability => :SWARM,      :moves => [:XSCISSOR,:SWORDSDANCE,:CLOSECOMBAT,:AGILITY],     :item => :BLACKBELT, :tier => 1},
    {:species => [:MAROWAK,:HITMONCHAN],  :level => 4, :ability => :IRONFIST,   :moves => [:DYNAMICPUNCH,:BONEMERANG,:DOUBLETEAM,:COUNTER],  :item => :BLACKBELT, :tier => 1},
    {:species => [:STEELIX,:MACHAMP],     :level => 3, :ability => :STURDY,     :moves => [:SANDSTORM,:IRONTAIL,:SUBMISSION,:CRUNCH],        :item => :BLACKBELT, :tier => 1},
    {:species => [:MAGNEZONE,:ONIX],      :level => 7, :ability => :MAGNETPULL, :moves => [:ZAPCANNON,:MAGNETRISE,:LOCKON,:IRONTAIL],        :item => :BLACKBELT, :tier => 1},
    #reserve
    #TIER 2
    {:species => [:LUCARIO,:BUTTERFREE],      :level => 5, :ability => :COMPOUNDEYES, :moves => [:QUIVERDANCE,:FOCUSBLAST,:SWAGGER,:AIRSLASH],        :item => :RAZORFANG, :tier => 2},
    {:species => [:MILTANK,:PRIMEAPE],      :level => 4, :ability => :SCRAPPY, :moves => [:FINALGAMBIT,:CLOSECOMBAT,:FACADE,:UTURN],   :nature => :ADAMANT,   :item => :CHOICESCARF, :tier => 2},

    #TIER 3
    {:species => [:AMPHAROS,:BEWEAR],      :level => 5, :ability => :FLUFFY, :moves => [:THUNDERWAVE,:DISCHARGE,:DRAINPUNCH,:BODYSLAM],   :nature => :RELAXED,     :item => :LEFTOVERS, :tier => 3},
    {:species => [:TENTACRUEL,:CHESNAUGHT],      :level => 4, :ability => :LIQUIDOOZE, :moves => [:TOXICSPIKES,:LEECHSEED,:MUDDYWATER,:DRAINPUNCH], :nature => :SASSY,       :item => :LEFTOVERS, :tier => 3},
    {:species => [:TOXAPEX,:SCRAFTY],      :level => 6, :ability => :SHEDSKIN, :moves => [:POISONJAB,:REST,:SLEEPTALK,:CRUNCH],   :nature => :CAREFUL,   :item => :BLACKSLUDGE, :tier => 3},

    #TIER 4
    {:species => [:MAGMORTAR,:INFERNAPE],   :level => 3, :item => :SITRUSBERRY, :ability => :FLAMEBODY,  :nature => :TIMID, :moves => [:SEARINGSHOT,:FOCUSBLAST,:THUNDERBOLT,:CALMMIND],    :tier => 4},
    {:species => [:MACHAMP,:METAGROSS],   :level => 6, :item => :REDCARD, :ability => :NOGUARD,  :nature => :ADAMANT, :moves => [:DYNAMICPUNCH,:ZENHEADBUTT,:DARKESTLARIAT,:EXPLOSION],    :tier => 4},
    {:species => [:HITMONLEE,:RAMPARDOS],   :level => 5, :item => :FOCUSSASH, :ability => :UNBURDEN,  :nature => :LONELY, :moves => [:CLOSECOMBAT,:STONEEDGE,:EARTHQUAKE,:REVERSAL],    :tier => 4},
    {:species => [:LUCARIO,:WHIMSICOTT],   :level => 3, :item => :BLACKSLUDGE, :ability => :PRANKSTER,  :nature => :MODEST, :moves => [:COPYCAT,:MOONBLAST,:FOCUSBLAST,:LEECHSEED],    :tier => 4},

    #TIER 5
    {:species => [:PORYGONZ,:BLAZIKEN],   :level => 6, :item => :CHOPLEBERRY, :ability => :ADAPTABILITY,  :nature => :TIMID, :moves => [:TRIATTACK,:FOCUSBLAST,:DARKPULSE,:WILLOWISP],    :tier => 5},
    {:species => [:LUCARIO,:SYLVEON],   :level => 4, :item => :PAYAPABERRY, :ability => :PIXILATE,  :nature => :ADAMANT, :moves => [:SWORDSDANCE,:EXTREMESPEED,:DRAINPUNCH,:EARTHQUAKE],    :tier => 5},
    {:species => [:MINIOR_M,:KOMMOO],   :level => 5, :item => :WHITEHERB, :ability => :SHIELDSDOWN,  :nature => :ADAMANT, :moves => [:SHELLSMASH,:CLOSECOMBAT,:EXTREMESPEED,:EARTHQUAKE],    :tier => 5},
    {:species => [:BLISSEY,:BRELOOM],   :level => 6, :item => :TOXICORB, :ability => :POISONHEAL,  :nature => :ADAMANT, :moves => [:LEECHSEED,:FACADE,:BULKUP,:FIREPUNCH],    :tier => 5},
    {:species => [:SALAMENCE,:GALLADE],   :level => 4, :item => :SITRUSBERRY, :ability => :INTIMIDATE,  :nature => :ADAMANT, :moves => [:DRAGONDANCE,:DRAINPUNCH,:DRAGONCLAW,:POISONJAB],    :tier => 5},
  ],

  :ELITEFOUR_Agatha => [
    #original league team
    {:species => [:MISMAGIUS,:CROBAT],    :level => 7, :ability => :LEVITATE,   :moves => [:WINGATTACK,:SHADOWBALL,:CONFUSERAY,:MEANLOOK],   :item => :SPELLTAG, :tier => 1},
    {:species => [:GENGAR,:HOUNDOOM],     :level => 5, :ability => :EARLYBIRD,  :moves => [:INFERNO,:SPITE,:DESTINYBOND,:SHADOWBALL],        :item => :SPELLTAG, :tier => 1},
    {:species => [:UMBREON,:HAUNTER],     :level => 5, :ability => :LEVITATE,   :moves => [:GUARDSWAP,:DARKPULSE,:MOONLIGHT,:NIGHTSHADE],    :item => :SPELLTAG, :tier => 1},
    {:species => [:SNORLAX,:GENGAR],      :level => 8, :ability => :LEVITATE,   :moves => [:REST,:CURSE,:BODYSLAM,:SHADOWPUNCH],             :item => :SPELLTAG, :tier => 1},
    {:species => [:WOBBUFFET,:GENGAR],    :level => 5, :ability => :SHADOWTAG,  :moves => [:DESTINYBOND,:COUNTER,:MIRRORCOAT,:CURSE],        :item => :SPELLTAG, :tier => 1},
    #reserve
    #TIER 2


    #TIER 3
    {:species => [:SMEARGLE,:FROSLASS],    :level => 5, :ability => :MOODY,   :moves => [:BOOMBURST,:SEARINGSHOT,:NUZZLE,:DESTINYBOND],   :item => :FOCUSSASH, :nature => :TIMID, :tier => 3},
    {:species => [:AEGISLASH,:SABLEYE],    :level =>6, :ability => :PRANKSTER,   :moves => [:DESTINYBOND,:METALBURST,:SPECTRALTHIEF,:GYROBALL],   :item => :LEFTOVERS, :nature => :SASSY, :tier => 3},
    {:species => [:BANETTE,:HERACROSS],   :level => 4, :item => :CHOICESCARF, :ability => :MOXIE,  :nature => :ADAMANT, :moves => [:SPECTRALTHIEF,:CLOSECOMBAT,:KNOCKOFF,:EARTHQUAKE],    :tier => 3},

    #TIER 4
    {:species => [:DHELMISE,:GYARADOS],    :level => 7, :ability => :INTIMIDATE,   :moves => [:DRAGONDANCE,:PHANTOMFORCE,:BOUNCE,:ANCHORSHOT],   :item => :LEFTOVERS, :nature => :JOLLY, :tier => 4},
    {:species => [:TANGROWTH,:TREVENANT],    :level => 6, :ability => :HARVEST,   :moves => [:LEECHSEED,:HORNLEECH,:PHANTOMFORCE,:WILLOWISP],   :item => :SITRUSBERRY, :nature => :CAREFUL, :tier => 4},
    {:species => [:CHANDELURE,:SCOLIPEDE],    :level => 5, :ability => :SPEEDBOOST,   :moves => [:HEX,:SLUDGEBOMB,:INFERNO,:WILLOWISP],   :item => :PETAYABERRY, :nature => :MODEST, :tier => 4},
    {:species => [:LANTURN,:SHEDINJA],    :level => 5, :ability => :WONDERGUARD,   :moves => [:VOLTSWITCH,:SPIRITSHACKLE,:SCALD,:THUNDERWAVE],   :item => :SAFETYGOGGLES, :nature => :RASH, :tier => 4},

    #TIER 5
    {:species => [:COFAGRIGUS,:KOMMOO],    :level => 5, :ability => :SOUNDPROOF,   :moves => [:TOXICSPIKES,:SPIRITSHACKLE,:SKYUPPERCUT,:EARTHQUAKE],   :item => :REDCARD, :nature => :BRAVE, :tier => 5},
    {:species => [:VAPOREON,:SPIRITOMB],    :level => 7, :ability => :PRESSURE,   :moves => [:REST,:SLEEPTALK,:SCALD,:SPIRITSHACKLE],   :item => :LEFTOVERS, :nature => :SASSY, :tier => 5},
    {:species => [:DRIFBLIM,:HYDREIGON],    :level => 6, :ability => :UNBURDEN,   :moves => [:NASTYPLOT,:SHADOWBALL,:DRACOMETEOR,:OBLIVIONWING],   :item => :AIRBALLOON, :nature => :MODEST, :tier => 5},
    {:species => [:BANETTE,:CLOYSTER],    :level => 8, :ability => :SKILLLINK,   :moves => [:SHELLSMASH,:SPECTRALTHIEF,:ICICLESPEAR,:FACADE],   :item => :FOCUSSASH, :nature => :ADAMANT, :tier => 5},
    {:species => [:MIMIKYU,:GALLADE],    :level => 6, :ability => :DISGUISE,   :moves => [:SWORDSDANCE,:DRAINPUNCH,:SHADOWSNEAK,:LEAFBLADE],   :item => :FOCUSSASH, :nature => :ADAMANT, :tier => 4},
  ],

  :ELITEFOUR_Lance => [
    #original league team
    {:species => [:DRAGONAIR,:GYARADOS],  :level => 5, :ability => :SHEDSKIN,   :moves => [:OUTRAGE,:THUNDERWAVE,:HYDROPUMP,:RAINDANCE],     :item => :DRAGONFANG, :tier => 1},
    {:species => [:PORYGON2,:KINGDRA],    :level => 4, :ability => :TRACE,      :moves => [:TRIATTACK,:DRAGONDANCE,:DRAGONPULSE,:RECOVER],   :item => :DRAGONFANG, :tier => 1},
    {:species => [:TYRANITAR,:AERODACTYL],:level => 9, :ability => :PRESSURE,   :moves => [:BRAVEBIRD,:HEADSMASH,:AGILITY,:DRAGONRUSH],      :item => :DRAGONFANG, :tier => 1},
    {:species => [:TYPHLOSION,:DRAGONAIR],:level => 7, :ability => :BLAZE,      :moves => [:FIREBLAST,:DRAGONTAIL,:DRAGONDANCE,:WILLOWISP],  :item => :DRAGONFANG, :tier => 1},
    {:species => [:TOGEKISS,:DRAGONITE],  :level => 8, :ability => :HUSTLE,     :moves => [:MOONBLAST,:OUTRAGE,:ANCIENTPOWER,:AIRSLASH],     :item => :DRAGONFANG, :tier => 1},
    #reserve
    #TIER 2
    {:species => [:FERALIGATR,:SALAMENCE],   :level => 9, :item => :ADRENALINEORB, :ability => :INTIMIDATE, :moves => [:THUNDERFANG,:AQUATAIL,:DRAGONCLAW,:FLY],    :tier => 2},
    {:species => [:CHARIZARD,:HAXORUS],   :level => 9, :item => :CHARCOAL, :ability => :MOLDBREAKER, :moves => [:FLAREBLITZ,:GUILLOTINE,:DRAGONRUSH,:CRUNCH],    :tier => 2},

    #TIER 3
    {:species => [:SYLVEON,:NOIVERN],   :level => 6, :item => :CHOICESPECS, :ability => :PIXILATE,  :nature => :TIMID, :moves => [:BOOMBURST,:DRAGONPULSE,:FLAMETHROWER,:SHADOWBALL],    :tier => 3},
    {:species => [:HAXORUS,:SCIZOR],   :level => 6, :item => :LIFEORB, :ability => :TECHNICIAN,  :nature => :JOLLY, :moves => [:SWORDSDANCE,:DUALCHOP,:BULLETPUNCH,:EARTHQUAKE],    :tier => 3},
    {:species => [:KOMMOO,:YANMEGA],   :level => 7, :item => :LEFTOVERS, :ability => :TINTEDLENS,  :nature => :MODEST, :moves => [:QUIVERDANCE,:CLANGINGSCALES,:AIRSLASH,:GIGADRAIN],    :tier => 3},

    #TIER 4
    {:species => [:DRAGONITE,:AURORUS],   :level => 7, :item => :CHOICEBAND, :ability => :REFRIGERATE,  :nature => :JOLLY, :moves => [:EXTREMESPEED,:OUTRAGE,:RETURN,:EARTHQUAKE],    :tier => 4},
    {:species => [:SALAMENCE,:DOUBLADE],   :level => 8, :item => :EVIOLITE, :ability => :INTIMIDATE,  :nature => :IMPISH, :moves => [:SPECTRALTHIEF,:ROOST,:TOXIC,:DRAGONTAIL],    :tier => 4},
    {:species => [:GARCHOMP,:URSARING],   :level => 7, :item => :FLAMEORB, :ability => :GUTS,  :nature => :ADAMANT, :moves => [:FACADE,:EARTHQUAKE,:DRAGONCLAW,:DRAGONDANCE],    :tier => 4},
    {:species => [:PORYGONZ,:NOIVERN],  :level => 5, :ability => :ADAPTABILITY,  :nature => :MODEST,   :moves => [:BOOMBURST,:DRAGONCLAW,:TRIATTACK,:WHIRLWIND],     :item => :ASSAULTVEST, :tier => 4},

    #TIER 5
    {:species => [:BLISSEY,:GOODRA],  :level => 8, :ability => :ADAPTABILITY,  :nature => :NATURALCURE,   :moves => [:RECOVER,:CALMMIND,:DRAGONPULSE,:FLAMETHROWER],     :item => :CHOPLEBERRY, :tier => 5},
    {:species => [:URSARING,:DRAGONITE],  :level => 6, :ability => :GUTS,  :nature => :ADAMANT,   :moves => [:SWORDSDANCE,:FIREPUNCH,:EXTREMESPEED,:FACADE],     :item => :FLAMEORB, :tier => 5},
    {:species => [:RAMPARDOS,:HYDREIGON],  :level => 8, :ability => :HUSTLE,  :nature => :ADAMANT,   :moves => [:DRAGONDANCE,:HEADSMASH,:OUTRAGE,:EARTHQUAKE],     :item => :FOCUSSASH, :tier => 5},
    {:species => [:TYRANITAR,:HITMONLEE],  :level => 7, :ability => :UNBURDEN,  :nature => :ADAMANT,   :moves => [:FAKEOUT,:CLOSECOMBAT,:ROCKSLIDE,:EARTHQUAKE],     :item => :NORMALGEM, :tier => 5},
    {:species => [:SNORLAX,:FLYGON],  :level => 7, :ability => :THICKFAT,  :nature => :CAREFUL,   :moves => [:BODYSLAM,:DRAGONTAIL,:GUNKSHOT,:ICEBEAM],     :item => :LEFTOVERS, :tier => 5},



  ],

  #Starter is always added to the team, no matter what
  :CHAMPION => [
    #original league team
    {:species => [:MAROWAK,:PIDGEOT],      :level => 9, :ability => :POISONPOINT,     :moves => [:EARTHQUAKE,:WINGATTACK,:DOUBLETEAM,:SWORDSDANCE],:item => :LAXINCENSE, :tier => 1},
    {:species => [:TAUROS,:EXEGGUTOR],     :level => 9, :ability => :CHLOROPHYLL,     :moves => [:ZENHEADBUTT,:GIGAIMPACT,:SCARYFACE,:SWAGGER],    :item => :KINGSROCK, :tier => 1},
    {:species => [:RHYPERIOR,:MAGMORTAR],     :level => 10,:ability => :LIGHTNINGROD,     :moves => [:FIREBLAST,:DRILLRUN,:WILLOWISP,:STONEEDGE],      :item => :ABSORBBULB, :tier => 1},
    {:species => [:ELECTABUZZ,:GYARADOS],  :level => 11,:ability => :INTIMIDATE,     :moves => [:RAINDANCE,:THUNDERPUNCH,:WATERFALL,:DRAGONDANCE],:item => :DAMPROCK, :tier => 1},
    {:species => [:STARMIE,:ALAKAZAM],     :level => 8, :ability => :ILLUMINATE,     :moves => [:PSYCHIC,:REFLECT,:SURF,:COSMICPOWER],            :item => :WISEGLASSES, :tier => 1},
    #reserve
    #TIER 2
    {:species => [:MAROWAK,:SANDSLASH],     :level => 9, :item => :SOFTSAND, :ability => :ROCKHEAD,     :moves => [:BONERUSH,:DOUBLEEDGE,:SWORDSDANCE,:DIG],  :tier => 2},
    {:species => [:MAGNETON,:FLAREON],     :level => 8, :item => :AIRBALLOON, :ability => :FLASHFIRE,     :moves => [:FLAMETHROWER,:THUNDERBOLT,:DOUBLETEAM,:MIRRORSHOT],  :tier => 2},
    {:species => [:VAPOREON,:NINETALES],     :level => 8, :item => :CHARCOAL, :ability => :WATERABSORB,     :moves => [:FLAMETHROWER,:SCALD,:PROTECT,:TOXIC],  :tier => 2},
    {:species => [:JOLTEON,:CLOYSTER],     :level => 8, :item => :MAGNET, :ability => :SKILLLINK,     :moves => [:THUNDERBOLT,:ICICLECRASH,:AQUAJET,:TWINEEDLE],  :tier => 2},
    {:species => [:HERACROSS,:MACHAMP],     :level => 9, :item => :EXPERTBELT, :ability => :NOGUARD,     :moves => [:MEGAHORN,:DYNAMICPUNCH,:BULKUP,:STONEEDGE],  :tier => 2},


    #TIER 3 (original mt. silver team)
    {:species => [:ARCANINE,:TYRANITAR],   :level => 9, :ability => :INTIMIDATE, :moves => [:THRASH,:FIREFANG,:CRUNCH,:ROAR],                 :item => :SMOOTHROCK, :tier => 3},
    {:species => [:AEGISLASH,:AERODACTYL], :level => 10, :ability => :STANCECHANGE, :moves => [:STEELWING,:DRAGONDANCE,:TAILWIND,:KINGSSHIELD],:item => :METALCOAT, :tier => 3},
    {:species => [:MISMAGIUS,:ALAKAZAM],   :level => 9, :ability => :LEVITATE, :moves => [:CALMMIND,:MYSTICALFIRE,:TRICKROOM,:PSYCHIC],   :item => :WISEGLASSES, :tier => 3},
    {:species => [:CROBAT,:PIDGEOT],       :level => 11, :ability => :KEENEYE, :moves => [:WHIRLWIND,:CROSSPOISON,:UTURN,:AIRSLASH],      :item => :RAZORFANG, :tier => 3},

    #TIER 4
    {:species => [:ALTARIA,:GLISCOR],  :level => 7, :ability => :POISONHEAL,  :nature => :ADAMANT,   :moves => [:DRAGONDANCE,:ROOST,:DRAGONCLAW,:EARTHQUAKE],     :item => :TOXICORB, :tier => 4},
    {:species => [:TALONFLAME,:AERODACTYL],  :level => 9, :ability => :ROCKHEAD,  :nature => :JOLLY,   :moves => [:FLAREBLITZ,:BRAVEBIRD,:DRAGONDANCE,:AQUATAIL],     :item => :BRIGHTPOWDER, :tier => 4},
    {:species => [:CHANDELURE,:BRUXISH],  :level => 10, :ability => :DAZZLING,  :nature => :TIMID,   :moves => [:PSYCHIC,:SHADOWBALL,:SIGNALBEAM,:OVERHEAT],     :item => :WHITEHERB, :tier => 4},
    {:species => [:LURANTIS,:WEAVILE],  :level => 8, :ability => :PICKPOCKET,  :nature => :JOLLY,   :moves => [:SOLARBLADE,:ICESHARD,:DIG,:AERIALACE],     :item => :POWERHERB, :tier => 4},
    {:species => [:HAWLUCHA,:ZOROARK],   :level => 4, :item => :FOCUSSASH, :ability => :ILLUSION,  :nature => :TIMID, :moves => [:DARKPULSE,:FOCUSBLAST,:NASTYPLOT,:FLAMETHROWER],    :tier => 4},

    #TIER 5
    {:species => [:TOXAPEX,:TYRANITAR], :level => 8, :ability => :REGENERATOR, :moves => [:PURSUIT,:KNOCKOFF,:DRAGONTAIL,:GUNKSHOT],      :item => :ASSAULTVEST, :tier => 5},
    {:species => [:SNORLAX,:GLISCOR], :level => 7, :ability => :POISONHEAL, :moves => [:SWORDSDANCE,:ROOST,:FACADE,:KNOCKOFF],      :item => :TOXICORB, :tier => 5},
    {:species => [:ELECTRODE,:ALAKAZAM], :level => 7, :ability => :MAGICGUARD, :moves => [:VOLTSWITCH,:PSYSHOCK,:ENERGYBALL,:MINDBLOWN],      :item => :LIFEORB, :tier => 5},
    {:species => [:TANGROWTH,:FORRETRESS], :level => 6, :ability => :REGENERATOR, :moves => [:VOLTSWITCH,:GIGADRAIN,:KNOCKOFF,:RAPIDSPIN],      :item => :ROCKYHELMET, :tier => 5},

  ],
}







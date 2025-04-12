def pbSpecialTutor(pokemon,legendaries=false)
  retval = true
  tutorUtil = FusionTutorService.new(pokemon)
  pbFadeOutIn {
    scene = MoveRelearner_Scene.new
    screen = MoveRelearnerScreen.new(scene)
    moves = tutorUtil.getCompatibleMoves(legendaries)
    if !moves.empty?
      retval = screen.pbStartScreen(pokemon, moves)
    else
      return false
    end
  }
  return retval
end

def pbShowRareTutorFullList(includeLegendaries = false)
  tutorUtil = FusionTutorService.new(nil)
  tutorUtil.setShowList(true)
  pbFadeOutIn {
    scene = MoveRelearner_Scene.new
    screen = MoveRelearnerScreen.new(scene)
    moves = tutorUtil.getCompatibleMoves(includeLegendaries)
    screen.pbStartScreen(nil, moves)
  }
  return false
end

def pbCheckRareTutorCompatibleMoves(pokemon, includeLeshgendaries)
  tutorUtil = FusionTutorService.new(pokemon)
  return tutorUtil.has_compatible_move(includeLeshgendaries)
end

def showRandomRareMoveConditionExample(legendary = false)
  example = legendary ? getlegendaryConditionExample : getRegularConditionExample
  text = "Par exemple : " + example
  pbMessage(text)
end

def getRegularConditionExample()
  list = [
    "une fusion de Sandslash de type Électrik pourra apprendre l'attaque Électrikipik.",
    "tout Pokémon de type Vol et Combat pourra apprendre l'attaque Flying Press.",
    "l'attaque OsOmbre ne peut être apprise que par des fusions de Ossatueur de type Spectre.",
    "tout Pokémon de type Spectre et Plante pourra apprendre l'attaque Halloween.",
    "l'attaque Maléfice Sylvain ne peut être apprise que par des Pokémon de type Spectre/Plante.",
    "une fusion de type Plante d’un Pokémon piquant comme Voltali pourra apprendre l'attaque Pico-Défense.",
    "seule une fusion de type Sol de Tadmorv ou Grotadmorv pourra apprendre l'attaque Amass'Sable.",
    "toute fusion de type Glace pouvant déjà apprendre Pince-Masse pourra aussi apprendre Marteau de Glace.",
    "seules les fusions de type Eau d’un Pokémon ninja comme Ninjask ou Zoroark pourront apprendre l'attaque Sheauriken.",
  ]
  return list.sample
end

def getlegendaryConditionExample()
  list = [
    "toute fusion de Motisma pouvant déjà apprendre Poing-Éclair pourra aussi apprendre Plasma Punch.",
    "seule une fusion de type Électrik d’un Pokémon légendaire de type Glace pourra apprendre Éclair Gelé.",
    "seule une fusion de type Feu d’un Pokémon légendaire de type Glace pourra apprendre Feu Glacé.",
    "tout Pokémon de type Vol et Ténèbres pourra apprendre l'attaque Mort'Ailes.",
    "une fusion de type Sol d’un Pokémon piquant comme Noacier pourra apprendre l'attaque Myria-Flèches.",
    "tout Pokémon de type Acier pouvant déjà apprendre Torgnoles pourra aussi apprendre Écrous d'Poing.",
    "tout Pokémon de type Fée et Roche pourra apprendre l'attaque Orage Adamantin.",
    "tout Pokémon de type Eau pouvant déjà apprendre Éruption pourra aussi apprendre Jet de Vapeur.",
  ]
  return list.sample
end

class FusionTutorService

  def has_compatible_move(include_legendaries = false)
    return !getCompatibleMoves(include_legendaries).empty?
  end

  def initialize(pokemon)
    @pokemon = pokemon
    @show_full_list = false
  end

  def setShowList(value)
    @show_full_list = value
  end

  #todo: these moves
  # DRAGONHAMMER
  # FIRELASH
  # BEAKBLAST
  # CHATTER
  # LEAFAGE
  # HEADCHARGE
  # HYPERSPACEHOLE
  # HOLDBACK
  # CELEBRATE
  # HEARTSWAP

  def getCompatibleMoves(includeLegendaries = false)
    compatibleMoves = []
    #normal moves
    if !includeLegendaries
      compatibleMoves << :ATTACKORDER if is_fusion_of([:BEEDRILL])
      # compatibleMoves << :FIRSTIMPRESSION if is_fusion_of([:SCYTHER, :SCIZOR, :PINSIR, :FARFETCHD, :TRAPINCH, :VIBRAVA, :FLYGON, :KABUTOPS, :ARMALDO])
      compatibleMoves << :POLLENPUFF if is_fusion_of([:BUTTERFREE, :CELEBI, :VILEPLUME, :PARASECT, :BRELOOM])
      compatibleMoves << :LUNGE if is_fusion_of([:SPINARAK, :ARIADOS, :JOLTIK, :GALVANTULA, :VENOMOTH, :VOLCARONA, :PINSIR, :PARASECT, :LEDIAN, :DODUO, :DODRIO, :STANTLER])
      compatibleMoves << :DEFENDORDER if is_fusion_of([:BEEDRILL])
      compatibleMoves << :HEALORDER if is_fusion_of([:BEEDRILL])
      compatibleMoves << :POWDER if is_fusion_of([:BUTTERFREE, :VENOMOTH, :VOLCARONA, :PARASECT, :BRELOOM])
      compatibleMoves << :TAILGLOW if is_fusion_of([:MAREEP, :FLAAFFY, :AMPHAROS, :LANTURN, :ZEKROM, :RESHIRAM])
      compatibleMoves << :DARKESTLARIAT if is_fusion_of([:SNORLAX, :REGIGIGAS, :POLIWRATH, :MACHAMP, :ELECTIVIRE, :DUSKNOIR, :SWAMPERT, :KROOKODILE, :GOLURK])
      compatibleMoves << :PARTINGSHOT if is_fusion_of([:MEOWTH, :PERSIAN, :SANDILE, :KROKOROK, :KROOKODILE, :UMBREON])
      compatibleMoves << :TOPSYTURVY if is_fusion_of([:HITMONTOP, :WOBBUFFET])
      # compatibleMoves << :CLANGINGSCALES if is_fusion_of([:EKANS, :ARBOK, :GARCHOMP, :FLYGON, :HAXORUS])
      compatibleMoves << :ZINGZAP if is_fusion_of([:PICHU, :PIKACHU, :RAICHU, :VOLTORB, :ELECTRODE]) || (is_fusion_of([:SANDSLASH, :GOLEM]) && hasType(:ELECTRIC))
      compatibleMoves << :PARABOLICCHARGE if is_fusion_of([:PICHU, :PIKACHU, :RAICHU, :MAGNEMITE, :MAGNETON, :MAGNEZONE, :MAREEP, :FLAAFFY, :AMPHAROS, :ELEKID, :ELECTABUZZ, :ELECTIVIRE, :ZAPDOS, :CHINCHOU, :LANTURN, :RAIKOU, :KLINK, :KLANG, :KLINKLANG, :ROTOM, :STUNFISK])
      compatibleMoves << :ELECTRIFY if is_fusion_of([:KLINK, :KLANG, :KLINKLANG]) || hasType(:ELECTRIC)
      compatibleMoves << :AROMATICMIST if is_fusion_of([:WEEZING, :BULBASAUR, :IVYSAUR, :VENUSAUR, :CHIKORITA, :BAYLEEF, :MEGANIUM, :GLOOM, :VILEPLUME, :BELLOSSOM, :ROSELIA, :ROSERADE])
      compatibleMoves << :FLORALHEALING if is_fusion_of([:SUNFLORA, :BELLOSSOM, :ROSELIA, :ROSERADE])
      #compatibleMoves << :FLYINGPRESS if is_fusion_of([:TORCHIC, :COMBUSKEN, :BLAZIKEN, :FARFETCHD, :HERACROSS]) || (hasType(:FLYING) && hasType(:FIGHTING))
      compatibleMoves << :MATBLOCK if is_fusion_of([:MACHOP, :MACHOKE, :MACHAMP, :TYROGUE, :HITMONLEE, :HITMONCHAN, :HITMONTOP])
      compatibleMoves << :MINDBLOWN if is_fusion_of([:VOLTORB, :ELECTRODE, :EXEGGUTOR])
      compatibleMoves << :SHELLTRAP if is_fusion_of([:MAGCARGO, :FORRETRESS])
      compatibleMoves << :HEATCRASH if is_fusion_of([:BLAZIKEN, :RESHIRAM, :GROUDON, :CHARIZARD, :GOLURK, :REGIGIGAS, :RHYDON, :RHYPERIOR, :SNORLAX])
      compatibleMoves << :SHADOWBONE if is_fusion_of([:MAROWAK]) && hasType(:GHOST)
      compatibleMoves << :SPIRITSHACKLE if is_fusion_of([:BANETTE, :SPIRITOMB, :DUSKNOIR, :SHEDINJA, :COFAGRIGUS])
      compatibleMoves << :TRICKORTREAT if (hasType(:GRASS) && hasType(:GHOST)) || is_fusion_of([:GASTLY, :HAUNTER, :GENGAR, :MIMIKYU, :ZORUA, :ZOROARK])
      compatibleMoves << :TROPKICK if is_fusion_of([:HITMONLEE, :HITMONTOP, :ROSERADE]) || (hasType(:GRASS) && hasType(:FIGHTING))
      #compatibleMoves << :NEEDLEARM if is_fusion_of([:FERROTHORN])
      #compatibleMoves << :FORESTSCURSE if (hasType(:GRASS) && hasType(:GHOST))
      #compatibleMoves << :SPIKYSHIELD if is_fusion_of([:FERROSEED, :FERROTHORN]) || (is_fusion_of([:SANDSLASH, :JOLTEON, :CLOYSTER]) && hasType(:GRASS))
      compatibleMoves << :STRENGTHSAP if is_fusion_of([:ODDISH, :GLOOM, :VILEPLUME, :BELLOSSOM, :HOPPIP, :SKIPLOOM, :JUMPLUFF, :BELLSPROUT, :WEEPINBELL, :VICTREEBEL, :PARAS, :PARASECT, :DRIFBLIM, :BRELOOM])
      #compatibleMoves << :SHOREUP if is_fusion_of([:GRIMER, :MUK]) && hasType(:GROUND)
      compatibleMoves << :ICEHAMMER if (canLearnMove(:CRABHAMMER) || canLearnMove(:GRASSHAMMER) || canLearnMove(:HAMMERARM)) && hasType(:ICE)
      compatibleMoves << :MULTIATTACK if is_fusion_of([:ARCEUS, :MEW, :GENESECT])
      # compatibleMoves << :REVELATIONDANCE if is_fusion_of([:KECLEON, :BELLOSSOM, :CLEFAIRY, :CLEFABLE, :CLEFFA])
      #compatibleMoves << :BANEFULBUNKER if is_fusion_of([:TENTACOOL, :TENTACRUEL, :NIDORINA, :NIDORINO, :NIDOQUEEN, :NIDOKING, :GRIMER, :MUK, :QWILFISH])
      compatibleMoves << :INSTRUCT if is_fusion_of([:CHIMCHAR, :MONFERNO, :INFERNAPE, :KADABRA, :ALAKAZAM, :SLOWKING])
      compatibleMoves << :PSYCHICTERRAIN if hasType(:PSYCHIC)
      #compatibleMoves << :GRASSYTERRAIN if hasType(:GRASS)
      compatibleMoves << :MISTYTERRAIN if hasType(:FAIRY)
      compatibleMoves << :SPEEDSWAP if is_fusion_of([:PIKACHU, :RAICHU, :ABRA, :KADABRA, :ALAKAZAM, :PORYGON, :PORYGON2, :PORYGONZ, :MEWTWO, :MEW, :JOLTIK, :GALVANTULA])
      #compatibleMoves << :ACCELEROCK if is_fusion_of([:AERODACTYL, :KABUTOPS, :ANORITH, :ARMALDO])
      #compatibleMoves << :ANCHORSHOT if (is_fusion_of([:EMPOLEON, :STEELIX, :BELDUM, :METANG, :METAGROSS, :KLINK, :KLINKLANG, :KLANG, :ARON, :LAIRON, :AGGRON]) && hasType(:WATER)) || (is_fusion_of([:LAPRAS, :WAILORD, :KYOGRE]) && hasType(:STEEL))
      compatibleMoves << :SPARKLINGARIA if (is_fusion_of([:JYNX, :JIGGLYPUFF, :WIGGLYTUFF]) && hasType(:WATER)) || is_fusion_of([:LAPRAS])
      #compatibleMoves << :WATERSHURIKEN if is_fusion_of([:NINJASK, :LUCARIO, :ZOROARK, :BISHARP]) && hasType(:WATER)
    end
    if includeLegendaries
      #legendary moves (only available after a certain trigger, maybe a different npc)
      compatibleMoves << :HYPERSPACEFURY if is_fusion_of([:GIRATINA, :PALKIA, :DIALGA, :ARCEUS])
      compatibleMoves << :COREENFORCER if is_fusion_of([:GIRATINA, :PALKIA, :DIALGA, :RAYQUAZA])
      compatibleMoves << :PLASMAFISTS if is_fusion_of([:ELECTABUZZ, :ELECTIVIRE, :ZEKROM]) || (is_fusion_of([:ROTOM]) && canLearnMove(:THUNDERPUNCH))
      compatibleMoves << :LIGHTOFRUIN if is_fusion_of([:ARCEUS, :MEW, :CELEBI, :JIRACHI])
      compatibleMoves << :FLEURCANNON if is_fusion_of([:GARDEVOIR, :GALLADE, :SYLVEON, :WIGGLYTUFF])
      compatibleMoves << :NATURESMADNESS if is_fusion_of([:CELEBI, :KYOGRE, :GROUDON, :ABSOL])
      compatibleMoves << :GEOMANCY if is_fusion_of([:CELEBI])
      compatibleMoves << :VCREATE if is_fusion_of([:ENTEI, :HOOH, :TYPHLOSION])
      compatibleMoves << :MAGMASTORM if is_fusion_of([:MAGCARGO, :TYPHLOSION, :MAGMORTAR, :MAGMAR, :ENTEI, :GROUDON]) || canLearnMove(:ERUPTION)
      compatibleMoves << :SEARINGSHOT if is_fusion_of([:MAGMORTAR])
      compatibleMoves << :OBLIVIONWING if is_fusion_of([:MURKROW, :HONCHKROW]) || (hasType(:DARK) && hasType(:FLYING))
      compatibleMoves << :MOONGEISTBEAM if (is_fusion_of([:CLEFFA, :CLEFAIRY, :CLEFABLE]) && hasType(:DARK)) || is_fusion_of([:DARKRAI, :MISDREAVUS, :MISMAGIUS])
      compatibleMoves << :SPECTRALTHIEF if is_fusion_of([:HAUNTER, :GENGAR, :BANETTE, :GIRATINA, :HONEDGE, :DOUBLADE, :AEGISLASH])
      compatibleMoves << :SEEDFLARE if is_fusion_of([:JUMPLUFF, :SUNFLORA])
      compatibleMoves << :LANDSWRATH if is_fusion_of([:GROUDON])
      compatibleMoves << :THOUSANDARROWS if is_fusion_of([:SANDSLASH, :JOLTEON, :FERROTHORN]) && hasType(:GROUND)
      compatibleMoves << :THOUSANDWAVES if is_fusion_of([:STUNFISK, :QUAGSIRE, :SWAMPERT])
      compatibleMoves << :FREEZESHOCK if is_fusion_of([:KYUREM, :ARTICUNO]) && hasType(:ELECTRIC)
      compatibleMoves << :ICEBURN if is_fusion_of([:KYUREM, :ARTICUNO]) && hasType(:FIRE)
      #compatibleMoves << :RELICSONG if is_fusion_of([:JYNX, :LAPRAS, :JIGGLYPUFF, :WIGGLYTUFF, :MISDREAVUS, :MISMAGIUS])
      compatibleMoves << :HAPPYHOUR if is_fusion_of([:MEOWTH, :JIRACHI, :DELIBIRD, :MUNCHLAX, :SNORLAX, :PIKACHU, :RAICHU])
      compatibleMoves << :HOLDHANDS if is_fusion_of([:CHARMANDER, :BULBASAUR, :SQUIRTLE, :PIKACHU, :TOGEPI])
      #compatibleMoves << :PRISMATICLASER if is_fusion_of([:LANTURN, :AMPHAROS, :HOOH, :DEOXYS, :MEWTWO, :MEW]) && hasType(:PSYCHIC)
      #compatibleMoves << :PHOTONGEYSER if is_fusion_of([:LANTURN, :AMPHAROS, :HOOH, :MEW, :MEWTWO, :DEOXYS]) && hasType(:PSYCHIC)
      # compatibleMoves << :LUNARDANCE if is_fusion_of([:CLEFAIRY, :CLEFABLE, :STARYU, :STARMIE])
      #compatibleMoves << :DIAMONDSTORM if ((hasType(:FAIRY) && hasType(:ROCK)) || (hasType(:ROCK) && hasType(:STEEL))) || is_fusion_of([:DIALGA, :STEELIX])
      compatibleMoves << :SUNSTEELSTRIKE if is_fusion_of([:CHARIZARD, :VOLCARONA, :FLAREON, :NINETALES, :ENTEI, :HOOH, :RAPIDASH]) && hasType(:STEEL)
      compatibleMoves << :DOUBLEIRONBASH if canLearnMove(:DOUBLESLAP) && hasType(:STEEL)
      compatibleMoves << :STEAMERUPTION if canLearnMove(:ERUPTION) && hasType(:WATER)
      compatibleMoves << :SECRETSWORD if is_fusion_of([:HONEDGE, :DOUBLADE, :AEGISLASH, :GALLADE, :FARFETCHD, :ABSOL, :BISHARP])
    end
    return compatibleMoves
  end

  def is_fusion_of(pokemonList)
    return true if @show_full_list
    is_species = false
    for fusionPokemon in pokemonList
      if @pokemon.isFusionOf(fusionPokemon)
        is_species = true
      end
    end
    return is_species
  end

  def hasType(type)
    return true if @show_full_list
    return @pokemon.hasType?(type)
  end

  def canLearnMove(move)
    return true if @show_full_list
    return @pokemon.compatible_with_move?(move)
  end

end




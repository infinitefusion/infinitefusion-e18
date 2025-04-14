##=##===========================================================================
##=## Easy Questing System - made by M3rein
##=##===========================================================================
##=## Create your own quests starting from line 72. Be aware of the following:
##=## * Every quest should have a unique ID;
##=## * Every quest should be unique (at least one field has to be different);
##=## * The "Name" field can't be very long;
##=## * The "Desc" field can be quite long;
##=## * The "NPC" field is JUST a name;
##=## * The "Sprite" field is the name of the sprite in "Graphics/Characters";
##=## * The "Location" field is JUST a name;
##=## * The "Color" field is a SYMBOL (starts with ':'). List under "pbColor";
##=## * The "Time" field can be a random string for it to be "?????" in-game;
##=## * The "Completed" field can be pre-set, but is normally only changed in-game
##=##===========================================================================
class Quest
  attr_accessor :id
  attr_accessor :name
  attr_accessor :desc
  attr_accessor :npc
  attr_accessor :sprite
  attr_accessor :location
  attr_accessor :color
  attr_accessor :time
  attr_accessor :completed

  def initialize(id, name, desc, npc, sprite, location, color = :WHITE, time = Time.now, completed = false)
    self.id = id
    self.name = name
    self.desc = desc
    self.npc = npc
    self.sprite = sprite
    self.location = location
    self.color = pbColor(color)
    self.time = time
    self.completed = completed
  end
end

def pbColor(color)
  # Mix your own colors: http://www.rapidtables.com/web/color/RGB_Color.htm  
  return Color.new(0, 0, 0) if color == :BLACK
  return Color.new(255, 115, 115) if color == :LIGHTRED
  return Color.new(245, 11, 11) if color == :RED
  return Color.new(164, 3, 3) if color == :DARKRED
  return Color.new(47, 46, 46) if color == :DARKGREY
  return Color.new(100, 92, 92) if color == :LIGHTGREY
  return Color.new(226, 104, 250) if color == :PINK
  return Color.new(243, 154, 154) if color == :PINKTWO
  return Color.new(255, 160, 50) if color == :GOLD
  return Color.new(255, 186, 107) if color == :LIGHTORANGE
  return Color.new(95, 54, 6) if color == :BROWN
  return Color.new(122, 76, 24) if color == :LIGHTBROWN
  return Color.new(255, 246, 152) if color == :LIGHTYELLOW
  return Color.new(242, 222, 42) if color == :YELLOW
  return Color.new(80, 111, 6) if color == :DARKGREEN
  return Color.new(154, 216, 8) if color == :GREEN
  return Color.new(197, 252, 70) if color == :LIGHTGREEN
  return Color.new(74, 146, 91) if color == :FADEDGREEN
  return Color.new(6, 128, 92) if color == :DARKLIGHTBLUE
  return Color.new(18, 235, 170) if color == :LIGHTBLUE
  return Color.new(139, 247, 215) if color == :SUPERLIGHTBLUE
  return Color.new(35, 203, 255) if color == :BLUE
  return Color.new(3, 44, 114) if color == :DARKBLUE
  return Color.new(7, 3, 114) if color == :SUPERDARKBLUE
  return Color.new(63, 6, 121) if color == :DARKPURPLE
  return Color.new(113, 16, 209) if color == :PURPLE
  return Color.new(219, 183, 37) if color == :ORANGE
  return Color.new(255, 255, 255,0) if color == :INVISIBLE
  return Color.new(255, 255, 255)
end


HotelQuestColor = :GOLD
FieldQuestColor = :PURPLE
LegendaryQuestColor = :GOLD
TRQuestColor = :DARKRED

QuestBranchHotels = "Hotel Quests"
QuestBranchField = "Field Quests"
QuestBranchRocket = "Team Rocket Quests"
QuestBranchLegendary = "Legendary Quests"

#todo: convert to non-numerical ids like team rocket quests
QUESTS = {
  #Pewter hotel
  "pewter_1" => Quest.new("pewter_1", "Cueillette de champignons", "Une dame d'Argenta veut que vous lui apportiez 3 petits champignons de la forêt de Jade pour faire un ragoût.", QuestBranchHotels, "BW (74)", "Argenta", HotelQuestColor),
  "pewter_2" =>Quest.new("pewter_2", "Médecine perdue", "Un jeune d'Argenta a besoin de votre aide pour retrouver un Revive perdu. Il l'a perdu en s'asseyant sur un banc quelque part à Argenta.", QuestBranchHotels, "BW (19)", "Argenta", HotelQuestColor),
  "pewter_3" =>Quest.new("pewter_3", "Évolution des insectes", "Un chasseur d'Insectes d'Argenta veut que vous lui montriez un Pokémon Insecte entièrement évolué.", QuestBranchHotels, "BWBugCatcher_male", "Argenta", HotelQuestColor),
  63 => Quest.new(63, "Je te choisis!", "Un Pikachu du PokéMart a perdu son chapeau officiel de la Ligue Pokémon. Trouvez-en un et donnez-le au Pikachu!", QuestBranchField, "YOUNGSTER_LeagueHat", "Argenta", FieldQuestColor),

  #Cerulean hotel
  3 => Quest.new(3, "Jouer à Cupidon", "Un garçon d'Azuria veut que tu apportes une lettre d'amour à une éleveuse de Pokémon nommée Maude. Elle est probablement quelque part sur l'une des routes près d'Azuria", QuestBranchHotels, "BW (18)", "Azuria", HotelQuestColor),
  4 => Quest.new(4, "Pêche à la sole", "Un pêcheur vous demande de récupérer une vieille botte. Accrochez-la avec la vieille canne dans n'importe quel plan d'eau.", QuestBranchHotels, "BW (71)", "Azuria", HotelQuestColor),
  5 => Quest.new(5, "Pokémon de Johto", "Un voyageur du PokéMart veut que vous lui montriez un Pokémon originaire de la région de Johto.", QuestBranchHotels, "traveler_johto", "Azuria", HotelQuestColor),
  "cerulean_2" => Quest.new(5, "Experts des types", "Battez tous les experts de type dispersés dans la région de Kanto (#{pbGet(VAR_TYPE_EXPERTS_BEATEN)}/#{TOTAL_NB_TYPE_EXPERTS})", QuestBranchHotels, "expert-normal", "Azuria", HotelQuestColor),

  #Route 24
  6 => Quest.new(6, "Recherche sur le terrain (Part 1)", "L'assistant du professeur Oak veut que vous attrapiez un Abra.", QuestBranchField, "BW (82)", "Route 24", FieldQuestColor),
  7 => Quest.new(7, "Recherche sur le terrain (Part 2)", "L'assistant du professeur Oak veut que vous rencontriez tous les Pokémon sur la Route 24.", QuestBranchField, "BW (82)", "Route 24", FieldQuestColor),
  8 => Quest.new(8, "Recherche sur le terrain (Part 3)", "L'assistant du professeur Oak veut que vous attrapiez un Laporeille en utilisant le Pokéradar.", QuestBranchField, "BW (82)", "Route 24", FieldQuestColor),

  #Vermillion City
  9 => Quest.new(9, "Types inhabituels 1", "Une femme à l'hôtel veut que vous lui montriez un Pokémon de type Eau/Feu", QuestBranchHotels, "BW (58)", "Carmin sur Mer", HotelQuestColor),
  10 => Quest.new(10, "Maison des Dresseurs", "Gagnez 10 points à la maison des Dresseurs de Jadielle", QuestBranchHotels, "BW (55)", "Carmin sur Mer", HotelQuestColor),
  11 => Quest.new(11, "Alimenter le phare", "Attrapez des Voltorbes pour alimenter le phare", QuestBranchHotels, "BW (43)", "Carmin sur Mer", HotelQuestColor),
  12 => Quest.new(12, "Cocktail de fruits de mer ", "Procurez-vous des cuisses de crabe cuites à la vapeur dans la cuisine de L'Océane et ramenez-les à l'hôtel avant qu'elles ne refroidissent.", QuestBranchHotels, "BW (36)", "Carmin sur Mer", HotelQuestColor),
  13 => Quest.new(13, "Matériaux de construction ", "Récupérez des planches de bois de Jadielle et des briques de Argenta.", QuestBranchField, "BW (36)", "Carmin sur Mer", FieldQuestColor),
  64 => Quest.new(64, "Garçon sur l'eau", "Le serveur de L'Océane veut que vous preniez les commandes du restaurant pendant qu'il va chercher un gâteau de remplacement.", QuestBranchField, "BW (53)", "L'Océane", FieldQuestColor),

  #Celadon City
  14 => Quest.new(14, "Soleil ou Lune", "Montre comment Evoli évolue lorsqu'il est exposé à une pierre de Lune ou de Soleil pour aider la scientifique dans ses recherches.", QuestBranchHotels, "BW (82)", "Céladopole", HotelQuestColor),
  15 => Quest.new(15, "Pour qui sonne la cloche", "Sonnez la cloche de Lavanville lorsque le moment est venu de révéler son secret.", QuestBranchHotels, "BW (40)", "Lavanville", HotelQuestColor),
  16 => Quest.new(16, "Cuit a dur", "Une dame veut que vous lui donniez un oeuf pour faire une omelette.", QuestBranchHotels, "BW (24)", "Céladopole", HotelQuestColor),
  17 => Quest.new(17, "Une promenade avec Evoli!", "Promenez Évoli pendant un moment jusqu'à ce qu'il se fatigue.", QuestBranchField, "BW (37)", "Céladopole", FieldQuestColor),

  #Fuchsia City
  18 => Quest.new(18, "Nettoyage de la piste cyclable", "Débarrassez-vous de tous les Pokémon qui salissent la piste cyclable.", QuestBranchHotels, "BW (77)", "Parmanie", HotelQuestColor),
  19 => Quest.new(19, "Pokémon perdu!", "Retrouvez le dresseur perdu de Leveinard!", QuestBranchHotels, "113", "Parmanie", HotelQuestColor),
  20 => Quest.new(20, "Course cycliste!", "Allez à la rencontre de la cycliste au bas de la route 17 et battez son temps sur la piste cyclable!", QuestBranchHotels, "BW032", "Piste Cyclable", HotelQuestColor),

  #Crimson City
  21 => Quest.new(21, "Sauvetage de Kokiyas", "Remettre à l'eau tous les Kokiyas échoués sur la route de la Cité Écarlate.", QuestBranchHotels, "BW (48)", "Cité Écarlate", HotelQuestColor),
  22 => Quest.new(22, "Rumble du quatrième tour", "Battez Jeanette et son Chétiflor de haut niveau dans un combat Pokémon", QuestBranchHotels, "BW024", "Cité Écarlate", HotelQuestColor),
  23 => Quest.new(23, "Types inhabituels 2", "Une femme à l'hôtel veut que vous lui montriez un Pokémon de type Normal/Fantôme", QuestBranchHotels, "BW (58)", "Cité Écarlate", HotelQuestColor),

  #Saffron City
  24 => Quest.new(24, "Reine de la danse!", "Danse avec Copinette!", QuestBranchField, "BW (24)", "Safrania (Boite de nuit)", FieldQuestColor),
    #celadon
  25 => Quest.new(25, "Pokémon de Sinnoh", "Un voyageur du Centre Départemental veut que vous lui montriez un Pokémon originaire de la région de Sinnoh.", QuestBranchHotels, "traveler_sinnoh", "Céladopole", HotelQuestColor),
  26 => Quest.new(26, "Chiots perdus", "Retrouvez tous les Caninos manquants dans les itinéraires autour de Safrania.", QuestBranchHotels, "BW (73)", "Safrania", HotelQuestColor),
  27 => Quest.new(27, "Pokémon invisibles", "Trouvez un Pokémon invisible dans la partie est de Safrania.", QuestBranchHotels, "BW (57)", "Safrania", HotelQuestColor),
  28 => Quest.new(28, "Mauvais jusqu'à l'os!", "Trouvez un os rare en utilisant Éclate-Roc.", QuestBranchHotels, "BW (72)", "Safrania", HotelQuestColor),

  #Cinnabar Island
  29 => Quest.new(29, "Les Pokémons transformables", "Le scientifique veut que vous trouviez de la poudre rapide qui peut parfois être trouvée sur des Métamorph dans le sous-sol du manoir.", QuestBranchHotels, "BW (82)", "Cramois'Ile", HotelQuestColor),
  30 => Quest.new(30, "Diamants et Perles", "Trouvez un collier de diamant pour sauver le mariage de l'homme.", QuestBranchHotels, "BW (71)", "Cramois'Ile", HotelQuestColor),
  62 => Quest.new(62, "Pokémon d'Alola", "Un voyageur du PokéMart veut que vous lui montriez un Pokémon originaire de la région d'Alola.", QuestBranchHotels, "traveler_alola", "Cramois'Ile", HotelQuestColor),

  #Vermillion City
  31 => Quest.new(31, "Pokémon de Hoenn", "Un voyageur dans le PokéMart vous demande de lui montrer un Pokémon originaire de la région de Hoenn.", QuestBranchHotels, "traveler_hoenn", "Carmin sur Mer", HotelQuestColor),
  #Goldenrod City
  32 => Quest.new(32, "Souvenir de safari!", "Rapportez un souvenir de la Zone Safari de Parmanie", QuestBranchHotels, "BW (28)", "Doublonville", HotelQuestColor),
  65 => Quest.new(65, "Travail de police infiltré!", "Allez voir la police de Doublonville pour les aider dans une opération policière importante.", QuestBranchField, "BW (80)", "Doublonville", FieldQuestColor),
  66 => Quest.new(66, "Île Guimauve!", "La Team Rocket prépare un braquage sur l'île Guimauve. Vous avez uni vos forces à celles de la police pour les arrêter!", QuestBranchField, "BW (80)", "Doublonville", FieldQuestColor),

  #Violet City
  33 => Quest.new(33, "Désamorcer les pommes de pin!", "Débarrassez-vous de tous les Pomdepik sur la Route 31 et la Route 30", QuestBranchHotels, "BW (64)", "Mauville", HotelQuestColor),
  34 => Quest.new(34, "Trouver la queue de Ramoloss!", "Trouvez une Queue Ramoloss dans des fleurs, quelque part autour de Mauville!", QuestBranchHotels, "BW (19)", "Mauville", HotelQuestColor),

  #Blackthorn City
  35 => Quest.new(35, "L'évolution du dragon", "Un dompteur de dragons de Ébènelle veut que vous lui montriez un Pokémon Dragon entièrement évolué.", QuestBranchHotels, "BW014", "Ébènelle", HotelQuestColor),
  36 => Quest.new(36, "Trésor englouti!", "Trouvez un vieux souvenir sur un navire coulé près de Cramois'Île.", QuestBranchHotels, "BW (28)", "Ébènelle", HotelQuestColor),
  37 => Quest.new(37, "La plus grosse carpe", "Un pêcheur veut que vous pêchiez un Magikarp d'un niveau exceptionnellement élevé dans l'Antre du Dragon.", QuestBranchHotels, "BW (71)", "Ébènelle", HotelQuestColor),

  #Saffron City
  38 => Quest.new(38, "Pokémon de Kalos", "Un voyageur du PokéMart veut que vous lui montriez un Pokémon originaire de la région de Kalos.", QuestBranchHotels, "traveler_kalos", "Safrania", HotelQuestColor),
  #Ecruteak City
  39 => Quest.new(39, "L'évolution des fantômes", "Une fille de Rosalia veut que vous lui montriez un Pokémon Fantôme entièrement évolué.", QuestBranchHotels, "BW014", "Rosalia", HotelQuestColor),

  #Kin Island
  40 => Quest.new(40, "Banana Slamma!", "Récupérez 30 bananes", QuestBranchHotels, "BW059", "Ile Trinité", HotelQuestColor),
    #fuchsia
  41 => Quest.new(41, "Pokémon de Unys", "Un voyageur du PokéMart veut que vous lui montriez un Pokémon originaire de la région d'Unys.", QuestBranchHotels, "traveler_unova", "Parmanie", HotelQuestColor),
  42 => Quest.new(42, "Objet volé", "Récupérez un vase volé par un cambrioleur dans le manoir Pokémon", QuestBranchHotels, "BW (21)", "Cramois'Ile", HotelQuestColor),
  43 => Quest.new(43, "Météore tombé", "Enquête sur un cratère près du Pont du Lien.", QuestBranchHotels, "BW009", "Ile Trinité", HotelQuestColor),
  44 => Quest.new(44, "Premier contact", "Trouvez les pièces manquantes d'un vaisseau spatial extraterrestre tombé", QuestBranchHotels, "BW (92)", "Pont du Lien", LegendaryQuestColor),
  45 => Quest.new(45, "Premier contact (Part 2)", "Demandez au marin du port de Cramois'Île de vous emmener sur l'île inexplorée où le vaisseau spatial pourrait se trouver", QuestBranchHotels, "BW (92)", "Pont du Lien", LegendaryQuestColor),
  46 => Quest.new(46, "Le poisson le plus rare", "Un pêcheur veut que vous lui montriez un Barpeau. Apparemment, on peut en pêcher autour des îles Sevii quand il pleut.", QuestBranchField, "BW056", "Ile Trinité", FieldQuestColor),

  #Necrozma quest
  47 => Quest.new(47, "Prismes mystérieux", "Vous avez trouvé un piédestal avec un prisme mystérieux dessus. Il semble y avoir de la place pour d'autres prismes.", QuestBranchLegendary, "BW_Sabrina", "Tour Pokémon", LegendaryQuestColor),

  48 => Quest.new(48, "La longue nuit (Part 1)", "Une obscurité mystérieuse a enveloppé une partie de la région. Rencontrez Sabrina à l'extérieur de la porte ouest de Safrania pour enquêter.", QuestBranchLegendary, "BW_Sabrina", "Lavanville", LegendaryQuestColor),
  49 => Quest.new(49, "La longue nuit (Part 2)", "L'obscurité mystérieuse s'est répandue. Rencontrez Sabrina au sommet du grand magasin de Céladopole pour découvrir la source de l'obscurité.", QuestBranchLegendary, "BW_Sabrina", "Route 7", LegendaryQuestColor),
  50 => Quest.new(50, "La longue nuit (Part 3)", "La ville de Parmanie ne semble pas affectée par l'obscurité. Allez enquêter pour voir si vous pouvez trouver plus d'informations.", QuestBranchLegendary, "BW_Sabrina", "Céladopole", LegendaryQuestColor),
  51 => Quest.new(51, "La longue nuit (Part 4)", "L'obscurité mystérieuse s'est à nouveau étendue et d'étranges plantes sont apparues. Suivez les plantes pour voir où elles mènent.", QuestBranchLegendary, "BW_koga", "Parmanie", LegendaryQuestColor),
  52 => Quest.new(52, "La longue nuit (Part 5)", "Vous avez trouvé un fruit étrange qui semble lié à l'obscurité mystérieuse. Allez voir le professeur Chen pour le faire analyser.", QuestBranchLegendary, "BW029", "Safari Zone", LegendaryQuestColor),
  53 => Quest.new(53, "La longue nuit (Part 6)", "L'étrange plante que vous avez trouvée semble briller dans l'obscurité mystérieuse qui recouvre désormais toute la région. Essayez de suivre la lueur pour découvrir la source de la perturbation.", QuestBranchLegendary, "BW-oak", "Bourg Palette", LegendaryQuestColor),

  54 => Quest.new(54, "Jardin de nectar", "Un vieil homme veut que vous apportiez des fleurs de différentes couleurs pour le jardin de la ville.", QuestBranchField, "BW (039)", "Argenta", FieldQuestColor),
  55 => Quest.new(55, "La forêt maudite", "Une enfant veut que vous trouviez une souche d'arbre flottante dans le Bois aux Chênes. De quoi pourrait-elle bien parler?", QuestBranchHotels, "BW109", "Doublonville", HotelQuestColor),
  56 => Quest.new(56, "Pokémon mordant", "Un pêcheur veut savoir quel est le Pokémon aux dents acérées qui l'a mordu dans le lac de la Zone Safari.", QuestBranchHotels, "BW (71)", "Parmanie", HotelQuestColor),

  57 => Quest.new(57, "Un groupe légendaire (Part 1)", "Le chanteur d'un groupe de Safrania vous demande de l'aider à recruter un batteur. Il pense avoir entendu des batteurs jouer dans les environs de la Cité Écarlate...", QuestBranchLegendary, "BW107", "Safrania", LegendaryQuestColor),
  58 => Quest.new(58, "Un groupe légendaire (Part 2)", "Le batteur d'un groupe légendaire de Pokémon veut que vous retrouviez ses anciens camarades de groupe. Le manager du groupe a parlé de deux anciens guitaristes...", QuestBranchLegendary, "band_drummer", "Safrania", LegendaryQuestColor),
  59 => Quest.new(59, "Un groupe légendaire (Part 3)", "Le batteur d'un groupe légendaire de Pokémon veut que vous retrouviez ses anciens camarades de groupe. Il y a des rumeurs sur une musique étrange qui a été entendue dans la région.", QuestBranchLegendary, "band_drummer", "Safrania", LegendaryQuestColor),
  60 => Quest.new(60, "Un groupe légendaire (Part 4)", "Vous avez réuni le groupe au complet ! Venez assister au spectacle samedi soir.", QuestBranchLegendary, "BW117", "Safrania", LegendaryQuestColor),

  61 => Quest.new(61, "Mystérieuses plumes lunaires", "Une entité mystérieuse vous a demandé de collecter des plumes lunaires pour elle. Elle a dit qu'elle viendrait la nuit pour vous dire où chercher. Qui que ce soit...", QuestBranchLegendary, "lunarFeather", "Lavanville", LegendaryQuestColor),
}

class PokeBattle_Trainer
  attr_accessor :quests
end


def pbAcceptNewQuest(id, bubblePosition = 20, show_description=true)
  return if isQuestAlreadyAccepted?(id)
  $game_variables[96] += 1 #nb. quests accepted
  $game_variables[97] += 1 #nb. quests active

  title = QUESTS[id].name
  description = QUESTS[id].desc
  showNewQuestMessage(title,description,show_description)

  pbAddQuest(id)
end

def showNewQuestMessage(title,description, show_description)
  pbMEPlay("Voltorb Flip Win")

  pbCallBub(3)
  Kernel.pbMessage("\\C[6]NOUVELLE QUÊTE: " + title)
  if show_description
    pbCallBub(3)
    Kernel.pbMessage("\\C[1]" + description)
  end
end

def isQuestAlreadyAccepted?(id)
  $Trainer.quests = [] if $Trainer.quests.class == NilClass
  for quest in $Trainer.quests
    return true if quest.id == id
  end
  return false
end

def finishQuest(id, silent=false)
  return if pbCompletedQuest?(id)
  pbMEPlay("Register phone") if !silent
  Kernel.pbMessage("\\C[6]Quête terminée!") if !silent

  $game_variables[222] += 1 # karma
  $game_variables[97] -= 1 #nb. quests active
  $game_variables[98] += 1 #nb. quests completed
  pbSetQuest(id, true)
end

def pbCompletedQuest?(id)
  $Trainer.quests = [] if $Trainer.quests.class == NilClass
  for i in 0...$Trainer.quests.size
    return true if $Trainer.quests[i].completed && $Trainer.quests[i].id == id
  end
  return false
end

def pbQuestlog
  # pbMessage(_INTL("The quest log has been temporarily removed from the game and is planned to be added back in a future update"))
  # return
  Questlog.new
end

def pbAddQuest(id)
  $Trainer.quests = [] if $Trainer.quests.class == NilClass
  quest = QUESTS[id]
  $Trainer.quests << quest if quest
end

def pbDeleteQuest(id)
  $Trainer.quests = [] if $Trainer.quests.class == NilClass
  for q in $Trainer.quests
    $Trainer.quests.delete(q) if q.id == id
  end
end

def pbSetQuest(id, completed)
  $Trainer.quests = [] if $Trainer.quests.class == NilClass
  for q in $Trainer.quests
    q.completed = completed if q.id == id
  end
end

def pbSetQuestName(id, name)
  $Trainer.quests = [] if $Trainer.quests.class == NilClass
  for q in $Trainer.quests
    q.name = name if q.id == id
  end
end

def pbSetQuestDesc(id, desc)
  $Trainer.quests = [] if $Trainer.quests.class == NilClass
  for q in $Trainer.quests
    q.desc = desc if q.id == id
  end
end

def pbSetQuestNPC(id, npc)
  $Trainer.quests = [] if $Trainer.quests.class == NilClass
  for q in $Trainer.quests
    q.npc = npc if q.id == id
  end
end

def pbSetQuestNPCSprite(id, sprite)
  $Trainer.quests = [] if $Trainer.quests.class == NilClass
  for q in $Trainer.quests
    q.sprite = sprite if q.id == id
  end
end

def pbSetQuestLocation(id, location)
  $Trainer.quests = [] if $Trainer.quests.class == NilClass
  for q in $Trainer.quests
    q.location = location if q.id == id
  end
end

def pbSetQuestColor(id, color)
  $Trainer.quests = [] if $Trainer.quests.class == NilClass
  for q in $Trainer.quests
    q.color = pbColor(color) if q.id == id
  end
end

class QuestSprite < IconSprite
  attr_accessor :quest
end

class Questlog
  def initialize
    $Trainer.quests = [] if $Trainer.quests.class == NilClass
    @page = 0
    @sel_one = 0
    @sel_two = 0
    @scene = 0
    @mode = 0
    @box = 0
    @completed = []
    @ongoing = []


    fix_broken_TR_quests()
    for q in $Trainer.quests
      @ongoing << q if !q.completed && @ongoing.include?(q)
      @completed << q if q.completed && @completed.include?(q)
    end

    for q in $Trainer.quests
      @ongoing << q if !q.completed
      @completed << q if q.completed
    end

    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["main"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["main"].z = 1
    @sprites["main"].opacity = 0
    @main = @sprites["main"].bitmap
    pbSetSystemFont(@main)
    pbDrawOutlineText(@main, 0, 2 - 178, 512, 384, "Journal de Quête", Color.new(255, 255, 255), Color.new(0, 0, 0), 1)

    @sprites["bg0"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg0"].setBitmap("Graphics/Pictures/pokegearbg")
    @sprites["bg0"].opacity = 0

    for i in 0..1
      @sprites["btn#{i}"] = IconSprite.new(0, 0, @viewport)
      @sprites["btn#{i}"].setBitmap("Graphics/Pictures/eqi/quest_button")
      @sprites["btn#{i}"].x = 84
      @sprites["btn#{i}"].y = 130 + 56 * i
      @sprites["btn#{i}"].src_rect.height = (@sprites["btn#{i}"].bitmap.height / 2).round
      @sprites["btn#{i}"].src_rect.y = i == 0 ? (@sprites["btn#{i}"].bitmap.height / 2).round : 0
      @sprites["btn#{i}"].opacity = 0
    end
    #pbDrawOutlineText(@main, 0, 142 - 178, 512, 384, "Ongoing: " + @ongoing.size.to_s, Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
    #pbDrawOutlineText(@main, 0, 198 - 178, 512, 384, "Completed: " + @completed.size.to_s, Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
    pbDrawOutlineText(@main, 0, 142, 512, 384, "En cours: " + @ongoing.size.to_s, Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
    pbDrawOutlineText(@main, 0, 198, 512, 384, "Terminées: " + @completed.size.to_s, Color.new(255, 255, 255), Color.new(0, 0, 0), 1)

    12.times do |i|
      Graphics.update
      @sprites["bg0"].opacity += 32 if i < 8
      @sprites["btn0"].opacity += 32 if i > 3
      @sprites["btn1"].opacity += 32 if i > 3
      @sprites["main"].opacity += 64 if i > 7
    end
    pbUpdate
  end

  def pbUpdate
    @frame = 0
    loop do
      @frame += 1
      Graphics.update
      Input.update
      if @scene == 0
        break if Input.trigger?(Input::B)
        pbList(@sel_one) if Input.trigger?(Input::C)
        pbSwitch(:DOWN) if Input.press?(Input::DOWN)
        pbSwitch(:UP) if Input.trigger?(Input::UP)
      end
      if @scene == 1
        pbMain if Input.trigger?(Input::B)
        pbMove(:DOWN) if Input.press?(Input::DOWN)
        pbMove(:UP) if Input.press?(Input::UP)
        pbLoad(0) if Input.trigger?(Input::C)
        pbArrows
      end
      if @scene == 2
        pbList(@sel_one) if Input.trigger?(Input::B)
        pbChar if @frame == 6 || @frame == 12 || @frame == 18
        #pbLoad(1) if Input.trigger?(Input::RIGHT) && @page == 0
        #pbLoad(2) if Input.trigger?(Input::LEFT) && @page == 1
      end
      @frame = 0 if @frame == 18
    end
    pbEnd
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    pbWait(1)
  end

  def pbArrows
    if @frame == 2 || @frame == 4 || @frame == 14 || @frame == 16
      @sprites["up"].y -= 1 if @sprites["up"] rescue nil
      @sprites["down"].y -= 1 if @sprites["down"] rescue nil
    elsif @frame == 6 || @frame == 8 || @frame == 10 || @frame == 12
      @sprites["up"].y += 1 if @sprites["up"] rescue nil
      @sprites["down"].y += 1 if @sprites["down"] rescue nil
    end
  end

  def pbLoad(page)
    return if @mode == 0 ? @ongoing.size == 0 : @completed.size == 0
    quest = @mode == 0 ? @ongoing[@sel_two] : @completed[@sel_two]
    pbWait(1)
    if page == 0
      @scene = 2
      if @sprites["bg1"]
        @sprites["bg1"] = IconSprite.new(0, 0, @viewport)
        @sprites["bg1"].setBitmap("Graphics/Pictures/EQI/quest_page1")
        @sprites["bg1"].opacity = 0
      end
      @sprites["pager"] = IconSprite.new(0, 0, @viewport)
      @sprites["pager"].setBitmap("Graphics/Pictures/EQI/quest_pager")
      @sprites["pager"].x = 442
      @sprites["pager"].y = 3
      @sprites["pager"].z = 1
      @sprites["pager"].opacity = 0
      8.times do
        Graphics.update
        @sprites["up"].opacity -= 32
        @sprites["down"].opacity -= 32
        @sprites["main"].opacity -= 32
        @sprites["bg1"].opacity += 32 if @sprites["bg1"]
        @sprites["pager"].opacity = 0 if @sprites["pager"]
        @sprites["char"].opacity -= 32 if @sprites["char"] rescue nil
        for i in 0...@ongoing.size
          break if i > 5
          @sprites["ongoing#{i}"].opacity -= 32 if @sprites["ongoing#{i}"] rescue nil
        end
        for i in 0...@completed.size
          break if i > 5
          @sprites["completed#{i}"].opacity -= 32 if @sprites["completed#{i}"] rescue nil
        end
      end
      @sprites["up"].dispose
      @sprites["down"].dispose
      @sprites["char"] = IconSprite.new(0, 0, @viewport)
      @sprites["char"].setBitmap("Graphics/Characters/#{quest.sprite}")
      @sprites["char"].x = 62
      @sprites["char"].y = 130
      @sprites["char"].src_rect.height = (@sprites["char"].bitmap.height / 4).round
      @sprites["char"].src_rect.width = (@sprites["char"].bitmap.width / 4).round
      @sprites["char"].opacity = 0 if @sprites["char"].opacity
      @main.clear if @main
      @text.clear if @text rescue nil
      @text2.clear if @text2 rescue nil
      drawTextExMulti(@main, 188, 54, 318, 8, quest.desc, Color.new(255, 255, 255), Color.new(0, 0, 0))
      pbDrawOutlineText(@main, 188, 330, 512, 384, quest.location, Color.new(255, 172, 115), Color.new(0, 0, 0))
      pbDrawOutlineText(@main, 10, -178, 512, 384, quest.name, quest.color, Color.new(0, 0, 0))
      if !quest.completed
        pbDrawOutlineText(@main, 8, 250, 512, 384, "Non Terminées", pbColor(:LIGHTRED), Color.new(0, 0, 0))
      else
        pbDrawOutlineText(@main, 8, 250, 512, 384, "Terminées", pbColor(:LIGHTBLUE), Color.new(0, 0, 0))
      end
      10.times do |i|
        Graphics.update
        @sprites["main"].opacity += 32
        @sprites["char"].opacity += 32 if i > 1
      end

    elsif page == 1
      @page = 1
      @sprites["bg2"] = IconSprite.new(0, 0, @viewport)
      @sprites["bg2"].setBitmap("Graphics/Pictures/EQI/quest_page1")
      @sprites["bg2"].x = 512
      @sprites["pager2"] = IconSprite.new(0, 0, @viewport)
      #@sprites["pager2"].setBitmap("Graphics/Pictures/EQI/quest_pager")
      #@sprites["pager2"].x = 474 + 512
      #@sprites["pager2"].y = 3
      #@sprites["pager2"].z = 1
      @sprites["char2"].dispose rescue nil
      @sprites["char2"] = IconSprite.new(0, 0, @viewport)
      @sprites["char2"].setBitmap("Graphics/Characters/#{quest.sprite}")
      @sprites["char2"].x = 62 + 512
      @sprites["char2"].y = 130
      @sprites["char2"].z = 1
      @sprites["char2"].src_rect.height = (@sprites["char2"].bitmap.height / 4).round
      @sprites["char2"].src_rect.width = (@sprites["char2"].bitmap.width / 4).round
      @sprites["text2"] = IconSprite.new(@viewport)
      @sprites["text2"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
      @text2 = @sprites["text2"].bitmap
      pbSetSystemFont(@text2)
      pbDrawOutlineText(@text2, 188, -122, 512, 384, "Quête reçue dans:", Color.new(255, 255, 255), Color.new(0, 0, 0))
      pbDrawOutlineText(@text2, 188, -94, 512, 384, quest.location, Color.new(255, 172, 115), Color.new(0, 0, 0))
      pbDrawOutlineText(@text2, 188, -62, 512, 384, "Quête reçue à:", Color.new(255, 255, 255), Color.new(0, 0, 0))
      time = quest.time.to_s
      txt = time.split(' ')[1] + " " + time.split(' ')[2] + ", " + time.split(' ')[3].split(':')[0] + ":" + time.split(' ')[3].split(':')[1] rescue "?????"
      pbDrawOutlineText(@text2, 188, -36, 512, 384, txt, Color.new(255, 172, 115), Color.new(0, 0, 0))
      pbDrawOutlineText(@text2, 188, -4, 512, 384, "Quête reçue de:", Color.new(255, 255, 255), Color.new(0, 0, 0))
      pbDrawOutlineText(@text2, 188, 22, 512, 384, quest.npc, Color.new(255, 172, 115), Color.new(0, 0, 0))
      pbDrawOutlineText(@text2, 188, 162, 512, 384, "De " + quest.npc, Color.new(255, 172, 115), Color.new(0, 0, 0))
      pbDrawOutlineText(@text2, 10, -178, 512, 384, quest.name, quest.color, Color.new(0, 0, 0))
      if !quest.completed
        pbDrawOutlineText(@text2, 8, 136, 512, 384, "Non Terminées", pbColor(:LIGHTRED), Color.new(0, 0, 0))
      else
        pbDrawOutlineText(@text2, 8, 136, 512, 384, "Terminées", pbColor(:LIGHTBLUE), Color.new(0, 0, 0))
      end
      @sprites["text2"].x = 512
      16.times do
        Graphics.update
        @sprites["bg1"].x -= (@sprites["bg1"].x + 526) * 0.2
        @sprites["pager"].x -= (@sprites["pager"].x + 526) * 0.2 rescue nil
        @sprites["char"].x -= (@sprites["char"].x + 526) * 0.2 rescue nil
        @sprites["main"].x -= (@sprites["main"].x + 526) * 0.2
        @sprites["text"].x -= (@sprites["text"].x + 526) * 0.2 rescue nil
        @sprites["bg2"].x -= (@sprites["bg2"].x + 14) * 0.2
        @sprites["pager2"].x -= (@sprites["pager2"].x - 459) * 0.2
        @sprites["text2"].x -= (@sprites["text2"].x + 14) * 0.2
        @sprites["char2"].x -= (@sprites["char2"].x - 47) * 0.2
      end
      @sprites["main"].x = 0
      @main.clear if @main
    else

      @page = 0
      @sprites["bg1"] = IconSprite.new(0, 0, @viewport)
      @sprites["bg1"].setBitmap("Graphics/Pictures/EQI/quest_page1")
      @sprites["bg1"].x = -512
      @sprites["pager"] = IconSprite.new(0, 0, @viewport)
      @sprites["pager"].setBitmap("Graphics/Pictures/EQI/quest_pager")
      @sprites["pager"].x = 442 - 512
      @sprites["pager"].y = 3
      @sprites["pager"].z = 1
      @sprites["text"] = IconSprite.new(@viewport)
      @sprites["text"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
      @text = @sprites["text"].bitmap
      pbSetSystemFont(@text)
      @sprites["char"].dispose rescue nil
      @sprites["char"] = IconSprite.new(0, 0, @viewport)
      @sprites["char"].setBitmap("Graphics/Characters/#{quest.sprite}")
      @sprites["char"].x = 62 - 512
      @sprites["char"].y = 130
      @sprites["char"].z = 1
      @sprites["char"].src_rect.height = (@sprites["char"].bitmap.height / 4).round
      @sprites["char"].src_rect.width = (@sprites["char"].bitmap.width / 4).round
      drawTextExMulti(@text, 188, 54, 318, 8, quest.desc, Color.new(255, 255, 255), Color.new(0, 0, 0))
      pbDrawOutlineText(@text, 188, 162, 512, 384, "From " + quest.npc, Color.new(255, 172, 115), Color.new(0, 0, 0))
      pbDrawOutlineText(@text, 10, -178, 512, 384, quest.name, quest.color, Color.new(0, 0, 0))
      if !quest.completed
        pbDrawOutlineText(@text, 8, 136, 512, 384, "Non Terminées", pbColor(:LIGHTRED), Color.new(0, 0, 0))
      else
        pbDrawOutlineText(@text, 8, 136, 512, 384, "Terminées", pbColor(:LIGHTBLUE), Color.new(0, 0, 0))
      end
      @sprites["text"].x = -512
      16.times do
        Graphics.update
        @sprites["bg1"].x -= (@sprites["bg1"].x - 14) * 0.2
        @sprites["pager"].x -= (@sprites["pager"].x - 457) * 0.2
        @sprites["bg2"].x -= (@sprites["bg2"].x - 526) * 0.2
        @sprites["pager2"].x -= (@sprites["pager2"].x - 526) * 0.2
        @sprites["char2"].x -= (@sprites["char2"].x - 526) * 0.2
        @sprites["text2"].x -= (@sprites["text2"].x - 526) * 0.2
        @sprites["text"].x -= (@sprites["text"].x - 15) * 0.2
        @sprites["char"].x -= (@sprites["char"].x - 76) * 0.2
      end
    end
  end

  def pbChar
    @sprites["char"].src_rect.x += (@sprites["char"].bitmap.width / 4).round if @sprites["char"] rescue nil
    @sprites["char"].src_rect.x = 0 if @sprites["char"].src_rect.x >= @sprites["char"].bitmap.width if @sprites["char"] rescue nil
    @sprites["char2"].src_rect.x += (@sprites["char2"].bitmap.width / 4).round if @sprites["char2"] rescue nil
    @sprites["char2"].src_rect.x = 0 if @sprites["char2"].src_rect.x >= @sprites["char2"].bitmap.width if @sprites["char2"] rescue nil
  end

  def pbMain
    12.times do |i|
      Graphics.update
      @sprites["main"].opacity -= 32 if @sprites["main"] rescue nil
      @sprites["bg0"].opacity += 32 if @sprites["bg0"].opacity < 255
      @sprites["bg1"].opacity -= 32 if @sprites["bg1"] rescue nil if i > 3
      @sprites["bg2"].opacity -= 32 if @sprites["bg2"] rescue nil if i > 3
      @sprites["pager"].opacity -= 32 if @sprites["pager"] rescue nil if i > 3
      @sprites["pager2"].opacity -= 32 if @sprites["pager2"] rescue nil if i > 3
      @sprites["char"].opacity -= 32 if @sprites["char"] rescue nil
      @sprites["char2"].opacity -= 32 if @sprites["char2"] rescue nil
      @sprites["text"].opacity -= 32 if @sprites["text"] rescue nil
      @sprites["up"].opacity -= 32 if @sprites["up"]
      @sprites["down"].opacity -= 32 if @sprites["down"]
      for j in 0...@ongoing.size
        @sprites["ongoing#{j}"].opacity -= 32 if @sprites["ongoing#{j}"] rescue nil
      end
      for j in 0...@completed.size
        @sprites["completed#{j}"].opacity -= 32 if @sprites["completed#{j}"] rescue nil
      end
    end
    @sprites["up"].dispose
    @sprites["down"].dispose
    @main.clear if @main
    @text.clear if @text rescue nil
    @text2.clear if @text2 rescue nil
    @sel_two = 0
    @scene = 0
    pbDrawOutlineText(@main, 0, 2, 512, 384, "Journal de Quête", Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
    pbDrawOutlineText(@main, 0, 142, 512, 384, "En cours: " + @ongoing.size.to_s, Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
    pbDrawOutlineText(@main, 0, 198, 512, 384, "Terminées: " + @completed.size.to_s, Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
    12.times do |i|
      Graphics.update
      @sprites["bg0"].opacity += 32 if i < 8
      @sprites["btn0"].opacity += 32 if i > 3
      @sprites["btn1"].opacity += 32 if i > 3
      @sprites["main"].opacity += 48 if i > 5
    end
  end

  def pbSwitch(dir)
    if dir == :DOWN
      return if @sel_one == 1
      @sprites["btn#{@sel_one}"].src_rect.y = 0
      @sel_one += 1
      @sprites["btn#{@sel_one}"].src_rect.y = (@sprites["btn#{@sel_one}"].bitmap.height / 2).round
    else
      return if @sel_one == 0
      @sprites["btn#{@sel_one}"].src_rect.y = 0
      @sel_one -= 1
      @sprites["btn#{@sel_one}"].src_rect.y = (@sprites["btn#{@sel_one}"].bitmap.height / 2).round
    end
  end

  def pbMove(dir)
    pbWait(1)
    if dir == :DOWN
      return if @sel_two == @ongoing.size - 1 && @mode == 0
      return if @sel_two == @completed.size - 1 && @mode == 1
      return if @ongoing.size == 0 && @mode == 0
      return if @completed.size == 0 && @mode == 1
      @sprites["ongoing#{@box}"].src_rect.y = 0 if @mode == 0
      @sprites["completed#{@box}"].src_rect.y = 0 if @mode == 1
      @sel_two += 1
      @box += 1
      @box = 5 if @box > 5
      @sprites["ongoing#{@box}"].src_rect.y = (@sprites["ongoing#{@box}"].bitmap.height / 2).round if @mode == 0
      @sprites["completed#{@box}"].src_rect.y = (@sprites["completed#{@box}"].bitmap.height / 2).round if @mode == 1
      if @box == 5
        @main.clear if @main
        if @mode == 0
          for i in 0...@ongoing.size
            break if i > 5
            j = (i == 0 ? -5 : (i == 1 ? -4 : (i == 2 ? -3 : (i == 3 ? -2 : (i == 4 ? -1 : 0)))))
            @sprites["ongoing#{i}"].quest = @ongoing[@sel_two + j]
            pbDrawOutlineText(@main, 11, getCellYPosition(i), 512, 384, @ongoing[@sel_two + j].name, @ongoing[@sel_two + j].color, Color.new(0, 0, 0), 1)
          end
          if @sprites["ongoing0"] != @ongoing[0]
            @sprites["up"].visible = true
          else
            @sprites["up"].visible = false
          end
          if @sprites["ongoing5"] != @ongoing[@ongoing.size - 1]
            @sprites["down"].visible = true
          else
            @sprites["down"].visible = false
          end
          pbDrawOutlineText(@main, 0, 2, 512, 384, "Quêtes en cours", Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
        else
          for i in 0...@completed.size
            break if i > 5
            j = (i == 0 ? -5 : (i == 1 ? -4 : (i == 2 ? -3 : (i == 3 ? -2 : (i == 4 ? -1 : 0)))))
            @sprites["completed#{i}"].quest = @completed[@sel_two + j]
            pbDrawOutlineText(@main, 11, getCellYPosition(i), 512, 384, @completed[@sel_two + j].name, @completed[@sel_two + j].color, Color.new(0, 0, 0), 1)
          end
          if @sprites["completed0"] != @completed[0]
            @sprites["up"].visible = true
          else
            @sprites["up"].visible = false
          end
          if @sprites["completed5"] != @completed[@completed.size - 1]
            @sprites["down"].visible = true
          else
            @sprites["down"].visible = false
          end
          pbDrawOutlineText(@main, 0, 2 - 178, 512, 384, "Quêtes terminées", Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
        end
      end
    else
      return if @sel_two == 0
      return if @ongoing.size == 0 && @mode == 0
      return if @completed.size == 0 && @mode == 1
      @sprites["ongoing#{@box}"].src_rect.y = 0 if @mode == 0
      @sprites["completed#{@box}"].src_rect.y = 0 if @mode == 1
      @sel_two -= 1
      @box -= 1
      @box = 0 if @box < 0
      @sprites["ongoing#{@box}"].src_rect.y = (@sprites["ongoing#{@box}"].bitmap.height / 2).round if @mode == 0
      @sprites["completed#{@box}"].src_rect.y = (@sprites["completed#{@box}"].bitmap.height / 2).round if @mode == 1
      if @box == 0
        @main.clear if @main
        if @mode == 0
          for i in 0...@ongoing.size
            break if i > 5
            @sprites["ongoing#{i}"].quest = @ongoing[@sel_two + i]
            pbDrawOutlineText(@main, 11, getCellYPosition(i), 512, 384, @ongoing[@sel_two + i].name, @ongoing[@sel_two + i].color, Color.new(0, 0, 0), 1)
          end
          if @sprites["ongoing5"] != @ongoing[0]
            @sprites["up"].visible = true
          else
            @sprites["up"].visible = false
          end
          if @sprites["ongoing5"] != @ongoing[@ongoing.size - 1]
            @sprites["down"].visible = true
          else
            @sprites["down"].visible = false
          end
          pbDrawOutlineText(@main, 0, 2, 512, 384, "Quêtes en cours", Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
        else
          for i in 0...@completed.size
            break if i > 5
            @sprites["completed#{i}"].quest = @completed[@sel_two + i]
            pbDrawOutlineText(@main, 11, getCellYPosition(i), 512, 384, @completed[@sel_two + i].name, @completed[@sel_two + i].color, Color.new(0, 0, 0), 1)
          end
          if @sprites["completed0"] != @completed[0]
            @sprites["up"].visible = true
          else
            @sprites["up"].visible = false
          end
          if @sprites["completed5"] != @completed[@completed.size - 1]
            @sprites["down"].visible = true
          else
            @sprites["down"].visible = false
          end
          pbDrawOutlineText(@main, 0, 2 - 178, 512, 384, "Quêtes terminées", Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
        end
      end
    end
    pbWait(4)
  end

  def pbList(id)
    pbWait(2)
    @sel_two = 0
    @page = 0
    @scene = 1
    @mode = id
    @box = 0
    @sprites["up"] = IconSprite.new(0, 0, @viewport)
    @sprites["up"].setBitmap("Graphics/Pictures/EQI/quest_arrow")
    @sprites["up"].zoom_x = 1.25
    @sprites["up"].zoom_y = 1.25
    @sprites["up"].x = Graphics.width / 2
    @sprites["up"].y = 36
    @sprites["up"].z = 2
    @sprites["up"].visible = false
    @sprites["down"] = IconSprite.new(0, 0, @viewport)
    @sprites["down"].setBitmap("Graphics/Pictures/EQI/quest_arrow")
    @sprites["down"].zoom_x = 1.25
    @sprites["down"].zoom_y = 1.25
    @sprites["down"].x = Graphics.width / 2 + 21
    @sprites["down"].y = 360
    @sprites["down"].z = 2
    @sprites["down"].angle = 180
    @sprites["down"].visible = @mode == 0 ? @ongoing.size > 6 : @completed.size > 6
    @sprites["down"].opacity = 0
    10.times do |i|
      Graphics.update
      @sprites["btn0"].opacity -= 32 if i > 1
      @sprites["btn1"].opacity -= 32 if i > 1
      @sprites["main"].opacity -= 32 if i > 1
      @sprites["bg1"].opacity -= 32 if @sprites["bg1"] rescue nil if i > 1
      @sprites["bg2"].opacity -= 32 if @sprites["bg2"] rescue nil if i > 1
      @sprites["pager"].opacity -= 32 if @sprites["pager"] rescue nil if i > 1
      @sprites["pager2"].opacity -= 32 if @sprites["pager2"] rescue nil if i > 1
      if @sprites["char"]
        @sprites["char"].opacity -= 32 rescue nil
      end
      if @sprites["char2"]
        @sprites["char2"].opacity -= 32 rescue nil
      end
      @sprites["text"].opacity -= 32 if @sprites["text"] rescue nil if i > 1
      @sprites["text2"].opacity -= 32 if @sprites["text"] rescue nil if i > 1
    end

    @main.clear if @main
    @text.clear if @text rescue nil
    @text2.clear if @text2 rescue nil
    if id == 0
      for i in 0...@ongoing.size
        break if i > 5
        @sprites["ongoing#{i}"] = QuestSprite.new(0, 0, @viewport)
        @sprites["ongoing#{i}"].setBitmap("Graphics/Pictures/EQI/quest_button")
        @sprites["ongoing#{i}"].quest = @ongoing[i]
        @sprites["ongoing#{i}"].x = 94
        @sprites["ongoing#{i}"].y = 42 + 52 * i
        @sprites["ongoing#{i}"].src_rect.height = (@sprites["ongoing#{i}"].bitmap.height / 2).round
        @sprites["ongoing#{i}"].src_rect.y = (@sprites["ongoing#{i}"].bitmap.height / 2).round if i == @sel_two
        @sprites["ongoing#{i}"].opacity = 0
        pbDrawOutlineText(@main, 11, getCellYPosition(i), 512, 384, @ongoing[i].name, @ongoing[i].color, Color.new(0, 0, 0), 1)

        #pbDrawOutlineText(@main, 11, -124 + 52 * i, 512, 384, @ongoing[i].name, @ongoing[i].color, Color.new(0, 0, 0), 1)
      end
      pbDrawOutlineText(@main, 0, 175, 512, 384, "Aucune Quête en Cours", pbColor(:WHITE), pbColor(:BLACK), 1) if @ongoing.size == 0
      pbDrawOutlineText(@main, 0, 2, 512, 384, "Quêtes en Cours", Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
      12.times do |i|
        Graphics.update
        @sprites["main"].opacity += 32 if i < 8
        for j in 0...@ongoing.size
          break if j > 5
          @sprites["ongoing#{j}"].opacity += 32 if i > 3
        end
      end
    elsif id == 1
      for i in 0...@completed.size
        break if i > 5
        @sprites["completed#{i}"] = QuestSprite.new(0, 0, @viewport)
        @sprites["completed#{i}"].setBitmap("Graphics/Pictures/EQI/quest_button")
        @sprites["completed#{i}"].x = 94
        @sprites["completed#{i}"].y = 42 + 52 * i
        @sprites["completed#{i}"].src_rect.height = (@sprites["completed#{i}"].bitmap.height / 2).round
        @sprites["completed#{i}"].src_rect.y = (@sprites["completed#{i}"].bitmap.height / 2).round if i == @sel_two
        @sprites["completed#{i}"].opacity = 0
        pbDrawOutlineText(@main, 11, getCellYPosition(i), 512, 384, @completed[i].name, @completed[i].color, Color.new(0, 0, 0), 1)
      end

      pbDrawOutlineText(@main, 0, 175, 512, 384, "Aucune Quête Terminée", pbColor(:WHITE), pbColor(:BLACK), 1) if @completed.size == 0
      pbDrawOutlineText(@main, 0, 2, 512, 384, "Quête Terminée", Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
      12.times do |i|
        Graphics.update
        @sprites["main"].opacity += 32 if i < 8
        @sprites["down"].opacity += 32 if i > 3
        for j in 0...@completed.size
          break if j > 5
          @sprites["completed#{j}"].opacity += 32 if i > 3
        end
      end
    end
  end

  def getCellYPosition(i)
    return 56 + (52 * i)
  end

  def pbEnd
    12.times do |i|
      Graphics.update
      @sprites["bg0"].opacity -= 32 if @sprites["bg0"] && i > 3
      @sprites["btn0"].opacity -= 32 if @sprites["btn0"]
      @sprites["btn1"].opacity -= 32 if @sprites["btn1"]
      @sprites["main"].opacity -= 32 if @sprites["main"]
      @sprites["char"].opacity -= 40 if @sprites["char"] rescue nil
      @sprites["char2"].opacity -= 40 if @sprites["char2"] rescue nil
    end
  end
end

#TODO: à terminer
def pbSynchronizeQuestLog()
  ########################
  ### Quest started    ###
  ########################
  #Pewter
  pbAddQuest(0) if $game_switches[926]
  pbAddQuest(1) if $game_switches[927]

  #Cerulean
  pbAddQuest(3) if $game_switches[931]
  pbAddQuest(4) if $game_switches[942] || $game_self_switches[[462, 7, "A"]]

  #Vermillion
  pbAddQuest(10) if $game_self_switches[[464, 6, "A"]]
  pbAddQuest(11) if $game_switches[945]
  pbAddQuest(12) if $game_switches[929]
  pbAddQuest(13) if $game_switches[175]

  #Celadon
  pbAddQuest(14) if $game_self_switches[[466, 10, "A"]]
  pbAddQuest(15) if $game_switches[185]
  pbAddQuest(16) if $game_switches[946]
  pbAddQuest(17) if $game_switches[172]

  #Fuchsia
  pbAddQuest(18) if $game_switches[941]
  pbAddQuest(19) if $game_switches[943]
  pbAddQuest(20) if $game_switches[949]

  #Crimson
  pbAddQuest(21) if $game_switches[940]
  pbAddQuest(22) if $game_self_switches[[177, 9, "A"]]
  pbAddQuest(23) if $game_self_switches[[177, 8, "A"]]

  #Saffron
  pbAddQuest(24) if $game_switches[932]
  pbAddQuest(25) if $game_self_switches[[111, 19, "A"]]
  pbAddQuest(26) if $game_switches[948]
  pbAddQuest(27) if $game_switches[339]
  pbAddQuest(28) if $game_switches[300]

  #Cinnabar
  pbAddQuest(29) if $game_switches[904]
  pbAddQuest(30) if $game_switches[903]

  #Goldenrod
  pbAddQuest(31) if $game_self_switches[[244, 5, "A"]]
  pbAddQuest(32) if $game_self_switches[[244, 8, "A"]]

  #Violet
  pbSetQuest(33, true) if $game_switches[908]
  pbSetQuest(34, true) if $game_switches[410]

  #Blackthorn
  pbSetQuest(35, true) if $game_self_switches[[332, 10, "A"]]
  pbSetQuest(36, true) if $game_self_switches[[332, 8, "A"]]
  pbSetQuest(37, true) if $game_self_switches[[332, 5, "B"]]

  #Ecruteak
  pbSetQuest(38, true) if $game_self_switches[[576, 9, "A"]]
  pbSetQuest(39, true) if $game_self_switches[[576, 8, "A"]]

  #Kin
  pbSetQuest(40, true) if $game_switches[526]
  pbSetQuest(41, true) if $game_self_switches[[565, 10, "A"]]

  ########################
  ### Quest finished    ###
  ########################
  #Pewter
  pbSetQuest(0, true) if $game_self_switches[[460, 5, "A"]]
  pbSetQuest(1, true) if $game_self_switches[[460, 7, "A"]] || $game_self_switches[[460, 7, "B"]]
  if $game_self_switches[[460, 9, "A"]]
    pbAddQuest(2)
    pbSetQuest(2, true)
  end

  #Cerulean
  if $game_self_switches[[462, 8, "A"]]
    pbAddQuest(5)
    pbSetQuest(5, true)
  end
  pbSetQuest(3, true) if $game_switches[931] && !$game_switches[939]
  pbSetQuest(4, true) if $game_self_switches[[462, 7, "A"]]

  #Vermillion
  pbSetQuest(13, true) if $game_self_switches[[19, 19, "B"]]
  if $game_self_switches[[464, 8, "A"]]
    pbAddQuest(9)
    pbSetQuest(9, true)
  end
  pbSetQuest(10, true) if $game_self_switches[[464, 6, "B"]]
  pbSetQuest(11, true) if $game_variables[145] >= 1
  pbSetQuest(12, true) if $game_self_switches[[464, 5, "A"]]

  #Celadon
  pbSetQuest(14, true) if $game_self_switches[[466, 10, "A"]]
  pbSetQuest(15, true) if $game_switches[947]
  pbSetQuest(16, true) if $game_self_switches[[466, 9, "A"]]
  pbSetQuest(17, true) if $game_self_switches[[509, 5, "D"]]

  #Fuchsia
  pbSetQuest(18, true) if $game_self_switches[[478, 6, "A"]]
  pbSetQuest(19, true) if $game_self_switches[[478, 8, "A"]]
  pbSetQuest(20, true) if $game_switches[922]

  #Crimson
  pbSetQuest(21, true) if $game_self_switches[[177, 5, "A"]]
  pbSetQuest(22, true) if $game_self_switches[[177, 9, "A"]]
  pbSetQuest(23, true) if $game_self_switches[[177, 8, "A"]]

  #Saffron
  pbSetQuest(24, true) if $game_switches[938]
  pbSetQuest(25, true) if $game_self_switches[[111, 19, "A"]]
  pbSetQuest(26, true) if $game_self_switches[[111, 9, "A"]]
  pbSetQuest(27, true) if $game_switches[338]
  pbSetQuest(28, true) if $game_self_switches[[111, 18, "A"]]

  #Cinnabar
  pbSetQuest(29, true) if $game_self_switches[[136, 5, "A"]]
  pbSetQuest(30, true) if $game_self_switches[[136, 8, "A"]]

  #Goldenrod
  pbSetQuest(31, true) if $game_self_switches[[244, 5, "A"]]
  pbSetQuest(32, true) if $game_self_switches[[244, 8, "B"]]

  #Violet
  pbSetQuest(33, true) if $game_self_switches[[274, 5, "A"]]
  pbSetQuest(34, true) if $game_self_switches[[274, 8, "A"]] || $game_self_switches[[274, 8, "B"]]

  #Blackthorn
  pbSetQuest(35, true) if $game_self_switches[[332, 10, "A"]]
  pbSetQuest(36, true) if $game_switches[337]
  pbSetQuest(37, true) if $game_self_switches[[332, 5, "A"]]

  #Ecruteak
  pbSetQuest(38, true) if $game_self_switches[[576, 9, "A"]]
  pbSetQuest(39, true) if $game_self_switches[[576, 8, "A"]]

  #Kin
  pbSetQuest(40, true) if $game_self_switches[[565, 9, "A"]]
  pbSetQuest(41, true) if $game_self_switches[[565, 10, "A"]]

end



def showQuestStatistics(eventId,includeRocketQuests=false)
  quests_accepted = []
  quests_in_progress=[]
  quests_completed=[]
  $Trainer.quests=[] if !$Trainer.quests
  for quest in $Trainer.quests
    next if quest.npc == QuestBranchRocket && !includeRocketQuests
    quests_accepted<<quest
    if quest.completed
      quests_completed << quest
    else
      quests_in_progress << quest
    end
  end
  pbCallBub(2, eventId)
  pbMessage("Quêtes acceptées: \\C[1]#{quests_accepted.length}")
  pbCallBub(2, eventId)
  pbMessage("Quêtes terminées: \\C[1]#{quests_completed.length}")
  pbCallBub(2, eventId)
  pbMessage("En cours: \\C[1]#{quests_in_progress.length}")
end

def get_completed_quests(includeRocketQuests=false)
  quests_completed=[]
  for quest in $Trainer.quests
    next if quest.npc == QuestBranchRocket && !includeRocketQuests
    quests_completed << quest if quest.completed
  end
  return quests_completed
end

def getQuestReward(eventId)
  $PokemonGlobal.questRewardsObtained = [] if !$PokemonGlobal.questRewardsObtained
  nb_quests_completed = get_completed_quests(false).length #pbGet(VAR_STAT_QUESTS_COMPLETED)
  pbSet(VAR_STAT_QUESTS_COMPLETED,nb_quests_completed)
  rewards_to_give = []
  for reward in QUEST_REWARDS
    rewards_to_give << reward if nb_quests_completed >= reward.nb_quests && !$PokemonGlobal.questRewardsObtained.include?(reward.item)
  end

  #Calculate how many until next reward
  next_reward = get_next_quest_reward
  nb_to_next_reward = next_reward.nb_quests - nb_quests_completed

  for reward in rewards_to_give
    echoln reward.item

  end
  #Give rewards
  for reward in rewards_to_give
    if !reward.can_have_multiple && $PokemonBag.pbQuantity(reward.item) >= 1
      $PokemonGlobal.questRewardsObtained << reward.item
      next
    end
    pbCallBub(2, eventId)
    pbMessage("Et puis, il y a encore une chose...")
    pbCallBub(2, eventId)
    pbMessage("En guise de cadeau pour avoir aidé tant de personnes, je veux vous offrir ceci.")
    pbReceiveItem(reward.item, reward.quantity)
    $PokemonGlobal.questRewardsObtained << reward.item

    #recalculate nb to next reward
    next_reward = get_next_quest_reward
    nb_to_next_reward = next_reward.nb_quests - nb_quests_completed
  end


  pbCallBub(2, eventId)
  if nb_to_next_reward <= 0
    pbMessage("Je n'ai plus de récompenses à vous offrir! Merci d'aider toutes ces personnes!")
  elsif nb_to_next_reward == 1
    pbMessage("Aidez #{nb_to_next_reward} personnes supplémentaires et je vous donnerai quelque chose de bien!")
  else
    pbMessage("Aidez #{nb_to_next_reward} personnes supplémentaires et je vous donnerai quelque chose de bien!")
  end
end

def get_next_quest_reward()
  for reward in QUEST_REWARDS
    nextReward = reward
    break if !$PokemonGlobal.questRewardsObtained.include?(reward.item)
  end
  # rewards_to_give << nextReward if nb_to_next_reward <=0 #for compatibility with old system
  return nextReward
end
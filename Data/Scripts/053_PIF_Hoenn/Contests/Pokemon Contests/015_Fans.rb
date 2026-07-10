#====================================================================================
#  Fans 
#====================================================================================

#====================================================================================
#================================== Fans Settings ===================================
#====================================================================================

module ContestSettings
	FAN_ITEMS = [
		[:ASPEARBERRY,:CHERIBERRY,:CHESTOBERRY,:FRESHWATER,:LEPPABERRY,:LUMIOSEGALETTE,:OLDGATEAU,
			:ORANBERRY,:PECHABERRY,:PERSIMBERRY,:RAGECANDYBAR,:RAWSTBERRY,:SHALOURSABLE,:SWEETHEART], #Normal Rank
		[:AGUAVBERRY,:BLUKBERRY,:FIGYBERRY,:HONEY,:IAPAPABERRY,:LUMIOSEGALETTE,:MAGOBERRY,:NANABBERRY,
			:OLDGATEAU,:PINAPBERRY,:RAGECANDYBAR,:RAZZBERRY,:SHALOURSABLE,:SITRUSBERRY,:SODAPOP,
			:STARDUST,:WEPEARBERRY,:WIKIBERRY], #Super Rank
		[:BELUEBERRY,:CORNNBERRY,:DURINBERRY,:GREPABERRY,:HEARTSCALE,:HONDEWBERRY,:KELPSYBERRY,
			:LEMONADE,:LUMIOSEGALETTE,:MAGOSTBERRY,:NOMELBERRY,:OLDGATEAU,:PAMTREBERRY,:POMEGBERRY,
			:QUALOTBERRY,:RABUTABERRY,:RAGECANDYBAR,:SHALOURSABLE,:SPELONBERRY,:STARPIECE,:TAMATOBERRY,:WATMELBERRY], #Hyper Rank
		[:BABIRIBERRY,:CHARTIBERRY,:CHILANBERRY,:CHOPLEBERRY,:COBABERRY,:COLBURBERRY,:COMETSHARD,
			:DESTINYKNOT,:HABANBERRY,:KASIBBERRY,:KEBIABERRY,:LUMIOSEGALETTE,:MOOMOOMILK,:OCCABERRY,
			:OLDGATEAU,:PASSHOBERRY,:PAYAPABERRY,:RAGECANDYBAR,:RINDOBERRY,:ROSELIBERRY,:SHALOURSABLE,
			:SHUCABERRY,:TANGABERRY,:WACANBERRY,:YACHEBERRY] #Master Rank
	]
end
def pbNumberContestsParticipated(rank: nil, category: nil)
	$Trainer.stats.initializeContestStats if !$Trainer.stats.pokemon_contests_participated_total
	rank = ContestFunctions.sanitizeRank(rank) if rank
	category = ContestFunctions.sanitizeCategory(category) if category
	if rank && category
		return $Trainer.stats.pokemon_contests_participated_category_rank[category][rank]
	elsif rank
		return $Trainer.stats.pokemon_contests_participated_rank[rank]
	elsif category
		return $Trainer.stats.pokemon_contests_participated_category[category]
	else
		return $Trainer.stats.pokemon_contests_participated_total
	end
end

def pbNumContestsPart(r: nil, c: nil)
	return pbNumberContestsParticipated(rank: r, category: c)
end

def pbNumberContestsWon(rank: nil, category: nil)
	$Trainer.stats.initializeContestStats if !$Trainer.stats.pokemon_contests_won_total
	rank = ContestFunctions.sanitizeRank(rank) if rank
	category = ContestFunctions.sanitizeCategory(category) if category
	if rank && category
		return $Trainer.stats.pokemon_contests_won_category_rank[category][rank]
	elsif rank
		return $Trainer.stats.pokemon_contests_won_rank[rank]
	elsif category
		return $Trainer.stats.pokemon_contests_won_category[category]
	else
		return $Trainer.stats.pokemon_contests_won_total
	end
end

def pbNumContestsWon(r: nil, c: nil)
	return pbNumberContestsWon(rank: r, category: c)
end

def pbGiveFanItem(rank = 0)
	rank = ContestFunctions.sanitizeRank(rank)
	items = ContestSettings::FAN_ITEMS[rank]
	pbReceiveItem(items[rand(items.length)])
end
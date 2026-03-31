//status effect for Biosphere system animals
	//contains:
	// eco_life
	// eco_nest_search
	//



//Aging mechanism. Makes them take brute damage over their life until they die.
/datum/status_effect/bio_life
	id = "bio_life"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = 0.4 SECONDS

/datum/status_effect/bio_life/tick(seconds_between_ticks)
	. = ..()
	if(owner.stat == DEAD)
		return
	if(owner.stat == CONSCIOUS)
		owner.adjustBruteLoss(BRUTELOSS, 1, TRUE, FALSE, FALSE, "bio_life")

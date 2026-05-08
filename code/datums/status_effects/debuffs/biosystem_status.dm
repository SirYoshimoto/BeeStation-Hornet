//status effect for Biosphere system animals
	//contains:
	// bio_life
	// bio_rot

//Aging mechanism. Makes them take brute damage over their life until they die.
/datum/status_effect/bio_life
	id = "bio_life"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = 4 SECONDS

/datum/status_effect/bio_life/tick(seconds_between_ticks)
	. = ..()
	if(owner.stat == DEAD)
		return
	if(owner.stat == CONSCIOUS)
		owner.adjustBruteLoss(BRUTELOSS, 0.5, TRUE, FALSE, FALSE, "bio_life")

//Rotting mechanism. Rots the body after sometime
/datum/status_effect/bio_rot
	id = "bio_rot"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = 1 SECONDS

/datum/status_effect/bio_rot/tick(seconds_between_ticks)
	if(owner.stat == CONSCIOUS)
		return
	if(owner.stat == DEAD)
		owner.adjustBruteLoss(BRUTELOSS, 1, TRUE, FALSE, FALSE, "bio_rot")

//Spawns A bunch of animals when spawned after some time. Then stops and acts as a nesting spot for animals. Should make 20 hares for 10 seconds.
/datum/status_effect/bio_nest
	id = "bio_nest"
	duration = 10 SECONDS
	tick_interval = 1 SECONDS

/datum/status_effect/bio_nest/tick(seconds_between_ticks)
	spawn_atom_to_turf(/mob/living/basic/biosystem_animals/hare_bio, owner, 2, FALSE)


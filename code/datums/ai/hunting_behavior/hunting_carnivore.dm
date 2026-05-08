/datum/ai_planning_subtree/find_and_hunt_target/carnivore
	hunt_range = 3
	hunt_targets = list(/mob/living/basic/biosystem_animals/hare_bio,)
	hunting_behavior = /datum/ai_behavior/hunt_target/carnivore

//Should kill the target first, and then eat its body
/datum/ai_behavior/hunt_target/carnivore
	var/eat_emote = "devours"
	hunt_cooldown = 20 SECONDS
	hunt_emote = "crunches"
	var/time/eat_delay = 3 SECONDS
	var/time/eat_started

/datum/ai_behavior/hunt_target/carnivore/target_caught(mob/living/hunter, atom/hunted)
	if(isliving(hunted)) // Are we hunting a living mob?
		var/mob/living/living_target = hunted
		hunter.manual_emote("[hunt_emote] [living_target]!")
		living_target.investigate_log("has been killed by [key_name(hunter)].", INVESTIGATE_DEATHS)
		living_target.death()
		// Now eat the body
		hunter.manual_emote("[eat_emote] [living_target]!")
		qdel(living_target)
	if(isdead(hunted)) // Eat it anways, little bit of rotten flesh can't hurt now can it?
		var/mob/living/dead_target = hunted
		hunter.manual_emote("[eat_emote] [dead_target]!")
		qdel(dead_target)
	else if(IS_EDIBLE(hunted))
		hunted.attack_animal(hunter)
	else // We're hunting an object, and should delete it instead of killing it. Mostly useful for decal bugs like ants or spider webs.
		hunter.manual_emote("[hunt_emote] [hunted]!")
		qdel(hunted)

/*/datum/ai_behavior/hunt_target/carnivore/perform(delta_time, datum/ai_controller/controller, hunting_target_key, hunting_cooldown_key)
    if(!eat_started)
        eat_started = world.time

    if(world.time < eat_started + eat_delay)
        return AI_BEHAVIOR_DELAY

    return ..()
*/
